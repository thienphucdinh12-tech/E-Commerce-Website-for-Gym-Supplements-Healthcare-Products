package utils;

import com.google.gson.JsonObject;
import com.google.gson.JsonParser;
import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.net.HttpURLConnection;
import java.net.URL;
import java.net.URLEncoder;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.HashMap;
import java.util.Map;

public class NutritionService {

    // Configurable FatSecret API credentials
    private static final String FATSECRET_TOKEN_URL = "https://oauth.fatsecret.com/connect/token";
    private static final String FATSECRET_API_URL = "https://platform.fatsecret.com/rest/server.api";
    private static final String FATSECRET_CLIENT_ID = "37fe0750c7694260991b282292144f57";
    private static final String FATSECRET_CLIENT_SECRET = "9b2a6864509048d9a1edb3e1a5de185e";

    // In-memory token cache
    private static String cachedToken = null;
    private static long tokenExpiryTime = 0;

    // Food nutrition data container
    public static class FoodNutrition {
        public String name;
        public int calories;
        public double protein;
        public double carbs;
        public double fat;
        public String servingSize;
        public String source; // "LOCAL" or "FATSECRET_API" or "MOCK_FALLBACK"
        public String description;

        public FoodNutrition(String name, int calories, double protein, double carbs, double fat, String servingSize, String source, String description) {
            this.name = name;
            this.calories = calories;
            this.protein = protein;
            this.carbs = carbs;
            this.fat = fat;
            this.servingSize = servingSize;
            this.source = source;
            this.description = description;
        }
    }

    /**
     * Get nutrition info for a specific food.
     * Checks local Custom_Foods first, then calls FatSecret API.
     * Falls back to international mock data if API is unconfigured/offline.
     */
    public static FoodNutrition getNutritionInfo(String queryFood) {
        if (queryFood == null || queryFood.trim().isEmpty()) {
            return null;
        }
        
        String cleanFood = queryFood.trim();

        // 1. Search in local custom database first
        FoodNutrition localFood = getLocalNutrition(cleanFood);
        if (localFood != null) {
            return localFood;
        }

        // 2. Call FatSecret API
        if (!"YOUR_FATSECRET_CLIENT_ID".equals(FATSECRET_CLIENT_ID) && !FATSECRET_CLIENT_ID.isEmpty() &&
            !"YOUR_FATSECRET_CLIENT_SECRET".equals(FATSECRET_CLIENT_SECRET) && !FATSECRET_CLIENT_SECRET.isEmpty()) {
            try {
                FoodNutrition apiFood = fetchFromFatSecretAPI(cleanFood);
                if (apiFood != null) {
                    return apiFood;
                }
            } catch (Exception e) {
                System.err.println("Error calling FatSecret API: " + e.getMessage());
            }
        }

        // 3. Fallback to mock data for common international foods to ensure robust testability
        return getMockFallbackNutrition(cleanFood);
    }

    /**
     * Query Custom_Foods table in local SQL Server database.
     */
    private static FoodNutrition getLocalNutrition(String foodName) {
        String sql = "SELECT food_name, calories, protein_g, carbs_g, fat_g, serving_size, description " +
                     "FROM Custom_Foods WHERE food_name LIKE ?";
        try (Connection conn = DBUtils.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, "%" + foodName + "%");
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return new FoodNutrition(
                        rs.getString("food_name"),
                        rs.getInt("calories"),
                        rs.getDouble("protein_g"),
                        rs.getDouble("carbs_g"),
                        rs.getDouble("fat_g"),
                        rs.getString("serving_size"),
                        "LOCAL",
                        rs.getString("description")
                    );
                }
            }
        } catch (Exception e) {
            System.err.println("Error querying local Custom_Foods database: " + e.getMessage());
            e.printStackTrace();
        }
        return null;
    }

    /**
     * Safely retrieves cached token or requests a new one from FatSecret.
     */
    private static synchronized String getAccessToken() throws Exception {
        if (cachedToken != null && System.currentTimeMillis() < tokenExpiryTime) {
            return cachedToken;
        }

        if ("YOUR_FATSECRET_CLIENT_ID".equals(FATSECRET_CLIENT_ID) || FATSECRET_CLIENT_ID.isEmpty() ||
            "YOUR_FATSECRET_CLIENT_SECRET".equals(FATSECRET_CLIENT_SECRET) || FATSECRET_CLIENT_SECRET.isEmpty()) {
            throw new Exception("FatSecret credentials not configured.");
        }

        URL url = new URL(FATSECRET_TOKEN_URL);
        HttpURLConnection conn = (HttpURLConnection) url.openConnection();
        conn.setRequestMethod("POST");
        
        // Basic Authorization: client_id:client_secret base64 encoded
        String credentials = FATSECRET_CLIENT_ID + ":" + FATSECRET_CLIENT_SECRET;
        String basicAuth = java.util.Base64.getEncoder().encodeToString(credentials.getBytes("UTF-8"));
        
        conn.setRequestProperty("Authorization", "Basic " + basicAuth);
        conn.setRequestProperty("Content-Type", "application/x-www-form-urlencoded");
        conn.setDoOutput(true);
        conn.setConnectTimeout(5000);
        conn.setReadTimeout(5000);

        try (java.io.OutputStream os = conn.getOutputStream()) {
            byte[] input = "grant_type=client_credentials".getBytes("utf-8");
            os.write(input, 0, input.length);
        }

        int responseCode = conn.getResponseCode();
        if (responseCode == 200) {
            try (BufferedReader in = new BufferedReader(new InputStreamReader(conn.getInputStream(), "UTF-8"))) {
                StringBuilder response = new StringBuilder();
                String line;
                while ((line = in.readLine()) != null) {
                    response.append(line);
                }
                
                JsonObject json = JsonParser.parseString(response.toString()).getAsJsonObject();
                cachedToken = json.get("access_token").getAsString();
                
                int expiresIn = json.has("expires_in") ? json.get("expires_in").getAsInt() : 3600;
                tokenExpiryTime = System.currentTimeMillis() + (expiresIn * 1000L) - 60000L;
                
                return cachedToken;
            }
        } else {
            try (BufferedReader in = new BufferedReader(new InputStreamReader(conn.getErrorStream(), "UTF-8"))) {
                StringBuilder err = new StringBuilder();
                String line;
                while ((line = in.readLine()) != null) {
                    err.append(line);
                }
                throw new Exception("Auth failed with status " + responseCode + ": " + err.toString());
            }
        }
    }

    /**
     * Make HTTP call to FatSecret API.
     */
    private static FoodNutrition fetchFromFatSecretAPI(String foodName) throws Exception {
        String token = getAccessToken();
        if (token == null) {
            return null;
        }

        String encodedFood = URLEncoder.encode(foodName, "UTF-8");
        String urlString = FATSECRET_API_URL + "?method=foods.search&format=json&search_expression=" + encodedFood;
        
        URL url = new URL(urlString);
        HttpURLConnection conn = (HttpURLConnection) url.openConnection();
        conn.setRequestMethod("GET");
        conn.setRequestProperty("Authorization", "Bearer " + token);
        conn.setRequestProperty("Content-Type", "application/json");
        conn.setConnectTimeout(5000);
        conn.setReadTimeout(5000);

        int responseCode = conn.getResponseCode();
        if (responseCode == 200) {
            try (BufferedReader in = new BufferedReader(new InputStreamReader(conn.getInputStream(), "UTF-8"))) {
                StringBuilder response = new StringBuilder();
                String line;
                while ((line = in.readLine()) != null) {
                    response.append(line);
                }
                
                JsonObject json = JsonParser.parseString(response.toString()).getAsJsonObject();
                if (!json.has("foods")) {
                    return null;
                }
                
                JsonObject foodsObj = json.getAsJsonObject("foods");
                if (foodsObj == null || !foodsObj.has("food")) {
                    return null;
                }
                
                JsonObject firstFood = null;
                if (foodsObj.get("food").isJsonArray()) {
                    com.google.gson.JsonArray foodArray = foodsObj.getAsJsonArray("food");
                    if (foodArray.size() > 0) {
                        firstFood = foodArray.get(0).getAsJsonObject();
                    }
                } else if (foodsObj.get("food").isJsonObject()) {
                    firstFood = foodsObj.getAsJsonObject("food");
                }
                
                if (firstFood != null) {
                    String name = firstFood.has("food_name") ? firstFood.get("food_name").getAsString() : foodName;
                    String desc = firstFood.has("food_description") ? firstFood.get("food_description").getAsString() : "";
                    
                    if (desc.isEmpty()) {
                        return null;
                    }
                    
                    // Parse pattern: Per [serving] - Calories: [val]kcal | Fat: [val]g | Carbs: [val]g | Protein: [val]g
                    String servingSize = "100g";
                    java.util.regex.Pattern pServing = java.util.regex.Pattern.compile("Per (.+?) - ");
                    java.util.regex.Matcher mServing = pServing.matcher(desc);
                    if (mServing.find()) {
                        servingSize = mServing.group(1);
                    }
                    
                    int calories = 0;
                    java.util.regex.Pattern pCal = java.util.regex.Pattern.compile("Calories: (\\d+)kcal");
                    java.util.regex.Matcher mCal = pCal.matcher(desc);
                    if (mCal.find()) {
                        calories = Integer.parseInt(mCal.group(1));
                    }
                    
                    double fat = 0.0;
                    java.util.regex.Pattern pFat = java.util.regex.Pattern.compile("Fat: ([\\d.]+)g");
                    java.util.regex.Matcher mFat = pFat.matcher(desc);
                    if (mFat.find()) {
                        fat = Double.parseDouble(mFat.group(1));
                    }
                    
                    double carbs = 0.0;
                    java.util.regex.Pattern pCarbs = java.util.regex.Pattern.compile("Carbs: ([\\d.]+)g");
                    java.util.regex.Matcher mCarbs = pCarbs.matcher(desc);
                    if (mCarbs.find()) {
                        carbs = Double.parseDouble(mCarbs.group(1));
                    }
                    
                    double protein = 0.0;
                    java.util.regex.Pattern pProtein = java.util.regex.Pattern.compile("Protein: ([\\d.]+)g");
                    java.util.regex.Matcher mProtein = pProtein.matcher(desc);
                    if (mProtein.find()) {
                        protein = Double.parseDouble(mProtein.group(1));
                    }

                    return new FoodNutrition(name, calories, protein, carbs, fat, servingSize, "FATSECRET_API", "Dữ liệu tra cứu tự động từ FatSecret API.");
                }
            }
        }
        return null;
    }

    /**
     * Mock fallback database for international foods.
     */
    private static FoodNutrition getMockFallbackNutrition(String foodName) {
        String lower = foodName.toLowerCase().trim();
        Map<String, FoodNutrition> mocks = new HashMap<>();

        mocks.put("apple", new FoodNutrition("Apple (Táo)", 52, 0.3, 14.0, 0.2, "100g", "MOCK_FALLBACK", "Táo tươi chứa nhiều chất xơ và vitamin C."));
        mocks.put("táo", new FoodNutrition("Apple (Táo)", 52, 0.3, 14.0, 0.2, "100g", "MOCK_FALLBACK", "Táo tươi chứa nhiều chất xơ và vitamin C."));
        mocks.put("banana", new FoodNutrition("Banana (Chuối)", 89, 1.1, 23.0, 0.3, "100g", "MOCK_FALLBACK", "Chuối chín giàu kali và cung cấp năng lượng nhanh chóng cho cơ thể."));
        mocks.put("chuối", new FoodNutrition("Banana (Chuối)", 89, 1.1, 23.0, 0.3, "100g", "MOCK_FALLBACK", "Chuối chín giàu kali và cung cấp năng lượng nhanh chóng cho cơ thể."));
        mocks.put("chicken breast", new FoodNutrition("Chicken Breast (Ức gà)", 165, 31.0, 0.0, 3.6, "100g", "MOCK_FALLBACK", "Ức gà luộc giàu protein tinh khiết, lý tưởng cho việc tăng cơ giảm mỡ."));
        mocks.put("ức gà", new FoodNutrition("Chicken Breast (Ức gà)", 165, 31.0, 0.0, 3.6, "100g", "MOCK_FALLBACK", "Ức gà luộc giàu protein tinh khiết, lý tưởng cho việc tăng cơ giảm mỡ."));
        mocks.put("salmon", new FoodNutrition("Salmon (Cá hồi)", 208, 20.0, 0.0, 13.0, "100g", "MOCK_FALLBACK", "Cá hồi giàu axit béo Omega-3 tốt cho tim mạch và não bộ."));
        mocks.put("cá hồi", new FoodNutrition("Salmon (Cá hồi)", 208, 20.0, 0.0, 13.0, "100g", "MOCK_FALLBACK", "Cá hồi giàu axit béo Omega-3 tốt cho tim mạch và não bộ."));
        mocks.put("egg", new FoodNutrition("Egg (Trứng gà)", 155, 13.0, 1.1, 11.0, "100g", "MOCK_FALLBACK", "Trứng gà luộc chứa nguồn protein sinh học cao và chất béo tốt."));
        mocks.put("trứng", new FoodNutrition("Egg (Trứng gà)", 155, 13.0, 1.1, 11.0, "100g", "MOCK_FALLBACK", "Trứng gà luộc chứa nguồn protein sinh học cao và chất béo tốt."));
        mocks.put("broccoli", new FoodNutrition("Broccoli (Súp lơ xanh)", 34, 2.8, 7.0, 0.4, "100g", "MOCK_FALLBACK", "Súp lơ xanh nhiều chất xơ, vitamin và khoáng chất chống oxy hóa."));
        mocks.put("súp lơ", new FoodNutrition("Broccoli (Súp lơ xanh)", 34, 2.8, 7.0, 0.4, "100g", "MOCK_FALLBACK", "Súp lơ xanh nhiều chất xơ, vitamin và khoáng chất chống oxy hóa."));

        for (Map.Entry<String, FoodNutrition> entry : mocks.entrySet()) {
            if (lower.contains(entry.getKey())) {
                return entry.getValue();
            }
        }
        return null;
    }
}

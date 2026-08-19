package utils;

import com.google.gson.Gson;
import com.google.gson.JsonArray;
import com.google.gson.JsonObject;
import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

public class GHNService {

    private static final String GHN_TOKEN = "8dd7cd88-58ab-11f1-a973-aee5264794df";
    private static final String GHN_SHOP_ID = "207689";
    private static final String API_URL = "https://dev-online-gateway.ghn.vn/shiip/public-api";

    private static final Gson gson = new Gson();

    private static String sendRequest(String endpoint, String method, JsonObject payload) throws Exception {
        URL url = new URL(API_URL + endpoint);
        HttpURLConnection conn = (HttpURLConnection) url.openConnection();
        conn.setRequestMethod(method);
        conn.setRequestProperty("Token", GHN_TOKEN);
        conn.setRequestProperty("Content-Type", "application/json");
        
        if (!endpoint.startsWith("/master-data/")) {
            conn.setRequestProperty("ShopId", GHN_SHOP_ID);
        }

        if ("POST".equalsIgnoreCase(method) && payload != null) {
            conn.setDoOutput(true);
            try (OutputStream os = conn.getOutputStream()) {
                byte[] input = payload.toString().getBytes("utf-8");
                os.write(input, 0, input.length);
            }
        }

        int responseCode = conn.getResponseCode();
        BufferedReader in = new BufferedReader(new InputStreamReader(
                (responseCode >= 200 && responseCode < 300) ? conn.getInputStream() : conn.getErrorStream(), "utf-8"
        ));
        
        StringBuilder response = new StringBuilder();
        String line;
        while ((line = in.readLine()) != null) {
            response.append(line);
        }
        in.close();

        if (responseCode < 200 || responseCode >= 300) {
            throw new Exception("GHN API Error (" + responseCode + "): " + response.toString());
        }

        return response.toString();
    }

    public static String getPrintToken(String ghnOrderCode) throws Exception {
        JsonObject payload = new JsonObject();
        JsonArray array = new JsonArray();
        array.add(ghnOrderCode);
        payload.add("order_codes", array);
        
        String response = sendRequest("/v2/a5/gen-token", "POST", payload);
        JsonObject json = gson.fromJson(response, JsonObject.class);
        return json.getAsJsonObject("data").get("token").getAsString();
    }

    private static String sanitizePhone(String phone) {
        if (phone == null) return "0911111111";
        String digits = phone.replaceAll("[^0-9]", "").trim();
        // Valid VN mobile prefix: 03, 05, 07, 08, 09 with 10 digits
        if (digits.matches("^0[35789]\\d{8}$")) {
            return digits;
        }
        // Fallback for invalid test numbers like 0123456789
        return "0911111111";
    }

    public static String createOrder(String toName, String toPhone, String toAddress, 
                                     String toWardCode, int toDistrictId, 
                                     int weightInGrams, int length, int width, int height, 
                                     double codAmount, JsonArray items) throws Exception {
        JsonObject payload = new JsonObject();
        payload.addProperty("payment_type_id", 1); // 1: Shop pays shipping, 2: Buyer pays shipping
        payload.addProperty("note", "NutriOverflow Order");
        payload.addProperty("required_note", "CHOXEMHANGKHONGTHU");
        payload.addProperty("from_name", "NutriOverflow Store");
        payload.addProperty("from_phone", "0917170428");
        payload.addProperty("from_address", "123 Nguyen Hue, Quan 1, TP. HCM");
        payload.addProperty("from_district_id", 1442);
        payload.addProperty("from_ward_code", "21211");
        payload.addProperty("to_name", (toName != null && !toName.trim().isEmpty()) ? toName : "Khách hàng NutriOverflow");
        payload.addProperty("to_phone", sanitizePhone(toPhone));
        payload.addProperty("to_address", (toAddress != null && !toAddress.trim().isEmpty()) ? toAddress : "123 Đường ABC, Quận 1, TP. HCM");
        payload.addProperty("to_ward_code", (toWardCode != null && !toWardCode.trim().isEmpty()) ? toWardCode : "21211");
        payload.addProperty("to_district_id", (toDistrictId > 0) ? toDistrictId : 1442);
        payload.addProperty("cod_amount", (int) codAmount);
        payload.addProperty("weight", weightInGrams > 0 ? weightInGrams : 500);
        payload.addProperty("length", length > 0 ? length : 10);
        payload.addProperty("width", width > 0 ? width : 10);
        payload.addProperty("height", height > 0 ? height : 10);
        payload.addProperty("service_type_id", 2);
        payload.add("items", items);

        String response = sendRequest("/v2/shipping-order/create", "POST", payload);
        JsonObject json = gson.fromJson(response, JsonObject.class);
        return json.getAsJsonObject("data").get("order_code").getAsString();
    }

    public static String createGHNOrderFromDB(int orderId) throws Exception {
        String sqlOrder = "SELECT o.shipping_address, o.ghn_district_id, o.ghn_ward_code, o.recipient_phone, " +
                          "       o.payment_method, o.total_amount, u.full_name, o.ghn_order_code " +
                          "FROM Orders o " +
                          "LEFT JOIN Users u ON o.user_id = u.user_id " +
                          "WHERE o.order_id = ?";
                          
        String sqlItems = "SELECT p.name, od.quantity, od.price_at_purchase " +
                          "FROM Order_Details od " +
                          "JOIN Products p ON od.product_id = p.product_id " +
                          "WHERE od.order_id = ?";
                          
        try (Connection conn = DBUtils.getConnection()) {
            String shippingAddress = null;
            int districtId = 0;
            String ghnWardCode = null;
            String recipientPhone = null;
            String paymentMethod = null;
            double totalAmount = 0;
            String fullName = null;
            String existingGhnCode = null;
            
            try (PreparedStatement ps = conn.prepareStatement(sqlOrder)) {
                ps.setInt(1, orderId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        shippingAddress = rs.getString("shipping_address");
                        districtId = rs.getInt("ghn_district_id");
                        ghnWardCode = rs.getString("ghn_ward_code");
                        recipientPhone = rs.getString("recipient_phone");
                        paymentMethod = rs.getString("payment_method");
                        totalAmount = rs.getDouble("total_amount");
                        fullName = rs.getString("full_name");
                        existingGhnCode = rs.getString("ghn_order_code");
                    }
                }
            }
            
            // If it already has a valid GHN order code (not starting with GHN17 dummy prefix), return it
            if (existingGhnCode != null && !existingGhnCode.trim().isEmpty() && !existingGhnCode.startsWith("GHN17")) {
                return existingGhnCode;
            }
            
            // Smart fallbacks if user location info is missing from older test orders
            if (shippingAddress == null || shippingAddress.trim().isEmpty()) {
                shippingAddress = "123 Nguyễn Huệ, Quận 1, TP. HCM";
            }
            if (districtId <= 0) {
                districtId = 1442;
            }
            if (ghnWardCode == null || ghnWardCode.trim().isEmpty()) {
                ghnWardCode = "21211";
            }
            if (recipientPhone == null || recipientPhone.trim().isEmpty()) {
                recipientPhone = "0911111111";
            }
            
            JsonArray items = new JsonArray();
            int totalWeight = 0;
            try (PreparedStatement ps = conn.prepareStatement(sqlItems)) {
                ps.setInt(1, orderId);
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        String name = rs.getString("name");
                        int quantity = rs.getInt("quantity");
                        double price = rs.getDouble("price_at_purchase");
                        
                        JsonObject item = new JsonObject();
                        item.addProperty("name", name);
                        item.addProperty("quantity", quantity);
                        item.addProperty("price", (int) price);
                        items.add(item);
                        
                        totalWeight += quantity * 500; // 500g per item
                    }
                }
            }
            
            if (items.size() == 0) {
                JsonObject item = new JsonObject();
                item.addProperty("name", "Sản phẩm NutriOverflow");
                item.addProperty("quantity", 1);
                item.addProperty("price", (int) totalAmount);
                items.add(item);
                totalWeight = 500;
            }
            
            // For VNPAY paid orders, codAmount is 0. For COD, it is the totalAmount
            double codAmount = "COD".equalsIgnoreCase(paymentMethod) ? totalAmount : 0;
            
            String ghnCode = createOrder(
                fullName != null && !fullName.isEmpty() ? fullName : "Khách hàng NutriOverflow",
                recipientPhone,
                shippingAddress,
                ghnWardCode, districtId,
                totalWeight, 10, 10, 10,
                codAmount, items
            );
            
            updateGhnCodeInDB(conn, orderId, ghnCode);
            return ghnCode;
            
        } catch (Exception e) {
            e.printStackTrace();
            System.err.println("GHN Create Order API error for order #" + orderId + ": " + e.getMessage());
            throw e; // Throw exception so controller can show error message to admin
        }
    }

    private static void updateGhnCodeInDB(Connection conn, int orderId, String ghnCode) throws Exception {
        String sqlUpdate = "UPDATE Orders SET ghn_order_code = ? WHERE order_id = ?";
        try (PreparedStatement ps = conn.prepareStatement(sqlUpdate)) {
            ps.setString(1, ghnCode);
            ps.setInt(2, orderId);
            ps.executeUpdate();
        }
    }
}


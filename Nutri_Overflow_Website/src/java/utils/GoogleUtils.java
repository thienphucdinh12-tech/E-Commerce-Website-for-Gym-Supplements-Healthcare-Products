package utils;

import java.io.BufferedReader;
import java.io.DataOutputStream;
import java.io.IOException;
import java.io.InputStreamReader;
import java.net.HttpURLConnection;
import java.net.URL;
import java.net.URLEncoder;
import com.google.gson.JsonObject;
import com.google.gson.JsonParser;

public class GoogleUtils {

    // =========================================================================
    // CONFIGURATION - Replace placeholders with actual credentials
    // =========================================================================
    public static final String GOOGLE_CLIENT_ID = "YOUR_GOOGLE_CLIENT_ID";
    public static final String GOOGLE_CLIENT_SECRET = "YOUR_GOOGLE_CLIENT_SECRET";
    public static final String GOOGLE_REDIRECT_URI = "http://localhost:9999/NutriOverflow_Website/LoginGoogleController";
    
    // Authorization URL with custom redirect URI
    public static String buildAuthorizeUrl(String redirectUri) {
        try {
            return "https://accounts.google.com/o/oauth2/auth?"
                    + "scope=" + URLEncoder.encode("email profile", "UTF-8")
                    + "&redirect_uri=" + URLEncoder.encode(redirectUri, "UTF-8")
                    + "&response_type=code"
                    + "&client_id=" + URLEncoder.encode(GOOGLE_CLIENT_ID, "UTF-8")
                    + "&approval_prompt=force";
        } catch (Exception e) {
            return "";
        }
    }

    // Authorization URL
    public static String buildAuthorizeUrl() {
        return buildAuthorizeUrl(GOOGLE_REDIRECT_URI);
    }

    /**
     * Exchanges OAuth2 authorization code for an Access Token.
     */
    public static String getToken(final String code, String redirectUri) throws IOException {
        String url = "https://oauth2.googleapis.com/token";
        URL obj = new URL(url);
        HttpURLConnection con = (HttpURLConnection) obj.openConnection();
        con.setRequestMethod("POST");
        con.setRequestProperty("Content-Type", "application/x-www-form-urlencoded");
        
        String urlParameters = "code=" + URLEncoder.encode(code, "UTF-8")
                + "&client_id=" + URLEncoder.encode(GOOGLE_CLIENT_ID, "UTF-8")
                + "&client_secret=" + URLEncoder.encode(GOOGLE_CLIENT_SECRET, "UTF-8")
                + "&redirect_uri=" + URLEncoder.encode(redirectUri, "UTF-8")
                + "&grant_type=authorization_code";
        
        con.setDoOutput(true);
        try (DataOutputStream wr = new DataOutputStream(con.getOutputStream())) {
            wr.writeBytes(urlParameters);
            wr.flush();
        }
        
        int responseCode = con.getResponseCode();
        BufferedReader in = new BufferedReader(new InputStreamReader(
                responseCode == 200 ? con.getInputStream() : con.getErrorStream(), "UTF-8"));
        String inputLine;
        StringBuilder response = new StringBuilder();
        while ((inputLine = in.readLine()) != null) {
            response.append(inputLine);
        }
        in.close();
        
        if (responseCode != 200) {
            throw new IOException("Failed to get token: " + response.toString());
        }
        
        JsonObject jobj = JsonParser.parseString(response.toString()).getAsJsonObject();
        return jobj.get("access_token").getAsString();
    }

    public static String getToken(final String code) throws IOException {
        return getToken(code, GOOGLE_REDIRECT_URI);
    }

    /**
     * Fetches user profile from Google using the Access Token.
     */
    public static GoogleUser getUserInfo(final String accessToken) throws IOException {
        String url = "https://www.googleapis.com/oauth2/v3/userinfo";
        URL obj = new URL(url);
        HttpURLConnection con = (HttpURLConnection) obj.openConnection();
        con.setRequestMethod("GET");
        con.setRequestProperty("Authorization", "Bearer " + accessToken);
        
        int responseCode = con.getResponseCode();
        BufferedReader in = new BufferedReader(new InputStreamReader(
                responseCode == 200 ? con.getInputStream() : con.getErrorStream(), "UTF-8"));
        String inputLine;
        StringBuilder response = new StringBuilder();
        while ((inputLine = in.readLine()) != null) {
            response.append(inputLine);
        }
        in.close();
        
        if (responseCode != 200) {
            throw new IOException("Failed to get user info: " + response.toString());
        }
        
        JsonObject jobj = JsonParser.parseString(response.toString()).getAsJsonObject();
        GoogleUser user = new GoogleUser();
        user.setId(jobj.get("sub").getAsString());
        user.setEmail(jobj.get("email").getAsString());
        user.setName(jobj.get("name").getAsString());
        if (jobj.has("picture")) {
            user.setPicture(jobj.get("picture").getAsString());
        }
        return user;
    }

    // Google User Model
    public static class GoogleUser {
        private String id;
        private String email;
        private String name;
        private String picture;

        public GoogleUser() {}

        public String getId() { return id; }
        public void setId(String id) { this.id = id; }

        public String getEmail() { return email; }
        public void setEmail(String email) { this.email = email; }

        public String getName() { return name; }
        public void setName(String name) { this.name = name; }

        public String getPicture() { return picture; }
        public void setPicture(String picture) { this.picture = picture; }

        @Override
        public String toString() {
            return "GoogleUser{" + "id=" + id + ", email=" + email + ", name=" + name + '}';
        }
    }
}

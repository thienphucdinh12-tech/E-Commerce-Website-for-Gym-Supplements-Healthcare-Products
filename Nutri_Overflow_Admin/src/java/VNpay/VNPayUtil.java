/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package VNpay;

import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.Map;
import java.util.TreeMap;
import javax.crypto.Mac;
import javax.crypto.spec.SecretKeySpec;

/**
 *
 * @author ADMIN
 */
public class VNPayUtil {
      // Mã secret key từ VNPay merchant portal
    public static final String TMN_CODE    = "FB3737KU";
    public static final String HASH_SECRET = "0W1YALPN9ZKBWWT4WHMQ81AJ11O3HG6F";
    public static final String VNPAY_URL   = "https://sandbox.vnpayment.vn/paymentv2/vpcpay.html";
    public static final String RETURN_URL  = "https://salute-massive-skimming.ngrok-free.dev/NutriFlow/VNPayReturnController";
    public static final String IPN_URL = "https://salute-massive-skimming.ngrok-free.dev/NutriFlow/VNPayIPNController";

    // =====================================================
    // Verify chữ ký IPN từ VNPay
    // =====================================================
    public static boolean verifySignature(Map<String, String> params, String secretKey) {
    try {
        String receivedHash = params.get("vnp_SecureHash");
        if (receivedHash == null) return false;

        Map<String, String> sortedParams = new TreeMap<>(params);
        sortedParams.remove("vnp_SecureHash");
        sortedParams.remove("vnp_SecureHashType");

        StringBuilder hashData = new StringBuilder();
        for (Map.Entry<String, String> entry : sortedParams.entrySet()) {
            String value = entry.getValue();
            if (value != null && !value.isEmpty()) {
                if (hashData.length() > 0) hashData.append("&");
                hashData.append(URLEncoder.encode(entry.getKey(), StandardCharsets.US_ASCII.toString()))
                        .append("=")
                        .append(URLEncoder.encode(value, StandardCharsets.US_ASCII.toString()));
            }
        }

        String computedHash = hmacSHA512(secretKey, hashData.toString());
        return computedHash.equalsIgnoreCase(receivedHash);

    } catch (Exception e) {
        e.printStackTrace();
        return false;
    }
}
    // =====================================================
    // Tạo link thanh toán VNPay
    // =====================================================
    public static String buildPaymentUrl(int orderId, String txnRef,
                                      long amount, String orderInfo,
                                      String ipAddr) throws Exception {
    Map<String, String> vnpParams = new TreeMap<>();
    vnpParams.put("vnp_Version",    "2.1.0");
    vnpParams.put("vnp_Command",    "pay");
    vnpParams.put("vnp_TmnCode",    TMN_CODE);
    vnpParams.put("vnp_Amount",     String.valueOf(amount * 100));
    vnpParams.put("vnp_CurrCode",   "VND");
    vnpParams.put("vnp_TxnRef",     txnRef);
    vnpParams.put("vnp_OrderInfo",  orderInfo);
    vnpParams.put("vnp_OrderType",  "other");
    vnpParams.put("vnp_Locale",     "vn");
    vnpParams.put("vnp_ReturnUrl",  RETURN_URL);
    vnpParams.put("vnp_IpAddr",     ipAddr);
    vnpParams.put("vnp_CreateDate", getCurrentTime());

    // Build chuỗi hash (key=value, KHÔNG encode)
    StringBuilder hashData = new StringBuilder();
    StringBuilder query    = new StringBuilder();

    for (Map.Entry<String, String> entry : vnpParams.entrySet()) {
        String key   = entry.getKey();
        String value = entry.getValue();
        if (value != null && !value.isEmpty()) {
            // Hash data: encode value
            if (hashData.length() > 0) hashData.append("&");
            hashData.append(URLEncoder.encode(key, StandardCharsets.US_ASCII.toString()))
                    .append("=")
                    .append(URLEncoder.encode(value, StandardCharsets.US_ASCII.toString()));

            // Query string: encode value
            if (query.length() > 0) query.append("&");
            query.append(URLEncoder.encode(key, StandardCharsets.US_ASCII.toString()))
                 .append("=")
                 .append(URLEncoder.encode(value, StandardCharsets.US_ASCII.toString()));
        }
    }

    String secureHash = hmacSHA512(HASH_SECRET, hashData.toString());
     System.out.println("=== VNPay Debug ===");
    System.out.println("HashData: " + hashData.toString());
    System.out.println("SecureHash: " + secureHash);    
    query.append("&vnp_SecureHash=").append(secureHash);
    
   

    return VNPAY_URL + "?" + query.toString();
    
}

    // =====================================================
    // Sinh txn_ref ngẫu nhiên (unique mỗi đơn hàng)
    // =====================================================
    public static String generateTxnRef(int orderId) {
        return orderId + "_" + System.currentTimeMillis();
    }

    // =====================================================
    // Hàm HMAC-SHA512
    // =====================================================
    public static String hmacSHA512(String key, String data) throws Exception {
        Mac mac = Mac.getInstance("HmacSHA512");
        SecretKeySpec secretKey = new SecretKeySpec(
            key.getBytes(StandardCharsets.UTF_8), "HmacSHA512"
        );
        mac.init(secretKey);
        byte[] hash = mac.doFinal(data.getBytes(StandardCharsets.UTF_8));
        StringBuilder sb = new StringBuilder();
        for (byte b : hash) {
            sb.append(String.format("%02x", b));
        }
        return sb.toString();
    }

    // =====================================================
    // Lấy thời gian hiện tại định dạng VNPay yêu cầu
    // =====================================================
    private static String getCurrentTime() {
        java.time.format.DateTimeFormatter fmt =
            java.time.format.DateTimeFormatter.ofPattern("yyyyMMddHHmmss");
        return java.time.LocalDateTime.now().format(fmt);
    }
}

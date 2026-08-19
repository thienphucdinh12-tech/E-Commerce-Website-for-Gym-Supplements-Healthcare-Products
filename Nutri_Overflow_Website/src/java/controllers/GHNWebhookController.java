package controllers;

import com.google.gson.Gson;
import com.google.gson.JsonObject;
import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.sql.Connection;
import java.sql.PreparedStatement;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import utils.DBUtils;

@WebServlet(name = "GHNWebhookController", urlPatterns = {"/api/ghn-webhook"})
public class GHNWebhookController extends HttpServlet {

    private final Gson gson = new Gson();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // GHN Webhook usually sends JSON payload
        StringBuilder sb = new StringBuilder();
        try (BufferedReader reader = new BufferedReader(new InputStreamReader(request.getInputStream(), "UTF-8"))) {
            String line;
            while ((line = reader.readLine()) != null) {
                sb.append(line);
            }
        }
        
        if (sb.length() == 0) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            return;
        }
        
        try {
            JsonObject payload = gson.fromJson(sb.toString(), JsonObject.class);
            String orderCode = payload.has("OrderCode") ? payload.get("OrderCode").getAsString() : null;
            String status = payload.has("Status") ? payload.get("Status").getAsString() : null;
            
            if (orderCode != null && status != null) {
                // Map GHN status to our internal status
                String internalStatus = mapGHNStatus(status);
                String trackingMessage = getTrackingMessage(status);
                
                updateOrderStatus(orderCode, internalStatus, trackingMessage);
            }
            
            response.setStatus(HttpServletResponse.SC_OK);
            response.getWriter().write("OK");
        } catch (Exception e) {
            log("Webhook processing error: " + e.getMessage());
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
        }
    }
    
    private String mapGHNStatus(String ghnStatus) {
        switch (ghnStatus.toLowerCase()) {
            case "ready_to_pick":
            case "picking":
                return "PROCESSING";
            case "delivering":
            case "picked":
                return "DELIVERING";
            case "delivered":
                return "DELIVERED";
            case "cancel":
            case "return":
            case "returned":
                return "CANCELLED";
            default:
                return "PROCESSING"; // Default safe mapping
        }
    }
    
    private String getTrackingMessage(String ghnStatus) {
        switch (ghnStatus.toLowerCase()) {
            case "ready_to_pick": return "Đơn hàng đang chờ lấy hàng.";
            case "picking": return "Shipper đang lấy hàng.";
            case "picked": return "Đã lấy hàng thành công.";
            case "delivering": return "Đơn hàng đang được giao đến bạn.";
            case "delivered": return "Giao hàng thành công.";
            case "cancel": return "Đơn hàng đã bị hủy bởi đơn vị vận chuyển.";
            case "return": return "Đơn hàng đang được hoàn trả lại shop.";
            case "returned": return "Đơn hàng đã hoàn trả thành công.";
            default: return "Cập nhật trạng thái mới từ GHN: " + ghnStatus;
        }
    }
    
    private void updateOrderStatus(String ghnCode, String internalStatus, String message) {
        String sqlUpdateOrder = "UPDATE Orders SET status = ? WHERE ghn_order_code = ?";
        String sqlInsertTracking = "INSERT INTO Order_Tracking(order_id, status, description, updated_at) " +
                                   "SELECT order_id, ?, ?, GETDATE() FROM Orders WHERE ghn_order_code = ?";
        
        try (Connection conn = DBUtils.getConnection()) {
            conn.setAutoCommit(false);
            
            try (PreparedStatement psUpdate = conn.prepareStatement(sqlUpdateOrder);
                 PreparedStatement psTrack = conn.prepareStatement(sqlInsertTracking)) {
                 
                psUpdate.setString(1, internalStatus);
                psUpdate.setString(2, ghnCode);
                psUpdate.executeUpdate();
                
                psTrack.setString(1, internalStatus);
                psTrack.setString(2, message);
                psTrack.setString(3, ghnCode);
                psTrack.executeUpdate();
                
                conn.commit();
            } catch (Exception e) {
                conn.rollback();
                throw e;
            }
        } catch (Exception e) {
            log("Error updating DB from webhook: " + e.getMessage());
        }
    }
}

package listeners;

import java.util.concurrent.Executors;
import java.util.concurrent.ScheduledExecutorService;
import java.util.concurrent.TimeUnit;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import javax.servlet.ServletContextEvent;
import javax.servlet.ServletContextListener;
import javax.servlet.annotation.WebListener;
import utils.DBUtils;
import notifications.OrderNotificationDAO;
import shopping.OrderHistoryDAO;

@WebListener
public class OrderSchedulerListener implements ServletContextListener {

    private ScheduledExecutorService scheduler;
    private final OrderNotificationDAO notifDAO = new OrderNotificationDAO();
    private final OrderHistoryDAO historyDAO = new OrderHistoryDAO();

    @Override
    public void contextInitialized(ServletContextEvent sce) {
        scheduler = Executors.newSingleThreadScheduledExecutor();
        scheduler.scheduleAtFixedRate(this::updateOrderStatuses, 10, 20, TimeUnit.SECONDS);
    }

    @Override
    public void contextDestroyed(ServletContextEvent sce) {
        if (scheduler != null) {
            scheduler.shutdownNow();
        }
    }

    private void updateOrderStatuses() {
        String sql = 
            "SELECT o.order_id, o.status, o.payment_method, u.username, o.ghn_order_code, " +
            "       COALESCE((SELECT MAX(updated_at) FROM Order_Tracking t WHERE t.order_id = o.order_id AND t.status = o.status), o.order_date) AS last_status_change " +
            "FROM Orders o " +
            "JOIN Users u ON o.user_id = u.user_id " +
            "WHERE o.status IN ('PENDING', 'PROCESSING', 'DELIVERING')";

        try (Connection conn = DBUtils.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            
            while (rs.next()) {
                int orderId = rs.getInt("order_id");
                String status = rs.getString("status");
                String paymentMethod = rs.getString("payment_method");
                String username = rs.getString("username");
                String ghnOrderCode = rs.getString("ghn_order_code");
                java.sql.Timestamp lastChange = rs.getTimestamp("last_status_change");
                
                long elapsedSeconds = (System.currentTimeMillis() - lastChange.getTime()) / 1000;

                if ("PENDING".equals(status) && "COD".equals(paymentMethod) && elapsedSeconds >= 30) {
                    transitionOrder(conn, orderId, username, "PROCESSING", "Shop đã xác nhận đơn hàng và đang chuẩn bị sản phẩm.", "ORDER_PROCESSING", "Đơn hàng đang được chuẩn bị — Đơn #" + orderId, "Đơn hàng #" + orderId + " đã được xác nhận. Shop đang chuẩn bị hàng.");
                } else if ("PROCESSING".equals(status) && elapsedSeconds >= 45) {
                    transitionOrder(conn, orderId, username, "DELIVERING", "Đơn hàng đã được giao cho đơn vị vận chuyển.", "ORDER_SHIPPED", "Đơn hàng đang được giao — Đơn #" + orderId, "Đơn hàng #" + orderId + " đã được giao cho đơn vị vận chuyển và đang trên đường tới bạn.");
                } else if ("DELIVERING".equals(status) && elapsedSeconds >= 30) {
                    int trackingCount = getTrackingCount(conn, orderId, "DELIVERING");
                    if (trackingCount == 1) {
                        insertTrackingLog(conn, orderId, "DELIVERING", "Đơn hàng đã đến kho phân loại trung tâm.");
                    } else if (trackingCount == 2) {
                        insertTrackingLog(conn, orderId, "DELIVERING", "Đơn hàng đang được giao đến bạn. Vui lòng chú ý điện thoại.");
                    }
                }
            }
        } catch (Exception e) {
            System.err.println("OrderSchedulerListener Error: " + e.getMessage());
        }

        // Revert any orders that were automatically set to DELIVERED back to DELIVERING
        revertAutoDeliveredOrders();

        // Clean up expired unpaid VNPay orders
        cleanupExpiredUnpaidVNPayOrders();
    }

    private void revertAutoDeliveredOrders() {
        String sql = "UPDATE Orders SET status = 'DELIVERING' WHERE status = 'DELIVERED'";
        try (Connection conn = DBUtils.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.executeUpdate();
        } catch (Exception ignored) {}
    }

    private void cleanupExpiredUnpaidVNPayOrders() {
        String sql = "SELECT o.order_id, u.username FROM Orders o " +
                     "JOIN Users u ON o.user_id = u.user_id " +
                     "WHERE o.payment_method = 'VNPAY' AND o.payment_status IN ('UNPAID', 'PENDING') " +
                     "AND o.status = 'PENDING' AND DATEDIFF(minute, o.order_date, GETDATE()) >= 15";
        try (Connection conn = DBUtils.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                int orderId = rs.getInt("order_id");
                String username = rs.getString("username");

                // Try deleting the unpaid order first
                boolean deleted = historyDAO.deleteUnpaidOrder(orderId, username);
                if (!deleted) {
                    // If deletion failed/was not allowed, update status so it will not match this query again
                    String cancelSql = "UPDATE Orders SET status = 'CANCELLED', payment_status = 'EXPIRED' WHERE order_id = ? AND status = 'PENDING'";
                    try (PreparedStatement psCancel = conn.prepareStatement(cancelSql)) {
                        psCancel.setInt(1, orderId);
                        psCancel.executeUpdate();
                    } catch (Exception ex) {
                        System.err.println("Error cancelling order #" + orderId + ": " + ex.getMessage());
                    }
                }
            }
        } catch (Exception e) {
            System.err.println("Error cleaning up expired VNPay orders: " + e.getMessage());
        }
    }

    private void transitionOrder(Connection conn, int orderId, String username, String newStatus, String trackingDesc, String notifType, String notifTitle, String notifMsg) throws Exception {
        String updateSql = "UPDATE Orders SET status = ? WHERE order_id = ?";
        try (PreparedStatement ps = conn.prepareStatement(updateSql)) {
            ps.setString(1, newStatus);
            ps.setInt(2, orderId);
            ps.executeUpdate();
        }

        insertTrackingLog(conn, orderId, newStatus, trackingDesc);
    }

    private void transitionOrderToDelivered(Connection conn, int orderId, String username, String paymentMethod) throws Exception {
        String updateSql = "UPDATE Orders SET status = 'DELIVERED'";
        if ("COD".equals(paymentMethod)) {
            updateSql += ", payment_status = 'PAID', paid_at = GETDATE()";
        }
        updateSql += " WHERE order_id = ?";
        
        try (PreparedStatement ps = conn.prepareStatement(updateSql)) {
            ps.setInt(1, orderId);
            ps.executeUpdate();
        }

        insertTrackingLog(conn, orderId, "DELIVERED", "Đơn hàng đã được giao thành công.");
    }

    private void insertTrackingLog(Connection conn, int orderId, String status, String desc) throws Exception {
        String sql = "INSERT INTO Order_Tracking(order_id, status, description, updated_at) VALUES (?, ?, ?, GETDATE())";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, orderId);
            ps.setString(2, status);
            ps.setString(3, desc);
            ps.executeUpdate();
        }
    }

    private int getTrackingCount(Connection conn, int orderId, String status) throws Exception {
        String sql = "SELECT COUNT(*) FROM Order_Tracking WHERE order_id = ? AND status = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, orderId);
            ps.setString(2, status);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        }
        return 0;
    }
}

package shopping;

import utils.DBUtils;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class OrderHistoryDAO {

    public List<OrderHistory> getOrdersByUsername(String username) {
        List<OrderHistory> orders = new ArrayList<>();

        String sqlOrders =
            "SELECT o.order_id, o.order_date, o.status, o.total_amount, " +
            "       o.payment_method, o.shipping_address, o.note, o.discount_applied, " +
            "       ISNULL(o.payment_status, 'UNPAID') AS payment_status, " +
            "       o.shipping_fee, o.ghn_order_code " +
            "FROM Orders o " +
            "JOIN Users u ON o.user_id = u.user_id " +
            "WHERE u.username = ? " +
            "ORDER BY o.order_date DESC";

        String sqlItems =
            "SELECT p.name AS product_name, od.quantity, od.price_at_purchase " +
            "FROM Order_Details od " +
            "JOIN Products p ON od.product_id = p.product_id " +
            "WHERE od.order_id = ?";

        String sqlTracking =
            "SELECT tracking_id, status, description, updated_at " +
            "FROM Order_Tracking " +
            "WHERE order_id = ? " +
            "ORDER BY updated_at ASC";

        try (Connection conn = DBUtils.getConnection();
             PreparedStatement stmtOrders = conn.prepareStatement(sqlOrders)) {

            stmtOrders.setString(1, username);
            try (ResultSet rsOrders = stmtOrders.executeQuery()) {
                while (rsOrders.next()) {
                    OrderHistory order = new OrderHistory(
                        rsOrders.getInt("order_id"),
                        rsOrders.getTimestamp("order_date"),
                        rsOrders.getString("status"),
                        rsOrders.getDouble("total_amount"),
                        rsOrders.getString("payment_method"),
                        rsOrders.getString("shipping_address"),
                        rsOrders.getString("note"),
                        rsOrders.getDouble("discount_applied"),
                        rsOrders.getDouble("shipping_fee"),
                        rsOrders.getString("ghn_order_code")
                    );
                    order.setPaymentStatus(rsOrders.getString("payment_status"));

                    // Load line items for this order
                    List<OrderHistory.OrderItem> items = new ArrayList<>();
                    try (PreparedStatement stmtItems = conn.prepareStatement(sqlItems)) {
                        stmtItems.setInt(1, order.getOrderId());
                        try (ResultSet rsItems = stmtItems.executeQuery()) {
                            while (rsItems.next()) {
                                items.add(new OrderHistory.OrderItem(
                                    rsItems.getString("product_name"),
                                    rsItems.getInt("quantity"),
                                    rsItems.getDouble("price_at_purchase")
                                ));
                            }
                        }
                    }
                    order.setItems(items);

                    // Load tracking logs for this order
                    List<OrderTrackingLog> trackingLogs = new ArrayList<>();
                    try (PreparedStatement stmtTracking = conn.prepareStatement(sqlTracking)) {
                        stmtTracking.setInt(1, order.getOrderId());
                        try (ResultSet rsTracking = stmtTracking.executeQuery()) {
                            while (rsTracking.next()) {
                                trackingLogs.add(new OrderTrackingLog(
                                    rsTracking.getInt("tracking_id"),
                                    rsTracking.getString("status"),
                                    rsTracking.getString("description"),
                                    rsTracking.getTimestamp("updated_at")
                                ));
                            }
                        }
                    }
                    order.setTrackingLogs(trackingLogs);
                    
                    orders.add(order);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return orders;
    }

    /**
     * Returns one specific order (with items) for a user.
     * Returns null if the order doesn't belong to this user (security check).
     */
    public OrderHistory getOrderDetail(int orderId, String username) {
        String sql =
            "SELECT o.order_id, o.order_date, o.status, o.total_amount, " +
            "       o.payment_method, o.shipping_address, o.note, o.discount_applied, " +
            "       ISNULL(o.payment_status, 'UNPAID') AS payment_status, " +
            "       o.shipping_fee, o.ghn_order_code " +
            "FROM Orders o " +
            "JOIN Users u ON o.user_id = u.user_id " +
            "WHERE o.order_id = ? AND u.username = ?";

        String sqlItems =
            "SELECT p.name AS product_name, od.quantity, od.price_at_purchase " +
            "FROM Order_Details od " +
            "JOIN Products p ON od.product_id = p.product_id " +
            "WHERE od.order_id = ?";

        String sqlTracking =
            "SELECT tracking_id, status, description, updated_at " +
            "FROM Order_Tracking " +
            "WHERE order_id = ? " +
            "ORDER BY updated_at ASC";

        try (Connection conn = DBUtils.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, orderId);
            stmt.setString(2, username);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    OrderHistory order = new OrderHistory(
                        rs.getInt("order_id"),
                        rs.getTimestamp("order_date"),
                        rs.getString("status"),
                        rs.getDouble("total_amount"),
                        rs.getString("payment_method"),
                        rs.getString("shipping_address"),
                        rs.getString("note"),
                        rs.getDouble("discount_applied"),
                        rs.getDouble("shipping_fee"),
                        rs.getString("ghn_order_code")
                    );
                    order.setPaymentStatus(rs.getString("payment_status"));
                    List<OrderHistory.OrderItem> items = new ArrayList<>();
                    try (PreparedStatement stmtItems = conn.prepareStatement(sqlItems)) {
                        stmtItems.setInt(1, orderId);
                        try (ResultSet rsItems = stmtItems.executeQuery()) {
                            while (rsItems.next()) {
                                items.add(new OrderHistory.OrderItem(
                                    rsItems.getString("product_name"),
                                    rsItems.getInt("quantity"),
                                    rsItems.getDouble("price_at_purchase")
                                ));
                            }
                        }
                    }
                    order.setItems(items);

                    List<OrderTrackingLog> trackingLogs = new ArrayList<>();
                    try (PreparedStatement stmtTracking = conn.prepareStatement(sqlTracking)) {
                        stmtTracking.setInt(1, orderId);
                        try (ResultSet rsTracking = stmtTracking.executeQuery()) {
                            while (rsTracking.next()) {
                                trackingLogs.add(new OrderTrackingLog(
                                    rsTracking.getInt("tracking_id"),
                                    rsTracking.getString("status"),
                                    rsTracking.getString("description"),
                                    rsTracking.getTimestamp("updated_at")
                                ));
                            }
                        }
                    }
                    order.setTrackingLogs(trackingLogs);
                    
                    return order;
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    /**
     * Atomically deletes a pending unpaid/failed order and restores the product stock.
     * Only allows deleting orders that belong to the user and are in PENDING status
     * with an unpaid/failed payment state.
     */
    public boolean deleteUnpaidOrder(int orderId, String username) {
        Connection conn = null;
        PreparedStatement psGetItems = null;
        PreparedStatement psUpdateStock = null;
        PreparedStatement psDeleteTracking = null;
        PreparedStatement psDeleteDetails = null;
        PreparedStatement psDeleteOrder = null;
        ResultSet rs = null;

        String sqlGetUserId = "SELECT user_id FROM Users WHERE username=?";
        String sqlCheckOrder = "SELECT status, payment_status, user_id, coupon_code FROM Orders WHERE order_id=?";
        String sqlGetItems = "SELECT product_id, quantity FROM Order_Details WHERE order_id=?";
        String sqlUpdateStock = "INSERT INTO Stock(product_id, quantity) VALUES(?, ?)";
        String sqlDeleteTracking = "DELETE FROM Order_Tracking WHERE order_id=?";
        String sqlDeleteDetails = "DELETE FROM Order_Details WHERE order_id=?";
        String sqlDeleteOrder = "DELETE FROM Orders WHERE order_id=?";

        try {
            conn = DBUtils.getConnection();
            if (conn == null) return false;

            conn.setAutoCommit(false); // Begin Transaction

            // 1. Get user_id of the currently logged-in user
            int userId = -1;
            try (PreparedStatement ps = conn.prepareStatement(sqlGetUserId)) {
                ps.setString(1, username);
                try (ResultSet rsUser = ps.executeQuery()) {
                    if (rsUser.next()) userId = rsUser.getInt("user_id");
                }
            }
            if (userId == -1) return false;

            // 2. Retrieve order status, owner ID, and coupon code
            String status = null;
            String paymentStatus = null;
            int orderUserId = -1;
            String couponCode = null;
            try (PreparedStatement ps = conn.prepareStatement(sqlCheckOrder)) {
                ps.setInt(1, orderId);
                try (ResultSet rsOrder = ps.executeQuery()) {
                    if (rsOrder.next()) {
                        status = rsOrder.getString("status");
                        paymentStatus = rsOrder.getString("payment_status");
                        orderUserId = rsOrder.getInt("user_id");
                        couponCode = rsOrder.getString("coupon_code");
                    }
                }
            }

            // Security: order must exist and belong to the logged-in user
            if (status == null || orderUserId != userId) {
                return false;
            }

            // Safety: only allow deletion of PENDING orders that are UNPAID, PENDING, or FAILED.
            boolean isRetryable = false;
            if ("PENDING".equalsIgnoreCase(status)) {
                if (paymentStatus == null) {
                    isRetryable = true;
                } else {
                    switch (paymentStatus.toUpperCase()) {
                        case "FAILED":
                        case "PENDING":
                        case "UNPAID":
                            isRetryable = true;
                            break;
                    }
                }
            }

            if (!isRetryable) {
                return false; // Cannot delete paid or processing/delivering/delivered orders
            }

            // 3. Restore product stock quantities
            psGetItems = conn.prepareStatement(sqlGetItems);
            psGetItems.setInt(1, orderId);
            rs = psGetItems.executeQuery();
            psUpdateStock = conn.prepareStatement(sqlUpdateStock);
            while (rs.next()) {
                int productId = rs.getInt("product_id");
                int quantity = rs.getInt("quantity");
                psUpdateStock.setInt(1, productId);
                psUpdateStock.setInt(2, quantity);
                psUpdateStock.executeUpdate();
            }

            // 4. Delete tracking history logs
            psDeleteTracking = conn.prepareStatement(sqlDeleteTracking);
            psDeleteTracking.setInt(1, orderId);
            psDeleteTracking.executeUpdate();

            // 5. Delete order detail items
            psDeleteDetails = conn.prepareStatement(sqlDeleteDetails);
            psDeleteDetails.setInt(1, orderId);
            psDeleteDetails.executeUpdate();

            // 6. Delete the order record itself
            psDeleteOrder = conn.prepareStatement(sqlDeleteOrder);
            psDeleteOrder.setInt(1, orderId);
            int rowsDeleted = psDeleteOrder.executeUpdate();

            // 7. Restore coupon usage if a coupon was used
            if (couponCode != null && !couponCode.trim().isEmpty()) {
                String sqlRestoreCoupon = "UPDATE Coupons SET used_count = CASE WHEN used_count > 0 THEN used_count - 1 ELSE 0 END WHERE code = ?";
                try (PreparedStatement psCoupon = conn.prepareStatement(sqlRestoreCoupon)) {
                    psCoupon.setString(1, couponCode.trim().toUpperCase());
                    psCoupon.executeUpdate();
                }
            }

            conn.commit(); // Commit Transaction
            return rowsDeleted > 0;

        } catch (Exception e) {
            e.printStackTrace();
            if (conn != null) {
                try { conn.rollback(); } catch (Exception ignored) {}
            }
            return false;
        } finally {
            if (rs != null) { try { rs.close(); } catch (Exception ignored) {} }
            if (psGetItems != null) { try { psGetItems.close(); } catch (Exception ignored) {} }
            if (psUpdateStock != null) { try { psUpdateStock.close(); } catch (Exception ignored) {} }
            if (psDeleteTracking != null) { try { psDeleteTracking.close(); } catch (Exception ignored) {} }
            if (psDeleteDetails != null) { try { psDeleteDetails.close(); } catch (Exception ignored) {} }
            if (psDeleteOrder != null) { try { psDeleteOrder.close(); } catch (Exception ignored) {} }
            if (conn != null) {
                try {
                    conn.setAutoCommit(true);
                    conn.close();
                } catch (Exception ignored) {}
            }
        }
    }

    /**
     * Updates the payment method of an order to COD (Cash on Delivery)
     * and sets the payment status to UNPAID. Inserts a tracking log.
     */
    public boolean updatePaymentMethodToCOD(int orderId, String username) {
        String sqlUpdateOrder = 
            "UPDATE Orders SET payment_method = 'COD', payment_status = 'UNPAID' " +
            "WHERE order_id = ? AND user_id = (SELECT user_id FROM Users WHERE username = ?)";
        String sqlInsertTracking = 
            "INSERT INTO Order_Tracking(order_id, status, description, updated_at) " +
            "VALUES (?, 'PENDING', N'Khách hàng thay đổi phương thức thanh toán sang COD (Tiền mặt).', GETDATE())";
        
        try (Connection conn = DBUtils.getConnection()) {
            conn.setAutoCommit(false);
            
            try (PreparedStatement psUpdate = conn.prepareStatement(sqlUpdateOrder)) {
                psUpdate.setInt(1, orderId);
                psUpdate.setString(2, username);
                int rows = psUpdate.executeUpdate();
                
                if (rows > 0) {
                    try (PreparedStatement psTrack = conn.prepareStatement(sqlInsertTracking)) {
                        psTrack.setInt(1, orderId);
                        psTrack.executeUpdate();
                    }
                    conn.commit();
                    return true;
                }
            }
            conn.rollback();
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    /**
     * Retrieves the username of the user who owns a given order.
     * Used for system cleanup flows like VNPay return / IPN when session is not available.
     */
    public String getUsernameByOrderId(int orderId) {
        String sql = "SELECT u.username FROM Orders o JOIN Users u ON o.user_id = u.user_id WHERE o.order_id = ?";
        try (Connection conn = DBUtils.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, orderId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getString("username");
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    /**
     * Finds and deletes all previous unpaid VNPay orders of the user.
     * This prevents duplicate pending orders if the checkout is interrupted/closed.
     */
    public void deletePreviousUnpaidVNPayOrders(String username) {
        String sql = "SELECT o.order_id FROM Orders o " +
                     "JOIN Users u ON o.user_id = u.user_id " +
                     "WHERE u.username = ? AND o.payment_method = 'VNPAY' " +
                     "AND o.payment_status IN ('UNPAID', 'PENDING') AND o.status = 'PENDING'";
        try (Connection conn = DBUtils.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, username);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    int orderId = rs.getInt("order_id");
                    deleteUnpaidOrder(orderId, username);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}

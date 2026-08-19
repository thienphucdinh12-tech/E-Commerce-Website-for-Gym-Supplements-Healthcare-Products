package shopping;

import utils.DBUtils;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class ReturnLogisticsDAO {

    public List<AdminOrderDTO> getEligibleReturnOrders(String search) {
        List<AdminOrderDTO> list = new ArrayList<>();
        
        StringBuilder sql = new StringBuilder(
            "SELECT o.order_id, o.order_date, o.status, o.total_amount, o.discount_applied, " +
            "       o.payment_method, o.payment_status, o.shipping_address, o.note, o.ghn_order_code, " +
            "       c.full_name AS customer_name " +
            "FROM Orders o " +
            "LEFT JOIN Customer c ON o.user_id = c.user_id " +
            "LEFT JOIN Account a ON c.account_id = a.account_id " +
            "WHERE o.status IN ('CANCELLED', 'SHIPPING', 'DELIVERING', 'DELIVERED') " +
            "  AND o.status <> 'RETURNED' " +
            "  AND NOT EXISTS (SELECT 1 FROM Order_Returns r WHERE r.order_id = o.order_id)"
        );
        
        List<Object> params = new ArrayList<>();
        
        if (search != null && !search.trim().isEmpty()) {
            sql.append(" AND (c.full_name LIKE ? OR a.username LIKE ? OR CAST(o.order_id AS VARCHAR) LIKE ?)");
            String searchPattern = "%" + search.trim() + "%";
            params.add(searchPattern);
            params.add(searchPattern);
            params.add(searchPattern);
        }
        
        sql.append(" ORDER BY o.order_date DESC");
        
        try (Connection conn = DBUtils.getConnection();
             PreparedStatement ptm = conn.prepareStatement(sql.toString())) {
            
            for (int i = 0; i < params.size(); i++) {
                ptm.setObject(i + 1, params.get(i));
            }
            
            try (ResultSet rs = ptm.executeQuery()) {
                while (rs.next()) {
                    AdminOrderDTO order = new AdminOrderDTO(
                        rs.getInt("order_id"),
                        rs.getTimestamp("order_date"),
                        rs.getString("status"),
                        rs.getDouble("total_amount"),
                        rs.getDouble("discount_applied"),
                        rs.getString("payment_method"),
                        rs.getString("payment_status"),
                        rs.getString("shipping_address"),
                        rs.getString("note"),
                        rs.getString("ghn_order_code"),
                        rs.getString("customer_name") != null ? rs.getString("customer_name") : "Khách hàng Vãng lai"
                    );
                    
                    order.setItems(getOrderItems(order.getOrderId(), conn));
                    list.add(order);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        
        return list;
    }

    private List<AdminOrderItemDTO> getOrderItems(int orderId, Connection conn) throws SQLException {
        List<AdminOrderItemDTO> list = new ArrayList<>();
        String sql = 
            "SELECT od.product_id, p.name AS product_name, p.sku, p.image_url, od.quantity, od.price_at_purchase " +
            "FROM Order_Details od " +
            "JOIN Products p ON od.product_id = p.product_id " +
            "WHERE od.order_id = ?";
        
        try (PreparedStatement ptm = conn.prepareStatement(sql)) {
            ptm.setInt(1, orderId);
            try (ResultSet rs = ptm.executeQuery()) {
                while (rs.next()) {
                    list.add(new AdminOrderItemDTO(
                        rs.getInt("product_id"),
                        rs.getString("product_name"),
                        rs.getString("sku"),
                        rs.getString("image_url"),
                        rs.getInt("quantity"),
                        rs.getDouble("price_at_purchase")
                    ));
                }
            }
        }
        return list;
    }

    public boolean processOrderReturn(int orderId, List<ReturnItemDTO> returnItems, String staffUsername) throws Exception {
        Connection conn = null;
        
        String sqlGetStaffId = "SELECT s.staff_id FROM Staff s JOIN Account a ON s.account_id = a.account_id WHERE a.username = ?";
        String sqlUpdateOrder = "UPDATE Orders SET status = 'RETURNED' WHERE order_id = ?";
        String sqlUpdateDelivery = "UPDATE Delivery SET status = 'RETURNED' WHERE order_id = ?";
        String sqlInsertReturn = 
            "INSERT INTO Order_Returns (order_id, product_id, quantity, condition, action, staff_id, notes, returned_at) " +
            "VALUES (?, ?, ?, ?, ?, ?, ?, GETDATE())";
        String sqlInsertStock = "INSERT INTO Stock (product_id, staff_id, quantity, updated_at) VALUES (?, ?, ?, GETDATE())";
        String sqlInsertTracking = "INSERT INTO Order_Tracking (order_id, status, description, updated_at) VALUES (?, 'RETURNED', ?, GETDATE())";
        
        try {
            conn = DBUtils.getConnection();
            conn.setAutoCommit(false);
            
            // 1. Get staff_id from username
            Integer staffId = null;
            try (PreparedStatement ps = conn.prepareStatement(sqlGetStaffId)) {
                ps.setString(1, staffUsername);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        staffId = rs.getInt("staff_id");
                    }
                }
            }
            
            // 2. Update order and delivery statuses
            try (PreparedStatement ps = conn.prepareStatement(sqlUpdateOrder)) {
                ps.setInt(1, orderId);
                ps.executeUpdate();
            }
            try (PreparedStatement ps = conn.prepareStatement(sqlUpdateDelivery)) {
                ps.setInt(1, orderId);
                ps.executeUpdate();
            }
            
            // 3. Process each return item
            int restockCount = 0;
            int discardCount = 0;
            
            for (ReturnItemDTO item : returnItems) {
                // Insert into Order_Returns
                try (PreparedStatement ps = conn.prepareStatement(sqlInsertReturn)) {
                    ps.setInt(1, orderId);
                    ps.setInt(2, item.getProductId());
                    ps.setInt(3, item.getQuantity());
                    ps.setString(4, item.getCondition());
                    ps.setString(5, item.getAction());
                    if (staffId != null) ps.setInt(6, staffId);
                    else                  ps.setNull(6, Types.INTEGER);
                    ps.setString(7, item.getNotes());
                    ps.executeUpdate();
                }
                
                // If action is RESTOCK, insert positive stock quantity to trigger sync
                if ("RESTOCK".equalsIgnoreCase(item.getAction())) {
                    try (PreparedStatement ps = conn.prepareStatement(sqlInsertStock)) {
                        ps.setInt(1, item.getProductId());
                        if (staffId != null) ps.setInt(2, staffId);
                        else                  ps.setNull(2, Types.INTEGER);
                        ps.setInt(3, item.getQuantity()); // Positive quantity to return back to stock
                        ps.executeUpdate();
                    }
                    restockCount += item.getQuantity();
                } else {
                    discardCount += item.getQuantity();
                }
            }
            
            // 4. Log tracking history
            String trackingDesc = "Đã tiếp nhận hàng hoàn trả từ đơn vị vận chuyển. Đánh giá: Nhập lại kho " 
                                + restockCount + " sản phẩm đạt chuẩn, hủy bỏ " + discardCount + " sản phẩm hư hại.";
            try (PreparedStatement ps = conn.prepareStatement(sqlInsertTracking)) {
                ps.setInt(1, orderId);
                ps.setString(2, trackingDesc);
                ps.executeUpdate();
            }
            
            conn.commit();
            return true;
        } catch (Exception e) {
            if (conn != null) conn.rollback();
            e.printStackTrace();
            throw e;
        } finally {
            if (conn != null) {
                conn.setAutoCommit(true);
                conn.close();
            }
        }
    }

    public int[] getReturnStats() {
        int[] stats = new int[3]; // [totalOrders, totalRestockQty, totalDiscardQty]
        String sql = "SELECT COUNT(DISTINCT order_id) AS total_orders, " +
                     "       ISNULL(SUM(CASE WHEN action = 'RESTOCK' THEN quantity ELSE 0 END), 0) AS total_restock, " +
                     "       ISNULL(SUM(CASE WHEN action = 'DISCARD' THEN quantity ELSE 0 END), 0) AS total_discard " +
                     "FROM Order_Returns";
        try (Connection conn = DBUtils.getConnection();
             PreparedStatement ptm = conn.prepareStatement(sql);
             ResultSet rs = ptm.executeQuery()) {
            if (rs.next()) {
                stats[0] = rs.getInt("total_orders");
                stats[1] = rs.getInt("total_restock");
                stats[2] = rs.getInt("total_discard");
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return stats;
    }
}

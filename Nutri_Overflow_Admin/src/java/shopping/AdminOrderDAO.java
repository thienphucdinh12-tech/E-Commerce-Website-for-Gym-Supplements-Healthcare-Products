package shopping;

import utils.DBUtils;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class AdminOrderDAO {

    public List<AdminOrderDTO> getAllOrders(String search, String statusFilter, String paymentMethodFilter) {
        List<AdminOrderDTO> list = new ArrayList<>();
        
        StringBuilder sql = new StringBuilder(
            "SELECT o.order_id, o.order_date, o.status, o.total_amount, o.discount_applied, " +
            "       o.payment_method, o.payment_status, o.shipping_address, o.note, o.ghn_order_code, " +
            "       c.full_name AS customer_name " +
            "FROM Orders o " +
            "LEFT JOIN Customer c ON o.user_id = c.user_id " +
            "LEFT JOIN Account a ON c.account_id = a.account_id " +
            "WHERE 1=1"
        );
        
        List<Object> params = new ArrayList<>();
        
        if (search != null && !search.trim().isEmpty()) {
            sql.append(" AND (c.full_name LIKE ? OR a.username LIKE ? OR CAST(o.order_id AS VARCHAR) LIKE ? OR o.ghn_order_code LIKE ?)");
            String searchPattern = "%" + search.trim() + "%";
            params.add(searchPattern);
            params.add(searchPattern);
            params.add(searchPattern);
            params.add(searchPattern);
        }
        
        if (statusFilter != null && !statusFilter.trim().isEmpty() && !"all".equalsIgnoreCase(statusFilter)) {
            sql.append(" AND o.status = ?");
            params.add(statusFilter);
        }
        
        if (paymentMethodFilter != null && !paymentMethodFilter.trim().isEmpty() && !"all".equalsIgnoreCase(paymentMethodFilter)) {
            sql.append(" AND o.payment_method = ?");
            params.add(paymentMethodFilter);
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

    public List<AdminOrderItemDTO> getOrderItems(int orderId) {
        try (Connection conn = DBUtils.getConnection()) {
            return getOrderItems(orderId, conn);
        } catch (Exception e) {
            e.printStackTrace();
            return new ArrayList<>();
        }
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

    public AdminOrderDTO getOrderById(int orderId) {
        String sql = 
            "SELECT o.order_id, o.order_date, o.status, o.total_amount, o.discount_applied, " +
            "       o.payment_method, o.payment_status, o.shipping_address, o.note, o.ghn_order_code, " +
            "       c.full_name AS customer_name " +
            "FROM Orders o " +
            "LEFT JOIN Customer c ON o.user_id = c.user_id " +
            "LEFT JOIN Account a ON c.account_id = a.account_id " +
            "WHERE o.order_id = ?";
        
        try (Connection conn = DBUtils.getConnection();
             PreparedStatement ptm = conn.prepareStatement(sql)) {
            ptm.setInt(1, orderId);
            try (ResultSet rs = ptm.executeQuery()) {
                if (rs.next()) {
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
                    order.setItems(getOrderItems(orderId, conn));
                    return order;
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    public boolean updateOrderHandover(int orderId, String ghnOrderCode) throws Exception {
        Connection conn = null;
        String sqlOrder = "UPDATE Orders SET status = 'SHIPPING', ghn_order_code = ? WHERE order_id = ?";
        String sqlDelivery = "UPDATE Delivery SET status = 'SHIPPING', ghn_order_code = ? WHERE order_id = ?";
        String sqlTracking = "INSERT INTO Order_Tracking (order_id, status, description, updated_at) VALUES (?, 'SHIPPING', ?, GETDATE())";
        
        String trackingDesc = "Đơn hàng đã được đóng gói và bàn giao cho đơn vị vận chuyển (GHN). Mã vận đơn: " + ghnOrderCode;
        
        try {
            conn = DBUtils.getConnection();
            conn.setAutoCommit(false);
            
            try (PreparedStatement ps1 = conn.prepareStatement(sqlOrder)) {
                ps1.setString(1, ghnOrderCode);
                ps1.setInt(2, orderId);
                ps1.executeUpdate();
            }
            
            try (PreparedStatement ps2 = conn.prepareStatement(sqlDelivery)) {
                ps2.setString(1, ghnOrderCode);
                ps2.setInt(2, orderId);
                ps2.executeUpdate();
            }
            
            try (PreparedStatement ps3 = conn.prepareStatement(sqlTracking)) {
                ps3.setInt(1, orderId);
                ps3.setString(2, trackingDesc);
                ps3.executeUpdate();
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

    public boolean updateOrderStatus(int orderId, String newStatus) throws Exception {
        Connection conn = null;
        String sqlOrder = "UPDATE Orders SET status = ? WHERE order_id = ?";
        String sqlDelivery = "UPDATE Delivery SET status = ? WHERE order_id = ?";
        String sqlTracking = "INSERT INTO Order_Tracking (order_id, status, description, updated_at) VALUES (?, ?, ?, GETDATE())";
        
        String statusLabel = "";
        switch (newStatus.toUpperCase()) {
            case "PENDING":    statusLabel = "Chờ xác nhận"; break;
            case "PROCESSING": statusLabel = "Đang xử lý (Đóng gói)"; break;
            case "DELIVERING":
            case "SHIPPING":   statusLabel = "Đang giao hàng"; break;
            case "DELIVERED":  statusLabel = "Đã giao thành công"; break;
            case "CANCELLED":  statusLabel = "Đã huỷ"; break;
            default:           statusLabel = newStatus; break;
        }
        
        String trackingDesc = "Trạng thái đơn hàng được thay đổi thủ công bởi quản trị viên thành: " + statusLabel;
        
        try {
            conn = DBUtils.getConnection();
            conn.setAutoCommit(false);
            
            try (PreparedStatement ps1 = conn.prepareStatement(sqlOrder)) {
                ps1.setString(1, newStatus);
                ps1.setInt(2, orderId);
                ps1.executeUpdate();
            }
            
            try (PreparedStatement ps2 = conn.prepareStatement(sqlDelivery)) {
                ps2.setString(1, newStatus);
                ps2.setInt(2, orderId);
                ps2.executeUpdate();
            }
            
            try (PreparedStatement ps3 = conn.prepareStatement(sqlTracking)) {
                ps3.setInt(1, orderId);
                ps3.setString(2, newStatus);
                ps3.setString(3, trackingDesc);
                ps3.executeUpdate();
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
}

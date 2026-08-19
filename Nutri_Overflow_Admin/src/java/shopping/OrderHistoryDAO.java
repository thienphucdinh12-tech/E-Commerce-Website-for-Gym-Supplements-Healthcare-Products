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
            "       ISNULL(o.payment_status, 'UNPAID') AS payment_status " +
            "FROM Orders o " +
            "JOIN Users u ON o.user_id = u.user_id " +
            "WHERE u.username = ? " +
            "ORDER BY o.order_date DESC";

        String sqlItems =
            "SELECT p.name AS product_name, od.quantity, od.price_at_purchase " +
            "FROM Order_Details od " +
            "JOIN Products p ON od.product_id = p.product_id " +
            "WHERE od.order_id = ?";

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
                        rsOrders.getDouble("discount_applied")
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
            "       ISNULL(o.payment_status, 'UNPAID') AS payment_status " +
            "FROM Orders o " +
            "JOIN Users u ON o.user_id = u.user_id " +
            "WHERE o.order_id = ? AND u.username = ?";

        String sqlItems =
            "SELECT p.name AS product_name, od.quantity, od.price_at_purchase " +
            "FROM Order_Details od " +
            "JOIN Products p ON od.product_id = p.product_id " +
            "WHERE od.order_id = ?";

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
                        rs.getDouble("discount_applied")
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
                    return order;
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }
}

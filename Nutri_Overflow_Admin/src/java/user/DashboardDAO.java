package user;

import utils.DBUtils;
import java.sql.*;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class DashboardDAO {

    /**
     * Get daily revenue for the last X days.
     */
    public List<Map<String, Object>> getRevenueData(int days) {
        List<Map<String, Object>> list = new ArrayList<>();
        String sql = "SELECT CAST(order_date AS DATE) AS order_day, SUM(total_amount) AS total_revenue " +
                     "FROM Orders " +
                     "WHERE order_date >= DATEADD(day, -?, GETDATE()) AND payment_status = 'PAID' " +
                     "GROUP BY CAST(order_date AS DATE) " +
                     "ORDER BY order_day ASC";
        try (Connection conn = DBUtils.getConnection();
             PreparedStatement ptm = conn.prepareStatement(sql)) {
            ptm.setInt(1, days);
            try (ResultSet rs = ptm.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> map = new HashMap<>();
                    map.put("date", rs.getDate("order_day").toString());
                    map.put("revenue", rs.getDouble("total_revenue"));
                    list.add(map);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    /**
     * Get top X best-selling products.
     */
    public List<Map<String, Object>> getBestSellers(int limit) {
        List<Map<String, Object>> list = new ArrayList<>();
        String sql = "SELECT TOP (?) p.name, SUM(od.quantity) AS total_sold " +
                     "FROM Order_Details od " +
                     "JOIN Products p ON od.product_id = p.product_id " +
                     "JOIN Orders o ON od.order_id = o.order_id " +
                     "WHERE o.status <> 'CANCELLED' " +
                     "GROUP BY p.name " +
                     "ORDER BY total_sold DESC";
        try (Connection conn = DBUtils.getConnection();
             PreparedStatement ptm = conn.prepareStatement(sql)) {
            ptm.setInt(1, limit);
            try (ResultSet rs = ptm.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> map = new HashMap<>();
                    map.put("name", rs.getString("name"));
                    map.put("sold", rs.getInt("total_sold"));
                    list.add(map);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    /**
     * Get general inventory statistics.
     */
    public Map<String, Object> getInventoryStatus() {
        Map<String, Object> stats = new HashMap<>();
        String sql = "SELECT " +
                     "(SELECT COUNT(*) FROM Products) AS total_products, " +
                     "(SELECT COALESCE(SUM(stock_quantity), 0) FROM Products) AS total_stock, " +
                     "(SELECT COUNT(*) FROM Products WHERE stock_quantity < 10) AS low_stock_count";
        try (Connection conn = DBUtils.getConnection();
             PreparedStatement ptm = conn.prepareStatement(sql);
             ResultSet rs = ptm.executeQuery()) {
            if (rs.next()) {
                stats.put("totalProducts", rs.getInt("total_products"));
                stats.put("totalStock", rs.getInt("total_stock"));
                stats.put("lowStockCount", rs.getInt("low_stock_count"));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return stats;
    }

    /**
     * Get order status ratios (including cancelled, pending, shipped, delivered).
     */
    public Map<String, Object> getOrderStatusStats() {
        Map<String, Object> stats = new HashMap<>();
        String sql = "SELECT CASE " +
                     "         WHEN UPPER(status) IN ('DELIVERING', 'SHIPPING') THEN 'SHIPPING' " +
                     "         WHEN UPPER(status) = 'PENDING' THEN 'PENDING' " +
                     "         WHEN UPPER(status) = 'PROCESSING' THEN 'PROCESSING' " +
                     "         WHEN UPPER(status) = 'DELIVERED' THEN 'DELIVERED' " +
                     "         WHEN UPPER(status) = 'CANCELLED' THEN 'CANCELLED' " +
                     "         ELSE UPPER(status) " +
                     "       END AS norm_status, COUNT(*) AS count " +
                     "FROM Orders " +
                     "GROUP BY CASE " +
                     "         WHEN UPPER(status) IN ('DELIVERING', 'SHIPPING') THEN 'SHIPPING' " +
                     "         WHEN UPPER(status) = 'PENDING' THEN 'PENDING' " +
                     "         WHEN UPPER(status) = 'PROCESSING' THEN 'PROCESSING' " +
                     "         WHEN UPPER(status) = 'DELIVERED' THEN 'DELIVERED' " +
                     "         WHEN UPPER(status) = 'CANCELLED' THEN 'CANCELLED' " +
                     "         ELSE UPPER(status) " +
                     "       END";
        int totalOrders = 0;
        int cancelledOrders = 0;
        List<Map<String, Object>> details = new ArrayList<>();

        try (Connection conn = DBUtils.getConnection();
             PreparedStatement ptm = conn.prepareStatement(sql);
             ResultSet rs = ptm.executeQuery()) {
            while (rs.next()) {
                String status = rs.getString("norm_status");
                int count = rs.getInt("count");
                totalOrders += count;
                if ("CANCELLED".equalsIgnoreCase(status)) {
                    cancelledOrders = count;
                }
                Map<String, Object> item = new HashMap<>();
                item.put("status", status);
                item.put("count", count);
                details.add(item);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        stats.put("totalOrders", totalOrders);
        stats.put("cancelledOrders", cancelledOrders);
        stats.put("cancellationRate", totalOrders == 0 ? 0.0 : Math.round(((double) cancelledOrders / totalOrders) * 1000.0) / 10.0);
        stats.put("details", details);
        return stats;
    }

    /**
     * Get CSKH staff performance metrics (number of articles written/approved).
     */
    public List<Map<String, Object>> getCSKHPerformance() {
        List<Map<String, Object>> list = new ArrayList<>();
        String sql = "SELECT username, fullName, COUNT(article_id) AS articlesCount FROM ( " +
                     "    SELECT u.username AS username, COALESCE(NULLIF(u.full_name, ''), u.username) AS fullName, a.article_id " +
                     "    FROM Users u " +
                     "    LEFT JOIN Articles a ON a.author_username = u.username " +
                     "    WHERE u.role IS NULL OR UPPER(u.role) NOT IN ('CUSTOMER', 'US') " +
                     "    UNION ALL " +
                     "    SELECT a.author_username AS username, COALESCE(NULLIF(a.author_name, ''), a.author_username) AS fullName, a.article_id " +
                     "    FROM Articles a " +
                     "    WHERE a.author_username IS NOT NULL AND a.author_username NOT IN (SELECT username FROM Users WHERE UPPER(role) IN ('CUSTOMER', 'US')) " +
                     ") combined " +
                     "GROUP BY username, fullName " +
                     "ORDER BY articlesCount DESC, username ASC";
        try (Connection conn = DBUtils.getConnection();
             PreparedStatement ptm = conn.prepareStatement(sql);
             ResultSet rs = ptm.executeQuery()) {
            while (rs.next()) {
                Map<String, Object> map = new HashMap<>();
                String username = rs.getString("username");
                String fullName = rs.getString("fullName");
                map.put("username", username != null ? username : "N/A");
                map.put("fullName", fullName != null && !fullName.trim().isEmpty() ? fullName : username);
                map.put("articlesCount", rs.getInt("articlesCount"));
                list.add(map);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    /**
     * Get Warehouse staff performance metrics (number of batches imported and returns handled).
     */
    public List<Map<String, Object>> getWarehousePerformance() {
        List<Map<String, Object>> list = new ArrayList<>();
        String sql = "SELECT staff_id, fullName, SUM(batches_count) AS batchesCount, SUM(returns_count) AS returnsCount FROM ( " +
                     "    SELECT COALESCE(st.staff_id, acc.account_id, 1) AS staff_id, " +
                     "           COALESCE(st.full_name, u.full_name, u.username) AS fullName, " +
                     "           (SELECT COUNT(*) FROM Stock s WHERE s.staff_id = st.staff_id) AS batches_count, " +
                     "           (SELECT COUNT(*) FROM Order_Returns r WHERE r.staff_id = st.staff_id) AS returns_count " +
                     "    FROM Users u " +
                     "    LEFT JOIN Account acc ON u.username = acc.username " +
                     "    LEFT JOIN Staff st ON acc.account_id = st.account_id " +
                     "    WHERE u.role IS NULL OR UPPER(u.role) NOT IN ('CUSTOMER', 'US') " +
                     ") combined " +
                     "GROUP BY staff_id, fullName " +
                     "ORDER BY batchesCount DESC, returnsCount DESC";
        try (Connection conn = DBUtils.getConnection();
             PreparedStatement ptm = conn.prepareStatement(sql);
             ResultSet rs = ptm.executeQuery()) {
            while (rs.next()) {
                Map<String, Object> map = new HashMap<>();
                map.put("staffId", rs.getInt("staff_id"));
                map.put("fullName", rs.getString("fullName"));
                map.put("batchesCount", rs.getInt("batchesCount"));
                map.put("returnsCount", rs.getInt("returnsCount"));
                list.add(map);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }
}

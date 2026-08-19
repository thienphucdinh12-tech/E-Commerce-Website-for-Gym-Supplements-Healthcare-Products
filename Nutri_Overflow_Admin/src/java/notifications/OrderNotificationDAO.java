package notifications;

import utils.DBUtils;
import java.sql.*;
import java.util.*;

/**
 * DAO for Order_Notifications table.
 * All methods are username-based (matches UserDTO.getUserID()).
 */
public class OrderNotificationDAO {

    // ── Check if a notification for username, orderId, type already exists ──
    public boolean exists(String username, int orderId, String type) {
        if (orderId <= 0) return false;
        String sql = "SELECT COUNT(*) FROM Order_Notifications WHERE username = ? AND order_id = ? AND type = ?";
        try (Connection conn = DBUtils.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, username);
            ps.setInt   (2, orderId);
            ps.setString(3, type);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1) > 0;
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    // ── Save a new notification ────────────────────────────────────────
    public boolean save(String username, int orderId, String type, String title, String message) {
        if (orderId > 0 && exists(username, orderId, type)) {
            return false; // Prevent saving duplicate notifications for the same order and type
        }
        String sql = "INSERT INTO Order_Notifications(username, order_id, type, title, message) " +
                     "VALUES(?, ?, ?, ?, ?)";
        try (Connection conn = DBUtils.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, username);
            ps.setInt   (2, orderId);
            ps.setString(3, type);
            ps.setString(4, title);
            ps.setString(5, message);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    // ── Mark all unread notifications in DB as read to purge old junk ──
    public int purgeAllNotifications() {
        String sql = "UPDATE Order_Notifications SET is_read = 1 WHERE is_read = 0";
        try (Connection conn = DBUtils.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            return ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    // ── Delete existing duplicate notifications ─────────────────────────
    public int cleanUpDuplicates() {
        purgeAllNotifications();
        String sql = "WITH CTE AS (" +
                     "  SELECT notif_id, ROW_NUMBER() OVER (" +
                     "    PARTITION BY username, order_id, type ORDER BY created_at DESC, notif_id DESC" +
                     "  ) AS row_num " +
                     "  FROM Order_Notifications WHERE order_id IS NOT NULL" +
                     ") " +
                     "DELETE FROM Order_Notifications WHERE notif_id IN (SELECT notif_id FROM CTE WHERE row_num > 1)";
        try (Connection conn = DBUtils.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            return ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    // ── Get all notifications for a user, newest first ─────────────────
    public List<OrderNotification> getByUsername(String username) {
        List<OrderNotification> list = new ArrayList<>();
        String sql = "SELECT * FROM Order_Notifications WHERE username = ? ORDER BY created_at DESC";
        try (Connection conn = DBUtils.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, username);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapRow(rs));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    // ── Get N most recent notifications (for navbar popup) ─────────────
    public List<OrderNotification> getRecent(String username, int limit) {
        List<OrderNotification> list = new ArrayList<>();
        String sql = "SELECT TOP(?) * FROM Order_Notifications " +
                     "WHERE username = ? ORDER BY created_at DESC";
        try (Connection conn = DBUtils.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt   (1, limit);
            ps.setString(2, username);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapRow(rs));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    // ── Count unread notifications ──────────────────────────────────────
    public int countUnread(String username) {
        String sql = "SELECT COUNT(*) FROM Order_Notifications WHERE username = ? AND is_read = 0";
        try (Connection conn = DBUtils.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, username);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    // ── Mark all notifications as read for a user ──────────────────────
    public void markAllRead(String username) {
        String sql = "UPDATE Order_Notifications SET is_read = 1 WHERE username = ? AND is_read = 0";
        try (Connection conn = DBUtils.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, username);
            ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    // ── Mark single notification as read ──────────────────────────────
    public void markRead(int notifId, String username) {
        String sql = "UPDATE Order_Notifications SET is_read = 1 WHERE notif_id = ? AND username = ?";
        try (Connection conn = DBUtils.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt   (1, notifId);
            ps.setString(2, username);
            ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    // ── Helper ─────────────────────────────────────────────────────────
    private OrderNotification mapRow(ResultSet rs) throws Exception {
        OrderNotification n = new OrderNotification();
        n.setNotifId  (rs.getInt    ("notif_id"));
        n.setUsername (rs.getString ("username"));
        n.setOrderId  (rs.getInt    ("order_id"));
        n.setType     (rs.getString ("type"));
        n.setTitle    (rs.getString ("title"));
        n.setMessage  (rs.getString ("message"));
        n.setRead     (rs.getBoolean("is_read"));
        n.setCreatedAt(rs.getTimestamp("created_at"));
        return n;
    }
}

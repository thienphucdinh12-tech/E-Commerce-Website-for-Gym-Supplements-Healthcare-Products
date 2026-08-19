package shopping;

import utils.DBUtils;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class SystemConfigDAO {

    public String getConfig(String key) {
        String sql = "SELECT config_value FROM System_Config WHERE config_key = ?";
        try (Connection conn = DBUtils.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, key);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getString("config_value");
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    public boolean updateConfig(String key, String value) {
        String sql = "UPDATE System_Config SET config_value = ? WHERE config_key = ?";
        try (Connection conn = DBUtils.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, value);
            ps.setString(2, key);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public List<CustomerPointDTO> getAllCustomerPoints() {
        List<CustomerPointDTO> list = new ArrayList<>();
        String sql = "SELECT c.user_id, a.username, c.full_name, c.phone, c.points " +
                     "FROM Customer c " +
                     "JOIN Account a ON c.account_id = a.account_id " +
                     "ORDER BY c.points DESC, c.user_id ASC";
        try (Connection conn = DBUtils.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(new CustomerPointDTO(
                    rs.getInt("user_id"),
                    rs.getString("username"),
                    rs.getString("full_name"),
                    rs.getString("phone"),
                    rs.getInt("points")
                ));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public boolean updateCustomerPoints(int userId, int points) {
        String sql = "UPDATE Customer SET points = ? WHERE user_id = ?";
        try (Connection conn = DBUtils.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, points);
            ps.setInt(2, userId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }
}

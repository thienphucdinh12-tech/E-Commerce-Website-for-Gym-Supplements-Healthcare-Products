package user;

import utils.DBUtils;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class UserDAO {
    private static final String LOGIN  =
            "SELECT u.username, u.full_name, u.role, u.password, a.is_active FROM Users u " +
            "JOIN Account a ON u.username = a.username " +
            "WHERE u.username=?";
    private static final String SEARCH =
            "SELECT username, full_name, role FROM Users WHERE full_name LIKE ?";
    private static final String UPDATE =
            "UPDATE Users SET full_name=?, role=? WHERE username=?";
    private static final String DELETE =
            "DELETE FROM Users WHERE username=?";
    private static final String INSERT =
            "INSERT INTO Users(username, full_name, role, password) VALUES(?,?,?,?)";

    // Profile queries — uses real columns: address(NVARCHAR(255)) already exists
    private static final String GET_PROFILE =
            "SELECT username, full_name, role, phone, address, " +
            "date_of_birth, gender, height_cm, weight_kg, health_goal " +
            "FROM Users WHERE username=?";
    private static final String UPDATE_PROFILE =
            "UPDATE Users SET full_name=?, phone=?, address=?, date_of_birth=?, gender=?, " +
            "height_cm=?, weight_kg=?, health_goal=? WHERE username=?";

    // ── Role mapping ─────────────────────────────────────────
    private String mapRoleToApp(String dbRole) {
        if ("ADMIN".equals(dbRole)) return "AD";
        if ("STAFF".equals(dbRole)) return "ST";
        return "US";
    }
    private String mapRoleToDB(String appRole) {
        if ("AD".equals(appRole)) return "ADMIN";
        if ("ST".equals(appRole)) return "STAFF";
        return "CUSTOMER";
    }

    // ── Authentication ───────────────────────────────────────
    public UserDTO checkLogin(String userID, String password) throws SQLException {
        UserDTO user = null;
        try (Connection conn = DBUtils.getConnection();
             PreparedStatement ptm = conn.prepareStatement(LOGIN)) {
            ptm.setString(1, userID);
            try (ResultSet rs = ptm.executeQuery()) {
                if (rs.next()) {
                    boolean isActive = rs.getBoolean("is_active");
                    if (!isActive) {
                        throw new SQLException("BANNED");
                    }
                    String storedHash = rs.getString("password");
                    if (utils.PasswordUtils.verifyPassword(password, storedHash)) {
                        String fullName = rs.getString("full_name");
                        String roleID   = mapRoleToApp(rs.getString("role"));
                        user = new UserDTO(userID, fullName, roleID, "***");
                    }
                }
            }
        } catch (SQLException e) {
            if ("BANNED".equals(e.getMessage())) {
                throw e;
            }
            e.printStackTrace();
        } catch (Exception e) {
            e.printStackTrace();
        }
        return user;
    }

    public UserDTO checkGoogleLogin(String username) throws SQLException {
        UserDTO user = null;
        String sql = "SELECT u.username, u.full_name, u.role, a.is_active FROM Users u " +
                     "JOIN Account a ON u.username = a.username " +
                     "WHERE u.username=?";
        try (Connection conn = DBUtils.getConnection();
             PreparedStatement ptm = conn.prepareStatement(sql)) {
            ptm.setString(1, username);
            try (ResultSet rs = ptm.executeQuery()) {
                if (rs.next()) {
                    boolean isActive = rs.getBoolean("is_active");
                    if (!isActive) {
                        throw new SQLException("BANNED");
                    }
                    String fullName = rs.getString("full_name");
                    String roleID   = mapRoleToApp(rs.getString("role"));
                    user = new UserDTO(username, fullName, roleID, "***");
                }
            }
        } catch (SQLException e) {
            if ("BANNED".equals(e.getMessage())) {
                throw e;
            }
            e.printStackTrace();
        } catch (Exception e) {
            e.printStackTrace();
        }
        return user;
    }

    // ── Admin: list users ────────────────────────────────────
    public List<UserDTO> getListUser(String search) throws SQLException {
        List<UserDTO> list = new ArrayList<>();
        try (Connection conn = DBUtils.getConnection();
             PreparedStatement ptm = conn.prepareStatement(SEARCH)) {
            ptm.setString(1, "%" + search + "%");
            try (ResultSet rs = ptm.executeQuery()) {
                while (rs.next()) {
                    String userID   = rs.getString("username");
                    String fullName = rs.getString("full_name");
                    String roleID   = mapRoleToApp(rs.getString("role"));
                    list.add(new UserDTO(userID, fullName, roleID, "***"));
                }
            }
        } catch (Exception e) { e.printStackTrace(); }
        return list;
    }

    // ── Admin: insert / update / delete ─────────────────────
    public boolean insert(UserDTO user) throws SQLException, Exception {
        try (Connection conn = DBUtils.getConnection();
             PreparedStatement ptm = conn.prepareStatement(INSERT)) {
            ptm.setString(1, user.getUserID());
            ptm.setString(2, user.getFullName());
            ptm.setString(3, mapRoleToDB(user.getRoleID()));
            String hashedPassword = utils.PasswordUtils.hashPassword(user.getPassword());
            ptm.setString(4, hashedPassword);
            ptm.executeUpdate();
            return true;
        }
    }

    public boolean update(UserDTO user) throws SQLException {
        try (Connection conn = DBUtils.getConnection();
             PreparedStatement ptm = conn.prepareStatement(UPDATE)) {
            ptm.setString(1, user.getFullName());
            ptm.setString(2, mapRoleToDB(user.getRoleID()));
            ptm.setString(3, user.getUserID());
            return ptm.executeUpdate() > 0;
        } catch (Exception e) { e.printStackTrace(); return false; }
    }

    public boolean delete(String userID) throws SQLException {
        try (Connection conn = DBUtils.getConnection();
             PreparedStatement ptm = conn.prepareStatement(DELETE)) {
            ptm.setString(1, userID);
            return ptm.executeUpdate() > 0;
        } catch (Exception e) { e.printStackTrace(); return false; }
    }

    // ── Profile: load full profile ───────────────────────────
    public UserDTO getUserProfile(String userID) {
        try (Connection conn = DBUtils.getConnection();
             PreparedStatement ptm = conn.prepareStatement(GET_PROFILE)) {
            ptm.setString(1, userID);
            try (ResultSet rs = ptm.executeQuery()) {
                if (rs.next()) {
                    UserDTO u = new UserDTO();
                    u.setUserID(rs.getString("username"));
                    u.setFullName(rs.getString("full_name"));
                    u.setRoleID(mapRoleToApp(rs.getString("role")));
                    u.setPassword("***");

                    // address column already exists in original schema
                    u.setAddress(rs.getString("address"));
                    u.setPhone(rs.getString("phone"));

                    // Profile extension columns (from chisobmi.sql / checkout_profile_migration.sql)
                    Date dob = rs.getDate("date_of_birth");
                    u.setDateOfBirth(dob);
                    u.setGender(rs.getString("gender"));

                    double h = rs.getDouble("height_cm");
                    u.setHeightCm(rs.wasNull() ? null : h);

                    double w = rs.getDouble("weight_kg");
                    u.setWeightKg(rs.wasNull() ? null : w);

                    u.setHealthGoal(rs.getString("health_goal"));
                    return u;
                }
            }
        } catch (Exception e) { e.printStackTrace(); }
        return null;
    }

    // ── Profile: save / update profile ──────────────────────
    public boolean updateProfile(UserDTO user) {
        try (Connection conn = DBUtils.getConnection();
             PreparedStatement ptm = conn.prepareStatement(UPDATE_PROFILE)) {
            ptm.setString(1, user.getFullName());
            ptm.setString(2, user.getPhone());
            ptm.setString(3, user.getAddress());

            if (user.getDateOfBirth() != null) {
                ptm.setDate(4, new java.sql.Date(user.getDateOfBirth().getTime()));
            } else {
                ptm.setNull(4, Types.DATE);
            }

            ptm.setString(5, user.getGender());

            if (user.getHeightCm() != null) {
                ptm.setDouble(6, user.getHeightCm());
            } else {
                ptm.setNull(6, Types.FLOAT);
            }

            if (user.getWeightKg() != null) {
                ptm.setDouble(7, user.getWeightKg());
            } else {
                ptm.setNull(7, Types.FLOAT);
            }

            ptm.setString(8, user.getHealthGoal());
            ptm.setString(9, user.getUserID());

            return ptm.executeUpdate() > 0;
        } catch (Exception e) { e.printStackTrace(); return false; }
    }

    public boolean checkUsernameExists(String username) throws SQLException {
        String sql = "SELECT username FROM Account WHERE username = ?";
        try (Connection conn = DBUtils.getConnection();
             PreparedStatement ptm = conn.prepareStatement(sql)) {
            ptm.setString(1, username);
            try (ResultSet rs = ptm.executeQuery()) {
                return rs.next();
            }
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean checkEmailExists(String email) throws SQLException {
        String sql = "SELECT email FROM Account WHERE email = ?";
        try (Connection conn = DBUtils.getConnection();
             PreparedStatement ptm = conn.prepareStatement(sql)) {
            ptm.setString(1, email);
            try (ResultSet rs = ptm.executeQuery()) {
                return rs.next();
            }
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean updateEmail(String username, String email) throws SQLException {
        String sql = "UPDATE Account SET email = ? WHERE username = ?";
        try (Connection conn = DBUtils.getConnection();
             PreparedStatement ptm = conn.prepareStatement(sql)) {
            ptm.setString(1, email);
            ptm.setString(2, username);
            return ptm.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean updateProfileAddress(String username, String address, String phone) {
        String sql = "UPDATE c SET c.address = ?, c.phone = ? FROM Customer c JOIN Account a ON c.account_id = a.account_id WHERE a.username = ?";
        try (Connection conn = DBUtils.getConnection();
             PreparedStatement ptm = conn.prepareStatement(sql)) {
            ptm.setString(1, address);
            ptm.setString(2, phone);
            ptm.setString(3, username);
            return ptm.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }
}
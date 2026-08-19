package user;

import utils.DBUtils;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class UserDAO {
    private static final String LOGIN  =
            "SELECT u.username, u.full_name, u.role, s.position " +
            "FROM Users u " +
            "LEFT JOIN Account a ON u.username = a.username " +
            "LEFT JOIN Staff s ON a.account_id = s.account_id " +
            "WHERE u.username=? AND u.password=? AND a.is_active = 1";
            
    private static final String SEARCH =
            "SELECT u.username, u.full_name, u.role, s.position, a.is_active " +
            "FROM Users u " +
            "LEFT JOIN Account a ON u.username = a.username " +
            "LEFT JOIN Staff s ON a.account_id = s.account_id " +
            "WHERE u.full_name LIKE ?";
            
    private static final String UPDATE =
            "UPDATE Users SET full_name=?, role=? WHERE username=?";
            
    private static final String DELETE =
            "DELETE FROM Users WHERE username=?";
            
    private static final String INSERT =
            "INSERT INTO Users(username, full_name, role, password) VALUES(?,?,?,?)";

    // Profile queries — uses real columns: address(NVARCHAR(255)) already exists
    private static final String GET_PROFILE =
            "SELECT username, full_name, role, address, " +
            "date_of_birth, gender, height_cm, weight_kg, health_goal " +
            "FROM Users WHERE username=?";
            
    private static final String UPDATE_PROFILE =
            "UPDATE Users SET full_name=?, address=?, date_of_birth=?, gender=?, " +
            "height_cm=?, weight_kg=?, health_goal=? WHERE username=?";

    // ── Role mapping ─────────────────────────────────────────
    private String mapRoleToApp(String dbRole) {
        return mapRoleToApp(dbRole, null);
    }

    private String mapRoleToApp(String dbRole, String position) {
        if ("ADMIN".equalsIgnoreCase(dbRole)) return "AD";
        if ("CUSTOMER".equalsIgnoreCase(dbRole)) return "US";
        if ("STAFF".equalsIgnoreCase(dbRole)) {
            if ("CSKH".equalsIgnoreCase(position)) return "CSKH";
            if ("Kho".equalsIgnoreCase(position)) return "KHO";
            if ("Manager".equalsIgnoreCase(position)) return "MAN";
        }
        return "US";
    }

    private String mapRoleToDB(String appRole) {
        if ("AD".equals(appRole)) return "ADMIN";
        if ("US".equals(appRole)) return "CUSTOMER";
        return "STAFF"; // MAN, KHO, CSKH
    }

    private String mapPositionToDB(String appRole) {
        if ("MAN".equals(appRole)) return "Manager";
        if ("KHO".equals(appRole)) return "Kho";
        if ("CSKH".equals(appRole)) return "CSKH";
        if ("AD".equals(appRole)) return "Manager";
        return "Staff";
    }

    // ── Authentication ───────────────────────────────────────
    public UserDTO checkLogin(String userID, String password) throws SQLException {
        UserDTO user = null;
        try (Connection conn = DBUtils.getConnection();
             PreparedStatement ptm = conn.prepareStatement(LOGIN)) {
            ptm.setString(1, userID);
            ptm.setString(2, password);
            try (ResultSet rs = ptm.executeQuery()) {
                if (rs.next()) {
                    String fullName = rs.getString("full_name");
                    String roleID   = mapRoleToApp(rs.getString("role"), rs.getString("position"));
                    user = new UserDTO(userID, fullName, roleID, "***");
                }
            }
        } catch (Exception e) { e.printStackTrace(); }
        return user;
    }

    // ── Admin: list users ────────────────────────────────────
    public List<UserDTO> getListUser(String search, String subRole) throws SQLException {
        List<UserDTO> list = new ArrayList<>();
        String searchPattern = "%" + (search == null ? "" : search.trim()) + "%";
        String sql;
        if ("US".equals(subRole)) {
            sql = "SELECT u.username, u.full_name, u.role, s.position, a.is_active " +
                  "FROM Users u " +
                  "LEFT JOIN Account a ON u.username = a.username " +
                  "LEFT JOIN Staff s ON a.account_id = s.account_id " +
                  "WHERE (u.username LIKE ? OR u.full_name LIKE ?) AND u.role = 'CUSTOMER'";
        } else if ("STAFF".equals(subRole)) {
            sql = "SELECT u.username, u.full_name, u.role, s.position, a.is_active " +
                  "FROM Users u " +
                  "LEFT JOIN Account a ON u.username = a.username " +
                  "LEFT JOIN Staff s ON a.account_id = s.account_id " +
                  "WHERE (u.username LIKE ? OR u.full_name LIKE ?) AND u.role <> 'CUSTOMER'";
        } else {
            sql = "SELECT u.username, u.full_name, u.role, s.position, a.is_active " +
                  "FROM Users u " +
                  "LEFT JOIN Account a ON u.username = a.username " +
                  "LEFT JOIN Staff s ON a.account_id = s.account_id " +
                  "WHERE (u.username LIKE ? OR u.full_name LIKE ?)";
        }
        try (Connection conn = DBUtils.getConnection();
             PreparedStatement ptm = conn.prepareStatement(sql)) {
            ptm.setString(1, searchPattern);
            ptm.setString(2, searchPattern);
            try (ResultSet rs = ptm.executeQuery()) {
                while (rs.next()) {
                    String userID   = rs.getString("username");
                    String fullName = rs.getString("full_name");
                    String roleID   = mapRoleToApp(rs.getString("role"), rs.getString("position"));
                    boolean active  = rs.getBoolean("is_active");
                    UserDTO user = new UserDTO(userID, fullName, roleID, "***");
                    user.setActive(active);
                    list.add(user);
                }
            }
        } catch (Exception e) { e.printStackTrace(); }
        return list;
    }

    // ── Admin: insert / update / delete ─────────────────────
    public boolean insert(UserDTO user) throws SQLException, Exception {
        try (Connection conn = DBUtils.getConnection()) {
            conn.setAutoCommit(false);
            try (PreparedStatement ptm = conn.prepareStatement(INSERT)) {
                ptm.setString(1, user.getUserID());
                ptm.setString(2, user.getFullName());
                ptm.setString(3, mapRoleToDB(user.getRoleID()));
                ptm.setString(4, user.getPassword());
                boolean success = ptm.executeUpdate() > 0;
                
                if (success) {
                    String appRole = user.getRoleID();
                    if ("MAN".equals(appRole) || "KHO".equals(appRole) || "CSKH".equals(appRole) || "AD".equals(appRole)) {
                        String updatePosSql = "UPDATE s SET s.position = ? FROM Staff s JOIN Account a ON s.account_id = a.account_id WHERE a.username = ?";
                        try (PreparedStatement ptm2 = conn.prepareStatement(updatePosSql)) {
                            ptm2.setString(1, mapPositionToDB(appRole));
                            ptm2.setString(2, user.getUserID());
                            ptm2.executeUpdate();
                        }
                    }
                    conn.commit();
                    return true;
                }
                conn.rollback();
                return false;
            } catch (Exception e) {
                conn.rollback();
                throw e;
            }
        }
    }

    public boolean update(UserDTO user) throws SQLException, Exception {
        try (Connection conn = DBUtils.getConnection()) {
            conn.setAutoCommit(false);
            try (PreparedStatement ptm = conn.prepareStatement(UPDATE)) {
                ptm.setString(1, user.getFullName());
                ptm.setString(2, mapRoleToDB(user.getRoleID()));
                ptm.setString(3, user.getUserID());
                boolean success = ptm.executeUpdate() > 0;
                
                if (success) {
                    String appRole = user.getRoleID();
                    String dbRole = mapRoleToDB(appRole);
                    
                    // Fetch account_id
                    int accountId = -1;
                    String getAccId = "SELECT account_id FROM Account WHERE username = ?";
                    try (PreparedStatement psAcc = conn.prepareStatement(getAccId)) {
                        psAcc.setString(1, user.getUserID());
                        try (ResultSet rsAcc = psAcc.executeQuery()) {
                            if (rsAcc.next()) {
                                accountId = rsAcc.getInt("account_id");
                            }
                        }
                    }
                    
                    if (accountId != -1) {
                        if ("ADMIN".equals(dbRole) || "STAFF".equals(dbRole)) {
                            // Ensure Staff record exists, set position
                            String checkStaff = "SELECT 1 FROM Staff WHERE account_id = ?";
                            boolean hasStaff = false;
                            try (PreparedStatement psCheck = conn.prepareStatement(checkStaff)) {
                                psCheck.setInt(1, accountId);
                                try (ResultSet rsCheck = psCheck.executeQuery()) {
                                    hasStaff = rsCheck.next();
                                }
                            }
                            if (!hasStaff) {
                                String insertStaff = "INSERT INTO Staff (account_id, full_name, position) VALUES (?, ?, ?)";
                                try (PreparedStatement psIns = conn.prepareStatement(insertStaff)) {
                                    psIns.setInt(1, accountId);
                                    psIns.setString(2, user.getFullName());
                                    psIns.setString(3, mapPositionToDB(appRole));
                                    psIns.executeUpdate();
                                }
                            } else {
                                String updateStaff = "UPDATE Staff SET position = ?, full_name = ? WHERE account_id = ?";
                                try (PreparedStatement psUp = conn.prepareStatement(updateStaff)) {
                                    psUp.setString(1, mapPositionToDB(appRole));
                                    psUp.setString(2, user.getFullName());
                                    psUp.setInt(3, accountId);
                                    psUp.executeUpdate();
                                }
                            }
                            // Delete Customer record
                            String delCust = "DELETE FROM Customer WHERE account_id = ?";
                            try (PreparedStatement psDel = conn.prepareStatement(delCust)) {
                                psDel.setInt(1, accountId);
                                psDel.executeUpdate();
                            }
                        } else if ("CUSTOMER".equals(dbRole)) {
                            // Ensure Customer record exists
                            String checkCust = "SELECT 1 FROM Customer WHERE account_id = ?";
                            boolean hasCust = false;
                            try (PreparedStatement psCheck = conn.prepareStatement(checkCust)) {
                                psCheck.setInt(1, accountId);
                                try (ResultSet rsCheck = psCheck.executeQuery()) {
                                    hasCust = rsCheck.next();
                                }
                            }
                            if (!hasCust) {
                                String insertCust = "INSERT INTO Customer (account_id, full_name) VALUES (?, ?)";
                                try (PreparedStatement psIns = conn.prepareStatement(insertCust)) {
                                    psIns.setInt(1, accountId);
                                    psIns.setString(2, user.getFullName());
                                    psIns.executeUpdate();
                                }
                            } else {
                                String updateCust = "UPDATE Customer SET full_name = ? WHERE account_id = ?";
                                try (PreparedStatement psUp = conn.prepareStatement(updateCust)) {
                                    psUp.setString(1, user.getFullName());
                                    psUp.setInt(2, accountId);
                                    psUp.executeUpdate();
                                }
                            }
                            // Delete Staff record
                            String delStaff = "DELETE FROM Staff WHERE account_id = ?";
                            try (PreparedStatement psDel = conn.prepareStatement(delStaff)) {
                                psDel.setInt(1, accountId);
                                psDel.executeUpdate();
                            }
                        }
                    }
                    conn.commit();
                    return true;
                }
                conn.rollback();
                return false;
            } catch (Exception e) {
                conn.rollback();
                throw e;
            }
        }
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
            ptm.setString(2, user.getAddress());

            if (user.getDateOfBirth() != null) {
                ptm.setDate(3, new java.sql.Date(user.getDateOfBirth().getTime()));
            } else {
                ptm.setNull(3, Types.DATE);
            }

            ptm.setString(4, user.getGender());

            if (user.getHeightCm() != null) {
                ptm.setDouble(5, user.getHeightCm());
            } else {
                ptm.setNull(5, Types.FLOAT);
            }

            if (user.getWeightKg() != null) {
                ptm.setDouble(6, user.getWeightKg());
            } else {
                ptm.setNull(6, Types.FLOAT);
            }

            ptm.setString(7, user.getHealthGoal());
            ptm.setString(8, user.getUserID());

            return ptm.executeUpdate() > 0;
        } catch (Exception e) { e.printStackTrace(); return false; }
    }

    public boolean toggleActive(String username, boolean active) throws SQLException {
        String sql = "UPDATE Account SET is_active = ? WHERE username = ?";
        try (Connection conn = DBUtils.getConnection();
             PreparedStatement ptm = conn.prepareStatement(sql)) {
            ptm.setBoolean(1, active);
            ptm.setString(2, username);
            return ptm.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }
}
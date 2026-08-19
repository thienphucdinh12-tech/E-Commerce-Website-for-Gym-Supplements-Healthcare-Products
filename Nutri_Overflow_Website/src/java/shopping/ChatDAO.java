package shopping;

import utils.DBUtils;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class ChatDAO {

    public ChatDAO() {
        checkAndCreateTables();
    }

    private void checkAndCreateTables() {
        String checkSql = "SELECT 1 FROM sysobjects WHERE name = 'Chat_Sessions' AND xtype = 'U'";
        boolean exists = false;
        try (Connection conn = DBUtils.getConnection();
             PreparedStatement ps = conn.prepareStatement(checkSql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                exists = true;
            }
        } catch (Exception e) {
            // Ignore error
        }

        if (!exists) {
            System.out.println("ChatDAO: Chat tables do not exist. Creating them now...");
            String sqlSessions = 
                "CREATE TABLE Chat_Sessions (" +
                "    session_id INT IDENTITY(1,1) PRIMARY KEY," +
                "    customer_name NVARCHAR(255) NOT NULL," +
                "    customer_id INT NULL," +
                "    status VARCHAR(50) DEFAULT 'ACTIVE'," +
                "    assigned_staff_id INT NULL," +
                "    created_at DATETIME DEFAULT GETDATE()," +
                "    last_message_at DATETIME DEFAULT GETDATE()," +
                "    FOREIGN KEY (customer_id) REFERENCES Customer(user_id) ON DELETE NO ACTION," +
                "    FOREIGN KEY (assigned_staff_id) REFERENCES Staff(staff_id) ON DELETE NO ACTION" +
                ")";
                
            String sqlMessages = 
                "CREATE TABLE Chat_Messages (" +
                "    message_id INT IDENTITY(1,1) PRIMARY KEY," +
                "    session_id INT NOT NULL," +
                "    sender_type VARCHAR(50) NOT NULL," +
                "    sender_name NVARCHAR(255) NOT NULL," +
                "    message_text NVARCHAR(MAX) NOT NULL," +
                "    sent_at DATETIME DEFAULT GETDATE()," +
                "    FOREIGN KEY (session_id) REFERENCES Chat_Sessions(session_id) ON DELETE CASCADE" +
                ")";
                
            try (Connection conn = DBUtils.getConnection();
                 Statement stmt = conn.createStatement()) {
                stmt.execute(sqlSessions);
                stmt.execute(sqlMessages);
                System.out.println("ChatDAO: Chat tables created successfully!");
            } catch (Exception e) {
                System.err.println("ChatDAO: Failed to create chat tables: " + e.getMessage());
                e.printStackTrace();
            }
        }
    }

    /**
     * Retrieves chat sessions based on status filter.
     * Orders by last_message_at DESC.
     */
    public List<ChatSessionDTO> getSessions(String statusFilter) {
        List<ChatSessionDTO> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder(
            "SELECT s.session_id, s.customer_id, s.customer_name, s.status, s.assigned_staff_id, " +
            "       s.last_message_at, s.created_at, st.full_name AS staff_name, " +
            "       (SELECT TOP 1 m.message_text FROM Chat_Messages m WHERE m.session_id = s.session_id ORDER BY m.sent_at DESC) AS last_message_text " +
            "FROM Chat_Sessions s " +
            "LEFT JOIN Staff st ON s.assigned_staff_id = st.staff_id " +
            "WHERE 1=1 "
        );

        List<Object> params = new ArrayList<>();

        if ("CLOSED".equalsIgnoreCase(statusFilter)) {
            sql.append("AND s.status = 'CLOSED' ");
        } else if ("WAITING_STAFF".equalsIgnoreCase(statusFilter)) {
            sql.append("AND s.status = 'WAITING_STAFF' ");
        } else if ("CONNECTED".equalsIgnoreCase(statusFilter)) {
            sql.append("AND s.status = 'CONNECTED' ");
        } else if ("ACTIVE".equalsIgnoreCase(statusFilter)) {
            sql.append("AND s.status = 'ACTIVE' ");
        } else {
            // Default: All active/open sessions (not closed)
            sql.append("AND s.status <> 'CLOSED' ");
        }

        sql.append("ORDER BY s.last_message_at DESC");

        try (Connection conn = DBUtils.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {

            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    ChatSessionDTO session = new ChatSessionDTO(
                        rs.getInt("session_id"),
                        rs.getObject("customer_id") != null ? rs.getInt("customer_id") : null,
                        rs.getString("customer_name"),
                        rs.getString("status"),
                        rs.getObject("assigned_staff_id") != null ? rs.getInt("assigned_staff_id") : null,
                        rs.getTimestamp("last_message_at"),
                        rs.getTimestamp("created_at")
                    );
                    session.setStaffName(rs.getString("staff_name"));
                    String lastMsg = rs.getString("last_message_text");
                    session.setLastMessageText(lastMsg != null ? lastMsg : "");
                    list.add(session);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    /**
     * Gets all messages belonging to a specific session.
     */
    public List<ChatMessageDTO> getSessionMessages(int sessionId) {
        List<ChatMessageDTO> list = new ArrayList<>();
        String sql = 
            "SELECT message_id, session_id, sender_type, sender_name, message_text, sent_at " +
            "FROM Chat_Messages WHERE session_id = ? " +
            "ORDER BY sent_at ASC";

        try (Connection conn = DBUtils.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, sessionId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(new ChatMessageDTO(
                        rs.getInt("message_id"),
                        rs.getInt("session_id"),
                        rs.getString("sender_type"),
                        rs.getString("sender_name"),
                        rs.getString("message_text"),
                        rs.getTimestamp("sent_at")
                    ));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    /**
     * Retrieves a single chat session by its ID.
     */
    public ChatSessionDTO getSessionById(int sessionId) {
        String sql = 
            "SELECT s.session_id, s.customer_id, s.customer_name, s.status, s.assigned_staff_id, " +
            "       s.last_message_at, s.created_at, st.full_name AS staff_name " +
            "FROM Chat_Sessions s " +
            "LEFT JOIN Staff st ON s.assigned_staff_id = st.staff_id " +
            "WHERE s.session_id = ?";
        try (Connection conn = DBUtils.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, sessionId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    ChatSessionDTO session = new ChatSessionDTO(
                        rs.getInt("session_id"),
                        rs.getObject("customer_id") != null ? rs.getInt("customer_id") : null,
                        rs.getString("customer_name"),
                        rs.getString("status"),
                        rs.getObject("assigned_staff_id") != null ? rs.getInt("assigned_staff_id") : null,
                        rs.getTimestamp("last_message_at"),
                        rs.getTimestamp("created_at")
                    );
                    session.setStaffName(rs.getString("staff_name"));
                    return session;
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    /**
     * Creates a new chat session and returns the generated session ID.
     */
    public int createSession(String customerName, Integer userId, String status) {
        String sql = "INSERT INTO Chat_Sessions (customer_id, customer_name, status, last_message_at, created_at) " +
                     "VALUES (?, ?, ?, GETDATE(), GETDATE())";
        try (Connection conn = DBUtils.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            if (userId != null) {
                ps.setInt(1, userId);
            } else {
                ps.setNull(1, Types.INTEGER);
            }
            ps.setString(2, customerName);
            ps.setString(3, status);
            ps.executeUpdate();
            
            try (ResultSet rs = ps.getGeneratedKeys()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return -1;
    }

    /**
     * Inserts a message and updates the session's last message time.
     */
    public boolean insertMessage(int sessionId, String senderType, String senderName, String messageText) {
        String sqlMsg = "INSERT INTO Chat_Messages (session_id, sender_type, sender_name, message_text, sent_at) " +
                        "VALUES (?, ?, ?, ?, GETDATE())";
        String sqlSessionUpdate = "UPDATE Chat_Sessions SET last_message_at = GETDATE() WHERE session_id = ?";

        try (Connection conn = DBUtils.getConnection()) {
            conn.setAutoCommit(false);
            try (PreparedStatement psMsg = conn.prepareStatement(sqlMsg);
                 PreparedStatement psSession = conn.prepareStatement(sqlSessionUpdate)) {
                
                psMsg.setInt(1, sessionId);
                psMsg.setString(2, senderType.toUpperCase());
                psMsg.setString(3, senderName);
                psMsg.setString(4, messageText);
                boolean successMsg = psMsg.executeUpdate() > 0;

                psSession.setInt(1, sessionId);
                boolean successSession = psSession.executeUpdate() > 0;

                if (successMsg && successSession) {
                    conn.commit();
                    return true;
                } else {
                    conn.rollback();
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    /**
     * Connects a staff member to a chat session, changing its status to CONNECTED.
     */
    public boolean assignStaff(int sessionId, String staffUsername) {
        String sqlGetStaffId = 
            "SELECT s.staff_id FROM Staff s " +
            "JOIN Account a ON s.account_id = a.account_id " +
            "WHERE a.username = ?";
        
        String sqlUpdate = 
            "UPDATE Chat_Sessions " +
            "SET status = 'CONNECTED', assigned_staff_id = ?, last_message_at = GETDATE() " +
            "WHERE session_id = ?";

        try (Connection conn = DBUtils.getConnection()) {
            Integer staffId = null;
            try (PreparedStatement psStaff = conn.prepareStatement(sqlGetStaffId)) {
                psStaff.setString(1, staffUsername);
                try (ResultSet rs = psStaff.executeQuery()) {
                    if (rs.next()) {
                        staffId = rs.getInt("staff_id");
                    }
                }
            }

            if (staffId == null) return false;

            try (PreparedStatement psUpdate = conn.prepareStatement(sqlUpdate)) {
                psUpdate.setInt(1, staffId);
                psUpdate.setInt(2, sessionId);
                return psUpdate.executeUpdate() > 0;
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    /**
     * Closes a chat session.
     */
    public boolean closeSession(int sessionId) {
        String sql = "UPDATE Chat_Sessions SET status = 'CLOSED', last_message_at = GETDATE() WHERE session_id = ?";
        try (Connection conn = DBUtils.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, sessionId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    /**
     * Hands the chat session back to AI control (status = ACTIVE, assigned_staff_id = NULL).
     */
    public boolean handbackToAI(int sessionId) {
        String sql = "UPDATE Chat_Sessions SET status = 'ACTIVE', assigned_staff_id = NULL, last_message_at = GETDATE() " +
                     "WHERE session_id = ?";
        try (Connection conn = DBUtils.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, sessionId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    /**
     * Updates session status directly.
     */
    public boolean updateSessionStatus(int sessionId, String status) {
        String sql = "UPDATE Chat_Sessions SET status = ?, last_message_at = GETDATE() WHERE session_id = ?";
        try (Connection conn = DBUtils.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, status.toUpperCase());
            ps.setInt(2, sessionId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    /**
     * Dynamically searches products based on keywords in the customer's message.
     */
    public String findProductsByMessage(String message) {
        if (message == null || message.trim().isEmpty()) {
            return "Chào bạn! Mình có thể giúp gì cho bạn hôm nay?";
        }
        
        String lowerMsg = message.toLowerCase();
        
        // 1. Check for price limits (e.g. "dưới 500k", "< 1 triệu")
        Double priceLimit = null;
        java.util.regex.Pattern pPrice = java.util.regex.Pattern.compile("(?:dưới|nhỏ hơn|<|tầm|khoảng|gia re hon|re hon)\\s*([0-9.,]+)\\s*(k|tr|triệu|triêu)?");
        java.util.regex.Matcher mPrice = pPrice.matcher(lowerMsg);
        if (mPrice.find()) {
            try {
                String numStr = mPrice.group(1).replace(".", "").replace(",", "");
                double value = Double.parseDouble(numStr);
                String unit = mPrice.group(2);
                if (unit != null) {
                    unit = unit.toLowerCase();
                    if (unit.equals("k")) {
                        value *= 1000;
                    } else if (unit.equals("tr") || unit.contains("triệu") || unit.contains("triêu")) {
                        value *= 1000000;
                    }
                } else {
                    if (value < 10000) {
                        value *= 1000; // E.g., "dưới 500" -> 500,000
                    }
                }
                priceLimit = value;
            } catch (Exception ex) {
                // Ignore parsing errors
            }
        }

        // 2. Identify category mapping (accented, non-accented and typos, using word boundary checks for short words)
        String categoryPattern = null;
        if (lowerMsg.contains("whey") || lowerMsg.contains("protein") || 
            containsWord(lowerMsg, "đạm") || containsWord(lowerMsg, "dam") || 
            lowerMsg.contains("co bap") || lowerMsg.contains("cơ bắp")) {
            categoryPattern = "%Protein%";
        } else if (lowerMsg.contains("mass") || lowerMsg.contains("tăng cân") || lowerMsg.contains("tang can") || 
                   lowerMsg.contains("sữa béo") || lowerMsg.contains("sua beo") || lowerMsg.contains("người gầy") || lowerMsg.contains("nguoi gay")) {
            categoryPattern = "%Mass Gainer%";
        } else if (lowerMsg.contains("pre-workout") || lowerMsg.contains("tăng sức mạnh") || lowerMsg.contains("tang suc manh") || 
                   lowerMsg.contains("sức bền") || lowerMsg.contains("suc ben") || lowerMsg.contains("tập luyện") || lowerMsg.contains("tap luyen") || 
                   containsWord(lowerMsg, "tập") || containsWord(lowerMsg, "tap")) {
            categoryPattern = "%Pre-Workout%";
        } else if (lowerMsg.contains("ăn kiêng") || lowerMsg.contains("an kieng") || lowerMsg.contains("diet") || 
                   lowerMsg.contains("đường ăn kiêng") || lowerMsg.contains("duong an kieng") || lowerMsg.contains("ít calo") || lowerMsg.contains("it calo") || 
                   lowerMsg.contains("keto")) {
            categoryPattern = "%Diet Food%";
        } else if (lowerMsg.contains("đốt mỡ") || lowerMsg.contains("dot mo") || lowerMsg.contains("giảm cân") || lowerMsg.contains("giam can") || 
                   lowerMsg.contains("fat burner") || containsWord(lowerMsg, "cla") || lowerMsg.contains("giam beo") || lowerMsg.contains("giảm béo")) {
            categoryPattern = "%Fat Burner%";
        } else if (lowerMsg.contains("vitamin") || lowerMsg.contains("omega") || lowerMsg.contains("dầu cá") || lowerMsg.contains("dau ca") || 
                   lowerMsg.contains("khoáng chất") || lowerMsg.contains("khoang chat") || lowerMsg.contains("collagen")) {
            categoryPattern = "%Vitamin%";
        } else if (lowerMsg.contains("snack") || lowerMsg.contains("ăn nhẹ") || lowerMsg.contains("an nhe") || 
                   lowerMsg.contains("bánh") || lowerMsg.contains("banh") || lowerMsg.contains("kẹo") || lowerMsg.contains("keo") || 
                   lowerMsg.contains("healthy")) {
            categoryPattern = "%Snack%";
        }

        // 3. Direct search keywords
        String namePattern = null;
        if (lowerMsg.contains("gold standard") || lowerMsg.contains("gold")) {
            namePattern = "%Gold Standard%";
        } else if (lowerMsg.contains("iso surge") || lowerMsg.contains("surge")) {
            namePattern = "%Iso Surge%";
        } else if (lowerMsg.contains("hydropure")) {
            namePattern = "%Hydropure%";
        } else if (lowerMsg.contains("creatine")) {
            namePattern = "%Creatine%";
        } else if (lowerMsg.contains("tương ớt") || lowerMsg.contains("bye béo") || lowerMsg.contains("bye beo") || lowerMsg.contains("tuong ot")) {
            namePattern = "%Bye Béo%";
        } else if (lowerMsg.contains("bún") || lowerMsg.contains("gạo lứt") || lowerMsg.contains("gao lut") || lowerMsg.contains("bun")) {
            namePattern = "%Vermicelli%";
        } else if (lowerMsg.contains("granola")) {
            namePattern = "%Granola%";
        } else if (lowerMsg.contains("bơ đậu phộng") || lowerMsg.contains("peanut butter") || lowerMsg.contains("bo dau phong")) {
            namePattern = "%Peanut%";
        } else if (lowerMsg.contains("lipo")) {
            namePattern = "%Lipo%";
        } else if (lowerMsg.contains("omega")) {
            namePattern = "%Omega%";
        } else if (lowerMsg.contains("collagen")) {
            namePattern = "%Collagen%";
        }

        // 4. Build SQL query (retrieves average review rating)
        StringBuilder sql = new StringBuilder(
            "SELECT p.product_id, p.name, p.price, p.discount_price, p.stock_quantity, c.name AS cat_name, " +
            "(SELECT AVG(CAST(rating AS FLOAT)) FROM Reviews r WHERE r.product_id = p.product_id) AS avg_rating " +
            "FROM Products p " +
            "JOIN Categories c ON p.category_id = c.category_id " +
            "WHERE p.is_active = 1 "
        );
        
        if (categoryPattern != null && namePattern != null) {
            sql.append("AND (c.name LIKE ? OR p.name LIKE ?) ");
        } else if (categoryPattern != null) {
            sql.append("AND c.name LIKE ? ");
        } else if (namePattern != null) {
            sql.append("AND p.name LIKE ? ");
        } else {
            if (lowerMsg.contains("khuyến mãi") || lowerMsg.contains("giảm giá") || lowerMsg.contains("sale") || lowerMsg.contains("giam gia") || lowerMsg.contains("khuyen mai")) {
                sql.append("AND p.discount_price IS NOT NULL ");
            } else if (lowerMsg.contains("bán chạy") || lowerMsg.contains("best seller") || lowerMsg.contains("hot") || lowerMsg.contains("ban chay")) {
                sql.append("AND p.is_bestseller = 1 ");
            } else {
                String cleanWord = message.replaceAll("(?i)(tìm|kiếm|mua|shop|có|bán|không|giúp|tôi|với|cái|sản phẩm|tim|kiem|co|ban|khong|giup|toi|voi|cai|san pham|bạn|ban|quy khach|quý khách)", "").trim();
                if (cleanWord.length() >= 2) {
                    sql.append("AND (p.name LIKE ? OR p.description LIKE ?) ");
                    namePattern = "%" + cleanWord + "%";
                } else {
                    if (priceLimit == null) {
                        return null; // Let standard fallback handle greetings or generic chats
                    }
                }
            }
        }
        
        if (priceLimit != null) {
            sql.append("AND (CASE WHEN p.discount_price IS NOT NULL THEN p.discount_price ELSE p.price END) <= ? ");
        }
        
        sql.append("ORDER BY p.sold_count DESC");

        java.text.DecimalFormat df = new java.text.DecimalFormat("#,###");
        StringBuilder reply = new StringBuilder();
        int count = 0;

        try (Connection conn = DBUtils.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            
            int paramIndex = 1;
            if (categoryPattern != null && namePattern != null) {
                ps.setString(paramIndex++, categoryPattern);
                ps.setString(paramIndex++, namePattern);
            } else if (categoryPattern != null) {
                ps.setString(paramIndex++, categoryPattern);
            } else if (namePattern != null) {
                if (sql.toString().contains("OR p.description LIKE ?")) {
                    ps.setString(paramIndex++, namePattern);
                    ps.setString(paramIndex++, namePattern);
                } else {
                    ps.setString(paramIndex++, namePattern);
                }
            }
            
            if (priceLimit != null) {
                ps.setDouble(paramIndex++, priceLimit);
            }

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next() && count < 5) {
                    if (count == 0) {
                        reply.append("Dạ, shop có các sản phẩm phù hợp với nhu cầu của bạn đây ạ:<br/>");
                    }
                    count++;
                    int pId = rs.getInt("product_id");
                    String pName = rs.getString("name");
                    double price = rs.getDouble("price");
                    double discPrice = rs.getDouble("discount_price");
                    boolean hasDisc = !rs.wasNull() && discPrice > 0;
                    int stock = rs.getInt("stock_quantity");
                    String catName = rs.getString("cat_name");
                    double rating = rs.getDouble("avg_rating");
                    boolean hasRating = !rs.wasNull() && rating > 0;

                    reply.append(count).append(". <strong>").append(pName).append("</strong><br/>");
                    reply.append("&nbsp;&nbsp;&nbsp;• Danh mục: ").append(catName).append("<br/>");
                    
                    // Display stars dynamically
                    if (hasRating) {
                        StringBuilder stars = new StringBuilder();
                        int starCount = (int) Math.round(rating);
                        for (int i = 0; i < 5; i++) {
                            if (i < starCount) stars.append("⭐");
                        }
                        reply.append("&nbsp;&nbsp;&nbsp;• Đánh giá: ").append(stars.toString()).append(" (").append(String.format("%.1f", rating)).append("/5)<br/>");
                    } else {
                        reply.append("&nbsp;&nbsp;&nbsp;• Đánh giá: <em>Chưa có đánh giá</em><br/>");
                    }

                    if (hasDisc) {
                        reply.append("&nbsp;&nbsp;&nbsp;• Giá: <span style='color: #ff4d6d; font-weight: bold;'>").append(df.format(discPrice)).append(" đ</span> <del style='font-size: 0.8rem; color: rgba(255,255,255,0.4);'>").append(df.format(price)).append(" đ</del><br/>");
                    } else {
                        reply.append("&nbsp;&nbsp;&nbsp;• Giá: <strong>").append(df.format(price)).append(" đ</strong><br/>");
                    }
                    if (stock <= 0) {
                        reply.append("&nbsp;&nbsp;&nbsp;• Tình trạng: <em>Tạm hết hàng</em><br/>");
                    } else {
                        reply.append("&nbsp;&nbsp;&nbsp;• Tình trạng: Còn hàng (").append(stock).append(" sản phẩm)<br/>");
                    }
                    
                    // Clickable eye button
                    reply.append("&nbsp;&nbsp;&nbsp;<a href='DetailController?id=").append(pId).append("' target='_blank' style='display: inline-block; margin-top: 6px; margin-bottom: 12px; padding: 5px 12px; background: linear-gradient(135deg, #dc3545, #ff4d6d); color: white; border-radius: 8px; font-size: 0.76rem; text-decoration: none; font-weight: 600; box-shadow: 0 2px 5px rgba(220,53,69,0.25);'><i class='fas fa-eye' style='margin-right: 4px;'></i> Xem &amp; Mua Ngay</a><br/>");
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        if (count > 0) {
            reply.append("<br/>Bạn có thể click vào nút trên để xem chi tiết sản phẩm. Bạn cần tư vấn thêm gì nữa không ạ?");
            return reply.toString();
        }
        
        return null;
    }

    /**
     * Check if text contains a specific word using word boundary matching.
     */
    private boolean containsWord(String text, String word) {
        if (text == null || word == null) return false;
        return text.matches(".*\\b" + java.util.regex.Pattern.quote(word) + "\\b.*");
    }
}

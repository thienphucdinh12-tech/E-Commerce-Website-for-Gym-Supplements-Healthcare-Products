package controllers;

import com.google.gson.Gson;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import shopping.ChatDAO;
import shopping.ChatMessageDTO;
import shopping.ChatSessionDTO;
import user.UserDTO;

@WebServlet(name = "CustomerChatController", urlPatterns = {"/CustomerChatController"})
public class CustomerChatController extends HttpServlet {

    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("application/json;charset=UTF-8");
        request.setCharacterEncoding("UTF-8");

        HttpSession session = request.getSession(true);
        UserDTO loginUser = (UserDTO) session.getAttribute("LOGIN_USER");
        
        PrintWriter out = response.getWriter();
        Gson gson = new Gson();
        Map<String, Object> jsonMap = new HashMap<>();

        String subAction = request.getParameter("subAction");
        ChatDAO dao = new ChatDAO();

        try {
            if ("createCustomerSession".equalsIgnoreCase(subAction)) {
                String name = request.getParameter("customerName");
                
                // If user is logged in, link their userId and use their full name
                if (loginUser != null) {
                    name = loginUser.getFullName();
                }
                
                if (name == null || name.trim().isEmpty()) {
                    name = "Khách vãng lai #" + (1000 + (int)(Math.random() * 9000));
                }
                
                // Fetch the integer user_id if logged in
                Integer intUserId = null;
                if (loginUser != null) {
                    intUserId = getCustomerIntId(loginUser.getUserID());
                }

                int sessionId = dao.createSession(name, intUserId, "ACTIVE");
                
                // Welcome message from AI
                dao.insertMessage(sessionId, "AI", "NutriBot AI", "Chào bạn " + name + "! Mình là trợ lý AI NutriBot. Bạn có thắc mắc gì về sản phẩm hay sức khỏe cần hỗ trợ không?");
                
                jsonMap.put("success", true);
                jsonMap.put("sessionId", sessionId);
                jsonMap.put("customerName", name);

            } else if ("getMessages".equalsIgnoreCase(subAction)) {
                int sessionId = Integer.parseInt(request.getParameter("sessionId"));
                List<ChatMessageDTO> messages = dao.getSessionMessages(sessionId);
                
                // Get current status of this session to send back to client
                ChatSessionDTO chatSession = dao.getSessionById(sessionId);
                String status = "ACTIVE";
                String staffName = "";
                if (chatSession != null) {
                    status = chatSession.getStatus();
                    staffName = chatSession.getStaffName() != null ? chatSession.getStaffName() : "";
                }
                
                jsonMap.put("success", true);
                jsonMap.put("messages", messages);
                jsonMap.put("status", status);
                jsonMap.put("staffName", staffName);

            } else if ("sendCustomerMessage".equalsIgnoreCase(subAction)) {
                int sessionId = Integer.parseInt(request.getParameter("sessionId"));
                String text = request.getParameter("messageText");
                String customerName = request.getParameter("customerName");

                // 1. Insert customer message
                boolean ok = dao.insertMessage(sessionId, "CUSTOMER", customerName, text);
                
                // 2. Read session current status to see if AI should reply
                ChatSessionDTO chatSession = dao.getSessionById(sessionId);
                String status = "ACTIVE";
                if (chatSession != null) {
                    status = chatSession.getStatus();
                }

                boolean triggeredHandoff = false;
                
                if ("ACTIVE".equalsIgnoreCase(status)) {
                    // Normalize text for simple keyword scanning
                    String lowerText = text.toLowerCase();
                    
                    // Keywords definitions
                    boolean hasPathology = lowerText.contains("suy thận") || lowerText.contains("tiểu đường") || 
                                           lowerText.contains("suy gan") || lowerText.contains("bệnh lý") || 
                                           lowerText.contains("đau dạ dày") || lowerText.contains("tim mạch") || 
                                           lowerText.contains("huyết áp");
                                           
                    boolean hasDosage = lowerText.contains("liều lượng") || lowerText.contains("liều dùng") || 
                                        lowerText.contains("cách dùng chi tiết") || lowerText.contains("chuyên sâu") || 
                                        lowerText.contains("uống bao nhiêu");
                                        
                    boolean hasContraindication = lowerText.contains("chống chỉ định") || lowerText.contains("tác dụng phụ") || 
                                                  lowerText.contains("dị ứng") || lowerText.contains("không được dùng");
                    
                    boolean wantsHuman = lowerText.contains("gặp nhân viên") || lowerText.contains("gặp người") || 
                                         lowerText.contains("tư vấn viên") || lowerText.contains("cskh") || 
                                         lowerText.contains("nhân viên trực tiếp");

                    if (hasPathology || hasDosage || hasContraindication || wantsHuman) {
                        // AI Handoff
                        String aiReply = "Chào bạn! Câu hỏi của bạn liên quan đến vấn đề bệnh lý, liều lượng chuyên sâu hoặc chống chỉ định y tế nhạy cảm. AI đang kết nối bạn với chuyên viên tư vấn y khoa / CSKH của shop để được hỗ trợ chính xác nhất. Vui lòng đợi trong giây lát!";
                        dao.insertMessage(sessionId, "AI", "NutriBot AI", aiReply);
                        
                        // Set status to WAITING_STAFF
                        dao.updateSessionStatus(sessionId, "WAITING_STAFF");
                        
                        // Add system handoff notification
                        String systemNote = "[Hệ thống] AI đã tự động chuyển giao cuộc trò chuyện này cho nhân viên CSKH vì câu hỏi chứa từ khóa bệnh lý, chống chỉ định hoặc có yêu cầu trực tiếp.";
                        dao.insertMessage(sessionId, "AI", "NutriBot AI", systemNote);
                        
                        triggeredHandoff = true;
                    } else {
                        String aiReply = null;
                        
                        // 1. Check FAQ rules first to prevent search collisions in product descriptions
                        if (lowerText.contains("chào") || lowerText.contains("hello") || lowerText.contains("hi") || lowerText.matches(".*\\balo\\b.*") || lowerText.equals("alo")) {
                            aiReply = "Dạ, NutriBot AI xin chào bạn! Mình có thể giúp bạn tìm kiếm Whey, Mass Gainer, Creatine, hoặc lọc sản phẩm theo giá (ví dụ: 'tìm whey dưới 500k', 'sản phẩm dưới 1 triệu')... Bạn cần tìm sản phẩm nào ạ?";
                        } else if (lowerText.contains("liên hệ") || lowerText.contains("sđt") || lowerText.contains("sdt") || lowerText.contains("số điện thoại") || lowerText.contains("zalo") || lowerText.contains("hotline")) {
                            aiReply = "Dạ, Hotline và Zalo hỗ trợ trực tiếp của shop là <strong>0896.612.861</strong> bạn nhé! Bạn có thể nhấn trực tiếp vào nút Gọi điện hoặc nút Zalo ở góc phải màn hình để liên hệ trực tiếp ạ.";
                        } else if (lowerText.contains("địa chỉ") || lowerText.contains("ở đâu") || lowerText.contains("cửa hàng") || lowerText.contains("shop ở đâu") || lowerText.contains("dia chi")) {
                            aiReply = "Dạ, shop ở TP. Hồ Chí Minh và hỗ trợ ship hàng COD siêu tốc toàn quốc. Nội thành TP.HCM hỗ trợ giao hỏa tốc trong vòng 2 giờ bạn nha.";
                        }
                        
                        // 1.5. Check if it's a nutrition / calorie query
                        if (aiReply == null) {
                            aiReply = tryHandleNutritionQuery(text);
                        }

                        // 2. If not an FAQ or nutrition query, query database for matching products
                        if (aiReply == null) {
                            aiReply = dao.findProductsByMessage(text);
                        }
                        
                        // 3. Fallback to custom "Not found" response if they were searching for a product
                        if (aiReply == null) {
                            String cleanWord = text.replaceAll("(?i)(tìm|kiếm|mua|shop|có|bán|không|giúp|tôi|với|cái|sản phẩm|tim|kiem|co|ban|khong|giup|toi|voi|cai|san pham|bạn|ban|quy khach|quý khách)", "").trim();
                            boolean hasSearchIntent = lowerText.contains("tìm") || lowerText.contains("tim") || 
                                                      lowerText.contains("bán") || lowerText.contains("ban") || 
                                                      lowerText.contains("mua") || lowerText.contains("có") || lowerText.contains("co");
                                                      
                            if (hasSearchIntent && cleanWord.length() >= 2) {
                                aiReply = "Dạ, hiện tại cửa hàng chưa có mặt hàng này rồi ạ. Bạn có thể tham khảo các sản phẩm thể hình &amp; sức khỏe hiện có của shop như Whey, Mass, Pre-workout, Vitamin nha!";
                            }
                        }
                        
                        // 4. Fallback to standard rule-based responses if still null
                        if (aiReply == null) {
                            if (lowerText.contains("whey") || lowerText.contains("protein") || lowerText.contains("mass")) {
                                aiReply = "Chào bạn! NutriOverflow cung cấp các sản phẩm Whey Protein và Mass Gainer chính hãng tốt nhất từ các thương hiệu lớn như Optimum Nutrition, Mutant, Redcon1. Bạn có thể tham khảo chi tiết tại trang sản phẩm nhé!";
                            } else if (lowerText.contains("giá") || lowerText.contains("bao nhiêu") || lowerText.contains("tiền") || lowerText.contains("gia") || lowerText.contains("tien")) {
                                aiReply = "Dạ, giá sản phẩm được niêm yết công khai trên hệ thống và thường xuyên đi kèm khuyến mãi coupon giảm giá từ 10% - 30% tại tab Khuyến mãi đó ạ!";
                            } else if (lowerText.contains("ship") || lowerText.contains("giao hàng") || lowerText.contains("vận chuyển") || lowerText.contains("giao hang") || lowerText.contains("van chuyen")) {
                                aiReply = "Dạ, cửa hàng hỗ trợ giao hàng toàn quốc nhanh chóng và hỗ trợ giao hỏa tốc 2 giờ tại nội thành TP.HCM bạn nha.";
                            } else {
                                aiReply = "Chào bạn! Mình là trợ lý AI NutriBot. Mình luôn sẵn sàng giải đáp thắc mắc mua sắm của bạn. Bạn có thể gõ tìm sản phẩm (ví dụ: 'tìm whey dưới 1 triệu') hoặc gõ 'gặp nhân viên CSKH' nha.";
                            }
                        }
                        
                        // Insert AI reply
                        dao.insertMessage(sessionId, "AI", "NutriBot AI", aiReply);
                    }
                }

                jsonMap.put("success", ok);
                jsonMap.put("triggeredHandoff", triggeredHandoff);

            } else if ("triggerManualHandoff".equalsIgnoreCase(subAction)) {
                int sessionId = Integer.parseInt(request.getParameter("sessionId"));
                String customerName = request.getParameter("customerName");
                
                dao.insertMessage(sessionId, "CUSTOMER", customerName, "Yêu cầu gặp chuyên viên tư vấn trực tiếp.");
                
                String aiReply = "Dạ vâng, mình đang chuyển cuộc trò chuyện này cho nhân viên tư vấn CSKH trực tuyến. Vui lòng chờ nhân viên tiếp nhận trong giây lát ạ!";
                dao.insertMessage(sessionId, "AI", "NutriBot AI", aiReply);
                
                dao.updateSessionStatus(sessionId, "WAITING_STAFF");
                dao.insertMessage(sessionId, "AI", "NutriBot AI", "[Hệ thống] Khách hàng đã chủ động yêu cầu gặp trực tiếp nhân viên CSKH.");
                
                jsonMap.put("success", true);

            } else {
                jsonMap.put("success", false);
                jsonMap.put("error", "Invalid subAction");
            }
        } catch (Exception e) {
            log("Error at CustomerChatController: " + e.toString());
            jsonMap.put("success", false);
            jsonMap.put("error", e.getMessage());
        }

        out.print(gson.toJson(jsonMap));
    }

    /**
     * Attempts to handle nutrition/calorie query by extracting food name and calling NutritionService.
     */
    private String tryHandleNutritionQuery(String text) {
        String lower = text.toLowerCase().trim();
        boolean isNutritionQuery = lower.contains("calo") || lower.contains("kcal") || 
                                   lower.contains("dinh dưỡng") || lower.contains("dinh duong") || 
                                   lower.contains("năng lượng") || lower.contains("nang luong") || 
                                   lower.contains("béo không") || lower.contains("beo khong") || 
                                   lower.contains("mập không") || lower.contains("map khong") || 
                                   lower.contains("ăn kiêng") || lower.contains("an kieng");
                                   
        if (!isNutritionQuery) {
            return null;
        }

        // Attempt to extract the food name by stripping away common query pattern words
        String foodName = text;
        foodName = foodName.replaceAll("(?i)(bao nhiêu calo|bao nhieu calo|bao nhiêu cal|bao nhieu cal|bao nhiêu kcal|bao nhieu kcal|bao nhiêu|bao nhieu|calo của món|calo cua mon|calo của|calo cua|calo|kcal|dinh dưỡng|dinh duong|năng lượng|nang luong|béo không|beo khong|mập không|map khong|ăn kiêng|an kieng|cho hỏi|cho hoi|hỏi về|hoi ve|tra cứu|tra cuu|thông tin|thong tin|của món|cua mon|của|cua|có|co|là|la|món|mon)", "");
        // Remove leading/trailing verbs like "ăn", "uống", "tìm", "mua" at word boundaries
        foodName = foodName.replaceAll("(?i)\\b(ăn|an|uống|uong|tìm|tim|kiếm|kiem|mua|xem|tra|bán|ban)\\b", "");
        foodName = foodName.replaceAll("\\s+", " ").trim();

        if (foodName.length() < 2) {
            return null;
        }

        // Call NutritionService
        utils.NutritionService.FoodNutrition nutrition = utils.NutritionService.getNutritionInfo(foodName);
        if (nutrition == null) {
            return null;
        }

        // Format the response into a clean, themed HTML representation matching the UI style
        String sourceName = "CSDL Local";
        if ("FATSECRET_API".equals(nutrition.source)) {
            sourceName = "FatSecret API";
        } else if ("MOCK_FALLBACK".equals(nutrition.source)) {
            sourceName = "CSDL Dự phòng";
        }

        StringBuilder sb = new StringBuilder();
        sb.append("Dạ, NutriBot AI đã tra cứu thông tin dinh dưỡng của món <strong>").append(nutrition.name).append("</strong> đây ạ:<br/>");
        sb.append("<div style='margin: 10px 0; padding: 12px; background: rgba(255,255,255,0.06); border-left: 4px solid #00e676; border-radius: 8px; font-size: 0.9rem;'>");
        sb.append("• <strong>Khẩu phần chuẩn:</strong> ").append(nutrition.servingSize).append("<br/>");
        sb.append("• <strong>Năng lượng (Calo):</strong> <span style='color: #ffc107; font-weight: bold;'>").append(nutrition.calories).append(" kcal</span><br/>");
        sb.append("• <strong>Protein (Đạm):</strong> ").append(nutrition.protein).append(" g<br/>");
        sb.append("• <strong>Carb (Tinh bột):</strong> ").append(nutrition.carbs).append(" g<br/>");
        sb.append("• <strong>Fat (Chất béo):</strong> ").append(nutrition.fat).append(" g<br/>");
        if (nutrition.description != null && !nutrition.description.isEmpty()) {
            sb.append("<hr style='border-top: 1px solid rgba(255,255,255,0.1); margin: 8px 0;'/>");
            sb.append("• <strong>Ghi chú:</strong> <em>").append(nutrition.description).append("</em><br/>");
        }
        sb.append("<span style='font-size: 0.75rem; color: rgba(255,255,255,0.45); display: block; margin-top: 6px; white-space: nowrap;'>[Nguồn: ").append(sourceName).append("]</span>");
        sb.append("</div>");
        
        if (nutrition.calories > 350) {
            sb.append("Món này có lượng calo khá cao đó ạ. Nếu bạn đang giảm cân, bạn có thể bổ sung các sản phẩm <strong>Fat Burner (Đốt mỡ)</strong> hoặc dòng sản phẩm <strong>Đường ăn kiêng / Bún gạo lứt</strong> hỗ trợ ăn kiêng từ shop nha! Bạn có cần mình giới thiệu thêm các sản phẩm này không ạ?");
        } else {
            sb.append("Món này có lượng calo vừa phải/thấp, rất lý tưởng để giữ dáng! Nếu bạn đang tập luyện tăng cơ, đừng quên bổ sung thêm <strong>Whey Protein / Amino</strong> từ shop để tối ưu hóa hiệu quả nha! Bạn cần mình hỗ trợ thêm gì không ạ?");
        }
        
        return sb.toString();
    }

    /**
     * Resolves the integer Customer.user_id from the Account.username (String).
     */
    private Integer getCustomerIntId(String username) {
        String sql = "SELECT c.user_id FROM Customer c JOIN Account a ON c.account_id = a.account_id WHERE a.username = ?";
        try (java.sql.Connection conn = utils.DBUtils.getConnection();
             java.sql.PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, username);
            try (java.sql.ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("user_id");
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException { processRequest(req, resp); }
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException { processRequest(req, resp); }
}

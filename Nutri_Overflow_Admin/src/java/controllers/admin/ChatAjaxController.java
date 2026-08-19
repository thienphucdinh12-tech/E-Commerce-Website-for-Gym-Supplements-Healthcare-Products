package controllers.admin;

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

@WebServlet(name = "ChatAjaxController", urlPatterns = {"/ChatAjaxController"})
public class ChatAjaxController extends HttpServlet {
    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("application/json;charset=UTF-8");
        request.setCharacterEncoding("UTF-8");

        HttpSession session = request.getSession(false);
        UserDTO loginUser = (session != null) ? (UserDTO) session.getAttribute("LOGIN_USER") : null;
        
        PrintWriter out = response.getWriter();
        Gson gson = new Gson();
        Map<String, Object> jsonMap = new HashMap<>();

        // Security check
        if (loginUser == null || (!"AD".equals(loginUser.getRoleID()) && !"MAN".equals(loginUser.getRoleID()) && !"CSKH".equals(loginUser.getRoleID()))) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            jsonMap.put("error", "Unauthorized access");
            out.print(gson.toJson(jsonMap));
            return;
        }

        String subAction = request.getParameter("subAction");
        ChatDAO dao = new ChatDAO();

        try {
            if ("getSessions".equalsIgnoreCase(subAction)) {
                String filter = request.getParameter("statusFilter");
                List<ChatSessionDTO> sessions = dao.getSessions(filter);
                jsonMap.put("success", true);
                jsonMap.put("sessions", sessions);

            } else if ("getMessages".equalsIgnoreCase(subAction)) {
                int sessionId = Integer.parseInt(request.getParameter("sessionId"));
                List<ChatMessageDTO> messages = dao.getSessionMessages(sessionId);
                jsonMap.put("success", true);
                jsonMap.put("messages", messages);

            } else if ("sendStaffMessage".equalsIgnoreCase(subAction)) {
                int sessionId = Integer.parseInt(request.getParameter("sessionId"));
                String text = request.getParameter("messageText");
                String staffName = loginUser.getFullName();

                boolean ok = dao.insertMessage(sessionId, "STAFF", staffName, text);
                jsonMap.put("success", ok);

            } else if ("connect".equalsIgnoreCase(subAction)) {
                int sessionId = Integer.parseInt(request.getParameter("sessionId"));
                String staffUsername = loginUser.getUserID();

                boolean ok = dao.assignStaff(sessionId, staffUsername);
                jsonMap.put("success", ok);

            } else if ("close".equalsIgnoreCase(subAction)) {
                int sessionId = Integer.parseInt(request.getParameter("sessionId"));
                boolean ok = dao.closeSession(sessionId);
                jsonMap.put("success", ok);

            } else if ("handback".equalsIgnoreCase(subAction)) {
                int sessionId = Integer.parseInt(request.getParameter("sessionId"));
                boolean ok = dao.handbackToAI(sessionId);
                jsonMap.put("success", ok);

            } else if ("createCustomerSession".equalsIgnoreCase(subAction)) {
                // Simulated customer starts a chat session
                String name = request.getParameter("customerName");
                if (name == null || name.trim().isEmpty()) {
                    name = "Khách vãng lai #" + (1000 + (int)(Math.random() * 9000));
                }
                int sessionId = dao.createSession(name, null, "ACTIVE");
                
                // Welcome message from AI
                dao.insertMessage(sessionId, "AI", "NutriBot AI", "Chào bạn " + name + "! Mình là trợ lý AI NutriBot. Bạn có thắc mắc gì về sản phẩm hay sức khỏe cần hỗ trợ không?");
                
                jsonMap.put("success", true);
                jsonMap.put("sessionId", sessionId);
                jsonMap.put("customerName", name);

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
                        // Normal AI responses
                        String aiReply = "";
                        if (lowerText.contains("whey") || lowerText.contains("protein") || lowerText.contains("mass")) {
                            aiReply = "Chào bạn! NutriOverflow cung cấp các sản phẩm Whey Protein và Mass Gainer chính hãng tốt nhất từ các thương hiệu lớn như Optimum Nutrition, Mutant, Redcon1. Bạn có thể tham khảo chi tiết tại tab Quản lý sản phẩm nhé!";
                        } else if (lowerText.contains("giá") || lowerText.contains("bao nhiêu") || lowerText.contains("tiền")) {
                            aiReply = "Dạ, giá sản phẩm được niêm yết công khai trên hệ thống và thường xuyên đi kèm khuyến mãi coupon giảm giá từ 10% - 30% tại tab Khuyến mãi đó ạ!";
                        } else if (lowerText.contains("ship") || lowerText.contains("giao hàng") || lowerText.contains("vận chuyển")) {
                            aiReply = "Dạ, cửa hàng hỗ trợ giao hàng toàn quốc nhanh chóng và hỗ trợ giao hỏa tốc 2 giờ tại nội thành TP.HCM bạn nha.";
                        } else {
                            aiReply = "Chào bạn! Mình là trợ lý AI NutriBot. Mình luôn sẵn sàng giải đáp thắc mắc mua sắm của bạn. Nếu cần tư vấn kỹ lưỡng hơn, bạn có thể gõ 'gặp nhân viên CSKH' nha.";
                        }
                        
                        // Insert AI reply with a tiny delay simulated in frontend or instantly here
                        dao.insertMessage(sessionId, "AI", "NutriBot AI", aiReply);
                    }
                }

                jsonMap.put("success", ok);
                jsonMap.put("triggeredHandoff", triggeredHandoff);

            } else if ("triggerManualHandoff".equalsIgnoreCase(subAction)) {
                // Customer manually requests CSKH staff
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
            log("Error at ChatAjaxController: " + e.toString());
            jsonMap.put("success", false);
            jsonMap.put("error", e.getMessage());
        }

        out.print(gson.toJson(jsonMap));
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException { processRequest(req, resp); }
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException { processRequest(req, resp); }
}

package controllers.admin;

import java.io.IOException;
import java.net.URLEncoder;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import shopping.SupportTicketDAO;
import user.UserDTO;

@WebServlet(name = "TicketActionController", urlPatterns = {"/TicketActionController"})
public class TicketActionController extends HttpServlet {
    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("text/html;charset=UTF-8");
        request.setCharacterEncoding("UTF-8");

        HttpSession session = request.getSession(false);
        UserDTO loginUser = (session != null) ? (UserDTO) session.getAttribute("LOGIN_USER") : null;
        if (loginUser == null || (!"AD".equals(loginUser.getRoleID()) && !"MAN".equals(loginUser.getRoleID()) && !"CSKH".equals(loginUser.getRoleID()))) {
            response.sendRedirect("admin_login.jsp");
            return;
        }

        String subAction = request.getParameter("subAction");
        String search = request.getParameter("search");
        String statusFilter = request.getParameter("statusFilter");
        String categoryFilter = request.getParameter("categoryFilter");

        if (search == null) search = "";
        if (statusFilter == null) statusFilter = "all";
        if (categoryFilter == null) categoryFilter = "all";

        String redirectUrl = "MainController?action=ManageTickets" +
                "&search=" + URLEncoder.encode(search, "UTF-8") +
                "&statusFilter=" + URLEncoder.encode(statusFilter, "UTF-8") +
                "&categoryFilter=" + URLEncoder.encode(categoryFilter, "UTF-8");

        SupportTicketDAO dao = new SupportTicketDAO();

        try {
            if ("process".equalsIgnoreCase(subAction)) {
                int ticketId = Integer.parseInt(request.getParameter("ticketId"));
                String status = request.getParameter("status");
                String feedback = request.getParameter("feedback");
                String staffUsername = loginUser.getUserID();

                if (feedback == null) feedback = "";

                boolean success = dao.updateTicket(ticketId, status, feedback, staffUsername);
                if (success) {
                    String statusLabel = "PENDING".equalsIgnoreCase(status) ? "Chờ tiếp nhận" :
                                         "PROCESSING".equalsIgnoreCase(status) ? "Đang xử lý" :
                                         "RESOLVED".equalsIgnoreCase(status) ? "Đã giải quyết" : "Đã chuyển tiếp";
                    session.setAttribute("SUCCESS_MESSAGE", "Cập nhật khiếu nại #" + ticketId + " thành công! Trạng thái: " + statusLabel);
                } else {
                    session.setAttribute("ERROR_MESSAGE", "Cập nhật khiếu nại thất bại!");
                }

            } else if ("delete".equalsIgnoreCase(subAction)) {
                // Security Check: ONLY Admin (AD) can delete tickets
                if (!"AD".equals(loginUser.getRoleID())) {
                    session.setAttribute("ERROR_MESSAGE", "Bạn không có quyền xóa khiếu nại!");
                } else {
                    int ticketId = Integer.parseInt(request.getParameter("ticketId"));
                    boolean success = dao.deleteTicket(ticketId);
                    if (success) {
                        session.setAttribute("SUCCESS_MESSAGE", "Xóa khiếu nại #" + ticketId + " thành công!");
                    } else {
                        session.setAttribute("ERROR_MESSAGE", "Xóa khiếu nại thất bại!");
                    }
                }
            } else {
                session.setAttribute("ERROR_MESSAGE", "Hành động không hợp lệ!");
            }
        } catch (Exception e) {
            log("Error at TicketActionController: " + e.toString());
            session.setAttribute("ERROR_MESSAGE", "Đã xảy ra lỗi: " + e.getMessage());
        }

        response.sendRedirect(redirectUrl);
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException { processRequest(req, resp); }
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException { processRequest(req, resp); }
}

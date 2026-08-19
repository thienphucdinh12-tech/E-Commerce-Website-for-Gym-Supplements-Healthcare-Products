package controllers.admin;

import java.io.IOException;
import java.net.URLEncoder;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import user.UserDAO;
import user.UserDTO;

@WebServlet(name = "ToggleUserActiveController", urlPatterns = {"/ToggleUserActiveController"})
public class ToggleUserActiveController extends HttpServlet {
    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("text/html;charset=UTF-8");
        request.setCharacterEncoding("UTF-8");
        
        HttpSession session = request.getSession(false);
        UserDTO loginUser = (session != null) ? (UserDTO) session.getAttribute("LOGIN_USER") : null;
        if (loginUser == null || !"AD".equals(loginUser.getRoleID())) {
            response.sendRedirect("admin_login.jsp");
            return;
        }

        String search = request.getParameter("search");
        if (search == null) search = "";
        String subRole = request.getParameter("subRole");
        if (subRole == null || subRole.trim().isEmpty()) subRole = "US";
        
        String redirectUrl = "MainController?action=Search&search=" + URLEncoder.encode(search, "UTF-8")
                + "&subRole=" + URLEncoder.encode(subRole, "UTF-8");

        try {
            String userID = request.getParameter("userID");
            String activeStr = request.getParameter("active");
            if (userID != null && activeStr != null) {
                boolean active = Boolean.parseBoolean(activeStr);
                
                // Prevent admin from banning themselves
                if (userID.equals(loginUser.getUserID())) {
                    session.setAttribute("ERROR_MESSAGE", "Bạn không thể tự khóa tài khoản của chính mình!");
                } else {
                    UserDAO dao = new UserDAO();
                    boolean success = dao.toggleActive(userID, active);
                    if (success) {
                        String actionName = active ? "Kích hoạt" : "Khóa";
                        session.setAttribute("SUCCESS_MESSAGE", actionName + " tài khoản [" + userID + "] thành công!");
                    } else {
                        session.setAttribute("ERROR_MESSAGE", "Cập nhật trạng thái hoạt động tài khoản thất bại!");
                    }
                }
            }
        } catch (Exception e) {
            log("Error at ToggleUserActiveController: " + e.toString());
            session.setAttribute("ERROR_MESSAGE", "Lỗi xử lý kích hoạt tài khoản: " + e.getMessage());
        }
        response.sendRedirect(redirectUrl);
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException { processRequest(req, resp); }
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException { processRequest(req, resp); }
}

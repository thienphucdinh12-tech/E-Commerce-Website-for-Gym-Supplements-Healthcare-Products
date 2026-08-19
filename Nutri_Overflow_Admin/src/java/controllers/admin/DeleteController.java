package controllers.admin;

import java.io.IOException;
import java.net.URLEncoder;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import user.UserDAO;
import user.UserDTO;

@WebServlet(name = "DeleteController", urlPatterns = {"/DeleteController"})
public class DeleteController extends HttpServlet {
    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        
        // Security Check
        HttpSession session = request.getSession(false);
        UserDTO loginUser = (session != null) ? (UserDTO) session.getAttribute("LOGIN_USER") : null;
        if (loginUser == null || !"AD".equals(loginUser.getRoleID())) {
            response.sendRedirect("admin_login.jsp");
            return;
        }

        String userID = request.getParameter("userID");
        String search = request.getParameter("search");
        if (search == null) search = "";
        String subRole = request.getParameter("subRole");
        if (subRole == null || subRole.trim().isEmpty()) subRole = "US";

        try {
            if (userID.equals(loginUser.getUserID())) {
                request.setAttribute("ERROR", "Bạn không thể xóa tài khoản mà bạn đang dùng để đăng nhập!");
                request.getRequestDispatcher("MainController?action=Search&subRole=" + subRole).forward(request, response);
            } else {
                UserDAO dao = new UserDAO();
                if (dao.delete(userID)) {
                    response.sendRedirect("MainController?action=Search&search=" + URLEncoder.encode(search, "UTF-8")
                            + "&subRole=" + URLEncoder.encode(subRole, "UTF-8"));
                } else {
                    request.setAttribute("ERROR", "Xóa tài khoản thất bại!");
                    request.getRequestDispatcher("MainController?action=Search&subRole=" + subRole).forward(request, response);
                }
            }
        } catch (Exception e) {
            log("Error at DeleteController: " + e.toString());
        }
    }
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException { processRequest(req, resp); }
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException { processRequest(req, resp); }
}
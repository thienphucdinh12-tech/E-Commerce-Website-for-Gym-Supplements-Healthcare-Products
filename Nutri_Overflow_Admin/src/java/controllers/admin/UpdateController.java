package controllers.admin;

import java.io.IOException;
import java.net.URLEncoder;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import user.UserDAO;
import user.UserDTO;

@WebServlet(name = "UpdateController", urlPatterns = {"/UpdateController"})
public class UpdateController extends HttpServlet {
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

        String url = "admin.jsp";
        try {
            String userID = request.getParameter("userID");
            String fullName = request.getParameter("fullName");
            String roleID = request.getParameter("roleID");
            String search = request.getParameter("search");
            if (search == null) search = "";
            String subRole = request.getParameter("subRole");
            if (subRole == null || subRole.trim().isEmpty()) subRole = "US";
            
            UserDAO dao = new UserDAO();
            UserDTO user = new UserDTO(userID, fullName, roleID, "");
            if (dao.update(user)) {
                // If updating self, update the current session data
                if (userID.equals(loginUser.getUserID())) {
                    loginUser.setFullName(fullName);
                    loginUser.setRoleID(roleID);
                    session.setAttribute("LOGIN_USER", loginUser);
                }
                url = "MainController?action=Search&search=" + URLEncoder.encode(search, "UTF-8")
                        + "&subRole=" + URLEncoder.encode(subRole, "UTF-8");
                response.sendRedirect(url);
                return; // Prevent request forward below
            }
        } catch (Exception e) {
            log("Error at UpdateController: " + e.toString());
        }
        request.getRequestDispatcher(url).forward(request, response);
    }
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException { processRequest(req, resp); }
}
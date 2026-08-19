package controllers.admin;

import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import user.UserDAO;
import user.UserDTO;
import user.UserError;

@WebServlet(name = "CreateController", urlPatterns = {"/CreateController"})
public class CreateController extends HttpServlet {
    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("text/html;charset=UTF-8");
        request.setCharacterEncoding("UTF-8");
        
        // Security Check
        HttpSession session = request.getSession(false);
        UserDTO loginUser = (session != null) ? (UserDTO) session.getAttribute("LOGIN_USER") : null;
        if (loginUser == null || !"AD".equals(loginUser.getRoleID())) {
            response.sendRedirect("admin_login.jsp");
            return;
        }

        String url = "createUser.jsp";
        UserError userError = new UserError();
        try {
            String userID = request.getParameter("userID");
            String fullName = request.getParameter("fullName");
            String roleID = request.getParameter("roleID");
            String password = request.getParameter("password");
            String confirm = request.getParameter("confirm");
            boolean checkValidation = true;
            
            if (userID.length() < 2 || userID.length() > 10) {
                userError.setUserID("Tên đăng nhập phải từ 2 đến 10 ký tự!");
                checkValidation = false;
            }
            if (fullName.length() < 5 || fullName.length() > 50) {
                userError.setFullName("Họ và tên phải từ 5 đến 50 ký tự!");
                checkValidation = false;
            }
            if (!password.equals(confirm)) {
                userError.setConfirm("Mật khẩu xác nhận không khớp!");
                checkValidation = false;
            }

            String subRole = request.getParameter("subRole");
            if (subRole == null || subRole.trim().isEmpty()) subRole = "US";
            if (checkValidation) {
                UserDAO dao = new UserDAO();
                UserDTO user = new UserDTO(userID, fullName, roleID, password);
                if (dao.insert(user)) {
                    url = "MainController?action=Search&search=&subRole=" + subRole; // Reload list
                }
            } else {
                request.setAttribute("USER_ERROR", userError);
            }
        } catch (Exception e) {
            log("Error at CreateController: " + e.toString());
            if (e.toString().contains("duplicate") || e.toString().contains("PRIMARY KEY")) {
                userError.setUserID("Tên đăng nhập này đã tồn tại, vui lòng chọn tên khác!");
                request.setAttribute("USER_ERROR", userError);
            }
        } finally {
            request.getRequestDispatcher(url).forward(request, response);
        }
    }
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException { processRequest(req, resp); }
}
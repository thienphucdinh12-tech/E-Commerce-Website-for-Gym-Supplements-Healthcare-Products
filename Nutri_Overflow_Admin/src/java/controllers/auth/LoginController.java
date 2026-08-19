package controllers.auth;

import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import user.UserDAO;
import user.UserDTO;

@WebServlet(name = "LoginController", urlPatterns = {"/LoginController"})
public class LoginController extends HttpServlet {
    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("text/html;charset=UTF-8");
        String url = "admin_login.jsp";
        
        try {
            String userID = request.getParameter("userID");
            String password = request.getParameter("password");
            UserDAO dao = new UserDAO();
            UserDTO loginUser = dao.checkLogin(userID, password);
            if (loginUser != null) {
                String roleID = loginUser.getRoleID();
                if ("US".equals(roleID)) {
                    request.setAttribute("ERROR_MESSAGE", "Bạn không có quyền truy cập vào trang Quản trị!");
                } else {
                    HttpSession session = request.getSession();
                    session.setAttribute("LOGIN_USER", loginUser);
                    if ("AD".equals(roleID)) {
                        url = "MainController?action=Search";
                    } else if ("MAN".equals(roleID)) {
                        url = "MainController?action=ManageProducts";
                    } else if ("KHO".equals(roleID)) {
                        url = "MainController?action=ManageBatches";
                    } else if ("CSKH".equals(roleID)) {
                        url = "MainController?action=ManageArticles";
                    } else {
                        url = "MainController?action=Search";
                    }
                }
            } else {
                request.setAttribute("ERROR_MESSAGE", "Tên đăng nhập hoặc mật khẩu không chính xác!");
            }
        } catch (Exception e) {
            log("Error at LoginController: " + e.toString());
        } finally {
            request.getRequestDispatcher(url).forward(request, response);
        }
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException { processRequest(req, resp); }
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException { processRequest(req, resp); }
}
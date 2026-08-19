package controllers.admin;

import java.io.IOException;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import user.UserDAO;
import user.UserDTO;

@WebServlet(name = "SearchController", urlPatterns = {"/SearchController"})
public class SearchController extends HttpServlet {
    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("text/html;charset=UTF-8");
        request.setCharacterEncoding("UTF-8");
        
        // --- SECURITY CHECK: Verify Admin role ---
        HttpSession session = request.getSession(false);
        UserDTO loginUser = (session != null) ? (UserDTO) session.getAttribute("LOGIN_USER") : null;
        if (loginUser == null || !"AD".equals(loginUser.getRoleID())) {
            response.sendRedirect("admin_login.jsp");
            return;
        }

        String url = "admin.jsp";
        try {
            String search = request.getParameter("search");
            if (search == null) search = "";
            String subRole = request.getParameter("subRole");
            if (subRole == null || subRole.trim().isEmpty()) {
                subRole = "US";
            }
            request.setAttribute("subRole", subRole);

            UserDAO dao = new UserDAO();
            List<UserDTO> listUser = dao.getListUser(search, subRole);
            if (listUser == null || listUser.isEmpty()) {
                request.setAttribute("EMPTY_MESSAGE", "Không tìm thấy kết quả nào!");
            } else {
                request.setAttribute("LIST_USER", listUser);
            }
        } catch (Exception e) {
            log("Error at SearchController: " + e.toString());
        } finally {
            request.getRequestDispatcher(url).forward(request, response);
        }
    }
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException { processRequest(req, resp); }
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException { processRequest(req, resp); }
}
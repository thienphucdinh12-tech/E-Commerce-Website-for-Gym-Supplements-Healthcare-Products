package controllers.admin;

import java.io.IOException;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import shopping.ArticleDAO;
import shopping.Article;
import user.UserDTO;

@WebServlet(name = "ManageArticlesController", urlPatterns = {"/ManageArticlesController"})
public class ManageArticlesController extends HttpServlet {
    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("text/html;charset=UTF-8");
        request.setCharacterEncoding("UTF-8");

        // --- SECURITY CHECK: Verify Admin role ---
        HttpSession session = request.getSession(false);
        UserDTO loginUser = (session != null) ? (UserDTO) session.getAttribute("LOGIN_USER") : null;
        if (loginUser == null || (!"AD".equals(loginUser.getRoleID()) && !"MAN".equals(loginUser.getRoleID()) && !"CSKH".equals(loginUser.getRoleID()))) {
            response.sendRedirect("admin_login.jsp");
            return;
        }

        String url = "manage_articles.jsp";
        try {
            String search = request.getParameter("search");
            String statusFilter = request.getParameter("statusFilter");
            String publishFilter = request.getParameter("publishFilter");

            if (search == null) search = "";
            if (statusFilter == null) statusFilter = "all";
            if (publishFilter == null) publishFilter = "all";

            ArticleDAO dao = new ArticleDAO();
            List<Article> listArticles = dao.getAllArticles(search, statusFilter, publishFilter);

            request.setAttribute("LIST_ARTICLES", listArticles);
        } catch (Exception e) {
            log("Error at ManageArticlesController: " + e.toString());
        } finally {
            request.getRequestDispatcher(url).forward(request, response);
        }
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException { processRequest(req, resp); }
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException { processRequest(req, resp); }
}

package controllers.blog;

import blog.BlogDAO;
import blog.BlogDTO;
import java.io.IOException;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet(name = "BlogController", urlPatterns = {"/BlogController", "/bai-viet"})
public class BlogController extends HttpServlet {
    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("text/html;charset=UTF-8");
        String action = request.getParameter("action");
        String url = "blog.jsp";
        
        try {
            BlogDAO dao = new BlogDAO();
            if ("BlogDetail".equals(action)) {
                String idStr = request.getParameter("id");
                if (idStr != null) {
                    int id = Integer.parseInt(idStr);
                    BlogDTO blog = dao.getBlogById(id);
                    if (blog != null) {
                        request.setAttribute("BLOG", blog);
                        url = "blogDetail.jsp";
                    }
                }
            } else {
                List<BlogDTO> list = dao.getAllBlogs();
                request.setAttribute("BLOG_LIST", list);
                url = "blog.jsp";
            }
        } catch (Exception e) {
            log("Error at BlogController: " + e.toString());
        } finally {
            request.getRequestDispatcher(url).forward(request, response);
        }
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException { processRequest(req, resp); }
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException { processRequest(req, resp); }
}

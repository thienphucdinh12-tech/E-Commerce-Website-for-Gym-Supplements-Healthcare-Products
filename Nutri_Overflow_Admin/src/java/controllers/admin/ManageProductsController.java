package controllers.admin;

import java.io.IOException;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import shopping.ProductDAO;
import shopping.Product;
import shopping.CategoryDTO;
import user.UserDTO;

@WebServlet(name = "ManageProductsController", urlPatterns = {"/ManageProductsController"})
public class ManageProductsController extends HttpServlet {
    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("text/html;charset=UTF-8");
        request.setCharacterEncoding("UTF-8");
        
        // --- SECURITY CHECK: Verify Admin/Manager role ---
        HttpSession session = request.getSession(false);
        UserDTO loginUser = (session != null) ? (UserDTO) session.getAttribute("LOGIN_USER") : null;
        if (loginUser == null || (!"AD".equals(loginUser.getRoleID()) && !"MAN".equals(loginUser.getRoleID()))) {
            response.sendRedirect("admin_login.jsp");
            return;
        }

        String url = "manage_products.jsp";
        try {
            String search = request.getParameter("search");
            String category = request.getParameter("category");
            String stockFilter = request.getParameter("stockFilter");

            if (search == null || "false".equalsIgnoreCase(search.trim())) search = "";
            if (category == null || "false".equalsIgnoreCase(category.trim())) category = "all";
            if (stockFilter == null || "false".equalsIgnoreCase(stockFilter.trim())) stockFilter = "all";

            ProductDAO dao = new ProductDAO();
            List<CategoryDTO> listCategory = dao.getAllCategories();
            List<Product> listProduct = dao.getAllProductsAdmin(search, category, stockFilter);

            request.setAttribute("LIST_CATEGORY", listCategory);
            request.setAttribute("LIST_PRODUCT", listProduct);
        } catch (Exception e) {
            log("Error at ManageProductsController: " + e.toString());
        } finally {
            request.getRequestDispatcher(url).forward(request, response);
        }
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException { processRequest(req, resp); }
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException { processRequest(req, resp); }
}

package controllers.product;

import java.io.IOException;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import shopping.Product;
import shopping.ProductDAO;

@WebServlet(name = "ShoppingController", urlPatterns = {"/ShoppingController"})
public class ShoppingController extends HttpServlet {
    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setContentType("text/html;charset=UTF-8");
        try {
            String txtSearch = request.getParameter("txtSearch");
            String categoryId = request.getParameter("category");
            ProductDAO dao = new ProductDAO();
            List<Product> listProduct;
            
            // Lọc sản phẩm kết hợp cả Danh mục và Từ khóa tìm kiếm
            listProduct = dao.getProductByFilter(categoryId, txtSearch);
            
            boolean isFiltered = (categoryId != null && !categoryId.trim().isEmpty()) || (txtSearch != null && !txtSearch.trim().isEmpty());
            if (!isFiltered) {
                // Trang chính không lọc -> Hiện Best Sellers và Flash Sale
                request.setAttribute("BEST_SELLERS", dao.getBestSellers());
                request.setAttribute("FLASH_SALE_LIST", dao.getFlashSaleProducts());
            }
            
            request.setAttribute("LIST_PRODUCT", listProduct);
        } catch (Exception e) {
            log("Error at ShoppingController: " + e.toString());
        } finally {
            request.getRequestDispatcher("shopping.jsp").forward(request, response);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException { processRequest(req, resp); }
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException { processRequest(req, resp); }
}
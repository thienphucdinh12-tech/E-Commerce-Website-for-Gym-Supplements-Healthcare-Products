package controllers.admin;

import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import shopping.ProductDAO;
import user.UserDTO;

@WebServlet(name = "DeleteProductController", urlPatterns = {"/DeleteProductController"})
public class DeleteProductController extends HttpServlet {
    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("text/html;charset=UTF-8");
        request.setCharacterEncoding("UTF-8");
        
        HttpSession session = request.getSession(false);
        UserDTO loginUser = (session != null) ? (UserDTO) session.getAttribute("LOGIN_USER") : null;
        if (loginUser == null || (!"AD".equals(loginUser.getRoleID()) && !"MAN".equals(loginUser.getRoleID()))) {
            response.sendRedirect("admin_login.jsp");
            return;
        }

        String search = request.getParameter("searchFilter");
        String categoryFilter = request.getParameter("categoryFilter");
        String stockFilter = request.getParameter("stockFilter");
        if (search == null || "false".equalsIgnoreCase(search.trim())) search = "";
        if (categoryFilter == null || "false".equalsIgnoreCase(categoryFilter.trim())) categoryFilter = "all";
        if (stockFilter == null || "false".equalsIgnoreCase(stockFilter.trim())) stockFilter = "all";

        String redirectUrl = "MainController?action=ManageProducts&search=" + java.net.URLEncoder.encode(search, "UTF-8")
                + "&category=" + java.net.URLEncoder.encode(categoryFilter, "UTF-8")
                + "&stockFilter=" + java.net.URLEncoder.encode(stockFilter, "UTF-8");

        try {
            String productIdStr = request.getParameter("productId");
            if (productIdStr != null && !productIdStr.trim().isEmpty()) {
                int productId = Integer.parseInt(productIdStr.trim());
                ProductDAO dao = new ProductDAO();
                boolean success = dao.deleteProduct(productId);
                if (success) {
                    session.setAttribute("SUCCESS_MESSAGE", "Đã xóa vĩnh viễn sản phẩm (ID: " + productId + ") và toàn bộ dữ liệu liên quan thành công!");
                } else {
                    session.setAttribute("ERROR_MESSAGE", "Xóa sản phẩm thất bại!");
                }
            }
        } catch (Exception e) {
            log("Error at DeleteProductController: " + e.toString());
            session.setAttribute("ERROR_MESSAGE", "Lỗi khi xóa sản phẩm: " + e.getMessage());
        }
        response.sendRedirect(redirectUrl);
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException { processRequest(req, resp); }
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException { processRequest(req, resp); }
}

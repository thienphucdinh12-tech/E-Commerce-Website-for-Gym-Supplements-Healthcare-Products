package controllers.admin;

import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import shopping.ProductDAO;
import user.UserDTO;

@WebServlet(name = "UpdateProductStockController", urlPatterns = {"/UpdateProductStockController"})
public class UpdateProductStockController extends HttpServlet {
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

        String search = request.getParameter("search");
        String category = request.getParameter("category");
        String stockFilter = request.getParameter("stockFilter");
        if (search == null) search = "";
        if (category == null) category = "all";
        if (stockFilter == null) stockFilter = "all";

        String url = "MainController?action=ManageProducts&search=" + java.net.URLEncoder.encode(search, "UTF-8")
                + "&category=" + java.net.URLEncoder.encode(category, "UTF-8")
                + "&stockFilter=" + java.net.URLEncoder.encode(stockFilter, "UTF-8");

        try {
            String productIdStr = request.getParameter("productId");
            String quantityStr = request.getParameter("quantity");
            if (productIdStr != null && quantityStr != null) {
                int productId = Integer.parseInt(productIdStr);
                int quantity = Integer.parseInt(quantityStr);
                if (quantity < 0) {
                    session.setAttribute("ERROR_MESSAGE", "Số lượng tồn kho không thể âm!");
                } else {
                    ProductDAO dao = new ProductDAO();
                    boolean success = dao.updateProductStock(productId, quantity);
                    if (success) {
                        session.setAttribute("SUCCESS_MESSAGE", "Cập nhật số lượng tồn kho thành công cho sản phẩm ID " + productId + "!");
                    } else {
                        session.setAttribute("ERROR_MESSAGE", "Cập nhật số lượng tồn kho thất bại!");
                    }
                }
            }
        } catch (Exception e) {
            log("Error at UpdateProductStockController: " + e.toString());
            session.setAttribute("ERROR_MESSAGE", "Lỗi hệ thống hoặc định dạng dữ liệu không hợp lệ!");
        }
        response.sendRedirect(url);
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException { processRequest(req, resp); }
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException { processRequest(req, resp); }
}

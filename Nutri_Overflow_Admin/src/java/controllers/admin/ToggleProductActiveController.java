package controllers.admin;

import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import shopping.ProductDAO;
import user.UserDTO;

@WebServlet(name = "ToggleProductActiveController", urlPatterns = {"/ToggleProductActiveController"})
public class ToggleProductActiveController extends HttpServlet {
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
        if (search == null) search = "";
        if (categoryFilter == null) categoryFilter = "all";
        if (stockFilter == null) stockFilter = "all";

        String redirectUrl = "MainController?action=ManageProducts&search=" + java.net.URLEncoder.encode(search, "UTF-8")
                + "&category=" + java.net.URLEncoder.encode(categoryFilter, "UTF-8")
                + "&stockFilter=" + java.net.URLEncoder.encode(stockFilter, "UTF-8");

        try {
            String productIdStr = request.getParameter("productId");
            String activeStr = request.getParameter("active");
            if (productIdStr != null && activeStr != null) {
                int productId = Integer.parseInt(productIdStr);
                boolean active = Boolean.parseBoolean(activeStr);
                ProductDAO dao = new ProductDAO();
                boolean success = dao.toggleActiveStatus(productId, active);
                if (success) {
                    session.setAttribute("SUCCESS_MESSAGE", "Thay đổi trạng thái hiển thị của sản phẩm (ID: " + productId + ") thành công!");
                } else {
                    session.setAttribute("ERROR_MESSAGE", "Thay đổi trạng thái hiển thị thất bại!");
                }
            }
        } catch (Exception e) {
            log("Error at ToggleProductActiveController: " + e.toString());
            session.setAttribute("ERROR_MESSAGE", "Lỗi dữ liệu kích hoạt: " + e.getMessage());
        }
        response.sendRedirect(redirectUrl);
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException { processRequest(req, resp); }
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException { processRequest(req, resp); }
}

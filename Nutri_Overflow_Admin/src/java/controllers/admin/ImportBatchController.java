package controllers.admin;

import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import shopping.StockBatchDAO;
import user.UserDTO;

@WebServlet(name = "ImportBatchController", urlPatterns = {"/ImportBatchController"})
public class ImportBatchController extends HttpServlet {
    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("text/html;charset=UTF-8");
        request.setCharacterEncoding("UTF-8");

        HttpSession session = request.getSession(false);
        UserDTO loginUser = (session != null) ? (UserDTO) session.getAttribute("LOGIN_USER") : null;
        if (loginUser == null || (!"AD".equals(loginUser.getRoleID()) 
                && !"MAN".equals(loginUser.getRoleID()) 
                && !"KHO".equals(loginUser.getRoleID()))) {
            response.sendRedirect("admin_login.jsp");
            return;
        }

        String search = request.getParameter("searchFilter");
        if (search == null) search = "";
        String redirectUrl = "MainController?action=ManageBatches&search=" + java.net.URLEncoder.encode(search, "UTF-8");

        try {
            String productIdStr = request.getParameter("productId");
            String quantityStr = request.getParameter("quantity");
            String batchNumber = request.getParameter("batchNumber");
            String mfgDate = request.getParameter("mfgDate");
            String expDate = request.getParameter("expDate");
            String distributorName = request.getParameter("distributorName");

            if (productIdStr == null || quantityStr == null || batchNumber == null || batchNumber.trim().isEmpty()) {
                if (session != null) {
                    session.setAttribute("ERROR_MESSAGE", "Vui lòng điền đầy đủ các thông tin bắt buộc!");
                }
                response.sendRedirect(redirectUrl);
                return;
            }

            int productId = Integer.parseInt(productIdStr);
            int quantity = Integer.parseInt(quantityStr);

            if (quantity <= 0) {
                if (session != null) {
                    session.setAttribute("ERROR_MESSAGE", "Số lượng nhập kho phải lớn hơn 0!");
                }
                response.sendRedirect(redirectUrl);
                return;
            }

            StockBatchDAO dao = new StockBatchDAO();
            boolean success = dao.insertBatch(productId, quantity, batchNumber.trim(), mfgDate, expDate, distributorName, loginUser.getUserID());
            if (success) {
                if (session != null) {
                    session.setAttribute("SUCCESS_MESSAGE", "Khai báo nhập lô hàng [" + batchNumber.trim() + "] thành công!");
                }
            } else {
                if (session != null) {
                    session.setAttribute("ERROR_MESSAGE", "Khai báo nhập lô hàng thất bại!");
                }
            }
        } catch (IllegalArgumentException e) {
            log("Date parsing error in ImportBatchController: " + e.toString());
            if (session != null) {
                session.setAttribute("ERROR_MESSAGE", "Định dạng ngày sản xuất hoặc hạn sử dụng không hợp lệ!");
            }
        } catch (Exception e) {
            log("Error at ImportBatchController: " + e.toString());
            if (session != null) {
                session.setAttribute("ERROR_MESSAGE", "Lỗi hệ thống: " + e.getMessage());
            }
        }
        response.sendRedirect(redirectUrl);
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException { processRequest(req, resp); }
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException { processRequest(req, resp); }
}

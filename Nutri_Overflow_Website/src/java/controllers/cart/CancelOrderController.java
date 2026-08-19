package controllers.cart;

import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import shopping.OrderHistoryDAO;
import user.UserDTO;

/**
 * CancelOrderController — handles canceling and deleting an unpaid pending order.
 * Restores product stock and deletes the order from the database.
 */
@WebServlet(name = "CancelOrderController", urlPatterns = {"/CancelOrderController"})
public class CancelOrderController extends HttpServlet {

    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("text/html;charset=UTF-8");
        
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("LOGIN_USER") == null) {
            response.sendRedirect("dang-nhap");
            return;
        }

        UserDTO loginUser = (UserDTO) session.getAttribute("LOGIN_USER");
        String username = loginUser.getUserID();

        try {
            String orderIdParam = request.getParameter("orderId");
            if (orderIdParam != null && !orderIdParam.trim().isEmpty()) {
                int orderId = Integer.parseInt(orderIdParam.trim());
                OrderHistoryDAO dao = new OrderHistoryDAO();
                
                // Retrieve order detail to fetch the GHN order code
                shopping.OrderHistory order = dao.getOrderDetail(orderId, username);
                if (order != null && order.getGhnOrderCode() != null && !order.getGhnOrderCode().trim().isEmpty()) {
                    try {
                        utils.GHNService.cancelOrder(order.getGhnOrderCode().trim());
                    } catch (Exception e) {
                        log("Failed to cancel order on GHN for order #" + orderId + ": " + e.getMessage());
                    }
                }
                
                boolean success = dao.deleteUnpaidOrder(orderId, username);
                if (success) {
                    session.setAttribute("ORDER_SUCCESS_MSG", "Hủy đơn hàng #" + orderId + " và hoàn trả số lượng sản phẩm vào kho thành công!");
                } else {
                    session.setAttribute("ORDER_ERROR_MSG", "Không thể hủy đơn hàng #" + orderId + ". Đơn hàng đã thanh toán hoặc đang được xử lý.");
                }
            } else {
                session.setAttribute("ORDER_ERROR_MSG", "Mã đơn hàng không hợp lệ.");
            }
        } catch (NumberFormatException e) {
            session.setAttribute("ORDER_ERROR_MSG", "Mã đơn hàng định dạng không chính xác.");
        } catch (Exception e) {
            log("Error at CancelOrderController: " + e.toString());
            session.setAttribute("ORDER_ERROR_MSG", "Có lỗi xảy ra khi hủy đơn hàng: " + e.getMessage());
        }

        response.sendRedirect("don-hang");
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        processRequest(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        processRequest(request, response);
    }
}

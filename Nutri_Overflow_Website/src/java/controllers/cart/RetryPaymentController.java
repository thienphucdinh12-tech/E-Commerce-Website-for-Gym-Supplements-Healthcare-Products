package controllers.cart;

import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import shopping.UnpaidOrderCountDAO;
import shopping.OrderHistoryDAO;
import shopping.OrderHistory;
import VNpay.VNPayService;
import user.UserDTO;

/**
 * Allows a user to retry (or initiate) payment for an order in FAILED/PENDING/UNPAID state.
 * Validates ownership and eligible status before generating a fresh VNPay URL.
 */
@WebServlet(name = "RetryPaymentController", urlPatterns = {"/RetryPaymentController"})
public class RetryPaymentController extends HttpServlet {

    private final VNPayService    vnPayService = new VNPayService();
    private final OrderHistoryDAO historyDAO   = new OrderHistoryDAO();
    private final UnpaidOrderCountDAO countDAO = new UnpaidOrderCountDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException { processRequest(request, response); }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException { processRequest(request, response); }

    private void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Must be logged in
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("LOGIN_USER") == null) {
            response.sendRedirect("dang-nhap");
            return;
        }

        UserDTO user     = (UserDTO) session.getAttribute("LOGIN_USER");
        if (!"US".equals(user.getRoleID())) {
            response.sendRedirect("cua-hang");
            return;
        }
        String  username = user.getUserID();

        try {
            String orderIdParam = request.getParameter("orderId");
            if (orderIdParam == null || orderIdParam.trim().isEmpty()) {
                response.sendRedirect("don-hang");
                return;
            }

            int orderId = Integer.parseInt(orderIdParam.trim());

            // Verify order belongs to this user
            OrderHistory order = historyDAO.getOrderDetail(orderId, username);

            if (order == null) {
                request.setAttribute("ERROR", "Không tìm thấy đơn hàng #" + orderId + ".");
                request.getRequestDispatcher("orderHistory.jsp").forward(request, response);
                return;
            }

            // Allow retry for FAILED, PENDING, UNPAID (not just FAILED)
            if (!order.isRetryable()) {
                request.setAttribute("ERROR",
                    "Đơn hàng #" + orderId + " không thể thanh toán lại (trạng thái: " +
                    order.getPaymentStatus() + ").");
                request.getRequestDispatcher("orderHistory.jsp").forward(request, response);
                return;
            }

            String paymentMethod = request.getParameter("paymentMethod");
            if (paymentMethod == null || paymentMethod.trim().isEmpty()) {
                paymentMethod = "VNPAY";
            }

            if ("COD".equalsIgnoreCase(paymentMethod)) {
                boolean success = historyDAO.updatePaymentMethodToCOD(orderId, username);
                if (success) {
                    session.setAttribute("ORDER_SUCCESS_MSG", "Phương thức thanh toán của đơn hàng #" + orderId + " đã được đổi sang nhận hàng thanh toán bằng tiền mặt (COD) thành công!");
                } else {
                    session.setAttribute("ORDER_ERROR_MSG", "Không thể cập nhật phương thức thanh toán cho đơn hàng #" + orderId + ".");
                }
                response.sendRedirect("don-hang");
            } else {
                // Get client IP
                String ipAddr = request.getHeader("X-Forwarded-For");
                if (ipAddr == null || ipAddr.isEmpty()) ipAddr = request.getRemoteAddr();

                long   amount    = (long) order.getTotalAmount();
                String orderInfo = "Thanh toan lai don hang NutriOverflow #" + orderId;

                // Generate a fresh VNPay payment URL with a new txn_ref
                String returnUrl  = VNpay.VNPayUtil.getReturnUrl(request);
                String paymentUrl = vnPayService.createPaymentUrl(orderId, amount, orderInfo, ipAddr, returnUrl);

                // Track this as the pending order in session
                session.setAttribute("PENDING_ORDER_ID", orderId);

                // Refresh badge
                session.setAttribute("UNREAD_NOTIF_COUNT",
                        countDAO.getUnreadNotifCount(username));

                response.sendRedirect(paymentUrl);
            }

        } catch (NumberFormatException e) {
            response.sendRedirect("don-hang");
        } catch (Exception e) {
            log("Error at RetryPaymentController: " + e.toString());
            request.setAttribute("ERROR", "Không thể khởi tạo thanh toán. Vui lòng thử lại.");
            request.getRequestDispatcher("orderHistory.jsp").forward(request, response);
        }
    }
}

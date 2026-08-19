package VNpay;

import java.io.IOException;
import java.util.HashMap;
import java.util.Map;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import notifications.OrderNotification;
import notifications.OrderNotificationDAO;
import shopping.UnpaidOrderCountDAO;
import shopping.OrderHistoryDAO;
import shopping.Cart;
import user.UserDTO;
import VNPayDAO.VNPayOrderDAO;

/**
 * VNPayReturnController — handles the browser redirect back from VNPay.
 *
 * Flow:
 *  1. Verify signature
 *  2a. SUCCESS (00): clear user cart + PENDING_ORDER_ID from session,
 *                    save SUCCESS notification, update badge, redirect to paymentResult.jsp
 *  2b. FAILED / INVALID: keep cart, save FAILED notification, update badge,
 *                         show error page (paymentResult.jsp in FAILED state)
 */
@WebServlet(name = "VNPayReturnController", urlPatterns = {"/VNPayReturnController"})
public class VNPayReturnController extends HttpServlet {

    private final OrderNotificationDAO notifDAO = new OrderNotificationDAO();
    private final UnpaidOrderCountDAO  countDAO = new UnpaidOrderCountDAO();
    private final OrderHistoryDAO      historyDAO = new OrderHistoryDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        Map<String, String> params = new HashMap<>();
        request.getParameterMap().forEach((k, v) -> params.put(k, v[0]));

        String responseCode = params.get("vnp_ResponseCode");
        String txnRef       = params.get("vnp_TxnRef");

        // Extract orderId from txnRef format "orderId_timestamp"
        int orderId = -1;
        if (txnRef != null && txnRef.contains("_")) {
            try { orderId = Integer.parseInt(txnRef.split("_")[0]); } catch (Exception ignored) {}
        }

        // Determine username for notifications
        HttpSession session  = request.getSession(false);
        String      username = null;
        if (session != null && session.getAttribute("LOGIN_USER") != null) {
            username = ((UserDTO) session.getAttribute("LOGIN_USER")).getUserID();
        }

        try {
            boolean isValid = VNPayUtil.verifySignature(params, VNPayUtil.HASH_SECRET);

            if (!isValid) {
                // ── INVALID SIGNATURE ──────────────────────────────────────
                if (orderId > 0) {
                    if (username == null) {
                        username = historyDAO.getUsernameByOrderId(orderId);
                    }
                    if (username != null) {
                        historyDAO.deleteUnpaidOrder(orderId, username);
                    }
                }
                if (session != null) {
                    Cart backupCart = (Cart) session.getAttribute("BACKUP_CART");
                    if (backupCart != null) {
                        session.setAttribute("CART", backupCart);
                        session.removeAttribute("BACKUP_CART");
                    }
                }
                request.setAttribute("ERROR_MESSAGE", "Chữ ký giao dịch không hợp lệ. Vui lòng liên hệ hỗ trợ.");
                request.getRequestDispatcher("MainController?action=ViewCart").forward(request, response);
                return;

            } else if ("00".equals(responseCode)) {
                // ── PAYMENT SUCCESS ────────────────────────────────────────
                try {
                    VNPayOrderDAO orderDAO = new VNPayOrderDAO();
                    orderDAO.updatePaymentResult(txnRef, "PAID", params.get("vnp_TransactionNo"), params.get("vnp_BankCode"));
                } catch (Exception e) {
                    log("Failed to update database on successful payment return: " + e.toString());
                }

                if (session != null) {
                    // Clear cart — payment confirmed
                    session.removeAttribute("CART");
                    // Clear backup cart
                    session.removeAttribute("BACKUP_CART");
                    // Clear idempotency tracker
                    session.removeAttribute("PENDING_ORDER_ID");

                    if (username != null) {
                        try {
                            shopping.CartPersistenceDAO cartDAO = new shopping.CartPersistenceDAO();
                            cartDAO.clearCart(username);
                        } catch (Exception ex) {
                            log("Failed to clear DB cart on VNPay success: " + ex.toString());
                        }

                        // Save SUCCESS notification
                        notifDAO.save(
                            username, orderId,
                            "PAYMENT_SUCCESS",
                            "Thanh toán thành công — Đơn #" + orderId,
                            "Đơn hàng #" + orderId + " đã được thanh toán thành công qua VNPay. " +
                            "Chúng tôi đang chuẩn bị hàng cho bạn."
                        );

                        // Refresh unread badge
                        session.setAttribute("UNREAD_NOTIF_COUNT",
                                countDAO.getUnreadNotifCount(username));
                    }
                }

                request.setAttribute("PAYMENT_STATUS", "SUCCESS");
                request.setAttribute("MESSAGE", "Thanh toán thành công! Đơn hàng đang được chuẩn bị.");
                request.setAttribute("TXN_REF",              txnRef);
                request.setAttribute("ORDER_ID",             orderId);
                request.setAttribute("VNP_AMOUNT",           params.get("vnp_Amount"));
                request.setAttribute("VNP_BANK_CODE",        params.get("vnp_BankCode"));
                request.setAttribute("VNP_TRANSACTION_NO",   params.get("vnp_TransactionNo"));

            } else {
                // ── PAYMENT FAILED / CANCELED ──────────────────────────────
                if (orderId > 0) {
                    if (username == null) {
                        username = historyDAO.getUsernameByOrderId(orderId);
                    }
                    if (username != null) {
                        historyDAO.deleteUnpaidOrder(orderId, username);
                    }
                }
                if (session != null) {
                    Cart backupCart = (Cart) session.getAttribute("BACKUP_CART");
                    if (backupCart != null) {
                        session.setAttribute("CART", backupCart);
                        session.removeAttribute("BACKUP_CART");
                    }
                }

                request.setAttribute("ERROR_MESSAGE", "Thanh toán không thành công hoặc đã bị hủy. Đơn hàng chưa được tạo, vui lòng thực hiện lại.");
                request.getRequestDispatcher("MainController?action=ViewCart").forward(request, response);
                return;
            }

        } catch (Exception e) {
            log("Error at VNPayReturnController: " + e.toString());
            request.setAttribute("PAYMENT_STATUS", "ERROR");
            request.setAttribute("MESSAGE", "Đã xảy ra lỗi không mong muốn. Vui lòng liên hệ hỗ trợ.");
            request.setAttribute("ORDER_ID", orderId);
        }

        request.getRequestDispatcher("paymentResult.jsp").forward(request, response);
    }
}

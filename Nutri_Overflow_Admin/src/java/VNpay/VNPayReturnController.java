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
import user.UserDTO;

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
                request.setAttribute("PAYMENT_STATUS", "INVALID");
                request.setAttribute("MESSAGE", "Chữ ký giao dịch không hợp lệ. Vui lòng liên hệ hỗ trợ.");
                request.setAttribute("ORDER_ID", orderId);

            } else if ("00".equals(responseCode)) {
                // ── PAYMENT SUCCESS ────────────────────────────────────────
                if (session != null) {
                    // Clear cart — payment confirmed
                    session.removeAttribute("CART");
                    // Clear idempotency tracker
                    session.removeAttribute("PENDING_ORDER_ID");

                    if (username != null) {
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
                // ── PAYMENT FAILED ─────────────────────────────────────────
                if (session != null && username != null) {
                    // Save FAILED notification
                    notifDAO.save(
                        username, orderId,
                        "PAYMENT_FAILED",
                        "Thanh toán thất bại — Đơn #" + orderId,
                        "Thanh toán cho đơn hàng #" + orderId + " không thành công (mã lỗi: " +
                        responseCode + "). Đơn hàng vẫn được lưu — bạn có thể thanh toán lại."
                    );

                    // Refresh unread badge (new failed notification added)
                    session.setAttribute("UNREAD_NOTIF_COUNT",
                            countDAO.getUnreadNotifCount(username));

                    // Keep PENDING_ORDER_ID so user can retry from cart
                }

                request.setAttribute("PAYMENT_STATUS", "FAILED");
                request.setAttribute("MESSAGE", "Thanh toán không hoàn tất. Bạn có thể thử lại từ Lịch sử đơn hàng.");
                request.setAttribute("TXN_REF",             txnRef);
                request.setAttribute("ORDER_ID",            orderId);
                request.setAttribute("VNP_RESPONSE_CODE",  responseCode);
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

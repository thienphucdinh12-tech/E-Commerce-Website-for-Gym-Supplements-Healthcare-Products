/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package VNpay;


import VNPayDAO.VNPayIPNLogDAO;
import VNPayDAO.VNPayOrderDAO;
import java.util.Map;

/**
 *
 * @author ADMIN
 */
public class VNPayService {
    
    private final VNPayOrderDAO orderDAO   = new VNPayOrderDAO();
    private final VNPayIPNLogDAO logDAO    = new VNPayIPNLogDAO();

    // =====================================================
    // Xử lý IPN từ VNPay gọi về
    // =====================================================
    public String processIPN(Map<String, String> params) {
        int logId = -1;
        try {
            // 1. Build log và lưu ngay (chưa verify)
            VNPayIPNLog log = buildLog(params);
            logId = logDAO.save(log);

            // 2. Verify chữ ký
            boolean isValid = VNPayUtil.verifySignature(params, VNPayUtil.HASH_SECRET);
            if (!isValid) {
                logDAO.updateVerifyResult(logId, false, -1);
                return "{\"RspCode\":\"97\",\"Message\":\"Invalid signature\"}";
            }

            // 3. Tìm đơn hàng theo txn_ref
            String txnRef = params.get("vnp_TxnRef");
            Order order = orderDAO.findByTxnRef(txnRef);

            if (order == null) {
                logDAO.updateVerifyResult(logId, true, -1);
                return "{\"RspCode\":\"01\",\"Message\":\"Order not found\"}";
            }

            // 4. Cập nhật log với order_id
            logDAO.updateVerifyResult(logId, true, order.getOrderId());

            // 5. Idempotent — đã xử lý rồi thì bỏ qua, không update lại
            String currentStatus = order.getPaymentStatus();
            if ("PAID".equals(currentStatus) || "FAILED".equals(currentStatus)) {
                return "{\"RspCode\":\"02\",\"Message\":\"Order already updated\"}";
            }

            // 6. Cập nhật kết quả thanh toán vào Orders
            String responseCode    = params.get("vnp_ResponseCode");
            if (!"00".equals(responseCode)) {
                // Payment failed/canceled: delete the order and restore stock/coupons
                shopping.OrderHistoryDAO historyDAO = new shopping.OrderHistoryDAO();
                String orderUsername = historyDAO.getUsernameByOrderId(order.getOrderId());
                if (orderUsername != null) {
                    historyDAO.deleteUnpaidOrder(order.getOrderId(), orderUsername);
                }
                return "{\"RspCode\":\"00\",\"Message\":\"Confirm success\"}";
            }

            String paymentStatus   = "PAID";
            String vnpTransactionNo = params.get("vnp_TransactionNo");
            String vnpBankCode     = params.get("vnp_BankCode");

            orderDAO.updatePaymentResult(txnRef, paymentStatus, vnpTransactionNo, vnpBankCode);

            return "{\"RspCode\":\"00\",\"Message\":\"Confirm success\"}";

        } catch (Exception e) {
            e.printStackTrace();
            return "{\"RspCode\":\"99\",\"Message\":\"Unknown error\"}";
        }
    }

    // =====================================================
    // Tạo link thanh toán VNPay (gọi từ CheckoutController)
    // =====================================================
    public String createPaymentUrl(int orderId, long amount,
                                    String orderInfo, String ipAddr, String returnUrl) throws Exception {
        // Sinh txn_ref unique và lưu vào Orders
        String txnRef = VNPayUtil.generateTxnRef(orderId);
        orderDAO.saveTxnRef(orderId, txnRef);

        // Build URL redirect sang VNPay
        return VNPayUtil.buildPaymentUrl(orderId, txnRef, amount, orderInfo, ipAddr, returnUrl);
    }

    // =====================================================
    // Build VNPayIPNLog từ params
    // =====================================================
    private VNPayIPNLog buildLog(Map<String, String> params) {
        VNPayIPNLog log = new VNPayIPNLog();
        log.setVnpTmnCode(params.get("vnp_TmnCode"));
        log.setVnpAmount(parseLong(params.get("vnp_Amount")));
        log.setVnpBankCode(params.get("vnp_BankCode"));
        log.setVnpBankTranNo(params.get("vnp_BankTranNo"));
        log.setVnpCardType(params.get("vnp_CardType"));
        log.setVnpOrderInfo(params.get("vnp_OrderInfo"));
        log.setVnpTransactionNo(params.get("vnp_TransactionNo"));
        log.setVnpResponseCode(params.get("vnp_ResponseCode"));
        log.setVnpTransactionStatus(params.get("vnp_TransactionStatus"));
        log.setVnpTxnRef(params.get("vnp_TxnRef"));
        log.setVnpSecureHash(params.get("vnp_SecureHash"));
        log.setRawParams(params.toString());
        return log;
    }

    private long parseLong(String value) {
        try { return Long.parseLong(value); }
        catch (Exception e) { return 0; }
    }
}

package VNPayDAO;

import VNpay.Order;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import utils.DBUtils;

/**
 * DAO for VNPay-related order operations.
 */
public class VNPayOrderDAO {

    /** Find an order by txn_ref (used during IPN processing) */
    public Order findByTxnRef(String txnRef) throws Exception {
        String sql = "SELECT * FROM Orders WHERE txn_ref = ?";
        try (Connection conn = DBUtils.getConnection();
             PreparedStatement ptm = conn.prepareStatement(sql)) {
            ptm.setString(1, txnRef);
            try (ResultSet rs = ptm.executeQuery()) {
                if (rs.next()) return mapRow(rs);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    /** Find an order by order_id (used for retry payment) */
    public Order findByOrderId(int orderId) throws Exception {
        String sql = "SELECT * FROM Orders WHERE order_id = ?";
        try (Connection conn = DBUtils.getConnection();
             PreparedStatement ptm = conn.prepareStatement(sql)) {
            ptm.setInt(1, orderId);
            try (ResultSet rs = ptm.executeQuery()) {
                if (rs.next()) return mapRow(rs);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    /** Save txn_ref when initiating a new VNPay payment (creates fresh link) */
    public boolean saveTxnRef(int orderId, String txnRef) throws Exception {
        String sql = "UPDATE Orders SET txn_ref = ?, payment_method = 'VNPAY', payment_status = 'PENDING' WHERE order_id = ?";
        try (Connection conn = DBUtils.getConnection();
             PreparedStatement ptm = conn.prepareStatement(sql)) {
            ptm.setString(1, txnRef);
            ptm.setInt(2, orderId);
            return ptm.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    /**
     * Update the payment result after IPN is received.
     * PAID  → payment_status=PAID, status=PROCESSING (ready for shipping)
     * FAILED → payment_status=FAILED, status stays PENDING (user can retry)
     */
    public boolean updatePaymentResult(String txnRef, String paymentStatus,
                                        String vnpTransactionNo, String vnpBankCode) throws Exception {
        String sql = "UPDATE Orders " +
                     "SET payment_status       = ?, " +
                     "    vnp_transaction_no   = ?, " +
                     "    vnp_bank_code        = ?, " +
                     "    paid_at              = CASE WHEN ? = 'PAID' THEN GETDATE() ELSE NULL END, " +
                     "    status               = CASE WHEN ? = 'PAID' THEN 'PROCESSING' " +
                     "                               WHEN ? = 'FAILED' THEN 'PENDING' " +
                     "                               ELSE status END " +
                     "WHERE txn_ref = ?";
        try (Connection conn = DBUtils.getConnection();
             PreparedStatement ptm = conn.prepareStatement(sql)) {
            ptm.setString(1, paymentStatus);
            ptm.setString(2, vnpTransactionNo);
            ptm.setString(3, vnpBankCode);
            ptm.setString(4, paymentStatus);  // for paid_at CASE
            ptm.setString(5, paymentStatus);  // for status CASE PAID
            ptm.setString(6, paymentStatus);  // for status CASE FAILED
            ptm.setString(7, txnRef);
            return ptm.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    // ── Helper: map a ResultSet row to Order ──
    private Order mapRow(ResultSet rs) throws Exception {
        Order order = new Order();
        order.setOrderId(rs.getInt("order_id"));
        order.setUserId(rs.getInt("user_id"));
        order.setStatus(rs.getString("status"));
        try { order.setPaymentStatus(rs.getString("payment_status")); } catch (Exception ignored) {}
        try { order.setPaymentMethod(rs.getString("payment_method")); } catch (Exception ignored) {}
        try { order.setTxnRef(rs.getString("txn_ref")); }              catch (Exception ignored) {}
        try { order.setTotalAmount(rs.getBigDecimal("total_amount")); } catch (Exception ignored) {}
        return order;
    }
}

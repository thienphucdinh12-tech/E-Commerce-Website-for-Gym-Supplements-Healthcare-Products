/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package VNPayDAO;

import VNpay.VNPayIPNLog;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;
import utils.DBUtils;

/**
 *
 * @author ADMIN
 */
public class VNPayIPNLogDAO {
     public int save(VNPayIPNLog log) throws Exception {
       String sql = "INSERT INTO vnpay_ipn_logs " +
             "(order_id, vnp_TmnCode, vnp_Amount, vnp_BankCode, vnp_BankTranNo, " +
             " vnp_CardType, vnp_OrderInfo, vnp_TransactionNo, vnp_ResponseCode, " +
             " vnp_TransactionStatus, vnp_TxnRef, vnp_SecureHash, " +
             " is_valid_signature, raw_params, created_at) " +
             "VALUES (?,?,?,?,?,?,?,?,?,?,?,?,0,?,GETDATE())";
        try (Connection conn = DBUtils.getConnection();
             PreparedStatement ptm = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ptm.setObject(1, log.getOrderId());   // có thể null
            ptm.setString(2, log.getVnpTmnCode());
            ptm.setLong(3, log.getVnpAmount());
            ptm.setString(4, log.getVnpBankCode());
            ptm.setString(5, log.getVnpBankTranNo());
            ptm.setString(6, log.getVnpCardType());
            ptm.setString(7, log.getVnpOrderInfo());
            ptm.setString(8, log.getVnpTransactionNo());
            ptm.setString(9, log.getVnpResponseCode());
            ptm.setString(10, log.getVnpTransactionStatus());
            ptm.setString(11, log.getVnpTxnRef());
            ptm.setString(12, log.getVnpSecureHash());
            ptm.setString(13, log.getRawParams());
            ptm.executeUpdate();

            try (ResultSet rs = ptm.getGeneratedKeys()) {
                if (rs.next()) return rs.getInt(1); // trả về id vừa insert
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return -1;
    }

    // Cập nhật kết quả verify chữ ký và gắn order_id
    public void updateVerifyResult(int logId, boolean isValid, int orderId) throws Exception {
        String sql = "UPDATE vnpay_ipn_logs SET is_valid_signature = ?, order_id = ? WHERE id = ?";
        try (Connection conn = DBUtils.getConnection();
             PreparedStatement ptm = conn.prepareStatement(sql)) {
            ptm.setBoolean(1, isValid);
            ptm.setInt(2, orderId);
            ptm.setInt(3, logId);
            ptm.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}

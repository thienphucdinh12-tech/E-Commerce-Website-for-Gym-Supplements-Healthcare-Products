package shopping;

import utils.DBUtils;
import java.sql.*;

/**
 * Data Access Object for the Coupons table.
 * Schema: code, discount_amount, discount_percent, min_order_value,
 *         usage_limit, used_count, expiry_date, is_active
 */
public class CouponDAO {

    private static final String SQL_VALIDATE =
        "SELECT code, discount_amount, discount_percent, min_order_value, usage_limit, used_count, expiry_date, is_active " +
        "FROM Coupons WHERE code = ?";

    private static final String SQL_INCREMENT =
        "UPDATE Coupons SET used_count = used_count + 1 WHERE code = ?";

    /**
     * Validates a coupon code against the real DB schema.
     * Returns a CouponDTO with valid=true if usable, or valid=false + errorMsg if not.
     */
    public CouponDTO validate(String code) {
        if (code == null || code.trim().isEmpty()) {
            return new CouponDTO(code, "Vui lòng nhập mã giảm giá.");
        }
        code = code.trim().toUpperCase();

        try (Connection conn = DBUtils.getConnection();
             PreparedStatement ps = conn.prepareStatement(SQL_VALIDATE)) {

            ps.setString(1, code);
            try (ResultSet rs = ps.executeQuery()) {
                if (!rs.next()) {
                    return new CouponDTO(code, "Mã giảm giá không tồn tại.");
                }

                // Active check
                if (!rs.getBoolean("is_active")) {
                    return new CouponDTO(code, "Mã giảm giá này đã ngừng kích hoạt.");
                }

                // Expiry check
                Timestamp expiry = rs.getTimestamp("expiry_date");
                if (expiry != null && expiry.getTime() < System.currentTimeMillis()) {
                    return new CouponDTO(code, "Mã giảm giá này đã hết hạn.");
                }

                // Usage limit check
                int usageLimit = rs.getInt("usage_limit");
                boolean limitIsNull = rs.wasNull();
                int usedCount = rs.getInt("used_count");
                if (!limitIsNull && usedCount >= usageLimit) {
                    return new CouponDTO(code, "Mã giảm giá này đã đạt giới hạn sử dụng.");
                }

                // Min order value check
                double minOrderVal = rs.getDouble("min_order_value");
                // Note: minOrderVal validation could be added here, but it requires cart total.
                // We keep it valid here, and validation of min order total can be done in checkout.

                // Discount percent & amount
                int discountPct = rs.getInt("discount_percent");
                boolean pctNull = rs.wasNull();
                
                double discountAmt = rs.getDouble("discount_amount");
                boolean amtNull = rs.wasNull();

                if ((pctNull || discountPct <= 0) && (amtNull || discountAmt <= 0.0)) {
                    return new CouponDTO(code, "Mã giảm giá này không hợp lệ.");
                }

                if (!pctNull && discountPct > 0) {
                    return new CouponDTO(code, discountPct, 0.0);
                } else {
                    return new CouponDTO(code, 0, discountAmt);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
            return new CouponDTO(code, "Không thể kiểm tra mã giảm giá. Vui lòng thử lại.");
        }
    }

    /**
     * Increments used_count for a coupon after successful order creation.
     */
    public void incrementUsage(String code) {
        if (code == null || code.trim().isEmpty()) return;
        try (Connection conn = DBUtils.getConnection();
             PreparedStatement ps = conn.prepareStatement(SQL_INCREMENT)) {
            ps.setString(1, code.trim().toUpperCase());
            ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}

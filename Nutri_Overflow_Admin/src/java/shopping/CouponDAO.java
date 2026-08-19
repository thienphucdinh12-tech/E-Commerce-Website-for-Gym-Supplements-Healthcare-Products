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
        "SELECT code, discount_percent, min_order_value, usage_limit, used_count, expiry_date, is_active " +
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

                // Discount percent — if 0 or null, not a percent coupon
                int discountPct = rs.getInt("discount_percent");
                boolean pctNull = rs.wasNull();

                if (pctNull || discountPct <= 0) {
                    // Fixed-amount coupon: not supported as percent in this flow
                    // Treat discount_amount as a flat discount
                    return new CouponDTO(code, "Loại mã giảm giá này không được hỗ trợ khi đặt hàng trực tuyến.");
                }

                return new CouponDTO(code, discountPct);
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

    public java.util.List<Coupon> getAllCoupons() {
        java.util.List<Coupon> list = new java.util.ArrayList<>();
        String sql = "SELECT coupon_id, code, discount_amount, discount_percent, min_order_value, usage_limit, used_count, expiry_date, is_active FROM Coupons ORDER BY coupon_id DESC";
        try (Connection conn = DBUtils.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                int id = rs.getInt("coupon_id");
                String code = rs.getString("code");
                double discountAmount = rs.getDouble("discount_amount");
                int discountPercent = rs.getInt("discount_percent");
                double minOrderValue = rs.getDouble("min_order_value");
                int limit = rs.getInt("usage_limit");
                Integer usageLimit = rs.wasNull() ? null : limit;
                int usedCount = rs.getInt("used_count");
                Timestamp expiryDate = rs.getTimestamp("expiry_date");
                boolean active = rs.getBoolean("is_active");
                
                list.add(new Coupon(id, code, discountAmount, discountPercent, minOrderValue, usageLimit, usedCount, expiryDate, active));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public boolean insertCoupon(Coupon c) {
        String sql = "INSERT INTO Coupons (code, discount_amount, discount_percent, min_order_value, usage_limit, used_count, expiry_date, is_active) VALUES (?, ?, ?, ?, ?, 0, ?, ?)";
        try (Connection conn = DBUtils.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, c.getCode().toUpperCase().trim());
            ps.setDouble(2, c.getDiscountAmount());
            ps.setInt(3, c.getDiscountPercent());
            ps.setDouble(4, c.getMinOrderValue());
            if (c.getUsageLimit() != null) {
                ps.setInt(5, c.getUsageLimit());
            } else {
                ps.setNull(5, Types.INTEGER);
            }
            ps.setTimestamp(6, c.getExpiryDate());
            ps.setBoolean(7, c.isActive());
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean updateCoupon(Coupon c) {
        String sql = "UPDATE Coupons SET code = ?, discount_amount = ?, discount_percent = ?, min_order_value = ?, usage_limit = ?, expiry_date = ?, is_active = ? WHERE coupon_id = ?";
        try (Connection conn = DBUtils.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, c.getCode().toUpperCase().trim());
            ps.setDouble(2, c.getDiscountAmount());
            ps.setInt(3, c.getDiscountPercent());
            ps.setDouble(4, c.getMinOrderValue());
            if (c.getUsageLimit() != null) {
                ps.setInt(5, c.getUsageLimit());
            } else {
                ps.setNull(5, Types.INTEGER);
            }
            ps.setTimestamp(6, c.getExpiryDate());
            ps.setBoolean(7, c.isActive());
            ps.setInt(8, c.getId());
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean toggleActive(int couponId, boolean active) {
        String sql = "UPDATE Coupons SET is_active = ? WHERE coupon_id = ?";
        try (Connection conn = DBUtils.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setBoolean(1, active);
            ps.setInt(2, couponId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean deleteCoupon(int couponId) {
        String sql = "DELETE FROM Coupons WHERE coupon_id = ?";
        try (Connection conn = DBUtils.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, couponId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }
}

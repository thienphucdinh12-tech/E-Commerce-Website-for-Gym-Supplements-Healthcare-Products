package shopping;

import utils.DBUtils;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;

/**
 * Handles creating a new order in the database.
 *
 * Orders table real schema (after migrations):
 *   order_id, user_id, order_date, status, total_amount,
 *   payment_method, shipping_address, note,
 *   coupon_id (FK), discount_applied,
 *   payment_status, paid_at, txn_ref, vnp_transaction_no, vnp_bank_code,
 *   coupon_code (VARCHAR, added by checkout_profile_migration.sql)
 */
public class OrderDAO {

    public int checkOut(String username, Cart cart,
                        String shippingAddress, double discountAmount,
                        String couponCode, String paymentMethod, double shippingFee,
                        int ghnDistrictId, String ghnWardCode, String recipientPhone) throws Exception {
        Connection conn = null;

        String sqlGetUser     = "SELECT user_id FROM Users WHERE username=?";
        String sqlGetCouponId = "SELECT coupon_id FROM Coupons WHERE code=?";

        // Insert order header — uses real column names: discount_applied, coupon_id, coupon_code, shipping_fee, and new GHN shipping columns
        String sqlOrder =
            "INSERT INTO Orders(user_id, order_date, status, payment_status, " +
            "total_amount, payment_method, shipping_address, shipping_fee, discount_applied, coupon_id, coupon_code, " +
            "ghn_district_id, ghn_ward_code, recipient_phone) " +
            "VALUES(?, GETDATE(), 'PENDING', 'UNPAID', ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";

        String sqlDetail      = "INSERT INTO Order_Details(order_id, product_id, quantity, price_at_purchase) VALUES(?,?,?,?)";
        String sqlUpdateStock = "INSERT INTO Stock(product_id, quantity) VALUES(?, ?)";
        String sqlCheckStock  = "SELECT stock_quantity, name FROM ProductsWithStock WHERE product_id = ?";
        String sqlTracking    = "INSERT INTO Order_Tracking(order_id, status, description, updated_at) VALUES(?, 'PENDING', ?, GETDATE())";

        double grossTotal = cart.getTotal();
        double finalTotal = Math.max(0, grossTotal - discountAmount);
        double totalWithShipping = finalTotal + shippingFee;

        // Truncate shippingAddress if longer than 450 characters to prevent DB truncation error
        if (shippingAddress != null && shippingAddress.length() > 450) {
            shippingAddress = shippingAddress.substring(0, 450);
        }

        try {
            conn = DBUtils.getConnection();
            if (conn == null) return -1;

            conn.setAutoCommit(false); // Begin Transaction

            // 1. Get user_id from username
            int userId = -1;
            try (PreparedStatement ps = conn.prepareStatement(sqlGetUser)) {
                ps.setString(1, username);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) userId = rs.getInt("user_id");
                }
            }
            if (userId == -1) throw new Exception("User not found: " + username);

            // 2. Resolve coupon_id (nullable FK) from coupon code
            Integer couponId = null;
            if (couponCode != null && !couponCode.isEmpty()) {
                try (PreparedStatement ps = conn.prepareStatement(sqlGetCouponId)) {
                    ps.setString(1, couponCode.toUpperCase());
                    try (ResultSet rs = ps.executeQuery()) {
                        if (rs.next()) couponId = rs.getInt("coupon_id");
                    }
                }
            }

            // 3. Insert order header
            int orderId = 0;
            try (PreparedStatement ps = conn.prepareStatement(sqlOrder, Statement.RETURN_GENERATED_KEYS)) {
                ps.setInt(1, userId);
                ps.setDouble(2, totalWithShipping);
                ps.setString(3, (paymentMethod != null) ? paymentMethod : "VNPAY");
                ps.setString(4, shippingAddress);
                ps.setDouble(5, shippingFee);
                ps.setDouble(6, discountAmount);
                if (couponId != null) ps.setInt(7, couponId);
                else                  ps.setNull(7, java.sql.Types.INTEGER);
                ps.setString(8, (couponCode != null && !couponCode.isEmpty()) ? couponCode.toUpperCase() : null);
                if (ghnDistrictId > 0) ps.setInt(9, ghnDistrictId);
                else                   ps.setNull(9, java.sql.Types.INTEGER);
                ps.setString(10, ghnWardCode);
                ps.setString(11, recipientPhone);
                ps.executeUpdate();
                try (ResultSet rs = ps.getGeneratedKeys()) {
                    if (rs.next()) orderId = rs.getInt(1);
                }
            }
            if (orderId == 0) throw new Exception("Failed to generate order_id");

            // Insert initial tracking
            try (PreparedStatement psTracking = conn.prepareStatement(sqlTracking)) {
                psTracking.setInt(1, orderId);
                psTracking.setString(2, "Đơn hàng đã được đặt thành công. Đang chờ xác nhận.");
                psTracking.executeUpdate();
            }

            // 4. Validate stock and insert order details
            for (Product p : cart.getCart().values()) {
                int productId = Integer.parseInt(p.getId());

                try (PreparedStatement ps = conn.prepareStatement(sqlCheckStock)) {
                    ps.setInt(1, productId);
                    try (ResultSet rs = ps.executeQuery()) {
                        if (rs.next()) {
                            int stock = rs.getInt("stock_quantity");
                            String productName = rs.getString("name");
                            if (stock < p.getQuantity()) {
                                throw new Exception("Insufficient stock for: " + productName +
                                                    ". Only " + stock + " left.");
                            }
                        } else {
                            throw new Exception("Product ID " + productId + " not found.");
                        }
                    }
                }

                try (PreparedStatement ps = conn.prepareStatement(sqlDetail)) {
                    ps.setInt(1, orderId);
                    ps.setInt(2, productId);
                    ps.setInt(3, p.getQuantity());
                    ps.setDouble(4, p.getPrice());
                    ps.executeUpdate();
                }

                try (PreparedStatement ps = conn.prepareStatement(sqlUpdateStock)) {
                    ps.setInt(1, productId);
                    ps.setInt(2, -p.getQuantity());
                    ps.executeUpdate();
                }
            }

            conn.commit();
            return orderId;

        } catch (Exception e) {
            if (conn != null) {
                try { conn.rollback(); } catch (Exception ex) {}
            }
            e.printStackTrace();
            try {
                java.io.PrintWriter pw = new java.io.PrintWriter(new java.io.FileWriter("checkout_error.log", true));
                pw.println("--- CHECKOUT ERROR at " + new java.util.Date() + " ---");
                pw.println("Username: " + username);
                pw.println("Cart total: " + (cart != null ? cart.getTotal() : "null"));
                e.printStackTrace(pw);
                pw.println();
                pw.close();
            } catch (Exception ex) {
                ex.printStackTrace();
            }
            return -1;
        } finally {
            if (conn != null) {
                conn.setAutoCommit(true);
                conn.close();
            }
        }
    }

    /** Backward-compatible overload */
    public int checkOut(String username, Cart cart) throws Exception {
        return checkOut(username, cart, null, 0, null, "VNPAY", 0, 0, null, null);
    }

    public boolean updateGhnCode(int orderId, String ghnCode) {
        String sql = "UPDATE Orders SET ghn_order_code = ? WHERE order_id = ?";
        try (Connection conn = DBUtils.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, ghnCode);
            ps.setInt(2, orderId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }
}
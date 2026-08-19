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
                        String couponCode, String paymentMethod) throws Exception {
        Connection conn = null;

        String sqlGetUser     = "SELECT user_id FROM Users WHERE username=?";
        String sqlGetCouponId = "SELECT coupon_id FROM Coupons WHERE code=?";

        // Insert order header — uses real column names: discount_applied, coupon_id, coupon_code
        String sqlOrder =
            "INSERT INTO Orders(user_id, order_date, status, payment_status, " +
            "total_amount, payment_method, shipping_address, discount_applied, coupon_id, coupon_code) " +
            "VALUES(?, GETDATE(), 'PENDING', 'UNPAID', ?, ?, ?, ?, ?, ?)";

        String sqlDetail      = "INSERT INTO Order_Details(order_id, product_id, quantity, price_at_purchase) VALUES(?,?,?,?)";
        String sqlUpdateStock = "UPDATE Products SET stock_quantity = stock_quantity - ? WHERE product_id = ?";
        String sqlCheckStock  = "SELECT stock_quantity, name FROM Products WHERE product_id = ?";

        double grossTotal = cart.getTotal();
        double finalTotal = Math.max(0, grossTotal - discountAmount);

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
                ps.setDouble(2, finalTotal);
                ps.setString(3, (paymentMethod != null) ? paymentMethod : "VNPAY");
                ps.setString(4, shippingAddress);
                ps.setDouble(5, discountAmount);
                if (couponId != null) ps.setInt(6, couponId);
                else                  ps.setNull(6, java.sql.Types.INTEGER);
                ps.setString(7, (couponCode != null && !couponCode.isEmpty()) ? couponCode.toUpperCase() : null);
                ps.executeUpdate();
                try (ResultSet rs = ps.getGeneratedKeys()) {
                    if (rs.next()) orderId = rs.getInt(1);
                }
            }
            if (orderId == 0) throw new Exception("Failed to generate order_id");

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
                    ps.setInt(1, p.getQuantity());
                    ps.setInt(2, productId);
                    ps.executeUpdate();
                }
            }

            conn.commit();
            return orderId;

        } catch (Exception e) {
            if (conn != null) conn.rollback();
            e.printStackTrace();
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
        return checkOut(username, cart, null, 0, null, "VNPAY");
    }
}
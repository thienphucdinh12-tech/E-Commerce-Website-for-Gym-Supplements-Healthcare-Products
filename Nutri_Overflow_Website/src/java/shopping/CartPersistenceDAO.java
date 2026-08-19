package shopping;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import utils.DBUtils;

/**
 * CartPersistenceDAO — saves and restores the shopping cart to/from the
 * Cart_Items table so that the cart survives logout / session expiry.
 *
 * Cart_Items schema (existing):
 *   cart_item_id INT PK, user_id INT, product_id INT, quantity INT, added_at DATETIME
 *
 * User lookup: Users.user_id (INT) matched by Users.username (the userID in UserDTO).
 */
public class CartPersistenceDAO {

    // ── Save cart to DB (called on logout) ────────────────────────────────────
    /**
     * Persists the current in-memory cart to Cart_Items.
     * Uses MERGE / upsert so repeated calls are safe.
     */
    public void saveCart(String username, Cart cart) throws Exception {
        if (cart == null || cart.getCart().isEmpty()) {
            // Nothing to save – clear any stale rows
            clearCart(username);
            return;
        }

        Connection conn = null;
        PreparedStatement pstm = null;
        try {
            conn = DBUtils.getConnection();
            if (conn == null) return;

            // 1. Remove existing items for this user first (full replace strategy)
            clearCart(username, conn);

            // 2. Insert current cart items
            String sql = "INSERT INTO Cart_Items (user_id, product_id, quantity) " +
                         "SELECT u.user_id, ?, ? FROM Users u WHERE u.username = ?";
            pstm = conn.prepareStatement(sql);
            for (Product p : cart.getCart().values()) {
                pstm.setInt(1, Integer.parseInt(p.getId()));
                pstm.setInt(2, p.getQuantity());
                pstm.setString(3, username);
                pstm.addBatch();
            }
            pstm.executeBatch();
        } finally {
            if (pstm != null) pstm.close();
            if (conn != null) conn.close();
        }
    }

    // ── Load cart from DB (called on login) ───────────────────────────────────
    /**
     * Restores the cart from Cart_Items, enriching each item with the current
     * live product data (name, price, discountPrice, imageUrl, stock_quantity).
     * Returns null if there are no saved items.
     */
    public Cart loadCart(String username) throws Exception {
        Connection conn = null;
        PreparedStatement pstm = null;
        ResultSet rs = null;
        try {
            conn = DBUtils.getConnection();
            if (conn == null) return null;

            String sql =
                "SELECT ci.product_id, ci.quantity, " +
                "       p.name, p.price, p.discount_price, p.discount_percent, " +
                "       p.is_flash_sale, p.sold_count, p.stock_quantity, p.image_url " +
                "FROM Cart_Items ci " +
                "JOIN ProductsWithStock p ON ci.product_id = p.product_id " +
                "JOIN Users    u ON ci.user_id     = u.user_id " +
                "WHERE u.username = ? AND p.is_active = 1";
            pstm = conn.prepareStatement(sql);
            pstm.setString(1, username);
            rs = pstm.executeQuery();

            Cart cart = new Cart();
            boolean hasItems = false;

            while (rs.next()) {
                int productId  = rs.getInt("product_id");
                int qty        = rs.getInt("quantity");
                String name    = rs.getString("name");
                double price   = rs.getDouble("price");

                // Use discounted price if available (same logic as AddController)
                double discountPriceRaw = rs.getDouble("discount_price");
                if (!rs.wasNull() && discountPriceRaw > 0) {
                    price = discountPriceRaw;
                }

                int stockQty   = rs.getInt("stock_quantity");
                String imageUrl = rs.getString("image_url");

                // Cap quantity to current stock
                int safeQty = Math.min(qty, stockQty);
                if (safeQty <= 0) continue;

                Product p = new Product();
                p.setId(String.valueOf(productId));
                p.setName(name);
                p.setPrice(price);
                p.setQuantity(safeQty);
                p.setImageUrl(imageUrl);

                cart.add(p);
                hasItems = true;
            }

            // After loading, remove the persisted rows (they now live in session)
            if (hasItems) {
                clearCart(username, conn);
            }
            return hasItems ? cart : null;
        } finally {
            if (rs   != null) rs.close();
            if (pstm != null) pstm.close();
            if (conn != null) conn.close();
        }
    }

    // ── Helpers ───────────────────────────────────────────────────────────────
    public void clearCart(String username) throws Exception {
        Connection conn = null;
        try {
            conn = DBUtils.getConnection();
            if (conn == null) return;
            clearCart(username, conn);
        } finally {
            if (conn != null) conn.close();
        }
    }

    private void clearCart(String username, Connection conn) throws Exception {
        String sql = "DELETE ci FROM Cart_Items ci " +
                     "JOIN Users u ON ci.user_id = u.user_id " +
                     "WHERE u.username = ?";
        try (PreparedStatement pstm = conn.prepareStatement(sql)) {
            pstm.setString(1, username);
            pstm.executeUpdate();
        }
    }
}

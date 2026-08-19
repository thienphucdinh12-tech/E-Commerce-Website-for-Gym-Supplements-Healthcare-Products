package shopping;

import utils.DBUtils;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

public class ProductDAO {

    // Helper: map ResultSet row -> Product (full fields)
    private Product mapProduct(ResultSet rs) throws Exception {
        double discPrice = rs.getDouble("discount_price");
        Double discountPrice = rs.wasNull() ? null : discPrice;
        return new Product(
            String.valueOf(rs.getInt("product_id")),
            rs.getString("name"),
            rs.getString("description"),
            rs.getDouble("price"),
            discountPrice,
            rs.getInt("discount_percent"),
            rs.getBoolean("is_flash_sale"),
            rs.getInt("sold_count"),
            rs.getInt("stock_quantity"),
            rs.getString("image_url")
        );
    }

    private static final String BASE_COLS =
        "product_id, name, description, price, discount_price, discount_percent, " +
        "is_flash_sale, sold_count, stock_quantity, image_url";

    public List<Product> getAllProduct() {
        List<Product> list = new ArrayList<>();
        String sql = "SELECT " + BASE_COLS + " FROM ProductsWithStock WHERE stock_quantity > 0 AND is_active = 1";
        try (Connection conn = DBUtils.getConnection();
             PreparedStatement ptm = conn.prepareStatement(sql);
             ResultSet rs = ptm.executeQuery()) {
            while (rs.next()) { list.add(mapProduct(rs)); }
        } catch (Exception e) { e.printStackTrace(); }
        return list;
    }

    public List<Product> getProductByStartName(String search) {
        List<Product> list = new ArrayList<>();
        String sql = "SELECT " + BASE_COLS + " FROM ProductsWithStock WHERE stock_quantity > 0 AND is_active = 1 AND name LIKE ?";
        try (Connection conn = DBUtils.getConnection();
             PreparedStatement ptm = conn.prepareStatement(sql)) {
            ptm.setString(1, "%" + search + "%");
            try (ResultSet rs = ptm.executeQuery()) {
                while (rs.next()) { list.add(mapProduct(rs)); }
            }
        } catch (Exception e) { e.printStackTrace(); }
        return list;
    }

    public List<Product> getProductByCategory(String categoryId) {
        return getProductByFilter(categoryId, null);
    }

    public List<Product> getProductByFilter(String categoryId, String search) {
        List<Product> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder("SELECT " + BASE_COLS + " FROM ProductsWithStock WHERE stock_quantity > 0 AND is_active = 1");
        List<Object> params = new ArrayList<>();

        if (categoryId != null && !categoryId.trim().isEmpty()) {
            try {
                int catId = Integer.parseInt(categoryId.trim());
                sql.append(" AND category_id = ?");
                params.add(catId);
            } catch (Exception ignored) {}
        }
        if (search != null && !search.trim().isEmpty()) {
            sql.append(" AND name LIKE ?");
            params.add("%" + search.trim() + "%");
        }

        try (Connection conn = DBUtils.getConnection();
             PreparedStatement ptm = conn.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                ptm.setObject(i + 1, params.get(i));
            }
            try (ResultSet rs = ptm.executeQuery()) {
                while (rs.next()) { list.add(mapProduct(rs)); }
            }
        } catch (Exception e) { e.printStackTrace(); }
        return list;
    }

    public Product getProductById(String id) {
        String sql = "SELECT " + BASE_COLS + " FROM ProductsWithStock WHERE product_id = ?";
        try (Connection conn = DBUtils.getConnection();
             PreparedStatement ptm = conn.prepareStatement(sql)) {
            ptm.setString(1, id);
            try (ResultSet rs = ptm.executeQuery()) {
                if (rs.next()) { return mapProduct(rs); }
            }
        } catch (Exception e) { e.printStackTrace(); }
        return null;
    }

    public List<Product> getBestSellers() {
        List<Product> list = new ArrayList<>();
        String sql = "SELECT TOP 8 " + BASE_COLS + ", is_bestseller " +
                     "FROM ProductsWithStock " +
                     "WHERE stock_quantity > 0 AND is_active = 1 " +
                     "ORDER BY is_bestseller DESC, sold_count DESC";
        try (Connection conn = DBUtils.getConnection();
             PreparedStatement ptm = conn.prepareStatement(sql);
             ResultSet rs = ptm.executeQuery()) {
            while (rs.next()) { list.add(mapProduct(rs)); }
        } catch (Exception e) { e.printStackTrace(); }
        return list;
    }

    /** Lấy các sản phẩm Sale Sốc (is_flash_sale = 1), tối đa 10 sản phẩm */
    public List<Product> getFlashSaleProducts() {
        List<Product> list = new ArrayList<>();
        String sql = "SELECT TOP 10 " + BASE_COLS + " " +
                     "FROM ProductsWithStock " +
                     "WHERE is_flash_sale = 1 AND stock_quantity > 0 AND is_active = 1 " +
                     "ORDER BY discount_percent DESC";
        try (Connection conn = DBUtils.getConnection();
             PreparedStatement ptm = conn.prepareStatement(sql);
             ResultSet rs = ptm.executeQuery()) {
            while (rs.next()) { list.add(mapProduct(rs)); }
        } catch (Exception e) { e.printStackTrace(); }
        return list;
    }
}
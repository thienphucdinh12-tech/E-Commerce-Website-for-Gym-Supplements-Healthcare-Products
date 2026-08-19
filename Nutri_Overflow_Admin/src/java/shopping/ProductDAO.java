package shopping;

import utils.DBUtils;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class ProductDAO {

    // Helper: map ResultSet row -> Product (full fields)
    private Product mapProduct(ResultSet rs) throws Exception {
        double discPrice = rs.getDouble("discount_price");
        Double discountPrice = rs.wasNull() ? null : discPrice;
        return new Product(
            String.valueOf(rs.getInt("product_id")),
            rs.getString("sku"),
            rs.getInt("category_id"),
            rs.getString("name"),
            rs.getString("description"),
            rs.getDouble("price"),
            discountPrice,
            rs.getInt("discount_percent"),
            rs.getBoolean("is_flash_sale"),
            rs.getInt("sold_count"),
            rs.getInt("stock_quantity"),
            rs.getString("image_url"),
            rs.getBoolean("is_active"),
            rs.getString("medical_warning"),
            rs.getBoolean("is_bestseller")
        );
    }

    private static final String BASE_COLS =
        "product_id, sku, category_id, name, description, price, discount_price, discount_percent, " +
        "is_flash_sale, sold_count, stock_quantity, image_url, is_active, medical_warning, is_bestseller";

    public List<Product> getAllProduct() {
        List<Product> list = new ArrayList<>();
        String sql = "SELECT " + BASE_COLS + " FROM Products WHERE stock_quantity > 0 AND is_active = 1";
        try (Connection conn = DBUtils.getConnection();
             PreparedStatement ptm = conn.prepareStatement(sql);
             ResultSet rs = ptm.executeQuery()) {
            while (rs.next()) { list.add(mapProduct(rs)); }
        } catch (Exception e) { e.printStackTrace(); }
        return list;
    }

    public List<Product> getProductByStartName(String search) {
        List<Product> list = new ArrayList<>();
        String sql = "SELECT " + BASE_COLS + " FROM Products WHERE stock_quantity > 0 AND is_active = 1 AND name LIKE ?";
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
        List<Product> list = new ArrayList<>();
        String sql = "SELECT " + BASE_COLS + " FROM Products WHERE stock_quantity > 0 AND is_active = 1 AND category_id = ?";
        try (Connection conn = DBUtils.getConnection();
             PreparedStatement ptm = conn.prepareStatement(sql)) {
            ptm.setInt(1, Integer.parseInt(categoryId));
            try (ResultSet rs = ptm.executeQuery()) {
                while (rs.next()) { list.add(mapProduct(rs)); }
            }
        } catch (Exception e) { e.printStackTrace(); }
        return list;
    }

    public Product getProductById(String id) {
        String sql = "SELECT " + BASE_COLS + " FROM Products WHERE product_id = ?";
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
        String sql = "SELECT TOP 8 " + BASE_COLS + " " +
                     "FROM Products " +
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
                     "FROM Products " +
                     "WHERE is_flash_sale = 1 AND stock_quantity > 0 AND is_active = 1 " +
                     "ORDER BY discount_percent DESC";
        try (Connection conn = DBUtils.getConnection();
             PreparedStatement ptm = conn.prepareStatement(sql);
             ResultSet rs = ptm.executeQuery()) {
            while (rs.next()) { list.add(mapProduct(rs)); }
        } catch (Exception e) { e.printStackTrace(); }
        return list;
    }

    public List<CategoryDTO> getAllCategories() {
        List<CategoryDTO> list = new ArrayList<>();
        String sql = "SELECT category_id, name, description FROM Categories WHERE is_active = 1";
        try (Connection conn = DBUtils.getConnection();
             PreparedStatement ptm = conn.prepareStatement(sql);
             ResultSet rs = ptm.executeQuery()) {
            while (rs.next()) {
                list.add(new CategoryDTO(
                    rs.getInt("category_id"),
                    rs.getString("name"),
                    rs.getString("description")
                ));
            }
        } catch (Exception e) { e.printStackTrace(); }
        return list;
    }

    public List<Product> getAllProductsAdmin(String search, String categoryId, String stockFilter) {
        List<Product> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder("SELECT " + BASE_COLS + " FROM Products WHERE 1=1");
        
        if (search != null && !search.trim().isEmpty()) {
            sql.append(" AND (name LIKE ? OR sku LIKE ?)");
        }
        if (categoryId != null && !categoryId.trim().isEmpty() && !"all".equalsIgnoreCase(categoryId)) {
            sql.append(" AND category_id = ?");
        }
        if (stockFilter != null && !stockFilter.trim().isEmpty()) {
            if ("out_of_stock".equalsIgnoreCase(stockFilter)) {
                sql.append(" AND stock_quantity = 0");
            } else if ("low_stock".equalsIgnoreCase(stockFilter)) {
                sql.append(" AND stock_quantity < 10");
            } else if ("in_stock".equalsIgnoreCase(stockFilter)) {
                sql.append(" AND stock_quantity > 0");
            }
        }
        sql.append(" ORDER BY stock_quantity ASC, product_id DESC");

        try (Connection conn = DBUtils.getConnection();
             PreparedStatement ptm = conn.prepareStatement(sql.toString())) {
            int paramIndex = 1;
            if (search != null && !search.trim().isEmpty()) {
                ptm.setString(paramIndex++, "%" + search.trim() + "%");
                ptm.setString(paramIndex++, "%" + search.trim() + "%");
            }
            if (categoryId != null && !categoryId.trim().isEmpty() && !"all".equalsIgnoreCase(categoryId)) {
                ptm.setInt(paramIndex++, Integer.parseInt(categoryId));
            }
            try (ResultSet rs = ptm.executeQuery()) {
                while (rs.next()) { list.add(mapProduct(rs)); }
            }
        } catch (Exception e) { e.printStackTrace(); }
        return list;
    }

    public boolean updateProductStock(int productId, int quantity) {
        String sql = "UPDATE Products SET stock_quantity = ? WHERE product_id = ?";
        try (Connection conn = DBUtils.getConnection();
             PreparedStatement ptm = conn.prepareStatement(sql)) {
            ptm.setInt(1, quantity);
            ptm.setInt(2, productId);
            return ptm.executeUpdate() > 0;
        } catch (Exception e) { e.printStackTrace(); }
        return false;
    }

    public boolean insertProduct(Product p) {
        String sqlProduct = "INSERT INTO Products (category_id, sku, name, description, price, discount_price, discount_percent, is_flash_sale, stock_quantity, image_url, is_active, medical_warning, is_bestseller) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
        String sqlStock = "INSERT INTO Stock (product_id, staff_id, quantity) VALUES (?, NULL, ?)";
        
        Connection conn = null;
        PreparedStatement ptmProduct = null;
        PreparedStatement ptmStock = null;
        ResultSet rs = null;
        try {
            conn = DBUtils.getConnection();
            conn.setAutoCommit(false);
            
            ptmProduct = conn.prepareStatement(sqlProduct, PreparedStatement.RETURN_GENERATED_KEYS);
            if (p.getCategoryId() > 0) {
                ptmProduct.setInt(1, p.getCategoryId());
            } else {
                ptmProduct.setNull(1, java.sql.Types.INTEGER);
            }
            ptmProduct.setString(2, p.getSku());
            ptmProduct.setString(3, p.getName());
            ptmProduct.setString(4, p.getDescription());
            ptmProduct.setDouble(5, p.getPrice());
            if (p.getDiscountPrice() != null) {
                ptmProduct.setDouble(6, p.getDiscountPrice());
            } else {
                ptmProduct.setNull(6, java.sql.Types.DECIMAL);
            }
            ptmProduct.setInt(7, p.getDiscountPercent());
            ptmProduct.setBoolean(8, p.isFlashSale());
            ptmProduct.setInt(9, p.getQuantity());
            ptmProduct.setString(10, p.getImageUrl());
            ptmProduct.setBoolean(11, p.isActive());
            ptmProduct.setString(12, p.getMedicalWarning());
            ptmProduct.setBoolean(13, p.isBestSeller());
            
            int affectedRows = ptmProduct.executeUpdate();
            if (affectedRows > 0) {
                rs = ptmProduct.getGeneratedKeys();
                if (rs.next()) {
                    int newProductId = rs.getInt(1);
                    ptmStock = conn.prepareStatement(sqlStock);
                    ptmStock.setInt(1, newProductId);
                    ptmStock.setInt(2, p.getQuantity());
                    ptmStock.executeUpdate();
                }
                conn.commit();
                return true;
            }
        } catch (Exception e) {
            if (conn != null) {
                try { conn.rollback(); } catch (SQLException ex) { ex.printStackTrace(); }
            }
            e.printStackTrace();
        } finally {
            try {
                if (rs != null) rs.close();
                if (ptmProduct != null) ptmProduct.close();
                if (ptmStock != null) ptmStock.close();
                if (conn != null) conn.close();
            } catch (SQLException e) { e.printStackTrace(); }
        }
        return false;
    }

    public boolean updateProduct(Product p) {
        String sql = "UPDATE Products SET category_id = ?, sku = ?, name = ?, description = ?, price = ?, discount_price = ?, discount_percent = ?, is_flash_sale = ?, stock_quantity = ?, image_url = ?, is_active = ?, medical_warning = ?, is_bestseller = ? WHERE product_id = ?";
        try (Connection conn = DBUtils.getConnection();
             PreparedStatement ptm = conn.prepareStatement(sql)) {
            if (p.getCategoryId() > 0) {
                ptm.setInt(1, p.getCategoryId());
            } else {
                ptm.setNull(1, java.sql.Types.INTEGER);
            }
            ptm.setString(2, p.getSku());
            ptm.setString(3, p.getName());
            ptm.setString(4, p.getDescription());
            ptm.setDouble(5, p.getPrice());
            if (p.getDiscountPrice() != null) {
                ptm.setDouble(6, p.getDiscountPrice());
            } else {
                ptm.setNull(6, java.sql.Types.DECIMAL);
            }
            ptm.setInt(7, p.getDiscountPercent());
            ptm.setBoolean(8, p.isFlashSale());
            ptm.setInt(9, p.getQuantity());
            ptm.setString(10, p.getImageUrl());
            ptm.setBoolean(11, p.isActive());
            ptm.setString(12, p.getMedicalWarning());
            ptm.setBoolean(13, p.isBestSeller());
            ptm.setInt(14, Integer.parseInt(p.getId()));
            return ptm.executeUpdate() > 0;
        } catch (Exception e) { e.printStackTrace(); }
        return false;
    }

    public boolean toggleActiveStatus(int productId, boolean active) {
        String sql = "UPDATE Products SET is_active = ? WHERE product_id = ?";
        try (Connection conn = DBUtils.getConnection();
             PreparedStatement ptm = conn.prepareStatement(sql)) {
            ptm.setBoolean(1, active);
            ptm.setInt(2, productId);
            return ptm.executeUpdate() > 0;
        } catch (Exception e) { e.printStackTrace(); }
        return false;
    }

    public boolean deleteProduct(int productId) {
        String sqlDeleteReturns = "DELETE FROM Return_Logistics WHERE product_id = ?";
        String sqlDeleteOrderDetails = "DELETE FROM Order_Details WHERE product_id = ?";
        String sqlDeleteStock = "DELETE FROM Stock WHERE product_id = ?";
        String sqlDeleteImages = "DELETE FROM Product_Images WHERE product_id = ?";
        String sqlDeleteCart = "DELETE FROM Cart_Items WHERE product_id = ?";
        String sqlDeleteFavs = "DELETE FROM Favorites WHERE product_id = ?";
        String sqlDeleteReviews = "DELETE FROM Product_Reviews WHERE product_id = ?";
        String sqlDeleteProduct = "DELETE FROM Products WHERE product_id = ?";

        Connection conn = null;
        try {
            conn = DBUtils.getConnection();
            conn.setAutoCommit(false);

            try (PreparedStatement ptm = conn.prepareStatement(sqlDeleteReturns)) {
                ptm.setInt(1, productId);
                ptm.executeUpdate();
            } catch (Exception ignored) {}

            try (PreparedStatement ptm = conn.prepareStatement(sqlDeleteOrderDetails)) {
                ptm.setInt(1, productId);
                ptm.executeUpdate();
            } catch (Exception ignored) {}

            try (PreparedStatement ptm = conn.prepareStatement(sqlDeleteStock)) {
                ptm.setInt(1, productId);
                ptm.executeUpdate();
            } catch (Exception ignored) {}

            try (PreparedStatement ptm = conn.prepareStatement(sqlDeleteImages)) {
                ptm.setInt(1, productId);
                ptm.executeUpdate();
            } catch (Exception ignored) {}

            try (PreparedStatement ptm = conn.prepareStatement(sqlDeleteCart)) {
                ptm.setInt(1, productId);
                ptm.executeUpdate();
            } catch (Exception ignored) {}

            try (PreparedStatement ptm = conn.prepareStatement(sqlDeleteFavs)) {
                ptm.setInt(1, productId);
                ptm.executeUpdate();
            } catch (Exception ignored) {}

            try (PreparedStatement ptm = conn.prepareStatement(sqlDeleteReviews)) {
                ptm.setInt(1, productId);
                ptm.executeUpdate();
            } catch (Exception ignored) {}

            int deleted;
            try (PreparedStatement ptm = conn.prepareStatement(sqlDeleteProduct)) {
                ptm.setInt(1, productId);
                deleted = ptm.executeUpdate();
            }

            conn.commit();
            return deleted > 0;
        } catch (Exception e) {
            if (conn != null) {
                try { conn.rollback(); } catch (Exception ignored) {}
            }
            e.printStackTrace();
        } finally {
            if (conn != null) {
                try { conn.close(); } catch (Exception ignored) {}
            }
        }
        return false;
    }
}
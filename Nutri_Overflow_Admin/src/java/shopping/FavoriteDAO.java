package shopping;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import utils.DBUtils;

public class FavoriteDAO {
    
    // 1. Thêm sản phẩm yêu thích (Dùng username để lấy user_id)
    public boolean addFavorite(String username, int productId) throws Exception {
        Connection conn = null;
        PreparedStatement ptm = null;
        boolean check = false;
        try {
            conn = DBUtils.getConnection();
            if (conn != null) {
                // Dùng SELECT để tự động tìm user_id tương ứng với username
                String sql = "INSERT INTO Favorites (user_id, product_id) "
                           + "SELECT user_id, ? FROM Users WHERE username = ?";
                ptm = conn.prepareStatement(sql);
                ptm.setInt(1, productId);
                ptm.setString(2, username); 
                
                check = ptm.executeUpdate() > 0;
            }
        } catch (SQLException e) {
            // Lỗi 2627: Vi phạm UNIQUE(user_id, product_id) -> Đã có trong Wishlist
            if (e.getErrorCode() == 2627) {
                return false;
            }
            throw e;
        } finally {
            if (ptm != null) ptm.close();
            if (conn != null) conn.close();
        }
        return check;
    }
    
    // 2. Lấy danh sách yêu thích (JOIN thêm bảng Users)
    public List<Product> getFavoriteProducts(String username) throws Exception {
        List<Product> list = new ArrayList<>();
        Connection conn = null;
        PreparedStatement ptm = null;
        ResultSet rs = null;
        try {
            conn = DBUtils.getConnection();
            if (conn != null) {
                // JOIN Favorites, Products và Users để lọc theo username
                String sql = "SELECT p.product_id, p.name, p.description, p.price, p.image_url, p.stock_quantity " +
                             "FROM Favorites f " +
                             "JOIN Products p ON f.product_id = p.product_id " +
                             "JOIN Users u ON f.user_id = u.user_id " +
                             "WHERE u.username = ?";
                ptm = conn.prepareStatement(sql);
                ptm.setString(1, username);
                rs = ptm.executeQuery();
                while (rs.next()) {
                    String id = String.valueOf(rs.getInt("product_id"));
                    String name = rs.getString("name");
                    String description = rs.getString("description");
                    double price = rs.getDouble("price");
                    String imageUrl = rs.getString("image_url");
                    int quantity = rs.getInt("stock_quantity");
                    
                    Product p = new Product(id, name, description, price, quantity, imageUrl);
                    list.add(p);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            if (rs != null) rs.close();
            if (ptm != null) ptm.close();
            if (conn != null) conn.close();
        }
        return list;
    }
    
    public boolean removeFavorite(String username, int productId) throws Exception {
        Connection conn = null;
        PreparedStatement ptm = null;
        boolean check = false;
        try {
            conn = DBUtils.getConnection();
            if (conn != null) {
                String sql = "DELETE FROM Favorites "
                           + "WHERE user_id = (SELECT user_id FROM Users WHERE username = ?) "
                           + "AND product_id = ?";
                ptm = conn.prepareStatement(sql);
                ptm.setString(1, username);
                ptm.setInt(2, productId);
                
                check = ptm.executeUpdate() > 0;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            if (ptm != null) ptm.close();
            if (conn != null) conn.close();
        }
        return check;
    }
}
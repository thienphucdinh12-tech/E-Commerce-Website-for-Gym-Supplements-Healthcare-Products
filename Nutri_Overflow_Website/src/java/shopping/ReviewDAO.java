package shopping;

import utils.DBUtils;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class ReviewDAO {
    private static final String GET_REVIEWS =
            "SELECT r.review_id, r.product_id, r.user_id, c.full_name, r.rating, r.comment_text, r.created_at " +
            "FROM Reviews r " +
            "JOIN Customer c ON r.user_id = c.user_id " +
            "WHERE r.product_id = ? AND r.is_approved = 1 " +
            "ORDER BY r.created_at DESC";

    private static final String ADD_REVIEW =
            "INSERT INTO Reviews (product_id, user_id, rating, comment_text, is_approved, created_at) " +
            "VALUES (?, (SELECT user_id FROM Users WHERE username = ?), ?, ?, 1, GETDATE())";

    public List<ReviewDTO> getReviewsByProductId(int productId) throws SQLException {
        List<ReviewDTO> list = new ArrayList<>();
        try (Connection conn = DBUtils.getConnection();
             PreparedStatement ptm = conn.prepareStatement(GET_REVIEWS)) {
            ptm.setInt(1, productId);
            try (ResultSet rs = ptm.executeQuery()) {
                while (rs.next()) {
                    int reviewId = rs.getInt("review_id");
                    int userId = rs.getInt("user_id");
                    String fullName = rs.getString("full_name");
                    int rating = rs.getInt("rating");
                    String commentText = rs.getString("comment_text");
                    Timestamp createdAt = rs.getTimestamp("created_at");
                    list.add(new ReviewDTO(reviewId, productId, userId, fullName, rating, commentText, createdAt));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public boolean addReview(int productId, String username, int rating, String commentText) throws SQLException {
        try (Connection conn = DBUtils.getConnection();
             PreparedStatement ptm = conn.prepareStatement(ADD_REVIEW)) {
            ptm.setInt(1, productId);
            ptm.setString(2, username);
            ptm.setInt(3, rating);
            ptm.setString(4, commentText);
            return ptm.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }
}

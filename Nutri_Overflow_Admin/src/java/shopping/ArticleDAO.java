package shopping;

import utils.DBUtils;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class ArticleDAO {

    /**
     * Fetch all articles with search and status/publishing filters.
     * Orders PENDING articles first, then by created_at DESC.
     */
    public List<Article> getAllArticles(String search, String statusFilter, String publishFilter) {
        List<Article> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder(
            "SELECT article_id, title, summary, content, image_url, author_username, author_name, " +
            "status, is_published, created_at, updated_at " +
            "FROM Articles WHERE 1=1 "
        );

        List<Object> params = new ArrayList<>();

        if (search != null && !search.trim().isEmpty()) {
            sql.append("AND title LIKE ? ");
            params.add("%" + search.trim() + "%");
        }

        if (statusFilter != null && !statusFilter.trim().isEmpty() && !"all".equalsIgnoreCase(statusFilter)) {
            sql.append("AND status = ? ");
            params.add(statusFilter.trim().toUpperCase());
        }

        if (publishFilter != null && !publishFilter.trim().isEmpty() && !"all".equalsIgnoreCase(publishFilter)) {
            if ("published".equalsIgnoreCase(publishFilter)) {
                sql.append("AND is_published = 1 ");
            } else if ("unpublished".equalsIgnoreCase(publishFilter)) {
                sql.append("AND is_published = 0 ");
            }
        }

        sql.append("ORDER BY CASE WHEN status = 'PENDING' THEN 0 ELSE 1 END ASC, created_at DESC");

        try (Connection conn = DBUtils.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {

            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Article a = new Article(
                        rs.getInt("article_id"),
                        rs.getString("title"),
                        rs.getString("summary"),
                        rs.getString("content"),
                        rs.getString("image_url"),
                        rs.getString("author_username"),
                        rs.getString("author_name"),
                        rs.getString("status"),
                        rs.getBoolean("is_published"),
                        rs.getTimestamp("created_at"),
                        rs.getTimestamp("updated_at")
                    );
                    list.add(a);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    /**
     * Get article detail by its ID.
     */
    public Article getArticleById(int id) {
        String sql = "SELECT article_id, title, summary, content, image_url, author_username, author_name, " +
                     "status, is_published, created_at, updated_at FROM Articles WHERE article_id = ?";
        try (Connection conn = DBUtils.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return new Article(
                        rs.getInt("article_id"),
                        rs.getString("title"),
                        rs.getString("summary"),
                        rs.getString("content"),
                        rs.getString("image_url"),
                        rs.getString("author_username"),
                        rs.getString("author_name"),
                        rs.getString("status"),
                        rs.getBoolean("is_published"),
                        rs.getTimestamp("created_at"),
                        rs.getTimestamp("updated_at")
                    );
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    /**
     * Insert a new article. Mặc định là PENDING và chưa xuất bản.
     */
    public boolean insertArticle(Article a) {
        String sql = "INSERT INTO Articles (title, summary, content, image_url, author_username, author_name, " +
                     "status, is_published, created_at, updated_at) VALUES (?, ?, ?, ?, ?, ?, ?, ?, GETDATE(), GETDATE())";
        try (Connection conn = DBUtils.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, a.getTitle());
            ps.setString(2, a.getSummary());
            ps.setString(3, a.getContent());
            ps.setString(4, a.getImageUrl());
            ps.setString(5, a.getAuthorUsername());
            ps.setString(6, a.getAuthorName());
            ps.setString(7, a.getStatus() != null ? a.getStatus() : "PENDING");
            ps.setBoolean(8, a.isPublished());

            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    /**
     * Update an article's basic information.
     */
    public boolean updateArticle(Article a) {
        String sql = "UPDATE Articles SET title = ?, summary = ?, content = ?, image_url = ?, " +
                     "author_name = ?, updated_at = GETDATE() WHERE article_id = ?";
        try (Connection conn = DBUtils.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, a.getTitle());
            ps.setString(2, a.getSummary());
            ps.setString(3, a.getContent());
            ps.setString(4, a.getImageUrl());
            ps.setString(5, a.getAuthorName());
            ps.setInt(6, a.getId());

            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    /**
     * Update article moderation status (APPROVED, REJECTED, PENDING).
     * Nếu bị REJECTED thì buộc phải gỡ xuất bản (is_published = 0).
     */
    public boolean updateStatus(int id, String status) {
        String sql;
        if ("REJECTED".equalsIgnoreCase(status)) {
            sql = "UPDATE Articles SET status = ?, is_published = 0, updated_at = GETDATE() WHERE article_id = ?";
        } else {
            sql = "UPDATE Articles SET status = ?, updated_at = GETDATE() WHERE article_id = ?";
        }

        try (Connection conn = DBUtils.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, status.toUpperCase());
            ps.setInt(2, id);

            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    /**
     * Toggle publication status of an article.
     */
    public boolean togglePublish(int id, boolean isPublished) {
        String sql = "UPDATE Articles SET is_published = ?, updated_at = GETDATE() WHERE article_id = ?";
        try (Connection conn = DBUtils.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setBoolean(1, isPublished);
            ps.setInt(2, id);

            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    /**
     * Delete an article.
     */
    public boolean deleteArticle(int id) {
        String sql = "DELETE FROM Articles WHERE article_id = ?";
        try (Connection conn = DBUtils.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);

            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }
}

package blog;

import utils.DBUtils;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class BlogDAO {
    private static final String GET_ALL_BLOGS = 
            "SELECT article_id AS blog_id, title, summary, content, image_url, COALESCE(author_name, author_username, N'NutriOverflow Team') AS author, created_at FROM Articles ORDER BY created_at DESC";
    
    private static final String GET_BLOG_BY_ID = 
            "SELECT article_id AS blog_id, title, summary, content, image_url, COALESCE(author_name, author_username, N'NutriOverflow Team') AS author, created_at FROM Articles WHERE article_id = ?";

    public List<BlogDTO> getAllBlogs() {
        List<BlogDTO> list = new ArrayList<>();
        try (Connection conn = DBUtils.getConnection()) {
            // Update legacy image_url strings in DB if present
            try (Statement st = conn.createStatement()) {
                st.executeUpdate(
                    "UPDATE Articles SET image_url = CASE " +
                    "WHEN title LIKE N'%Whey Protein%' THEN 'https://images.unsplash.com/photo-1579722821273-0f6c7d44362f?w=800&auto=format&fit=crop&q=80' " +
                    "WHEN title LIKE N'%Thực Phẩm%' THEN 'https://images.unsplash.com/photo-1490645935967-10de6ba17061?w=800&auto=format&fit=crop&q=80' " +
                    "WHEN title LIKE N'%Creatine%' THEN 'https://images.unsplash.com/photo-1517838277536-f5f99be501cd?w=800&auto=format&fit=crop&q=80' " +
                    "ELSE image_url END WHERE image_url NOT LIKE 'http%' OR image_url IS NULL"
                );
            } catch (Exception ignored) {}

            try (PreparedStatement ptm = conn.prepareStatement(GET_ALL_BLOGS);
                 ResultSet rs = ptm.executeQuery()) {
                while (rs.next()) {
                    int blogId = rs.getInt("blog_id");
                    String title = rs.getString("title");
                    String summary = rs.getString("summary");
                    String content = rs.getString("content");
                    String imageUrl = rs.getString("image_url");
                    String author = rs.getString("author");
                    Timestamp createdAt = rs.getTimestamp("created_at");
                    list.add(new BlogDTO(blogId, title, summary, content, imageUrl, author, createdAt));
                }
            }
            
            // Auto-seed if database Articles table is empty
            if (list.isEmpty()) {
                seedDefaultArticles(conn);
                try (PreparedStatement ptm2 = conn.prepareStatement(GET_ALL_BLOGS);
                     ResultSet rs2 = ptm2.executeQuery()) {
                    while (rs2.next()) {
                        int blogId = rs2.getInt("blog_id");
                        String title = rs2.getString("title");
                        String summary = rs2.getString("summary");
                        String content = rs2.getString("content");
                        String imageUrl = rs2.getString("image_url");
                        String author = rs2.getString("author");
                        Timestamp createdAt = rs2.getTimestamp("created_at");
                        list.add(new BlogDTO(blogId, title, summary, content, imageUrl, author, createdAt));
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    private void seedDefaultArticles(Connection conn) {
        String insertSql = "INSERT INTO Articles (title, summary, content, image_url, author_username, author_name, status, is_published, created_at, updated_at) VALUES (?, ?, ?, ?, ?, ?, ?, ?, GETDATE(), GETDATE())";
        try (PreparedStatement ptm = conn.prepareStatement(insertSql)) {
            // Article 1
            ptm.setString(1, "Bí Quyết Chọn Whey Protein Chuẩn Dành Cho Người Mới Bắt Đầu Tập Gym");
            ptm.setString(2, "Hướng dẫn chi tiết từ A-Z cách chọn dòng Whey Protein (Isolate, Concentrate, Hydrolyzed) phù hợp với cơ địa, mục tiêu tăng cơ và ngân sách của bạn.");
            ptm.setString(3, "<p>Đối với người mới bắt đầu bước chân vào hành trình tập luyện thể hình, việc lựa chọn dòng Whey Protein phù hợp đóng vai trò vô cùng quan trọng giúp tối ưu hóa khả năng phục hồi và phát triển cơ bắp.</p><h4>1. Phân biệt các loại Whey Protein phổ biến</h4><ul><li><b>Whey Protein Concentrate (WPC):</b> Hàm lượng protein từ 70-80%, chứa một lượng nhỏ đường lactose và chất béo. Giá thành hợp lý, phù hợp người không bị dị ứng lactose.</li><li><b>Whey Protein Isolate (WPI):</b> Hàm lượng protein từ 90% trở lên, được lọc tinh khiết loại bỏ hầu hết lactose và fat. Hấp thụ siêu nhanh, phù hợp cho người siết cơ hoặc bất dung nạp lactose.</li><li><b>Whey Protein Hydrolyzed (WPH):</b> Whey thủy phân giúp phân tách protein thành các chuỗi peptide ngắn, hấp thụ vào cơ bắp tức thì.</li></ul><h4>2. Lời khuyên cho người mới</h4><p>Nếu bạn mới tập và ngân sách vừa phải, hãy chọn Whey Isolate hoặc Whey Blend từ các thương hiệu uy tín như ON Gold Standard, Mutant Iso Surge để tối ưu chi phí và hiệu quả.</p>");
            ptm.setString(4, "https://images.unsplash.com/photo-1579722821273-0f6c7d44362f?w=800&auto=format&fit=crop&q=80");
            ptm.setString(5, "admin");
            ptm.setString(6, "NutriOverflow Team");
            ptm.setString(7, "APPROVED");
            ptm.setInt(8, 1);
            ptm.executeUpdate();

            // Article 2
            ptm.setString(1, "Top 5 Thực Phẩm Tự Nhiên Giúp Tăng Cơ Giảm Mỡ Hiệu Quả Nhất");
            ptm.setString(2, "Khám phá 5 loại thực phẩm tự nhiên giàu đạm và dinh dưỡng thiết yếu giúp bạn xây dựng cơ bắp săn chắc và đốt cháy mỡ thừa mỗi ngày.");
            ptm.setString(3, "<p>Chế độ dinh dưỡng chiếm tới 70% thành công trong thể hình. Dưới đây là 5 loại thực phẩm \"vàng\" bạn nên thêm vào thực đơn hàng ngày:</p><ol><li><b>Ức gà:</b> Cung cấp lượng protein tinh khiết cao, rất ít mỡ và calo, là lựa chọn số 1 cho người tăng cơ cắt nét.</li><li><b>Trứng gà:</b> Chứa đầy đủ 9 loại axit amin thiết yếu, vitamin D và choline giúp tổng hợp đạm tối đa.</li><li><b>Cá hồi:</b> Giàu Omega-3 và Protein giúp giảm viêm khớp, hỗ trợ trao đổi chất và tăng trưởng cơ nạc.</li><li><b>Yến mạch:</b> Nguồn tinh bột hấp thụ chậm (Complex Carbs) giúp duy trì năng lượng bền bỉ suốt buổi tập.</li><li><b>Bông cải xanh (Súp lơ):</b> Giàu chất xơ, vitamin C và các hợp chất chống oxy hóa giúp làm sạch cơ thể.</li></ol>");
            ptm.setString(4, "https://images.unsplash.com/photo-1490645935967-10de6ba17061?w=800&auto=format&fit=crop&q=80");
            ptm.setString(5, "admin");
            ptm.setString(6, "NutriOverflow Team");
            ptm.setString(7, "APPROVED");
            ptm.setInt(8, 1);
            ptm.executeUpdate();

            // Article 3
            ptm.setString(1, "Creatine Monohydrate: Tăng Sức Mạnh Bộc Phát Và Tối Ưu Khối Lượng Cơ Bắp");
            ptm.setString(2, "Giải mã toàn bộ tác dụng, liều lượng chuẩn (Loading Phase & Maintenance) và thời điểm vàng uống Creatine để bùng nổ sức mạnh.");
            ptm.setString(3, "<p>Creatine Monohydrate là một trong những thực phẩm bổ sung được nghiên cứu khoa học nhiều nhất trên thế giới về độ an toàn và tính hiệu quả trong thể thao.</p><h4>1. Creatine hoạt động như thế nào?</h4><p>Creatine giúp tái tạo nhanh chóng nguồn năng lượng ATP trong tế bào cơ bắp, giúp bạn nâng được mức tạ nặng hơn, đẩy thêm 1-2 reps cuối cùng - yếu tố then chốt kích thích cơ bắp phì đại (Hypertrophy).</p><h4>2. Hướng dẫn liều dùng chuẩn</h4><ul><li><b>Liều duy trì (Khuyên dùng):</b> Uống 3g - 5g Creatine mỗi ngày vào thời điểm sau tập hoặc buổi sáng.</li><li><b>Uống đủ nước:</b> Creatine kéo nước vào bên trong tế bào cơ, vì vậy hãy duy trì ít nhất 2.5 - 3 lít nước mỗi ngày.</li></ul>");
            ptm.setString(4, "https://images.unsplash.com/photo-1517838277536-f5f99be501cd?w=800&auto=format&fit=crop&q=80");
            ptm.setString(5, "admin");
            ptm.setString(6, "NutriOverflow Team");
            ptm.setString(7, "APPROVED");
            ptm.setInt(8, 1);
            ptm.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public BlogDTO getBlogById(int id) {
        try (Connection conn = DBUtils.getConnection();
             PreparedStatement ptm = conn.prepareStatement(GET_BLOG_BY_ID)) {
            ptm.setInt(1, id);
            try (ResultSet rs = ptm.executeQuery()) {
                if (rs.next()) {
                    String title = rs.getString("title");
                    String summary = rs.getString("summary");
                    String content = rs.getString("content");
                    String imageUrl = rs.getString("image_url");
                    String author = rs.getString("author");
                    Timestamp createdAt = rs.getTimestamp("created_at");
                    return new BlogDTO(id, title, summary, content, imageUrl, author, createdAt);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }
}

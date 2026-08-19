-- ============================================================
-- V5: Add 3 new high-quality blog articles
-- ============================================================

INSERT INTO Articles (title, summary, content, image_url, author_username, author_name, status, is_published, created_at, updated_at)
VALUES 
(
    N'Bí Quyết Chọn Whey Protein Chuẩn Dành Cho Người Mới Bắt Đầu Tập Gym',
    N'Hướng dẫn chi tiết từ A-Z cách chọn dòng Whey Protein (Isolate, Concentrate, Hydrolyzed) phù hợp với cơ địa, mục tiêu tăng cơ và ngân sách của bạn.',
    N'<p>Đối với người mới bắt đầu bước chân vào hành trình tập luyện thể hình, việc lựa chọn dòng Whey Protein phù hợp đóng vai trò vô cùng quan trọng giúp tối ưu hóa khả năng phục hồi và phát triển cơ bắp.</p><h4>1. Phân biệt các loại Whey Protein phổ biến</h4><ul><li><b>Whey Protein Concentrate (WPC):</b> Hàm lượng protein từ 70-80%, chứa một lượng nhỏ đường lactose và chất béo. Giá thành hợp lý, phù hợp người không bị dị ứng lactose.</li><li><b>Whey Protein Isolate (WPI):</b> Hàm lượng protein từ 90% trở lên, được lọc tinh khiết loại bỏ hầu hết lactose và fat. Hấp thụ siêu nhanh, phù hợp cho người siết cơ hoặc bất dung nạp lactose.</li><li><b>Whey Protein Hydrolyzed (WPH):</b> Whey thủy phân giúp phân tách protein thành các chuỗi peptide ngắn, hấp thụ vào cơ bắp tức thì.</li></ul><h4>2. Lời khuyên cho người mới</h4><p>Nếu bạn mới tập và ngân sách vừa phải, hãy chọn Whey Isolate hoặc Whey Blend từ các thương hiệu uy tín như ON Gold Standard, Mutant Iso Surge để tối ưu chi phí và hiệu quả.</p>',
    'blog_whey_guide.jpg',
    'admin',
    N'NutriOverflow Team',
    'APPROVED',
    1,
    GETDATE(),
    GETDATE()
),
(
    N'Top 5 Thực Phẩm Tự Nhiên Giúp Tăng Cơ Giảm Mỡ Hiệu Quả Nhất',
    N'Khám phá 5 loại thực phẩm tự nhiên giàu đạm và dinh dưỡng thiết yếu giúp bạn xây dựng cơ bắp săn chắc và đốt cháy mỡ thừa mỗi ngày.',
    N'<p>Chế độ dinh dưỡng chiếm tới 70% thành công trong thể hình. Dưới đây là 5 loại thực phẩm "vàng" bạn nên thêm vào thực đơn hàng ngày:</p><ol><li><b>Ức gà:</b> Cung cấp lượng protein tinh khiết cao, rất ít mỡ và calo, là lựa chọn số 1 cho người tăng cơ cắt nét.</li><li><b>Trứng gà:</b> Chứa đầy đủ 9 loại axit amin thiết yếu, vitamin D và choline giúp tổng hợp đạm tối đa.</li><li><b>Cá hồi:</b> Giàu Omega-3 và Protein giúp giảm viêm khớp, hỗ trợ trao đổi chất và tăng trưởng cơ nạc.</li><li><b>Yến mạch:</b> Nguồn tinh bột hấp thụ chậm (Complex Carbs) giúp duy trì năng lượng bền bỉ suốt buổi tập.</li><li><b>Bông cải xanh (Súp lơ):</b> Giàu chất xơ, vitamin C và các hợp chất chống oxy hóa giúp làm sạch cơ thể.</li></ol>',
    'blog_top5_foods.jpg',
    'admin',
    N'NutriOverflow Team',
    'APPROVED',
    1,
    GETDATE(),
    GETDATE()
),
(
    N'Creatine Monohydrate: Tăng Sức Mạnh Bộc Phát Và Tối Ưu Khối Lượng Cơ Bắp',
    N'Giải mã toàn bộ tác dụng, liều lượng chuẩn (Loading Phase & Maintenance) và thời điểm vàng uống Creatine để bùng nổ sức mạnh.',
    N'<p>Creatine Monohydrate là một trong những thực phẩm bổ sung được nghiên cứu khoa học nhiều nhất trên thế giới về độ an toàn và tính hiệu quả trong thể thao.</p><h4>1. Creatine hoạt động như thế nào?</h4><p>Creatine giúp tái tạo nhanh chóng nguồn năng lượng ATP trong tế bào cơ bắp, giúp bạn nâng được mức tạ nặng hơn, đẩy thêm 1-2 reps cuối cùng - yếu tố then chốt kích thích cơ bắp phì đại (Hypertrophy).</p><h4>2. Hướng dẫn liều dùng chuẩn</h4><ul><li><b>Liều duy trì (Khuyên dùng):</b> Uống 3g - 5g Creatine mỗi ngày vào thời điểm sau tập hoặc buổi sáng.</li><li><b>Uống đủ nước:</b> Creatine kéo nước vào bên trong tế bào cơ, vì vậy hãy duy trì ít nhất 2.5 - 3 lít nước mỗi ngày.</li></ul>',
    'blog_creatine_benefits.jpg',
    'admin',
    N'NutriOverflow Team',
    'APPROVED',
    1,
    GETDATE(),
    GETDATE()
);

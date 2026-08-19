<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt"%>
<!DOCTYPE html>
<html lang="en">
    <head>
        <title>${requestScope.BLOG.title} — NutriOverflow</title>
        <jsp:include page="includes/header.jsp" />
        <style>
            body {
                background-color: #f8f9fa;
                color: #2d3748;
            }
            .reader-container {
                opacity: 0;
                transform: translateY(20px);
                transition: opacity 0.8s cubic-bezier(0.16, 1, 0.3, 1), transform 0.8s cubic-bezier(0.16, 1, 0.3, 1);
                max-width: 820px;
                margin: 0 auto;
                background: #fff;
                border-radius: 32px;
                padding: 3rem 3.5rem;
                box-shadow: 0 10px 40px rgba(0,0,0,0.04);
                border: 1px solid #f0f0f0;
            }
            .post-category {
                display: inline-block;
                background: #f0fff4;
                color: #00c853;
                border: 1px solid #a7f3d0;
                border-radius: 50px;
                font-size: 0.75rem;
                font-weight: 800;
                padding: 4px 14px;
                text-transform: uppercase;
                letter-spacing: 1px;
                margin-bottom: 1.2rem;
            }
            .post-title {
                font-size: 2.3rem;
                font-weight: 800;
                line-height: 1.3;
                color: #1a202c;
                margin-bottom: 1.5rem;
                letter-spacing: -0.5px;
            }
            .post-meta {
                display: flex;
                align-items: center;
                gap: 16px;
                font-size: 0.88rem;
                color: #718096;
                border-bottom: 1px solid #edf2f7;
                padding-bottom: 1.5rem;
                margin-bottom: 2rem;
            }
            .meta-item {
                display: flex;
                align-items: center;
                gap: 6px;
            }
            .meta-item i {
                color: #00c853;
            }
            .post-hero-img-wrap {
                width: 100%;
                border-radius: 24px;
                overflow: hidden;
                box-shadow: 0 12px 30px rgba(0,0,0,0.08);
                margin-bottom: 2.5rem;
                aspect-ratio: 16/9;
            }
            .post-hero-img {
                width: 100%;
                height: 100%;
                object-fit: cover;
            }
            .post-content {
                font-size: 1.05rem;
                line-height: 1.9;
                color: #374151;
            }
            .post-content h3 {
                font-size: 1.45rem;
                font-weight: 700;
                color: #1a202c;
                margin-top: 2.2rem;
                margin-bottom: 1rem;
                border-left: 4px solid #00c853;
                padding-left: 12px;
            }
            .post-content p {
                margin-bottom: 1.4rem;
            }
            .post-content ul {
                margin-bottom: 1.4rem;
                padding-left: 1.5rem;
            }
            .post-content li {
                margin-bottom: 0.5rem;
            }
            .btn-back {
                color: #4a5568;
                font-weight: 600;
                text-decoration: none;
                display: inline-flex;
                align-items: center;
                gap: 8px;
                font-size: 0.9rem;
                transition: color 0.2s;
            }
            .btn-back:hover {
                color: #00c853;
            }
            
            /* Recommendations Card */
            .recom-card {
                background: linear-gradient(135deg, #0a0a12 0%, #1e1e30 100%);
                color: #fff;
                border-radius: 20px;
                padding: 1.8rem;
                margin-top: 3.5rem;
                border: 1px solid rgba(255,255,255,0.08);
                display: flex;
                align-items: center;
                justify-content: space-between;
                flex-wrap: wrap;
                gap: 20px;
                box-shadow: 0 10px 30px rgba(0,230,118,0.1);
            }
            .btn-recom-shop {
                background: linear-gradient(135deg, #00e676, #00c853);
                color: #0a0a0a;
                border: none;
                border-radius: 12px;
                font-weight: 800;
                font-size: 0.95rem;
                padding: 0.7rem 1.6rem;
                text-decoration: none;
                transition: all 0.25s;
                box-shadow: 0 4px 14px rgba(0,230,118,0.3);
            }
            .btn-recom-shop:hover {
                transform: translateY(-2px);
                box-shadow: 0 6px 20px rgba(0,230,118,0.5);
                color: #0a0a0a;
            }
        </style>
    </head>
    <body>
        <jsp:include page="includes/navbar.jsp" />

        <div class="container mt-4 pb-5">
            
            <%-- BREADCRUMBS & BACK BUTTON --%>
            <div class="d-flex justify-content-between align-items-center mb-4">
                <a href="bai-viet" class="btn-back">
                    <i class="fas fa-arrow-left"></i> Quay lại danh sách
                </a>
                <nav aria-label="breadcrumb" style="font-size: 0.8rem;">
                    <ol class="breadcrumb mb-0">
                        <li class="breadcrumb-item"><a href="bai-viet" class="text-decoration-none text-muted">Blog</a></li>
                        <li class="breadcrumb-item active text-dark fw-500" aria-current="page">${requestScope.BLOG.title}</li>
                    </ol>
                </nav>
            </div>

            <%-- MAIN READER CARD --%>
            <article class="reader-container">
                <%-- Category Badge --%>
                <span class="post-category">Kiến thức</span>
                
                <%-- Title --%>
                <h1 class="post-title">${requestScope.BLOG.title}</h1>
                
                <%-- Meta Information --%>
                <div class="post-meta">
                    <div class="meta-item">
                        <i class="fas fa-user-circle"></i>
                        <span>Đăng bởi: <strong>${requestScope.BLOG.author}</strong></span>
                    </div>
                    <div class="meta-item">
                        <i class="far fa-calendar-alt"></i>
                        <span>Ngày đăng: <strong><fmt:formatDate value="${requestScope.BLOG.createdAt}" pattern="dd/MM/yyyy HH:mm" /></strong></span>
                    </div>
                </div>

                <%-- Hero Image --%>
                <div class="post-hero-img-wrap">
                    <c:choose>
                        <c:when test="${not empty requestScope.BLOG.imageUrl and requestScope.BLOG.imageUrl.startsWith('http')}">
                            <img src="${requestScope.BLOG.imageUrl}" class="post-hero-img" alt="${requestScope.BLOG.title}" onerror="this.onerror=null;this.src='https://images.unsplash.com/photo-1517838277536-f5f99be501cd?w=800&auto=format&fit=crop&q=80';">
                        </c:when>
                        <c:when test="${not empty requestScope.BLOG.imageUrl}">
                            <img src="image/${requestScope.BLOG.imageUrl}" class="post-hero-img" alt="${requestScope.BLOG.title}" onerror="this.onerror=null;this.src='https://images.unsplash.com/photo-1517838277536-f5f99be501cd?w=800&auto=format&fit=crop&q=80';">
                        </c:when>
                        <c:otherwise>
                            <img src="https://images.unsplash.com/photo-1517838277536-f5f99be501cd?w=800&auto=format&fit=crop&q=80" class="post-hero-img" alt="${requestScope.BLOG.title}">
                        </c:otherwise>
                    </c:choose>
                </div>

                <%-- Raw markdown content hidden --%>
                <div id="rawContent" style="display: none;">${requestScope.BLOG.content}</div>

                <%-- Rendered Content --%>
                <div id="renderedContent" class="post-content">
                    <%-- Parsed HTML will be injected here via JavaScript --%>
                </div>

                <%-- RELATED STORE RECOMMENDATION --%>
                <c:choose>
                    <c:when test="${requestScope.BLOG.title.contains('Eat Clean')}">
                        <div class="recom-card">
                            <div>
                                <h4 class="fw-bold mb-1" style="font-size: 1.15rem; color:#fff;">Bắt đầu chế độ Eat Clean ngay hôm nay!</h4>
                                <p class="text-white-50 mb-0" style="font-size: 0.85rem;">Khám phá bộ sưu tập thực phẩm ăn kiêng, yến mạch, gia vị ăn kiêng ít calo tại cửa hàng của chúng tôi.</p>
                            </div>
                            <a href="cua-hang?category=4" class="btn-recom-shop">
                                Ghé xem Đồ Ăn Kiêng <i class="fas fa-arrow-right ms-1"></i>
                            </a>
                        </div>
                    </c:when>
                    <c:when test="${requestScope.BLOG.title.contains('Cardio')}">
                        <div class="recom-card">
                            <div>
                                <h4 class="fw-bold mb-1" style="font-size: 1.15rem; color:#fff;">Tăng hiệu suất Cardio & Đốt mỡ nhanh hơn!</h4>
                                <p class="text-white-50 mb-0" style="font-size: 0.85rem;">Tìm kiếm các dòng Fat Burner, L-Carnitine, Pre-Workout để tăng sức bền và tối ưu calo tiêu thụ.</p>
                            </div>
                            <a href="cua-hang?category=5" class="btn-recom-shop">
                                Xem Hỗ Trợ Đốt Mỡ <i class="fas fa-arrow-right ms-1"></i>
                            </a>
                        </div>
                    </c:when>
                    <c:when test="${requestScope.BLOG.title.contains('Whey Protein')}">
                        <div class="recom-card">
                            <div>
                                <h4 class="fw-bold mb-1" style="font-size: 1.15rem; color:#fff;">Nuôi dưỡng cơ bắp của bạn sau tập luyện!</h4>
                                <p class="text-white-50 mb-0" style="font-size: 0.85rem;">Mua ngay Whey Protein Isolate, Hydrolyzed tinh khiết cao cấp nhất giúp phục hồi cơ bắp cấp tốc.</p>
                            </div>
                            <a href="cua-hang?category=1" class="btn-recom-shop">
                                Xem Whey Protein <i class="fas fa-arrow-right ms-1"></i>
                            </a>
                        </div>
                    </c:when>
                </c:choose>

            </article>

        </div>

        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
        <script>
            // Client-side markdown parser
            function parseMarkdown(md) {
                // If it contains HTML tags, return it directly without parsing or escaping
                if (md.trim().startsWith('<') || md.includes('</')) {
                    return md;
                }
                
                // Escape HTML characters
                let html = md
                    .replace(/&/g, "&amp;")
                    .replace(/</g, "&lt;")
                    .replace(/>/g, "&gt;");
                
                // Replace headers (###, ##, #)
                html = html.replace(/^### (.*$)/gim, '<h3>$1</h3>');
                html = html.replace(/^## (.*$)/gim, '<h2>$1</h2>');
                html = html.replace(/^# (.*$)/gim, '<h1>$1</h1>');
                
                // Replace bold (**text**)
                html = html.replace(/\*\*(.*?)\*\*/g, '<strong>$1</strong>');
                
                // Replace italics (*text*)
                html = html.replace(/\*(.*?)\*/g, '<em>$1</em>');
                
                // Handle bullet points (* point)
                // Split lines
                let lines = html.split('\n');
                let inList = false;
                for (let i = 0; i < lines.length; i++) {
                    let trimLine = lines[i].trim();
                    if (trimLine.startsWith('* ') || trimLine.startsWith('- ')) {
                        let content = trimLine.substring(2);
                        if (!inList) {
                            lines[i] = '<ul><li>' + content + '</li>';
                            inList = true;
                        } else {
                            lines[i] = '<li>' + content + '</li>';
                        }
                    } else {
                        if (inList) {
                            lines[i] = '</ul>' + lines[i];
                            inList = false;
                        }
                        
                        // Treat non-empty, non-header lines as paragraphs
                        if (trimLine.length > 0 && !trimLine.startsWith('<h') && !trimLine.startsWith('<ul') && !trimLine.startsWith('</ul')) {
                            lines[i] = '<p>' + lines[i] + '</p>';
                        }
                    }
                }
                if (inList) {
                    lines.push('</ul>');
                }
                
                return lines.join('\n');
            }

            document.addEventListener("DOMContentLoaded", function() {
                const raw = document.getElementById("rawContent").innerHTML;
                const parsed = parseMarkdown(raw);
                document.getElementById("renderedContent").innerHTML = parsed;
                
                // Smooth fade-in animation
                const container = document.querySelector('.reader-container');
                if (container) {
                    setTimeout(() => {
                        container.style.opacity = 1;
                        container.style.transform = 'translateY(0)';
                    }, 50);
                }
            });
        </script>
    
    <jsp:include page="includes/footer.jsp" />
</body>
</html>

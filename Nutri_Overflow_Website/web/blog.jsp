<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt"%>
<!DOCTYPE html>
<html lang="en">
    <head>
        <title>Blog Sức Khỏe & Dinh Dưỡng — NutriOverflow</title>
        <jsp:include page="includes/header.jsp" />
        <style>
            body {
                background-color: #f5f6f8;
            }
            
            /* ?? SCROLL ANIMATIONS ?? */
            .fade-in-up {
                opacity: 0;
                transform: translateY(30px);
                transition: opacity 0.8s cubic-bezier(0.16, 1, 0.3, 1), transform 0.8s cubic-bezier(0.16, 1, 0.3, 1);
            }
            .fade-in-up.visible {
                opacity: 1;
                transform: translateY(0);
            }
            .blog-header {
                background: linear-gradient(135deg, #0a0a12 0%, #1c1c2b 100%);
                color: #fff;
                padding: 4.5rem 0;
                position: relative;
                overflow: hidden;
                border-radius: 0 0 40px 40px;
                box-shadow: 0 10px 30px rgba(0,0,0,0.15);
            }
            .blog-header::before {
                content: '';
                position: absolute;
                inset: 0;
                background: radial-gradient(circle at 80% 20%, rgba(0, 230, 118, 0.12) 0%, transparent 60%);
            }
            .blog-card {
                background: #fff;
                border: 1.5px solid #f0f0f0;
                border-radius: 24px;
                overflow: hidden;
                transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
                height: 100%;
                display: flex;
                flex-direction: column;
                box-shadow: 0 4px 20px rgba(0,0,0,0.04);
            }
            .blog-card:hover {
                transform: translateY(-8px);
                box-shadow: 0 16px 36px rgba(0, 230, 118, 0.12);
                border-color: rgba(0, 230, 118, 0.25);
            }
            .blog-img-wrap {
                position: relative;
                overflow: hidden;
                aspect-ratio: 16/10;
                background: #f3f4f6;
            }
            .blog-img {
                width: 100%;
                height: 100%;
                object-fit: cover;
                transition: transform 0.5s ease;
            }
            .blog-card:hover .blog-img {
                transform: scale(1.06);
            }
            .blog-tag {
                position: absolute;
                top: 16px;
                left: 16px;
                background: linear-gradient(135deg, #00e676, #00c853);
                color: #0a0a0a;
                font-size: 0.72rem;
                font-weight: 800;
                padding: 5px 12px;
                border-radius: 50px;
                text-transform: uppercase;
                letter-spacing: 0.5px;
                box-shadow: 0 4px 10px rgba(0,230,118,0.3);
            }
            .blog-body {
                padding: 1.6rem;
                display: flex;
                flex-direction: column;
                flex-grow: 1;
            }
            .blog-title {
                font-size: 1.25rem;
                font-weight: 700;
                color: #111827;
                line-height: 1.4;
                margin-bottom: 0.8rem;
                transition: color 0.22s;
                display: -webkit-box;
                -webkit-line-clamp: 2;
                -webkit-box-orient: vertical;
                overflow: hidden;
            }
            .blog-card:hover .blog-title {
                color: #00c853;
            }
            .blog-summary {
                font-size: 0.92rem;
                color: #6b7280;
                line-height: 1.6;
                margin-bottom: 1.5rem;
                display: -webkit-box;
                -webkit-line-clamp: 3;
                -webkit-box-orient: vertical;
                overflow: hidden;
                flex-grow: 1;
            }
            .blog-footer {
                display: flex;
                align-items: center;
                justify-content: space-between;
                border-top: 1.5px solid #f9fafb;
                padding-top: 1rem;
                margin-top: auto;
                font-size: 0.8rem;
                color: #9ca3af;
            }
            .blog-author {
                font-weight: 600;
                color: #4b5563;
                display: flex;
                align-items: center;
                gap: 6px;
            }
            .blog-author i {
                color: #00c853;
            }
            .btn-read-more {
                color: #00c853;
                font-weight: 700;
                text-decoration: none;
                font-size: 0.88rem;
                display: inline-flex;
                align-items: center;
                gap: 5px;
                transition: gap 0.2s;
            }
            .btn-read-more:hover {
                gap: 8px;
                color: #009624;
            }
        </style>
    </head>
    <body>
        <jsp:include page="includes/navbar.jsp" />

        <%-- HEADER --%>
        <header class="blog-header text-center mb-5">
            <div class="container" style="max-width: 900px;">
                <span style="display:inline-block; background:rgba(0,230,118,0.12); color:#00e676; border-radius:50px; font-size:0.75rem; font-weight:800; letter-spacing:1.5px; padding:6px 16px; text-transform:uppercase; margin-bottom:14px;">
                    Cẩm nang NutriOverflow
                </span>
                <h1 style="font-size: 2.8rem; font-weight: 800; letter-spacing: -1px; margin-bottom: 12px;">Blog Sức Khỏe & Thể Hình</h1>
                <p class="text-white-50 fs-5 mb-0">Cung cấp kiến thức tập luyện, chế độ dinh dưỡng lành mạnh và lối sống khoa học từ chuyên gia.</p>
            </div>
        </header>

        <%-- MAIN GRID --%>
        <main class="container mb-5" style="max-width: 1100px;">
            <div class="row g-4">
                <c:choose>
                    <c:when test="${not empty requestScope.BLOG_LIST}">
                        <c:forEach var="blog" items="${requestScope.BLOG_LIST}">
                            <div class="col-md-6 col-lg-4">
                                <article class="blog-card">
                                    <div class="blog-img-wrap">
                                        <c:choose>
                                            <c:when test="${not empty blog.imageUrl and blog.imageUrl.startsWith('http')}">
                                                <img src="${blog.imageUrl}" class="blog-img" alt="${blog.title}" onerror="this.onerror=null;this.src='https://images.unsplash.com/photo-1517838277536-f5f99be501cd?w=800&auto=format&fit=crop&q=80';">
                                            </c:when>
                                            <c:when test="${not empty blog.imageUrl}">
                                                <img src="image/${blog.imageUrl}" class="blog-img" alt="${blog.title}" onerror="this.onerror=null;this.src='https://images.unsplash.com/photo-1517838277536-f5f99be501cd?w=800&auto=format&fit=crop&q=80';">
                                            </c:when>
                                            <c:otherwise>
                                                <img src="https://images.unsplash.com/photo-1517838277536-f5f99be501cd?w=800&auto=format&fit=crop&q=80" class="blog-img" alt="${blog.title}">
                                            </c:otherwise>
                                        </c:choose>
                                        <span class="blog-tag">Kiến thức</span>
                                    </div>
                                    <div class="blog-body">
                                        <a href="bai-viet?action=BlogDetail&id=${blog.blogId}" class="text-decoration-none">
                                            <h2 class="blog-title">${blog.title}</h2>
                                        </a>
                                        <p class="blog-summary">${blog.summary}</p>
                                        
                                        <div class="blog-footer">
                                            <span class="blog-author">
                                                <i class="fas fa-user-circle"></i> ${blog.author}
                                            </span>
                                            <span>
                                                <i class="far fa-calendar-alt me-1"></i>
                                                <fmt:formatDate value="${blog.createdAt}" pattern="dd/MM/yyyy" />
                                            </span>
                                        </div>
                                        
                                        <div class="mt-3">
                                            <a href="bai-viet?action=BlogDetail&id=${blog.blogId}" class="btn-read-more">
                                                Đọc bài viết <i class="fas fa-arrow-right"></i>
                                            </a>
                                        </div>
                                    </div>
                                </article>
                            </div>
                        </c:forEach>
                    </c:when>
                    <c:otherwise>
                        <div class="col-12 text-center py-5">
                            <i class="far fa-newspaper text-muted mb-3" style="font-size: 3.5rem;"></i>
                            <p class="text-muted fs-5">Hiện tại chưa có bài viết nào được đăng tải.</p>
                        </div>
                    </c:otherwise>
                </c:choose>
            </div>
        </main>

        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
        <script>
            document.addEventListener("DOMContentLoaded", function() {
                // Initialize Intersection Observer for scroll fade-in animations
                const observer = new IntersectionObserver((entries) => {
                    entries.forEach(entry => {
                        if (entry.isIntersecting) {
                            entry.target.classList.add('visible');
                            observer.unobserve(entry.target);
                        }
                    });
                }, { threshold: 0.08 });

                document.querySelectorAll('.blog-card').forEach(card => {
                    card.classList.add('fade-in-up');
                    observer.observe(card);
                });
            });
        </script>
    
    <jsp:include page="includes/footer.jsp" />
</body>
</html>

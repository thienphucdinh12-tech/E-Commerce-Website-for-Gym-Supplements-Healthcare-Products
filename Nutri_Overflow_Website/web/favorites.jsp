<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/fmt"  prefix="fmt"%>
<!DOCTYPE html>
<html>
    <head>
        <title>Danh sách yêu thích — NutriOverflow</title>
        <jsp:include page="includes/header.jsp" />
        <style>
            /* ── PAGE HERO ── */
            .page-hero {
                background: linear-gradient(135deg, #0a0a12 0%, #0d1f10 100%);
                padding: 2.5rem 0 2rem;
                margin-bottom: 2.5rem;
            }
            .page-hero h1 {
                font-size: 1.6rem;
                font-weight: 900;
                color: #fff;
                margin: 0;
            }
            .page-hero p  {
                color: rgba(255,255,255,0.5);
                font-size: 0.85rem;
                margin: 6px 0 0;
            }

            /* ── EMPTY STATE ── */
            .empty-state {
                text-align: center;
                padding: 5rem 1rem;
            }
            .empty-state i {
                font-size: 4rem;
                color: #d1d5db;
                margin-bottom: 1rem;
                display: block;
            }
            .empty-state h4 {
                font-weight: 800;
                color: var(--txt);
                margin-bottom: 0.5rem;
            }
            .empty-state p  {
                color: var(--txt-muted);
                font-size: 0.875rem;
                margin-bottom: 1.5rem;
            }
        </style>
    </head>
    <body class="bg-light">
        <jsp:include page="includes/navbar.jsp" />

        <!-- PAGE HERO -->
        <div class="page-hero">
            <div class="container">
                <h1><i class="fas fa-heart me-2" style="color:#ef4444;"></i>Danh sách yêu thích</h1>
                <p>Lưu và quản lý các sản phẩm bạn muốn mua sau</p>
            </div>
        </div>

        <div class="container pb-5">
            <div class="row g-4">
                <c:choose>
                    <c:when test="${not empty requestScope.LIST_FAVORITE}">
                        <c:forEach var="p" items="${requestScope.LIST_FAVORITE}">
                            <div class="col-6 col-md-4 col-lg-3 position-relative">
                                <a href="RemoveFavoriteController?id=${p.id}" 
                                   class="btn btn-danger btn-sm position-absolute rounded-circle shadow-sm d-flex align-items-center justify-content-center" 
                                   style="top: 10px; right: 20px; z-index: 10; width: 32px; height: 32px;" 
                                   onclick="return confirm('Bạn có chắc chắn muốn xóa sản phẩm này khỏi danh sách yêu thích?');"
                                   title="Xóa khỏi danh sách yêu thích">
                                    <i class="fas fa-heart-broken"></i>
                                </a>

                                <a href="san-pham?id=${p.id}" class="text-decoration-none text-dark">
                                    <div class="card h-100 card-product border-0 shadow-sm rounded-4" style="transition: all 0.3s ease;">
                                        <div class="bg-white text-center p-3 rounded-top-4" style="height: 200px; display: flex; align-items: center; justify-content: center; overflow: hidden;">
                                            <img src="image/${p.imageUrl}" onerror="this.src='https://via.placeholder.com/200'" style="max-height: 100%; max-width: 100%; object-fit: contain;">
                                        </div>
                                        <div class="card-body d-flex flex-column text-center">
                                            <h6 class="card-title fw-bold text-truncate" title="${p.name}">${p.name}</h6>

                                            <%-- Hiển thị giá sau giảm nếu có, giá gốc nếu không --%>
                                            <c:choose>
                                                <c:when test="${not empty p.discountPrice and p.discountPrice > 0}">
                                                    <%-- Có giá giảm --%>
                                                    <div class="mt-auto">
                                                        <c:if test="${p.discountPercent > 0}">
                                                            <span class="badge text-white mb-1"
                                                                  style="background:linear-gradient(135deg,#ef4444,#dc2626);font-size:0.7rem;">
                                                                -${p.discountPercent}%
                                                            </span>
                                                        </c:if>
                                                        <div class="text-success fw-bold" style="font-size:1.05rem;">
                                                            <fmt:formatNumber value="${p.discountPrice}" type="number" maxFractionDigits="0"/> ₫
                                                        </div>
                                                        <div class="text-decoration-line-through text-muted" style="font-size:0.78rem;">
                                                            <fmt:formatNumber value="${p.price}" type="number" maxFractionDigits="0"/> ₫
                                                        </div>
                                                    </div>
                                                </c:when>
                                                <c:otherwise>
                                                    <%-- Không có giảm giá --%>
                                                    <h5 class="text-success fw-bold mt-auto mb-0">
                                                        <fmt:formatNumber value="${p.price}" type="number" maxFractionDigits="0"/> ₫
                                                    </h5>
                                                </c:otherwise>
                                            </c:choose>
                                        </div>
                                    </div>
                                </a>
                            </div>
                        </c:forEach>
                    </c:when>
                    <c:otherwise>
                        <div class="col-12">
                            <div class="empty-state">
                                <i class="far fa-heart"></i>
                                <h4>Danh sách yêu thích trống</h4>
                                <p>Khám phá cửa hàng của chúng tôi và thêm những sản phẩm bạn yêu thích.</p>
                                <a href="cua-hang" class="btn btn-brand">Mua sắm ngay</a>
                            </div>
                        </div>
                    </c:otherwise>
                </c:choose>
            </div>
        </div>

        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
        <jsp:include page="includes/footer.jsp" />
    </body>
</html>
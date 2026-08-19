<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt"%>
<!DOCTYPE html>
<html lang="en">
    <head>
        <title>${requestScope.PRODUCT.name} — NutriOverflow</title>
        <jsp:include page="includes/header.jsp" />
        <style>
            body {
                background: #f5f6f8;
            }

            /* ── IMAGE PANEL ── */
            .detail-img-panel {
                background: linear-gradient(145deg, #f0f2f5 0%, #e8eaf0 100%);
                border-radius: 24px;
                height: 480px;
                display: flex;
                align-items: center;
                justify-content: center;
                position: relative;
                overflow: hidden;
            }
            @media (max-width: 768px) {
                .detail-img-panel {
                    height: 350px;
                }
            }
            .product-detail-img {
                max-width: 90%;
                max-height: 90%;
                object-fit: contain;
                border-radius: 24px;
                transition: transform 0.5s cubic-bezier(0.16, 1, 0.3, 1);
            }
            .detail-img-panel:hover .product-detail-img {
                transform: scale(1.04);
            }
            .detail-img-panel::before {
                content: '';
                position: absolute;
                inset: 0;
                background: radial-gradient(circle at 60% 40%, rgba(0,230,118,0.08) 0%, transparent 70%);
            }
            .detail-img-panel .product-icon {
                font-size: 9rem;
                color: #9ca3af;
                filter: drop-shadow(0 12px 28px rgba(0,0,0,0.15));
                position: relative;
                z-index: 1;
            }

            /* ── BADGE STOCK ── */
            .stock-badge {
                display: inline-flex;
                align-items: center;
                gap: 6px;
                background: #ecfdf5;
                color: #065f46;
                border: 1px solid #a7f3d0;
                border-radius: 50px;
                font-size: 0.78rem;
                font-weight: 700;
                padding: 4px 14px;
            }
            .stock-badge.low {
                background: #fff7ed;
                color: #9a3412;
                border-color: #fed7aa;
            }
            .stock-badge .dot {
                width: 7px;
                height: 7px;
                border-radius: 50%;
                background: currentColor;
                animation: pulse-dot 1.5s infinite;
            }
            @keyframes pulse-dot {
                0%, 100% {
                    opacity: 1;
                    transform: scale(1);
                }
                50%       {
                    opacity: 0.5;
                    transform: scale(0.7);
                }
            }

            /* ── QUANTITY STEPPER ── */
            .qty-stepper {
                display: inline-flex;
                align-items: center;
                border: 1.5px solid #e5e7eb;
                border-radius: 12px;
                overflow: hidden;
                background: #fff;
            }
            .qty-btn {
                width: 42px;
                height: 42px;
                background: none;
                border: none;
                font-size: 1.1rem;
                font-weight: 700;
                color: #374151;
                cursor: pointer;
                transition: background 0.18s;
                display: flex;
                align-items: center;
                justify-content: center;
            }
            .qty-btn:hover {
                background: #f3f4f6;
            }
            .qty-input {
                width: 56px;
                border: none;
                border-left: 1.5px solid #e5e7eb;
                border-right: 1.5px solid #e5e7eb;
                text-align: center;
                font-size: 1rem;
                font-weight: 700;
                color: #111827;
                height: 42px;
                outline: none;
                background: #fff;
            }
            .qty-input::-webkit-inner-spin-button,
            .qty-input::-webkit-outer-spin-button {
                -webkit-appearance: none;
            }

            /* ── BUTTONS ── */
            .btn-add-cart {
                background: linear-gradient(135deg, #00e676, #00c853);
                color: #0a0a0a;
                border: none;
                border-radius: 14px;
                font-size: 0.92rem;
                font-weight: 800;
                letter-spacing: 0.5px;
                padding: 0.75rem 2rem;
                cursor: pointer;
                transition: all 0.25s ease;
                box-shadow: 0 4px 18px rgba(0,230,118,0.35);
                flex: 1;
            }
            .btn-add-cart:hover {
                transform: translateY(-2px);
                box-shadow: 0 8px 28px rgba(0,230,118,0.5);
            }
            .btn-add-cart:active {
                transform: translateY(0);
            }

            .btn-wishlist {
                width: 52px;
                height: 52px;
                border-radius: 14px;
                border: 1.5px solid #fca5a5;
                background: #fff;
                color: #ef4444;
                font-size: 1.1rem;
                cursor: pointer;
                transition: all 0.22s;
                display: flex;
                align-items: center;
                justify-content: center;
                flex-shrink: 0;
            }
            .btn-wishlist:hover {
                background: #fef2f2;
                border-color: #ef4444;
                transform: scale(1.08);
            }

            /* ── TRUST SIGNALS ── */
            .trust-item {
                display: flex;
                align-items: center;
                gap: 10px;
                font-size: 0.8rem;
                color: #6b7280;
                font-weight: 500;
            }
            .trust-item i {
                width: 32px;
                height: 32px;
                background: #f3f4f6;
                border-radius: 8px;
                display: flex;
                align-items: center;
                justify-content: center;
                color: #00c853;
                font-size: 0.85rem;
                flex-shrink: 0;
            }

            /* ── DESCRIPTION BOX ── */
            .desc-box {
                background: #fff;
                border-radius: 16px;
                border: 1.5px solid #f0f0f0;
                padding: 1.5rem 1.8rem;
            }
            .desc-box h6 {
                font-size: 0.75rem;
                font-weight: 800;
                letter-spacing: 1.2px;
                text-transform: uppercase;
                color: #9ca3af;
                margin-bottom: 10px;
            }
            .desc-box p {
                font-size: 0.92rem;
                color: #374151;
                line-height: 1.85;
                margin: 0;
                white-space: pre-line;
            }

            /* ── DIVIDER ── */
            .detail-divider {
                border: none;
                border-top: 1.5px solid #f0f2f5;
                margin: 1.4rem 0;
            }

            /* ── PRICE ── */
            .price-tag {
                font-size: 2.2rem;
                font-weight: 900;
                color: #e53935;
                line-height: 1;
                letter-spacing: -1px;
            }
            .price-unit {
                font-size: 1rem;
                font-weight: 600;
                color: #9ca3af;
                margin-left: 4px;
            }
            .price-original {
                font-size: 1rem;
                font-weight: 500;
                color: #9ca3af;
                text-decoration: line-through;
            }
            .discount-badge-detail {
                display: inline-flex;
                align-items: center;
                background: #e53935;
                color: #fff;
                font-size: 0.82rem;
                font-weight: 800;
                border-radius: 8px;
                padding: 4px 12px;
                letter-spacing: 0.3px;
            }
            .flash-sale-badge-detail {
                display: inline-flex;
                align-items: center;
                gap: 5px;
                background: linear-gradient(135deg, #ff2d2d, #ff6b35);
                color: #fff;
                font-size: 0.78rem;
                font-weight: 800;
                border-radius: 50px;
                padding: 5px 14px;
                letter-spacing: 0.5px;
                box-shadow: 0 3px 12px rgba(255,45,45,0.45);
                animation: flashPulseDetail 1.8s infinite alternate;
            }
            @keyframes flashPulseDetail {
                0%   {
                    box-shadow: 0 3px 10px rgba(255,45,45,0.35);
                }
                100% {
                    box-shadow: 0 5px 20px rgba(255,45,45,0.7);
                }
            }

            /* ── THUMBNAIL DOTS (decoration) ── */
            .img-dots {
                display: flex;
                gap: 6px;
                justify-content: center;
                margin-top: 14px;
            }
            .img-dots span {
                width: 8px;
                height: 8px;
                border-radius: 50%;
                background: #d1d5db;
            }
            .img-dots span.active {
                background: var(--brand, #00e676);
                width: 22px;
                border-radius: 4px;
            }

            /* ── REVIEWS SECTION ── */
            .review-section {
                background: #fff;
                border-radius: 24px;
                padding: 2.2rem 2.4rem;
                box-shadow: 0 4px 24px rgba(0,0,0,0.07);
                border: 1.5px solid #f0f0f0;
            }
            .review-title {
                font-size: 1.5rem;
                font-weight: 800;
                color: #111827;
                margin-bottom: 1.5rem;
                display: flex;
                align-items: center;
                gap: 10px;
            }
            .review-form-card {
                background: #fff;
                border: 1.5px solid #f0f2f5;
                border-radius: 16px;
                padding: 1.5rem;
            }
            .review-item {
                padding: 1.2rem 0;
                border-bottom: 1.5px solid #f0f2f5;
            }
            .review-item:last-child {
                border-bottom: none;
            }
            .review-avatar {
                width: 44px;
                height: 44px;
                border-radius: 50%;
                background: #f3f4f6;
                color: #9ca3af;
                display: flex;
                align-items: center;
                justify-content: center;
                font-size: 1.2rem;
            }
            .rating-stars {
                color: #ffc107;
                font-size: 0.9rem;
            }
            .rating-stars-empty {
                color: #e4e5e9;
                font-size: 0.9rem;
            }
            .btn-submit-review {
                background: linear-gradient(135deg, #00e676, #00c853);
                color: #0a0a0a;
                border: none;
                border-radius: 12px;
                font-weight: 700;
                font-size: 0.95rem;
                padding: 0.65rem 1.5rem;
                cursor: pointer;
                transition: all 0.22s;
                box-shadow: 0 4px 14px rgba(0, 230, 118, 0.25);
            }
            .btn-submit-review:hover {
                transform: translateY(-2px);
                box-shadow: 0 6px 18px rgba(0, 230, 118, 0.4);
            }
        </style>
    </head>
    <body>
        <jsp:include page="includes/navbar.jsp" />

        <div class="container-lg mt-4 pb-5" style="max-width: 1100px;">

            <%-- BREADCRUMB --%>
            <nav aria-label="breadcrumb" class="mb-4">
                <ol class="breadcrumb" style="font-size:0.82rem;">
                    <li class="breadcrumb-item"><a href="cua-hang" class="text-decoration-none fw-600" style="color:var(--brand);">Cửa hàng</a></li>
                    <li class="breadcrumb-item active text-muted" aria-current="page">${requestScope.PRODUCT.name}</li>
                </ol>
            </nav>

            <%-- MAIN PRODUCT CARD --%>
            <div class="row g-4 align-items-start">

                <%-- LEFT: IMAGE --%>
                <div class="col-md-5">
                    <div class="detail-img-panel">
                        <%-- Flash Sale overlay badge on image --%>
                        <c:if test="${requestScope.PRODUCT.flashSale}">
                            <div style="position:absolute;top:16px;left:16px;z-index:2;">
                                <span class="flash-sale-badge-detail">&#9889; SALE S&#7888;C</span>
                            </div>
                        </c:if>
                        <%-- Discount % badge --%>
                        <c:if test="${requestScope.PRODUCT.discountPercent > 0}">
                            <div style="position:absolute;top:16px;right:16px;z-index:2;background:#e53935;color:#fff;font-size:1rem;font-weight:900;border-radius:10px;padding:6px 14px;box-shadow:0 4px 14px rgba(229,57,53,0.5);">
                                -${requestScope.PRODUCT.discountPercent}%
                            </div>
                        </c:if>
                        <c:choose>
                            <c:when test="${not empty requestScope.PRODUCT.imageUrl and requestScope.PRODUCT.imageUrl != 'default-product.jpg'}">
                                <img src="image/${requestScope.PRODUCT.imageUrl}" class="product-detail-img" alt="${requestScope.PRODUCT.name}"/>
                            </c:when>
                            <c:otherwise>
                                <i class="fas fa-prescription-bottle-alt product-icon"></i>
                            </c:otherwise>
                        </c:choose>
                    </div>
                    <div class="img-dots mt-3">
                        <span class="active"></span>
                        <span></span>
                        <span></span>
                    </div>
                </div>

                <%-- RIGHT: INFO --%>
                <div class="col-md-7">
                    <div style="background:#fff; border-radius:24px; padding:2.2rem 2.4rem; box-shadow: 0 4px 24px rgba(0,0,0,0.07);">

                        <%-- Category tag + Flash Sale badge --%>
                        <div class="d-flex align-items-center gap-2 flex-wrap mb-3">
                            <span style="display:inline-block; background:#f0fff8; color:#00c853; border:1px solid #a7f3d0; border-radius:50px; font-size:0.72rem; font-weight:700; letter-spacing:1px; padding:4px 14px; text-transform:uppercase;">
                                <i class="fas fa-tag me-1"></i>Thực phẩm bổ sung
                            </span>
                            <c:if test="${requestScope.PRODUCT.flashSale}">
                                <span class="flash-sale-badge-detail">&#9889; SALE S&#7888;C</span>
                            </c:if>
                        </div>

                        <%-- Product Name --%>
                        <h1 style="font-size:1.75rem; font-weight:900; color:#111827; line-height:1.25; margin-bottom:14px; letter-spacing:-0.5px;">
                            ${requestScope.PRODUCT.name}
                        </h1>

                        <%-- Price row — hiển thị giá sau giảm + giá gốc + badge % --%>
                        <c:choose>
                            <c:when test="${requestScope.PRODUCT.discountPrice != null && requestScope.PRODUCT.discountPrice > 0}">
                                <div class="mb-1">
                                    <span class="price-tag">${String.format("%,.0f", requestScope.PRODUCT.discountPrice)}</span>
                                    <span class="price-unit">đ</span>
                                </div>
                                <div class="d-flex align-items-center gap-2 mb-3">
                                    <span class="price-original">${String.format("%,.0f", requestScope.PRODUCT.price)}đ</span>
                                    <span class="discount-badge-detail">-${requestScope.PRODUCT.discountPercent}%</span>
                                    <span style="font-size:0.78rem;color:#059669;font-weight:700;">
                                        Tiết kiệm ${String.format("%,.0f", requestScope.PRODUCT.price - requestScope.PRODUCT.discountPrice)}đ
                                    </span>
                                </div>
                            </c:when>
                            <c:otherwise>
                                <div class="d-flex align-items-baseline gap-2 mb-3">
                                    <span class="price-tag">${String.format("%,.0f", requestScope.PRODUCT.price)}</span>
                                    <span class="price-unit">đ</span>
                                </div>
                            </c:otherwise>
                        </c:choose>

                        <%-- Stock badge --%>
                        <div class="mb-3">
                            <c:choose>
                                <c:when test="${requestScope.PRODUCT.quantity > 10}">
                                    <span class="stock-badge"><span class="dot"></span>Còn ${requestScope.PRODUCT.quantity} sản phẩm</span>
                                </c:when>
                                <c:when test="${requestScope.PRODUCT.quantity > 0}">
                                    <span class="stock-badge low"><span class="dot"></span>Chỉ còn ${requestScope.PRODUCT.quantity} sản phẩm!</span>
                                </c:when>
                                <c:otherwise>
                                    <span class="stock-badge" style="background:#fef2f2;color:#991b1b;border-color:#fca5a5;"><span class="dot"></span>Tạm hết hàng</span>
                                </c:otherwise>
                            </c:choose>
                        </div>

                        <hr class="detail-divider">

                        <%-- Description Box rút gọn / mở rộng inline --%>
                        <div class="desc-box mb-4 position-relative">
                            <h6><i class="fas fa-info-circle me-2"></i>Mô tả sản phẩm</h6>

                            <%-- Hộp chứa nội dung bị giới hạn chiều cao ngoài trang chính --%>
                            <div class="desc-preview-content" id="descContent" style="max-height: 120px; overflow: hidden; position: relative; transition: max-height 0.4s ease;">
                                <%-- Giữ nguyên định dạng xuống hàng bằng pre-line, không dùng thẻ danh sách --%>
                                <p style="font-size: 0.92rem; color: #374151; line-height: 1.85; margin: 0; white-space: pre-line;">
                                    ${requestScope.PRODUCT.description}
                                </p>
                                <%-- Lớp phủ mờ ở đáy tạo hiệu ứng văn bản còn tiếp (sẽ biến mất khi mở rộng) --%>
                                <div id="descOverlay" style="position: absolute; bottom: 0; left: 0; width: 100%; height: 40px; background: linear-gradient(transparent, #fff); pointer-events: none; transition: opacity 0.3s ease;"></div>
                            </div>

                            <%-- Nút bấm mở rộng xem chi tiết qua modal --%>
                            <div class="text-center mt-2">
                                <button type="button" class="btn btn-sm fw-bold" id="btnToggleDesc" data-bs-toggle="modal" data-bs-target="#descriptionModal" style="color: #00c853; background: none; border: none; font-size: 0.9rem; outline: none; box-shadow: none;">
                                    <span>Xem thêm chi tiết</span> <i class="fas fa-external-link-alt ms-1" style="font-size: 0.8rem;"></i>
                                </button>
                            </div>
                        </div>

                        <%-- Form: Quantity + Buttons --%>
                        <form action="MainController" method="POST">
                            <input type="hidden" name="productId" value="${requestScope.PRODUCT.id}"/>

                            <%-- Quantity label --%>
                            <label style="font-size:0.8rem; font-weight:700; color:#6b7280; letter-spacing:0.8px; text-transform:uppercase; display:block; margin-bottom:10px;">
                                Số lượng
                            </label>

                            <%-- Stepper + Buttons row --%>
                            <div class="d-flex align-items-center gap-3 flex-wrap">

                                <%-- Custom stepper --%>
                                <div class="qty-stepper">
                                    <button type="button" class="qty-btn" onclick="changeQty(-1)">−</button>
                                    <input type="number" id="qtyInput" name="quantity" class="qty-input"
                                           value="1" min="1" max="${requestScope.PRODUCT.quantity}" readonly>
                                    <button type="button" class="qty-btn" onclick="changeQty(1)">+</button>
                                </div>

                                <%-- Add to Cart --%>
                                <button type="submit" name="action" value="Add" class="btn-add-cart">
                                    <i class="fas fa-shopping-bag me-2"></i>Thêm vào giỏ hàng
                                </button>

                                <%-- Wishlist --%>
                                <button type="submit" name="action" value="AddFavorite" class="btn-wishlist" title="Thêm vào yêu thích">
                                    <i class="far fa-heart"></i>
                                </button>
                            </div>

                            <p class="text-muted mt-2" style="font-size:0.78rem;">
                                <i class="fas fa-shield-alt me-1" style="color:#00c853;"></i>
                                Tối đa ${requestScope.PRODUCT.quantity} sản phẩm mỗi đơn hàng
                            </p>
                        </form>

                        <hr class="detail-divider">

                        <%-- Trust signals --%>
                        <div class="row g-3">
                            <div class="col-6">
                                <div class="trust-item">
                                    <i class="fas fa-truck-fast"></i>
                                    <span>Miễn phí vận chuyển từ 500K</span>
                                </div>
                            </div>
                            <div class="col-6">
                                <div class="trust-item">
                                    <i class="fas fa-rotate-left"></i>
                                    <span>Đổi trả miễn phí trong 7 ngày</span>
                                </div>
                            </div>
                            <div class="col-6">
                                <div class="trust-item">
                                    <i class="fas fa-certificate"></i>
                                    <span>Cam kết chính hãng 100%</span>
                                </div>
                            </div>
                            <div class="col-6">
                                <div class="trust-item">
                                    <i class="fas fa-headset"></i>
                                    <span>Hỗ trợ khách hàng 24/7</span>
                                </div>
                            </div>
                        </div>

                    </div>
                </div>
            </div>

            <%-- SUCCESS / ERROR MESSAGES MOVED TO GLOBAL TOAST IN FOOTER --%>

            <%-- REVIEWS & COMMENTS SECTION --%>
            <div class="row mt-5">
                <div class="col-12">
                    <div class="review-section">
                        <h3 class="review-title">
                            <i class="fas fa-star text-warning"></i> Đánh giá & Nhận xét
                        </h3>
                        
                        <div class="row g-4">
                            <%-- LEFT: WRITE REVIEW FORM --%>
                            <div class="col-md-5">
                                <div class="review-form-card">
                                    <h5 class="fw-bold mb-3" style="font-size: 1.1rem; color: #1f2937;">Viết đánh giá của bạn</h5>
                                    
                                    <c:choose>
                                        <c:when test="${not empty sessionScope.LOGIN_USER}">
                                            <form action="MainController" method="POST">
                                                <input type="hidden" name="productId" value="${requestScope.PRODUCT.id}" />
                                                
                                                <div class="mb-3">
                                                    <label class="form-label fw-bold text-uppercase text-muted" style="font-size: 0.75rem; letter-spacing: 0.5px;">Đánh giá sao</label>
                                                    <select name="rating" class="form-select" style="border-radius: 10px; padding: 0.6rem;" required>
                                                        <option value="" disabled selected>-- Chọn mức độ hài lòng --</option>
                                                        <option value="5">5 sao (Rất hài lòng)</option>
                                                        <option value="4">4 sao (Hài lòng)</option>
                                                        <option value="3">3 sao (Bình thường)</option>
                                                        <option value="2">2 sao (Không hài lòng)</option>
                                                        <option value="1">1 sao (Tệ)</option>
                                                    </select>
                                                </div>
                                                
                                                <div class="mb-3">
                                                    <label class="form-label fw-bold text-uppercase text-muted" style="font-size: 0.75rem; letter-spacing: 0.5px;">Nội dung nhận xét</label>
                                                    <textarea name="comment" rows="4" class="form-control" placeholder="Chia sẻ cảm nhận của bạn về sản phẩm..." style="border-radius: 10px; padding: 0.6rem; font-size: 0.92rem;" required></textarea>
                                                </div>
                                                
                                                <button type="submit" name="action" value="AddReview" class="btn-submit-review w-100">
                                                    <i class="fas fa-paper-plane me-2"></i> Gửi đánh giá
                                                </button>
                                            </form>
                                        </c:when>
                                        <c:otherwise>
                                            <div class="text-center py-4">
                                                <i class="fas fa-lock text-muted mb-3" style="font-size: 2rem;"></i>
                                                <p class="text-muted" style="font-size: 0.92rem;">Vui lòng <a href="dang-nhap" class="fw-bold" style="color: #00c853; text-decoration: none;">Đăng nhập</a> để viết đánh giá cho sản phẩm này.</p>
                                            </div>
                                        </c:otherwise>
                                    </c:choose>
                                </div>
                            </div>
                            
                            <%-- RIGHT: REVIEWS LIST --%>
                            <div class="col-md-7">
                                <h5 class="fw-bold mb-3" style="font-size: 1.1rem; color: #1f2937;">Khách hàng nói gì?</h5>
                                
                                <div class="review-list-container" style="max-height: 400px; overflow-y: auto; padding-right: 5px;">
                                    <c:choose>
                                        <c:when test="${not empty requestScope.REVIEWS}">
                                            <c:forEach var="rev" items="${requestScope.REVIEWS}">
                                                <div class="review-item">
                                                    <div class="d-flex align-items-start gap-3">
                                                        <%-- Avatar circle --%>
                                                        <div class="review-avatar flex-shrink-0">
                                                            <i class="fas fa-user"></i>
                                                        </div>
                                                        
                                                        <div class="flex-grow-1">
                                                            <div class="d-flex justify-content-between align-items-baseline flex-wrap">
                                                                <h6 class="fw-bold mb-1 text-dark" style="font-size: 0.95rem;">${rev.fullName}</h6>
                                                                <small class="text-muted" style="font-size: 0.78rem;">
                                                                    <fmt:formatDate value="${rev.createdAt}" pattern="yyyy-MM-dd HH:mm:ss" />
                                                                </small>
                                                            </div>
                                                            
                                                            <div class="mb-2">
                                                                <%-- Draw stars --%>
                                                                <c:forEach begin="1" end="${rev.rating}">
                                                                    <i class="fas fa-star rating-stars"></i>
                                                                </c:forEach>
                                                                <c:forEach begin="1" end="${5 - rev.rating}">
                                                                    <i class="far fa-star rating-stars-empty"></i>
                                                                </c:forEach>
                                                            </div>
                                                            
                                                            <p class="text-muted mb-0" style="font-size: 0.92rem; line-height: 1.5; white-space: pre-line;">
                                                                ${rev.commentText}
                                                            </p>
                                                        </div>
                                                    </div>
                                                </div>
                                            </c:forEach>
                                        </c:when>
                                        <c:otherwise>
                                            <div class="text-center py-5">
                                                <i class="far fa-comments text-muted mb-3" style="font-size: 2.5rem;"></i>
                                                <p class="text-muted mb-0" style="font-size: 0.92rem;">Sản phẩm này chưa có đánh giá nào. Hãy là người đầu tiên nhận xét!</p>
                                            </div>
                                        </c:otherwise>
                                    </c:choose>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

        </div>

        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
                        <script>
            /* ── Quantity stepper ── */
            var maxQty = parseInt("${requestScope.PRODUCT.quantity}") || 1;
            function changeQty(delta) {
                var input = document.getElementById('qtyInput');
                var val = parseInt(input.value) + delta;
                if (val < 1) val = 1;
                if (val > maxQty) val = maxQty;
                input.value = val;
            }

            /* ── Wishlist heart toggle ── */
            var wishBtn = document.querySelector('.btn-wishlist');
            if (wishBtn) {
                wishBtn.addEventListener('mouseenter', function () {
                    var icon = this.querySelector('i');
                    if (icon) icon.className = 'fas fa-heart';
                });
                wishBtn.addEventListener('mouseleave', function () {
                    var icon = this.querySelector('i');
                    if (icon) icon.className = 'far fa-heart';
                });
            }



            // Hide Expand button if description text is short
            document.addEventListener("DOMContentLoaded", function() {
                var content = document.getElementById('descContent');
                var btn = document.getElementById('btnToggleDesc');
                var overlay = document.getElementById('descOverlay');
                if (content) {
                    if (content.scrollHeight <= 120) {
                        content.style.maxHeight = 'none';
                        if (btn) btn.style.display = 'none';
                        if (overlay) overlay.style.display = 'none';
                    }
                }
            });
        </script>
    
    <!-- Description Detail Modal -->
    <div class="modal fade" id="descriptionModal" tabindex="-1" aria-labelledby="descriptionModalLabel" aria-hidden="true">
        <div class="modal-dialog modal-dialog-centered modal-dialog-scrollable modal-lg">
            <div class="modal-content rounded-4 border-0 shadow-lg" style="background: #ffffff; color: #111827;">
                <div class="modal-header border-0 pb-0" style="padding: 1.8rem 1.8rem 0.5rem 1.8rem;">
                    <h5 class="modal-title fw-bold text-dark" id="descriptionModalLabel" style="font-size: 1.3rem;">
                        <i class="fas fa-info-circle me-2" style="color: #00c853;"></i>Mô tả sản phẩm chi tiết
                    </h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close" style="box-shadow: none;"></button>
                </div>
                <div class="modal-body" style="padding: 1rem 1.8rem 1.8rem 1.8rem;">
                    <h4 class="fw-bold mb-3" style="font-size: 1.2rem; color: #00c853;">${requestScope.PRODUCT.name}</h4>
                    <div style="font-size: 0.95rem; color: #374151; line-height: 1.9; white-space: pre-line;">
                        ${requestScope.PRODUCT.description}
                    </div>
                </div>
                <div class="modal-footer border-0 pt-0" style="padding: 0 1.8rem 1.8rem 1.8rem;">
                    <button type="button" class="btn btn-secondary px-4 py-2" data-bs-dismiss="modal" style="border-radius: 10px; font-weight: 700; font-size: 0.9rem; background: #6c757d; border: none;">Đóng</button>
                </div>
            </div>
        </div>
    </div>

    <jsp:include page="includes/footer.jsp" />
</body>
</html>

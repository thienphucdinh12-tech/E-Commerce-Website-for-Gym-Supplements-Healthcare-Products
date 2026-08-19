<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<!DOCTYPE html>
<html lang="en">
    <head>
        <title>NutriOverflow &mdash; Cửa hàng Thể hình &amp; Sức khỏe</title>
        <jsp:include page="includes/header.jsp" />
        <style>
            /* ── Category columns: 4 per row on md+ ── */
            .col-lg-cat {
                flex: 0 0 auto;
                width: 12.5%; /* 8 items ÷1 row on lg */
            }
            @media (max-width: 991.98px) { .col-lg-cat { width: 25%; } }
            @media (max-width: 575.98px)  { .col-lg-cat { width: 33.333%; } }

            /* ── Category card base ── */
            .category-card {
                background: #fff;
                border-radius: 12px;
                border: 1.5px solid #e5e7eb;
                transition: all 0.28s cubic-bezier(0.34,1.56,0.64,1);
                cursor: pointer;
                display: flex;
                flex-direction: column;
                align-items: center;
                justify-content: center;
                padding: 18px 10px;
                min-height: 92px;
                position: relative;
                overflow: hidden;
            }
            .category-card::before {
                content: '';
                position: absolute;
                inset: 0;
                background: linear-gradient(135deg, rgba(0,230,118,0.06), rgba(0,230,118,0.02));
                opacity: 0;
                transition: opacity 0.28s ease;
            }
            .category-card:hover {
                transform: translateY(-6px) scale(1.03);
                box-shadow: 0 14px 32px rgba(0,230,118,0.20), 0 2px 8px rgba(0,0,0,0.06) !important;
                border-color: var(--brand) !important;
                background: #f6fffb !important;
            }
            .category-card:hover::before { opacity: 1; }
            .category-card:hover .cat-icon {
                color: var(--brand) !important;
                transform: translateY(-3px) scale(1.18);
                filter: drop-shadow(0 4px 8px rgba(0,230,118,0.35));
            }
            .category-card:hover .cat-label {
                color: var(--brand-dark, #00c853) !important;
                font-weight: 800 !important;
            }

            /* ── Active (selected) category ── */
            .cat-active {
                border-color: var(--brand) !important;
                background: linear-gradient(135deg, #f0fff8, #ffffff) !important;
                box-shadow: 0 6px 18px rgba(0,230,118,0.20) !important;
            }
            .cat-active .cat-label { color: var(--brand-dark, #00c853) !important; font-weight: 800 !important; }
            .cat-active .cat-icon { color: var(--brand) !important; }

            /* Icon transition */
            .cat-icon {
                transition: color 0.25s ease, transform 0.28s cubic-bezier(0.34,1.56,0.64,1), filter 0.25s ease;
                font-size: 1.6rem;
                margin-bottom: 8px !important;
                position: relative; z-index: 1;
            }
            .cat-label {
                font-size: 0.82rem; font-weight: 700; color: #374151; margin: 0;
                white-space: nowrap; position: relative; z-index: 1;
                transition: color 0.25s ease, font-weight 0.1s ease;
            }
        </style>
    </head>
    <body>
        <jsp:include page="includes/navbar.jsp" />

        <%-- ══════════════════ DYNAMIC BANNER SLIDESHOW ══════════════════ --%>
        <style>
            /* ══════════════════════════════════
               HERO BANNER — BACKGROUND-IMAGE SLIDESHOW
               Như ban đầu, không chữ, có overlay nhẹ
            ══════════════════════════════════ */
            .hero-slider {
                position: relative;
                width: 100%;
                min-height: 500px;
                overflow: hidden;
                background: #080b12;
            }
            .hero-slides-track {
                position: relative;
                width: 100%;
                height: 100%;
            }
            .hero-slide {
                position: absolute;
                inset: 0;
                min-height: 500px;
                opacity: 0;
                visibility: hidden;
                transition: opacity 0.9s ease, visibility 0.9s ease;
                z-index: 1;
            }
            .hero-slide.active {
                opacity: 1;
                visibility: visible;
                z-index: 2;
            }

            /* Ảnh nền — lấp đầy màn hình với ảnh ngang mới */
            .hero-slide-bg {
                position: absolute;
                inset: 0;
                background-size: cover;
                background-position: center;
                background-repeat: no-repeat;
                transform: scale(1.05);
                transition: transform 8s ease;
            }
            .hero-slide.active .hero-slide-bg {
                transform: scale(1.0);
            }

            /* Overlay tối nhẹ — chỉ để tăng độ tương phản nhẹ */
            .hero-slide-overlay {
                position: absolute;
                inset: 0;
            }

            /* Link bao phủ toàn bộ slide để click được */
            .slide-click-area {
                position: absolute;
                inset: 0;
                z-index: 3;
                display: block;
                cursor: pointer;
            }

            /* ── Arrows ── */
            .slider-arrow {
                position: absolute;
                top: 50%; z-index: 10;
                transform: translateY(-50%);
                background: rgba(255,255,255,0.08);
                border: 1.5px solid rgba(255,255,255,0.18);
                color: #fff;
                width: 44px; height: 44px;
                border-radius: 50%;
                display: flex; align-items: center; justify-content: center;
                font-size: 1rem;
                cursor: pointer;
                transition: all 0.25s ease;
                backdrop-filter: blur(8px);
                -webkit-backdrop-filter: blur(8px);
                z-index: 11;
            }
            .slider-arrow:hover {
                background: rgba(0,230,118,0.25);
                border-color: rgba(0,230,118,0.6);
                color: #00e676;
                box-shadow: 0 0 18px rgba(0,230,118,0.3);
                transform: translateY(-50%) scale(1.08);
            }
            .slider-prev { left: 18px; }
            .slider-next { right: 18px; }

            /* ── Dot Indicators ── */
            .slider-dots {
                position: absolute;
                bottom: 20px; left: 50%;
                transform: translateX(-50%);
                display: flex; gap: 10px;
                z-index: 10;
                background: rgba(0,0,0,0.25);
                padding: 6px 12px;
                border-radius: 30px;
                backdrop-filter: blur(6px);
            }
            .slider-dot {
                width: 10px; height: 10px;
                border-radius: 50%;
                background: rgba(255,255,255,0.50);
                border: 1.5px solid rgba(255,255,255,0.30);
                cursor: pointer;
                padding: 0;
                transition: all 0.35s cubic-bezier(0.34,1.56,0.64,1);
            }
            .slider-dot:hover { background: rgba(255,255,255,0.80); transform: scale(1.2); }
            .slider-dot.active {
                background: #00e676;
                width: 28px;
                border-radius: 5px;
                border-color: #00e676;
                box-shadow: 0 0 12px rgba(0,230,118,0.7);
            }

            /* ── Progress Bar ── */
            .slider-progress {
                position: absolute;
                bottom: 0; left: 0;
                height: 3px;
                background: linear-gradient(90deg, #00e676, #00c853);
                z-index: 10;
                width: 0%;
                box-shadow: 0 0 8px rgba(0,230,118,0.5);
            }

            @media (max-width: 768px) {
                .hero-slider { min-height: 360px; }
                .hero-slide  { min-height: 360px; }
                .slider-arrow { width: 36px; height: 36px; font-size: 0.85rem; }
                .slider-prev { left: 10px; }
                .slider-next { right: 10px; }
            }
        </style>

        <div id="home" class="hero-slider" style="min-height:500px;">
            <div class="hero-slides-track" id="heroBannerTrack" style="min-height:500px;">

                <%-- ── SLIDE 1: Whey Protein --%>
                <div class="hero-slide active" id="heroSlide0">
                    <div class="hero-slide-bg"
                         style="background-image: url('banner/banner_whey_protein.png');"></div>
                    <div class="hero-slide-overlay"
                         style="background: linear-gradient(135deg, rgba(0,0,0,0.15) 0%, rgba(0,0,0,0.05) 100%);"></div>
                    <a href="cua-hang?category=1" class="slide-click-area" aria-label="Xem Whey Protein"></a>
                </div>

                <%-- ── SLIDE 2: Free Shipping --%>
                <div class="hero-slide" id="heroSlide1">
                    <div class="hero-slide-bg"
                         style="background-image: url('banner/banner_free_ship.png');"></div>
                    <div class="hero-slide-overlay"
                         style="background: linear-gradient(135deg, rgba(0,0,0,0.15) 0%, rgba(0,0,0,0.05) 100%);"></div>
                    <a href="cua-hang" class="slide-click-area" aria-label="Miễn phí vận chuyển"></a>
                </div>

                <%-- ── SLIDE 3: Khuyến Mãi --%>
                <div class="hero-slide" id="heroSlide2">
                    <div class="hero-slide-bg"
                         style="background-image: url('banner/banner_promo.png');"></div>
                    <div class="hero-slide-overlay"
                         style="background: linear-gradient(135deg, rgba(0,0,0,0.15) 0%, rgba(0,0,0,0.05) 100%);"></div>
                    <a href="cua-hang" class="slide-click-area" aria-label="Khuyến mãi đặc biệt"></a>
                </div>

            </div><%-- /hero-slides-track --%>

            <%-- Arrows --%>
            <button class="slider-arrow slider-prev" id="heroPrev" aria-label="Slide trước">
                <i class="fas fa-chevron-left"></i>
            </button>
            <button class="slider-arrow slider-next" id="heroNext" aria-label="Slide tiếp theo">
                <i class="fas fa-chevron-right"></i>
            </button>

            <%-- Dots --%>
            <div class="slider-dots" id="sliderDots">
                <button class="slider-dot active" data-index="0" aria-label="Slide 1"></button>
                <button class="slider-dot"        data-index="1" aria-label="Slide 2"></button>
                <button class="slider-dot"        data-index="2" aria-label="Slide 3"></button>
            </div>

            <%-- Progress bar --%>
            <div class="slider-progress" id="sliderProgress"></div>
        </div>

        <script>
        (function () {
            var TOTAL       = 3;
            var INTERVAL_MS = 5000;   // 5 giây mỗi slide
            var current     = 0;
            var timer       = null;
            var rafId       = null;
            var progStart   = null;
            var paused      = false;
            var pausedAt    = 0;      // thời gian đã trôi qua khi pause

            var slides   = document.querySelectorAll('#heroBannerTrack .hero-slide');
            var dots     = document.querySelectorAll('.slider-dot');
            var progress = document.getElementById('sliderProgress');

            /* ─────────────────────────────────────
               goTo: chuyển đến slide idx
               Crossfade thuần opacity — không track movement
               → loop 1→2→3→1 tuyệt đối mượt
            ───────────────────────────────────── */
            function goTo(idx) {
                if (idx === current) return;

                slides[current].classList.remove('active');
                dots[current].classList.remove('active');

                current = ((idx % TOTAL) + TOTAL) % TOTAL;

                slides[current].classList.add('active');
                dots[current].classList.add('active');

                restartProgress();
            }

            function next() { goTo(current + 1); }
            function prev() { goTo(current - 1); }

            /* ─── Auto-play ─── */
            function startAuto() {
                if (timer) return;
                timer = setInterval(next, INTERVAL_MS);
            }
            function stopAuto() {
                clearInterval(timer);
                timer = null;
            }

            /* ─── Progress bar (requestAnimationFrame) ─── */
            function restartProgress() {
                cancelAnimationFrame(rafId);
                progStart  = null;
                pausedAt   = 0;
                progress.style.transition = 'none';
                progress.style.width      = '0%';
                /* Đợi 1 frame để browser apply width=0 trước khi animate */
                requestAnimationFrame(function () {
                    if (!paused) tickProgress(performance.now());
                });
            }

            function tickProgress(ts) {
                if (progStart === null) progStart = ts;
                var elapsed = ts - progStart + pausedAt;
                var pct     = Math.min(elapsed / INTERVAL_MS * 100, 100);
                progress.style.width = pct + '%';
                if (pct < 100) {
                    rafId = requestAnimationFrame(tickProgress);
                }
            }

            /* ─── Pause / Resume (giữ đúng elapsed time) ─── */
            function pauseAll() {
                paused   = true;
                pausedAt = progStart !== null ? (performance.now() - progStart + pausedAt) : 0;
                cancelAnimationFrame(rafId);
                stopAuto();
            }
            function resumeAll() {
                paused    = false;
                progStart = null;   // sẽ set lại trong tickProgress
                rafId = requestAnimationFrame(tickProgress);
                startAuto();
            }

            /* ─── Arrows ─── */
            document.getElementById('heroNext').addEventListener('click', function () {
                stopAuto(); next(); startAuto();
            });
            document.getElementById('heroPrev').addEventListener('click', function () {
                stopAuto(); prev(); startAuto();
            });

            /* ─── Dots ─── */
            dots.forEach(function (dot) {
                dot.addEventListener('click', function () {
                    var idx = parseInt(this.getAttribute('data-index'), 10);
                    stopAuto(); goTo(idx); startAuto();
                });
            });

            /* ─── Hover pause ─── */
            var slider = document.getElementById('home');
            slider.addEventListener('mouseenter', pauseAll);
            slider.addEventListener('mouseleave', resumeAll);

            /* ─── Touch / Swipe ─── */
            var touchX = 0;
            slider.addEventListener('touchstart', function (e) {
                touchX = e.touches[0].clientX;
                pauseAll();
            }, { passive: true });
            slider.addEventListener('touchend', function (e) {
                var diff = touchX - e.changedTouches[0].clientX;
                if (Math.abs(diff) > 45) {
                    if (diff > 0) next(); else prev();
                }
                resumeAll();
            }, { passive: true });

            /* ─── Khởi động ─── */
            startAuto();
            restartProgress();
        })();
        </script>
        <%-- ══════════════════ END BANNER SLIDESHOW ══════════════════ --%>

        <div class="container mb-3 mt-4">
            <h2 class="section-heading mb-3" style="font-size:1.1rem;">Mua sắm theo danh mục</h2>
            <div class="row g-2 justify-content-center text-center">

                <%-- All Products --%>
                <div class="col-3 col-sm-3 col-md-3">
                    <a href="cua-hang" class="text-decoration-none">
                        <div class="category-card ${empty param.category and empty param.txtSearch ? 'cat-active' : ''}">
                            <i class="fas fa-th-large cat-icon ${empty param.category and empty param.txtSearch ? 'text-brand' : 'text-secondary'}"></i>
                            <p class="cat-label">Tất cả sản phẩm</p>
                        </div>
                    </a>
                </div>

                <%-- Protein --%>
                <div class="col-3 col-sm-3 col-md-3">
                    <a href="cua-hang?category=1" class="text-decoration-none">
                        <div class="category-card ${'1'.equals(param.category) ? 'cat-active' : ''}">
                            <i class="fas fa-dna cat-icon ${'1'.equals(param.category) ? 'text-brand' : 'text-secondary'}"></i>
                            <p class="cat-label">Đạm / Whey</p>
                        </div>
                    </a>
                </div>

                <%-- Mass Gainer --%>
                <div class="col-3 col-sm-3 col-md-3">
                    <a href="cua-hang?category=2" class="text-decoration-none">
                        <div class="category-card ${'2'.equals(param.category) ? 'cat-active' : ''}">
                            <i class="fas fa-weight-hanging cat-icon ${'2'.equals(param.category) ? 'text-brand' : 'text-secondary'}"></i>
                            <p class="cat-label">Sữa tăng cân</p>
                        </div>
                    </a>
                </div>

                <%-- Pre-Workout --%>
                <div class="col-3 col-sm-3 col-md-3">
                    <a href="cua-hang?category=3" class="text-decoration-none">
                        <div class="category-card ${'3'.equals(param.category) ? 'cat-active' : ''}">
                            <i class="fas fa-bolt cat-icon ${'3'.equals(param.category) ? 'text-brand' : 'text-secondary'}"></i>
                            <p class="cat-label">Tăng sức mạnh</p>
                        </div>
                    </a>
                </div>

                <%-- Diet Food --%>
                <div class="col-3 col-sm-3 col-md-3">
                    <a href="cua-hang?category=4" class="text-decoration-none">
                        <div class="category-card ${'4'.equals(param.category) ? 'cat-active' : ''}">
                            <i class="fas fa-leaf cat-icon ${'4'.equals(param.category) ? 'text-brand' : 'text-secondary'}"></i>
                            <p class="cat-label">Đồ ăn kiêng</p>
                        </div>
                    </a>
                </div>

                <%-- Fat Burner --%>
                <div class="col-3 col-sm-3 col-md-3">
                    <a href="cua-hang?category=5" class="text-decoration-none">
                        <div class="category-card ${'5'.equals(param.category) ? 'cat-active' : ''}">
                            <i class="fas fa-fire-alt cat-icon ${'5'.equals(param.category) ? 'text-brand' : 'text-secondary'}"></i>
                            <p class="cat-label">Đốt mỡ</p>
                        </div>
                    </a>
                </div>

                <%-- Vitamin --%>
                <div class="col-3 col-sm-3 col-md-3">
                    <a href="cua-hang?category=6" class="text-decoration-none">
                        <div class="category-card ${'6'.equals(param.category) ? 'cat-active' : ''}">
                            <i class="fas fa-capsules cat-icon ${'6'.equals(param.category) ? 'text-brand' : 'text-secondary'}"></i>
                            <p class="cat-label">Vitamin</p>
                        </div>
                    </a>
                </div>

                <%-- Snack --%>
                <div class="col-3 col-sm-3 col-md-3">
                    <a href="cua-hang?category=7" class="text-decoration-none">
                        <div class="category-card ${'7'.equals(param.category) ? 'cat-active' : ''}">
                            <i class="fas fa-cookie-bite cat-icon ${'7'.equals(param.category) ? 'text-brand' : 'text-secondary'}"></i>
                            <p class="cat-label">Snack / Bánh</p>
                        </div>
                    </a>
                </div>

            </div>
        </div>

        <%-- ===== BEST SELLERS SECTION ===== --%>
        <c:if test="${not empty requestScope.BEST_SELLERS}">
        <div class="container mb-5">
            <div class="d-flex align-items-center gap-3 mb-4">
                <div class="bestseller-badge-title">
                    <span class="fire-icon">&#128293;</span>
                    <h3 class="mb-0 fw-bold d-inline">SẢN PHẨM BÁN CHẠY</h3>
                </div>
                <div class="flex-grow-1" style="height:2px; background: linear-gradient(90deg, #ff6b35, #ff6b3500);"></div>
            </div>

            <%-- Wrapper với nút mũi tên --%>
            <div class="bs-slider-container">
                <button class="bs-arrow bs-arrow-left" onclick="slideBestSeller(-1)" id="bsArrowLeft">
                    <i class="fas fa-chevron-left"></i>
                </button>

                <div class="bs-viewport" id="bsViewport">
                    <div class="bestseller-track" id="bsTrack">
                        <c:forEach var="p" items="${requestScope.BEST_SELLERS}" varStatus="s">
                            <a href="san-pham?id=${p.id}" class="text-decoration-none text-dark bestseller-card-link">
                                <div class="bestseller-card">
                                    <div class="bestseller-rank">#${s.index + 1}</div>
                                    <c:if test="${s.index == 0}">
                                        <div class="bestseller-crown">👑</div>
                                    </c:if>
                                     <div class="bestseller-img-wrap">
                                         <c:choose>
                                             <c:when test="${not empty p.imageUrl and p.imageUrl != 'default-product.jpg'}">
                                                 <img src="image/${p.imageUrl}" style="max-height:100%;max-width:100%;object-fit:contain;" alt="${p.name}"/>
                                             </c:when>
                                             <c:otherwise>
                                                 <i class="fas fa-prescription-bottle-alt fa-4x text-secondary"></i>
                                             </c:otherwise>
                                         </c:choose>
                                     </div>
                                    <div class="bestseller-info">
                                        <p class="bestseller-name" title="${p.name}">${p.name}</p>
                                        <c:choose>
                                            <c:when test="${p.discountPrice != null && p.discountPrice > 0}">
                                                <p class="bestseller-price">${String.format("%,.0f", p.discountPrice)} &#273;</p>
                                                <div style="display:flex;align-items:center;gap:5px;justify-content:center;margin-top:2px;">
                                                    <span style="font-size:0.72rem;color:#9ca3af;text-decoration:line-through;">${String.format("%,.0f", p.price)}&#273;</span>
                                                    <span style="background:#e53935;color:#fff;font-size:0.62rem;font-weight:800;border-radius:4px;padding:1px 5px;">-${p.discountPercent}%</span>
                                                </div>
                                            </c:when>
                                            <c:otherwise>
                                                <p class="bestseller-price">${String.format("%,.0f", p.price)} &#273;</p>
                                            </c:otherwise>
                                        </c:choose>
                                    </div>
                                    <div class="bestseller-footer">
                                        <span class="badge-hot">&#128293; BÁN CHẠY</span>
                                    </div>
                                </div>
                            </a>
                        </c:forEach>
                    </div>
                </div>

                <button class="bs-arrow bs-arrow-right" onclick="slideBestSeller(1)" id="bsArrowRight">
                    <i class="fas fa-chevron-right"></i>
                </button>
            </div>
        </div>
        </c:if>

        <%-- ===== FLASH SALE / SALE SỐC SECTION ===== --%>
        <c:if test="${not empty requestScope.FLASH_SALE_LIST}">
        <div class="container mb-5" id="flash-sale-section">
            <%-- Header - đồng bộ cấu trúc với Best Sellers --%>
            <div class="d-flex align-items-center gap-3 mb-4">
                <div class="bestseller-badge-title">
                    <span style="font-size: 1.8rem;">&#9889;</span>
                    <h3 class="mb-0 fw-bold d-inline" style="background: linear-gradient(90deg, var(--brand-dark), #e53935); -webkit-background-clip: text; -webkit-text-fill-color: transparent; background-clip: text;">SALE SỐC</h3>
                </div>
                <div class="flex-grow-1" style="height:2px; background: linear-gradient(90deg, var(--brand), rgba(0,230,118,0));"></div>
            </div>

            <%-- Slider giống Best Sellers --%>
            <div class="bs-slider-container">
                <button class="bs-arrow bs-arrow-left flash-arrow" onclick="slideFlashSale(-1)" id="fsArrowLeft">
                    <i class="fas fa-chevron-left"></i>
                </button>

                <div class="bs-viewport" id="fsViewport">
                    <div class="bestseller-track" id="fsTrack">
                        <c:forEach var="p" items="${requestScope.FLASH_SALE_LIST}">
                            <a href="san-pham?id=${p.id}" class="text-decoration-none text-dark bestseller-card-link">
                                <div class="flash-sale-card">
                                    <%-- Ảnh sản phẩm --%>
                                    <div class="flash-img-wrap">
                                        <c:choose>
                                            <c:when test="${not empty p.imageUrl and p.imageUrl != 'default-product.jpg'}">
                                                <img src="image/${p.imageUrl}" style="max-height:100%;max-width:100%;object-fit:contain;" alt="${p.name}"/>
                                            </c:when>
                                            <c:otherwise>
                                                <i class="fas fa-prescription-bottle-alt fa-4x text-secondary"></i>
                                            </c:otherwise>
                                        </c:choose>
                                        <div class="flash-shimmer"></div>
                                    </div>

                                    <%-- Body --%>
                                    <div class="flash-body">
                                        <p class="flash-name" title="${p.name}">${p.name}</p>

                                        <%-- Giá --%>
                                        <div class="flash-price-row">
                                            <c:choose>
                                                <c:when test="${p.discountPrice != null && p.discountPrice > 0}">
                                                    <span class="flash-price-sale">${String.format("%,.0f", p.discountPrice)}&#273;</span>
                                                    <div class="flash-price-original-wrap" style="display:flex;align-items:center;gap:5px;justify-content:center;margin-top:2px;">
                                                        <span class="flash-price-original" style="font-size:0.72rem;color:#9ca3af;text-decoration:line-through;">${String.format("%,.0f", p.price)}&#273;</span>
                                                        <span class="flash-pct-inline" style="background:#e53935;color:#fff;font-size:0.62rem;font-weight:800;border-radius:4px;padding:1px 5px;">-${p.discountPercent}%</span>
                                                    </div>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="flash-price-sale">${String.format("%,.0f", p.price)}&#273;</span>
                                                </c:otherwise>
                                            </c:choose>
                                        </div>
                                    </div>

                                    <%-- Footer đồng bộ với Best Sellers --%>
                                    <div class="bestseller-footer">
                                        <span class="badge-flash">&#9889; SALE SỐC</span>
                                    </div>
                                </div>
                            </a>
                        </c:forEach>
                    </div>
                </div>

                <button class="bs-arrow bs-arrow-right flash-arrow" onclick="slideFlashSale(1)" id="fsArrowRight">
                    <i class="fas fa-chevron-right"></i>
                </button>
            </div>
        </div>
        </c:if>

        <style>
            /* ===== BEST SELLERS STYLES ===== */
            .bestseller-badge-title { display: flex; align-items: center; gap: 10px; }
            .fire-icon { font-size: 2rem; animation: fireFlicker 1.2s infinite alternate; }
            @keyframes fireFlicker {
                0%   { transform: scale(1) rotate(-5deg); }
                100% { transform: scale(1.15) rotate(5deg); }
            }

            /* Wrapper bao ngoài (chứa cả viewport + 2 nút) */
            .bs-slider-container {
                position: relative;
                display: flex;
                align-items: center;
                gap: 0;
            }

            /* Nút mũi tên — đồng nhất màu brand xanh neon */
            .bs-arrow {
                flex-shrink: 0;
                width: 44px;
                height: 44px;
                border-radius: 50%;
                border: 2px solid rgba(0,230,118,0.40);
                background: rgba(0,230,118,0.10);
                color: var(--brand);
                font-size: 1rem;
                cursor: pointer;
                box-shadow: 0 4px 14px rgba(0,230,118,0.18);
                transition: all 0.25s cubic-bezier(0.34,1.56,0.64,1);
                z-index: 10;
                display: flex; align-items: center; justify-content: center;
                backdrop-filter: blur(4px);
            }
            .bs-arrow:hover {
                background: var(--brand);
                color: #0a0a0a;
                border-color: var(--brand);
                transform: scale(1.12);
                box-shadow: 0 6px 22px rgba(0,230,118,0.45);
            }
            .bs-arrow:disabled, .bs-arrow.hidden { opacity: 0.25; pointer-events: none; }
            .bs-arrow-left  { margin-right: 12px; }
            .bs-arrow-right { margin-left: 12px; }

            /* Viewport: che phần overflow, KHÔNG hiện thanh kéo */
            .bs-viewport {
                flex: 1;
                overflow: hidden;
            }

            /* Track thực tế chứa các card, dịch chuyển bằng JS */
            .bestseller-track {
                display: flex;
                gap: 24px;
                padding: 12px 6px 18px;
                transition: transform 0.4s cubic-bezier(0.25, 0.8, 0.25, 1);
                will-change: transform;
            }
            .bestseller-card-link { flex-shrink: 0; }

            /* Card Best Sellers và Flash Sale đồng bộ kích thước và thiết kế */
            .bestseller-card, .flash-sale-card {
                position: relative;
                width: 220px;
                height: 330px;
                background: #fff;
                border-radius: 20px;
                box-shadow: 0 4px 20px rgba(0,0,0,0.04);
                border: 1.5px solid #e5e7eb;
                padding: 22px 16px 16px;
                transition: transform 0.28s ease, box-shadow 0.28s ease, border-color 0.28s ease;
                cursor: pointer;
                overflow: hidden;
                display: flex;
                flex-direction: column;
                justify-content: space-between;
                box-sizing: border-box;
                text-align: center;
            }
            .bestseller-card:hover {
                transform: translateY(-8px) scale(1.02);
                box-shadow: 0 14px 36px rgba(0,230,118,0.20), 0 4px 12px rgba(0,0,0,0.08);
                border-color: var(--brand);
            }
            .flash-sale-card:hover {
                transform: translateY(-8px) scale(1.02);
                box-shadow: 0 14px 36px rgba(0,230,118,0.22), 0 4px 12px rgba(0,0,0,0.08);
                border-color: var(--brand);
            }
            .bestseller-rank {
                position: absolute;
                top: 12px; left: 14px;
                font-size: 0.75rem; font-weight: 800;
                color: var(--brand-dark);
                background: rgba(0,230,118,0.12);
                border-radius: 8px;
                padding: 3px 9px;
                letter-spacing: 0.5px;
                z-index: 2;
            }
            .bestseller-crown {
                position: absolute;
                top: 10px; right: 12px;
                font-size: 1.2rem;
                z-index: 2;
            }
            .bestseller-img-wrap, .flash-img-wrap {
                height: 120px;
                display: flex; align-items: center; justify-content: center;
                border-radius: 14px;
                margin-bottom: 12px;
                position: relative;
                overflow: hidden;
                flex-shrink: 0;
            }
            .bestseller-img-wrap {
                background: linear-gradient(135deg, #f4fff9, #ffffff);
            }
            .flash-img-wrap {
                background: linear-gradient(135deg, #f0fff4, #fff);
            }
            .flash-shimmer {
                position: absolute; top: 0; left: -100%; width: 50%; height: 100%;
                background: linear-gradient(90deg, transparent, rgba(255,255,255,0.45), transparent);
                animation: shimmer 2.5s infinite;
            }
            @keyframes shimmer { 0%{left:-100%} 100%{left:200%} }

            .bestseller-name, .flash-name {
                font-size: 0.90rem;
                font-weight: 700;
                color: #1a1a2e;
                margin: 0 0 6px;
                display: -webkit-box;
                -webkit-line-clamp: 2;
                -webkit-box-orient: vertical;
                overflow: hidden;
                min-height: 42px;
                line-height: 1.5;
                letter-spacing: -0.1px;
            }
            .bestseller-price, .flash-price-sale {
                font-size: 1.05rem;
                font-weight: 900;
                color: #dc2626;
                margin: 0;
                line-height: 1.1;
            }
            .bestseller-footer { 
                margin-top: auto;
                display: flex;
                justify-content: center;
                align-items: center;
            }
            .badge-hot, .badge-flash {
                display: inline-block;
                font-size: 0.72rem;
                font-weight: 700;
                border-radius: 20px;
                padding: 4px 14px;
                letter-spacing: 0.5px;
            }
            .badge-hot {
                background: linear-gradient(90deg, var(--brand-dark), var(--brand));
                color: #0a0a0a;
                font-weight: 800;
            }
            .badge-flash {
                background: linear-gradient(90deg, var(--brand-dark), var(--brand));
                color: #0a0a0a;
                font-weight: 800;
            }
        </style>

        <script>
            /* ===== BEST SELLERS ARROW SLIDER ===== */
            (function () {
                const CARD_WIDTH = 220;  // phải khớp width trong CSS
                const GAP       = 20;
                const STEP      = CARD_WIDTH + GAP; // pixels mỗi lần bấm

                var currentOffset = 0;

                function updateArrows() {
                    var track    = document.getElementById('bsTrack');
                    var viewport = document.getElementById('bsViewport');
                    var btnL     = document.getElementById('bsArrowLeft');
                    var btnR     = document.getElementById('bsArrowRight');
                    if (!track || !viewport || !btnL || !btnR) return;

                    var maxOffset = track.scrollWidth - viewport.clientWidth;
                    if (maxOffset < 0) maxOffset = 0;

                    btnL.disabled = (currentOffset <= 0);
                    btnR.disabled = (currentOffset >= maxOffset);
                }

                window.slideBestSeller = function(dir) {
                    var track    = document.getElementById('bsTrack');
                    var viewport = document.getElementById('bsViewport');
                    if (!track || !viewport) return;

                    var maxOffset = track.scrollWidth - viewport.clientWidth;
                    if (maxOffset < 0) maxOffset = 0;

                    currentOffset += dir * STEP;
                    if (currentOffset < 0)         currentOffset = 0;
                    if (currentOffset > maxOffset) currentOffset = maxOffset;

                    track.style.transform = 'translateX(-' + currentOffset + 'px)';
                    updateArrows();
                };

                // Khởi tạo trạng thái nút khi load trang
                document.addEventListener('DOMContentLoaded', function () {
                    updateArrows();
                    // Cũng cập nhật lại khi resize
                    window.addEventListener('resize', function() {
                        // Reset về đầu khi resize để tránh lệch
                        currentOffset = 0;
                        var track = document.getElementById('bsTrack');
                        if (track) track.style.transform = 'translateX(0)';
                        updateArrows();
                    });
                });
            })();

            /* ===== FLASH SALE ARROW SLIDER ===== */
            (function () {
                const CARD_WIDTH = 220;
                const GAP       = 20;
                const STEP      = CARD_WIDTH + GAP;

                var fsOffset = 0;

                function updateFsArrows() {
                    var track    = document.getElementById('fsTrack');
                    var viewport = document.getElementById('fsViewport');
                    var btnL     = document.getElementById('fsArrowLeft');
                    var btnR     = document.getElementById('fsArrowRight');
                    if (!track || !viewport || !btnL || !btnR) return;
                    var maxOffset = Math.max(0, track.scrollWidth - viewport.clientWidth);
                    btnL.disabled = (fsOffset <= 0);
                    btnR.disabled = (fsOffset >= maxOffset);
                }

                window.slideFlashSale = function(dir) {
                    var track    = document.getElementById('fsTrack');
                    var viewport = document.getElementById('fsViewport');
                    if (!track || !viewport) return;
                    var maxOffset = Math.max(0, track.scrollWidth - viewport.clientWidth);
                    fsOffset += dir * STEP;
                    if (fsOffset < 0)           fsOffset = 0;
                    if (fsOffset > maxOffset)   fsOffset = maxOffset;
                    track.style.transform = 'translateX(-' + fsOffset + 'px)';
                    updateFsArrows();
                };

                document.addEventListener('DOMContentLoaded', function () {
                    updateFsArrows();
                    window.addEventListener('resize', function() {
                        fsOffset = 0;
                        var t = document.getElementById('fsTrack');
                        if (t) t.style.transform = 'translateX(0)';
                        updateFsArrows();
                    });
                });
            })();

        </script>

        <div id="products" class="container pb-5 mt-4">
            <div class="d-flex align-items-center justify-content-between mb-3">
                <h2 class="section-heading" style="font-size:1.1rem;">Tất cả sản phẩm</h2>
                <span class="text-muted" style="font-size:0.8rem;">
                    <c:if test="${not empty requestScope.LIST_PRODUCT}">Tìm thấy ${requestScope.LIST_PRODUCT.size()} sản phẩm</c:if>
                </span>
            </div>
            <%-- SUCCESS MESSAGES MOVED TO GLOBAL TOAST IN FOOTER --%>

            <div class="row g-4 row-cols-2 row-cols-md-3 row-cols-lg-4 row-cols-xl-5" id="productGrid">
                <c:choose>
                    <c:when test="${not empty requestScope.LIST_PRODUCT}">
                        <c:forEach var="p" items="${requestScope.LIST_PRODUCT}">
                            <div class="col product-item-card">
                                <a href="san-pham?id=${p.id}" class="text-decoration-none text-dark">
                                    <div class="pcard-wrap" onmouseover="this.style.boxShadow='0 12px 36px rgba(0,230,118,0.16)';this.style.transform='translateY(-6px)';this.style.borderColor='rgba(0,230,118,0.40)';" onmouseout="this.style.boxShadow='none';this.style.transform='translateY(0)';this.style.borderColor='#ebebeb';" style="background:#fff;border-radius:14px;border:1px solid #ebebeb;overflow:hidden;height:100%;display:flex;flex-direction:column;transition:box-shadow 0.28s cubic-bezier(0.34,1.56,0.64,1),transform 0.28s cubic-bezier(0.34,1.56,0.64,1),border-color 0.28s ease;">

                                        <%-- Vùng ảnh full-width --%>
                                        <div style="position:relative;">
                                            <c:if test="${p.quantity == 0}">
                                                <div style="position:absolute;top:8px;right:8px;z-index:2;background:rgba(255,255,255,0.92);border:1px solid #ddd;color:#666;font-size:0.6rem;font-weight:600;border-radius:4px;padding:2px 7px;">tạm hết</div>
                                            </c:if>
                                            <c:if test="${p.flashSale}">
                                                <div style="position:absolute;top:8px;left:8px;z-index:2;background:linear-gradient(135deg,#ff2d2d,#ff6b35);color:#fff;font-size:0.58rem;font-weight:800;border-radius:20px;padding:2px 9px;letter-spacing:0.7px;">&#9889; SALE S&#7888;C</div>
                                            </c:if>
                                            <c:if test="${p.discountPercent > 0}">
                                                <div style="position:absolute;top:8px;right:8px;z-index:2;background:#e53935;color:#fff;font-size:0.62rem;font-weight:800;border-radius:4px;padding:2px 6px;">-${p.discountPercent}%</div>
                                            </c:if>
                                            <div style="height:170px;background:#fff;display:flex;align-items:center;justify-content:center;padding:14px;border-bottom:1px solid #f5f5f5;">
                                                <c:choose>
                                                    <c:when test="${not empty p.imageUrl and p.imageUrl != 'default-product.jpg'}">
                                                        <img src="image/${p.imageUrl}" style="max-height:100%;max-width:100%;object-fit:contain;" alt="${p.name}"/>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <i class="fas fa-prescription-bottle-alt fa-3x" style="color:#d1d5db;"></i>
                                                    </c:otherwise>
                                                </c:choose>
                                            </div>
                                        </div>

                                        <%-- Nội dung --%>
                                        <div style="padding:12px 14px 16px;flex:1;display:flex;flex-direction:column;">
                                            <%-- Tên sản phẩm: tăng font-weight và size để nổi bật hơn --%>
                                            <p style="font-size:0.87rem;font-weight:700;color:#1a2035;margin:0 0 10px;display:-webkit-box;-webkit-line-clamp:2;-webkit-box-orient:vertical;overflow:hidden;min-height:42px;line-height:1.5;letter-spacing:-0.1px;">${p.name}</p>
                                            <div style="margin-top:auto;">
                                                <c:choose>
                                                    <c:when test="${p.discountPrice != null && p.discountPrice > 0}">
                                                        <%-- Giá đổi sang màu đỏ --%>
                                                        <div style="font-size:1.02rem;font-weight:900;color:#dc2626;line-height:1.2;">${String.format("%,.0f", p.discountPrice)}&#273;</div>
                                                        <div style="display:flex;align-items:center;gap:5px;margin-top:4px;">
                                                            <span style="font-size:0.75rem;color:#9ca3af;text-decoration:line-through;">${String.format("%,.0f", p.price)}&#273;</span>
                                                            <span style="background:linear-gradient(90deg,#00c853,#00e676);color:#0a0a0a;font-size:0.6rem;font-weight:800;border-radius:4px;padding:2px 6px;">-${p.discountPercent}%</span>
                                                        </div>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <div style="font-size:1.02rem;font-weight:900;color:#dc2626;line-height:1.2;">${String.format("%,.0f", p.price)}&#273;</div>
                                                    </c:otherwise>
                                                </c:choose>
                                            </div>
                                        </div>

                                    </div>
                                </a>
                            </div>
                        </c:forEach>
                    </c:when>
                    <c:otherwise>
                        <div class="col-12 text-center py-5">
                            <i class="fas fa-box-open fa-4x text-muted mb-3 d-block"></i>
                            <h4 class="text-muted fw-600">Không tìm thấy sản phẩm nào.</h4>
                            <p class="text-muted" style="font-size:0.875rem;">Vui lòng chọn danh mục khác hoặc thử lại từ khóa khác.</p>
                            <a href="cua-hang" class="btn-brand text-decoration-none mt-2" style="padding:0.5rem 1.6rem; font-size:0.85rem;">Xem tất cả sản phẩm</a>
                        </div>
                    </c:otherwise>
                </c:choose>
            </div>
            
            <!-- Nút xem thêm -->
            <c:if test="${not empty requestScope.LIST_PRODUCT}">
                <div class="text-center mt-4" id="loadMoreContainer" style="display: none;">
                    <button class="btn btn-brand" id="btnLoadMore" onclick="showAllProducts()" style="font-size: 0.88rem; padding: 0.55rem 2rem;">
                        <i class="fas fa-arrow-down me-2"></i>Xem thêm sản phẩm
                    </button>
                </div>
            </c:if>
        </div>

        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
        
        <script>
        (function() {
            var hasLoadedMore = false;
            
            function checkProductRows() {
                if (hasLoadedMore) return;
                
                var grid = document.getElementById('productGrid');
                if (!grid) return;
                
                var items = grid.getElementsByClassName('product-item-card');
                if (items.length === 0) return;
                
                // Xác định số cột hiển thị dựa trên kích thước màn hình
                var cols = 2; // mặc định xs/sm
                var width = window.innerWidth;
                if (width >= 1200) {
                    cols = 5;
                } else if (width >= 992) {
                    cols = 4;
                } else if (width >= 768) {
                    cols = 3;
                }
                
                var maxVisible = cols * 3; // tối đa 3 hàng
                var btnContainer = document.getElementById('loadMoreContainer');
                
                if (items.length > maxVisible) {
                    // Ẩn các sản phẩm vượt quá 3 hàng
                    for (var i = 0; i < items.length; i++) {
                        if (i >= maxVisible) {
                            items[i].style.setProperty('display', 'none', 'important');
                        } else {
                            items[i].style.display = '';
                        }
                    }
                    if (btnContainer) btnContainer.style.display = 'block';
                } else {
                    // Hiện hết nếu không đủ 3 hàng
                    for (var i = 0; i < items.length; i++) {
                        items[i].style.display = '';
                    }
                    if (btnContainer) btnContainer.style.display = 'none';
                }
            }
            
            window.showAllProducts = function() {
                var grid = document.getElementById('productGrid');
                if (!grid) return;
                
                var items = grid.getElementsByClassName('product-item-card');
                for (var i = 0; i < items.length; i++) {
                    items[i].style.display = '';
                }
                
                var btnContainer = document.getElementById('loadMoreContainer');
                if (btnContainer) btnContainer.style.display = 'none';
                
                hasLoadedMore = true;
            };
            
            // Khởi chạy
            if (document.readyState === 'loading') {
                document.addEventListener('DOMContentLoaded', checkProductRows);
            } else {
                checkProductRows();
            }
            window.addEventListener('resize', checkProductRows);
        })();
        </script>
    
    <jsp:include page="includes/footer.jsp" />
</body>
</html>
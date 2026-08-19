<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn"%>

<nav class="navbar navbar-expand-lg navbar-custom sticky-top" id="mainNavbar">

    <!-- ══ DESKTOP HEADER (≥ 992px) ══ -->
    <div class="container d-none d-lg-flex align-items-center" style="gap: 10px; height: 68px; padding: 0 20px;">

        <!-- Sidebar Toggle -->
        <button class="btn sidebar-toggle-btn border-0" type="button"
                data-bs-toggle="offcanvas" data-bs-target="#leftSidebar"
                aria-controls="leftSidebar" title="Menu chính">
            <i class="fas fa-bars"></i>
        </button>

        <!-- Brand Logo -->
        <a class="navbar-brand navbar-brand-logo d-flex align-items-center gap-2 me-2" href="cua-hang">
            <div class="brand-logo-wrap">
                <img src="${pageContext.request.contextPath}/image/logonutrioverflow.jpg"
                     alt="NutriOverflow Logo"
                     class="brand-logo-img">
            </div>
            <span class="brand-name-text">Nutri<span class="brand-name-accent">Overflow</span></span>
        </a>

        <!-- Nav divider -->
        <div class="nav-divider"></div>

        <!-- Left Nav Links -->
        <ul class="navbar-nav align-items-center" style="gap: 20px; flex-shrink: 0;">
            <li class="nav-item">
                <a class="nav-link" href="cua-hang">
                    <i class="fas fa-store" style="font-size:0.72rem; opacity:0.7; margin-right:5px;"></i>Cửa hàng
                </a>
            </li>
            <li class="nav-item">
                <a class="nav-link" href="bai-viet">
                    <i class="fas fa-newspaper" style="font-size:0.72rem; opacity:0.7; margin-right:5px;"></i>Blog
                </a>
            </li>
            <li class="nav-item">
                <a class="nav-link" href="nutriboost" style="color: var(--brand) !important; font-weight: 700;">
                    <i class="fas fa-bolt" style="font-size:0.72rem; opacity:0.9; margin-right:5px; animation: nutriboost-pulse 1.8s infinite alternate;"></i>NutriBoost AI
                </a>
            </li>
        </ul>

        <!-- Search Bar (center, flexible) -->
        <div class="search-wrap mx-2" style="position: relative;">
            <form action="MainController" method="POST" style="margin:0;">
                <input type="hidden" name="action" value="GoShopping">
                <div class="search-inner" style="width:100%;">
                    <i class="fas fa-search search-icon-prefix"></i>
                    <input oninput="searchByName(this)"
                           id="searchBox"
                           class="search-input"
                           type="search"
                           name="txtSearch"
                           value="${param.txtSearch}"
                           placeholder="Tìm kiếm whey, vitamin, protein..."
                           aria-label="Search"
                           autocomplete="off">
                    <button class="search-btn" type="submit" title="Tìm kiếm">
                        <i class="fas fa-arrow-right"></i>
                    </button>
                </div>
            </form>
            <div id="searchResult"></div>
        </div>

        <!-- Right Action Group -->
        <div class="d-flex align-items-center" style="gap: 8px; flex-shrink: 0;">

            <!-- Cart -->
            <a href="gio-hang" class="nav-icon-btn-cart position-relative" title="Giỏ hàng">
                <div class="cart-icon-wrap">
                    <i class="fas fa-bag-shopping"></i>
                </div>
                <span>Giỏ hàng</span>
                <c:if test="${not empty sessionScope.CART and sessionScope.CART.cart.size() > 0}">
                    <span class="position-absolute badge badge-sharp"
                          style="top:-7px; right:-7px;">
                        ${sessionScope.CART.cart.size()}
                    </span>
                </c:if>
            </a>

            <!-- Wishlist -->
            <a href="yeu-thich" class="nav-icon-btn btn-heart" title="Yêu thích">
                <i class="fas fa-heart"></i>
            </a>

            <!-- Notification Bell (logged in only) -->
            <c:if test="${not empty sessionScope.LOGIN_USER}">
                <c:set var="unreadCount" value="${sessionScope.UNREAD_NOTIF_COUNT}"/>
                <a href="thong-bao"
                   id="notifBell"
                   class="nav-icon-btn btn-bell position-relative ${unreadCount > 0 ? 'notif-bell-alert' : ''}"
                   title="${unreadCount > 0 ? 'Bạn có ' += unreadCount += ' thông báo chưa đọc' : 'Thông báo'}">
                    <i class="fas fa-bell"></i>
                    <c:if test="${unreadCount > 0}">
                        <span class="position-absolute badge badge-sharp badge-danger-pulse"
                              style="top:-6px; right:-6px;">
                            ${unreadCount}
                        </span>
                    </c:if>
                </a>
            </c:if>

            <div class="nav-divider"></div>

            <!-- User Menu -->
            <c:choose>
                <c:when test="${not empty sessionScope.LOGIN_USER}">
                    <div class="dropdown">
                        <button class="btn-user-dropdown" type="button"
                                data-bs-toggle="dropdown" aria-expanded="false"
                                id="userDropdownDesktop">
                            <div class="btn-user-avatar" id="navUserAvatar">
                                <i class="fas fa-user" style="font-size:0.7rem;"></i>
                            </div>
                            <span id="navUserName" style="max-width:110px; overflow:hidden; text-overflow:ellipsis; white-space:nowrap;">
                                ${sessionScope.LOGIN_USER.fullName}
                            </span>
                            <i class="fas fa-chevron-down btn-user-chevron"></i>
                        </button>
                        <ul class="dropdown-menu dropdown-menu-end dropdown-menu-dark-custom" style="padding:6px;">
                            <!-- User info header -->
                            <li>
                                <div class="dropdown-user-header d-flex align-items-center gap-3">
                                    <div id="navDropdownAvatar" style="width:38px;height:38px;border-radius:50%;background:linear-gradient(135deg,#00e676,#00c853);display:flex;align-items:center;justify-content:center;font-weight:800;font-size:1rem;color:#0a0a0a;flex-shrink:0;">
                                        <i class="fas fa-user" style="font-size:0.8rem;"></i>
                                    </div>
                                    <div>
                                        <div class="dropdown-user-name">${sessionScope.LOGIN_USER.fullName}</div>
                                        <div class="dropdown-user-label">Thành viên</div>
                                    </div>
                                </div>
                            </li>
                            <li>
                                <a class="dropdown-item-custom" href="don-hang">
                                    <div class="item-icon" style="background:rgba(0,200,83,0.12);">
                                        <i class="fas fa-box-open" style="color:#00c853;"></i>
                                    </div>
                                    Đơn hàng của tôi
                                </a>
                            </li>
                            <li>
                                <a class="dropdown-item-custom" href="ca-nhan">
                                    <div class="item-icon" style="background:rgba(99,102,241,0.12);">
                                        <i class="fas fa-user-edit" style="color:#6366f1;"></i>
                                    </div>
                                    Hồ sơ của tôi
                                </a>
                            </li>
                            <li>
                                <a class="dropdown-item-custom" href="thong-bao">
                                    <div class="item-icon" style="background:rgba(245,158,11,0.12);">
                                        <i class="fas fa-bell" style="color:#f59e0b;"></i>
                                    </div>
                                    Thông báo
                                    <c:if test="${sessionScope.UNREAD_NOTIF_COUNT > 0}">
                                        <span class="badge ms-auto"
                                              style="background:#ef4444;color:#fff;font-size:0.65rem;border-radius:50px;padding:2px 7px;">
                                            ${sessionScope.UNREAD_NOTIF_COUNT}
                                        </span>
                                    </c:if>
                                </a>
                            </li>
                            <li><hr class="dropdown-divider-custom" style="border-color:rgba(255,255,255,0.07);margin:4px 0;"></li>
                            <li>
                                <a class="dropdown-item-custom danger" href="dang-xuat">
                                    <div class="item-icon" style="background:rgba(239,68,68,0.10);">
                                        <i class="fas fa-sign-out-alt" style="color:#ef4444;"></i>
                                    </div>
                                    Đăng xuất
                                </a>
                            </li>
                        </ul>
                    </div>
                </c:when>
                <c:otherwise>
                    <a href="dang-nhap" class="btn-login">
                        <i class="fas fa-sign-in-alt" style="font-size:0.78rem;"></i>
                        Đăng nhập
                    </a>
                </c:otherwise>
            </c:choose>
        </div>
    </div>

    <!-- ══ MOBILE HEADER (< 992px) ══ -->
    <div class="container d-flex d-lg-none flex-column px-3" style="gap: 6px; padding-top: 8px; padding-bottom: 8px;">

        <!-- Row 1: Brand & Quick Actions -->
        <div class="d-flex align-items-center justify-content-between w-100">

            <div class="d-flex align-items-center gap-2">
                <!-- Sidebar Toggle -->
                <button class="btn sidebar-toggle-btn border-0" type="button"
                        data-bs-toggle="offcanvas" data-bs-target="#leftSidebar"
                        aria-controls="leftSidebar">
                    <i class="fas fa-bars"></i>
                </button>
                <!-- Brand -->
                <a class="navbar-brand-logo d-flex align-items-center gap-2" href="cua-hang">
                    <div class="brand-logo-wrap">
                        <img src="${pageContext.request.contextPath}/image/logonutrioverflow.jpg"
                             alt="NutriOverflow Logo" class="brand-logo-img">
                    </div>
                    <span class="brand-name-text">Nutri<span class="brand-name-accent">Overflow</span></span>
                </a>
            </div>

            <!-- Mobile Actions -->
            <div class="d-flex align-items-center" style="gap: 6px;">
                <!-- Cart -->
                <a href="gio-hang" class="nav-icon-btn position-relative" title="Giỏ hàng">
                    <i class="fas fa-bag-shopping"></i>
                    <c:if test="${not empty sessionScope.CART and sessionScope.CART.cart.size() > 0}">
                        <span class="position-absolute badge badge-sharp" style="top:-6px;right:-6px;">
                            ${sessionScope.CART.cart.size()}
                        </span>
                    </c:if>
                </a>

                <!-- Notification (logged in) -->
                <c:if test="${not empty sessionScope.LOGIN_USER}">
                    <c:set var="unreadCount" value="${sessionScope.UNREAD_NOTIF_COUNT}"/>
                    <a href="thong-bao"
                       id="notifBellMobile"
                       class="nav-icon-btn btn-bell position-relative ${unreadCount > 0 ? 'notif-bell-alert' : ''}"
                       title="Thông báo">
                        <i class="fas fa-bell"></i>
                        <c:if test="${unreadCount > 0}">
                            <span class="position-absolute badge badge-sharp badge-danger-pulse"
                                  style="top:-6px;right:-6px;">
                                ${unreadCount}
                            </span>
                        </c:if>
                    </a>
                </c:if>

                <!-- User -->
                <c:choose>
                    <c:when test="${not empty sessionScope.LOGIN_USER}">
                        <div class="dropdown">
                            <button class="btn-user-dropdown" type="button"
                                    data-bs-toggle="dropdown" aria-expanded="false"
                                    style="padding: 0.35rem 0.85rem 0.35rem 0.55rem;">
                                <div class="btn-user-avatar" id="navMobileAvatar" style="width:24px;height:24px;font-size:0.68rem;">
                                    <i class="fas fa-user" style="font-size:0.62rem;"></i>
                                </div>
                                <i class="fas fa-chevron-down btn-user-chevron"></i>
                            </button>
                            <ul class="dropdown-menu dropdown-menu-end dropdown-menu-dark-custom">
                                <li>
                                    <a class="dropdown-item-custom" href="don-hang">
                                        <div class="item-icon" style="background:rgba(0,200,83,0.12);">
                                            <i class="fas fa-box-open" style="color:#00c853;"></i>
                                        </div>
                                        Đơn hàng của tôi
                                    </a>
                                </li>
                                <li>
                                    <a class="dropdown-item-custom" href="ca-nhan">
                                        <div class="item-icon" style="background:rgba(99,102,241,0.12);">
                                            <i class="fas fa-user-edit" style="color:#6366f1;"></i>
                                        </div>
                                        Hồ sơ của tôi
                                    </a>
                                </li>
                                <li>
                                    <a class="dropdown-item-custom" href="thong-bao">
                                        <div class="item-icon" style="background:rgba(245,158,11,0.12);">
                                            <i class="fas fa-bell" style="color:#f59e0b;"></i>
                                        </div>
                                        Thông báo
                                        <c:if test="${sessionScope.UNREAD_NOTIF_COUNT > 0}">
                                            <span class="badge ms-auto" style="background:#ef4444;color:#fff;font-size:0.65rem;border-radius:50px;padding:2px 7px;">
                                                ${sessionScope.UNREAD_NOTIF_COUNT}
                                            </span>
                                        </c:if>
                                    </a>
                                </li>
                                <li><hr class="dropdown-divider-custom" style="border-color:rgba(255,255,255,0.07);margin:4px 0;"></li>
                                <li>
                                    <a class="dropdown-item-custom danger" href="dang-xuat">
                                        <div class="item-icon" style="background:rgba(239,68,68,0.10);">
                                            <i class="fas fa-sign-out-alt" style="color:#ef4444;"></i>
                                        </div>
                                        Đăng xuất
                                    </a>
                                </li>
                            </ul>
                        </div>
                    </c:when>
                    <c:otherwise>
                        <a href="dang-nhap" class="btn-login" style="padding:0.38rem 1rem;font-size:0.76rem;">
                            <i class="fas fa-sign-in-alt" style="font-size:0.72rem;"></i>
                            Đăng nhập
                        </a>
                    </c:otherwise>
                </c:choose>
            </div>
        </div>

        <!-- Row 2: Mobile Search -->
        <div class="search-wrap w-100 pb-1" style="position: relative;">
            <form action="MainController" method="POST" style="margin:0;">
                <input type="hidden" name="action" value="GoShopping">
                <div class="search-inner" style="width:100%;">
                    <input oninput="searchByName(this)"
                           id="searchBoxMobile"
                           class="search-input"
                           type="search"
                           name="txtSearch"
                           value="${param.txtSearch}"
                           placeholder="Tìm kiếm whey, vitamin..."
                           aria-label="Search"
                           autocomplete="off">
                    <button class="search-btn" type="submit">
                        <i class="fas fa-search"></i>
                    </button>
                </div>
            </form>
            <div id="searchResultMobile"></div>
        </div>
    </div>
</nav>

<!-- Global Toast -->
<div id="nf-global-toast">
    <div class="toast-icon"><i id="nf-toast-icon" class="fas fa-check"></i></div>
    <div class="toast-body-wrap">
        <div class="toast-title" id="nf-toast-title"></div>
        <div class="toast-msg"   id="nf-toast-msg"></div>
        <div class="toast-actions" id="nf-toast-actions"></div>
    </div>
    <button class="toast-close" onclick="closeNfToast()"><i class="fas fa-times"></i></button>
</div>

<style>
/* Chevron rotate on dropdown open */
.dropdown.show .btn-user-chevron { transform: rotate(180deg) !important; }
</style>

<script>
// ── Navbar scroll effect ──────────────────────────────────────────────────────
(function() {
    var nav = document.getElementById('mainNavbar');
    if (!nav) return;
    window.addEventListener('scroll', function() {
        if (window.scrollY > 30) {
            nav.classList.add('scrolled');
        } else {
            nav.classList.remove('scrolled');
        }
    }, { passive: true });
})();

// ── Fill user avatar initials ─────────────────────────────────────────────────
(function() {
    var nameEl = document.getElementById('navUserName');
    if (!nameEl) return;
    var fullName = nameEl.textContent.trim();
    var initial = fullName.charAt(0).toUpperCase();
    var iconHtml = '<span style="font-family:\'Outfit\',sans-serif;font-weight:900;font-size:0.8rem;">' + initial + '</span>';
    ['navUserAvatar','navDropdownAvatar','navMobileAvatar'].forEach(function(id) {
        var el = document.getElementById(id);
        if (el) el.innerHTML = iconHtml;
    });
})();

// ── Cross-tab payment signal listener ─────────────────────────────────────────
var nfToastTimer = null;

function showNfToast(type, title, msg, actions) {
    var el = document.getElementById('nf-global-toast');
    el.className = 'show toast-' + type;
    document.getElementById('nf-toast-icon').className  = 'fas ' + (type === 'success' ? 'fa-check-circle' : 'fa-times-circle');
    document.getElementById('nf-toast-title').textContent = title;
    document.getElementById('nf-toast-msg').textContent   = msg;

    var actEl = document.getElementById('nf-toast-actions');
    actEl.innerHTML = '';
    (actions || []).forEach(function(a) {
        var btn = document.createElement('a');
        btn.href = a.href;
        btn.textContent = a.label;
        btn.className = a.primary ? 'toast-btn-primary' : 'toast-btn-secondary';
        if (a.target) btn.target = a.target;
        actEl.appendChild(btn);
    });

    clearTimeout(nfToastTimer);
    nfToastTimer = setTimeout(closeNfToast, 7000);
}

function closeNfToast() {
    var el = document.getElementById('nf-global-toast');
    if (el) el.classList.remove('show');
}

window.addEventListener('storage', function(e) {
    if (e.key !== 'nf_payment_result' || !e.newValue) return;
    try {
        var d = JSON.parse(e.newValue);
        if (Date.now() - d.ts > 15000) return;
        if (d.status === 'SUCCESS') {
            showNfToast('success',
                'Thanh toán thành công! 🎉',
                'Đơn hàng #' + d.orderId + ' đã được thanh toán.',
                [
                    { href: 'don-hang', label: 'Xem đơn hàng', primary: true },
                    { href: 'cua-hang', label: 'Tiếp tục mua sắm', primary: false }
                ]
            );
            setTimeout(function() { window.location.reload(); }, 2000);
        } else if (d.status === 'FAILED') {
            showNfToast('failed',
                'Thanh toán thất bại',
                'Đơn hàng #' + d.orderId + ' chưa được thanh toán.',
                [
                    { href: 'don-hang?orderId=' + d.orderId, label: 'Thử lại', primary: true },
                    { href: 'thong-bao', label: 'Xem thông báo', primary: false }
                ]
            );
        }
    } catch(err) {}
});

// ── Bell shake on load ────────────────────────────────────────────────────────
(function() {
    ['notifBell', 'notifBellMobile'].forEach(function(id) {
        var bell = document.getElementById(id);
        if (bell) {
            bell.addEventListener('click', function() {
                var badge = bell.querySelector('.badge');
                if (badge) badge.remove();
                bell.classList.remove('notif-bell-alert');
            });
            if (bell.classList.contains('notif-bell-alert')) {
                setTimeout(function() {
                    bell.style.animation = 'none';
                    void bell.offsetWidth;
                    bell.style.animation = '';
                }, 200);
            }
        }
    });
})();

/* ══ GLOBAL SEARCH AJAX ══ */
function searchByName(txt) {
    var txtSearch = txt.value;
    var targetId = (txt.id === "searchBoxMobile") ? "searchResultMobile" : "searchResult";
    var resultDiv = document.getElementById(targetId);

    if (txtSearch.trim() === "") {
        resultDiv.innerHTML = "";
        return;
    }

    fetch("tim-kiem-goi-y?txtSearch=" + encodeURIComponent(txtSearch))
        .then(response => response.json())
        .then(data => {
            if (data.length === 0) {
                resultDiv.innerHTML = '<div style="padding:20px;text-align:center;color:rgba(255,255,255,0.4);font-size:0.82rem;"><i class="fas fa-search" style="display:block;font-size:1.5rem;margin-bottom:8px;opacity:0.3;"></i>Không tìm thấy sản phẩm</div>';
                return;
            }
            var content = "";
            data.forEach(p => {
                var detailUrl = "san-pham?id=" + p.id;
                var imgPath = "image/" + (p.imageUrl || 'default-product.jpg');

                content += '<a href="' + detailUrl + '" style="display:flex;align-items:center;padding:10px 14px;text-decoration:none;color:#ffffff;border-bottom:1px solid rgba(255,255,255,0.04);transition:background 0.2s,padding-left 0.2s;" onmouseover="this.style.background=\'rgba(0,230,118,0.08)\';this.style.paddingLeft=\'18px\'" onmouseout="this.style.background=\'transparent\';this.style.paddingLeft=\'14px\'">';
                content += '  <div style="width:44px;height:44px;background:rgba(255,255,255,0.05);border-radius:10px;overflow:hidden;display:flex;align-items:center;justify-content:center;flex-shrink:0;margin-right:12px;border:1px solid rgba(255,255,255,0.07);">';
                content += '    <img src="' + imgPath + '" onerror="this.src=\'https://via.placeholder.com/44\'" style="width:100%;height:100%;object-fit:cover;border-radius:8px;">';
                content += '  </div>';
                content += '  <div style="flex-grow:1;min-width:0;">';
                content += '    <div style="font-size:0.84rem;font-weight:600;color:#ffffff;white-space:nowrap;overflow:hidden;text-overflow:ellipsis;" title="' + p.name + '">' + p.name + '</div>';
                content += '    <div style="font-size:0.75rem;color:#00e676;font-weight:700;margin-top:2px;">' + Number(p.price).toLocaleString('vi-VN') + ' ₫</div>';
                content += '  </div>';
                content += '  <i class="fas fa-arrow-right" style="color:rgba(0,230,118,0.5);font-size:0.72rem;flex-shrink:0;margin-left:8px;"></i>';
                content += '</a>';
            });
            resultDiv.innerHTML = content;
        })
        .catch(error => console.error('Search error:', error));
}

document.addEventListener("click", function(e) {
    var dsResult = document.getElementById("searchResult");
    var dsBox = document.getElementById("searchBox");
    if (dsResult && !dsResult.contains(e.target) && e.target !== dsBox) {
        dsResult.innerHTML = "";
    }
    var mbResult = document.getElementById("searchResultMobile");
    var mbBox = document.getElementById("searchBoxMobile");
    if (mbResult && !mbResult.contains(e.target) && e.target !== mbBox) {
        mbResult.innerHTML = "";
    }
});

// ── Global Scroll Reveal ──────────────────────────────────────────────────────
document.addEventListener("DOMContentLoaded", function() {
    const observer = new IntersectionObserver((entries) => {
        entries.forEach(entry => {
            if (entry.isIntersecting) {
                entry.target.classList.add('visible');
                observer.unobserve(entry.target);
            }
        });
    }, { threshold: 0.08 });

    const selectors = '.card-product,.blog-card,.notif-card,.confirm-card,.order-card,.result-card,.goal-card,.category-card,.bestseller-card,.flash-sale-card,.product-item-card,.review-section,.reader-container,.review-form-card,.card';
    document.querySelectorAll(selectors).forEach(el => {
        el.classList.add('fade-in-up');
        observer.observe(el);
    });
});
</script>

<!-- ══ LEFT SIDEBAR OFF-CANVAS ══ -->
<div class="offcanvas offcanvas-start sidebar-offcanvas text-white" tabindex="-1" id="leftSidebar" aria-labelledby="leftSidebarLabel">
    <div class="offcanvas-header sidebar-header">
        <h5 class="offcanvas-title d-flex align-items-center gap-2" id="leftSidebarLabel">
            <img src="${pageContext.request.contextPath}/image/logonutrioverflow.jpg" alt="Logo"
                 class="rounded-circle"
                 style="width:30px;height:30px;border:1.5px solid rgba(0,230,118,0.5);">
            <span style="font-family:'Outfit',sans-serif;font-weight:800;font-size:0.95rem;letter-spacing:1.5px;">
                NUTRI<span class="text-brand">OVERFLOW</span>
            </span>
        </h5>
        <button type="button" class="btn-close btn-close-white" data-bs-dismiss="offcanvas" aria-label="Close"></button>
    </div>

    <div class="offcanvas-body px-0" style="padding-top:1rem !important;">

        <!-- Nhóm 1: Sản phẩm -->
        <div class="sidebar-group mb-3">
            <div class="sidebar-group-title">
                <i class="fas fa-grid-2" style="margin-right:6px;color:rgba(0,230,118,0.5);"></i>Menu sản phẩm
            </div>
            <ul class="list-unstyled m-0 p-0">
                <li><a href="cua-hang" class="sidebar-link"><i class="fas fa-th-large"></i> Tất cả sản phẩm</a></li>
                <li><a href="bai-viet" class="sidebar-link"><i class="fas fa-newspaper"></i> Blog sức khỏe</a></li>
                <li><a href="nutriboost" class="sidebar-link text-brand" style="color: var(--brand) !important; font-weight: 700;"><i class="fas fa-bolt" style="color: var(--brand);"></i> NutriBoost AI</a></li>
                <li><a href="cua-hang?category=1" class="sidebar-link"><i class="fas fa-dna"></i> Đạm / Whey Protein</a></li>
                <li><a href="cua-hang?category=2" class="sidebar-link"><i class="fas fa-weight-hanging"></i> Sữa tăng cân (Mass)</a></li>
                <li><a href="cua-hang?category=3" class="sidebar-link"><i class="fas fa-bolt"></i> Tăng sức mạnh (Pre)</a></li>
                <li><a href="cua-hang?category=4" class="sidebar-link"><i class="fas fa-leaf"></i> Đồ ăn kiêng (Diet)</a></li>
                <li><a href="cua-hang?category=5" class="sidebar-link"><i class="fas fa-fire-alt"></i> Hỗ trợ đốt mỡ (Burner)</a></li>
                <li><a href="cua-hang?category=6" class="sidebar-link"><i class="fas fa-capsules"></i> Vitamin & Khoáng chất</a></li>
                <li><a href="cua-hang?category=7" class="sidebar-link"><i class="fas fa-cookie-bite"></i> Snack / Bánh Protein</a></li>
            </ul>
        </div>

        <div style="height:1px;background:rgba(255,255,255,0.05);margin:0 1.4rem 1rem;"></div>

        <!-- Nhóm 2: Lối tắt cá nhân -->
        <div class="sidebar-group mb-3">
            <div class="sidebar-group-title">
                <i class="fas fa-user-circle" style="margin-right:6px;color:rgba(0,230,118,0.5);"></i>Lối tắt cá nhân
            </div>
            <ul class="list-unstyled m-0 p-0">
                <li><a href="ca-nhan" class="sidebar-link"><i class="fas fa-user-edit"></i> Hồ sơ của tôi</a></li>
                <li><a href="don-hang" class="sidebar-link"><i class="fas fa-box-open"></i> Đơn hàng của tôi</a></li>
                <li><a href="yeu-thich" class="sidebar-link"><i class="fas fa-heart"></i> Danh sách yêu thích</a></li>
                <li><a href="thong-bao" class="sidebar-link"><i class="fas fa-bell"></i> Hộp thư thông báo</a></li>
                <li><a href="gio-hang" class="sidebar-link"><i class="fas fa-bag-shopping"></i> Giỏ hàng hiện tại</a></li>
            </ul>
        </div>

        <div style="height:1px;background:rgba(255,255,255,0.05);margin:0 1.4rem 1rem;"></div>

        <!-- Nhóm 3: Hỗ trợ -->
        <div class="sidebar-group">
            <div class="sidebar-group-title">
                <i class="fas fa-info-circle" style="margin-right:6px;color:rgba(0,230,118,0.5);"></i>Thông tin & Hỗ trợ
            </div>
            <ul class="list-unstyled m-0 p-0">
                <li><a href="#" class="sidebar-link" onclick="alert('NutriOverflow - Thương hiệu thực phẩm bổ sung thể hình cao cấp chính hãng Việt Nam. Thành lập năm 2026.');return false;"><i class="fas fa-award"></i> Về thương hiệu</a></li>
                <li><a href="#" class="sidebar-link" onclick="alert('Chính sách đổi trả: Lỗi 1 đổi 1 trong vòng 7 ngày nếu lỗi nhà sản xuất.');return false;"><i class="fas fa-shield-alt"></i> Chính sách đổi trả</a></li>
                <li><a href="#" class="sidebar-link" onclick="alert('Tổng đài hỗ trợ: 1900 6868 (8:00 - 22:00)\nEmail: support@nutrioverflow.com');return false;"><i class="fas fa-headset"></i> Liên hệ trợ giúp</a></li>
                <li><a href="#" class="sidebar-link" onclick="alert('Hệ thống NutriOverflow:\n- Q.1, TP. HCM\n- Cầu Giấy, Hà Nội\n- Hải Châu, Đà Nẵng');return false;"><i class="fas fa-map-marker-alt"></i> Hệ thống cửa hàng</a></li>
            </ul>
        </div>
    </div>
</div>

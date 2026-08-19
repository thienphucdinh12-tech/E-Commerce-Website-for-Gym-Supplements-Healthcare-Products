<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>

<nav class="navbar navbar-expand-lg navbar-custom sticky-top">
    <!-- Desktop Header: visible only on lg screens (>= 992px) -->
    <div class="container d-none d-lg-flex">
        <!-- Button mở Sidebar bên trái -->
        <button class="btn sidebar-toggle-btn border-0 text-white me-2" type="button" data-bs-toggle="offcanvas" data-bs-target="#leftSidebar" aria-controls="leftSidebar" title="Menu chính">
            <i class="fas fa-bars"></i>
        </button>
        
        <!-- Brand -->
        <a class="navbar-brand navbar-brand-logo d-flex align-items-center gap-2" href="MainController?action=GoShopping">
            <div class="brand-logo-wrap">
                <img src="${pageContext.request.contextPath}/image/logonutrioverflow.jpg"
                     alt="NutriOverflow Logo"
                     class="brand-logo-img">
            </div>
            <span class="brand-name-text">Nutri<span class="brand-name-accent">Overflow</span></span>
        </a>

        <!-- Left links -->
        <ul class="navbar-nav me-auto ps-3">
            <li class="nav-item">
                <a class="nav-link" href="MainController?action=GoShopping">Cửa hàng</a>
            </li>
        </ul>

        <!-- Right controls -->
        <div class="d-flex align-items-center gap-2">
            <!-- Search -->
            <div class="search-wrap" style="position: relative;">
                <form action="MainController" method="POST" class="d-flex align-items-center">
                    <input type="hidden" name="action" value="GoShopping">
                    <input oninput="searchByName(this)"
                           id="searchBox"
                           class="form-control search-input"
                           type="search"
                           name="txtSearch"
                           value="${param.txtSearch}"
                           placeholder="Tìm kiếm whey, vitamin..."
                           aria-label="Search"
                           autocomplete="off">
                    <button class="search-btn" type="submit">
                        <i class="fas fa-search" style="font-size: 0.8rem;"></i>
                    </button>
                </form>
                <div id="searchResult"></div>
            </div>

            <!-- Cart -->
            <a href="MainController?action=ViewCart" class="nav-icon-btn position-relative">
                <i class="fas fa-shopping-bag"></i> Giỏ hàng
                <c:if test="${not empty sessionScope.CART and sessionScope.CART.cart.size() > 0}">
                    <span class="position-absolute top-0 start-100 translate-middle badge badge-sharp">
                        ${sessionScope.CART.cart.size()}
                    </span>
                </c:if>
            </a>

            <!-- Wishlist -->
            <a href="MainController?action=ViewFavorites" class="nav-icon-btn btn-heart" title="Yêu thích">
                <i class="fas fa-heart"></i>
            </a>

            <!-- Notification -->
            <c:if test="${not empty sessionScope.LOGIN_USER}">
                <c:set var="unreadCount" value="${sessionScope.UNREAD_NOTIF_COUNT}"/>
                <a href="NotificationController"
                   id="notifBell"
                   class="nav-icon-btn position-relative ${unreadCount > 0 ? 'notif-bell-alert' : ''}"
                   title="${unreadCount > 0 ? 'Bạn có ' += unreadCount += ' thông báo chưa đọc' : 'Thông báo'}">
                    <i class="fas fa-bell"></i>
                    <c:if test="${unreadCount > 0}">
                        <span class="position-absolute top-0 start-100 translate-middle badge badge-sharp badge-danger-pulse">
                            ${unreadCount}
                        </span>
                    </c:if>
                </a>
            </c:if>

            <!-- User -->
            <c:choose>
                <c:when test="${not empty sessionScope.LOGIN_USER}">
                    <div class="dropdown">
                        <button class="btn-brand dropdown-toggle d-flex align-items-center gap-2"
                                type="button" data-bs-toggle="dropdown">
                            <i class="fas fa-user-circle"></i>
                            <span style="max-width:110px; overflow:hidden; text-overflow:ellipsis; white-space:nowrap;">
                                ${sessionScope.LOGIN_USER.fullName}
                            </span>
                        </button>
                        <ul class="dropdown-menu dropdown-menu-end border-0 shadow-lg mt-2"
                            style="border-radius: 14px; min-width: 180px; overflow: hidden;">
                            <li>
                                <a class="dropdown-item d-flex align-items-center gap-2 py-2"
                                   href="MainController?action=ViewOrders"
                                   style="font-size: 0.84rem; font-weight: 600; color: #374151;">
                                    <i class="fas fa-box-open" style="color:#00c853;"></i> Đơn hàng của tôi
                                </a>
                            </li>
                            <li>
                                <a class="dropdown-item d-flex align-items-center gap-2 py-2"
                                   href="ProfileController"
                                   style="font-size: 0.84rem; font-weight: 600; color: #374151;">
                                    <i class="fas fa-user-edit" style="color:#6366f1;"></i> Hồ sơ của tôi
                                </a>
                            </li>
                            <li>
                                <a class="dropdown-item d-flex align-items-center gap-2 py-2"
                                   href="NotificationController"
                                   style="font-size: 0.84rem; font-weight: 600; color: #374151;">
                                    <i class="fas fa-bell" style="color:#f59e0b;"></i> Thông báo
                                    <c:if test="${sessionScope.UNREAD_NOTIF_COUNT > 0}">
                                        <span class="badge ms-auto" style="background:#ef4444;color:#fff;font-size:0.68rem;border-radius:50px;padding:2px 7px;">
                                            ${sessionScope.UNREAD_NOTIF_COUNT}
                                        </span>
                                    </c:if>
                                </a>
                            </li>
                            <li><hr class="dropdown-divider my-1"></li>
                            <li>
                                <a class="dropdown-item d-flex align-items-center gap-2 py-2"
                                   href="MainController?action=Logout"
                                   style="font-size: 0.84rem; font-weight: 600; color: #ef4444;">
                                    <i class="fas fa-sign-out-alt"></i> Đăng xuất
                                </a>
                            </li>
                        </ul>
                    </div>
                </c:when>
                <c:otherwise>
                    <a href="login.jsp" class="btn-brand text-decoration-none">Đăng nhập</a>
                </c:otherwise>
            </c:choose>
        </div>
    </div>

    <!-- Mobile Header: visible only on screens < 992px -->
    <div class="container d-flex d-lg-none flex-column gap-2 px-3">
        <!-- Row 1: Brand & Actions -->
        <div class="d-flex align-items-center justify-content-between w-100">
            <div class="d-flex align-items-center gap-1">
                <!-- Button mở Sidebar bên trái -->
                <button class="btn sidebar-toggle-btn border-0 text-white p-1 me-1" type="button" data-bs-toggle="offcanvas" data-bs-target="#leftSidebar" aria-controls="leftSidebar" title="Menu chính">
                    <i class="fas fa-bars"></i>
                </button>
                
                <!-- Brand -->
                <a class="navbar-brand navbar-brand-logo d-flex align-items-center gap-2" href="MainController?action=GoShopping">
                    <div class="brand-logo-wrap">
                        <img src="${pageContext.request.contextPath}/image/logonutrioverflow.jpg"
                             alt="NutriOverflow Logo"
                             class="brand-logo-img">
                    </div>
                    <span class="brand-name-text">Nutri<span class="brand-name-accent">Overflow</span></span>
                </a>
            </div>

            <!-- Mobile Action Icons (Cart, Notification, Profile) -->
            <div class="d-flex align-items-center gap-2">
                <!-- Cart -->
                <a href="MainController?action=ViewCart" class="nav-icon-btn position-relative" title="Giỏ hàng">
                    <i class="fas fa-shopping-bag"></i>
                    <c:if test="${not empty sessionScope.CART and sessionScope.CART.cart.size() > 0}">
                        <span class="position-absolute top-0 start-100 translate-middle badge badge-sharp">
                            ${sessionScope.CART.cart.size()}
                        </span>
                    </c:if>
                </a>

                <!-- Notification -->
                <c:if test="${not empty sessionScope.LOGIN_USER}">
                    <c:set var="unreadCount" value="${sessionScope.UNREAD_NOTIF_COUNT}"/>
                    <a href="NotificationController"
                       id="notifBellMobile"
                       class="nav-icon-btn position-relative ${unreadCount > 0 ? 'notif-bell-alert' : ''}"
                       title="${unreadCount > 0 ? 'Bạn có ' += unreadCount += ' thông báo chưa đọc' : 'Thông báo'}">
                        <i class="fas fa-bell"></i>
                        <c:if test="${unreadCount > 0}">
                            <span class="position-absolute top-0 start-100 translate-middle badge badge-sharp badge-danger-pulse">
                                ${unreadCount}
                            </span>
                        </c:if>
                    </a>
                </c:if>

                <!-- User Dropdown / Login -->
                <c:choose>
                    <c:when test="${not empty sessionScope.LOGIN_USER}">
                        <div class="dropdown">
                            <button class="btn-brand dropdown-toggle" type="button" data-bs-toggle="dropdown" aria-expanded="false">
                                <i class="fas fa-user-circle" style="font-size: 1.1rem;"></i>
                            </button>
                            <ul class="dropdown-menu dropdown-menu-end border-0 shadow-lg mt-2"
                                style="border-radius: 14px; min-width: 180px; overflow: hidden; background-color: #ffffff;">
                                <li>
                                    <a class="dropdown-item d-flex align-items-center gap-2 py-2"
                                       href="MainController?action=ViewOrders"
                                       style="font-size: 0.84rem; font-weight: 600; color: #374151;">
                                        <i class="fas fa-box-open" style="color:#00c853;"></i> Đơn hàng của tôi
                                    </a>
                                </li>
                                <li>
                                    <a class="dropdown-item d-flex align-items-center gap-2 py-2"
                                       href="ProfileController"
                                       style="font-size: 0.84rem; font-weight: 600; color: #374151;">
                                        <i class="fas fa-user-edit" style="color:#6366f1;"></i> Hồ sơ của tôi
                                    </a>
                                </li>
                                <li>
                                    <a class="dropdown-item d-flex align-items-center gap-2 py-2"
                                       href="NotificationController"
                                       style="font-size: 0.84rem; font-weight: 600; color: #374151;">
                                        <i class="fas fa-bell" style="color:#f59e0b;"></i> Thông báo
                                        <c:if test="${sessionScope.UNREAD_NOTIF_COUNT > 0}">
                                            <span class="badge ms-auto" style="background:#ef4444;color:#fff;font-size:0.68rem;border-radius:50px;padding:2px 7px;">
                                                ${sessionScope.UNREAD_NOTIF_COUNT}
                                            </span>
                                        </c:if>
                                    </a>
                                </li>
                                <li><hr class="dropdown-divider my-1"></li>
                                <li>
                                    <a class="dropdown-item d-flex align-items-center gap-2 py-2"
                                       href="MainController?action=Logout"
                                       style="font-size: 0.84rem; font-weight: 600; color: #ef4444;">
                                        <i class="fas fa-sign-out-alt"></i> Đăng xuất
                                    </a>
                                </li>
                            </ul>
                        </div>
                    </c:when>
                    <c:otherwise>
                        <a href="login.jsp" class="btn-brand text-decoration-none d-flex align-items-center justify-content-center" title="Đăng nhập">
                            <i class="fas fa-sign-in-alt"></i>
                        </a>
                    </c:otherwise>
                </c:choose>
            </div>
        </div>

        <!-- Row 2: Search Bar -->
        <div class="search-wrap-mobile w-100 pb-1" style="position: relative;">
            <form action="MainController" method="POST" class="d-flex align-items-center w-100">
                <input type="hidden" name="action" value="GoShopping">
                <input oninput="searchByName(this)"
                       id="searchBoxMobile"
                       class="form-control search-input"
                       type="search"
                       name="txtSearch"
                       value="${param.txtSearch}"
                       placeholder="Tìm kiếm whey, vitamin..."
                       aria-label="Search"
                       autocomplete="off">
                <button class="search-btn" type="submit">
                    <i class="fas fa-search" style="font-size: 0.8rem;"></i>
                </button>
            </form>
            <div id="searchResultMobile"></div>
        </div>
    </div>
</nav>

<style>
/* ── LEFT SIDEBAR OFF-CANVAS STYLES ── */
.sidebar-toggle-btn {
    font-size: 1.25rem;
    color: rgba(255, 255, 255, 0.8) !important;
    transition: color 0.22s, transform 0.22s;
    padding: 6px 12px;
}
.sidebar-toggle-btn:hover {
    color: var(--brand) !important;
    transform: scale(1.08);
}
.sidebar-offcanvas {
    background-color: #0b0b14 !important;
    border-right: 2px solid rgba(0, 230, 118, 0.35) !important;
    width: 290px !important;
    box-shadow: 10px 0 30px rgba(0, 0, 0, 0.6) !important;
}
.sidebar-header {
    background: #06060c;
    padding: 1.2rem 1.4rem;
}
.sidebar-group-title {
    font-size: 0.72rem;
    font-weight: 800;
    text-transform: uppercase;
    letter-spacing: 1.5px;
    color: var(--txt-muted);
    padding: 0.4rem 1.4rem;
    margin-bottom: 0.5rem;
    border-left: 3px solid var(--brand);
}
.sidebar-link {
    display: flex;
    align-items: center;
    gap: 12px;
    padding: 0.72rem 1.8rem;
    color: rgba(255, 255, 255, 0.78) !important;
    text-decoration: none !important;
    font-size: 0.86rem;
    font-weight: 500;
    transition: all 0.24s ease;
}
.sidebar-link i {
    width: 18px;
    text-align: center;
    font-size: 1rem;
    color: var(--brand);
    transition: transform 0.24s ease, color 0.24s ease;
}
.sidebar-link:hover {
    background: rgba(0, 230, 118, 0.08);
    color: var(--brand) !important;
    padding-left: 2.1rem;
}
.sidebar-link:hover i {
    transform: scale(1.15) rotate(-3deg);
    color: #fff;
}

/* ── NOTIFICATION BELL STYLES ── */
.notif-bell-alert {
    color: #f59e0b !important;
    animation: bellShake 0.6s ease-in-out 1s both;
}
@keyframes bellShake {
    0%,100% { transform: rotate(0deg); }
    20%      { transform: rotate(-15deg); }
    40%      { transform: rotate(15deg); }
    60%      { transform: rotate(-10deg); }
    80%      { transform: rotate(10deg); }
}

.badge-danger-pulse {
    background: #ef4444 !important;
    animation: pulseBadge 1.5s ease-in-out infinite;
}
@keyframes pulseBadge {
    0%,100% { box-shadow: 0 0 0 0 rgba(239,68,68,0.6); }
    50%      { box-shadow: 0 0 0 5px rgba(239,68,68,0); }
}

/* ── GLOBAL TOAST (payment result signal) ── */
#nf-global-toast {
    display: none;
    position: fixed;
    top: 1.2rem; right: 1.5rem;
    min-width: 320px; max-width: 420px;
    border-radius: 18px;
    padding: 1rem 1.3rem;
    z-index: 99999;
    box-shadow: 0 16px 48px rgba(0,0,0,0.55);
    animation: toastSlideIn 0.35s cubic-bezier(.34,1.56,.64,1) both;
    pointer-events: all;
}
#nf-global-toast.show { display: flex; }
#nf-global-toast.toast-success {
    background: #0d1f10;
    border: 1.5px solid rgba(0,230,118,0.4);
}
#nf-global-toast.toast-failed {
    background: #1a0a0a;
    border: 1.5px solid rgba(239,68,68,0.4);
}
@keyframes toastSlideIn {
    from { opacity: 0; transform: translateX(40px) scale(0.95); }
    to   { opacity: 1; transform: translateX(0)    scale(1); }
}
.toast-icon {
    flex-shrink: 0;
    width: 40px; height: 40px; border-radius: 12px;
    display: flex; align-items: center; justify-content: center;
    font-size: 1.1rem; margin-right: 12px;
}
.toast-success .toast-icon { background: rgba(0,230,118,0.12); color: #00e676; }
.toast-failed  .toast-icon { background: rgba(239,68,68,0.12);  color: #ef4444; }
.toast-body-wrap { flex: 1; }
.toast-title { font-size: 0.85rem; font-weight: 800; margin-bottom: 3px; }
.toast-success .toast-title { color: #00e676; }
.toast-failed  .toast-title { color: #ef4444; }
.toast-msg  { font-size: 0.78rem; color: rgba(255,255,255,0.55); line-height: 1.4; }
.toast-close {
    flex-shrink: 0;
    background: none; border: none; color: rgba(255,255,255,0.3);
    font-size: 0.9rem; cursor: pointer; padding: 0 0 0 8px;
    line-height: 1; align-self: flex-start;
}
.toast-close:hover { color: rgba(255,255,255,0.7); }
.toast-actions { margin-top: 10px; display: flex; gap: 8px; }
.toast-btn-primary {
    font-size: 0.74rem; font-weight: 700; padding: 4px 12px;
    border-radius: 50px; text-decoration: none; border: none; cursor: pointer;
}
.toast-success .toast-btn-primary { background: #00e676; color: #0a0a12; }
.toast-failed  .toast-btn-primary { background: #ef4444; color: #fff; }
.toast-btn-secondary {
    font-size: 0.74rem; font-weight: 600; padding: 4px 12px;
    border-radius: 50px; text-decoration: none;
    background: rgba(255,255,255,0.08); border: 1px solid rgba(255,255,255,0.1);
    color: rgba(255,255,255,0.6);
}
</style>

<!-- Global Toast for cross-tab payment result -->
<div id="nf-global-toast">
    <div class="toast-icon"><i id="nf-toast-icon" class="fas fa-check"></i></div>
    <div class="toast-body-wrap">
        <div class="toast-title" id="nf-toast-title"></div>
        <div class="toast-msg"   id="nf-toast-msg"></div>
        <div class="toast-actions" id="nf-toast-actions"></div>
    </div>
    <button class="toast-close" onclick="closeNfToast()"><i class="fas fa-times"></i></button>
</div>

<script>
// ── Cross-tab payment signal listener ─────────────────────────────────────
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
    el.classList.remove('show');
}

window.addEventListener('storage', function(e) {
    if (e.key !== 'nf_payment_result' || !e.newValue) return;
    try {
        var d = JSON.parse(e.newValue);
        if (Date.now() - d.ts > 15000) return; // ignore stale signals

        if (d.status === 'SUCCESS') {
            showNfToast('success',
                'Thanh toán thành công! 🎉',
                'Đơn hàng #' + d.orderId + ' đã được thanh toán. Đang cập nhật giỏ hàng...',
                [
                    { href: 'MainController?action=ViewOrders', label: 'Xem đơn hàng', primary: true },
                    { href: 'MainController?action=GoShopping', label: 'Tiếp tục mua sắm', primary: false }
                ]
            );
            // Auto-reload after 2s to clear cart display
            setTimeout(function() { window.location.reload(); }, 2000);

        } else if (d.status === 'FAILED') {
            showNfToast('failed',
                'Thanh toán thất bại',
                'Đơn hàng #' + d.orderId + ' chưa được thanh toán. Đơn hàng của bạn đã được lưu.',
                [
                    { href: 'RetryPaymentController?orderId=' + d.orderId, label: 'Thử lại ngay', primary: true, target: '_blank' },
                    { href: 'NotificationController', label: 'Xem thông báo', primary: false }
                ]
            );
        }
    } catch(err) {}
});

// Auto-show bell shake on load if has unread
(function() {
    ['notifBell', 'notifBellMobile'].forEach(function(id) {
        var bell = document.getElementById(id);
        if (bell && bell.classList.contains('notif-bell-alert')) {
            setTimeout(function() {
                bell.style.animation = 'none';
                void bell.offsetWidth; // reflow
                bell.style.animation = '';
            }, 100);
        }
    });
})();

/* ===== GLOBAL SEARCH AJAX (supports desktop & mobile) ===== */
function searchByName(txt) {
    var txtSearch = txt.value;
    var targetId = (txt.id === "searchBoxMobile") ? "searchResultMobile" : "searchResult";
    var resultDiv = document.getElementById(targetId);
    
    if (txtSearch.trim() === "") {
        resultDiv.innerHTML = "";
        return;
    }

    fetch("MainController?action=SearchAjax&txtSearch=" + encodeURIComponent(txtSearch))
        .then(response => response.json())
        .then(data => {
            var content = "";
            data.forEach(p => {
                var detailUrl = "MainController?action=Detail&id=" + p.id;
                var imgPath = "image/" + (p.imageUrl || 'default-product.jpg');
                
                content += '<a href="' + detailUrl + '" class="list-group-item list-group-item-action d-flex align-items-center border-0 border-bottom">';
                content += '    <div class="me-3" style="width: 46px; height: 46px; background: #f3f4f6; border-radius: 8px; overflow: hidden; display: flex; align-items: center; justify-content: center; flex-shrink: 0;">';
                content += '        <img src="' + imgPath + '" onerror="this.src=\'https://via.placeholder.com/46\'" style="width: 100%; height: 100%; object-fit: cover;">';
                content += '    </div>';
                content += '    <div style="flex-grow: 1; text-align: left;">';
                content += '        <div class="fw-bold text-dark" style="font-size: 0.88rem; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; max-width: 190px;" title="' + p.name + '">' + p.name + '</div>';
                content += '        <small style="color: #e53935; font-weight: 700;">' + Number(p.price).toLocaleString() + ' ₫</small>';
                content += '    </div>';
                content += '</a>';
            });
            resultDiv.innerHTML = content;
        })
        .catch(error => console.error('Error:', error));
}

// Global click listener to clear search results when clicking away
document.addEventListener("click", function(e) {
    // Handle desktop search box click-away
    var dsResult = document.getElementById("searchResult");
    var dsBox = document.getElementById("searchBox");
    if (dsResult && !dsResult.contains(e.target) && e.target !== dsBox) {
        dsResult.innerHTML = "";
    }

    // Handle mobile search box click-away
    var mbResult = document.getElementById("searchResultMobile");
    var mbBox = document.getElementById("searchBoxMobile");
    if (mbResult && !mbResult.contains(e.target) && e.target !== mbBox) {
        mbResult.innerHTML = "";
    }
});
</script>

<!-- LEFT SIDEBAR OFF-CANVAS -->
<div class="offcanvas offcanvas-start sidebar-offcanvas text-white" tabindex="-1" id="leftSidebar" aria-labelledby="leftSidebarLabel">
    <div class="offcanvas-header sidebar-header border-bottom border-secondary">
        <h5 class="offcanvas-title d-flex align-items-center gap-2" id="leftSidebarLabel">
            <img src="${pageContext.request.contextPath}/image/logonutrioverflow.jpg" alt="Logo" class="rounded-circle" style="width: 32px; height: 32px; border: 1.5px solid var(--brand);">
            <span class="fw-bold tracking-wide">NUTRI<span class="text-brand">OVERFLOW</span></span>
        </h5>
        <button type="button" class="btn-close btn-close-white" data-bs-dismiss="offcanvas" aria-label="Close"></button>
    </div>
    
    <div class="offcanvas-body sidebar-body px-0">
        <!-- Nhóm 1: Phân loại sản phẩm chuyên sâu (Menu Sản Phẩm) -->
        <div class="sidebar-group mb-4">
            <div class="sidebar-group-title">
                <i class="fas fa-filter text-brand me-2"></i>Menu Sản Phẩm
            </div>
            <ul class="sidebar-links-list list-unstyled m-0 p-0">
                <li><a href="MainController?action=GoShopping" class="sidebar-link"><i class="fas fa-th-large"></i> Tất cả sản phẩm</a></li>
                <li><a href="MainController?action=GoShopping&category=1" class="sidebar-link"><i class="fas fa-dna"></i> Đạm / Whey Protein</a></li>
                <li><a href="MainController?action=GoShopping&category=2" class="sidebar-link"><i class="fas fa-weight-hanging"></i> Sữa tăng cân (Mass)</a></li>
                <li><a href="MainController?action=GoShopping&category=3" class="sidebar-link"><i class="fas fa-bolt"></i> Tăng sức mạnh (Pre)</a></li>
                <li><a href="MainController?action=GoShopping&category=4" class="sidebar-link"><i class="fas fa-leaf"></i> Đồ ăn kiêng (Diet)</a></li>
                <li><a href="MainController?action=GoShopping&category=5" class="sidebar-link"><i class="fas fa-fire-alt"></i> Hỗ trợ đốt mỡ (Burner)</a></li>
                <li><a href="MainController?action=GoShopping&category=6" class="sidebar-link"><i class="fas fa-capsules"></i> Vitamin & Khoáng chất</a></li>
                <li><a href="MainController?action=GoShopping&category=7" class="sidebar-link"><i class="fas fa-cookie-bite"></i> Snack / Bánh Protein</a></li>
            </ul>
        </div>

        <!-- Nhóm 2: Lối tắt cá nhân (User Shortcuts) -->
        <div class="sidebar-group mb-4">
            <div class="sidebar-group-title">
                <i class="fas fa-user-circle text-brand me-2"></i>Lối tắt cá nhân
            </div>
            <ul class="sidebar-links-list list-unstyled m-0 p-0">
                <li><a href="ProfileController" class="sidebar-link"><i class="fas fa-user-edit"></i> Hồ sơ của tôi</a></li>
                <li><a href="MainController?action=ViewOrders" class="sidebar-link"><i class="fas fa-box-open"></i> Đơn hàng của tôi</a></li>
                <li><a href="MainController?action=ViewFavorites" class="sidebar-link"><i class="fas fa-heart"></i> Danh sách yêu thích</a></li>
                <li><a href="NotificationController" class="sidebar-link"><i class="fas fa-bell"></i> Hộp thư thông báo</a></li>
                <li><a href="MainController?action=ViewCart" class="sidebar-link"><i class="fas fa-shopping-bag"></i> Giỏ hàng hiện tại</a></li>
            </ul>
        </div>

        <!-- Nhóm 3: Thông tin hỗ trợ & Thương hiệu (Information) -->
        <div class="sidebar-group">
            <div class="sidebar-group-title">
                <i class="fas fa-info-circle text-brand me-2"></i>Thông tin & Hỗ trợ
            </div>
            <ul class="sidebar-links-list list-unstyled m-0 p-0">
                <li><a href="#" class="sidebar-link" onclick="alert('NutriOverflow - Thương hiệu thực phẩm bổ sung thể hình cao cấp chính hãng Việt Nam. Thành lập năm 2026.');"><i class="fas fa-award"></i> Về thương hiệu</a></li>
                <li><a href="#" class="sidebar-link" onclick="alert('Chính sách đổi trả hàng: Lỗi 1 đổi 1 trong vòng 7 ngày nếu lỗi do nhà sản xuất hoặc quá trình vận chuyển.');"><i class="fas fa-shield-alt"></i> Chính sách đổi trả</a></li>
                <li><a href="#" class="sidebar-link" onclick="alert('Tổng đài hỗ trợ: 1900 6868 (8:00 - 22:00) | Email: support@nutrioverflow.com');"><i class="fas fa-headset"></i> Liên hệ trợ giúp</a></li>
                <li><a href="#" class="sidebar-link" onclick="alert('Hệ thống 3 chi nhánh NutriOverflow:\n- Chi nhánh 1: Quận 1, TP. Hồ Chí Minh\n- Chi nhánh 2: Quận Cầu Giấy, Hà Nội\n- Chi nhánh 3: Quận Hải Châu, Đà Nẵng');"><i class="fas fa-map-marker-alt"></i> Hệ thống cửa hàng</a></li>
            </ul>
        </div>
    </div>
</div>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/fmt"  prefix="fmt"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <title>Thông báo — NutriOverflow</title>
    <jsp:include page="includes/header.jsp"/>
    <style>
        body { 
            background: var(--bg-page);
            min-height: 100vh; 
        }

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

        /* ── NOTIFICATION CARD ── */
        .notif-card {
            display: flex;
            align-items: flex-start;
            gap: 16px;
            background: var(--bg-card);
            border-radius: 20px;
            border: 1.5px solid var(--border);
            padding: 1.2rem 1.6rem;
            margin-bottom: 1.2rem;
            transition: box-shadow 0.25s, border-color 0.25s;
        }
        .notif-card:hover {
            box-shadow: 0 8px 32px rgba(0,0,0,0.09);
            border-color: var(--brand);
            transform: translateY(-1px);
        }
        .notif-card.unread {
            border-color: var(--brand);
            background: #f9fffb;
        }

        /* Text colors inside cards */
        .notif-title-text {
            font-size: 0.88rem;
            font-weight: 800;
            color: var(--txt);
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
        }
        .notif-msg {
            font-size: 0.80rem;
            color: var(--txt-muted);
            line-height: 1.5;
            margin-bottom: 10px;
        }
        .notif-time {
            font-size: 0.73rem;
            color: var(--txt-muted);
        }

        /* Icon */
        .notif-icon-box {
            flex-shrink: 0;
            width: 44px; height: 44px;
            border-radius: 14px;
            display: flex; align-items: center; justify-content: center;
            font-size: 1.1rem;
        }
        .notif-failed    .notif-icon-box { background: rgba(239,68,68,0.12);  color: #ef4444; }
        .notif-success   .notif-icon-box { background: rgba(0,230,118,0.12); color: #00e676; }
        .notif-cancelled .notif-icon-box { background: rgba(245,158,11,0.12); color: #f59e0b; }
        .notif-shipped   .notif-icon-box { background: rgba(99,102,241,0.12); color: #818cf8; }
        .notif-default   .notif-icon-box { background: rgba(156,163,175,0.12); color: #9ca3af; }

        /* Body */
        .notif-body-wrap { flex: 1; min-width: 0; }
        .notif-title-row {
            display: flex; align-items: center; gap: 8px;
            margin-bottom: 4px;
        }
        .unread-dot {
            width: 7px; height: 7px; border-radius: 50%;
            background: #00e676; flex-shrink: 0;
            animation: pulse-dot 2s ease-in-out infinite;
        }
        @keyframes pulse-dot {
            0%,100% { box-shadow: 0 0 0 0 rgba(0,230,118,0.5); }
            50%      { box-shadow: 0 0 0 4px rgba(0,230,118,0); }
        }
        .notif-meta {
            display: flex; align-items: center; gap: 12px; flex-wrap: wrap;
        }
        .notif-order-link {
            font-size: 0.73rem; color: var(--brand-dark); font-weight: 700;
            text-decoration: none;
        }
        .notif-order-link:hover { color: var(--brand-deep); }

        /* Action buttons */
        .notif-actions { display: flex; gap: 8px; flex-wrap: wrap; margin-top: 10px; }
        .btn-notif-retry {
            display: inline-flex; align-items: center; gap: 5px;
            background: linear-gradient(135deg,#ef4444,#dc2626);
            color: #fff !important; font-size: 0.74rem; font-weight: 700;
            padding: 5px 14px; border-radius: 50px;
            text-decoration: none; transition: all 0.2s;
            box-shadow: 0 3px 10px rgba(239,68,68,0.3);
        }
        .btn-notif-retry:hover { transform: translateY(-1px); box-shadow: 0 5px 16px rgba(239,68,68,0.45); }

        .btn-notif-detail {
            display: inline-flex; align-items: center; gap: 6px;
            background: #f3f4f6; border: 1px solid #e5e7eb;
            border-radius: 50px; color: #374151; font-size: 0.74rem; font-weight: 600;
            padding: 5px 14px; text-decoration: none; transition: all 0.2s;
        }
        .btn-notif-detail:hover { background: #e5e7eb; color: #111827; }

        /* ── EMPTY STATE ── */
        .empty-state {
            text-align: center; padding: 5rem 1rem;
        }
        .empty-state i {
            font-size: 4rem; color: #d1d5db; margin-bottom: 1rem; display: block;
        }
        .empty-state h4 { color: var(--txt); font-weight: 800; margin-bottom: 0.5rem; }
        .empty-state p  { color: var(--txt-muted); font-size: 0.875rem; margin-bottom: 1.5rem; }

        /* ── SECTION DIVIDERS ── */
        .notif-section-label {
            font-size: 0.7rem; font-weight: 800; letter-spacing: 1.5px;
            text-transform: uppercase; color: var(--txt-muted);
            padding: 0.5rem 0 0.8rem;
        }

        /* ── BACK BUTTON ── */
        .btn-back-hero {
            display: inline-flex; align-items: center; gap: 8px;
            background: rgba(255,255,255,0.08); border: 1px solid rgba(255,255,255,0.12);
            border-radius: 50px; color: rgba(255,255,255,0.7);
            font-size: 0.8rem; font-weight: 600; padding: 6px 16px;
            text-decoration: none; transition: all 0.2s; margin-bottom: 1.2rem;
        }
        .btn-back-hero:hover { background: rgba(255,255,255,0.14); color: #fff; }

        /* ── TOAST ── */
        #retryToastNotif {
            display: none;
            position: fixed; bottom: 2rem; left: 50%; transform: translateX(-50%);
            background: #1a0a0a; border: 1.5px solid rgba(239,68,68,0.4); border-radius: 16px;
            padding: 0.85rem 1.5rem; color: #fff; font-size: 0.88rem; font-weight: 600;
            z-index: 9999; align-items: center; gap: 10px; box-shadow: 0 12px 40px rgba(0,0,0,0.5);
            white-space: nowrap;
        }
    </style>
</head>
<body>
<jsp:include page="includes/navbar.jsp"/>

<!-- PAGE HERO -->
<div class="page-hero">
    <div class="container">
        <h1>
            <i class="fas fa-bell me-2" style="color:#f59e0b;"></i>Thông báo
        </h1>
        <p>Cập nhật về đơn hàng và thanh toán của bạn</p>
    </div>
</div>

<!-- TOAST for retry tab open -->
<div id="retryToastNotif">
    <i class="fas fa-external-link-alt" style="color:#ef4444;"></i>
    Cổng thanh toán VNPay đã được mở trong tab mới!
</div>

<div class="container pb-5" style="max-width: 900px;">
    <div class="notif-list">

        <c:choose>
            <c:when test="${not empty requestScope.NOTIFICATIONS}">

                <%-- Count unread for display --%>
                <c:set var="unreadCount" value="0"/>
                <c:forEach var="n" items="${requestScope.NOTIFICATIONS}">
                    <c:if test="${!n.read}"><c:set var="unreadCount" value="${unreadCount + 1}"/></c:if>
                </c:forEach>

                <div class="d-flex align-items-center justify-content-between mb-3">
                    <div class="text-muted" style="font-size:0.84rem;">
                        <strong style="color: var(--txt);">${requestScope.NOTIFICATIONS.size()}</strong> thông báo
                        <c:if test="${unreadCount > 0}">
                            — <span class="text-brand fw-bold">${unreadCount} chưa đọc</span>
                        </c:if>
                    </div>
                    <a href="don-hang" class="text-decoration-none fw-bold" style="color: var(--brand-dark); font-size:0.78rem;">
                        <i class="fas fa-box-open me-1"></i>Xem đơn hàng
                    </a>
                </div>

                <c:forEach var="n" items="${requestScope.NOTIFICATIONS}">
                    <div class="notif-card ${n.typeColorClass} ${!n.read ? 'unread' : ''}">

                        <%-- Icon --%>
                        <div class="notif-icon-box">
                            <i class="fas ${n.typeIcon}"></i>
                        </div>

                        <%-- Body --%>
                        <div class="notif-body-wrap">
                            <div class="notif-title-row">
                                <span class="notif-title-text">${n.title}</span>
                                <c:if test="${!n.read}">
                                    <span class="unread-dot"></span>
                                </c:if>
                            </div>
                            <div class="notif-msg">${n.message}</div>

                            <div class="notif-meta">
                                <span class="notif-time">
                                    <i class="far fa-clock me-1"></i>
                                    <fmt:formatDate value="${n.createdAt}" pattern="dd/MM/yyyy HH:mm"/>
                                </span>
                                <c:if test="${n.orderId > 0}">
                                    <a href="don-hang?orderId=${n.orderId}"
                                       class="notif-order-link">
                                        <i class="fas fa-hashtag" style="font-size:0.65rem;"></i>Đơn hàng #${n.orderId}
                                    </a>
                                </c:if>
                            </div>

                            <%-- Action buttons --%>
                            <c:if test="${n.orderId > 0}">
                                <div class="notif-actions">
                                    <c:if test="${n.retryable}">
                                        <a href="RetryPaymentController?orderId=${n.orderId}"
                                           class="btn-notif-retry" target="_blank"
                                           onclick="showRetryToastNotif()">
                                            <i class="fas fa-redo"></i> Thanh toán lại
                                        </a>
                                    </c:if>
                                    <a href="don-hang?orderId=${n.orderId}"
                                        class="btn-notif-detail">
                                        <i class="fas fa-eye"></i> Xem chi tiết
                                    </a>
                                </div>
                            </c:if>
                        </div>
                    </div>
                </c:forEach>

            </c:when>
            <c:otherwise>
                <div class="empty-state">
                    <i class="far fa-bell-slash"></i>
                    <h4>Chưa có thông báo nào</h4>
                    <p>Thông báo về đơn hàng và thanh toán của bạn sẽ xuất hiện ở đây.</p>
                    <a href="cua-hang" class="btn btn-brand">Mua sắm ngay</a>
                </div>
            </c:otherwise>
        </c:choose>

    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<script>
function showRetryToastNotif() {
    var t = document.getElementById('retryToastNotif');
    t.style.display = 'flex';
    setTimeout(function() { t.style.display = 'none'; }, 4000);
}

// Cross-tab: if payment result comes in while on this page, refresh
window.addEventListener('storage', function(e) {
    if (e.key !== 'nf_payment_result') return;
    try {
        var d = JSON.parse(e.newValue);
        if (Date.now() - d.ts < 10000) {
            // Refresh page to show new notification
            setTimeout(function() { window.location.reload(); }, 1200);
        }
    } catch(err) {}
});
</script>

    <jsp:include page="includes/footer.jsp" />
</body>
</html>

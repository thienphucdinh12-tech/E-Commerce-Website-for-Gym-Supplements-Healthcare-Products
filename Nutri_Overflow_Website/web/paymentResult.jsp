<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <title>Kết quả thanh toán — NutriOverflow</title>
    <jsp:include page="includes/header.jsp"/>
    <style>
        * { box-sizing: border-box; margin: 0; padding: 0; }

        body {
            background: #0a0a12;
            min-height: 100vh;
            display: flex;
            flex-direction: column;
            font-family: 'Inter', sans-serif;
        }

        /* ── HERO RESULT AREA ── */
        .result-wrapper {
            flex: 1;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 3rem 1rem;
        }

        .result-card {
            background: #13131f;
            border-radius: 28px;
            border: 1.5px solid rgba(255,255,255,0.07);
            padding: 3rem 2.5rem;
            max-width: 520px;
            width: 100%;
            text-align: center;
            position: relative;
            overflow: hidden;
            box-shadow: 0 32px 80px rgba(0,0,0,0.6);
        }

        /* Glow ring behind icon */
        .result-card::before {
            content: '';
            position: absolute;
            top: -60px; left: 50%;
            transform: translateX(-50%);
            width: 300px; height: 300px;
            border-radius: 50%;
            filter: blur(60px);
            opacity: 0.25;
            pointer-events: none;
        }
        .result-card.success::before { background: #00e676; }
        .result-card.failed::before  { background: #ef4444; }
        .result-card.invalid::before { background: #f59e0b; }
        .result-card.error::before   { background: #6b7280; }

        /* ── ICON ── */
        .result-icon {
            width: 96px; height: 96px;
            border-radius: 50%;
            display: flex; align-items: center; justify-content: center;
            margin: 0 auto 1.5rem;
            font-size: 2.4rem;
            position: relative;
            z-index: 1;
        }
        .result-card.success .result-icon { background: rgba(0,230,118,0.15); color: #00e676; border: 2px solid rgba(0,230,118,0.4); }
        .result-card.failed  .result-icon { background: rgba(239,68,68,0.12); color: #ef4444; border: 2px solid rgba(239,68,68,0.3); }
        .result-card.invalid .result-icon { background: rgba(245,158,11,0.12); color: #f59e0b; border: 2px solid rgba(245,158,11,0.3); }
        .result-card.error   .result-icon { background: rgba(107,114,128,0.12); color: #9ca3af; border: 2px solid rgba(107,114,128,0.3); }

        /* ── TITLE ── */
        .result-title {
            font-size: 1.6rem;
            font-weight: 900;
            color: #fff;
            margin-bottom: 0.6rem;
            position: relative; z-index: 1;
        }
        .result-card.success .result-title { color: #00e676; }
        .result-card.failed  .result-title { color: #ef4444; }
        .result-card.invalid .result-title { color: #f59e0b; }

        .result-subtitle {
            font-size: 0.9rem;
            color: rgba(255,255,255,0.55);
            line-height: 1.6;
            margin-bottom: 2rem;
            position: relative; z-index: 1;
        }

        /* ── INFO GRID ── */
        .info-grid {
            background: rgba(255,255,255,0.04);
            border-radius: 16px;
            border: 1px solid rgba(255,255,255,0.06);
            padding: 1.2rem 1.4rem;
            margin-bottom: 1.8rem;
            text-align: left;
            position: relative; z-index: 1;
        }
        .info-row {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 0.4rem 0;
            font-size: 0.85rem;
        }
        .info-row:not(:last-child) { border-bottom: 1px solid rgba(255,255,255,0.06); }
        .info-label { color: rgba(255,255,255,0.4); font-weight: 500; }
        .info-val   { color: #fff; font-weight: 700; }
        .info-val.green { color: #00e676; }
        .info-val.red   { color: #ef4444; }

        /* ── BUTTONS ── */
        .btn-group-result {
            display: flex;
            flex-direction: column;
            gap: 0.75rem;
            position: relative; z-index: 1;
        }
        .btn-result-primary {
            display: flex; align-items: center; justify-content: center; gap: 8px;
            padding: 0.85rem 1.5rem;
            border-radius: 14px;
            font-size: 0.9rem;
            font-weight: 700;
            text-decoration: none;
            cursor: pointer;
            border: none;
            transition: all 0.2s;
        }
        .btn-success-primary {
            background: linear-gradient(135deg, #00e676, #00c853);
            color: #0a0a12;
            box-shadow: 0 4px 20px rgba(0,230,118,0.3);
        }
        .btn-success-primary:hover { transform: translateY(-1px); box-shadow: 0 6px 28px rgba(0,230,118,0.45); color: #0a0a12; }

        .btn-failed-primary {
            background: linear-gradient(135deg, #ef4444, #dc2626);
            color: #fff;
            box-shadow: 0 4px 20px rgba(239,68,68,0.3);
        }
        .btn-failed-primary:hover { transform: translateY(-1px); box-shadow: 0 6px 28px rgba(239,68,68,0.45); color: #fff; }

        .btn-result-secondary {
            display: flex; align-items: center; justify-content: center; gap: 8px;
            padding: 0.75rem 1.5rem;
            border-radius: 14px;
            font-size: 0.85rem;
            font-weight: 600;
            text-decoration: none;
            background: rgba(255,255,255,0.06);
            color: rgba(255,255,255,0.7);
            border: 1px solid rgba(255,255,255,0.1);
            transition: all 0.2s;
        }
        .btn-result-secondary:hover { background: rgba(255,255,255,0.1); color: #fff; }

        /* ── SUCCESS PARTICLES ── */
        .confetti-wrap {
            position: fixed; top: 0; left: 0;
            width: 100%; height: 100%;
            pointer-events: none;
            overflow: hidden;
            z-index: 999;
        }
        .confetti-piece {
            position: absolute;
            width: 8px; height: 8px;
            border-radius: 2px;
            animation: confettiFall linear forwards;
            opacity: 0;
        }
        @keyframes confettiFall {
            0%   { transform: translateY(-20px) rotate(0deg); opacity: 1; }
            100% { transform: translateY(110vh) rotate(720deg); opacity: 0; }
        }

        /* ── ICON ANIMATION ── */
        @keyframes iconPop {
            0%   { transform: scale(0) rotate(-15deg); opacity: 0; }
            60%  { transform: scale(1.15) rotate(5deg); opacity: 1; }
            100% { transform: scale(1) rotate(0deg); opacity: 1; }
        }
        .result-icon { animation: iconPop 0.5s cubic-bezier(.34,1.56,.64,1) 0.2s both; }

        @keyframes cardSlideIn {
            0%   { transform: translateY(30px); opacity: 0; }
            100% { transform: translateY(0); opacity: 1; }
        }
        .result-card { animation: cardSlideIn 0.4s ease 0.05s both; }
    </style>
</head>
<body>
<jsp:include page="includes/navbar.jsp"/>

<%-- Confetti for success --%>
<c:if test="${requestScope.PAYMENT_STATUS == 'SUCCESS'}">
    <div class="confetti-wrap" id="confettiWrap"></div>
</c:if>

<div class="result-wrapper">

    <%-- ═══ SUCCESS ═══ --%>
    <c:if test="${requestScope.PAYMENT_STATUS == 'SUCCESS'}">
        <div class="result-card success">
            <div class="result-icon"><i class="fas fa-check"></i></div>
            <div class="result-title">Thanh toán thành công!</div>
            <div class="result-subtitle">
                Cảm ơn bạn đã đặt hàng. Đội ngũ của chúng tôi đang chuẩn bị hàng và sẽ sớm giao đến bạn.
            </div>

            <div class="info-grid">
                <c:if test="${not empty requestScope.ORDER_ID and requestScope.ORDER_ID > 0}">
                    <div class="info-row">
                        <span class="info-label">Mã đơn hàng</span>
                        <span class="info-val green">#${requestScope.ORDER_ID}</span>
                    </div>
                </c:if>
                <c:if test="${not empty requestScope.VNP_TRANSACTION_NO}">
                    <div class="info-row">
                        <span class="info-label">Mã giao dịch</span>
                        <span class="info-val">${requestScope.VNP_TRANSACTION_NO}</span>
                    </div>
                </c:if>
                <c:if test="${not empty requestScope.VNP_BANK_CODE}">
                    <div class="info-row">
                        <span class="info-label">Ngân hàng</span>
                        <span class="info-val">${requestScope.VNP_BANK_CODE}</span>
                    </div>
                </c:if>
                <div class="info-row">
                    <span class="info-label">Trạng thái</span>
                    <span class="info-val green"><i class="fas fa-circle" style="font-size:0.5rem;"></i> Đang xử lý — Chờ giao hàng</span>
                </div>
            </div>

            <div class="btn-group-result">
                <a href="don-hang" class="btn-result-primary btn-success-primary">
                    <i class="fas fa-box-open"></i> Xem đơn hàng của tôi
                </a>
                <a href="cua-hang" class="btn-result-secondary">
                    <i class="fas fa-shopping-bag"></i> Tiếp tục mua sắm
                </a>
            </div>
        </div>
    </c:if>

    <%-- ═══ FAILED ═══ --%>
    <c:if test="${requestScope.PAYMENT_STATUS == 'FAILED'}">
        <div class="result-card failed">
            <div class="result-icon"><i class="fas fa-times"></i></div>
            <div class="result-title">Thanh toán thất bại</div>
            <div class="result-subtitle">
                ${requestScope.MESSAGE}<br>
                Đơn hàng của bạn đã được lưu — bạn có thể thanh toán lại bất cứ lúc nào trong mục <strong style="color:#fff;">Đơn hàng của tôi</strong>.
            </div>

            <div class="info-grid">
                <c:if test="${not empty requestScope.ORDER_ID and requestScope.ORDER_ID > 0}">
                    <div class="info-row">
                        <span class="info-label">Mã đơn hàng</span>
                        <span class="info-val">#${requestScope.ORDER_ID}</span>
                    </div>
                </c:if>
                <div class="info-row">
                    <span class="info-label">Trạng thái</span>
                    <span class="info-val red"><i class="fas fa-circle" style="font-size:0.5rem;"></i> Thanh toán thất bại — Đơn hàng chờ</span>
                </div>
                <div class="info-row">
                    <span class="info-label">Bước tiếp theo</span>
                    <span class="info-val">Đơn hàng của tôi → Thanh toán ngay</span>
                </div>
            </div>

            <div class="btn-group-result">
                <c:if test="${not empty requestScope.ORDER_ID and requestScope.ORDER_ID > 0}">
                    <a href="don-hang?orderId=${requestScope.ORDER_ID}"
                       class="btn-result-primary btn-failed-primary">
                        <i class="fas fa-redo"></i> Thử thanh toán lại ngay
                    </a>
                </c:if>
                <a href="don-hang" class="btn-result-secondary">
                    <i class="fas fa-box-open"></i> Đến Đơn hàng của tôi
                </a>
                <a href="gio-hang" class="btn-result-secondary">
                    <i class="fas fa-shopping-cart"></i> Quay lại giỏ hàng
                </a>
            </div>
        </div>
    </c:if>

    <%-- ═══ INVALID SIGNATURE ═══ --%>
    <c:if test="${requestScope.PAYMENT_STATUS == 'INVALID'}">
        <div class="result-card invalid">
            <div class="result-icon"><i class="fas fa-shield-alt"></i></div>
            <div class="result-title">Giao dịch không hợp lệ</div>
            <div class="result-subtitle">
                Chữ ký giao dịch không thể xác minh. Yêu cầu có thể đã bị can thiệp. Vui lòng liên hệ với đội ngũ hỗ trợ của chúng tôi.
            </div>
            <div class="btn-group-result">
                <a href="cua-hang" class="btn-result-secondary">
                    <i class="fas fa-home"></i> Về cửa hàng
                </a>
            </div>
        </div>
    </c:if>

    <%-- ═══ ERROR ═══ --%>
    <c:if test="${requestScope.PAYMENT_STATUS == 'ERROR' or (empty requestScope.PAYMENT_STATUS)}">
        <div class="result-card error">
            <div class="result-icon"><i class="fas fa-exclamation-circle"></i></div>
            <div class="result-title">Đã xảy ra lỗi</div>
            <div class="result-subtitle">
                Đã xảy ra lỗi không mong muốn trong khi xử lý thanh toán. Đơn hàng có thể vẫn được lưu — vui lòng kiểm tra Đơn hàng của tôi hoặc liên hệ hỗ trợ.
            </div>
            <div class="btn-group-result">
                <a href="don-hang" class="btn-result-secondary">
                    <i class="fas fa-box-open"></i> Kiểm tra đơn hàng của tôi
                </a>
                <a href="cua-hang" class="btn-result-secondary">
                    <i class="fas fa-home"></i> Về cửa hàng
                </a>
            </div>
        </div>
    </c:if>

</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<script>
// ── Cross-tab signal: notify giỏ hàng / các tab khác về kết quả thanh toán ──
(function() {
    var status  = '${requestScope.PAYMENT_STATUS}';
    var orderId = '${requestScope.ORDER_ID}';
    if (!status) return;

    // Map to simplified status for tabs
    var signalStatus = (status === 'SUCCESS') ? 'SUCCESS' : 'FAILED';

    try {
        localStorage.setItem('nf_payment_result', JSON.stringify({
            status:  signalStatus,
            orderId: orderId,
            ts:      Date.now()
        }));
        // Remove after 30s to prevent stale signals
        setTimeout(function() { localStorage.removeItem('nf_payment_result'); }, 30000);
    } catch(e) {}
})();
</script>
<script>
// ── Confetti burst for success ──
(function() {
    var wrap = document.getElementById('confettiWrap');
    if (!wrap) return;
    var colors = ['#00e676','#00c853','#64ffda','#fff59d','#80cbc4','#a5d6a7','#fff'];
    function randomBetween(a, b) { return a + Math.random() * (b - a); }
    for (var i = 0; i < 80; i++) {
        (function(i) {
            setTimeout(function() {
                var el = document.createElement('div');
                el.className = 'confetti-piece';
                el.style.left = randomBetween(5, 95) + '%';
                el.style.width = randomBetween(6, 12) + 'px';
                el.style.height = randomBetween(6, 12) + 'px';
                el.style.background = colors[Math.floor(Math.random() * colors.length)];
                el.style.borderRadius = Math.random() > 0.5 ? '50%' : '2px';
                var dur = randomBetween(1.5, 3.5);
                el.style.animationDuration = dur + 's';
                el.style.animationDelay = '0s';
                wrap.appendChild(el);
                setTimeout(function() { el.remove(); }, dur * 1000 + 100);
            }, i * 30);
        })(i);
    }
})();
</script>

    <jsp:include page="includes/footer.jsp" />
</body>
</html>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<!DOCTYPE html>
<html lang="en">
    <head>
        <title>Giỏ hàng — NutriOverflow</title>
        <jsp:include page="includes/header.jsp" />
        <style>
            /* VNPay button */
            .btn-vnpay {
                background: linear-gradient(135deg, #00e676, #00c853);
                color: #0a0a12 !important;
                border: none;
                font-weight: 800;
                padding: 0.75rem 2.2rem;
                border-radius: 50px;
                font-size: 0.95rem;
                display: inline-flex; align-items: center; gap: 8px;
                box-shadow: 0 4px 20px rgba(0,230,118,0.35);
                transition: all 0.2s;
                cursor: pointer;
            }
            .btn-vnpay:hover  { transform: translateY(-2px); box-shadow: 0 6px 28px rgba(0,230,118,0.5); }
            .btn-vnpay:active { transform: translateY(0); }
            .btn-vnpay:disabled, .btn-vnpay.disabled {
                opacity: 0.6; cursor: not-allowed; transform: none;
                background: linear-gradient(135deg, #4caf50, #388e3c);
            }
            .btn-vnpay .vnpay-logo {
                font-size: 0.7rem; background: rgba(0,0,0,0.15);
                border-radius: 4px; padding: 1px 6px; font-weight: 900;
            }

            /* Status hint below button */
            .checkout-status {
                font-size: 0.76rem; margin-top: 8px;
                display: none; align-items: center; gap: 6px;
                justify-content: flex-end;
            }
            .checkout-status.show { display: flex; }
            .checkout-status.pending { color: #f59e0b; }
            .checkout-status.success { color: #00e676; }
            .checkout-status.failed  { color: #ef4444; }

            .spin-sm {
                display: inline-block;
                width: 14px; height: 14px;
                border: 2px solid rgba(245,158,11,0.3);
                border-top-color: #f59e0b;
                border-radius: 50%;
                animation: spin 0.8s linear infinite;
            }
            @keyframes spin { to { transform: rotate(360deg); } }
        </style>
    </head>
    <body>
        <jsp:include page="includes/navbar.jsp" />

        <div class="container mt-5 pb-5">
            <h2 class="mb-4 fw-bold"><i class="fas fa-shopping-bag text-brand"></i> Giỏ hàng</h2>

            <c:if test="${not empty requestScope.ERROR_MESSAGE}">
                <div class="alert alert-danger"><i class="fas fa-exclamation-triangle"></i> ${requestScope.ERROR_MESSAGE}</div>
            </c:if>

            <c:choose>
                <c:when test="${not empty sessionScope.CART and not empty sessionScope.CART.cart}">
                    <div class="card shadow-sm border-0 rounded-4 overflow-hidden">
                        <table class="table table-hover align-middle mb-0">
                            <thead class="table-dark">
                                <tr>
                                    <th>STT</th>
                                    <th>Sản phẩm</th>
                                    <th>Đơn giá</th>
                                    <th>Số lượng</th>
                                    <th>Tổng tiền</th>
                                    <th class="text-center">Thao tác</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:set var="totalMoney" value="0" />
                                <c:forEach var="item" items="${sessionScope.CART.cart.values()}" varStatus="counter">
                                    <c:set var="subTotal" value="${item.price * item.quantity}" />
                                    <c:set var="totalMoney" value="${totalMoney + subTotal}" />
                                    <tr>
                                        <td>${counter.count}</td>
                                        <td class="fw-bold">${item.name}</td>
                                        <td class="text-muted">${String.format("%,.0f", item.price)} ₫</td>
                                        <form action="MainController" method="POST">
                                            <td style="width: 150px;">
                                                <input type="hidden" name="id" value="${item.id}"/>
                                                <input type="number" name="quantity" class="form-control text-center"
                                                       value="${item.quantity}" min="1"/>
                                            </td>
                                            <td class="text-brand fw-bold">${String.format("%,.0f", subTotal)} ₫</td>
                                            <td class="text-center">
                                                <button type="submit" name="action" value="Edit"
                                                        class="btn btn-sm btn-info text-white">
                                                    <i class="fas fa-sync-alt"></i>
                                                </button>
                                                <button type="submit" name="action" value="Remove"
                                                        class="btn btn-sm btn-danger"
                                                        onclick="return confirm('Xóa sản phẩm này?')">
                                                    <i class="fas fa-trash"></i>
                                                </button>
                                            </td>
                                        </form>
                                    </tr>
                                </c:forEach>
                            </tbody>
                        </table>
                    </div>

                    <div class="row mt-4">
                        <div class="col-md-6 text-md-start">
                            <a href="cua-hang" class="btn btn-outline-secondary">
                                <i class="fas fa-arrow-left"></i> Tiếp tục mua sắm
                            </a>
                        </div>
                        <div class="col-md-6 text-md-end">
                            <h4 class="mb-3">Tổng cộng:
                                <span class="text-danger fw-bold">${String.format("%,.0f", totalMoney)} ₫</span>
                            </h4>

                            <c:choose>
                                <c:when test="${empty sessionScope.LOGIN_USER}">
                                    <a href="dang-nhap" class="btn btn-warning btn-lg fw-bold">
                                        <i class="fas fa-sign-in-alt"></i> Đăng nhập để đặt hàng
                                    </a>
                                </c:when>
                                <c:otherwise>
                                    <form action="thanh-toan" method="GET"
                                          id="checkoutForm">
                                        <button type="submit" class="btn-vnpay" id="checkoutBtn">
                                            <i class="fas fa-clipboard-check"></i>
                                            Tiến hành đặt hàng
                                            <i class="fas fa-arrow-right" style="font-size:0.8rem;"></i>
                                        </button>
                                    </form>

                                    <p class="text-muted mt-2" style="font-size:0.75rem;">
                                        <i class="fas fa-shield-alt me-1 text-success"></i>
                                        Chọn địa chỉ, mã giảm giá &amp; thanh toán ở bước tiếp theo
                                    </p>
                                </c:otherwise>
                            </c:choose>
                        </div>
                    </div>
                </c:when>
                <c:otherwise>
                    <div class="text-center py-5">
                        <i class="fas fa-box-open fa-5x text-muted mb-3"></i>
                        <h4>Giỏ hàng của bạn đang trống!</h4>
                        <p class="text-muted">Hãy thêm sản phẩm vào giỏ để bắt đầu mua sắm.</p>
                        <a href="cua-hang" class="btn btn-brand mt-2">Đến cửa hàng</a>
                    </div>
                </c:otherwise>
            </c:choose>
        </div>

        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
        <script>
        var checkoutReenableTimer = null;

        function onCheckoutSubmit(e) {
            var btn    = document.getElementById('checkoutBtn');
            var status = document.getElementById('checkoutStatus');
            var icon   = document.getElementById('checkoutStatusIcon');
            var text   = document.getElementById('checkoutStatusText');

            // Disable button, show pending state
            btn.disabled = true;
            btn.classList.add('disabled');
            icon.innerHTML = '<span class="spin-sm"></span>';
            text.textContent = 'Đang mở cổng thanh toán VNPay...';
            status.className = 'checkout-status show pending';

            // Re-enable after 90s in case user closed VNPay tab without result
            checkoutReenableTimer = setTimeout(function() {
                reenableCheckout('failed', '⚠ Cổng thanh toán đã đóng. Bạn có thể thử lại.');
            }, 90000);
        }

        function reenableCheckout(state, msg) {
            var btn    = document.getElementById('checkoutBtn');
            var status = document.getElementById('checkoutStatus');
            var icon   = document.getElementById('checkoutStatusIcon');
            var text   = document.getElementById('checkoutStatusText');
            if (!btn) return;

            btn.disabled = false;
            btn.classList.remove('disabled');

            if (state === 'success') {
                icon.innerHTML = '<i class="fas fa-check-circle" style="color:#00e676;"></i>';
                text.textContent = msg || 'Thanh toán thành công! Đang tải lại...';
                status.className = 'checkout-status show success';
            } else if (state === 'failed') {
                icon.innerHTML = '<i class="fas fa-times-circle" style="color:#ef4444;"></i>';
                text.textContent = msg || 'Thanh toán thất bại. Vui lòng thử lại.';
                status.className = 'checkout-status show failed';
            }
            clearTimeout(checkoutReenableTimer);
        }

        // Listen for cross-tab payment result from VNPay tab
        window.addEventListener('storage', function(e) {
            if (e.key !== 'nf_payment_result' || !e.newValue) return;
            try {
                var d = JSON.parse(e.newValue);
                if (Date.now() - d.ts > 15000) return; // stale

                clearTimeout(checkoutReenableTimer);

                if (d.status === 'SUCCESS') {
                    reenableCheckout('success', '✓ Thanh toán thành công! Đang dọn giỏ hàng...');
                    setTimeout(function() { window.location.reload(); }, 1800);
                } else {
                    reenableCheckout('failed',
                        '✗ Thanh toán thất bại cho đơn hàng #' + d.orderId + '. Bạn có thể thử lại.');
                }
            } catch(err) {}
        });
        </script>
    
    <jsp:include page="includes/footer.jsp" />
</body>
</html>
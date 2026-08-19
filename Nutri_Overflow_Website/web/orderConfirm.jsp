<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt"%>
<%
    if (session.getAttribute("LOGIN_USER") == null) {
        response.sendRedirect("dang-nhap"); return;
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <title>Xác nhận đơn hàng — NutriOverflow</title>
    <jsp:include page="includes/header.jsp" />
    <style>
        /* ── PAGE HERO ── */
        .page-hero {
            background: linear-gradient(135deg, #0a0a12 0%, #0d1f10 100%);
            padding: 2rem 0 1.8rem;
            margin-bottom: 2rem;
        }
        .page-hero h1 { font-size: 1.5rem; font-weight: 900; color: #fff; margin: 0; }
        .page-hero p  { color: rgba(255,255,255,0.5); font-size: 0.83rem; margin: 5px 0 0; }

        /* ── LAYOUT ── */
        .confirm-layout {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 1.8rem;
            max-width: 1160px;
            margin: 0 auto;
            padding: 0 1.5rem 4rem;
            align-items: start;
        }
        @media (max-width: 900px) {
            .confirm-layout { grid-template-columns: 1fr; }
        }

        /* ── CARDS ── */
        .confirm-card {
            position: relative;
            background: #fff;
            border-radius: 20px;
            border: 1.5px solid #eef0f3;
            overflow: visible;
            margin-bottom: 1.4rem;
            box-shadow: 0 2px 16px rgba(0,0,0,0.05);
            transition: box-shadow 0.2s ease;
        }
        .confirm-card:hover {
            box-shadow: 0 4px 24px rgba(0,0,0,0.08);
        }
        .confirm-card:nth-of-type(1) { z-index: 3; }
        .confirm-card:nth-of-type(2) { z-index: 2; }
        .confirm-card:nth-of-type(3) { z-index: 1; }
        .confirm-card:focus-within { z-index: 10 !important; }

        .card-header-section {
            display: flex; align-items: center; gap: 12px;
            padding: 1.15rem 1.5rem;
            border-bottom: 1.5px solid #f3f4f6;
            background: linear-gradient(135deg, #f9fafb, #f3f4f6);
            border-top-left-radius: 18px;
            border-top-right-radius: 18px;
        }
        .card-header-section h3 {
            font-size: 1.1rem; font-weight: 800; color: var(--txt); margin: 0; letter-spacing: -0.2px;
        }
        .card-header-section .header-num {
            width: 32px; height: 32px; border-radius: 50%;
            background: linear-gradient(135deg, var(--brand), var(--brand-dark));
            color: #0a0a12; font-size: 0.88rem; font-weight: 900;
            display: flex; align-items: center; justify-content: center; flex-shrink: 0;
            box-shadow: 0 2px 8px rgba(0,230,118,0.3);
        }
        .card-body-section { padding: 1.5rem 1.5rem; }

        /* ── ORDER SUMMARY TABLE ── */
        .order-item-row {
            display: flex; align-items: center;
            padding: 0.75rem 0;
            border-bottom: 1px solid #f3f4f6;
            gap: 12px;
        }
        .order-item-row:last-child { border-bottom: none; padding-bottom: 0; }
        .item-name { flex: 1; font-size: 0.92rem; font-weight: 600; color: var(--txt); line-height: 1.4; }
        .item-qty  { font-size: 0.85rem; color: var(--txt-muted); min-width: 35px; text-align: center;
            background: #f3f4f6; border-radius: 6px; padding: 2px 8px; font-weight: 600; }
        .item-price { font-size: 0.92rem; font-weight: 700; color: #dc2626; min-width: 110px; text-align: right; }

        .summary-divider { height: 1px; background: #f3f4f6; margin: 0.75rem 0; }
        .summary-row {
            display: flex; justify-content: space-between;
            align-items: center;
            padding: 0.45rem 0;
            font-size: 0.92rem;
            color: var(--txt-muted);
        }
        .summary-row.total {
            border-top: 2px solid #f3f4f6;
            margin-top: 0.6rem; padding-top: 0.9rem;
            font-size: 1.1rem; font-weight: 900; color: var(--txt);
        }
        .summary-row .discount-val { color: #10b981; font-weight: 700; }
        .summary-row .total-val { color: #dc2626; font-size: 1.15rem; }

        /* ── ADDRESS ── */
        .address-display {
            background: #f9fffb;
            border: 1.5px solid rgba(0,230,118,0.3);
            border-radius: 12px;
            padding: 1rem 1.2rem;
            font-size: 0.92rem;
            color: var(--txt);
            line-height: 1.6;
            position: relative;
        }
        .btn-edit-address {
            position: absolute; top: 10px; right: 12px;
            font-size: 0.72rem; font-weight: 700;
            color: var(--brand-dark); background: none; border: none;
            cursor: pointer; text-decoration: underline;
        }

        /* ── COUPON ── */
        .coupon-wrap { display: flex; gap: 10px; }
        .coupon-wrap .form-control {
            border-radius: 50px !important; font-size: 0.92rem;
            text-transform: uppercase; letter-spacing: 1.5px;
            border: 1.5px solid #e5e7eb; padding: 0.65rem 1.2rem;
        }
        .coupon-wrap .form-control:focus { border-color: var(--brand); box-shadow: 0 0 0 3px rgba(0,230,118,0.12); }
        .btn-apply {
            background: #f3f4f6; border: 1.5px solid #e5e7eb;
            border-radius: 50px; font-size: 0.92rem; font-weight: 700;
            padding: 0 1.4rem; color: var(--txt); cursor: pointer;
            transition: all 0.2s; white-space: nowrap;
        }
        .btn-apply:hover { background: var(--brand); border-color: var(--brand); color: #0a0a12; }
        .coupon-result {
            font-size: 0.82rem; font-weight: 600; margin-top: 8px;
            display: none; align-items: center; gap: 6px; padding: 8px 12px;
            border-radius: 10px;
        }
        .coupon-result.success { color: #059669; display: flex; background: #f0fdf4; }
        .coupon-result.error   { color: #dc2626; display: flex; background: #fef2f2; }

        /* ── PAYMENT METHOD ── */
        .pay-option {
            border: 2px solid #eef0f3;
            border-radius: 16px;
            padding: 1rem 1.2rem;
            cursor: pointer;
            transition: all 0.22s ease;
            display: flex; align-items: center; gap: 14px;
            margin-bottom: 0.85rem;
            background: #fff;
        }
        .pay-option:last-child { margin-bottom: 0; }
        .pay-option:hover { border-color: var(--brand); background: #f9fffb; transform: translateY(-1px); box-shadow: 0 4px 16px rgba(0,230,118,0.1); }
        .pay-option.selected {
            border-color: var(--brand);
            background: rgba(0,230,118,0.04);
            box-shadow: 0 0 0 3px rgba(0,230,118,0.15);
        }
        .pay-option input[type="radio"] { display: none; }
        .pay-icon {
            width: 48px; height: 48px; border-radius: 14px;
            display: flex; align-items: center; justify-content: center;
            font-size: 1.4rem; flex-shrink: 0;
        }
        .pay-vnpay .pay-icon { background: linear-gradient(135deg, rgba(0,230,118,0.15), rgba(0,200,100,0.08)); }
        .pay-cod   .pay-icon { background: linear-gradient(135deg, rgba(245,158,11,0.15), rgba(217,119,6,0.08)); }
        .pay-info { flex: 1; min-width: 0; }
        .pay-title { font-size: 0.92rem; font-weight: 800; color: var(--txt); margin-bottom: 3px; }
        .pay-desc  { font-size: 0.78rem; color: var(--txt-muted); line-height: 1.45; }
        .pay-badge {
            flex-shrink: 0;
            font-size: 0.7rem; font-weight: 700;
            border-radius: 50px; padding: 4px 10px;
        }
        .badge-secure { background: rgba(0,230,118,0.12); color: var(--brand-dark); }
        .badge-free   { background: rgba(245,158,11,0.12); color: #b45309; }

        /* ── PLACE ORDER BUTTON ── */
        .btn-place-order {
            width: 100%;
            background: linear-gradient(135deg, var(--brand) 0%, #00c853 50%, var(--brand-dark) 100%);
            color: #0a0a12;
            border: none;
            font-weight: 900;
            font-size: 1.05rem;
            border-radius: 50px;
            padding: 1rem 2rem;
            display: flex; align-items: center; justify-content: center; gap: 12px;
            cursor: pointer;
            transition: all 0.25s ease;
            box-shadow: 0 6px 24px rgba(0,230,118,0.4);
            letter-spacing: 0.3px;
            margin-top: 0.5rem;
        }
        .btn-place-order:hover {
            transform: translateY(-3px);
            box-shadow: 0 12px 32px rgba(0,230,118,0.55);
            background: linear-gradient(135deg, var(--brand-dark), var(--brand-deep));
            color: #fff;
        }
        .btn-place-order:active { transform: translateY(-1px); }
        .btn-place-order.cod-mode {
            background: linear-gradient(135deg, #f59e0b, #e8940a, #d97706);
            box-shadow: 0 6px 24px rgba(245,158,11,0.4);
            color: #fff;
        }
        .btn-place-order.cod-mode:hover {
            box-shadow: 0 12px 32px rgba(245,158,11,0.5);
        }
        .order-security-note {
            text-align: center; margin-top: 0.85rem;
            font-size: 0.76rem; color: var(--txt-muted);
            display: flex; align-items: center; justify-content: center; gap: 5px;
        }

        /* ── ERROR ALERT ── */
        .alert-error {
            background: #fef2f2; color: #991b1b;
            border-left: 4px solid #ef4444;
            border-radius: 10px;
            padding: 0.85rem 1.1rem;
            font-size: 0.87rem; font-weight: 600;
            margin-bottom: 1.2rem;
            display: flex; align-items: center; gap: 10px;
        }

        /* ── BREADCRUMB ── */
        .checkout-steps {
            display: flex; align-items: center; gap: 6px;
            font-size: 0.78rem; font-weight: 600;
        }
        .step { color: rgba(255,255,255,0.4); }
        .step.done { color: rgba(255,255,255,0.6); }
        .step.active { color: var(--brand); }
        .step-arrow { color: rgba(255,255,255,0.25); font-size: 0.65rem; }

        /* ── CUSTOM SELECT DROPDOWNS ── */
        .custom-select-wrapper {
            position: relative;
            width: 100%;
            user-select: none;
            margin-bottom: 0.85rem;
        }
        .custom-select-trigger {
            display: flex;
            align-items: center;
            justify-content: space-between;
            padding: 0.8rem 1.2rem;
            font-size: 0.92rem;
            color: #374151;
            background: #fff;
            border: 1.5px solid #e5e7eb;
            border-radius: 12px;
            cursor: pointer;
            transition: all 0.2s ease;
        }
        .custom-select-trigger:after {
            content: '\f078';
            font-family: 'Font Awesome 5 Free';
            font-weight: 900;
            font-size: 0.8rem;
            color: #6b7280;
            transition: transform 0.2s ease;
        }
        .custom-select-wrapper.open .custom-select-trigger {
            border-color: var(--brand);
            box-shadow: 0 0 0 3px rgba(0,230,118,0.12);
        }
        .custom-select-wrapper.open .custom-select-trigger:after {
            transform: rotate(180deg);
        }
        .custom-select-options {
            position: absolute;
            top: 105%;
            left: 0;
            width: 100%;
            background: #fff;
            border: 1px solid #e5e7eb;
            border-radius: 12px;
            box-shadow: 0 10px 25px rgba(0,0,0,0.08);
            z-index: 1000;
            opacity: 0;
            visibility: hidden;
            transform: translateY(-10px);
            transition: all 0.2s cubic-bezier(0.16, 1, 0.3, 1);
        }
        .custom-select-wrapper.open .custom-select-options {
            opacity: 1;
            visibility: visible;
            transform: translateY(0);
        }
        .custom-select-search-box {
            padding: 10px;
            border-bottom: 1px solid #f3f4f6;
        }
        .custom-select-search-box input {
            border-radius: 8px !important;
            font-size: 0.9rem;
            padding: 6px 12px;
            border: 1px solid #e5e7eb;
            width: 100%;
        }
        .custom-select-list {
            max-height: 280px;
            overflow-y: auto;
        }
        .custom-select-option {
            padding: 10px 16px;
            font-size: 0.92rem;
            color: #374151;
            cursor: pointer;
            transition: all 0.15s;
        }
        .custom-select-option:hover {
            background: #f9fffb;
            color: var(--brand-dark);
        }
        .custom-select-option.selected {
            background: rgba(0,230,118,0.06);
            color: var(--brand-dark);
            font-weight: 700;
        }

        /* ── FORM SELECT FOCUS STYLE ── */
        .form-select:focus, .form-control:focus {
            border-color: var(--brand) !important;
            box-shadow: 0 0 0 3px rgba(0,230,118,0.12) !important;
            outline: none;
        }
        .form-select {
            transition: border-color 0.2s, box-shadow 0.2s;
        }
        .form-select:disabled {
            background-color: #f9fafb;
            color: #9ca3af;
            cursor: not-allowed;
        }

        /* ── ADDRESS SECTION STYLING ── */
        .address-select-group {
            display: flex;
            flex-direction: column;
            gap: 0.65rem;
            margin-bottom: 0.65rem;
        }
        .address-select-group .form-select {
            border-radius: 12px;
            border: 1.5px solid #e5e7eb;
            padding: 0.75rem 1rem;
            font-size: 0.92rem;
            height: auto;
        }
        #addressInput.form-control, #phoneInput.form-control {
            border-radius: 12px !important;
            border: 1.5px solid #e5e7eb;
            padding: 0.75rem 1rem;
            font-size: 0.92rem;
        }
    </style>
</head>
<body class="bg-light">
<jsp:include page="includes/navbar.jsp" />

<!-- PAGE HERO -->
<div class="page-hero">
    <div class="container">
        <div class="checkout-steps mb-2">
            <span class="step done"><i class="fas fa-shopping-bag me-1"></i>Giỏ hàng</span>
            <span class="step-arrow">›</span>
            <span class="step active"><i class="fas fa-clipboard-check me-1"></i>Xác nhận đơn hàng</span>
            <span class="step-arrow">›</span>
            <span class="step">Thanh toán</span>
        </div>
        <h1><i class="fas fa-clipboard-check me-2" style="color:var(--brand);"></i>Xác nhận đơn hàng của bạn</h1>
        <p>Kiểm tra lại sản phẩm, nhập địa chỉ nhận hàng và chọn phương thức thanh toán</p>
    </div>
</div>

<form method="POST" action="thanh-toan" id="orderForm">
    <input type="hidden" name="action" value="PlaceOrder">
    <input type="hidden" name="couponCode" id="hiddenCoupon" value="">
    <input type="hidden" name="paymentMethod" id="hiddenPayment" value="VNPAY">
    <input type="hidden" name="discountAmount" id="hiddenDiscount" value="0">
    <input type="hidden" name="shippingFee" id="hiddenShipping" value="30000">

    <div class="confirm-layout container" style="max-width:1080px;">

        <!-- ── LEFT: Step 1 (Summary) & Step 2 (Coupon) ── -->
        <div>
            <%-- Error message --%>
            <c:if test="${not empty ERROR_MSG}">
                <div class="alert-error">
                    <i class="fas fa-exclamation-circle"></i>
                    ${ERROR_MSG}
                </div>
            </c:if>
            <% String errMsg = (String) request.getAttribute("ERROR_MSG");
               if (errMsg == null && request.getParameter("err") != null) out.print(""); %>

            <!-- STEP 1: Tóm tắt đơn hàng -->
            <div class="confirm-card">
                <div class="card-header-section">
                    <div class="header-num">1</div>
                    <h3><i class="fas fa-box me-1" style="color:#6366f1;"></i> Tóm tắt đơn hàng</h3>
                </div>
                <div class="card-body-section">
                    <c:set var="grossTotal" value="0"/>
                    <c:forEach var="item" items="${sessionScope.CART.cart.values()}">
                        <c:set var="sub" value="${item.price * item.quantity}"/>
                        <c:set var="grossTotal" value="${grossTotal + sub}"/>
                        <div class="order-item-row">
                            <div class="item-name">${item.name}</div>
                            <div class="item-qty">×${item.quantity}</div>
                            <div class="item-price"><fmt:formatNumber value="${sub}" pattern="#,###"/> ₫</div>
                        </div>
                    </c:forEach>

                    <!-- Totals -->
                    <div style="margin-top:1rem;">
                        <div class="summary-row">
                            <span>Tạm tính</span>
                            <span id="subtotalDisplay"><fmt:formatNumber value="${grossTotal}" pattern="#,###"/> ₫</span>
                        </div>
                        <div class="summary-row" id="discountRow" style="display:none;">
                            <span>Giảm giá (<span id="discountPctLabel"></span>)</span>
                            <span class="discount-val">– <span id="discountAmtDisplay">0</span> ₫</span>
                        </div>
                        <div class="summary-row" id="shippingRow" style="display:flex;">
                            <span>Phí vận chuyển</span>
                            <span id="shippingFeeDisplay">Đang tính...</span>
                        </div>
                        <div class="summary-row total">
                            <span>Tổng tiền thanh toán</span>
                            <span class="total-val" id="totalDisplay"><fmt:formatNumber value="${grossTotal}" pattern="#,###"/> ₫</span>
                        </div>
                    </div>
                </div>
            </div>

            <!-- STEP 2: Coupon -->
            <div class="confirm-card">
                <div class="card-header-section">
                    <div class="header-num">2</div>
                    <h3><i class="fas fa-tag me-1" style="color:#f59e0b;"></i> Mã giảm giá <span style="font-weight:400; font-size:0.78rem; color:var(--txt-muted);">(không bắt buộc)</span></h3>
                </div>
                <div class="card-body-section">
                    <div class="coupon-wrap">
                        <input type="text" class="form-control" id="couponInput"
                               placeholder="Ví dụ: WELCOME10"
                               maxlength="50" autocomplete="off"
                               oninput="this.value = this.value.toUpperCase()">
                        <button type="button" class="btn-apply" onclick="applyCoupon()">Áp dụng</button>
                    </div>
                    <div class="coupon-result" id="couponResult">
                        <i class="fas fa-check-circle"></i>
                        <span id="couponResultText"></span>
                    </div>
                </div>
            </div>

            <!-- Back to cart link -->
            <a href="gio-hang" class="text-decoration-none"
               style="font-size:0.82rem; color: var(--txt-muted); display:inline-flex; align-items:center; gap:6px; margin-top:0.5rem; margin-bottom:1.5rem;">
                <i class="fas fa-arrow-left"></i> Quay lại giỏ hàng
            </a>
        </div>

        <!-- ── RIGHT: Step 3 (Address) & Step 4 (Payment) & Submit ── -->
        <div>
            <!-- STEP 3: Shipping Address -->
            <div class="confirm-card" style="z-index: 10;">
                <div class="card-header-section">
                    <div class="header-num">3</div>
                    <h3><i class="fas fa-map-marker-alt me-1" style="color:#ef4444;"></i> Địa chỉ giao hàng</h3>
                </div>
                <div class="card-body-section">
                    <c:if test="${not empty requestScope.PROFILE.address}">
                        <div style="border: 1.5px dashed rgba(0,230,118,0.45); border-radius: 14px; background: linear-gradient(135deg, #f0fff4, #fafdfb); padding: 0.9rem 1.1rem; margin-bottom: 1.1rem;">
                            <div class="form-check d-flex align-items-center gap-2" style="margin: 0;">
                                <input class="form-check-input" type="checkbox" id="useProfileAddress" onchange="toggleUseProfileAddress()" style="width:18px; height:18px; cursor:pointer; flex-shrink:0;" ${not empty requestScope.PROFILE.address ? 'checked' : ''}>
                                <label class="form-check-label fw-bold" for="useProfileAddress" style="font-size:0.88rem; cursor:pointer; color:#059669; margin:0;">
                                    <i class="fas fa-home me-1"></i> Sử dụng địa chỉ mặc định trong hồ sơ
                                </label>
                            </div>
                            <p class="mb-0" id="profileAddressText" style="font-size:0.82rem; color:#6b7280; padding-left:28px; margin-top:6px; line-height:1.5;">${requestScope.PROFILE.address}</p>
                        </div>
                    </c:if>
                    
                    <div class="mb-3">
                        <label class="form-label" style="font-size:0.82rem; font-weight:700; color:var(--txt-muted); text-transform:uppercase;"><i class="fas fa-phone-alt me-1" style="color:#10b981;"></i> Số điện thoại nhận hàng *</label>
                        <input type="text" class="form-control" name="recipientPhone" id="phoneInput"
                               placeholder="Nhập số điện thoại nhận hàng..." 
                               value="${not empty requestScope.PROFILE.phone ? requestScope.PROFILE.phone : ''}" required>
                    </div>

                    <label class="form-label" style="font-size:0.82rem; font-weight:700; color:var(--txt-muted); text-transform:uppercase;"><i class="fas fa-map me-1" style="color:#10b981;"></i> Khu vực giao hàng *</label>
                    <div class="mb-3">
                        <select class="form-select" id="ghnProvince" onchange="loadDistricts()">
                            <option value="">Chọn Tỉnh/Thành</option>
                        </select>
                    </div>
                    <div class="row g-2 mb-3">
                        <div class="col-6">
                            <select class="form-select" id="ghnDistrict" name="districtId" onchange="loadWards()" disabled>
                                <option value="">Chọn Quận/Huyện</option>
                            </select>
                        </div>
                        <div class="col-6">
                            <select class="form-select" id="ghnWard" name="wardCode" onchange="calcShipping()" disabled>
                                <option value="">Chọn Phường/Xã</option>
                            </select>
                        </div>
                    </div>
                    <div id="debugLocationStatus" style="font-size:0.76rem; color:#6b7280; margin-bottom:8px; min-height:0;"></div>
                    
                    <div class="mb-2">
                        <label class="form-label" style="font-size:0.82rem; font-weight:700; color:var(--txt-muted); text-transform:uppercase;"><i class="fas fa-home me-1" style="color:#10b981;"></i> Địa chỉ cụ thể *</label>
                        <input type="text" class="form-control" name="streetAddress" id="addressInput" 
                               placeholder="Số nhà, tên đường, tòa nhà..." 
                               onblur="calcShipping()" 
                               value="<c:out value="${param.streetAddress}"/>" required>
                    </div>
                    <div class="form-check mt-2 mb-1">
                        <input class="form-check-input" type="checkbox" name="saveDefaultAddress" value="true" id="saveDefaultAddressChk" style="cursor:pointer;" checked>
                        <label class="form-check-label text-muted" for="saveDefaultAddressChk" style="font-size:0.82rem; cursor:pointer; font-weight:600;">
                            <i class="fas fa-bookmark text-success me-1"></i> Lưu thông tin & địa chỉ này làm mặc định cho tài khoản
                        </label>
                    </div>
                    <input type="hidden" name="shippingAddress" id="hiddenShippingAddress">
                </div>
            </div>

            <!-- STEP 4: Payment Method -->
            <div class="confirm-card" style="z-index: 5;">
                <div class="card-header-section">
                    <div class="header-num">4</div>
                    <h3><i class="fas fa-credit-card me-1" style="color:#6366f1;"></i> Phương thức thanh toán</h3>
                </div>
                <div class="card-body-section">
                    <!-- VNPay Option -->
                    <label class="pay-option pay-vnpay selected" for="payVnpay" id="labelVnpay"
                           onclick="selectPayment('VNPAY')">
                        <input type="radio" id="payVnpay" name="_paymentRadio" value="VNPAY" checked>
                        <div class="pay-icon">💳</div>
                        <div class="pay-info">
                            <div class="pay-title">Chuyển khoản VNPay QR</div>
                            <div class="pay-desc">Quét mã QR qua ứng dụng ngân hàng. An toàn & tức thì.</div>
                        </div>
                        <span class="pay-badge badge-secure">🔒 Bảo mật</span>
                    </label>

                    <!-- COD Option -->
                    <label class="pay-option pay-cod" for="payCod" id="labelCod"
                           onclick="selectPayment('COD')">
                        <input type="radio" id="payCod" name="_paymentRadio" value="COD">
                        <div class="pay-icon">🏠</div>
                        <div class="pay-info">
                            <div class="pay-title">Thanh toán khi nhận hàng (COD)</div>
                            <div class="pay-desc">Trả tiền mặt khi nhận hàng. Không cần thẻ.</div>
                        </div>
                        <span class="pay-badge badge-free">Miễn phí</span>
                    </label>
                </div>
            </div>

            <!-- PLACE ORDER BUTTON -->
            <button type="button" class="btn-place-order" id="placeOrderBtn" onclick="submitOrder()">
                <i class="fas fa-lock" id="btnIcon"></i>
                <span id="btnLabel">Thanh toán qua VNPay</span>
                <i class="fas fa-arrow-right"></i>
            </button>
            <div class="order-security-note">
                <i class="fas fa-shield-alt" style="color: var(--brand-dark);"></i>
                <span>Thông tin của bạn được bảo vệ và mã hóa an toàn.</span>
            </div>
        </div>

    </div>
</form>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<script>
// ── Globals ────────────────────────────────────────────────────────────────
var grossTotal    = ${grossTotal};
var discountAmt   = 0;
var discountPct   = 0;
var shippingFee   = 30000; // Default
var selectedPayment = 'VNPAY';

// ── GHN Location API ──────────────────────────────────────────────────────
window.onload = function() {
    loadProvinces();
    initCustomSelect('ghnProvince', 'Chọn Tỉnh/Thành');
    initCustomSelect('ghnDistrict', 'Chọn Quận/Huyện');
    initCustomSelect('ghnWard', 'Chọn Phường/Xã');
    
    var useProfileAddress = document.getElementById('useProfileAddress');
    if (useProfileAddress && useProfileAddress.checked) {
        toggleUseProfileAddress();
    }
};

function loadProvinces() {
    fetch('api/ghn-location?type=province&t=' + new Date().getTime())
        .then(res => res.json())
        .then(data => {
            let select = document.getElementById('ghnProvince');
            select.innerHTML = '<option value="">Chọn Tỉnh/Thành</option>';
            if (data.error) {
                console.error("API Error:", data.error);
                alert("Error loading provinces: " + data.error);
                return;
            }
            data.forEach(item => {
                select.innerHTML += '<option value="' + item.ProvinceID + '">' + item.ProvinceName + '</option>';
            });
            if (select.customSelect) select.customSelect.update();
        }).catch(err => {
            console.error("Fetch error:", err);
            let dbg = document.getElementById('debugLocationStatus');
            if (dbg) dbg.innerHTML = "[DEBUG] Fetch error: " + err.message;
        });
}

function loadDistricts() {
    let provId = document.getElementById('ghnProvince').value;
    let distSelect = document.getElementById('ghnDistrict');
    let wardSelect = document.getElementById('ghnWard');
    wardSelect.innerHTML = '<option value="">Chọn Phường/Xã</option>';
    if (wardSelect.customSelect) {
        wardSelect.customSelect.update();
        wardSelect.customSelect.setPlaceholder('Chọn Phường/Xã');
    }
    wardSelect.disabled = true;
    
    if (!provId) {
        distSelect.innerHTML = '<option value="">Chọn Quận/Huyện</option>';
        if (distSelect.customSelect) {
            distSelect.customSelect.update();
            distSelect.customSelect.setPlaceholder('Chọn Quận/Huyện');
        }
        distSelect.disabled = true;
        calcShipping();
        return;
    }
    
    fetch('api/ghn-location?type=district&province_id=' + provId + '&t=' + new Date().getTime())
        .then(res => res.json())
        .then(data => {
            distSelect.innerHTML = '<option value="">Chọn Quận/Huyện</option>';
            if (data.error) {
                console.error("API Error:", data.error);
                return;
            }
            data.forEach(item => {
                distSelect.innerHTML += '<option value="' + item.DistrictID + '">' + item.DistrictName + '</option>';
            });
            distSelect.disabled = false;
            if (distSelect.customSelect) distSelect.customSelect.update();
        }).catch(err => {
            console.error("Fetch error:", err);
            let dbg = document.getElementById('debugLocationStatus');
            if (dbg) dbg.innerHTML = "[DEBUG] Fetch error: " + err.message;
        });
    calcShipping();
}

function loadWards() {
    let distId = document.getElementById('ghnDistrict').value;
    let wardSelect = document.getElementById('ghnWard');
    
    if (!distId) {
        wardSelect.innerHTML = '<option value="">Chọn Phường/Xã</option>';
        if (wardSelect.customSelect) {
            wardSelect.customSelect.update();
            wardSelect.customSelect.setPlaceholder('Chọn Phường/Xã');
        }
        wardSelect.disabled = true;
        return;
    }
    
    fetch('api/ghn-location?type=ward&district_id=' + distId + '&t=' + new Date().getTime())
        .then(res => res.json())
        .then(data => {
            wardSelect.innerHTML = '<option value="">Chọn Phường/Xã</option>';
            if (data.error) {
                console.error("API Error:", data.error);
                return;
            }
            data.forEach(item => {
                wardSelect.innerHTML += '<option value="' + item.WardCode + '">' + item.WardName + '</option>';
            });
            wardSelect.disabled = false;
            if (wardSelect.customSelect) wardSelect.customSelect.update();
        }).catch(err => console.error("Fetch error:", err));
    calcShipping();
}

function calcShipping() {
    var distId = document.getElementById('ghnDistrict').value;
    var wardCode = document.getElementById('ghnWard').value;
    
    if (!distId || !wardCode) {
        shippingFee = 0;
        document.getElementById('shippingFeeDisplay').textContent = 'Vui lòng chọn địa chỉ';
        document.getElementById('hiddenShipping').value = 0;
        updateTotals();
        return;
    }
    
    document.getElementById('shippingFeeDisplay').innerHTML = '<span class="spin-sm"></span>';
    var xhr = new XMLHttpRequest();
    xhr.open('POST', 'OrderConfirmController', true);
    xhr.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');
    xhr.onreadystatechange = function () {
        if (xhr.readyState === 4 && xhr.status === 200) {
            try {
                var data = JSON.parse(xhr.responseText);
                shippingFee = data.shippingFee;
                document.getElementById('shippingFeeDisplay').textContent = formatVnd(shippingFee) + ' ₫';
                document.getElementById('hiddenShipping').value = shippingFee;
                updateTotals();
            } catch(e) {
                console.error(e);
            }
        }
    };
    xhr.send('action=CalculateShipping&districtId=' + encodeURIComponent(distId) + '&wardCode=' + encodeURIComponent(wardCode));
}

// ── Auto-parse profile address helper ────────────────────────────────────────
function toggleUseProfileAddress() {
    var checkbox = document.getElementById('useProfileAddress');
    var provinceSel = document.getElementById('ghnProvince');
    var districtSel = document.getElementById('ghnDistrict');
    var wardSel = document.getElementById('ghnWard');
    var streetInput = document.getElementById('addressInput');
    
    if (checkbox.checked) {
        var addrText = document.getElementById('profileAddressText').textContent.trim();
        if (!addrText) return;
        
        provinceSel.disabled = true;
        districtSel.disabled = true;
        wardSel.disabled = true;
        streetInput.disabled = true;
        
        document.getElementById('debugLocationStatus').innerHTML = '<span style="color:var(--brand-dark); font-weight:bold;"><i class="fas fa-spinner fa-spin me-1"></i>Đang tự động phân tích địa chỉ của bạn...</span>';
        
        var parts = addrText.split(',').map(s => s.trim());
        if (parts.length < 3) {
            document.getElementById('debugLocationStatus').innerHTML = '<span style="color:#ef4444;">Địa chỉ hồ sơ ngắn quá. Vui lòng chọn thủ công bên dưới.</span>';
            resetSelectors();
            return;
        }
        
        var provName = parts[parts.length - 1];
        var distName = parts[parts.length - 2];
        var wardName = parts[parts.length - 3];
        
        var streetParts = parts.slice(0, parts.length - 3);
        var streetVal = streetParts.join(', ');
        if (!streetVal) streetVal = parts[0];
        
        function cleanName(name) {
            if (!name) return "";
            return name.toLowerCase()
                .replace(/tỉnh|thành phố|tp|quận|q\.|huyện|h\.|phường|p\.|xã|thị xã|thị trấn/g, "")
                .trim()
                .normalize("NFD").replace(/[\u0300-\u036f]/g, "")
                .replace(/đ/g, "d");
        }
        
        var cleanProvTarget = cleanName(provName);
        var cleanDistTarget = cleanName(distName);
        var cleanWardTarget = cleanName(wardName);
        
        fetch('api/ghn-location?type=province&t=' + new Date().getTime())
            .then(res => res.json())
            .then(provinces => {
                var matchedProv = provinces.find(p => cleanName(p.ProvinceName) === cleanProvTarget || p.ProvinceName.toLowerCase().includes(provName.toLowerCase()));
                if (!matchedProv) {
                    matchedProv = provinces.find(p => cleanName(p.ProvinceName).includes(cleanProvTarget) || cleanProvTarget.includes(cleanName(p.ProvinceName)));
                }
                
                if (!matchedProv) {
                    throw new Error("Không tìm thấy Tỉnh/Thành tương ứng trong hệ thống GHN.");
                }
                
                provinceSel.value = matchedProv.ProvinceID;
                if (provinceSel.customSelect) provinceSel.customSelect.update();
                
                return fetch('api/ghn-location?type=district&province_id=' + matchedProv.ProvinceID + '&t=' + new Date().getTime())
                    .then(res => res.json())
                    .then(districts => {
                        var matchedDist = districts.find(d => cleanName(d.DistrictName) === cleanDistTarget);
                        if (!matchedDist) {
                            matchedDist = districts.find(d => cleanName(d.DistrictName).includes(cleanDistTarget) || cleanDistTarget.includes(cleanName(d.DistrictName)));
                        }
                        
                        if (!matchedDist) {
                            throw new Error("Không tìm thấy Quận/Huyện tương ứng trong hệ thống GHN.");
                        }
                        
                        districtSel.innerHTML = '<option value="">Chọn Quận/Huyện</option>';
                        districts.forEach(item => {
                            districtSel.innerHTML += '<option value="' + item.DistrictID + '">' + item.DistrictName + '</option>';
                        });
                        districtSel.value = matchedDist.DistrictID;
                        districtSel.disabled = true;
                        if (districtSel.customSelect) districtSel.customSelect.update();
                        
                        return fetch('api/ghn-location?type=ward&district_id=' + matchedDist.DistrictID + '&t=' + new Date().getTime())
                            .then(res => res.json())
                            .then(wards => {
                                var matchedWard = wards.find(w => cleanName(w.WardName) === cleanWardTarget);
                                if (!matchedWard) {
                                    matchedWard = wards.find(w => cleanName(w.WardName).includes(cleanWardTarget) || cleanWardTarget.includes(cleanName(w.WardName)));
                                }
                                
                                if (!matchedWard) {
                                    throw new Error("Không tìm thấy Phường/Xã tương ứng trong hệ thống GHN.");
                                }
                                
                                wardSel.innerHTML = '<option value="">Chọn Phường/Xã</option>';
                                wards.forEach(item => {
                                    wardSel.innerHTML += '<option value="' + item.WardCode + '">' + item.WardName + '</option>';
                                });
                                wardSel.value = matchedWard.WardCode;
                                wardSel.disabled = true;
                                if (wardSel.customSelect) wardSel.customSelect.update();
                                
                                streetInput.value = streetVal;
                                streetInput.disabled = true;
                                
                                document.getElementById('debugLocationStatus').innerHTML = '<span style="color:#00c853; font-weight:bold;"><i class="fas fa-check-circle me-1"></i>Đã phân tích địa chỉ và tính phí giao hàng thành công!</span>';
                                provinceSel.disabled = true;
                                
                                calcShipping();
                            });
                    });
            })
            .catch(err => {
                console.error(err);
                document.getElementById('debugLocationStatus').innerHTML = '<span style="color:#ef4444;"><i class="fas fa-exclamation-triangle me-1"></i>Không thể tự động phân tích (' + err.message + '). Vui lòng chọn thủ công.</span>';
                resetSelectors();
            });
    } else {
        resetSelectors();
        document.getElementById('debugLocationStatus').innerHTML = '';
    }
}

function resetSelectors() {
    var provinceSel = document.getElementById('ghnProvince');
    var districtSel = document.getElementById('ghnDistrict');
    var wardSel = document.getElementById('ghnWard');
    var streetInput = document.getElementById('addressInput');
    
    provinceSel.value = "";
    provinceSel.disabled = false;
    if (provinceSel.customSelect) {
        provinceSel.customSelect.update();
        provinceSel.customSelect.setPlaceholder('Chọn Tỉnh/Thành');
    }
    
    districtSel.innerHTML = '<option value="">Chọn Quận/Huyện</option>';
    districtSel.disabled = true;
    if (districtSel.customSelect) {
        districtSel.customSelect.update();
        districtSel.customSelect.setPlaceholder('Chọn Quận/Huyện');
    }
    
    wardSel.innerHTML = '<option value="">Chọn Phường/Xã</option>';
    wardSel.disabled = true;
    if (wardSel.customSelect) {
        wardSel.customSelect.update();
        wardSel.customSelect.setPlaceholder('Chọn Phường/Xã');
    }
    
    streetInput.value = "";
    streetInput.disabled = false;
    
    shippingFee = 0;
    document.getElementById('shippingFeeDisplay').textContent = 'Vui lòng chọn địa chỉ';
    document.getElementById('hiddenShipping').value = 0;
    updateTotals();
}

// ── CUSTOM SELECT DROPDOWN JS IMPLEMENTATION ──
function initCustomSelect(selectId, placeholder) {
    var nativeSelect = document.getElementById(selectId);
    if (!nativeSelect) return;
    
    var existingWrapper = document.getElementById('wrapper-' + selectId);
    if (existingWrapper) {
        existingWrapper.remove();
    }
    
    nativeSelect.style.display = 'none';
    
    var wrapper = document.createElement('div');
    wrapper.className = 'custom-select-wrapper';
    wrapper.id = 'wrapper-' + selectId;
    
    var trigger = document.createElement('div');
    trigger.className = 'custom-select-trigger';
    trigger.textContent = placeholder;
    wrapper.appendChild(trigger);
    
    var optionsContainer = document.createElement('div');
    optionsContainer.className = 'custom-select-options';
    
    var searchBox = document.createElement('div');
    searchBox.className = 'custom-select-search-box';
    var searchInput = document.createElement('input');
    searchInput.type = 'text';
    searchInput.className = 'form-control form-control-sm';
    searchInput.placeholder = 'Tìm kiếm nhanh...';
    searchInput.autocomplete = 'off';
    searchBox.appendChild(searchInput);
    optionsContainer.appendChild(searchBox);
    
    var list = document.createElement('div');
    list.className = 'custom-select-list';
    optionsContainer.appendChild(list);
    
    wrapper.appendChild(optionsContainer);
    nativeSelect.parentNode.insertBefore(wrapper, nativeSelect.nextSibling);
    
    function updateOptions() {
        list.innerHTML = "";
        var options = nativeSelect.options;
        for (var i = 0; i < options.length; i++) {
            var opt = options[i];
            if (opt.value === "") continue;
            
            var item = document.createElement('div');
            item.className = 'custom-select-option';
            item.setAttribute('data-value', opt.value);
            item.textContent = opt.text;
            if (opt.selected) {
                item.className += ' selected';
                trigger.textContent = opt.text;
            }
            
            item.addEventListener('click', function(e) {
                var val = this.getAttribute('data-value');
                nativeSelect.value = val;
                trigger.textContent = this.textContent;
                
                var event = new Event('change');
                nativeSelect.dispatchEvent(event);
                
                wrapper.classList.remove('open');
                e.stopPropagation();
            });
            list.appendChild(item);
        }
        
        if (nativeSelect.disabled) {
            trigger.style.background = '#f3f4f6';
            trigger.style.color = '#9ca3af';
            trigger.style.cursor = 'not-allowed';
            wrapper.style.pointerEvents = 'none';
        } else {
            trigger.style.background = '#fff';
            trigger.style.color = '#374151';
            trigger.style.cursor = 'pointer';
            wrapper.style.pointerEvents = 'auto';
        }
    }
    
    updateOptions();
    
    trigger.addEventListener('click', function(e) {
        if (nativeSelect.disabled) return;
        
        document.querySelectorAll('.custom-select-wrapper').forEach(w => {
            if (w.id !== wrapper.id) w.classList.remove('open');
        });
        
        wrapper.classList.toggle('open');
        if (wrapper.classList.contains('open')) {
            searchInput.value = "";
            filterOptions("");
            setTimeout(() => searchInput.focus(), 100);
        }
        e.stopPropagation();
    });
    
    function filterOptions(term) {
        var cleanTerm = term.trim().toLowerCase().normalize("NFD").replace(/[\u0300-\u036f]/g, "").replace(/đ/g, "d");
        var items = list.querySelectorAll('.custom-select-option');
        items.forEach(item => {
            var text = item.textContent.toLowerCase().normalize("NFD").replace(/[\u0300-\u036f]/g, "").replace(/đ/g, "d");
            if (text.includes(cleanTerm)) {
                item.style.display = 'block';
            } else {
                item.style.display = 'none';
            }
        });
    }
    
    searchInput.addEventListener('input', function() {
        filterOptions(this.value);
    });
    
    nativeSelect.customSelect = {
        update: updateOptions,
        setPlaceholder: function(txt) {
            trigger.textContent = txt;
        }
    };
}

document.addEventListener('click', function() {
    document.querySelectorAll('.custom-select-wrapper').forEach(w => {
        w.classList.remove('open');
    });
});

// ── Payment method selection ───────────────────────────────────────────────
function selectPayment(method) {
    selectedPayment = method;
    document.getElementById('hiddenPayment').value = method;
    document.getElementById('labelVnpay').classList.toggle('selected', method === 'VNPAY');
    document.getElementById('labelCod').classList.toggle('selected', method === 'COD');

    var btn   = document.getElementById('placeOrderBtn');
    var icon  = document.getElementById('btnIcon');
    var label = document.getElementById('btnLabel');
    if (method === 'COD') {
        btn.className   = 'btn-place-order cod-mode';
        icon.className  = 'fas fa-motorcycle';
        label.textContent = 'Đặt hàng COD';
    } else {
        btn.className   = 'btn-place-order';
        icon.className  = 'fas fa-lock';
        label.textContent = 'Thanh toán qua VNPay';
    }
}

// ── Coupon validation (AJAX) ───────────────────────────────────────────────
function applyCoupon() {
    var code      = document.getElementById('couponInput').value.trim().toUpperCase();
    var resultEl  = document.getElementById('couponResult');
    var resultTxt = document.getElementById('couponResultText');
    var applyBtn  = document.querySelector('.btn-apply');

    if (!code) {
        showCouponMsg('error', 'Vui lòng nhập mã giảm giá.');
        return;
    }

    applyBtn.textContent = '...';
    applyBtn.disabled = true;

    var xhr = new XMLHttpRequest();
    xhr.open('POST', 'OrderConfirmController', true);
    xhr.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');
    xhr.onreadystatechange = function () {
        if (xhr.readyState !== 4) return;
        applyBtn.textContent = 'Apply';
        applyBtn.disabled = false;
        try {
            var data = JSON.parse(xhr.responseText);
            if (data.valid) {
                discountPct = data.discountPct;
                discountAmt = data.discountAmount;
                document.getElementById('hiddenCoupon').value = code;
                document.getElementById('hiddenDiscount').value = discountAmt.toFixed(0);
                updateTotals();
                showCouponMsg('success',
                    'Áp dụng mã giảm giá thành công! Bạn tiết kiệm được ' + (data.discountPct > 0 ? data.discountPct + '% (' + formatVnd(discountAmt) + ' ₫)' : formatVnd(discountAmt) + ' ₫'));
            } else {
                // Reset if previously valid
                discountPct = 0; discountAmt = 0;
                document.getElementById('hiddenCoupon').value = '';
                document.getElementById('hiddenDiscount').value = 0;
                updateTotals();
                showCouponMsg('error', data.errorMsg || 'Mã giảm giá không hợp lệ.');
            }
        } catch(e) {
            showCouponMsg('error', 'Lỗi kiểm tra mã. Vui lòng thử lại sau.');
        }
    };
    xhr.send('action=ValidateCoupon&couponCode=' + encodeURIComponent(code));
}

function showCouponMsg(type, msg) {
    var el   = document.getElementById('couponResult');
    var txt  = document.getElementById('couponResultText');
    var icon = el.querySelector('i');
    el.className = 'coupon-result ' + type;
    icon.className = type === 'success' ? 'fas fa-check-circle' : 'fas fa-times-circle';
    txt.textContent = msg;
}

// ── Update totals display ──────────────────────────────────────────────────
function updateTotals() {
    var finalTotal = Math.max(0, grossTotal - discountAmt) + shippingFee;
    document.getElementById('totalDisplay').textContent = formatVnd(finalTotal) + ' ₫';

    var discRow = document.getElementById('discountRow');
    if (discountAmt > 0) {
        discRow.style.display = 'flex';
        document.getElementById('discountPctLabel').textContent = 'Giảm ' + discountPct + '%';
        document.getElementById('discountAmtDisplay').textContent = formatVnd(discountAmt);
    } else {
        discRow.style.display = 'none';
    }
}

function formatVnd(n) {
    return Math.round(n).toLocaleString('vi-VN');
}

// ── Submit order ───────────────────────────────────────────────────────────
function submitOrder() {
    var provSelect = document.getElementById('ghnProvince');
    var distSelect = document.getElementById('ghnDistrict');
    var wardSelect = document.getElementById('ghnWard');
    var street = document.getElementById('addressInput').value;
    
    if (!distSelect.value || !wardSelect.value || !street) {
        alert("Vui lòng nhập đầy đủ địa chỉ giao hàng.");
        return;
    }
    
    // Combine full address before submitting
    var fullAddress = street + ", " + 
        wardSelect.options[wardSelect.selectedIndex].text + ", " +
        distSelect.options[distSelect.selectedIndex].text + ", " +
        provSelect.options[provSelect.selectedIndex].text;
        
    document.getElementById('hiddenShippingAddress').value = fullAddress;

    var btn = document.getElementById('placeOrderBtn');
    btn.disabled = true;
    btn.innerHTML = '<span class="spin-sm"></span> Đang xử lý...';
    document.getElementById('orderForm').submit();
}

// ── Spinner style ──────────────────────────────────────────────────────────
var style = document.createElement('style');
style.textContent = '.spin-sm{display:inline-block;width:16px;height:16px;border:2px solid rgba(0,0,0,0.2);border-top-color:#0a0a12;border-radius:50%;animation:spin .8s linear infinite;}.cod-mode .spin-sm{border-top-color:#fff;}@keyframes spin{to{transform:rotate(360deg);}}';
document.head.appendChild(style);
</script>

    <jsp:include page="includes/footer.jsp" />
</body>
</html>

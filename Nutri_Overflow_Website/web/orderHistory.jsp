<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt"%>
<!DOCTYPE html>
<html lang="en">
    <title>Đơn hàng của tôi — NutriOverflow</title>
    <jsp:include page="includes/header.jsp"/>
    <style>
        body {
            background: #f0f2f5;
        }

        /* ── PAGE HEADER ── */
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

        /* ── STATUS BADGE ── */
        .status-badge {
            display: inline-flex;
            align-items: center;
            gap: 6px;
            border-radius: 50px;
            font-size: 0.74rem;
            font-weight: 700;
            padding: 4px 14px;
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }
        .status-badge .dot {
            width:7px;
            height:7px;
            border-radius:50%;
            background:currentColor;
        }
        .badge-PENDING    {
            background:#fef9c3;
            color:#a16207;
        }
        .badge-PROCESSING {
            background:#e0f2fe;
            color:#075985;
        }
        .badge-DELIVERING,
        .badge-SHIPPING {
            background:#ede9fe;
            color:#5b21b6;
        }
        .badge-DELIVERED  {
            background:#dcfce7;
            color:#166534;
        }
        .badge-CANCELLED  {
            background:#fee2e2;
            color:#991b1b;
        }
        .badge-DEFAULT    {
            background:#f3f4f6;
            color:#374151;
        }

        /* ── ORDER CARD ── */
        .order-card {
            background: #fff;
            border-radius: 20px;
            border: 1.5px solid #f0f0f0;
            overflow: hidden;
            transition: box-shadow 0.25s, border-color 0.25s;
            margin-bottom: 1.2rem;
        }
        .order-card:hover {
            box-shadow: 0 8px 32px rgba(0,0,0,0.09);
            border-color: #e0e0e0;
        }

        .order-card-head {
            padding: 1.2rem 1.6rem;
            display: flex;
            align-items: center;
            justify-content: space-between;
            flex-wrap: wrap;
            gap: 10px;
            border-bottom: 1px solid #f5f5f5;
        }
        .order-id   {
            font-size: 0.82rem;
            font-weight: 800;
            color: #111;
        }
        .order-date {
            font-size: 0.78rem;
            color: #9ca3af;
            margin-top: 2px;
        }

        .order-card-body {
            padding: 1.2rem 1.6rem;
        }

        /* item row */
        .item-row {
            display: flex;
            align-items: center;
            justify-content: space-between;
            padding: 8px 0;
            border-bottom: 1px dashed #f3f4f6;
            font-size: 0.85rem;
        }
        .item-row:last-child {
            border-bottom: none;
        }
        .item-name  {
            color: #374151;
            font-weight: 600;
            flex: 1;
        }
        .item-qty   {
            color: #9ca3af;
            margin: 0 14px;
            white-space: nowrap;
        }
        .item-price {
            color: #e53935;
            font-weight: 700;
            white-space: nowrap;
        }

        /* totals */
        .order-totals {
            border-top: 2px solid #f0f0f0;
            padding: 1rem 1.6rem;
        }
        .total-row {
            display: flex;
            justify-content: space-between;
            font-size: 0.84rem;
            margin-bottom: 6px;
        }
        .total-row.main {
            font-size: 1rem;
            font-weight: 800;
            color: #e53935;
        }

        /* ── DELIVERY TIMELINE ── */
        .timeline {
            display: flex;
            align-items: flex-start;
            gap: 0;
            margin: 1.4rem 0 0;
        }
        .tl-step  {
            flex: 1;
            text-align: center;
            position: relative;
        }
        .tl-step::before {
            content: '';
            position: absolute;
            top: 14px;
            left: calc(-50% + 14px);
            right: calc(50% + 14px);
            height: 3px;
            background: #e5e7eb;
            z-index: 0;
        }
        .tl-step:first-child::before {
            display: none;
        }
        .tl-step.done::before  {
            background: #00e676;
        }
        .tl-dot {
            width: 28px;
            height: 28px;
            border-radius: 50%;
            background: #e5e7eb;
            color: #9ca3af;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            font-size: 0.7rem;
            position: relative;
            z-index: 1;
            transition: all 0.2s;
        }
        .tl-step.done  .tl-dot {
            background: #00e676;
            color: #0a0a0a;
        }
        .tl-step.active .tl-dot {
            background: #00c853;
            color: #fff;
            box-shadow: 0 0 0 4px rgba(0,230,118,0.22);
        }
        .tl-step.cancelled .tl-dot {
            background: #fca5a5;
            color: #991b1b;
        }
        .tl-label {
            font-size: 0.68rem;
            font-weight: 700;
            color: #9ca3af;
            margin-top: 6px;
            line-height: 1.3;
        }
        .tl-step.done .tl-label   {
            color: #00a844;
        }
        .tl-step.active .tl-label {
            color: #00c853;
        }

        /* ── DETAIL VIEW ── */
        .detail-section {
            background: #fff;
            border-radius: 20px;
            border: 1.5px solid #f0f0f0;
            padding: 2rem;
            margin-bottom: 1.5rem;
        }
        .detail-label {
            font-size: 0.72rem;
            font-weight: 800;
            text-transform: uppercase;
            letter-spacing: 1px;
            color: #9ca3af;
            margin-bottom: 6px;
        }
        .info-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 1.2rem;
        }
        .info-item {
        }
        .info-val  {
            font-size: 0.9rem;
            font-weight: 600;
            color: #111827;
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
            color: #374151;
        }
        .empty-state p  {
            color: #9ca3af;
            font-size: 0.875rem;
        }

        /* ── BACK BUTTON ── */
        .btn-back {
            display: inline-flex;
            align-items: center;
            gap: 8px;
            background: rgba(255,255,255,0.1);
            border: 1px solid rgba(255,255,255,0.2);
            border-radius: 50px;
            color: rgba(255,255,255,0.8);
            font-size: 0.8rem;
            font-weight: 600;
            padding: 6px 16px;
            text-decoration: none;
            transition: all 0.2s;
        }
        .btn-back:hover {
            background: rgba(255,255,255,0.18);
            color: #fff;
        }

        /* ── View detail link ── */
        .btn-view-detail {
            display: inline-flex;
            align-items: center;
            gap: 6px;
            background: #f0fff8;
            border: 1px solid #a7f3d0;
            border-radius: 50px;
            color: #065f46;
            font-size: 0.76rem;
            font-weight: 700;
            padding: 5px 14px;
            text-decoration: none;
            transition: all 0.2s;
        }
        .btn-view-detail:hover {
            background: #00e676;
            color: #0a0a0a;
            border-color: #00e676;
        }

        /* ── PAYMENT chip ── */
        .pay-chip {
            display: inline-flex;
            align-items: center;
            gap: 5px;
            background: #f8f9fa;
            border-radius: 8px;
            font-size: 0.78rem;
            font-weight: 700;
            color: #374151;
            padding: 3px 10px;
        }

        /* ── PAYMENT STATUS BADGE ── */
        .payment-badge {
            display: inline-flex;
            align-items: center;
            gap: 5px;
            border-radius: 50px;
            font-size: 0.72rem;
            font-weight: 700;
            padding: 3px 12px;
            text-transform: uppercase;
            letter-spacing: 0.4px;
        }
        .pay-PAID    {
            background: #dcfce7;
            color: #166534;
        }
        .pay-UNPAID  {
            background: #fef9c3;
            color: #a16207;
        }
        .pay-PENDING {
            background: #e0f2fe;
            color: #075985;
        }
        .pay-FAILED  {
            background: #fee2e2;
            color: #991b1b;
        }

        /* ── PAY NOW BUTTON ── */
        .btn-pay-now {
            display: inline-flex;
            align-items: center;
            gap: 6px;
            background: linear-gradient(135deg, #ef4444, #dc2626);
            color: #fff !important;
            border-radius: 50px;
            font-size: 0.76rem;
            font-weight: 700;
            padding: 6px 16px;
            text-decoration: none;
            box-shadow: 0 3px 12px rgba(239,68,68,0.35);
            transition: all 0.2s;
            animation: pulsePayBtn 1.8s ease-in-out infinite;
        }
        .btn-pay-now:hover {
            transform: translateY(-1px);
            box-shadow: 0 5px 18px rgba(239,68,68,0.5);
        }
        @keyframes pulsePayBtn {
            0%,100% {
                box-shadow: 0 3px 12px rgba(239,68,68,0.35);
            }
            50%      {
                box-shadow: 0 3px 20px rgba(239,68,68,0.6);
            }
        }

        /* ── FAILED ORDER BANNER ── */
        .failed-banner {
            background: rgba(239,68,68,0.08);
            border: 1.5px solid rgba(239,68,68,0.25);
            border-radius: 14px;
            padding: 0.85rem 1.2rem;
            display: flex;
            align-items: center;
            gap: 12px;
            margin-bottom: 0.8rem;
        }
        .failed-banner-icon {
            color: #ef4444;
            font-size: 1.2rem;
            flex-shrink: 0;
        }
        .failed-banner-text {
            flex: 1;
            font-size: 0.8rem;
            color: #dc2626;
            font-weight: 600;
        }
        .failed-banner-text span {
            color: rgba(0,0,0,0.5);
            font-weight: 400;
        }

        .btn-cancel-order {
            display: inline-flex;
            align-items: center;
            gap: 6px;
            background: #fff5f5;
            border: 1px solid #fecaca;
            border-radius: 50px;
            color: #dc2626;
            font-size: 0.76rem;
            font-weight: 700;
            padding: 6px 14px;
            text-decoration: none;
            transition: all 0.2s;
            cursor: pointer;
        }
        .btn-cancel-order:hover {
            background: #fee2e2;
            color: #b91c1c;
            border-color: #fca5a5;
        }

        /* ── VERTICAL TIMELINE FOR TRACKING LOGS ── */
        .v-timeline {
            position: relative;
            padding-left: 30px;
            margin: 1.5rem 0;
            border-left: 2px solid #e5e7eb;
        }
        .v-timeline-item {
            position: relative;
            margin-bottom: 1.5rem;
        }
        .v-timeline-item:last-child {
            margin-bottom: 0;
        }
        .v-timeline-icon {
            position: absolute;
            left: -41px;
            top: 2px;
            width: 20px;
            height: 20px;
            border-radius: 50%;
            background: #fff;
            border: 2px solid #00c853;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 0.6rem;
            color: #00c853;
        }
        .v-timeline-item.active .v-timeline-icon {
            background: #00c853;
            color: #fff;
            box-shadow: 0 0 0 4px rgba(0,230,118,0.2);
        }
        .v-timeline-time {
            font-size: 0.75rem;
            color: #9ca3af;
            font-weight: 600;
        }
        .v-timeline-status {
            font-size: 0.85rem;
            font-weight: 700;
            color: #374151;
            margin-top: 2px;
        }
        .v-timeline-desc {
            font-size: 0.82rem;
            color: #6b7280;
            margin-top: 2px;
        }
        /* ── MODAL STYLES ── */
        .payment-option {
            cursor: pointer;
            padding: 1.2rem;
            border-radius: 14px;
            border: 2px solid #e5e7eb;
            background: #fafafa;
            transition: all 0.25s ease;
            margin-bottom: 1rem;
        }
        .payment-option:hover {
            border-color: #00c853;
            background: #f0fff4;
        }
        .payment-option.selected {
            border-color: #00e676 !important;
            background: #e8fbf1 !important;
            box-shadow: 0 4px 12px rgba(0, 230, 118, 0.1);
        }
    </style>
</head>
<body>
    <jsp:include page="includes/navbar.jsp"/>

    <!-- PAGE HERO -->
    <div class="page-hero">
        <div class="container">
            <c:if test="${not empty requestScope.ORDER_DETAIL}">
                <a href="don-hang" class="btn-back mb-3">
                    <i class="fas fa-arrow-left"></i> Tất cả đơn hàng
                </a>
            </c:if>
            <h1><i class="fas fa-box-open me-2" style="color:#00e676;"></i>Đơn hàng của tôi</h1>
            <p>Theo dõi lịch sử đơn hàng và trạng thái giao hàng</p>
        </div>
    </div>

    <div class="container pb-5" style="max-width:900px;">

        <!-- SUCCESS MSG -->
        <c:if test="${not empty sessionScope.ORDER_SUCCESS_MSG}">
            <div class="alert alert-success alert-dismissible fade show" role="alert" style="border-radius:14px; background-color: #dcfce7; color: #166534; border: 1px solid #bbf7d0; padding: 1rem; margin-bottom: 1.2rem;">
                <i class="fas fa-check-circle me-2"></i>${sessionScope.ORDER_SUCCESS_MSG}
                <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
            </div>
            <% session.removeAttribute("ORDER_SUCCESS_MSG"); %>
        </c:if>

        <!-- ERROR MSG -->
        <c:if test="${not empty sessionScope.ORDER_ERROR_MSG}">
            <div class="alert alert-danger alert-dismissible fade show" role="alert" style="border-radius:14px; background-color: #fee2e2; color: #991b1b; border: 1px solid #fecaca; padding: 1rem; margin-bottom: 1.2rem;">
                <i class="fas fa-exclamation-circle me-2"></i>${sessionScope.ORDER_ERROR_MSG}
                <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
            </div>
            <% session.removeAttribute("ORDER_ERROR_MSG"); %>
        </c:if>

        <!-- ERROR -->
        <c:if test="${not empty requestScope.ERROR}">
            <div class="alert alert-danger" style="border-radius:14px;">
                <i class="fas fa-exclamation-circle me-2"></i>${requestScope.ERROR}
            </div>
        </c:if>

        <!-- ═══════════════════════════════════════════════════════
             A) DETAIL VIEW — single order
        ═══════════════════════════════════════════════════════ -->
        <c:if test="${not empty requestScope.ORDER_DETAIL}">
            <c:set var="o" value="${requestScope.ORDER_DETAIL}"/>

            <!-- STATUS + TIMELINE -->
            <div class="detail-section">
                <div class="d-flex align-items-center justify-content-between flex-wrap gap-3 mb-4">
                    <div>
                        <div class="detail-label">Mã đơn hàng</div>
                        <div style="font-size:1.3rem; font-weight:900; color:#111;">#${o.orderId}</div>

                    </div>
                    <c:set var="sc" value="${o.statusColor}"/>
                    <div class="d-flex align-items-center gap-2 flex-wrap">
                        <span class="status-badge badge-${o.status}">
                            <span class="dot"></span>${o.statusLabel}
                        </span>
                        <%-- Payment status badge --%>
                        <c:if test="${not empty o.paymentStatus}">
                            <span class="payment-badge pay-${o.paymentStatus}">
                                <c:choose>
                                    <c:when test="${o.paymentStatus == 'PAID'}"><i class="fas fa-check-circle"></i> Đã thanh toán</c:when>
                                    <c:when test="${o.paymentStatus == 'FAILED'}"><i class="fas fa-times-circle"></i> Thanh toán thất bại</c:when>
                                    <c:when test="${o.paymentStatus == 'PENDING'}"><i class="fas fa-clock"></i> Đang xử lý</c:when>
                                    <c:otherwise><i class="fas fa-hourglass-half"></i> Chưa thanh toán</c:otherwise>
                                </c:choose>
                            </span>
                        </c:if>
                    </div>
                </div>

                <%-- Banner đơn có thể retry trong detail view --%>
                <c:if test="${o.retryable}">
                    <div class="failed-banner">
                        <i class="fas fa-exclamation-circle failed-banner-icon"></i>
                        <div class="failed-banner-text">
                            <c:choose>
                                <c:when test="${o.paymentStatus == 'PENDING'}">Thanh toán chưa hoàn tất. <span>Tiến hành thanh toán để xác nhận đơn hàng.</span></c:when>
                                <c:when test="${o.paymentStatus == 'FAILED'}">Thanh toán thất bại. <span>Chọn phương thức thanh toán để hoàn tất đơn hàng.</span></c:when>
                                <c:otherwise>Đơn hàng chưa thanh toán. <span>Hoàn tất thanh toán ngay.</span></c:otherwise>
                            </c:choose>
                        </div>
                        <a href="javascript:void(0);" onclick="openPaymentModal(${o.orderId})" class="btn-pay-now">
                            <i class="fas fa-credit-card"></i> Thanh toán ngay
                        </a>
                        <a href="javascript:void(0);" onclick="confirmCancelOrder(${o.orderId})" class="btn-cancel-order">
                            <i class="fas fa-trash-alt"></i> Hủy đơn
                        </a>
                    </div>
                </c:if>

                <!-- TIMELINE (hide for CANCELLED) -->
                <c:if test="${o.status != 'CANCELLED'}">
                    <div class="timeline">
                        <c:set var="step" value="${o.timelineStep}"/>
                        <div class="tl-step ${step >= 1 ? (step == 1 ? 'active' : 'done') : ''}">
                            <div class="tl-dot"><i class="fas fa-file-alt"></i></div>
                            <div class="tl-label">Chờ xác nhận</div>
                        </div>
                        <div class="tl-step ${step >= 2 ? (step == 2 ? 'active' : 'done') : ''}">
                            <div class="tl-dot"><i class="fas fa-cog"></i></div>
                            <div class="tl-label">Đang xử lý</div>
                        </div>
                        <div class="tl-step ${step >= 3 ? (step == 3 ? 'active' : 'done') : ''}">
                            <div class="tl-dot"><i class="fas fa-truck"></i></div>
                            <div class="tl-label">Đang giao hàng</div>
                        </div>
                        <div class="tl-step ${step >= 4 ? 'done' : ''}">
                            <div class="tl-dot"><i class="fas fa-check"></i></div>
                            <div class="tl-label">Đã giao hàng</div>
                        </div>
                    </div>
                </c:if>
                <c:if test="${o.status == 'CANCELLED'}">
                    <div class="alert" style="background:#fef2f2;color:#991b1b;border-radius:12px;font-size:0.85rem;margin-top:1rem;border:none;">
                        <i class="fas fa-ban me-2"></i>Đơn hàng này đã bị hủy.
                    </div>
                </c:if>
            </div>

            <!-- ORDER INFO GRID -->
            <div class="detail-section">
                <h6 class="fw-800 mb-3" style="font-size:0.85rem;">Thông tin đơn hàng</h6>
                <div class="info-grid">
                    <div class="info-item">
                        <div class="detail-label"><i class="fas fa-calendar me-1"></i>Ngày đặt hàng</div>
                        <div class="info-val"><fmt:formatDate value="${o.orderDate}" pattern="dd/MM/yyyy HH:mm"/></div>
                    </div>
                    <div class="info-item">
                        <div class="detail-label"><i class="fas fa-credit-card me-1"></i>Phương thức thanh toán</div>
                        <div class="info-val">
                            <span class="pay-chip">
                                <i class="fas fa-wallet" style="color:#00c853;"></i>
                                ${not empty o.paymentMethod ? o.paymentMethod : 'COD'}
                            </span>
                        </div>
                    </div>
                    <c:if test="${not empty o.shippingAddress}">
                        <div class="info-item" style="grid-column: 1 / -1;">
                            <div class="detail-label"><i class="fas fa-map-marker-alt me-1"></i>Địa chỉ giao hàng</div>
                            <div class="info-val">${o.shippingAddress}</div>
                        </div>
                    </c:if>
                    <c:if test="${not empty o.note}">
                        <div class="info-item" style="grid-column: 1 / -1;">
                            <div class="detail-label"><i class="fas fa-sticky-note me-1"></i>Ghi chú</div>
                            <div class="info-val" style="color:#6b7280;">${o.note}</div>
                        </div>
                    </c:if>
                </div>
            </div>

            <!-- DETAILED TRACKING LOGS -->
            <c:if test="${not empty o.trackingLogs}">
                <div class="detail-section">
                    <h6 class="fw-800 mb-3" style="font-size:0.85rem;"><i class="fas fa-history me-1" style="color:#00c853;"></i>Hành trình đơn hàng</h6>
                    <div class="v-timeline">
                        <c:forEach var="log" items="${o.trackingLogs}" varStatus="status">
                            <div class="v-timeline-item ${status.last ? 'active' : ''}">
                                <div class="v-timeline-icon">
                                    <c:choose>
                                        <c:when test="${status.last}">
                                            <i class="fas fa-dot-circle"></i>
                                        </c:when>
                                        <c:otherwise>
                                            <i class="fas fa-check"></i>
                                        </c:otherwise>
                                    </c:choose>
                                </div>
                                <div class="v-timeline-time">
                                    <fmt:formatDate value="${log.updatedAt}" pattern="dd/MM/yyyy HH:mm:ss"/>
                                </div>
                                <div class="v-timeline-status">
                                    <c:choose>
                                        <c:when test="${log.status == 'PENDING'}">Chờ xác nhận</c:when>
                                        <c:when test="${log.status == 'PROCESSING'}">Đang xử lý</c:when>
                                        <c:when test="${log.status == 'DELIVERING' || log.status == 'SHIPPING'}">Đang giao hàng</c:when>
                                        <c:when test="${log.status == 'DELIVERED'}">Đã giao hàng</c:when>
                                        <c:when test="${log.status == 'CANCELLED'}">Đã hủy</c:when>
                                        <c:otherwise>${log.status}</c:otherwise>
                                    </c:choose>
                                </div>
                                <div class="v-timeline-desc">${log.description}</div>
                            </div>
                        </c:forEach>
                    </div>
                </div>
            </c:if>

            <!-- ITEMS TABLE -->
            <div class="detail-section" style="padding-bottom:0;">
                <h6 class="fw-800 mb-3" style="font-size:0.85rem;">Danh sách sản phẩm (${o.totalItems} sản phẩm)</h6>
                <c:forEach var="item" items="${o.items}">
                    <div class="item-row">
                        <div class="item-name">
                            <i class="fas fa-prescription-bottle-alt me-2" style="color:#d1d5db;"></i>${item.productName}
                        </div>
                        <span class="item-qty">x${item.quantity}</span>
                        <span class="item-price"><fmt:formatNumber value="${item.subtotal}" pattern="#,###"/> ₫</span>
                    </div>
                </c:forEach>
            </div>

            <!-- TOTALS -->
            <div class="order-totals" style="background:#fff;border-radius:0 0 20px 20px;border:1.5px solid #f0f0f0;border-top:none;">
                <c:if test="${o.discountApplied > 0}">
                    <div class="total-row" style="color:#6b7280;">
                        <span>Giảm giá</span>
                        <span style="color:#00a844;">- <fmt:formatNumber value="${o.discountApplied}" pattern="#,###"/> ₫</span>
                    </div>
                </c:if>
                <div class="total-row" style="color:#6b7280;">
                    <span>Phí vận chuyển</span>
                    <span><fmt:formatNumber value="${o.shippingFee}" pattern="#,###"/> ₫</span>
                </div>
                <div class="total-row main">
                    <span>Tổng cộng</span>
                    <span><fmt:formatNumber value="${o.totalAmount}" pattern="#,###"/> ₫</span>
                </div>
            </div>
        </c:if>

        <!-- ═══════════════════════════════════════════════════════
             B) LIST VIEW — all orders
         ═══════════════════════════════════════════════════════ -->
        <c:if test="${empty requestScope.ORDER_DETAIL}">
            <c:choose>
                <c:when test="${not empty requestScope.ORDER_LIST}">
                    <div class="d-flex align-items-center justify-content-between mb-3">
                        <h2 class="section-heading" style="font-size:1.1rem;">
                            ${requestScope.ORDER_LIST.size()} đơn hàng
                        </h2>
                    </div>

                    <c:forEach var="o" items="${requestScope.ORDER_LIST}">
                        <div class="order-card">
                            <!-- HEAD -->
                            <div class="order-card-head">
                                <div>
                                    <div class="order-id"><i class="fas fa-hashtag me-1" style="color:#9ca3af;font-size:0.7rem;"></i>Đơn hàng #${o.orderId}</div>

                                    <div class="order-date">
                                        <i class="far fa-clock me-1"></i>
                                        <fmt:formatDate value="${o.orderDate}" pattern="dd/MM/yyyy HH:mm"/>
                                    </div>
                                </div>
                                <div class="d-flex align-items-center gap-2 flex-wrap">
                                    <span class="status-badge badge-${o.status}">
                                        <span class="dot"></span>${o.statusLabel}
                                    </span>
                                    <%-- Payment status badge --%>
                                    <c:if test="${not empty o.paymentStatus}">
                                        <span class="payment-badge pay-${o.paymentStatus}">
                                            <c:choose>
                                                <c:when test="${o.paymentStatus == 'PAID'}"><i class="fas fa-check-circle"></i> Đã thanh toán</c:when>
                                                <c:when test="${o.paymentStatus == 'FAILED'}"><i class="fas fa-times-circle"></i> Thanh toán thất bại</c:when>
                                                <c:when test="${o.paymentStatus == 'PENDING'}"><i class="fas fa-clock"></i> Đang xử lý</c:when>
                                                <c:otherwise><i class="fas fa-hourglass-half"></i> Chưa thanh toán</c:otherwise>
                                            </c:choose>
                                        </span>
                                    </c:if>
                                    <a href="don-hang?orderId=${o.orderId}" class="btn-view-detail">
                                        Chi tiết <i class="fas fa-chevron-right" style="font-size:0.65rem;"></i>
                                    </a>
                                </div>
                            </div>

                            <!-- BODY: failed banner + mini timeline + items preview -->
                            <div class="order-card-body">
                                <!-- Failed/Pending payment banner -->
                                <c:if test="${o.retryable}">
                                    <div class="failed-banner">
                                        <i class="fas fa-exclamation-circle failed-banner-icon"></i>
                                        <div class="failed-banner-text">
                                            <c:choose>
                                                <c:when test="${o.paymentStatus == 'PENDING'}">Thanh toán chưa hoàn tất. <span>Tiến hành thanh toán để xác nhận đơn hàng.</span></c:when>
                                                <c:when test="${o.paymentStatus == 'FAILED'}">Thanh toán thất bại. <span>Chọn phương thức thanh toán để hoàn tất đơn hàng.</span></c:when>
                                                <c:otherwise>Đơn hàng chưa thanh toán. <span>Hoàn tất thanh toán ngay.</span></c:otherwise>
                                            </c:choose>
                                        </div>
                                        <a href="javascript:void(0);" onclick="openPaymentModal(${o.orderId})" class="btn-pay-now">
                                            <i class="fas fa-credit-card"></i> Thanh toán ngay
                                        </a>
                                        <a href="javascript:void(0);" onclick="confirmCancelOrder(${o.orderId})" class="btn-cancel-order">
                                            <i class="fas fa-trash-alt"></i> Hủy đơn
                                        </a>
                                    </div>
                                </c:if>
                                <!-- Mini timeline -->
                                <c:if test="${o.status != 'CANCELLED'}">
                                    <div class="timeline mb-3" style="max-width:420px;">
                                        <c:set var="step" value="${o.timelineStep}"/>
                                        <div class="tl-step ${step>=1?(step==1?'active':'done'):''}">
                                            <div class="tl-dot" style="width:22px;height:22px;font-size:0.6rem;"><i class="fas fa-file-alt"></i></div>
                                            <div class="tl-label">Đã đặt</div>
                                        </div>
                                        <div class="tl-step ${step>=2?(step==2?'active':'done'):''}">
                                            <div class="tl-dot" style="width:22px;height:22px;font-size:0.6rem;"><i class="fas fa-cog"></i></div>
                                            <div class="tl-label">Đang xử lý</div>
                                        </div>
                                        <div class="tl-step ${step>=3?(step==3?'active':'done'):''}">
                                            <div class="tl-dot" style="width:22px;height:22px;font-size:0.6rem;"><i class="fas fa-truck"></i></div>
                                            <div class="tl-label">Đang giao hàng</div>
                                        </div>
                                        <div class="tl-step ${step>=4?'done':''}">
                                            <div class="tl-dot" style="width:22px;height:22px;font-size:0.6rem;"><i class="fas fa-check"></i></div>
                                            <div class="tl-label">Đã giao hàng</div>
                                        </div>
                                    </div>
                                </c:if>

                                <!-- Items preview (max 3) -->
                                <c:forEach var="item" items="${o.items}" end="2">
                                    <div class="item-row">
                                        <div class="item-name"><i class="fas fa-prescription-bottle-alt me-2" style="color:#d1d5db;"></i>${item.productName}</div>
                                        <span class="item-qty">x${item.quantity}</span>
                                        <span class="item-price"><fmt:formatNumber value="${item.subtotal}" pattern="#,###"/> ₫</span>
                                    </div>
                                </c:forEach>
                                <c:if test="${o.items.size() > 3}">
                                    <p class="text-muted mt-1 mb-0" style="font-size:0.78rem;">
                                        <i class="fas fa-plus me-1"></i>+ ${o.items.size() - 3} sản phẩm khác...
                                    </p>
                                </c:if>
                            </div>

                            <!-- FOOT: total -->
                            <div class="order-totals" style="background:#fafafa;">
                                <c:if test="${o.discountApplied > 0}">
                                    <div class="total-row" style="color:#6b7280; font-size:0.8rem;">
                                        <span>Giảm giá</span>
                                        <span style="color:#00a844;">- <fmt:formatNumber value="${o.discountApplied}" pattern="#,###"/> ₫</span>
                                    </div>
                                </c:if>
                                <div class="total-row" style="color:#6b7280; font-size:0.8rem;">
                                    <span>Phí vận chuyển</span>
                                    <span><fmt:formatNumber value="${o.shippingFee}" pattern="#,###"/> ₫</span>
                                </div>
                                <div class="total-row main" style="font-size:0.95rem;">
                                    <span>Tổng cộng: <span class="pay-chip ms-1"><i class="fas fa-wallet" style="color:#00c853;"></i> ${not empty o.paymentMethod ? o.paymentMethod : 'COD'}</span></span>
                                    <span><fmt:formatNumber value="${o.totalAmount}" pattern="#,###"/> ₫</span>
                                </div>
                            </div>
                        </div>
                    </c:forEach>
                </c:when>
                <c:otherwise>
                    <div class="empty-state">
                        <i class="fas fa-shopping-bag"></i>
                        <h4>Không tìm thấy đơn hàng nào</h4>
                        <p>Bắt đầu hành trình chăm sóc sức khỏe bằng cách mua sắm tại cửa hàng của chúng tôi ngay hôm nay.</p>
                        <a href="cua-hang" class="btn btn-brand">Mua sắm ngay</a>
                    </div>
                </c:otherwise>
            </c:choose>
        </c:if>

    </div>

    <!-- MODAL CHỌN PHƯƠNG THỨC THANH TOÁN -->
    <div class="modal fade" id="paymentModal" tabindex="-1" aria-labelledby="paymentModalLabel" aria-hidden="true">
        <div class="modal-dialog modal-dialog-centered">
            <div class="modal-content" style="border-radius: 20px; border: none; box-shadow: 0 15px 50px rgba(0,0,0,0.15);">
                <div class="modal-header" style="border-bottom: 1px solid #f0f0f0; padding: 1.5rem 1.8rem;">
                    <h5 class="modal-title fw-800" id="paymentModalLabel" style="font-size: 1.1rem; color: #111;">
                        <i class="fas fa-wallet me-2" style="color: #00c853;"></i>Chọn phương thức thanh toán
                    </h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body" style="padding: 1.5rem 1.8rem;">
                    <p class="text-muted" style="font-size: 0.85rem; margin-bottom: 1.2rem;">
                        Vui lòng chọn phương thức thanh toán để hoàn tất đơn hàng <span id="modalOrderId" class="fw-800" style="color: #111;"></span>.
                    </p>
                    
                    <!-- Lựa chọn VNPay -->
                    <div class="payment-option selected" id="opt-VNPAY" onclick="selectPaymentMethod('VNPAY')">
                        <div class="d-flex align-items-center justify-content-between">
                            <div class="d-flex align-items-center gap-3">
                                <div style="width: 42px; height: 42px; background: rgba(0, 230, 118, 0.1); border-radius: 12px; display: flex; align-items: center; justify-content: center; color: #00e676;">
                                    <i class="fas fa-qrcode fa-lg"></i>
                                </div>
                                <div>
                                    <div class="fw-800" style="font-size: 0.9rem; color: #111;">Cổng VNPay (Mã QR / Thẻ ngân hàng)</div>
                                    <div class="text-muted" style="font-size: 0.76rem;">Thanh toán tức thì qua cổng VNPay</div>
                                </div>
                            </div>
                            <input type="radio" name="paymentOpt" id="radio-VNPAY" value="VNPAY" checked style="accent-color: #00e676; width: 18px; height: 18px;">
                        </div>
                    </div>
                    
                    <!-- Lựa chọn COD -->
                    <div class="payment-option" id="opt-COD" onclick="selectPaymentMethod('COD')">
                        <div class="d-flex align-items-center justify-content-between">
                            <div class="d-flex align-items-center gap-3">
                                <div style="width: 42px; height: 42px; background: rgba(245, 158, 11, 0.1); border-radius: 12px; display: flex; align-items: center; justify-content: center; color: #f59e0b;">
                                    <i class="fas fa-hand-holding-usd fa-lg"></i>
                                </div>
                                <div>
                                    <div class="fw-800" style="font-size: 0.9rem; color: #111;">Thanh toán khi nhận hàng (COD)</div>
                                    <div class="text-muted" style="font-size: 0.76rem;">Thanh toán bằng tiền mặt khi nhận hàng</div>
                                </div>
                            </div>
                            <input type="radio" name="paymentOpt" id="radio-COD" value="COD" style="accent-color: #00e676; width: 18px; height: 18px;">
                        </div>
                    </div>
                </div>
                <div class="modal-footer" style="border-top: 1px solid #f0f0f0; padding: 1.2rem 1.8rem;">
                    <button type="button" class="btn btn-light rounded-xl" data-bs-dismiss="modal" style="font-size: 0.8rem; font-weight: 600; padding: 0.5rem 1.2rem; background: #f3f4f6; border: none; color: #4b5563;">Hủy bỏ</button>
                    <button type="button" class="btn btn-brand" onclick="submitRepayment()" style="font-size: 0.8rem; font-weight: 700; padding: 0.5rem 1.5rem;">Xác nhận & Thanh toán</button>
                </div>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>

    <!-- Toast khi mở tab thanh toán lại -->
    <div id="retryToast" style="
         display:none; position:fixed; bottom:2rem; left:50%; transform:translateX(-50%);
         background:#1a0a0a; border:1.5px solid rgba(239,68,68,0.4); border-radius:16px;
         padding:0.85rem 1.5rem; color:#fff; font-size:0.88rem; font-weight:600;
         z-index:9999; align-items:center; gap:10px; box-shadow:0 12px 40px rgba(0,0,0,0.5);
         white-space:nowrap;
         animation: toastIn2 0.3s ease both;
         ">
        <i class="fas fa-external-link-alt" style="color:#ef4444;"></i>
        Cổng thanh toán VNPay đã được mở ở một tab mới!
    </div>
    <style>
        @keyframes toastIn2 {
            from {
                opacity: 0;
                transform: translateX(-50%) translateY(20px);
            }
            to   {
                opacity: 1;
                transform: translateX(-50%) translateY(0);
            }
        }
    </style>

    <script>
        var currentRetryOrderId = null;
        var paymentModalObj = null;

        function openPaymentModal(orderId) {
            currentRetryOrderId = orderId;
            document.getElementById('modalOrderId').innerText = '#' + orderId;
            selectPaymentMethod('VNPAY');
            
            if (!paymentModalObj) {
                paymentModalObj = new bootstrap.Modal(document.getElementById('paymentModal'));
            }
            paymentModalObj.show();
        }

        function selectPaymentMethod(method) {
            document.getElementById('radio-' + method).checked = true;
            document.querySelectorAll('.payment-option').forEach(el => el.classList.remove('selected'));
            document.getElementById('opt-' + method).classList.add('selected');
        }

        function submitRepayment() {
            if (!currentRetryOrderId) return;
            const method = document.querySelector('input[name="paymentOpt"]:checked').value;
            
            if (paymentModalObj) {
                paymentModalObj.hide();
            }
            
            if (method === 'VNPAY') {
                window.open('RetryPaymentController?orderId=' + currentRetryOrderId + '&paymentMethod=VNPAY', '_blank');
                showRetryToast();
            } else if (method === 'COD') {
                window.location.href = 'RetryPaymentController?orderId=' + currentRetryOrderId + '&paymentMethod=COD';
            }
        }

        function confirmCancelOrder(orderId) {
            if (confirm("Bạn có chắc chắn muốn hủy đơn hàng #" + orderId + "? Các mặt hàng trong đơn sẽ được hoàn trả lại kho sản phẩm.")) {
                window.location.href = "don-hang?action=CancelOrder&orderId=" + orderId;
            }
        }

        function showRetryToast() {
            var t = document.getElementById('retryToast');
            t.style.display = 'flex';
            setTimeout(function () {
                t.style.display = 'none';
            }, 4000);
        }

                                               </script>

    <jsp:include page="includes/footer.jsp" />
</body>
</html>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn"%>
<!DOCTYPE html>
<html>
    <head>
        <title>Quản lý Đơn hàng & Đóng gói - NutriOverflow</title>
        <jsp:include page="includes/header.jsp" />
        <style>
            /* KPI dashboard cards */
            .kpi-card {
                border-radius: 20px;
                border: none;
                transition: transform 0.3s ease, box-shadow 0.3s ease;
                background: #ffffff;
            }
            .kpi-card:hover {
                transform: translateY(-5px);
                box-shadow: 0 10px 25px rgba(0,0,0,0.08) !important;
            }
            .kpi-icon-wrapper {
                width: 55px;
                height: 55px;
                border-radius: 16px;
                display: flex;
                align-items: center;
                justify-content: center;
                font-size: 1.4rem;
                flex-shrink: 0;
            }
            .bg-warning-light { background-color: #fffbeb; color: #d97706; }
            .bg-info-light { background-color: #eff6ff; color: #2563eb; }
            .bg-success-light { background-color: #f0fdf4; color: #16a34a; }
            .bg-danger-light { background-color: #fef2f2; color: #dc2626; }

            .dashboard-card {
                border-radius: 20px;
                border: none;
                background: #ffffff;
                box-shadow: 0 4px 20px rgba(0,0,0,0.03);
            }
            .card-header-custom {
                border-bottom: 1px solid #f1f5f9;
                padding-bottom: 1.25rem;
                margin-bottom: 1.25rem;
            }

            /* Custom Table */
            .custom-table {
                border-collapse: separate;
                border-spacing: 0 8px;
            }
            .custom-table thead th {
                background-color: #1e293b !important;
                color: #ffffff !important;
                border: none;
                padding: 1rem 1rem;
                font-size: 0.8rem;
                letter-spacing: 0.5px;
            }
            .custom-table thead th:first-child {
                border-top-left-radius: 12px;
                border-bottom-left-radius: 12px;
            }
            .custom-table thead th:last-child {
                border-top-right-radius: 12px;
                border-bottom-right-radius: 12px;
            }
            .custom-table tbody tr {
                box-shadow: 0 2px 8px rgba(0,0,0,0.02);
                border-radius: 12px;
                transition: transform 0.2s ease, box-shadow 0.2s ease;
            }
            .custom-table tbody tr:hover {
                transform: scale(1.002);
                box-shadow: 0 4px 15px rgba(0,0,0,0.06);
                background-color: #fafbfd !important;
            }
            .custom-table tbody td {
                background: #ffffff;
                border-top: 1px solid #f1f5f9;
                border-bottom: 1px solid #f1f5f9;
                padding: 1rem 1rem;
            }
            .custom-table tbody tr td:first-child {
                border-left: 1px solid #f1f5f9;
                border-top-left-radius: 12px;
                border-bottom-left-radius: 12px;
            }
            .custom-table tbody tr td:last-child {
                border-right: 1px solid #f1f5f9;
                border-top-right-radius: 12px;
                border-bottom-right-radius: 12px;
            }

            /* Custom Badges */
            .badge-soft {
                padding: 0.4em 0.8em;
                border-radius: 8px;
                font-weight: 600;
                font-size: 0.76rem;
            }
            .badge-soft-warning { background-color: #fef3c7; color: #d97706; }
            .badge-soft-info { background-color: #eff6ff; color: #1e40af; }
            .badge-soft-primary { background-color: #dbeafe; color: #1d4ed8; }
            .badge-soft-success { background-color: #dcfce7; color: #15803d; }
            .badge-soft-danger { background-color: #fee2e2; color: #b91c1c; }

            .admin-tab-container .nav-link {
                color: #4b5563 !important;
                background: transparent !important;
                padding: 0.6rem 1.5rem !important;
                border-radius: 8px !important;
                transition: all 0.2s ease !important;
                font-size: 0.9rem !important;
                font-weight: 600 !important;
                white-space: nowrap !important;
            }
            .admin-tab-container .nav-link::after {
                display: none !important;
            }
            .admin-tab-container .nav-link.active {
                color: #ffffff !important;
                background-color: #8b0000 !important;
                box-shadow: 0 4px 12px rgba(139, 0, 0, 0.25) !important;
            }
            .admin-tab-container .nav-link:hover:not(.active) {
                color: #8b0000 !important;
                background-color: #f3f4f6 !important;
            }
            .admin-tab-container ul {
                scrollbar-width: none;
                -ms-overflow-style: none;
            }
            .admin-tab-container ul::-webkit-scrollbar {
                display: none;
            }

            /* Scanner UI styles */
            .barcode-input-container {
                position: relative;
            }
            .barcode-icon {
                position: absolute;
                right: 15px;
                top: 50%;
                transform: translateY(-50%);
                color: #9ca3af;
                font-size: 1.2rem;
            }
            .scanned-success-row {
                background-color: rgba(22, 163, 74, 0.08) !important;
                transition: background-color 0.5s ease;
            }
            .scanned-glow {
                animation: scan-glow-anim 0.8s ease;
            }
            @keyframes scan-glow-anim {
                0% { background-color: rgba(22, 163, 74, 0.3); }
                100% { background-color: transparent; }
            }
        </style>
    </head>
    <body class="bg-light">
        <c:set var="activeTab" value="Orders" scope="request" />
        <jsp:include page="includes/sidebar.jsp" />

        <!-- Main Navbar -->
        <nav class="navbar navbar-expand-lg navbar-dark mb-4 shadow-sm" style="background-color: #8b0000;">
            <div class="container-fluid px-4">
                <div class="d-flex align-items-center">
                    <button class="btn btn-outline-light me-3" type="button" data-bs-toggle="offcanvas" data-bs-target="#adminSidebar" aria-controls="adminSidebar">
                        <i class="fas fa-bars"></i>
                    </button>
                    <span class="navbar-brand mb-0 h1"><i class="fas fa-user-shield me-2"></i>Hệ thống Quản trị NutriOverflow</span>
                </div>
                <div class="d-flex align-items-center">
                    <span class="text-white me-3">Xin chào, <strong>${sessionScope.LOGIN_USER.fullName}</strong></span>
                    <a href="MainController?action=Logout" class="btn btn-outline-light btn-sm"><i class="fas fa-sign-out-alt"></i> Đăng xuất</a>
                </div>
            </div>
        </nav>

        <div class="container-fluid px-4 pb-5">
            <h3 class="mb-4 fw-bold text-dark"><i class="fas fa-boxes me-2 text-danger"></i>Xử lý Đơn hàng & Đóng gói</h3>

            <!-- Alerts for Success/Error -->
            <c:if test="${not empty sessionScope.SUCCESS_MESSAGE}">
                <div class="alert alert-success alert-dismissible fade show shadow-sm border-start border-4 border-success mb-4">
                    <i class="fas fa-check-circle me-2"></i> ${sessionScope.SUCCESS_MESSAGE}
                    <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                </div>
                <c:remove var="SUCCESS_MESSAGE" scope="session" />
            </c:if>
            <c:if test="${not empty sessionScope.ERROR_MESSAGE}">
                <div class="alert alert-danger alert-dismissible fade show shadow-sm border-start border-4 border-danger mb-4">
                    <i class="fas fa-exclamation-triangle me-2"></i> ${sessionScope.ERROR_MESSAGE}
                    <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                </div>
                <c:remove var="ERROR_MESSAGE" scope="session" />
            </c:if>

            <!-- 1. KPI WIDGET SUMMARY CARDS -->
            <c:set var="pendingCount" value="0" />
            <c:set var="shippingCount" value="0" />
            <c:set var="deliveredCount" value="0" />
            <c:set var="cancelledCount" value="0" />
            <c:forEach var="ord" items="${requestScope.LIST_ORDERS}">
                <c:if test="${fn:toUpperCase(ord.status) eq 'PENDING' or fn:toUpperCase(ord.status) eq 'PROCESSING'}">
                    <c:set var="pendingCount" value="${pendingCount + 1}" />
                </c:if>
                <c:if test="${fn:toUpperCase(ord.status) eq 'SHIPPING' or fn:toUpperCase(ord.status) eq 'DELIVERING'}">
                    <c:set var="shippingCount" value="${shippingCount + 1}" />
                </c:if>
                <c:if test="${fn:toUpperCase(ord.status) eq 'DELIVERED'}">
                    <c:set var="deliveredCount" value="${deliveredCount + 1}" />
                </c:if>
                <c:if test="${fn:toUpperCase(ord.status) eq 'CANCELLED'}">
                    <c:set var="cancelledCount" value="${cancelledCount + 1}" />
                </c:if>
            </c:forEach>

            <div class="row g-4 mb-4">
                <!-- Card 1: Pending/Processing Packing -->
                <div class="col-md-3">
                    <div class="card kpi-card shadow-sm p-4 d-flex flex-row align-items-center justify-content-between">
                        <div>
                            <span class="text-muted small fw-bold text-uppercase d-block mb-1">Đơn cần đóng gói</span>
                            <h2 class="fw-bold text-dark m-0">${pendingCount} <span class="fs-6 text-muted fw-normal">chờ xử lý</span></h2>
                        </div>
                        <div class="kpi-icon-wrapper bg-warning-light">
                            <i class="fas fa-box"></i>
                        </div>
                    </div>
                </div>
                <!-- Card 2: Shipping -->
                <div class="col-md-3">
                    <div class="card kpi-card shadow-sm p-4 d-flex flex-row align-items-center justify-content-between">
                        <div>
                            <span class="text-muted small fw-bold text-uppercase d-block mb-1">Đang giao hàng</span>
                            <h2 class="fw-bold text-dark m-0">${shippingCount} <span class="fs-6 text-muted fw-normal">đơn đi</span></h2>
                        </div>
                        <div class="kpi-icon-wrapper bg-info-light">
                            <i class="fas fa-shipping-fast"></i>
                        </div>
                    </div>
                </div>
                <!-- Card 3: Delivered -->
                <div class="col-md-3">
                    <div class="card kpi-card shadow-sm p-4 d-flex flex-row align-items-center justify-content-between">
                        <div>
                            <span class="text-muted small fw-bold text-uppercase d-block mb-1">Giao thành công</span>
                            <h2 class="fw-bold text-success m-0">${deliveredCount} <span class="fs-6 text-muted fw-normal">hoàn tất</span></h2>
                        </div>
                        <div class="kpi-icon-wrapper bg-success-light">
                            <i class="fas fa-check-double"></i>
                        </div>
                    </div>
                </div>
                <!-- Card 4: Cancelled -->
                <div class="col-md-3">
                    <div class="card kpi-card shadow-sm p-4 d-flex flex-row align-items-center justify-content-between">
                        <div>
                            <span class="text-muted small fw-bold text-uppercase d-block mb-1">Đã hủy đơn</span>
                            <h2 class="fw-bold text-danger m-0">${cancelledCount} <span class="fs-6 text-muted fw-normal">đơn hủy</span></h2>
                        </div>
                        <div class="kpi-icon-wrapper bg-danger-light">
                            <i class="fas fa-times-circle"></i>
                        </div>
                    </div>
                </div>
            </div>

            <!-- 2. SEARCH & FILTERS -->
            <div class="card border-0 shadow-sm rounded-4 p-4 mb-4">
                <form action="MainController" method="GET" class="row g-3 align-items-end">
                    <input type="hidden" name="action" value="ManageOrders" />
                    
                    <div class="col-md-4">
                        <label class="form-label fw-bold text-secondary"><i class="fas fa-search me-1"></i> Tìm kiếm đơn hàng</label>
                        <input type="text" name="search" class="form-control" value="${param.search}" placeholder="Nhập mã đơn hàng hoặc tên khách...">
                    </div>
                    
                    <div class="col-md-3">
                        <label class="form-label fw-bold text-secondary"><i class="fas fa-filter me-1"></i> Trạng thái</label>
                        <select name="statusFilter" class="form-select">
                            <option value="all" ${param.statusFilter eq 'all' ? 'selected' : ''}>-- Tất cả trạng thái --</option>
                            <option value="PENDING" ${param.statusFilter eq 'PENDING' ? 'selected' : ''}>Chờ xác nhận (PENDING)</option>
                            <option value="PROCESSING" ${param.statusFilter eq 'PROCESSING' ? 'selected' : ''}>Đang đóng gói (PROCESSING)</option>
                            <option value="SHIPPING" ${param.statusFilter eq 'SHIPPING' ? 'selected' : ''}>Đang giao hàng (SHIPPING)</option>
                            <option value="DELIVERED" ${param.statusFilter eq 'DELIVERED' ? 'selected' : ''}>Đã giao hàng (DELIVERED)</option>
                            <option value="CANCELLED" ${param.statusFilter eq 'CANCELLED' ? 'selected' : ''}>Đã hủy (CANCELLED)</option>
                        </select>
                    </div>

                    <div class="col-md-3">
                        <label class="form-label fw-bold text-secondary"><i class="fas fa-credit-card me-1"></i> Phương thức thanh toán</label>
                        <select name="paymentMethodFilter" class="form-select">
                            <option value="all" ${param.paymentMethodFilter eq 'all' ? 'selected' : ''}>-- Tất cả phương thức --</option>
                            <option value="COD" ${param.paymentMethodFilter eq 'COD' ? 'selected' : ''}>COD (Giao hàng thu tiền)</option>
                            <option value="VNPAY" ${param.paymentMethodFilter eq 'VNPAY' ? 'selected' : ''}>Thanh toán VNPAY</option>
                        </select>
                    </div>

                    <div class="col-md-2">
                        <button type="submit" class="btn btn-dark w-100 fw-bold"><i class="fas fa-search me-1"></i> Lọc đơn</button>
                    </div>
                </form>
            </div>

            <!-- 3. ORDERS TABLE -->
            <div class="card border-0 shadow-sm rounded-4 p-4">
                <c:choose>
                    <c:when test="${not empty requestScope.LIST_ORDERS}">
                        <div class="table-responsive">
                            <table class="table custom-table align-middle mb-0">
                                <thead class="table-dark">
                                    <tr>
                                        <th style="width: 80px;">Mã ĐH</th>
                                        <th style="width: 140px;">Ngày Đặt</th>
                                        <th>Khách Hàng</th>
                                        <th style="width: 160px;">Thanh Toán</th>
                                        <th style="width: 140px;">Tổng Tiền</th>
                                        <th style="width: 220px;" class="text-center">Trạng Thái</th>
                                        <th style="width: 180px;" class="text-center">Thao Tác</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <c:forEach var="order" items="${requestScope.LIST_ORDERS}">
                                        <tr>
                                            <td class="fw-bold text-danger">
                                                 #${order.orderId}
                                                 <c:if test="${not empty order.ghnOrderCode}">
                                                     <div style="font-size: 0.75rem; margin-top: 4px;" class="d-flex flex-column gap-1">
                                                         <a href="https://5sao.ghn.dev/?order_code=${order.ghnOrderCode}" target="_blank" rel="noopener noreferrer" 
                                                            class="badge bg-warning text-dark text-decoration-none shadow-sm p-1" title="Bấm để xem đơn hàng trên hệ thống GHN Sandbox">
                                                             <i class="fas fa-shipping-fast me-1"></i>${order.ghnOrderCode} <i class="fas fa-external-link-alt ms-1" style="font-size:0.65rem;"></i>
                                                         </a>
                                                         <a href="javascript:void(0);" onclick="openPrintWaybillModal('${order.ghnOrderCode}', '${order.orderId}')" class="text-secondary small text-decoration-underline" style="font-size: 0.7rem;">
                                                             <i class="fas fa-print me-1"></i>In vận đơn
                                                         </a>
                                                     </div>
                                                 </c:if>
                                            </td>
                                            <td>
                                                <small class="fw-semibold">
                                                    <fmt:formatDate value="${order.orderDate}" pattern="dd-MM-yyyy HH:mm" />
                                                </small>
                                            </td>
                                            <td>
                                                <div class="fw-bold text-dark">${order.customerName}</div>
                                                <div class="text-muted small text-truncate" style="max-width: 200px;" title="${order.shippingAddress}">
                                                    <i class="fas fa-map-marker-alt text-secondary me-1"></i>${order.shippingAddress}
                                                </div>
                                            </td>
                                            <td>
                                                <div class="fw-bold small">${order.paymentMethod}</div>
                                                <span class="badge bg-${order.paymentStatusColor}">${order.paymentStatusLabel}</span>
                                            </td>
                                            <td class="fw-bold text-dark">
                                                <fmt:formatNumber value="${order.totalAmount}" type="currency" currencySymbol="đ" maxFractionDigits="0"/>
                                            </td>
                                            <td class="text-center">
                                                <c:choose>
                                                    <c:when test="${sessionScope.LOGIN_USER.roleID eq 'AD' or sessionScope.LOGIN_USER.roleID eq 'MAN'}">
                                                        <!-- Shopee-like manual status dropdown change for ADMIN/MANAGER -->
                                                        <form action="MainController" method="POST" class="m-0">
                                                            <input type="hidden" name="action" value="OrderAction" />
                                                            <input type="hidden" name="subAction" value="updateStatus" />
                                                            <input type="hidden" name="orderId" value="${order.orderId}" />
                                                            <select name="status" class="form-select form-select-sm border-secondary fw-semibold bg-light text-dark" onchange="this.form.submit()">
                                                                <option value="PENDING" ${fn:toUpperCase(order.status) eq 'PENDING' ? 'selected' : ''}>Chờ xác nhận</option>
                                                                <option value="PROCESSING" ${fn:toUpperCase(order.status) eq 'PROCESSING' ? 'selected' : ''}>Đang đóng gói</option>
                                                                <option value="SHIPPING" ${fn:toUpperCase(order.status) eq 'SHIPPING' or fn:toUpperCase(order.status) eq 'DELIVERING' ? 'selected' : ''}>Đang giao hàng</option>
                                                                <option value="DELIVERED" ${fn:toUpperCase(order.status) eq 'DELIVERED' ? 'selected' : ''}>Giao thành công</option>
                                                                <option value="CANCELLED" ${fn:toUpperCase(order.status) eq 'CANCELLED' ? 'selected' : ''}>Đã hủy đơn</option>
                                                            </select>
                                                        </form>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <!-- Static Badge for Warehouse staff (KHO) -->
                                                        <span class="badge-soft badge-soft-${order.statusColor}"><i class="fas fa-circle me-1 small"></i>${order.statusLabel}</span>
                                                    </c:otherwise>
                                                </c:choose>
                                            </td>
                                            <td class="text-center">
                                                 <!-- Packaging & Direct Approval Action -->
                                                 <c:choose>
                                                     <c:when test="${fn:toUpperCase(order.status) eq 'PENDING' or fn:toUpperCase(order.status) eq 'PROCESSING'}">
                                                         <div class="d-flex align-items-center justify-content-center gap-1 flex-wrap">
                                                             <form action="MainController" method="POST" class="m-0 d-inline">
                                                                 <input type="hidden" name="action" value="OrderAction" />
                                                                 <input type="hidden" name="subAction" value="handover" />
                                                                 <input type="hidden" name="orderId" value="${order.orderId}" />
                                                                 <button type="submit" class="btn btn-primary btn-sm fw-bold shadow-sm rounded-pill px-3" title="Duyệt đơn & Gửi sang GHN">
                                                                     <i class="fas fa-check-circle me-1"></i> Duyệt đơn (GHN)
                                                                 </button>
                                                             </form>
                                                             <button type="button" class="btn btn-outline-secondary btn-sm rounded-pill px-2" 
                                                                     onclick="openPackingModal('${order.orderId}')" title="Kiểm hàng / Đóng gói">
                                                                 <i class="fas fa-box-open"></i> Đóng gói
                                                             </button>
                                                         </div>
                                                     </c:when>
                                                     <c:otherwise>
                                                         <button type="button" class="btn btn-outline-secondary btn-sm rounded-pill px-3" 
                                                                 onclick="openPackingModal('${order.orderId}', true)">
                                                             <i class="fas fa-info-circle me-1"></i> Chi tiết
                                                         </button>
                                                     </c:otherwise>
                                                 </c:choose>
                                            </td>
                                        </tr>
                                    </c:forEach>
                                </tbody>
                            </table>
                        </div>
                    </c:when>
                    <c:otherwise>
                        <div class="text-center py-5">
                            <i class="fas fa-boxes fa-3x text-muted mb-3"></i>
                            <h5 class="text-muted">Không tìm thấy đơn hàng nào cần đóng gói hoặc xử lý!</h5>
                        </div>
                    </c:otherwise>
                </c:choose>
            </div>
        </div>

        <!-- PACKING & BARCODE SCAN SIMULATOR MODAL -->
        <div class="modal fade" id="packingModal" tabindex="-1" aria-labelledby="packingModalLabel" aria-hidden="true" data-bs-backdrop="static">
            <div class="modal-dialog modal-lg modal-dialog-centered">
                <div class="modal-content" style="border-radius: 16px;">
                    <div class="modal-header bg-dark text-white border-0 py-3" style="border-top-left-radius: 16px; border-top-right-radius: 16px;">
                        <h5 class="modal-title fw-bold" id="packingModalLabel"><i class="fas fa-boxes me-2"></i>Quy trình đóng gói đơn hàng #<span id="modalOrderIdTitle"></span></h5>
                        <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
                    </div>
                    
                    <div class="modal-body p-4">


                        <!-- 1. Customer Receiver info -->
                        <div class="row g-3 bg-light rounded-3 p-3 mb-4 border border-secondary-subtle">
                            <div class="col-md-6">
                                <small class="text-uppercase text-secondary fw-bold d-block">Người nhận hàng</small>
                                <strong class="text-dark" id="custName"></strong>
                            </div>
                            <div class="col-md-6">
                                <small class="text-uppercase text-secondary fw-bold d-block">Phương thức thanh toán</small>
                                <span class="badge bg-secondary fw-bold" id="payMethod"></span>
                            </div>
                            <div class="col-12 mt-2">
                                <small class="text-uppercase text-secondary fw-bold d-block">Địa chỉ giao hàng</small>
                                <span class="text-dark fw-semibold" id="shipAddr"></span>
                            </div>
                            <div class="col-12 mt-2" id="orderNoteContainer">
                                <small class="text-uppercase text-secondary fw-bold d-block text-danger">Ghi chú khách hàng</small>
                                <span class="text-danger italic small" id="orderNote"></span>
                            </div>
                            <div class="col-12 mt-2" id="ghnInfoContainer" style="display: none;">
                                <small class="text-uppercase text-secondary fw-bold d-block">Mã vận đơn (GHN)</small>
                                <div class="d-flex align-items-center gap-2 flex-wrap">
                                    <strong class="text-danger" id="detailGhnCode"></strong>
                                    <a id="btnDetailGhnLink" href="#" target="_blank" rel="noopener noreferrer" class="btn btn-warning btn-sm fw-bold shadow-sm py-1 px-3 rounded-pill text-dark text-decoration-none">
                                        <i class="fas fa-external-link-alt me-1"></i>Xem trên GHN Sandbox
                                    </a>
                                    <button type="button" class="btn btn-secondary btn-sm fw-bold shadow-sm py-1 px-3 rounded-pill" onclick="openPrintWaybillModalFromDetail()">
                                        <i class="fas fa-print me-1"></i>In vận đơn
                                    </button>
                                </div>
                            </div>
                        </div>

                        <!-- 2. Barcode Simulator Input (Visible only if order is in PENDING/PROCESSING packing state) -->
                        <div id="scannerSection">
                            <h6 class="fw-bold text-dark mb-2"><i class="fas fa-barcode me-2"></i>Quét mã vạch sản phẩm (SKU)</h6>
                            <div class="barcode-input-container mb-4">
                                <input type="text" id="barcodeInput" class="form-control form-control-lg border-2 border-primary" 
                                       placeholder="Gõ mã SKU sản phẩm và ấn Enter (Ví dụ: WHEY-GOLD, WHEY-ISO)..."
                                       onkeydown="handleBarcodeScan(event)" />
                                <i class="fas fa-barcode barcode-icon"></i>
                            </div>
                            <div id="scanFeedback" class="alert d-none py-2 px-3 mb-3"></div>
                        </div>

                        <!-- 3. Packing Progress Bar -->
                        <div class="mb-3">
                            <div class="d-flex justify-content-between align-items-center mb-1">
                                <span class="small fw-bold text-secondary">Tiến trình đóng gói sản phẩm</span>
                                <span class="small fw-bold text-success" id="progressPercent">0%</span>
                            </div>
                            <div class="progress" style="height: 12px; border-radius: 6px;">
                                <div id="progressBar" class="progress-bar progress-bar-striped progress-bar-animated bg-success" role="progressbar" style="width: 0%"></div>
                            </div>
                        </div>

                        <!-- 4. Items List -->
                        <h6 class="fw-bold text-dark mb-2"><i class="fas fa-list-ul me-2"></i>Danh sách sản phẩm cần đóng gói</h6>
                        <div class="table-responsive">
                            <table class="table table-bordered align-middle text-center mb-0">
                                <thead class="table-secondary small">
                                    <tr>
                                        <th style="width: 60px;">Ảnh</th>
                                        <th>Tên sản phẩm</th>
                                        <th style="width: 120px;">Mã SKU</th>
                                        <th style="width: 100px;">Giá bán</th>
                                        <th style="width: 80px;">Số lượng</th>
                                        <th style="width: 100px;">Đã quét</th>
                                        <th style="width: 110px;">Trạng thái</th>
                                    </tr>
                                </thead>
                                <tbody id="packingItemsTable">
                                    <!-- Populated dynamically via JS -->
                                </tbody>
                            </table>
                        </div>
                    </div>

                    <!-- Modal Action Footer -->
                    <div class="modal-footer border-0 p-4 pt-0 justify-content-between">
                        <button type="button" class="btn btn-outline-secondary px-4 fw-bold rounded-pill" data-bs-dismiss="modal">Đóng lại</button>
                        
                        <!-- Handover Form (Only shows up when order is not SHIPPING/DELIVERED) -->
                        <form id="handoverForm" action="MainController" method="POST" class="d-flex align-items-center gap-2 m-0" onsubmit="return validateHandover()">
                            <input type="hidden" name="action" value="OrderAction" />
                            <input type="hidden" name="subAction" value="handover" />
                            <input type="hidden" id="handoverOrderId" name="orderId" />
                            
                            <div class="input-group input-group-sm" id="ghnOrderCodeWrapper" style="width: 250px;">
                                <span class="input-group-text bg-light fw-bold text-secondary">Mã GHN</span>
                                <input type="text" id="ghnOrderCode" name="ghnOrderCode" class="form-control" placeholder="Tự sinh nếu để trống..." />
                            </div>
                            
                            <button type="submit" id="btnConfirmHandover" class="btn btn-success px-4 fw-bold rounded-pill" disabled>
                                <i class="fas fa-truck-loading me-1"></i> Bàn giao vận chuyển
                            </button>
                        </form>
                    </div>
                </div>
            </div>
        </div>



        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
        <script>
            let packingModalObj;
            let currentOrder = null;
            let scannedCounts = {}; // Key: SKU, Value: current scanned count
            let isViewOnly = false;

            document.addEventListener("DOMContentLoaded", function() {
                packingModalObj = new bootstrap.Modal(document.getElementById('packingModal'));
            });

            // WEB AUDIO API BEEP SYNTHESIZER FOR SCAN CONFIRMATION
            function playBeep(type) {
                try {
                    const audioCtx = new (window.AudioContext || window.webkitAudioContext)();
                    const oscillator = audioCtx.createOscillator();
                    const gainNode = audioCtx.createGain();

                    oscillator.connect(gainNode);
                    gainNode.connect(audioCtx.destination);

                    if (type === 'success') {
                        oscillator.frequency.value = 880; // High frequency beep
                        gainNode.gain.setValueAtTime(0.1, audioCtx.currentTime);
                        oscillator.start();
                        gainNode.gain.exponentialRampToValueAtTime(0.00001, audioCtx.currentTime + 0.15);
                        oscillator.stop(audioCtx.currentTime + 0.15);
                    } else if (type === 'error') {
                        oscillator.frequency.value = 220; // Low buzz
                        gainNode.gain.setValueAtTime(0.2, audioCtx.currentTime);
                        oscillator.start();
                        gainNode.gain.exponentialRampToValueAtTime(0.00001, audioCtx.currentTime + 0.3);
                        oscillator.stop(audioCtx.currentTime + 0.3);
                    }
                } catch (e) {
                    console.log("Audio not supported yet, or waiting for user interaction: ", e);
                }
            }

            function openPackingModal(orderId, viewOnly = false) {
                isViewOnly = viewOnly;
                currentOrder = null;
                scannedCounts = {};
                
                // Reset UI
                document.getElementById('modalOrderIdTitle').textContent = orderId;
                document.getElementById('handoverOrderId').value = orderId;
                document.getElementById('custName').textContent = "Đang tải...";
                document.getElementById('payMethod').className = "badge bg-secondary fw-bold";
                document.getElementById('payMethod').textContent = "Đang tải...";
                document.getElementById('shipAddr').textContent = "Đang tải...";
                document.getElementById('orderNoteContainer').style.display = 'none';
                document.getElementById('packingItemsTable').innerHTML = '<tr><td colspan="7" class="text-center"><i class="fas fa-spinner fa-spin me-2"></i>Đang tải thông tin chi tiết đơn hàng...</td></tr>';
                document.getElementById('progressBar').style.width = '0%';
                document.getElementById('progressPercent').textContent = '0%';
                document.getElementById('barcodeInput').value = "";
                document.getElementById('ghnOrderCode').value = "";
                document.getElementById('btnConfirmHandover').disabled = true;
                
                let scanFeedback = document.getElementById('scanFeedback');
                scanFeedback.className = "alert d-none";
                scanFeedback.innerHTML = "";

                if (viewOnly) {
                    document.getElementById('scannerSection').style.display = 'none';
                    document.getElementById('ghnOrderCodeWrapper').style.display = 'none';
                    document.getElementById('btnConfirmHandover').style.display = 'none';
                } else {
                    document.getElementById('scannerSection').style.display = 'block';
                    document.getElementById('ghnOrderCodeWrapper').style.display = 'flex';
                    document.getElementById('btnConfirmHandover').style.display = 'block';
                }

                packingModalObj.show();

                // Fetch Order details asynchronously
                fetch("MainController?action=OrderAction&subAction=getDetails&orderId=" + orderId)
                    .then(response => {
                        if (!response.ok) throw new Error("Order details fetch failed");
                        return response.json();
                    })
                    .then(data => {
                        currentOrder = data;
                        
                        // Populate modal metadata
                        document.getElementById('custName').textContent = data.customerName;
                        document.getElementById('payMethod').textContent = data.paymentMethod + " (" + data.paymentStatus + ")";
                        document.getElementById('payMethod').className = "badge bg-" + (data.paymentStatus === 'PAID' ? 'success' : 'danger') + " fw-bold";
                        document.getElementById('shipAddr').textContent = data.shippingAddress;
                        
                        if (data.ghnOrderCode && data.ghnOrderCode.trim().length > 0) {
                            document.getElementById('ghnInfoContainer').style.display = 'block';
                            document.getElementById('detailGhnCode').textContent = data.ghnOrderCode;
                            document.getElementById('btnDetailGhnLink').href = 'https://5sao.ghn.dev';
                        } else {
                            document.getElementById('ghnInfoContainer').style.display = 'none';
                        }
                        
                        if (data.note && data.note.trim().length > 0) {
                            document.getElementById('orderNoteContainer').style.display = 'block';
                            document.getElementById('orderNote').textContent = data.note;
                        } else {
                            document.getElementById('orderNoteContainer').style.display = 'none';
                        }

                        // Populate packing items list
                        let tableBody = document.getElementById('packingItemsTable');
                        tableBody.innerHTML = "";
                        
                        data.items.forEach(item => {
                            // If viewOnly, assume already fully scanned for visual purposes
                            scannedCounts[item.sku] = viewOnly ? item.quantity : 0;
                            
                            let tr = document.createElement('tr');
                            tr.id = "item-row-" + item.sku;
                            
                            // Image cell
                            let tdImg = document.createElement('td');
                            let imgUrl = item.imageUrl && item.imageUrl.trim().length > 0 ? item.imageUrl : 'default-product.jpg';
                            tdImg.innerHTML = `<img src="\${imgUrl}" class="rounded" style="width: 45px; height: 45px; object-fit: cover;" onerror="this.src='https://placehold.co/100x100?text=Product'" />`;
                            tr.appendChild(tdImg);
                            
                            // Name cell
                            let tdName = document.createElement('td');
                            tdName.className = "text-start fw-bold text-dark";
                            tdName.textContent = item.productName;
                            tr.appendChild(tdName);
                            
                            // SKU cell
                            let tdSku = document.createElement('td');
                            tdSku.className = "font-monospace fw-bold text-secondary";
                            tdSku.textContent = item.sku;
                            tr.appendChild(tdSku);
                            
                            // Price cell
                            let tdPrice = document.createElement('td');
                            tdPrice.className = "fw-semibold";
                            tdPrice.textContent = item.priceAtPurchase.toLocaleString('vi-VN') + "đ";
                            tr.appendChild(tdPrice);
                            
                            // Target Quantity cell
                            let tdQty = document.createElement('td');
                            tdQty.className = "fw-bold text-dark fs-5";
                            tdQty.id = "qty-target-" + item.sku;
                            tdQty.textContent = item.quantity;
                            tr.appendChild(tdQty);
                            
                            // Scanned Quantity cell
                            let tdScanned = document.createElement('td');
                            tdScanned.className = "fw-bold fs-5";
                            tdScanned.id = "qty-scanned-" + item.sku;
                            tdScanned.textContent = scannedCounts[item.sku];
                            if (viewOnly) tdScanned.classList.add("text-success");
                            tr.appendChild(tdScanned);
                            
                            // Status cell
                            let tdStatus = document.createElement('td');
                            tdStatus.id = "badge-status-" + item.sku;
                            if (viewOnly) {
                                tdStatus.innerHTML = '<span class="badge bg-success w-100 py-1.5"><i class="fas fa-check-circle me-1"></i>Đã đóng</span>';
                                tr.className = "scanned-success-row";
                            } else {
                                tdStatus.innerHTML = '<span class="badge bg-danger w-100 py-1.5"><i class="fas fa-hourglass-start me-1"></i>Chưa quét</span>';
                            }
                            tr.appendChild(tdStatus);
                            
                            tableBody.appendChild(tr);
                        });

                        updateProgressBar();
                        
                        // Focus barcode input box
                        if (!viewOnly) {
                            setTimeout(() => {
                                document.getElementById('barcodeInput').focus();
                            }, 500);
                        }
                    })
                    .catch(err => {
                        console.error(err);
                        document.getElementById('packingItemsTable').innerHTML = '<tr><td colspan="7" class="text-center text-danger fw-bold"><i class="fas fa-exclamation-triangle me-2"></i>Không tải được thông tin đơn hàng! Vui lòng thử lại.</td></tr>';
                    });
            }

            function handleBarcodeScan(event) {
                if (event.key === "Enter") {
                    event.preventDefault();
                    let input = document.getElementById('barcodeInput');
                    let sku = input.value.trim().toUpperCase();
                    input.value = ""; // Clear immediately for next scan
                    
                    if (!currentOrder) return;
                    
                    let feedback = document.getElementById('scanFeedback');
                    feedback.className = "alert d-none";

                    // Find item with scanned SKU
                    let item = currentOrder.items.find(i => i.sku.toUpperCase() === sku);
                    
                    if (item) {
                        if (scannedCounts[item.sku] < item.quantity) {
                            scannedCounts[item.sku]++;
                            playBeep('success');
                            
                            // Update counts in UI
                            let scannedCell = document.getElementById('qty-scanned-' + item.sku);
                            scannedCell.textContent = scannedCounts[item.sku];
                            
                            let statusCell = document.getElementById('badge-status-' + item.sku);
                            let row = document.getElementById('item-row-' + item.sku);
                            
                            // Add scan animations
                            row.classList.add('scanned-glow');
                            setTimeout(() => {
                                row.classList.remove('scanned-glow');
                            }, 800);

                            if (scannedCounts[item.sku] === item.quantity) {
                                scannedCell.className = "fw-bold fs-5 text-success";
                                statusCell.innerHTML = '<span class="badge bg-success w-100 py-1.5"><i class="fas fa-check-circle me-1"></i>Đã đủ</span>';
                                row.className = "scanned-success-row";
                            } else {
                                scannedCell.className = "fw-bold fs-5 text-warning";
                                statusCell.innerHTML = '<span class="badge bg-warning w-100 py-1.5"><i class="fas fa-spinner fa-pulse me-1"></i>Đang quét</span>';
                            }
                            
                            feedback.className = "alert alert-success py-2 px-3 mb-3";
                            feedback.innerHTML = `<i class="fas fa-check-circle me-1"></i>Đã quét thành công sản phẩm: <strong>\${item.productName}</strong> (\${scannedCounts[item.sku]}/\${item.quantity})`;
                            
                            updateProgressBar();
                        } else {
                            // Already fully scanned
                            playBeep('error');
                            feedback.className = "alert alert-warning py-2 px-3 mb-3";
                            feedback.innerHTML = `<i class="fas fa-exclamation-triangle me-1"></i>Sản phẩm <strong>\${item.productName}</strong> đã đóng gói đủ số lượng cần thiết!`;
                        }
                    } else {
                        // SKU not found in this order
                        playBeep('error');
                        feedback.className = "alert alert-danger py-2 px-3 mb-3";
                        feedback.innerHTML = `<i class="fas fa-times-circle me-1"></i>Mã SKU <strong>"\${sku}"</strong> không nằm trong đơn hàng này!`;
                    }
                }
            }

            function updateProgressBar() {
                if (!currentOrder) return;
                
                let totalTarget = currentOrder.items.reduce((sum, item) => sum + item.quantity, 0);
                let totalScanned = currentOrder.items.reduce((sum, item) => sum + scannedCounts[item.sku], 0);
                
                let percent = totalTarget > 0 ? Math.round((totalScanned / totalTarget) * 100) : 0;
                
                document.getElementById('progressBar').style.width = percent + "%";
                document.getElementById('progressPercent').textContent = percent + "%";
                
                // Enable or disable the Handover Submit button
                if (totalScanned === totalTarget && totalTarget > 0 && !isViewOnly) {
                    document.getElementById('btnConfirmHandover').disabled = false;
                } else {
                    document.getElementById('btnConfirmHandover').disabled = true;
                }
            }

            function validateHandover() {
                if (!currentOrder) return false;
                
                let totalTarget = currentOrder.items.reduce((sum, item) => sum + item.quantity, 0);
                let totalScanned = currentOrder.items.reduce((sum, item) => sum + scannedCounts[item.sku], 0);
                
                if (totalScanned !== totalTarget) {
                    alert("Bạn chưa quét đủ sản phẩm cho đơn hàng này!");
                    return false;
                }
                
                return confirm("Xác nhận bàn giao đơn hàng #" + currentOrder.orderId + " cho đơn vị vận chuyển?");
            }



            function openPrintWaybillModal(ghnCode, orderId) {
                window.open("https://5sao.ghn.dev/", "_blank");
            }

            function openPrintWaybillModalFromDetail() {
                openPrintWaybillModal();
            }
        </script>
    </body>
</html>

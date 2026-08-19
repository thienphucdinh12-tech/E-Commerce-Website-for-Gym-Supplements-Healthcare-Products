<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn"%>
<!DOCTYPE html>
<html>
    <head>
        <title>Quản lý Khuyến mãi & Tích điểm - NutriOverflow</title>
        <jsp:include page="includes/header.jsp" />
        <style>
            /* Global Dashboard Styles */
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
                width: 60px;
                height: 60px;
                border-radius: 16px;
                display: flex;
                align-items: center;
                justify-content: center;
                font-size: 1.5rem;
                flex-shrink: 0;
            }
            .bg-danger-light { background-color: #fef2f2; color: #dc2626; }
            .bg-warning-light { background-color: #fffbeb; color: #d97706; }
            .bg-success-light { background-color: #f0fdf4; color: #16a34a; }
            .bg-info-light { background-color: #eff6ff; color: #2563eb; }

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

            /* Table Customization */
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
                transform: scale(1.005);
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

            /* Soft Badges */
            .badge-soft {
                padding: 0.4em 0.8em;
                border-radius: 8px;
                font-weight: 600;
                font-size: 0.76rem;
            }
            .badge-soft-success { background-color: #dcfce7; color: #15803d; }
            .badge-soft-secondary { background-color: #f1f5f9; color: #475569; }
            .badge-soft-danger { background-color: #fee2e2; color: #b91c1c; }
            .badge-soft-info { background-color: #dbeafe; color: #1d4ed8; }

            .coupon-code-pill {
                font-family: 'Courier New', Courier, monospace;
                background-color: #fef2f2;
                color: #b91c1c;
                border: 1px dashed #fca5a5;
                font-weight: 700;
                padding: 0.35rem 0.75rem;
                border-radius: 8px;
            }

            /* Adjust scrollbar */
            .scroll-container::-webkit-scrollbar {
                width: 6px;
            }
            .scroll-container::-webkit-scrollbar-track {
                background: #f8fafc;
            }
            .scroll-container::-webkit-scrollbar-thumb {
                background: #cbd5e1;
                border-radius: 3px;
            }

            /* Custom tabs styling */
            .admin-tab-container .nav-link {
                color: #4b5563 !important;
                background: transparent !important;
                padding: 0.6rem 1.5rem !important;
                border-radius: 8px !important;
                transition: all 0.2s ease !important;
                font-size: 0.9rem !important;
                text-transform: none !important;
                letter-spacing: normal !important;
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
        </style>
    </head>
    <body class="bg-light">
        <c:set var="activeTab" value="Campaigns" scope="request" />
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
            <!-- Alert message block -->
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
            <div class="row g-4 mb-4">
                <!-- Card 1: Total Coupons -->
                <div class="col-md-4">
                    <div class="card kpi-card shadow-sm p-4 d-flex flex-row align-items-center justify-content-between">
                        <div>
                            <span class="text-muted small fw-bold text-uppercase d-block mb-1">Chiến dịch mã Coupon</span>
                            <h2 class="fw-bold text-dark m-0">${fn:length(requestScope.LIST_COUPONS)} <span class="fs-5 text-muted fw-normal">mã hoạt động</span></h2>
                        </div>
                        <div class="kpi-icon-wrapper bg-danger-light">
                            <i class="fas fa-ticket-alt"></i>
                        </div>
                    </div>
                </div>

                <!-- Card 2: Earning Rule -->
                <div class="col-md-4">
                    <div class="card kpi-card shadow-sm p-4 d-flex flex-row align-items-center justify-content-between">
                        <div>
                            <span class="text-muted small fw-bold text-uppercase d-block mb-1">Tỷ lệ quy đổi điểm</span>
                            <h3 class="fw-bold text-dark m-0">
                                <fmt:formatNumber value="${requestScope.POINT_EARNING_RATE}" type="currency" currencySymbol="đ" maxFractionDigits="0"/> = 1 Điểm
                            </h3>
                        </div>
                        <div class="kpi-icon-wrapper bg-warning-light">
                            <i class="fas fa-coins"></i>
                        </div>
                    </div>
                </div>

                <!-- Card 3: Membership points ledger size -->
                <div class="col-md-4">
                    <div class="card kpi-card shadow-sm p-4 d-flex flex-row align-items-center justify-content-between">
                        <div>
                            <span class="text-muted small fw-bold text-uppercase d-block mb-1">Tổng thành viên tích điểm</span>
                            <h2 class="fw-bold text-dark m-0">${fn:length(requestScope.LIST_CUSTOMER_POINTS)} <span class="fs-5 text-muted fw-normal">khách hàng</span></h2>
                        </div>
                        <div class="kpi-icon-wrapper bg-success-light">
                            <i class="fas fa-users"></i>
                        </div>
                    </div>
                </div>
            </div>

            <!-- 2. TWO-COLUMN LAYOUT -->
            <div class="row g-4">
                
                <!-- LEFT COLUMN: Point configuration & Customer points list -->
                <div class="col-lg-4">
                    
                    <!-- Point Configuration Form Card -->
                    <div class="card dashboard-card p-4 mb-4">
                        <div class="card-header-custom d-flex align-items-center justify-content-between">
                            <h5 class="fw-bold text-dark m-0"><i class="fas fa-sliders-h me-2 text-danger"></i>Cài đặt tích điểm</h5>
                        </div>
                        <form action="MainController" method="POST">
                            <input type="hidden" name="action" value="MemberPointsAction" />
                            <input type="hidden" name="subAction" value="updateRules" />
                            
                            <div class="mb-3">
                                <label class="form-label small fw-bold text-secondary">Hạn mức tích lũy (VNĐ mua hàng = 1 điểm)</label>
                                <div class="input-group">
                                    <input type="number" name="pointEarningRate" class="form-control fw-bold border-secondary-subtle" value="${requestScope.POINT_EARNING_RATE}" min="1000" required />
                                    <span class="input-group-text bg-light fw-bold text-muted">VNĐ</span>
                                </div>
                            </div>
                            
                            <div class="mb-4">
                                <label class="form-label small fw-bold text-secondary">Giá trị thanh toán (1 điểm = VNĐ giảm giá)</label>
                                <div class="input-group">
                                    <input type="number" name="pointRedeemRate" class="form-control fw-bold border-secondary-subtle" value="${requestScope.POINT_REDEEM_RATE}" min="1" required />
                                    <span class="input-group-text bg-light fw-bold text-muted">VNĐ</span>
                                </div>
                            </div>

                            <button type="submit" class="btn btn-dark w-100 fw-bold py-2 shadow-sm rounded-3"><i class="fas fa-check-circle me-2"></i>Áp dụng quy tắc mới</button>
                        </form>
                    </div>

                    <!-- Customer Points Balance Ledger Card -->
                    <div class="card dashboard-card p-4">
                        <div class="card-header-custom d-flex align-items-center justify-content-between">
                            <h5 class="fw-bold text-dark m-0"><i class="fas fa-medal me-2 text-warning"></i>Bảng điểm thành viên</h5>
                        </div>
                        <c:choose>
                            <c:when test="${not empty requestScope.LIST_CUSTOMER_POINTS}">
                                <div class="scroll-container" style="max-height: 350px; overflow-y: auto;">
                                    <table class="table table-borderless align-middle mb-0">
                                        <thead>
                                            <tr class="text-secondary small fw-bold border-bottom">
                                                <th class="pb-2">Khách hàng</th>
                                                <th class="text-center pb-2">Điểm số</th>
                                                <th class="text-end pb-2">Hành động</th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                            <c:forEach var="cust" items="${requestScope.LIST_CUSTOMER_POINTS}">
                                                <tr class="border-bottom-subtle" style="border-bottom: 1px solid #f8fafc;">
                                                    <td class="py-2">
                                                        <div class="fw-bold text-dark text-truncate" style="max-width: 130px;">${cust.fullName}</div>
                                                        <small class="text-muted text-tiny">@${cust.username}</small>
                                                    </td>
                                                    <td class="text-center py-2">
                                                        <span class="badge bg-warning-light px-2.5 py-1.5 fw-bold fs-6 rounded-3">
                                                            ${cust.points}
                                                        </span>
                                                    </td>
                                                    <td class="text-end py-2">
                                                        <button type="button" class="btn btn-sm btn-outline-dark px-3 py-1 rounded-pill fw-bold text-tiny"
                                                                onclick="openAdjustPointsModal(${cust.userId}, '${cust.username}', '${cust.fullName}', ${cust.points})">
                                                            Sửa
                                                        </button>
                                                    </td>
                                                </tr>
                                            </c:forEach>
                                        </tbody>
                                    </table>
                                </div>
                            </c:when>
                            <c:otherwise>
                                <div class="text-center py-4">
                                    <i class="fas fa-user-slash fa-2x text-muted mb-2"></i>
                                    <div class="text-muted small">Không tìm thấy tài khoản khách hàng thành viên nào.</div>
                                </div>
                            </c:otherwise>
                        </c:choose>
                    </div>
                </div>

                <!-- RIGHT COLUMN: Detailed list of Coupons -->
                <div class="col-lg-8">
                    <div class="card dashboard-card p-4">
                        <div class="card-header-custom d-flex align-items-center justify-content-between">
                            <h5 class="fw-bold text-dark m-0"><i class="fas fa-ticket-alt me-2 text-danger"></i>Danh sách chiến dịch Coupon</h5>
                            <button type="button" class="btn btn-success btn-sm fw-bold px-3 py-2 rounded-pill shadow-sm" onclick="openAddCouponModal()">
                                <i class="fas fa-plus-circle me-1"></i>Thêm Coupon mới
                            </button>
                        </div>

                        <c:choose>
                            <c:when test="${not empty requestScope.LIST_COUPONS}">
                                <div class="table-responsive">
                                    <table class="table custom-table align-middle mb-0">
                                        <thead>
                                            <tr>
                                                <th>Mã Code</th>
                                                <th>Mức giảm</th>
                                                <th>Đơn tối thiểu</th>
                                                <th class="text-center">Sử dụng</th>
                                                <th>Thời hạn</th>
                                                <th>Trạng thái</th>
                                                <th class="text-center">Hành động</th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                            <c:forEach var="coupon" items="${requestScope.LIST_COUPONS}">
                                                <tr>
                                                    <td>
                                                        <span class="coupon-code-pill">${coupon.code}</span>
                                                    </td>
                                                    <td>
                                                        <c:choose>
                                                            <c:when test="${coupon.discountPercent > 0}">
                                                                <span class="badge badge-soft badge-soft-danger">- ${coupon.discountPercent}%</span>
                                                            </c:when>
                                                            <c:otherwise>
                                                                <span class="fw-bold text-success">
                                                                    <fmt:formatNumber value="${coupon.discountAmount}" type="currency" currencySymbol="đ" maxFractionDigits="0"/>
                                                                </span>
                                                            </c:otherwise>
                                                        </c:choose>
                                                    </td>
                                                    <td class="fw-semibold text-secondary">
                                                        <fmt:formatNumber value="${coupon.minOrderValue}" type="currency" currencySymbol="đ" maxFractionDigits="0"/>
                                                    </td>
                                                    <td class="text-center">
                                                        <span class="fw-bold text-dark">${coupon.usedCount}</span>
                                                        <span class="text-muted">/</span>
                                                        <span class="text-secondary small">${coupon.usageLimit != null ? coupon.usageLimit : '∞'}</span>
                                                    </td>
                                                    <td>
                                                        <c:choose>
                                                            <c:when test="${not empty coupon.expiryDate}">
                                                                <span class="small fw-semibold text-dark"><fmt:formatDate value="${coupon.expiryDate}" pattern="dd-MM-yyyy HH:mm"/></span>
                                                            </c:when>
                                                            <c:otherwise>
                                                                <span class="text-muted small">Vô hạn</span>
                                                            </c:otherwise>
                                                        </c:choose>
                                                    </td>
                                                    <td>
                                                        <c:choose>
                                                            <c:when test="${coupon.active}">
                                                                <span class="badge-soft badge-soft-success"><i class="fas fa-check-circle me-1"></i>Đang mở</span>
                                                            </c:when>
                                                            <c:otherwise>
                                                                <span class="badge-soft badge-soft-secondary"><i class="fas fa-pause-circle me-1"></i>Đang tắt</span>
                                                            </c:otherwise>
                                                        </c:choose>
                                                    </td>
                                                    <td class="text-center">
                                                        <!-- Edit button -->
                                                        <button type="button" class="btn btn-sm btn-outline-primary rounded-circle"
                                                                style="width: 32px; height: 32px; padding:0; display:inline-flex; align-items:center; justify-content:center;"
                                                                data-id="${coupon.id}"
                                                                data-code="${coupon.code}"
                                                                data-amount="${coupon.discountAmount}"
                                                                data-percent="${coupon.discountPercent}"
                                                                data-min="${coupon.minOrderValue}"
                                                                data-limit="${coupon.usageLimit}"
                                                                data-expiry="<fmt:formatDate value="${coupon.expiryDate}" pattern="yyyy-MM-dd'T'HH:mm"/>"
                                                                data-active="${coupon.active}"
                                                                onclick="openEditCouponModal(this)"
                                                                title="Chỉnh sửa chi tiết">
                                                            <i class="fas fa-edit"></i>
                                                        </button>

                                                        <!-- Toggle active state -->
                                                        <c:choose>
                                                            <c:when test="${coupon.active}">
                                                                <a href="MainController?action=CouponAction&subAction=toggleActive&couponId=${coupon.id}&active=false" 
                                                                   class="btn btn-sm btn-outline-warning rounded-circle ms-1"
                                                                   style="width: 32px; height: 32px; padding:0; display:inline-flex; align-items:center; justify-content:center;"
                                                                   title="Tắt hoạt động">
                                                                    <i class="fas fa-pause"></i>
                                                                </a>
                                                            </c:when>
                                                            <c:otherwise>
                                                                <a href="MainController?action=CouponAction&subAction=toggleActive&couponId=${coupon.id}&active=true" 
                                                                   class="btn btn-sm btn-outline-success rounded-circle ms-1"
                                                                   style="width: 32px; height: 32px; padding:0; display:inline-flex; align-items:center; justify-content:center;"
                                                                   title="Bật hoạt động">
                                                                    <i class="fas fa-play"></i>
                                                                </a>
                                                            </c:otherwise>
                                                        </c:choose>

                                                        <!-- Delete button -->
                                                        <a href="MainController?action=CouponAction&subAction=delete&couponId=${coupon.id}" 
                                                           class="btn btn-sm btn-outline-danger rounded-circle ms-1"
                                                           style="width: 32px; height: 32px; padding:0; display:inline-flex; align-items:center; justify-content:center;"
                                                           onclick="return confirm('Bạn có chắc chắn muốn xóa vĩnh viễn mã giảm giá [${coupon.code}]?')"
                                                           title="Xóa vĩnh viễn">
                                                            <i class="fas fa-trash"></i>
                                                        </a>
                                                    </td>
                                                </tr>
                                            </c:forEach>
                                        </tbody>
                                    </table>
                                </div>
                            </c:when>
                            <c:otherwise>
                                <div class="text-center py-5">
                                    <i class="fas fa-ticket-alt fa-3x text-muted mb-3"></i>
                                    <h5 class="text-muted">Chưa cấu hình chiến dịch Coupon nào!</h5>
                                    <p class="text-secondary small">Vui lòng click "Thêm Coupon mới" để bắt đầu.</p>
                                </div>
                            </c:otherwise>
                        </c:choose>
                    </div>
                </div>
            </div>
        </div>

        <!-- Add Coupon Modal -->
        <div class="modal fade" id="addCouponModal" tabindex="-1" aria-labelledby="addCouponModalLabel" aria-hidden="true">
            <div class="modal-dialog modal-dialog-centered">
                <div class="modal-content modal-content-custom">
                    <div class="modal-header bg-success text-white border-0 py-3" style="border-top-left-radius: 16px; border-top-right-radius: 16px;">
                        <h5 class="modal-title fw-bold" id="addCouponModalLabel"><i class="fas fa-plus-circle me-2"></i>Tạo mã giảm giá mới</h5>
                        <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
                    </div>
                    <form action="MainController" method="POST">
                        <input type="hidden" name="action" value="CouponAction" />
                        <input type="hidden" name="subAction" value="add" />

                        <div class="modal-body p-4 row g-3">
                            <div class="col-12">
                                <label class="form-label fw-bold">Mã CODE giảm giá <span class="text-danger">*</span></label>
                                <input type="text" name="code" class="form-control text-uppercase fw-bold" required placeholder="Ví dụ: GIAM20K, MUAHE10..." />
                            </div>

                            <div class="col-md-6">
                                <label class="form-label fw-bold">Phần trăm giảm (%)</label>
                                <input type="number" name="discountPercent" class="form-control fw-semibold" min="0" max="100" value="0" />
                            </div>
                            <div class="col-md-6">
                                <label class="form-label fw-bold">Số tiền giảm thẳng (VNĐ)</label>
                                <input type="number" name="discountAmount" class="form-control fw-semibold" min="0" value="0" />
                            </div>

                            <div class="col-md-6">
                                <label class="form-label fw-bold">Đơn tối thiểu áp dụng</label>
                                <input type="number" name="minOrderValue" class="form-control fw-semibold" min="0" value="0" />
                            </div>
                            <div class="col-md-6">
                                <label class="form-label fw-bold">Giới hạn sử dụng</label>
                                <input type="number" name="usageLimit" class="form-control fw-semibold" min="1" placeholder="Vô hạn nếu để trống" />
                            </div>

                            <div class="col-12">
                                <label class="form-label fw-bold">Thời hạn hết hạn (Expiry Date)</label>
                                <input type="datetime-local" name="expiryDate" class="form-control" />
                            </div>
                        </div>
                        <div class="modal-footer border-0 p-4 pt-0 justify-content-between">
                            <button type="button" class="btn btn-outline-secondary px-4 fw-bold rounded-pill" data-bs-dismiss="modal">Hủy bỏ</button>
                            <button type="submit" class="btn btn-success px-4 fw-bold rounded-pill"><i class="fas fa-save me-1"></i> Tạo mã</button>
                        </div>
                    </form>
                </div>
            </div>
        </div>

        <!-- Edit Coupon Modal -->
        <div class="modal fade" id="editCouponModal" tabindex="-1" aria-labelledby="editCouponModalLabel" aria-hidden="true">
            <div class="modal-dialog modal-dialog-centered">
                <div class="modal-content modal-content-custom">
                    <div class="modal-header bg-dark text-white border-0 py-3" style="border-top-left-radius: 16px; border-top-right-radius: 16px;">
                        <h5 class="modal-title fw-bold" id="editCouponModalLabel"><i class="fas fa-edit me-2"></i>Chỉnh sửa mã giảm giá</h5>
                        <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
                    </div>
                    <form action="MainController" method="POST">
                        <input type="hidden" name="action" value="CouponAction" />
                        <input type="hidden" name="subAction" value="update" />
                        
                        <input type="hidden" id="editCouponId" name="couponId" />

                        <div class="modal-body p-4 row g-3">
                            <div class="col-12">
                                <label class="form-label fw-bold">Mã CODE giảm giá <span class="text-danger">*</span></label>
                                <input type="text" id="editCouponCode" name="code" class="form-control text-uppercase fw-bold" required />
                            </div>

                            <div class="col-md-6">
                                <label class="form-label fw-bold">Phần trăm giảm (%)</label>
                                <input type="number" id="editCouponPercent" name="discountPercent" class="form-control fw-semibold" min="0" max="100" />
                            </div>
                            <div class="col-md-6">
                                <label class="form-label fw-bold">Số tiền giảm thẳng (VNĐ)</label>
                                <input type="number" id="editCouponAmount" name="discountAmount" class="form-control fw-semibold" min="0" />
                            </div>

                            <div class="col-md-6">
                                <label class="form-label fw-bold">Đơn tối thiểu áp dụng</label>
                                <input type="number" id="editCouponMin" name="minOrderValue" class="form-control fw-semibold" min="0" />
                            </div>
                            <div class="col-md-6">
                                <label class="form-label fw-bold">Giới hạn sử dụng</label>
                                <input type="number" id="editCouponLimit" name="usageLimit" class="form-control fw-semibold" min="1" placeholder="Vô hạn nếu để trống" />
                            </div>

                            <div class="col-12">
                                <label class="form-label fw-bold">Thời hạn hết hạn</label>
                                <input type="datetime-local" id="editCouponExpiry" name="expiryDate" class="form-control" />
                            </div>

                            <div class="col-12">
                                <div class="form-check form-switch mt-2">
                                    <input class="form-check-input" type="checkbox" name="isActive" id="editCouponActive" />
                                    <label class="form-check-label fw-bold text-success" for="editCouponActive">Kích hoạt hoạt động</label>
                                </div>
                            </div>
                        </div>
                        <div class="modal-footer border-0 p-4 pt-0 justify-content-between">
                            <button type="button" class="btn btn-outline-secondary px-4 fw-bold rounded-pill" data-bs-dismiss="modal">Hủy bỏ</button>
                            <button type="submit" class="btn btn-danger px-4 fw-bold rounded-pill"><i class="fas fa-save me-1"></i> Lưu thay đổi</button>
                        </div>
                    </form>
                </div>
            </div>
        </div>

        <!-- Adjust Points Modal -->
        <div class="modal fade" id="adjustPointsModal" tabindex="-1" aria-labelledby="adjustPointsModalLabel" aria-hidden="true">
            <div class="modal-dialog modal-dialog-centered">
                <div class="modal-content modal-content-custom">
                    <div class="modal-header bg-dark text-white border-0 py-3" style="border-top-left-radius: 16px; border-top-right-radius: 16px;">
                        <h5 class="modal-title fw-bold" id="adjustPointsModalLabel"><i class="fas fa-users-cog me-2"></i>Điều chỉnh điểm tích lũy thành viên</h5>
                        <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
                    </div>
                    <form action="MainController" method="POST">
                        <input type="hidden" name="action" value="MemberPointsAction" />
                        <input type="hidden" name="subAction" value="updateCustomerPoints" />
                        
                        <input type="hidden" id="adjustPointsUserId" name="userId" />

                        <div class="modal-body p-4 row g-3">
                            <div class="col-12">
                                <label class="form-label fw-bold text-secondary">Tài khoản thành viên</label>
                                <input type="text" id="adjustPointsUsername" class="form-control bg-light border-0 fw-bold" readonly />
                            </div>
                            <div class="col-12">
                                <label class="form-label fw-bold text-secondary">Họ và tên khách hàng</label>
                                <input type="text" id="adjustPointsFullName" class="form-control bg-light border-0 fw-bold" readonly />
                            </div>
                            <div class="col-12">
                                <label for="adjustPointsValue" class="form-label fw-bold text-dark">Số điểm tích lũy mới</label>
                                <div class="input-group">
                                    <button class="btn btn-outline-secondary" type="button" onclick="adjustPointsInput(-50)">-50</button>
                                    <button class="btn btn-outline-secondary" type="button" onclick="adjustPointsInput(-10)">-10</button>
                                    <input type="number" id="adjustPointsValue" name="points" class="form-control text-center fw-bold fs-4 border-secondary-subtle" min="0" required />
                                    <button class="btn btn-outline-secondary" type="button" onclick="adjustPointsInput(10)">+10</button>
                                    <button class="btn btn-outline-secondary" type="button" onclick="adjustPointsInput(50)">+50</button>
                                </div>
                            </div>
                        </div>
                        <div class="modal-footer border-0 p-4 pt-0 justify-content-between">
                            <button type="button" class="btn btn-outline-secondary px-4 fw-bold rounded-pill" data-bs-dismiss="modal">Hủy bỏ</button>
                            <button type="submit" class="btn btn-danger px-4 fw-bold rounded-pill"><i class="fas fa-save me-1"></i> Lưu thay đổi</button>
                        </div>
                    </form>
                </div>
            </div>
        </div>

        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
        <script>
            let addCouponModalObj;
            let editCouponModalObj;
            let adjustPointsModalObj;

            document.addEventListener("DOMContentLoaded", function() {
                addCouponModalObj = new bootstrap.Modal(document.getElementById('addCouponModal'));
                editCouponModalObj = new bootstrap.Modal(document.getElementById('editCouponModal'));
                adjustPointsModalObj = new bootstrap.Modal(document.getElementById('adjustPointsModal'));
            });

            function openAddCouponModal() {
                addCouponModalObj.show();
            }

            function openEditCouponModal(button) {
                document.getElementById('editCouponId').value = button.dataset.id;
                document.getElementById('editCouponCode').value = button.dataset.code;
                document.getElementById('editCouponAmount').value = button.dataset.amount;
                document.getElementById('editCouponPercent').value = button.dataset.percent;
                document.getElementById('editCouponMin').value = button.dataset.min;
                document.getElementById('editCouponLimit').value = button.dataset.limit || '';
                
                // Format datetime-local string compatibility yyyy-MM-ddTHH:mm
                let expiry = button.dataset.expiry;
                if (expiry && expiry.length >= 16) {
                    document.getElementById('editCouponExpiry').value = expiry.substring(0, 16);
                } else {
                    document.getElementById('editCouponExpiry').value = '';
                }
                
                document.getElementById('editCouponActive').checked = button.dataset.active === 'true';
                
                editCouponModalObj.show();
            }

            function openAdjustPointsModal(userId, username, fullName, currentPoints) {
                document.getElementById('adjustPointsUserId').value = userId;
                document.getElementById('adjustPointsUsername').value = '@' + username;
                document.getElementById('adjustPointsFullName').value = fullName;
                document.getElementById('adjustPointsValue').value = currentPoints;
                
                adjustPointsModalObj.show();
            }

            function adjustPointsInput(amount) {
                const input = document.getElementById('adjustPointsValue');
                let val = parseInt(input.value) || 0;
                val += amount;
                if (val < 0) val = 0;
                input.value = val;
            }
        </script>
    </body>
</html>

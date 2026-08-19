<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn"%>
<!DOCTYPE html>
<html>
    <head>
        <title>Quản lý lô hàng (Batch Tracking) - NutriOverflow</title>
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
        </style>
    </head>
    <body class="bg-light">
        <c:set var="activeTab" value="Batches" scope="request" />
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

        <!-- KPI Calculation -->
        <c:set var="totalQty" value="0" />
        <c:set var="expiringSoonCount" value="0" />
        <%
            java.util.Date today = new java.util.Date();
            long thirtyDaysMs = 30L * 24 * 60 * 60 * 1000;
            request.setAttribute("today", today);
            request.setAttribute("thirtyDaysMs", thirtyDaysMs);
        %>
        <c:forEach var="batch" items="${requestScope.LIST_BATCHES}">
            <c:set var="totalQty" value="${totalQty + batch.quantity}" />
            <c:if test="${not empty batch.expDate}">
                <c:set var="diff" value="${batch.expDate.time - today.time}" />
                <c:if test="${diff > 0 and diff < thirtyDaysMs}">
                    <c:set var="expiringSoonCount" value="${expiringSoonCount + 1}" />
                </c:if>
            </c:if>
        </c:forEach>

        <div class="container-fluid px-4 pb-5">
            <div class="d-flex justify-content-between align-items-center mb-4">
                <h3 class="fw-bold text-dark m-0"><i class="fas fa-boxes me-2 text-danger"></i>Quản lý kho (Batch Tracking)</h3>
                <button type="button" class="btn btn-success fw-bold shadow-sm px-4 py-2 rounded-pill" onclick="openImportModal()">
                    <i class="fas fa-plus-circle me-2"></i>Khai báo nhập lô
                </button>
            </div>

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
            <div class="row g-4 mb-4">
                <!-- Card 1: Total Batches -->
                <div class="col-md-4">
                    <div class="card kpi-card shadow-sm p-4 d-flex flex-row align-items-center justify-content-between">
                        <div>
                            <span class="text-muted small fw-bold text-uppercase d-block mb-1">Tổng số lô hàng</span>
                            <h2 class="fw-bold text-dark m-0">${fn:length(requestScope.LIST_BATCHES)} <span class="fs-6 text-muted fw-normal">lô đang lưu</span></h2>
                        </div>
                        <div class="kpi-icon-wrapper bg-info-light">
                            <i class="fas fa-layer-group"></i>
                        </div>
                    </div>
                </div>
                <!-- Card 2: Total Stock Qty -->
                <div class="col-md-4">
                    <div class="card kpi-card shadow-sm p-4 d-flex flex-row align-items-center justify-content-between">
                        <div>
                            <span class="text-muted small fw-bold text-uppercase d-block mb-1">Tổng sản phẩm nhập lô</span>
                            <h2 class="fw-bold text-success m-0">${totalQty} <span class="fs-6 text-muted fw-normal">đơn vị</span></h2>
                        </div>
                        <div class="kpi-icon-wrapper bg-success-light">
                            <i class="fas fa-plus-circle"></i>
                        </div>
                    </div>
                </div>
                <!-- Card 3: Expiring soon batches -->
                <div class="col-md-4">
                    <div class="card kpi-card shadow-sm p-4 d-flex flex-row align-items-center justify-content-between">
                        <div>
                            <span class="text-muted small fw-bold text-uppercase d-block mb-1">Lô hàng sắp hết hạn</span>
                            <h2 class="fw-bold text-danger m-0">${expiringSoonCount} <span class="fs-6 text-muted fw-normal">lô (< 30 ngày)</span></h2>
                        </div>
                        <div class="kpi-icon-wrapper bg-danger-light">
                            <i class="fas fa-calendar-times"></i>
                        </div>
                    </div>
                </div>
            </div>

            <!-- 2. SEARCH & FILTERS -->
            <div class="card border-0 shadow-sm rounded-4 p-4 mb-4">
                <form action="MainController" method="GET" class="row g-3 align-items-end">
                    <input type="hidden" name="action" value="ManageBatches" />
                    
                    <div class="col-md-8">
                        <label class="form-label fw-bold text-secondary"><i class="fas fa-search me-1"></i> Tìm kiếm lô hàng</label>
                        <input type="text" name="search" class="form-control" value="${param.search}" placeholder="Nhập tên sản phẩm, mã SKU hoặc số lô hàng...">
                    </div>

                    <div class="col-md-4">
                        <button type="submit" class="btn btn-dark w-100 fw-bold"><i class="fas fa-search me-1"></i> Tìm kiếm</button>
                    </div>
                </form>
            </div>

            <!-- 3. BATCHES TABLE -->
            <div class="card border-0 shadow-sm rounded-4 p-4">
                <c:choose>
                    <c:when test="${not empty requestScope.LIST_BATCHES}">
                        <div class="table-responsive">
                            <table class="table custom-table align-middle mb-0">
                                <thead class="table-dark">
                                    <tr>
                                        <th style="width: 50px;">STT</th>
                                        <th style="width: 130px;">Số lô</th>
                                        <th>Sản phẩm</th>
                                        <th style="width: 100px;" class="text-center">Số lượng</th>
                                        <th style="width: 130px;">Ngày sản xuất (MFG)</th>
                                        <th style="width: 130px;">Hạn sử dụng (EXP)</th>
                                        <th style="width: 160px;">Nhà phân phối</th>
                                        <th>Người nhập</th>
                                        <th style="width: 140px;">Thời gian khai báo</th>
                                        <th style="width: 120px;" class="text-center">Trạng thái</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <c:forEach var="b" items="${requestScope.LIST_BATCHES}" varStatus="counter">
                                        <c:set var="isExpired" value="false" />
                                        <c:set var="isExpiringSoon" value="false" />
                                        <c:if test="${not empty b.expDate}">
                                            <c:choose>
                                                <c:when test="${b.expDate.time <= today.time}">
                                                    <c:set var="isExpired" value="true" />
                                                </c:when>
                                                <c:otherwise>
                                                    <c:set var="diff" value="${b.expDate.time - today.time}" />
                                                    <c:if test="${diff < thirtyDaysMs}">
                                                        <c:set var="isExpiringSoon" value="true" />
                                                    </c:if>
                                                </c:otherwise>
                                            </c:choose>
                                        </c:if>

                                        <tr class="${isExpired ? 'table-danger' : (isExpiringSoon ? 'table-warning' : '')}">
                                            <td>${counter.count}</td>
                                            <td><span class="badge bg-dark font-monospace fs-6">${not empty b.batchNumber ? b.batchNumber : 'LÔ-MẶC-ĐỊNH'}</span></td>
                                            <td>
                                                <div class="fw-bold text-dark">${b.productName}</div>
                                                <span class="badge bg-secondary small">${b.sku}</span>
                                            </td>
                                            <td class="text-center fw-bold text-danger fs-5">${b.quantity}</td>
                                            <td>
                                                <c:choose>
                                                    <c:when test="${not empty b.mfgDate}">
                                                        <fmt:formatDate value="${b.mfgDate}" pattern="dd-MM-yyyy" />
                                                    </c:when>
                                                    <c:otherwise><span class="text-muted small">N/A</span></c:otherwise>
                                                </c:choose>
                                            </td>
                                            <td>
                                                <c:choose>
                                                    <c:when test="${not empty b.expDate}">
                                                        <fmt:formatDate value="${b.expDate}" pattern="dd-MM-yyyy" />
                                                    </c:when>
                                                    <c:otherwise><span class="text-muted small">N/A</span></c:otherwise>
                                                </c:choose>
                                            </td>
                                            <td class="fw-semibold text-secondary">
                                                <c:choose>
                                                    <c:when test="${not empty b.distributorName}">
                                                        <c:out value="${b.distributorName}" />
                                                    </c:when>
                                                    <c:otherwise><span class="text-muted small">N/A</span></c:otherwise>
                                                </c:choose>
                                            </td>
                                            <td class="fw-semibold text-secondary">${b.staffName}</td>
                                            <td>
                                                <small class="fw-semibold text-secondary">
                                                    <fmt:formatDate value="${b.updatedAt}" pattern="dd-MM-yyyy HH:mm" />
                                                </small>
                                            </td>
                                            <td class="text-center">
                                                <c:choose>
                                                    <c:when test="${isExpired}">
                                                        <span class="badge bg-danger"><i class="fas fa-skull-crossbones me-1"></i>Hết hạn</span>
                                                    </c:when>
                                                    <c:when test="${isExpiringSoon}">
                                                        <span class="badge bg-warning text-dark"><i class="fas fa-exclamation-triangle me-1"></i>Sắp hết hạn</span>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <span class="badge bg-success"><i class="fas fa-check-circle me-1"></i>An toàn</span>
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
                            <h5 class="text-muted">Không tìm thấy lô hàng nào trong kho!</h5>
                        </div>
                    </c:otherwise>
                </c:choose>
            </div>
        </div>

        <!-- BATCH IMPORT MODAL -->
        <div class="modal fade" id="importBatchModal" tabindex="-1" aria-labelledby="importBatchModalLabel" aria-hidden="true" data-bs-backdrop="static">
            <div class="modal-dialog modal-lg modal-dialog-centered">
                <div class="modal-content modal-content-custom">
                    <div class="modal-header bg-success text-white border-0 py-3" style="border-top-left-radius: 16px; border-top-right-radius: 16px;">
                        <h5 class="modal-title fw-bold" id="importBatchModalLabel"><i class="fas fa-boxes me-2"></i>Khai báo nhập lô hàng mới</h5>
                        <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
                    </div>
                    
                    <form action="MainController" method="POST" onsubmit="return validateBatchForm()">
                        <input type="hidden" name="action" value="ImportBatch" />
                        <input type="hidden" name="searchFilter" value="${param.search}" />
                        
                        <div class="modal-body p-4 row g-3">
                            <!-- Product selection -->
                            <div class="col-12">
                                <label class="form-label fw-bold">Chọn sản phẩm nhập kho <span class="text-danger">*</span></label>
                                <select name="productId" class="form-select" required>
                                    <option value="" disabled selected>-- Chọn sản phẩm trong danh mục --</option>
                                    <c:forEach var="prod" items="${requestScope.LIST_PRODUCTS}">
                                        <option value="${prod.id}">${prod.name} (${prod.sku})</option>
                                    </c:forEach>
                                </select>
                            </div>

                            <!-- Quantity & Batch Number -->
                            <div class="col-md-6">
                                <label class="form-label fw-bold">Số lượng nhập kho <span class="text-danger">*</span></label>
                                <input type="number" name="quantity" class="form-control" min="1" value="100" required placeholder="Nhập số lượng..." />
                            </div>
                            <div class="col-md-6">
                                <label class="form-label fw-bold">Số lô hàng (Batch Number) <span class="text-danger">*</span></label>
                                <input type="text" name="batchNumber" class="form-control" required placeholder="Ví dụ: LOT-20260617-01..." />
                            </div>

                            <!-- MFG & EXP Dates -->
                            <div class="col-md-6">
                                <label class="form-label fw-bold">Ngày sản xuất (MFG)</label>
                                <input type="date" id="mfgDate" name="mfgDate" class="form-control" />
                            </div>
                            <div class="col-md-6">
                                <label class="form-label fw-bold">Hạn sử dụng (EXP)</label>
                                <input type="date" id="expDate" name="expDate" class="form-control" />
                            </div>
                            <div class="col-12">
                                <label class="form-label fw-bold">Nhà phân phối (Distributor)</label>
                                <input type="text" name="distributorName" class="form-control" placeholder="Ví dụ: Công ty Dược phẩm ABC, Abbott Việt Nam..." />
                            </div>
                        </div>

                        <!-- Modal Action Footer -->
                        <div class="modal-footer border-0 p-4 pt-0 justify-content-between">
                            <button type="button" class="btn btn-outline-secondary px-4 fw-bold rounded-pill" data-bs-dismiss="modal">Hủy bỏ</button>
                            <button type="submit" class="btn btn-success px-4 fw-bold rounded-pill">
                                <i class="fas fa-save me-1"></i> Xác nhận nhập lô
                            </button>
                        </div>
                    </form>
                </div>
            </div>
        </div>

        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
        <script>
            let importBatchModalObj;

            document.addEventListener("DOMContentLoaded", function() {
                importBatchModalObj = new bootstrap.Modal(document.getElementById('importBatchModal'));
            });

            function openImportModal() {
                importBatchModalObj.show();
            }

            function validateBatchForm() {
                const mfgVal = document.getElementById("mfgDate").value;
                const expVal = document.getElementById("expDate").value;
                if (mfgVal && expVal) {
                    const mfgDate = new Date(mfgVal);
                    const expDate = new Date(expVal);
                    if (expDate <= mfgDate) {
                        alert("Hạn sử dụng (EXP) phải sau Ngày sản xuất (MFG)!");
                        return false;
                    }
                }
                return true;
            }
        </script>
    </body>
</html>

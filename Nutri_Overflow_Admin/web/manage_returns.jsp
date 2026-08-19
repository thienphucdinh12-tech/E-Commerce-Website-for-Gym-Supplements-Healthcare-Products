<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn"%>
<!DOCTYPE html>
<html>
    <head>
        <title>Quản lý Hàng hoàn (Return Logistics) - NutriOverflow</title>
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
        </style>
    </head>
    <body class="bg-light">
        <c:set var="activeTab" value="Returns" scope="request" />
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
            <h3 class="mb-4 fw-bold text-dark"><i class="fas fa-undo me-2 text-danger"></i>Quản lý hàng hoàn (Return Logistics)</h3>

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
                <!-- Card 1: Eligible Returns -->
                <div class="col-md-3">
                    <div class="card kpi-card shadow-sm p-4 d-flex flex-row align-items-center justify-content-between">
                        <div>
                            <span class="text-muted small fw-bold text-uppercase d-block mb-1">Đơn chờ tiếp nhận</span>
                            <h2 class="fw-bold text-dark m-0">${fn:length(requestScope.LIST_RETURN_ORDERS)} <span class="fs-6 text-muted fw-normal">đơn hàng</span></h2>
                        </div>
                        <div class="kpi-icon-wrapper bg-warning-light">
                            <i class="fas fa-hourglass-half"></i>
                        </div>
                    </div>
                </div>
                <!-- Card 2: Processed Returns -->
                <div class="col-md-3">
                    <div class="card kpi-card shadow-sm p-4 d-flex flex-row align-items-center justify-content-between">
                        <div>
                            <span class="text-muted small fw-bold text-uppercase d-block mb-1">Đơn hàng đã xử lý</span>
                            <h2 class="fw-bold text-info m-0">${requestScope.STATS_TOTAL_ORDERS} <span class="fs-6 text-muted fw-normal">đơn hoàn</span></h2>
                        </div>
                        <div class="kpi-icon-wrapper bg-info-light">
                            <i class="fas fa-check-double"></i>
                        </div>
                    </div>
                </div>
                <!-- Card 3: Restocked Qty -->
                <div class="col-md-3">
                    <div class="card kpi-card shadow-sm p-4 d-flex flex-row align-items-center justify-content-between">
                        <div>
                            <span class="text-muted small fw-bold text-uppercase d-block mb-1">Đã nhập lại kho</span>
                            <h2 class="fw-bold text-success m-0">${requestScope.STATS_TOTAL_RESTOCK} <span class="fs-6 text-muted fw-normal">sản phẩm</span></h2>
                        </div>
                        <div class="kpi-icon-wrapper bg-success-light">
                            <i class="fas fa-plus-circle"></i>
                        </div>
                    </div>
                </div>
                <!-- Card 4: Discarded Qty -->
                <div class="col-md-3">
                    <div class="card kpi-card shadow-sm p-4 d-flex flex-row align-items-center justify-content-between">
                        <div>
                            <span class="text-muted small fw-bold text-uppercase d-block mb-1">Đã tiêu hủy / Bỏ qua</span>
                            <h2 class="fw-bold text-danger m-0">${requestScope.STATS_TOTAL_DISCARD} <span class="fs-6 text-muted fw-normal">sản phẩm</span></h2>
                        </div>
                        <div class="kpi-icon-wrapper bg-danger-light">
                            <i class="fas fa-trash-alt"></i>
                        </div>
                    </div>
                </div>
            </div>

            <!-- 2. SEARCH & FILTERS -->
            <div class="card border-0 shadow-sm rounded-4 p-4 mb-4">
                <form action="MainController" method="GET" class="row g-3 align-items-end">
                    <input type="hidden" name="action" value="ManageReturns" />
                    
                    <div class="col-md-8">
                        <label class="form-label fw-bold text-secondary"><i class="fas fa-search me-1"></i> Tìm kiếm đơn hàng trả về</label>
                        <input type="text" name="search" class="form-control" value="${param.search}" placeholder="Nhập mã đơn hàng, tên khách hàng hoặc tên đăng nhập...">
                    </div>

                    <div class="col-md-4">
                        <button type="submit" class="btn btn-dark w-100 fw-bold"><i class="fas fa-search me-1"></i> Tìm kiếm</button>
                    </div>
                </form>
            </div>

            <!-- 3. ELIGIBLE RETURN ORDERS TABLE -->
            <div class="card border-0 shadow-sm rounded-4 p-4">
                <c:choose>
                    <c:when test="${not empty requestScope.LIST_RETURN_ORDERS}">
                        <div class="table-responsive">
                            <table class="table custom-table align-middle mb-0">
                                <thead class="table-dark">
                                    <tr>
                                        <th style="width: 80px;">Mã ĐH</th>
                                        <th style="width: 140px;">Ngày Đặt</th>
                                        <th>Khách Hàng</th>
                                        <th style="width: 160px;">Phương Thức</th>
                                        <th style="width: 140px;">Tổng Tiền</th>
                                        <th style="width: 160px;" class="text-center">Trạng Thái ĐH</th>
                                        <th style="width: 180px;" class="text-center">Thao Tác</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <c:forEach var="order" items="${requestScope.LIST_RETURN_ORDERS}">
                                        <tr>
                                            <td class="fw-bold text-danger">#${order.orderId}</td>
                                            <td>
                                                <small class="fw-semibold">
                                                    <fmt:formatDate value="${order.orderDate}" pattern="dd-MM-yyyy HH:mm" />
                                                </small>
                                            </td>
                                            <td>
                                                <div class="fw-bold text-dark">${order.customerName}</div>
                                                <div class="text-muted small text-truncate" style="max-width: 250px;" title="${order.shippingAddress}">
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
                                                <span class="badge-soft badge-soft-${order.statusColor}"><i class="fas fa-circle me-1 small"></i>${order.statusLabel}</span>
                                            </td>
                                            <td class="text-center">
                                                <button type="button" class="btn btn-danger btn-sm fw-bold shadow-sm rounded-pill px-3" 
                                                        onclick="openReturnModal('${order.orderId}')">
                                                    <i class="fas fa-clipboard-check me-1"></i> Đánh giá & Hoàn kho
                                                </button>
                                            </td>
                                        </tr>
                                    </c:forEach>
                                </tbody>
                            </table>
                        </div>
                    </c:when>
                    <c:otherwise>
                        <div class="text-center py-5">
                            <i class="fas fa-undo fa-3x text-muted mb-3"></i>
                            <h5 class="text-muted">Không có đơn hàng nào cần tiếp nhận hoàn trả!</h5>
                        </div>
                    </c:otherwise>
                </c:choose>
            </div>
        </div>

        <!-- RETURN ASSESSMENT MODAL -->
        <div class="modal fade" id="returnModal" tabindex="-1" aria-labelledby="returnModalLabel" aria-hidden="true" data-bs-backdrop="static">
            <div class="modal-dialog modal-xl modal-dialog-centered">
                <div class="modal-content" style="border-radius: 16px;">
                    <form id="returnForm" action="MainController" method="POST" class="m-0">
                        <input type="hidden" name="action" value="ReturnAction" />
                        <input type="hidden" id="returnOrderId" name="orderId" />
                        
                        <div class="modal-header bg-danger text-white border-0 py-3" style="border-top-left-radius: 16px; border-top-right-radius: 16px;">
                            <h5 class="modal-title fw-bold" id="returnModalLabel"><i class="fas fa-clipboard-check me-2"></i>Đánh giá hàng hoàn & Hoàn kho đơn hàng #<span id="modalOrderIdTitle"></span></h5>
                            <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
                        </div>
                        
                        <div class="modal-body p-4">
                            <!-- 1. Order information summary -->
                            <div class="row g-3 bg-light rounded-3 p-3 mb-4 border border-secondary-subtle">
                                <div class="col-md-4">
                                    <small class="text-uppercase text-secondary fw-bold d-block">Khách hàng</small>
                                    <strong class="text-dark" id="custName"></strong>
                                </div>
                                <div class="col-md-4">
                                    <small class="text-uppercase text-secondary fw-bold d-block">Phương thức thanh toán</small>
                                    <span class="badge bg-secondary fw-bold" id="payMethod"></span>
                                </div>
                                <div class="col-md-4">
                                    <small class="text-uppercase text-secondary fw-bold d-block">Mã GHN / Vận đơn</small>
                                    <strong class="text-dark" id="ghnCode">N/A</strong>
                                </div>
                                <div class="col-12 mt-2">
                                    <small class="text-uppercase text-secondary fw-bold d-block">Địa chỉ giao hàng</small>
                                    <span class="text-dark fw-semibold" id="shipAddr"></span>
                                </div>
                                <div class="col-12 mt-2" id="orderNoteContainer">
                                    <small class="text-uppercase text-secondary fw-bold d-block text-danger">Ghi chú của khách</small>
                                    <span class="text-danger italic small" id="orderNote"></span>
                                </div>
                            </div>

                            <!-- 2. Product returns checklist -->
                            <h6 class="fw-bold text-dark mb-3"><i class="fas fa-boxes me-2"></i>Chi tiết sản phẩm & Đánh giá trạng thái</h6>
                            <div class="table-responsive">
                                <table class="table table-bordered align-middle text-center mb-0">
                                    <thead class="table-secondary small">
                                        <tr>
                                            <th style="width: 60px;">Ảnh</th>
                                            <th>Tên sản phẩm</th>
                                            <th style="width: 120px;">Mã SKU</th>
                                            <th style="width: 100px;">Số lượng nhận</th>
                                            <th style="width: 200px;">Tình trạng hộp/seal</th>
                                            <th style="width: 200px;">Hướng xử lý</th>
                                            <th>Ghi chú lỗi (nếu có)</th>
                                        </tr>
                                    </thead>
                                    <tbody id="returnItemsTable">
                                        <!-- Dynamically generated -->
                                    </tbody>
                                </table>
                            </div>
                        </div>

                        <!-- Modal Action Footer -->
                        <div class="modal-footer border-0 p-4 pt-0 justify-content-between">
                            <button type="button" class="btn btn-outline-secondary px-4 fw-bold rounded-pill" data-bs-dismiss="modal">Đóng lại</button>
                            <button type="submit" class="btn btn-danger px-4 fw-bold rounded-pill shadow-sm">
                                <i class="fas fa-box-open me-1"></i> Xác nhận hoàn kho
                            </button>
                        </div>
                    </form>
                </div>
            </div>
        </div>

        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
        <script>
            let returnModalObj;

            document.addEventListener("DOMContentLoaded", function() {
                returnModalObj = new bootstrap.Modal(document.getElementById('returnModal'));
            });

            function openReturnModal(orderId) {
                // Reset metadata fields
                document.getElementById('modalOrderIdTitle').textContent = orderId;
                document.getElementById('returnOrderId').value = orderId;
                document.getElementById('custName').textContent = "Đang tải...";
                document.getElementById('payMethod').textContent = "Đang tải...";
                document.getElementById('payMethod').className = "badge bg-secondary fw-bold";
                document.getElementById('ghnCode').textContent = "Đang tải...";
                document.getElementById('shipAddr').textContent = "Đang tải...";
                document.getElementById('orderNoteContainer').style.display = 'none';
                document.getElementById('returnItemsTable').innerHTML = '<tr><td colspan="7" class="text-center"><i class="fas fa-spinner fa-spin me-2"></i>Đang tải chi tiết đơn hàng...</td></tr>';
                
                returnModalObj.show();

                // Fetch details using the existing AJAX getDetails route
                fetch("MainController?action=OrderAction&subAction=getDetails&orderId=" + orderId)
                    .then(response => {
                        if (!response.ok) throw new Error("Fetch order details failed.");
                        return response.json();
                    })
                    .then(data => {
                        document.getElementById('custName').textContent = data.customerName;
                        document.getElementById('payMethod').textContent = data.paymentMethod + " (" + data.paymentStatus + ")";
                        document.getElementById('payMethod').className = "badge bg-" + (data.paymentStatus === 'PAID' ? 'success' : 'danger') + " fw-bold";
                        document.getElementById('ghnCode').textContent = data.ghnOrderCode ? data.ghnOrderCode : "N/A";
                        document.getElementById('shipAddr').textContent = data.shippingAddress;
                        
                        if (data.note && data.note.trim().length > 0) {
                            document.getElementById('orderNoteContainer').style.display = 'block';
                            document.getElementById('orderNote').textContent = data.note;
                        } else {
                            document.getElementById('orderNoteContainer').style.display = 'none';
                        }

                        // Build products checklist rows
                        let tableBody = document.getElementById('returnItemsTable');
                        tableBody.innerHTML = "";

                        data.items.forEach((item, index) => {
                            let tr = document.createElement('tr');
                            
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
                            tdSku.innerHTML = `<span class="badge bg-dark">\${item.sku}</span>`;
                            tr.appendChild(tdSku);
                            
                            // Quantity cell
                            let tdQty = document.createElement('td');
                            tdQty.className = "fw-bold text-danger";
                            tdQty.innerHTML = `\${item.quantity} <input type="hidden" name="productId" value="\${item.productId}" /><input type="hidden" name="quantity" value="\${item.quantity}" />`;
                            tr.appendChild(tdQty);
                            
                            // Condition dropdown (SEALED / DAMAGED)
                            let tdCond = document.createElement('td');
                            tdCond.innerHTML = `
                                <select name="condition" class="form-select form-select-sm" onchange="autoSuggestAction(this, \${index})">
                                    <option value="SEALED" selected>Còn nguyên vẹn (SEALED)</option>
                                    <option value="DAMAGED">Hư hại, móp méo (DAMAGED)</option>
                                </select>
                            `;
                            tr.appendChild(tdCond);
                            
                            // Action dropdown (RESTOCK / DISCARD)
                            let tdAct = document.createElement('td');
                            tdAct.innerHTML = `
                                <select name="action" class="form-select form-select-sm" id="action-select-\${index}">
                                    <option value="RESTOCK" selected>Nhập lại kho (RESTOCK)</option>
                                    <option value="DISCARD">Hủy bỏ sản phẩm (DISCARD)</option>
                                </select>
                            `;
                            tr.appendChild(tdAct);
                            
                            // Notes cell
                            let tdNote = document.createElement('td');
                            tdNote.innerHTML = `<input type="text" name="notes" class="form-control form-control-sm" placeholder="Ghi chú thêm..." />`;
                            tr.appendChild(tdNote);
                            
                            tableBody.appendChild(tr);
                        });
                    })
                    .catch(err => {
                        console.error(err);
                        document.getElementById('returnItemsTable').innerHTML = '<tr><td colspan="7" class="text-center text-danger"><i class="fas fa-exclamation-triangle me-2"></i>Không thể tải chi tiết đơn hàng! Vui lòng thử lại.</td></tr>';
                    });
            }

            // AUTO-SUGGEST MICRO-ANIMATION AND LOGIC: 
            // If condition is SEALED -> Restock. If condition is DAMAGED -> Discard
            function autoSuggestAction(conditionSelect, index) {
                let actionSelect = document.getElementById("action-select-" + index);
                if (conditionSelect.value === "DAMAGED") {
                    actionSelect.value = "DISCARD";
                    // Brief flash effect to indicate automatic change
                    actionSelect.classList.add("is-invalid");
                    setTimeout(() => {
                        actionSelect.classList.remove("is-invalid");
                    }, 500);
                } else {
                    actionSelect.value = "RESTOCK";
                    actionSelect.classList.add("is-valid");
                    setTimeout(() => {
                        actionSelect.classList.remove("is-valid");
                    }, 500);
                }
            }
        </script>
    </body>
</html>

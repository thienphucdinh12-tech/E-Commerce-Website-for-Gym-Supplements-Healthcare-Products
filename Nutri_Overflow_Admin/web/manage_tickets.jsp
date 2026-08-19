<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt"%>
<!DOCTYPE html>
<html>
    <head>
        <title>Quản lý Hỗ trợ & Khiếu nại - NutriOverflow</title>
        <jsp:include page="includes/header.jsp" />
        <style>
            .ticket-card {
                transition: transform 0.2s ease, box-shadow 0.2s ease;
                border-radius: 16px;
            }
            .ticket-card:hover {
                transform: translateY(-5px);
            }
            .kpi-icon {
                width: 48px;
                height: 48px;
                display: flex;
                align-items: center;
                justify-content: center;
                border-radius: 12px;
            }
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
            .badge-category {
                font-weight: 600;
                padding: 0.4em 0.8em;
                border-radius: 8px;
            }
            .bg-cat-quality { background-color: #ffe4e6; color: #e11d48; }
            .bg-cat-missing { background-color: #fef3c7; color: #d97706; }
            .bg-cat-damaged { background-color: #ede9fe; color: #7c3aed; }
            .bg-cat-other { background-color: #e2e8f0; color: #475569; }
        </style>
    </head>
    <body class="bg-light">
        <c:set var="activeTab" value="Tickets" scope="request" />
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
            <h3 class="fw-bold text-dark mb-4"><i class="fas fa-headset me-2 text-danger"></i>Quản lý Hỗ trợ & Khiếu nại</h3>

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

            <!-- KPI Metric Cards -->
            <div class="row g-3 mb-4">
                <div class="col-md-3">
                    <div class="card ticket-card border-0 shadow-sm p-3 bg-white">
                        <div class="d-flex align-items-center justify-content-between">
                            <div>
                                <h6 class="text-muted fw-bold mb-1">Tổng khiếu nại</h6>
                                <h3 class="fw-extrabold mb-0 text-dark">${requestScope.KPI_TOTAL}</h3>
                            </div>
                            <div class="kpi-icon bg-light text-dark">
                                <i class="fas fa-list-ol fa-lg"></i>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="col-md-3">
                    <div class="card ticket-card border-0 shadow-sm p-3 bg-white">
                        <div class="d-flex align-items-center justify-content-between">
                            <div>
                                <h6 class="text-muted fw-bold mb-1">Chờ tiếp nhận</h6>
                                <h3 class="fw-extrabold mb-0 text-warning">${requestScope.KPI_PENDING}</h3>
                            </div>
                            <div class="kpi-icon bg-warning-subtle text-warning">
                                <i class="fas fa-clock fa-lg"></i>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="col-md-3">
                    <div class="card ticket-card border-0 shadow-sm p-3 bg-white">
                        <div class="d-flex align-items-center justify-content-between">
                            <div>
                                <h6 class="text-muted fw-bold mb-1">Đang xử lý</h6>
                                <h3 class="fw-extrabold mb-0 text-primary">${requestScope.KPI_PROCESSING}</h3>
                            </div>
                            <div class="kpi-icon bg-primary-subtle text-primary">
                                <i class="fas fa-spinner fa-spin fa-lg"></i>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="col-md-3">
                    <div class="card ticket-card border-0 shadow-sm p-3 bg-white">
                        <div class="d-flex align-items-center justify-content-between">
                            <div>
                                <h6 class="text-muted fw-bold mb-1">Đã giải quyết</h6>
                                <h3 class="fw-extrabold mb-0 text-success">${requestScope.KPI_RESOLVED}</h3>
                            </div>
                            <div class="kpi-icon bg-success-subtle text-success">
                                <i class="fas fa-check-circle fa-lg"></i>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Filter & Search Bar -->
            <div class="card border-0 shadow-sm rounded-4 p-4 mb-4">
                <form action="MainController" method="GET" class="row g-3 align-items-end">
                    <input type="hidden" name="action" value="ManageTickets" />
                    
                    <div class="col-md-4">
                        <label class="form-label fw-bold"><i class="fas fa-search me-1"></i> Tìm kiếm khiếu nại</label>
                        <input type="text" name="search" class="form-control" placeholder="Tên khách, mã đơn, nội dung..." value="${param.search}">
                    </div>
                    
                    <div class="col-md-3">
                        <label class="form-label fw-bold"><i class="fas fa-filter me-1"></i> Trạng thái</label>
                        <select name="statusFilter" class="form-select">
                            <option value="all" ${param.statusFilter eq 'all' ? 'selected' : ''}>Tất cả trạng thái</option>
                            <option value="PENDING" ${param.statusFilter eq 'PENDING' ? 'selected' : ''}>Chờ tiếp nhận (PENDING)</option>
                            <option value="PROCESSING" ${param.statusFilter eq 'PROCESSING' ? 'selected' : ''}>Đang xử lý (PROCESSING)</option>
                            <option value="FORWARDED" ${param.statusFilter eq 'FORWARDED' ? 'selected' : ''}>Đã chuyển tiếp (FORWARDED)</option>
                            <option value="RESOLVED" ${param.statusFilter eq 'RESOLVED' ? 'selected' : ''}>Đã giải quyết (RESOLVED)</option>
                        </select>
                    </div>

                    <div class="col-md-3">
                        <label class="form-label fw-bold"><i class="fas fa-tags me-1"></i> Loại khiếu nại</label>
                        <select name="categoryFilter" class="form-select">
                            <option value="all" ${param.categoryFilter eq 'all' ? 'selected' : ''}>Tất cả phân loại</option>
                            <option value="Chất lượng sản phẩm" ${param.categoryFilter eq 'Chất lượng sản phẩm' ? 'selected' : ''}>Chất lượng sản phẩm</option>
                            <option value="Giao thiếu hàng" ${param.categoryFilter eq 'Giao thiếu hàng' ? 'selected' : ''}>Giao thiếu hàng</option>
                            <option value="Hàng móp méo" ${param.categoryFilter eq 'Hàng móp méo' ? 'selected' : ''}>Hàng móp méo</option>
                            <option value="Khác" ${param.categoryFilter eq 'Khác' ? 'selected' : ''}>Khác</option>
                        </select>
                    </div>

                    <div class="col-md-2">
                        <button type="submit" class="btn btn-dark w-100 fw-bold"><i class="fas fa-filter me-1"></i> Lọc dữ liệu</button>
                    </div>
                </form>
            </div>

            <!-- Tickets Table -->
            <div class="card border-0 shadow-sm rounded-4 p-4">
                <c:choose>
                    <c:when test="${not empty requestScope.LIST_TICKETS}">
                        <div class="table-responsive">
                            <table class="table table-hover align-middle mb-0">
                                <thead class="table-dark">
                                    <tr>
                                        <th>Mã Ticket</th>
                                        <th>Khách hàng</th>
                                        <th>Đơn hàng</th>
                                        <th>Loại khiếu nại</th>
                                        <th>Tiêu đề khiếu nại</th>
                                        <th>Ngày gửi</th>
                                        <th>Trạng thái</th>
                                        <th>Người xử lý</th>
                                        <th class="text-center">Tác vụ</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <c:forEach var="ticket" items="${requestScope.LIST_TICKETS}">
                                        <tr>
                                            <td class="fw-bold">#${ticket.ticketId}</td>
                                            <td>
                                                <div class="fw-bold text-dark">${ticket.customerName}</div>
                                                <small class="text-muted">User ID: ${ticket.userId}</small>
                                            </td>
                                            <td>
                                                <c:choose>
                                                    <c:when test="${not empty ticket.orderId}">
                                                        <span class="badge bg-secondary">Đơn #${ticket.orderId}</span>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <span class="text-muted small">Không liên kết</span>
                                                    </c:otherwise>
                                                </c:choose>
                                            </td>
                                            <td>
                                                <c:choose>
                                                    <c:when test="${ticket.category eq 'Chất lượng sản phẩm'}">
                                                        <span class="badge-category bg-cat-quality">${ticket.category}</span>
                                                    </c:when>
                                                    <c:when test="${ticket.category eq 'Giao thiếu hàng'}">
                                                        <span class="badge-category bg-cat-missing">${ticket.category}</span>
                                                    </c:when>
                                                    <c:when test="${ticket.category eq 'Hàng móp méo'}">
                                                        <span class="badge-category bg-cat-damaged">${ticket.category}</span>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <span class="badge-category bg-cat-other">${ticket.category}</span>
                                                    </c:otherwise>
                                                </c:choose>
                                            </td>
                                            <td>
                                                <div class="fw-bold text-truncate" style="max-width: 250px;" title="${ticket.title}">${ticket.title}</div>
                                                <small class="text-muted text-truncate d-block" style="max-width: 250px;">${ticket.description}</small>
                                            </td>
                                            <td>
                                                <fmt:formatDate value="${ticket.createdAt}" pattern="dd/MM/yyyy HH:mm" />
                                            </td>
                                            <td>
                                                <c:choose>
                                                    <c:when test="${ticket.status eq 'PENDING'}">
                                                        <span class="badge bg-secondary"><i class="fas fa-clock me-1"></i>Chờ tiếp nhận</span>
                                                    </c:when>
                                                    <c:when test="${ticket.status eq 'PROCESSING'}">
                                                        <span class="badge bg-primary"><i class="fas fa-spinner fa-spin me-1"></i>Đang xử lý</span>
                                                    </c:when>
                                                    <c:when test="${ticket.status eq 'FORWARDED'}">
                                                        <span class="badge bg-warning text-dark"><i class="fas fa-share me-1"></i>Đã chuyển tiếp</span>
                                                    </c:when>
                                                    <c:when test="${ticket.status eq 'RESOLVED'}">
                                                        <span class="badge bg-success"><i class="fas fa-check-circle me-1"></i>Đã giải quyết</span>
                                                    </c:when>
                                                </c:choose>
                                            </td>
                                            <td>
                                                <c:choose>
                                                    <c:when test="${not empty ticket.staffName}">
                                                        <span class="fw-bold text-secondary"><i class="fas fa-user-tie me-1"></i>${ticket.staffName}</span>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <span class="text-danger small"><i class="fas fa-user-slash me-1"></i>Chưa phân công</span>
                                                    </c:otherwise>
                                                </c:choose>
                                            </td>
                                            <td class="text-center">
                                                <button type="button" class="btn btn-sm btn-primary shadow-sm" 
                                                        onclick="openProcessModal(this)"
                                                        data-id="${ticket.ticketId}"
                                                        data-customer="${ticket.customerName}"
                                                        data-order="${ticket.orderId != null ? ticket.orderId : ''}"
                                                        data-category="${ticket.category}"
                                                        data-title="${ticket.title}"
                                                        data-desc="${ticket.description}"
                                                        data-status="${ticket.status}"
                                                        data-feedback="${ticket.feedback != null ? ticket.feedback : ''}"
                                                        data-staff="${ticket.staffName != null ? ticket.staffName : ''}"
                                                        data-date="<fmt:formatDate value="${ticket.createdAt}" pattern="dd/MM/yyyy HH:mm" />">
                                                    <i class="fas fa-edit me-1"></i> Xử lý
                                                </button>
                                                
                                                <!-- Admins Only Delete Button -->
                                                <c:if test="${sessionScope.LOGIN_USER.roleID eq 'AD'}">
                                                    <c:url var="deleteLink" value="MainController">
                                                        <c:param name="action" value="TicketAction" />
                                                        <c:param name="subAction" value="delete" />
                                                        <c:param name="ticketId" value="${ticket.ticketId}" />
                                                        <c:param name="search" value="${param.search}" />
                                                        <c:param name="statusFilter" value="${param.statusFilter}" />
                                                        <c:param name="categoryFilter" value="${param.categoryFilter}" />
                                                    </c:url>
                                                    <a href="${deleteLink}" class="btn btn-sm btn-danger shadow-sm ms-1" 
                                                       onclick="return confirm('Bạn có chắc muốn xóa khiếu nại #${ticket.ticketId} này không?')">
                                                        <i class="fas fa-trash me-1"></i> Xóa
                                                    </a>
                                                </c:if>
                                            </td>
                                        </tr>
                                    </c:forEach>
                                </tbody>
                            </table>
                        </div>
                    </c:when>
                    <c:otherwise>
                        <div class="text-center py-5">
                            <i class="fas fa-headset fa-3x text-muted mb-3"></i>
                            <h5 class="text-muted">Không tìm thấy yêu cầu hỗ trợ hoặc khiếu nại nào!</h5>
                        </div>
                    </c:otherwise>
                </c:choose>
            </div>
        </div>

        <!-- Support Ticket Processing Modal -->
        <div class="modal fade" id="processTicketModal" tabindex="-1" aria-hidden="true">
            <div class="modal-dialog modal-dialog-centered modal-lg">
                <div class="modal-content border-0 shadow-lg" style="border-radius: 16px;">
                    <div class="modal-header text-white" style="background-color: #8b0000; border-top-left-radius: 16px; border-top-right-radius: 16px;">
                        <h5 class="modal-title fw-bold" id="modalTicketTitle">Xử lý yêu cầu khiếu nại</h5>
                        <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
                    </div>
                    <form action="MainController" method="POST">
                        <input type="hidden" name="action" value="TicketAction"/>
                        <input type="hidden" name="subAction" value="process"/>
                        <input type="hidden" name="ticketId" id="formTicketId"/>
                        
                        <!-- Keep search/filter parameters -->
                        <input type="hidden" name="search" value="${requestScope.search}"/>
                        <input type="hidden" name="statusFilter" value="${requestScope.statusFilter}"/>
                        <input type="hidden" name="categoryFilter" value="${requestScope.categoryFilter}"/>

                        <div class="modal-body p-4">
                            <div class="row g-3 mb-4">
                                <div class="col-md-6">
                                    <label class="form-label text-muted small fw-bold mb-1">Khách hàng yêu cầu</label>
                                    <div class="fw-bold fs-6 text-dark" id="displayCustomer"></div>
                                </div>
                                <div class="col-md-6">
                                    <label class="form-label text-muted small fw-bold mb-1">Liên kết đơn hàng</label>
                                    <div class="fw-bold fs-6 text-dark" id="displayOrder"></div>
                                </div>
                                <div class="col-md-6">
                                    <label class="form-label text-muted small fw-bold mb-1">Phân loại khiếu nại</label>
                                    <div id="displayCategory"></div>
                                </div>
                                <div class="col-md-6">
                                    <label class="form-label text-muted small fw-bold mb-1">Thời gian gửi</label>
                                    <div class="fw-bold fs-6 text-dark" id="displayDate"></div>
                                </div>
                            </div>

                            <div class="mb-4">
                                <label class="form-label fw-bold text-dark"><i class="fas fa-comment-alt me-1"></i> Nội dung khiếu nại</label>
                                <div class="card bg-light border-0 p-3 rounded-3">
                                    <div class="fw-bold mb-2" id="displayTitle"></div>
                                    <div class="text-secondary" id="displayDesc" style="white-space: pre-wrap;"></div>
                                </div>
                            </div>

                            <div class="row g-3 mb-4">
                                <div class="col-md-6">
                                    <label class="form-label fw-bold text-dark"><i class="fas fa-tasks me-1"></i> Cập nhật trạng thái</label>
                                    <select name="status" id="formStatus" class="form-select" onchange="toggleFeedbackRequirement()">
                                        <option value="PENDING">Chờ tiếp nhận (PENDING)</option>
                                        <option value="PROCESSING">Đang xử lý (PROCESSING)</option>
                                        <option value="FORWARDED">Chuyển tiếp (FORWARDED)</option>
                                        <option value="RESOLVED">Đã giải quyết (RESOLVED)</option>
                                    </select>
                                </div>
                                <div class="col-md-6">
                                    <label class="form-label text-muted small fw-bold mb-1">Nhân viên đang xử lý</label>
                                    <div class="fw-bold fs-6 text-secondary pt-2" id="displayStaff"></div>
                                </div>
                            </div>

                            <div class="mb-3">
                                <label class="form-label fw-bold text-dark" id="feedbackLabel"><i class="fas fa-reply me-1"></i> Phản hồi / Ghi chú xử lý</label>
                                <textarea name="feedback" id="formFeedback" class="form-control" rows="4" placeholder="Nhập câu trả lời cho khách hoặc lý do chuyển tiếp khiếu nại..."></textarea>
                                <span class="text-danger small" id="feedbackWarning" style="display:none;">Phản hồi hoặc Ghi chú là bắt buộc khi chọn Giải quyết hoặc Chuyển tiếp!</span>
                            </div>
                        </div>

                        <div class="modal-footer border-0 p-4 pt-0 justify-content-between">
                            <button type="button" class="btn btn-outline-secondary px-4 fw-bold rounded-pill" data-bs-dismiss="modal">Hủy bỏ</button>
                            <button type="submit" class="btn btn-danger px-4 fw-bold rounded-pill" onclick="return validateFeedback()"><i class="fas fa-save me-1"></i> Lưu thông tin</button>
                        </div>
                    </form>
                </div>
            </div>
        </div>

        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
        <script>
            let processModalObj;

            document.addEventListener("DOMContentLoaded", function() {
                processModalObj = new bootstrap.Modal(document.getElementById('processTicketModal'));
            });

            function openProcessModal(button) {
                const id = button.dataset.id;
                const customer = button.dataset.customer;
                const order = button.dataset.order;
                const category = button.dataset.category;
                const title = button.dataset.title;
                const desc = button.dataset.desc;
                const status = button.dataset.status;
                const feedback = button.dataset.feedback;
                const staff = button.dataset.staff;
                const date = button.dataset.date;

                document.getElementById('modalTicketTitle').innerHTML = 'Xử lý khiếu nại #' + id;
                document.getElementById('formTicketId').value = id;
                document.getElementById('displayCustomer').innerText = customer;
                document.getElementById('displayOrder').innerHTML = order ? '<span class="badge bg-secondary">Đơn #' + order + '</span>' : '<span class="text-muted small">Không liên kết</span>';
                document.getElementById('displayCategory').innerHTML = '<span class="badge-category bg-cat-other">' + category + '</span>';
                
                // Adjust category badge color inside modal
                const badgeEl = document.getElementById('displayCategory').querySelector('.badge-category');
                if (category === 'Chất lượng sản phẩm') {
                    badgeEl.className = 'badge-category bg-cat-quality';
                } else if (category === 'Giao thiếu hàng') {
                    badgeEl.className = 'badge-category bg-cat-missing';
                } else if (category === 'Hàng móp méo') {
                    badgeEl.className = 'badge-category bg-cat-damaged';
                }

                document.getElementById('displayDate').innerText = date;
                document.getElementById('displayTitle').innerText = title;
                document.getElementById('displayDesc').innerText = desc;
                
                document.getElementById('formStatus').value = status;
                document.getElementById('formFeedback').value = feedback;
                document.getElementById('displayStaff').innerHTML = staff ? '<i class="fas fa-user-tie me-1"></i>' + staff : '<span class="text-danger small"><i class="fas fa-user-slash me-1"></i>Chưa phân công</span>';

                toggleFeedbackRequirement();
                processModalObj.show();
            }

            function toggleFeedbackRequirement() {
                const status = document.getElementById('formStatus').value;
                const feedbackLabel = document.getElementById('feedbackLabel');
                const formFeedback = document.getElementById('formFeedback');

                if (status === 'RESOLVED' || status === 'FORWARDED') {
                    feedbackLabel.innerHTML = '<i class="fas fa-reply me-1"></i> Phản hồi / Ghi chú xử lý <span class="text-danger">*</span>';
                    formFeedback.placeholder = status === 'RESOLVED' ? "Bắt buộc: Nhập phương án xử lý đã thỏa thuận với khách hàng để đóng ticket..." : "Bắt buộc: Ghi rõ lý do chuyển tiếp và bộ phận tiếp nhận...";
                } else {
                    feedbackLabel.innerHTML = '<i class="fas fa-reply me-1"></i> Phản hồi / Ghi chú xử lý';
                    formFeedback.placeholder = "Nhập câu trả lời cho khách hoặc lý do chuyển tiếp khiếu nại...";
                }
                document.getElementById('feedbackWarning').style.display = 'none';
            }

            function validateFeedback() {
                const status = document.getElementById('formStatus').value;
                const feedback = document.getElementById('formFeedback').value.trim();
                if ((status === 'RESOLVED' || status === 'FORWARDED') && feedback === '') {
                    document.getElementById('feedbackWarning').style.display = 'block';
                    document.getElementById('formFeedback').focus();
                    return false;
                }
                return true;
            }
        </script>
    </body>
</html>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn"%>
<!DOCTYPE html>
<html>
    <head>
        <title>Quản lý nội dung (CMS) - NutriOverflow</title>
        <jsp:include page="includes/header.jsp" />
        <style>
            /* KPI summary cards styling */
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
            .bg-pending-light { background-color: #fffbeb; color: #d97706; }
            .bg-approved-light { background-color: #f0fdf4; color: #16a34a; }
            .bg-rejected-light { background-color: #fef2f2; color: #dc2626; }
            .bg-total-light { background-color: #eff6ff; color: #2563eb; }

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

            /* Rules guidelines box */
            .rules-box {
                background: #fff8f8;
                border-left: 4px solid #dc2626;
                border-radius: 12px;
                padding: 1.25rem;
                box-shadow: 0 2px 10px rgba(220, 38, 38, 0.05);
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

            /* Badges */
            .badge-soft {
                padding: 0.4em 0.8em;
                border-radius: 8px;
                font-weight: 600;
                font-size: 0.76rem;
            }
            .badge-soft-pending { background-color: #fef3c7; color: #d97706; }
            .badge-soft-approved { background-color: #dcfce7; color: #15803d; }
            .badge-soft-rejected { background-color: #fee2e2; color: #b91c1c; }

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

            /* Scroll bar style for content pre-viewing */
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
        </style>
    </head>
    <body class="bg-light">
        <c:set var="activeTab" value="Articles" scope="request" />
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
            <c:set var="totalCount" value="${fn:length(requestScope.LIST_ARTICLES)}" />
            <c:set var="pendingCount" value="0" />
            <c:set var="publishedCount" value="0" />
            <c:forEach var="art" items="${requestScope.LIST_ARTICLES}">
                <c:if test="${art.status == 'PENDING'}">
                    <c:set var="pendingCount" value="${pendingCount + 1}" />
                </c:if>
                <c:if test="${art.published}">
                    <c:set var="publishedCount" value="${publishedCount + 1}" />
                </c:if>
            </c:forEach>

            <div class="row g-4 mb-4">
                <div class="col-md-4">
                    <div class="card kpi-card shadow-sm p-4 d-flex flex-row align-items-center justify-content-between">
                        <div>
                            <span class="text-muted small fw-bold text-uppercase d-block mb-1">Tổng số bài viết</span>
                            <h2 class="fw-bold text-dark m-0">${totalCount} <span class="fs-5 text-muted fw-normal">bài đăng</span></h2>
                        </div>
                        <div class="kpi-icon-wrapper bg-total-light">
                            <i class="fas fa-file-alt"></i>
                        </div>
                    </div>
                </div>

                <div class="col-md-4">
                    <div class="card kpi-card shadow-sm p-4 d-flex flex-row align-items-center justify-content-between">
                        <div>
                            <span class="text-muted small fw-bold text-uppercase d-block mb-1">Đang chờ kiểm duyệt</span>
                            <h2 class="fw-bold text-warning m-0">${pendingCount} <span class="fs-5 text-muted fw-normal">yêu cầu</span></h2>
                        </div>
                        <div class="kpi-icon-wrapper bg-pending-light">
                            <i class="fas fa-clock"></i>
                        </div>
                    </div>
                </div>

                <div class="col-md-4">
                    <div class="card kpi-card shadow-sm p-4 d-flex flex-row align-items-center justify-content-between">
                        <div>
                            <span class="text-muted small fw-bold text-uppercase d-block mb-1">Đã xuất bản (Live)</span>
                            <h2 class="fw-bold text-success m-0">${publishedCount} <span class="fs-5 text-muted fw-normal">bài viết</span></h2>
                        </div>
                        <div class="kpi-icon-wrapper bg-approved-light">
                            <i class="fas fa-globe"></i>
                        </div>
                    </div>
                </div>
            </div>

            <!-- 2. TWO-COLUMN LAYOUT -->
            <div class="row g-4">
                
                <!-- LEFT COLUMN: Rules & Guidelines Sidebar -->
                <div class="col-lg-3">
                    <div class="card dashboard-card p-4 mb-4 rules-box">
                        <h5 class="fw-bold text-danger mb-3">
                            <i class="fas fa-gavel me-2"></i>Quy định Pháp lý & Kiểm duyệt CMS
                        </h5>
                        <hr class="text-danger opacity-25">
                        
                        <p class="small text-secondary mb-3">
                            <strong>Luật Quảng cáo TPCN số 16/2012/QH13:</strong> Biên tập viên và quản trị viên phải tuyệt đối tuân thủ các quy tắc sau khi duyệt hoặc xuất bản nội dung:
                        </p>

                        <div class="mb-3">
                            <h6 class="fw-bold text-dark mb-1 small"><i class="fas fa-ban text-danger me-1"></i> 1. Cấm tuyệt đối:</h6>
                            <p class="text-muted small mb-0">Không dùng các từ ngữ khẳng định công dụng tuyệt đối hoặc gây hiểu nhầm sản phẩm là thuốc chữa bệnh.</p>
                            <span class="badge bg-danger-subtle text-danger font-monospace text-tiny mt-1">"đặc trị", "trị dứt điểm", "chữa khỏi"</span>
                        </div>

                        <div class="mb-3">
                            <h6 class="fw-bold text-dark mb-1 small"><i class="fas fa-check-circle text-success me-1"></i> 2. Yêu cầu bắt buộc:</h6>
                            <p class="text-muted small mb-0">Mô tả đúng công dụng đã được cấp phép đăng ký của sản phẩm sức khỏe.</p>
                        </div>

                        <div class="mb-3">
                            <h6 class="fw-bold text-dark mb-1 small"><i class="fas fa-info-circle text-info me-1"></i> 3. Cảnh cáo hệ thống:</h6>
                            <p class="text-muted small mb-0">Hệ thống của chúng tôi tự động kiểm quét từ ngữ phóng đại trước khi cập nhật dữ liệu.</p>
                        </div>
                    </div>
                </div>

                <!-- RIGHT COLUMN: Detailed list of Articles with filter forms -->
                <div class="col-lg-9">
                    <div class="card dashboard-card p-4">
                        <div class="card-header-custom d-flex flex-wrap align-items-center justify-content-between gap-3">
                            <h5 class="fw-bold text-dark m-0"><i class="fas fa-newspaper me-2 text-danger"></i>Danh mục bài viết & Cẩm nang Y khoa</h5>
                            <button type="button" class="btn btn-success btn-sm fw-bold px-3 py-2 rounded-pill shadow-sm" onclick="openAddArticleModal()">
                                <i class="fas fa-plus-circle me-1"></i>Viết bài mới
                            </button>
                        </div>

                        <!-- SEARCH & FILTERS -->
                        <form action="MainController" method="GET" class="row g-3 mb-4">
                            <input type="hidden" name="action" value="ManageArticles" />
                            <div class="col-md-5">
                                <div class="input-group">
                                    <span class="input-group-text bg-white border-end-0 text-muted"><i class="fas fa-search"></i></span>
                                    <input type="text" name="search" class="form-control border-start-0" placeholder="Tìm kiếm theo tiêu đề bài viết..." value="${param.search}" />
                                </div>
                            </div>
                            <div class="col-md-3">
                                <select name="statusFilter" class="form-select">
                                    <option value="all" ${param.statusFilter == 'all' ? 'selected' : ''}>-- Trạng thái duyệt --</option>
                                    <option value="PENDING" ${param.statusFilter == 'PENDING' ? 'selected' : ''}>Chờ duyệt (PENDING)</option>
                                    <option value="APPROVED" ${param.statusFilter == 'APPROVED' ? 'selected' : ''}>Đã duyệt (APPROVED)</option>
                                    <option value="REJECTED" ${param.statusFilter == 'REJECTED' ? 'selected' : ''}>Bị từ chối (REJECTED)</option>
                                </select>
                            </div>
                            <div class="col-md-3">
                                <select name="publishFilter" class="form-select">
                                    <option value="all" ${param.publishFilter == 'all' ? 'selected' : ''}>-- Trạng thái xuất bản --</option>
                                    <option value="published" ${param.publishFilter == 'published' ? 'selected' : ''}>Đã xuất bản (Live)</option>
                                    <option value="unpublished" ${param.publishFilter == 'unpublished' ? 'selected' : ''}>Chưa xuất bản (Ẩn)</option>
                                </select>
                            </div>
                            <div class="col-md-1">
                                <button type="submit" class="btn btn-dark w-100"><i class="fas fa-filter"></i></button>
                            </div>
                        </form>

                        <!-- ARTICLES LIST TABLE -->
                        <c:choose>
                            <c:when test="${not empty requestScope.LIST_ARTICLES}">
                                <div class="table-responsive">
                                    <table class="table custom-table align-middle mb-0">
                                        <thead>
                                            <tr>
                                                <th style="width: 50px;">STT</th>
                                                <th style="width: 80px;">Hình ảnh</th>
                                                <th>Bài viết</th>
                                                <th style="width: 140px;">Người viết</th>
                                                <th style="width: 130px;">Thời gian</th>
                                                <th style="width: 130px;" class="text-center">Duyệt</th>
                                                <th style="width: 120px;" class="text-center">Xuất bản</th>
                                                <th style="width: 150px;" class="text-center">Hành động</th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                            <c:forEach var="art" items="${requestScope.LIST_ARTICLES}" varStatus="counter">
                                                <tr>
                                                    <td>${counter.count}</td>
                                                    <td>
                                                        <c:choose>
                                                            <c:when test="${not empty art.imageUrl}">
                                                                <img src="${art.imageUrl}" class="rounded-3" style="width: 60px; height: 60px; object-fit: cover;" onerror="this.src='https://placehold.co/100x100?text=Health'" />
                                                            </c:when>
                                                            <c:otherwise>
                                                                <img src="https://placehold.co/100x100?text=Health" class="rounded-3" style="width: 60px; height: 60px; object-fit: cover;" />
                                                            </c:otherwise>
                                                        </c:choose>
                                                    </td>
                                                    <td>
                                                        <div class="fw-bold text-dark text-truncate" style="max-width: 280px;" title="<c:out value="${art.title}" />">
                                                            <c:out value="${art.title}" />
                                                        </div>
                                                        <div class="text-muted small text-truncate" style="max-width: 280px;" title="<c:out value="${art.summary}" />">
                                                            <c:out value="${art.summary}" />
                                                        </div>
                                                    </td>
                                                    <td>
                                                        <div class="fw-semibold text-secondary text-truncate" style="max-width: 120px;"><c:out value="${art.authorName}" /></div>
                                                        <small class="text-muted text-tiny">@<c:out value="${art.authorUsername}" /></small>
                                                    </td>
                                                    <td>
                                                        <small class="fw-semibold text-dark">
                                                            <fmt:formatDate value="${art.createdAt}" pattern="dd-MM-yyyy HH:mm" />
                                                        </small>
                                                    </td>
                                                    <td class="text-center">
                                                        <c:choose>
                                                            <c:when test="${art.status == 'APPROVED'}">
                                                                <span class="badge-soft badge-soft-approved"><i class="fas fa-check-circle me-1"></i>Đã duyệt</span>
                                                            </c:when>
                                                            <c:when test="${art.status == 'REJECTED'}">
                                                                <span class="badge-soft badge-soft-rejected"><i class="fas fa-times-circle me-1"></i>Từ chối</span>
                                                            </c:when>
                                                            <c:otherwise>
                                                                <span class="badge-soft badge-soft-pending"><i class="fas fa-hourglass-half me-1"></i>Chờ duyệt</span>
                                                            </c:otherwise>
                                                        </c:choose>
                                                    </td>
                                                    <td class="text-center">
                                                        <c:choose>
                                                            <c:when test="${art.published}">
                                                                <a href="MainController?action=ArticleAction&subAction=togglePublish&articleId=${art.id}&published=false" class="badge bg-success text-decoration-none px-2.5 py-1.5 rounded-pill shadow-sm" title="Gỡ xuất bản">
                                                                    <i class="fas fa-globe me-1"></i> Đang hiện
                                                                </a>
                                                            </c:when>
                                                            <c:otherwise>
                                                                <a href="MainController?action=ArticleAction&subAction=togglePublish&articleId=${art.id}&published=true" class="badge bg-secondary text-decoration-none px-2.5 py-1.5 rounded-pill" title="Xuất bản lên website">
                                                                    <i class="fas fa-eye-slash me-1"></i> Đang ẩn
                                                                </a>
                                                            </c:otherwise>
                                                        </c:choose>
                                                    </td>
                                                    <td class="text-center">
                                                        <div class="d-flex align-items-center justify-content-center gap-1">
                                                            <!-- Moderation approval/rejection actions (only visible or enabled when not in that state) -->
                                                            <c:if test="${art.status != 'APPROVED'}">
                                                                <a href="MainController?action=ArticleAction&subAction=approve&articleId=${art.id}" class="btn btn-sm btn-outline-success rounded-circle" style="width: 32px; height: 32px; padding:0; display:inline-flex; align-items:center; justify-content:center;" title="Duyệt bài viết">
                                                                    <i class="fas fa-check"></i>
                                                                </a>
                                                            </c:if>
                                                            <c:if test="${art.status != 'REJECTED'}">
                                                                <a href="MainController?action=ArticleAction&subAction=reject&articleId=${art.id}" class="btn btn-sm btn-outline-warning rounded-circle" style="width: 32px; height: 32px; padding:0; display:inline-flex; align-items:center; justify-content:center;" title="Từ chối bài viết" onclick="return confirm('Bạn có chắc chắn muốn từ chối bài viết này?')">
                                                                    <i class="fas fa-ban"></i>
                                                                </a>
                                                            </c:if>

                                                            <!-- Edit Button -->
                                                            <button type="button" class="btn btn-sm btn-outline-primary rounded-circle" style="width: 32px; height: 32px; padding:0; display:inline-flex; align-items:center; justify-content:center;"
                                                                    data-id="${art.id}"
                                                                    data-title="<c:out value="${art.title}" />"
                                                                    data-summary="<c:out value="${art.summary}" />"
                                                                    data-image="<c:out value="${art.imageUrl}" />"
                                                                    data-author="<c:out value="${art.authorName}" />"
                                                                    onclick="openEditArticleModal(this)"
                                                                    title="Chỉnh sửa nội dung">
                                                                <i class="fas fa-edit"></i>
                                                            </button>

                                                            <!-- Delete Button -->
                                                            <a href="MainController?action=ArticleAction&subAction=delete&articleId=${art.id}" class="btn btn-sm btn-outline-danger rounded-circle" style="width: 32px; height: 32px; padding:0; display:inline-flex; align-items:center; justify-content:center;" title="Xóa vĩnh viễn" onclick="return confirm('Bạn có chắc chắn muốn xóa bài viết này?')">
                                                                <i class="fas fa-trash"></i>
                                                            </a>
                                                        </div>
                                                    </td>
                                                </tr>
                                                
                                                <!-- HIDDEN CONTENT STORAGE FOR JS MODAL POPULATION -->
                                                <div id="article-content-${art.id}" style="display:none;"><c:out value="${art.content}" /></div>
                                            </c:forEach>
                                        </tbody>
                                    </table>
                                </div>
                            </c:when>
                            <c:otherwise>
                                <div class="text-center py-5">
                                    <i class="fas fa-newspaper fa-3x text-muted mb-3"></i>
                                    <h5 class="text-muted">Chưa có bài viết sức khỏe nào trong cơ sở dữ liệu!</h5>
                                    <p class="text-secondary small">Vui lòng click "Viết bài mới" để bắt đầu.</p>
                                </div>
                            </c:otherwise>
                        </c:choose>
                    </div>
                </div>
            </div>
        </div>

        <!-- ADD ARTICLE MODAL -->
        <div class="modal fade" id="addArticleModal" tabindex="-1" aria-labelledby="addArticleModalLabel" aria-hidden="true">
            <div class="modal-dialog modal-lg modal-dialog-centered">
                <div class="modal-content" style="border-radius: 16px;">
                    <div class="modal-header bg-success text-white border-0 py-3" style="border-top-left-radius: 16px; border-top-right-radius: 16px;">
                        <h5 class="modal-title fw-bold" id="addArticleModalLabel"><i class="fas fa-plus-circle me-2"></i>Tạo bài viết cẩm nang mới</h5>
                        <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
                    </div>
                    <form id="addArticleForm" action="MainController" method="POST" onsubmit="return validateArticleForm('add')">
                        <input type="hidden" name="action" value="ArticleAction" />
                        <input type="hidden" name="subAction" value="add" />

                        <div class="modal-body p-4 row g-3">
                            <!-- Compliance Warning Banner -->
                            <div class="col-12">
                                <div class="alert alert-warning border-start border-4 border-warning mb-0 py-2.5">
                                    <i class="fas fa-exclamation-triangle me-2"></i>
                                    <strong class="text-dark">Nhắc nhở Pháp lý:</strong> Nội dung không được thổi phồng tác dụng của Thực phẩm chức năng hoặc mô tả như thuốc điều trị bệnh.
                                </div>
                            </div>

                            <div class="col-12">
                                <label class="form-label fw-bold">Tiêu đề bài viết <span class="text-danger">*</span></label>
                                <input type="text" id="addTitle" name="title" class="form-control" required placeholder="Nhập tiêu đề bài viết sức khỏe..." onkeyup="checkTextCompliance(this, 'addTitleWarning')" />
                                <div id="addTitleWarning" class="text-danger small mt-1" style="display:none;"></div>
                            </div>

                            <div class="col-12">
                                <label class="form-label fw-bold">Tóm tắt ngắn <span class="text-danger">*</span></label>
                                <textarea id="addSummary" name="summary" class="form-control" rows="2" required placeholder="Nhập tóm tắt mô tả ngắn gọn về bài viết..." onkeyup="checkTextCompliance(this, 'addSummaryWarning')"></textarea>
                                <div id="addSummaryWarning" class="text-danger small mt-1" style="display:none;"></div>
                            </div>

                            <div class="col-12">
                                <label class="form-label fw-bold">Nội dung chi tiết bài viết <span class="text-danger">*</span></label>
                                <textarea id="addContent" name="content" class="form-control" rows="8" required placeholder="Viết nội dung bài viết chi tiết tại đây..." onkeyup="checkTextCompliance(this, 'addContentWarning')"></textarea>
                                <div id="addContentWarning" class="text-danger small mt-1" style="display:none;"></div>
                            </div>

                            <div class="col-md-6">
                                <label class="form-label fw-bold">Đường dẫn hình ảnh (Image URL)</label>
                                <input type="text" name="imageUrl" class="form-control" placeholder="https://example.com/image.jpg" />
                            </div>

                            <div class="col-md-6">
                                <label class="form-label fw-bold">Tên hiển thị tác giả (Để trống để lấy Tên Admin)</label>
                                <input type="text" name="authorName" class="form-control" placeholder="Bác sĩ / Biên tập viên..." value="${sessionScope.LOGIN_USER.fullName}" />
                            </div>
                        </div>
                        <div class="modal-footer border-0 p-4 pt-0 justify-content-between">
                            <button type="button" class="btn btn-outline-secondary px-4 fw-bold rounded-pill" data-bs-dismiss="modal">Hủy bỏ</button>
                            <button type="submit" class="btn btn-success px-4 fw-bold rounded-pill"><i class="fas fa-save me-1"></i> Lưu & Gửi duyệt</button>
                        </div>
                    </form>
                </div>
            </div>
        </div>

        <!-- EDIT ARTICLE MODAL -->
        <div class="modal fade" id="editArticleModal" tabindex="-1" aria-labelledby="editArticleModalLabel" aria-hidden="true">
            <div class="modal-dialog modal-lg modal-dialog-centered">
                <div class="modal-content" style="border-radius: 16px;">
                    <div class="modal-header bg-dark text-white border-0 py-3" style="border-top-left-radius: 16px; border-top-right-radius: 16px;">
                        <h5 class="modal-title fw-bold" id="editArticleModalLabel"><i class="fas fa-edit me-2"></i>Chỉnh sửa chi tiết bài viết</h5>
                        <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
                    </div>
                    <form id="editArticleForm" action="MainController" method="POST" onsubmit="return validateArticleForm('edit')">
                        <input type="hidden" name="action" value="ArticleAction" />
                        <input type="hidden" name="subAction" value="update" />
                        <input type="hidden" id="editArticleId" name="articleId" />

                        <div class="modal-body p-4 row g-3">
                            <!-- Compliance Warning Banner -->
                            <div class="col-12">
                                <div class="alert alert-warning border-start border-4 border-warning mb-0 py-2.5">
                                    <i class="fas fa-exclamation-triangle me-2"></i>
                                    <strong class="text-dark">Nhắc nhở Pháp lý:</strong> Nội dung không được thổi phồng tác dụng của Thực phẩm chức năng hoặc mô tả như thuốc điều trị bệnh.
                                </div>
                            </div>

                            <div class="col-12">
                                <label class="form-label fw-bold">Tiêu đề bài viết <span class="text-danger">*</span></label>
                                <input type="text" id="editTitle" name="title" class="form-control" required onkeyup="checkTextCompliance(this, 'editTitleWarning')" />
                                <div id="editTitleWarning" class="text-danger small mt-1" style="display:none;"></div>
                            </div>

                            <div class="col-12">
                                <label class="form-label fw-bold">Tóm tắt ngắn <span class="text-danger">*</span></label>
                                <textarea id="editSummary" name="summary" class="form-control" rows="2" required onkeyup="checkTextCompliance(this, 'editSummaryWarning')"></textarea>
                                <div id="editSummaryWarning" class="text-danger small mt-1" style="display:none;"></div>
                            </div>

                            <div class="col-12">
                                <label class="form-label fw-bold">Nội dung chi tiết bài viết <span class="text-danger">*</span></label>
                                <textarea id="editContent" name="content" class="form-control" rows="8" required onkeyup="checkTextCompliance(this, 'editContentWarning')"></textarea>
                                <div id="editContentWarning" class="text-danger small mt-1" style="display:none;"></div>
                            </div>

                            <div class="col-md-6">
                                <label class="form-label fw-bold">Đường dẫn hình ảnh (Image URL)</label>
                                <input type="text" id="editImageUrl" name="imageUrl" class="form-control" />
                            </div>

                            <div class="col-md-6">
                                <label class="form-label fw-bold">Tên hiển thị tác giả</label>
                                <input type="text" id="editAuthorName" name="authorName" class="form-control" required />
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
            let addArticleModalObj;
            let editArticleModalObj;

            // List of restricted/sensitive health claim words in Vietnam advertising regulation context
            const SENSITIVE_WORDS = ["đặc trị", "trị dứt điểm", "chữa khỏi", "thuốc chữa bệnh", "dứt điểm", "điều trị tận gốc", "chữa trị tận gốc", "cam kết khỏi"];

            document.addEventListener("DOMContentLoaded", function() {
                addArticleModalObj = new bootstrap.Modal(document.getElementById('addArticleModal'));
                editArticleModalObj = new bootstrap.Modal(document.getElementById('editArticleModal'));
            });

            function openAddArticleModal() {
                // Reset errors
                document.getElementById('addTitleWarning').style.display = 'none';
                document.getElementById('addSummaryWarning').style.display = 'none';
                document.getElementById('addContentWarning').style.display = 'none';
                document.getElementById('addArticleForm').reset();
                
                addArticleModalObj.show();
            }

            function openEditArticleModal(button) {
                let id = button.dataset.id;
                document.getElementById('editArticleId').value = id;
                document.getElementById('editTitle').value = button.dataset.title;
                document.getElementById('editSummary').value = button.dataset.summary;
                document.getElementById('editImageUrl').value = button.dataset.image;
                document.getElementById('editAuthorName').value = button.dataset.author;

                // Load content from hidden div safely
                let contentDiv = document.getElementById('article-content-' + id);
                document.getElementById('editContent').value = contentDiv ? contentDiv.textContent : "";

                // Reset warnings
                document.getElementById('editTitleWarning').style.display = 'none';
                document.getElementById('editSummaryWarning').style.display = 'none';
                document.getElementById('editContentWarning').style.display = 'none';

                // Initial scan
                checkTextCompliance(document.getElementById('editTitle'), 'editTitleWarning');
                checkTextCompliance(document.getElementById('editSummary'), 'editSummaryWarning');
                checkTextCompliance(document.getElementById('editContent'), 'editContentWarning');

                editArticleModalObj.show();
            }

            /**
             * Scans input text and shows compliance warning in UI
             */
            function checkTextCompliance(inputElement, warningElementId) {
                const text = inputElement.value.toLowerCase();
                const warningDiv = document.getElementById(warningElementId);
                let detected = [];

                for (let word of SENSITIVE_WORDS) {
                    if (text.includes(word)) {
                        detected.push('"' + word + '"');
                    }
                }

                if (detected.length > 0) {
                    warningDiv.innerHTML = '<i class="fas fa-exclamation-triangle"></i> Cảnh báo nhạy cảm quảng cáo y khoa: Nội dung chứa từ ngữ phóng đại công dụng: ' + detected.join(', ');
                    warningDiv.style.display = 'block';
                    return false;
                } else {
                    warningDiv.style.display = 'none';
                    return true;
                }
            }

            /**
             * Final warning dialog on submit if sensitive words exist
             */
            function validateArticleForm(type) {
                let titleInput = document.getElementById(type === 'add' ? 'addTitle' : 'editTitle');
                let summaryInput = document.getElementById(type === 'add' ? 'addSummary' : 'editSummary');
                let contentInput = document.getElementById(type === 'add' ? 'addContent' : 'editContent');

                let titleOk = checkTextCompliance(titleInput, type === 'add' ? 'addTitleWarning' : 'editTitleWarning');
                let summaryOk = checkTextCompliance(summaryInput, type === 'add' ? 'addSummaryWarning' : 'editSummaryWarning');
                let contentOk = checkTextCompliance(contentInput, type === 'add' ? 'addContentWarning' : 'editContentWarning');

                if (!titleOk || !summaryOk || !contentOk) {
                    return confirm("Cảnh báo: Bài viết chứa một số từ ngữ nhạy cảm y khoa hoặc quảng cáo quá công dụng (ví dụ: đặc trị, chữa khỏi, dứt điểm). Bạn có chắc chắn nội dung này vẫn tuân thủ quy định pháp luật và muốn lưu lại?");
                }
                return true;
            }
        </script>
    </body>
</html>

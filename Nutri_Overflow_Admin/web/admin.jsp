<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<!DOCTYPE html>
<html>
    <head>
        <title>Trang quản trị Admin - NutriOverflow</title>
        <jsp:include page="includes/header.jsp" />
        <style>
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
        <c:set var="activeTab" value="Users" scope="request" />
        <jsp:include page="includes/sidebar.jsp" />

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
            <h3 class="mb-4 fw-bold">
                <c:choose>
                    <c:when test="${requestScope.subRole eq 'STAFF'}">Quản lý nhân viên</c:when>
                    <c:otherwise>Quản lý người dùng</c:otherwise>
                </c:choose>
            </h3>
        
            <div class="row mb-4">
                <div class="col-md-6">
                    <form action="MainController" method="POST" class="d-flex shadow-sm rounded">
                        <input type="hidden" name="subRole" value="${requestScope.subRole}"/>
                        <input type="text" name="search" class="form-control me-2 border-0" value="${param.search}" placeholder="Tìm kiếm theo tên...">
                        <button class="btn btn-dark px-4" type="submit" name="action" value="Search"><i class="fas fa-search"></i> Tìm kiếm</button>
                    </form>
                </div>
                <div class="col-md-6 text-end">
                    <a href="createUser.jsp?search=${param.search}&subRole=${requestScope.subRole}" class="btn btn-success shadow-sm"><i class="fas fa-user-plus"></i> Tạo tài khoản mới</a>
                </div>
            </div>

            <c:if test="${not empty requestScope.ERROR}">
                <div class="alert alert-danger alert-dismissible fade show shadow-sm">
                    <i class="fas fa-exclamation-triangle"></i> ${requestScope.ERROR}
                    <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                </div>
            </c:if>
            <c:if test="${not empty sessionScope.SUCCESS_MESSAGE}">
                <div class="alert alert-success alert-dismissible fade show shadow-sm">
                    <i class="fas fa-check-circle me-2"></i> ${sessionScope.SUCCESS_MESSAGE}
                    <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                </div>
                <c:remove var="SUCCESS_MESSAGE" scope="session" />
            </c:if>
            <c:if test="${not empty sessionScope.ERROR_MESSAGE}">
                <div class="alert alert-danger alert-dismissible fade show shadow-sm">
                    <i class="fas fa-exclamation-triangle me-2"></i> ${sessionScope.ERROR_MESSAGE}
                    <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                </div>
                <c:remove var="ERROR_MESSAGE" scope="session" />
            </c:if>

            <div class="card border-0 shadow-sm rounded-4 p-4">
                <c:choose>
                    <c:when test="${not empty requestScope.LIST_USER}">
                        <div class="table-responsive">
                            <table class="table table-hover align-middle mb-0">
                                <thead class="table-dark">
                                    <tr>
                                        <th>STT</th>
                                        <th>Tên đăng nhập (ID)</th>
                                        <th>Họ và tên</th>
                                        <th>Vai trò</th>
                                        <th>Trạng thái</th>
                                        <th class="text-center">Hành động</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <c:forEach var="user" items="${requestScope.LIST_USER}" varStatus="counter">
                                        <form action="MainController" method="POST">
                                            <input type="hidden" name="subRole" value="${requestScope.subRole}"/>
                                            <tr>
                                                <td>${counter.count}</td>
                                                <td>
                                                    <input type="text" name="userID" class="form-control-plaintext fw-bold text-primary" value="${user.userID}" readonly>
                                                </td>
                                                <td>
                                                    <input type="text" name="fullName" class="form-control border-secondary" value="${user.fullName}" required>
                                                </td>
                                                <td>
                                                    <select name="roleID" class="form-select border-secondary">
                                                        <option value="US" ${user.roleID eq 'US' ? 'selected' : ''}>Khách hàng</option>
                                                        <option value="AD" ${user.roleID eq 'AD' ? 'selected' : ''}>Quản trị viên</option>
                                                        <option value="MAN" ${user.roleID eq 'MAN' ? 'selected' : ''}>Quản lý (Manager)</option>
                                                        <option value="KHO" ${user.roleID eq 'KHO' ? 'selected' : ''}>Nhân viên kho</option>
                                                        <option value="CSKH" ${user.roleID eq 'CSKH' ? 'selected' : ''}>Nhân viên CSKH</option>
                                                    </select>
                                                </td>
                                                <td>
                                                    <c:choose>
                                                        <c:when test="${user.active}">
                                                            <span class="badge bg-success"><i class="fas fa-check-circle me-1"></i>Hoạt động</span>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <span class="badge bg-danger"><i class="fas fa-ban me-1"></i>Bị khóa</span>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </td>
                                                <td class="text-center">
                                                    <input type="hidden" name="search" value="${param.search}"/>
                                                    <button type="submit" name="action" value="Update" class="btn btn-sm btn-primary shadow-sm"><i class="fas fa-save"></i> Cập nhật</button>
                                                    
                                                    <c:choose>
                                                        <c:when test="${user.active}">
                                                            <c:url var="banLink" value="MainController">
                                                                <c:param name="action" value="ToggleUserActive" />
                                                                <c:param name="userID" value="${user.userID}" />
                                                                <c:param name="active" value="false" />
                                                                <c:param name="search" value="${param.search}" />
                                                                <c:param name="subRole" value="${requestScope.subRole}" />
                                                            </c:url>
                                                            <a href="${banLink}" class="btn btn-sm btn-warning shadow-sm" onclick="return confirm('Bạn có chắc muốn khóa tài khoản [${user.userID}] vì bùng hàng?')"><i class="fas fa-ban"></i> Khóa</a>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <c:url var="unbanLink" value="MainController">
                                                                <c:param name="action" value="ToggleUserActive" />
                                                                <c:param name="userID" value="${user.userID}" />
                                                                <c:param name="active" value="true" />
                                                                <c:param name="search" value="${param.search}" />
                                                                <c:param name="subRole" value="${requestScope.subRole}" />
                                                            </c:url>
                                                            <a href="${unbanLink}" class="btn btn-sm btn-success shadow-sm" onclick="return confirm('Bạn có chắc muốn mở khóa tài khoản [${user.userID}]?')"><i class="fas fa-check"></i> Mở khóa</a>
                                                        </c:otherwise>
                                                    </c:choose>
                                                    
                                                    <c:url var="deleteLink" value="MainController">
                                                        <c:param name="action" value="Delete" />
                                                        <c:param name="userID" value="${user.userID}" />
                                                        <c:param name="search" value="${param.search}" />
                                                        <c:param name="subRole" value="${requestScope.subRole}" />
                                                    </c:url>
                                                    <a href="${deleteLink}" class="btn btn-sm btn-danger shadow-sm" onclick="return confirm('Bạn có chắc chắn muốn xóa tài khoản [${user.userID}]?')"><i class="fas fa-trash"></i> Xóa</a>
                                                </td>
                                            </tr>
                                        </form>
                                    </c:forEach>
                                </tbody>
                            </table>
                        </div>
                    </c:when>
                    <c:otherwise>
                        <div class="text-center py-4">
                            <i class="fas fa-users-slash fa-3x text-muted mb-3"></i>
                            <h5 class="text-muted">${requestScope.EMPTY_MESSAGE != null ? requestScope.EMPTY_MESSAGE : "Vui lòng nhập tên và nhấn Tìm kiếm để hiển thị danh sách người dùng."}</h5>
                        </div>
                    </c:otherwise>
                </c:choose>
            </div>
        </div>
        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    </body>
</html>
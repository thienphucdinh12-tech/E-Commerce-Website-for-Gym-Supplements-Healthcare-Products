<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <title>Tạo người dùng - NutriOverflow CPanel</title>
        <jsp:include page="includes/header.jsp" />
    </head>
    <body class="bg-light d-flex align-items-center" style="height: 100vh;">
        <div class="container">
            <div class="row justify-content-center">
                <div class="col-md-5">
                    <div class="card shadow-lg border-0 rounded-4 p-4">
                        <div class="text-center mb-4">
                            <h3 class="fw-bold text-success"><i class="fas fa-user-shield"></i> Thêm người dùng</h3>
                        </div>
                        
                        <form action="MainController" method="POST">
                            <div class="mb-3">
                                <label class="form-label fw-bold">Tên đăng nhập (ID)</label>
                                <input type="text" name="userID" class="form-control" value="${param.userID}" required placeholder="Ví dụ: staff01">
                                <span class="text-danger small fw-bold">${requestScope.USER_ERROR.userID}</span>
                            </div>
                            <div class="mb-3">
                                <label class="form-label fw-bold">Họ và tên</label>
                                <input type="text" name="fullName" class="form-control" value="${param.fullName}" required placeholder="Nhập họ và tên...">
                                <span class="text-danger small fw-bold">${requestScope.USER_ERROR.fullName}</span>
                            </div>
                            <div class="mb-3">
                                <label class="form-label fw-bold">Phân quyền</label>
                                <select name="roleID" class="form-select">
                                    <option value="US" ${param.roleID == 'US' ? 'selected' : ''}>Khách hàng (US)</option>
                                    <option value="AD" ${param.roleID == 'AD' ? 'selected' : ''}>Quản trị viên (AD)</option>
                                    <option value="MAN" ${param.roleID == 'MAN' ? 'selected' : ''}>Quản lý (Manager)</option>
                                    <option value="KHO" ${param.roleID == 'KHO' ? 'selected' : ''}>Nhân viên kho (KHO)</option>
                                    <option value="CSKH" ${param.roleID == 'CSKH' ? 'selected' : ''}>Nhân viên CSKH (CSKH)</option>
                                </select>
                            </div>
                            <div class="mb-3">
                                <label class="form-label fw-bold">Mật khẩu</label>
                                <input type="password" name="password" class="form-control" required>
                            </div>
                            <div class="mb-4">
                                <label class="form-label fw-bold">Xác nhận mật khẩu</label>
                                <input type="password" name="confirm" class="form-control" required>
                                <span class="text-danger small fw-bold">${requestScope.USER_ERROR.confirm}</span>
                            </div>
                            
                            <input type="hidden" name="search" value="${param.search}"/>
                            <input type="hidden" name="subRole" value="${param.subRole}"/>
                            <button type="submit" name="action" value="Create" class="btn btn-success w-100 fw-bold"><i class="fas fa-check"></i> Lưu tài khoản</button>
                        </form>
                        
                        <p class="text-danger mt-3 text-center fw-bold">${requestScope.USER_ERROR.error}</p>
                        
                        <div class="text-center mt-2">
                            <a href="MainController?action=Search&search=${param.search}&subRole=${param.subRole}" class="text-decoration-none text-muted"><i class="fas fa-arrow-left"></i> Quay lại danh sách</a>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </body>
</html>
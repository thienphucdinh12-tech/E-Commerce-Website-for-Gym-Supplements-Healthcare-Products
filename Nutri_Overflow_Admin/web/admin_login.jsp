<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <title>Đăng nhập Admin - Bảo mật</title>
        <jsp:include page="includes/header.jsp" />
        <style>
            body { background-color: #1a1a2e; } /* Security Dark Tone */
            .admin-card { background-color: #16213e; border: 1px solid #0f3460; }
        </style>
    </head>
    <body class="d-flex align-items-center" style="height: 100vh;">
        <div class="container">
            <div class="row justify-content-center">
                <div class="col-md-4">
                    <div class="card admin-card shadow-lg rounded-4 p-4 text-white">
                        <div class="text-center mb-4">
                            <i class="fas fa-user-shield fa-3x text-danger mb-2"></i>
                            <h3 class="fw-bold">Hệ thống Quản trị</h3>
                        </div>  
                        <form action="MainController" method="POST">
                            <div class="mb-3">
                                <label class="form-label text-secondary">Tài khoản Admin</label>
                                <input type="text" name="userID" class="form-control bg-dark text-white border-secondary" required>
                            </div>
                            <div class="mb-4">
                                <label class="form-label text-secondary">Mật khẩu</label>
                                <input type="password" name="password" class="form-control bg-dark text-white border-secondary" required>
                            </div>
                            <input type="hidden" name="loginType" value="ADMIN">
                            
                            <button type="submit" name="action" value="Login" class="btn btn-danger w-100 fw-bold">Đăng nhập CPanel</button>
                        </form>
                        <p class="text-warning mt-3 text-center small">${requestScope.ERROR_MESSAGE}</p>
                    </div>
                </div>
            </div>
        </div>
    </body>
</html>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<!DOCTYPE html>
<html lang="vi">
    <head>
        <title>Đăng nhập — NutriOverflow</title>
        <jsp:include page="includes/header.jsp" />
        <style>
            :root {
                --primary:       #00e676;
                --primary-dark:  #00c853;
                --primary-glow:  rgba(0, 230, 118, 0.18);
                --bg-dark:       #05080d;
                --bg-card:       #0d1117;
                --bg-input:      #111820;
                --border-color:  rgba(0, 230, 118, 0.18);
                --border-subtle: rgba(255,255,255,0.07);
                --text-main:     #f0f4f8;
                --text-muted:    rgba(255,255,255,0.5);
            }

            * { box-sizing: border-box; margin: 0; padding: 0; }

            body {
                font-family: 'Inter', sans-serif;
                background-color: var(--bg-dark);
                color: var(--text-main);
                min-height: 100vh;
                display: flex;
                align-items: center;
                justify-content: center;
                overflow-x: hidden;
                padding: 2rem 1rem;
                position: relative;
            }

            /* ── Ambient background ── */
            .bg-canvas {
                position: fixed;
                inset: 0;
                z-index: 0;
                overflow: hidden;
                pointer-events: none;
            }
            .bg-canvas::before {
                content: '';
                position: absolute;
                width: 700px; height: 700px;
                border-radius: 50%;
                background: radial-gradient(circle, rgba(0,230,118,0.07) 0%, transparent 70%);
                top: -200px; left: -200px;
                animation: driftA 18s ease-in-out infinite alternate;
            }
            .bg-canvas::after {
                content: '';
                position: absolute;
                width: 500px; height: 500px;
                border-radius: 50%;
                background: radial-gradient(circle, rgba(0,200,83,0.05) 0%, transparent 70%);
                bottom: -150px; right: -100px;
                animation: driftB 22s ease-in-out infinite alternate;
            }
            .grid-overlay {
                position: absolute;
                inset: 0;
                background-image:
                    linear-gradient(rgba(0,230,118,0.03) 1px, transparent 1px),
                    linear-gradient(90deg, rgba(0,230,118,0.03) 1px, transparent 1px);
                background-size: 50px 50px;
            }
            @keyframes driftA {
                0%   { transform: translate(0,0) scale(1); }
                100% { transform: translate(80px,60px) scale(1.1); }
            }
            @keyframes driftB {
                0%   { transform: translate(0,0) scale(1); }
                100% { transform: translate(-60px,-80px) scale(1.08); }
            }

            /* ── Wrapper ── */
            .auth-wrapper {
                position: relative;
                z-index: 1;
                width: 100%;
                max-width: 980px;
                display: flex;
                border-radius: 24px;
                overflow: hidden;
                border: 1px solid var(--border-subtle);
                box-shadow:
                    0 0 0 1px rgba(0,230,118,0.08),
                    0 30px 80px rgba(0,0,0,0.6),
                    0 0 60px rgba(0,230,118,0.04);
                animation: fadeUp 0.7s cubic-bezier(0.16,1,0.3,1) both;
            }
            @keyframes fadeUp {
                from { opacity:0; transform:translateY(28px); }
                to   { opacity:1; transform:translateY(0);    }
            }

            /* ── Left visual panel ── */
            .auth-visual {
                flex: 1;
                min-height: 560px;
                background:
                    linear-gradient(160deg, rgba(0,0,0,0.55) 0%, rgba(0,60,25,0.30) 60%, rgba(0,0,0,0.70) 100%),
                    url('https://images.unsplash.com/photo-1517838277536-f5f99be501cd?q=80&w=1470&auto=format&fit=crop');
                background-size: cover;
                background-position: center;
                display: flex;
                flex-direction: column;
                justify-content: flex-end;
                padding: 3rem;
                position: relative;
                overflow: hidden;
            }
            .auth-visual::after {
                content: '';
                position: absolute;
                inset: 0;
                background: linear-gradient(to top, rgba(5,8,13,0.85) 0%, transparent 65%);
            }
            .visual-content { position: relative; z-index: 2; }
            .visual-badge {
                display: inline-flex;
                align-items: center;
                gap: 6px;
                background: rgba(0,230,118,0.12);
                border: 1px solid rgba(0,230,118,0.35);
                color: var(--primary);
                font-size: 0.72rem;
                font-weight: 700;
                letter-spacing: 2px;
                text-transform: uppercase;
                border-radius: 50px;
                padding: 5px 14px;
                margin-bottom: 1rem;
            }
            .visual-content h2 {
                color: #fff;
                font-size: 2.1rem;
                font-weight: 800;
                line-height: 1.25;
                margin-bottom: 0.9rem;
            }
            .visual-content h2 span { color: var(--primary); }
            .visual-content p {
                color: rgba(255,255,255,0.65);
                font-size: 0.97rem;
                line-height: 1.6;
                max-width: 88%;
            }
            .visual-stats {
                display: flex;
                gap: 1.5rem;
                margin-top: 1.8rem;
            }
            .stat-item { text-align: left; }
            .stat-num {
                font-size: 1.5rem;
                font-weight: 800;
                color: var(--primary);
                line-height: 1;
            }
            .stat-lbl {
                font-size: 0.75rem;
                color: rgba(255,255,255,0.5);
                margin-top: 2px;
            }

            /* ── Right form panel ── */
            .auth-form-container {
                flex: 1;
                padding: 3.5rem 3rem;
                background: var(--bg-card);
                display: flex;
                flex-direction: column;
                justify-content: center;
            }

            /* Logo mark */
            .auth-logo {
                width: 52px; height: 52px;
                background: linear-gradient(135deg, var(--primary), var(--primary-dark));
                border-radius: 14px;
                display: flex; align-items: center; justify-content: center;
                font-size: 1.3rem;
                color: #000;
                margin-bottom: 1.6rem;
                box-shadow: 0 0 20px var(--primary-glow);
            }

            .auth-title {
                font-size: 1.8rem;
                font-weight: 800;
                color: var(--text-main);
                margin-bottom: 0.35rem;
                letter-spacing: -0.3px;
            }
            .auth-sub {
                font-size: 0.93rem;
                color: var(--text-muted);
                margin-bottom: 2.2rem;
            }

            /* ── Form elements ── */
            .form-group { margin-bottom: 1.2rem; }
            .form-label {
                display: block;
                font-size: 0.82rem;
                font-weight: 600;
                color: rgba(255,255,255,0.75);
                margin-bottom: 7px;
                letter-spacing: 0.3px;
            }

            .auth-input {
                width: 100%;
                background: var(--bg-input);
                border: 1px solid var(--border-subtle);
                color: var(--text-main);
                border-radius: 10px;
                padding: 0.78rem 1.1rem;
                font-size: 0.95rem;
                transition: border-color 0.25s, box-shadow 0.25s, background 0.25s;
                font-family: 'Inter', sans-serif;
            }
            .auth-input:focus {
                outline: none;
                border-color: var(--primary);
                background: rgba(0,230,118,0.04);
                box-shadow: 0 0 0 3px var(--primary-glow);
            }
            .auth-input::placeholder { color: rgba(255,255,255,0.25); }

            /* ── Primary button ── */
            .btn-auth {
                background: linear-gradient(135deg, var(--primary), var(--primary-dark));
                color: #000;
                border: none;
                border-radius: 10px;
                padding: 0.85rem;
                font-weight: 700;
                font-size: 1rem;
                width: 100%;
                cursor: pointer;
                transition: all 0.25s ease;
                box-shadow: 0 4px 18px var(--primary-glow);
                margin-top: 0.5rem;
                display: flex;
                align-items: center;
                justify-content: center;
                gap: 8px;
                letter-spacing: 0.2px;
            }
            .btn-auth:hover {
                transform: translateY(-2px);
                box-shadow: 0 8px 28px rgba(0,230,118,0.35);
                filter: brightness(1.06);
            }
            .btn-auth:active { transform: translateY(0); }

            /* ── Google button ── */
            .btn-google {
                display: flex;
                align-items: center;
                justify-content: center;
                gap: 10px;
                background: rgba(255,255,255,0.05);
                border: 1px solid var(--border-subtle);
                color: var(--text-main);
                border-radius: 10px;
                padding: 0.75rem;
                font-weight: 600;
                font-size: 0.93rem;
                text-decoration: none;
                transition: all 0.25s ease;
                cursor: pointer;
                width: 100%;
                margin-bottom: 1.5rem;
            }
            .btn-google:hover {
                background: rgba(255,255,255,0.09);
                border-color: rgba(255,255,255,0.18);
                color: var(--text-main);
                transform: translateY(-1px);
            }
            .btn-google img { width: 18px; height: 18px; }

            /* ── Divider ── */
            .divider {
                display: flex;
                align-items: center;
                text-align: center;
                margin: 1.5rem 0;
                color: var(--text-muted);
                font-size: 0.83rem;
                font-weight: 500;
                gap: 0.75rem;
            }
            .divider::before, .divider::after {
                content: '';
                flex: 1;
                border-bottom: 1px solid var(--border-subtle);
            }

            /* ── Links ── */
            .link-brand { color: var(--primary); font-weight: 600; text-decoration: none; transition: 0.2s; }
            .link-brand:hover { color: var(--primary-dark); text-decoration: underline; }

            .back-link {
                display: inline-flex;
                align-items: center;
                gap: 6px;
                color: var(--text-muted);
                text-decoration: none;
                font-size: 0.88rem;
                font-weight: 500;
                transition: color 0.2s;
                margin-top: 1.4rem;
                justify-content: center;
            }
            .back-link:hover { color: var(--primary); }

            /* ── Alerts ── */
            .error-msg {
                background: rgba(239,68,68,0.1);
                color: #f87171;
                border: 1px solid rgba(239,68,68,0.3);
                border-radius: 10px;
                padding: 10px 14px;
                font-size: 0.9rem;
                font-weight: 500;
                margin-top: 1rem;
                display: flex;
                align-items: center;
                gap: 8px;
                animation: shake 0.45s ease-in-out;
            }
            .success-msg {
                background: rgba(0,230,118,0.08);
                color: var(--primary);
                border: 1px solid rgba(0,230,118,0.25);
                border-radius: 10px;
                padding: 10px 14px;
                font-size: 0.9rem;
                font-weight: 500;
                margin-top: 1rem;
                display: flex;
                align-items: center;
                gap: 8px;
                animation: fadeIn 0.4s ease;
            }

            @keyframes shake {
                0%,100% { transform: translateX(0); }
                25%      { transform: translateX(-6px); }
                75%      { transform: translateX(6px); }
            }
            @keyframes fadeIn {
                from { opacity:0; transform:translateY(-8px); }
                to   { opacity:1; transform:translateY(0);   }
            }

            /* ── Responsive ── */
            @media (max-width: 860px) {
                .auth-wrapper { flex-direction: column; max-width: 440px; }
                .auth-visual  { display: none; }
                .auth-form-container { padding: 2.8rem 2rem; }
            }
        </style>
    </head>
    <body>
        <div class="bg-canvas"><div class="grid-overlay"></div></div>

        <div class="auth-wrapper">
            <!-- ── Visual panel ── -->
            <div class="auth-visual">
                <div class="visual-content">
                    <div class="visual-badge"><i class="fas fa-bolt"></i> NutriOverflow</div>
                    <h2>Tiếp sức cho<br>hành trình <span>thể hình</span></h2>
                    <p>Thực phẩm bổ sung chính hãng, chất lượng cao — đồng hành cùng bạn chinh phục mọi mục tiêu.</p>
                    <div class="visual-stats">
                        <div class="stat-item">
                            <div class="stat-num">500+</div>
                            <div class="stat-lbl">Sản phẩm</div>
                        </div>
                        <div class="stat-item">
                            <div class="stat-num">10K+</div>
                            <div class="stat-lbl">Khách hàng</div>
                        </div>
                        <div class="stat-item">
                            <div class="stat-num">100%</div>
                            <div class="stat-lbl">Chính hãng</div>
                        </div>
                    </div>
                </div>
            </div>

            <!-- ── Form panel ── -->
            <div class="auth-form-container">
                <div class="auth-logo"><i class="fas fa-dumbbell"></i></div>
                <h1 class="auth-title">Chào mừng trở lại</h1>
                <p class="auth-sub">Đăng nhập tài khoản để tiếp tục</p>

                <form action="dang-nhap" method="POST">
                    <input type="hidden" name="loginType" value="CUSTOMER">

                    <div class="form-group">
                        <label class="form-label">Tên đăng nhập</label>
                        <input type="text" name="userID" class="auth-input"
                               required placeholder="Nhập tên đăng nhập của bạn"
                               value="${param.userID}" autocomplete="username">
                    </div>

                    <div class="form-group">
                        <label class="form-label">Mật khẩu</label>
                        <input type="password" name="password" class="auth-input"
                               required placeholder="Nhập mật khẩu của bạn"
                               autocomplete="current-password">
                    </div>

                    <button type="submit" name="action" value="Login" class="btn-auth">
                        Đăng nhập <i class="fas fa-arrow-right"></i>
                    </button>
                </form>

                <c:if test="${not empty requestScope.ERROR_MESSAGE}">
                    <div class="error-msg">
                        <i class="fas fa-exclamation-circle"></i> ${requestScope.ERROR_MESSAGE}
                    </div>
                </c:if>
                <c:if test="${not empty requestScope.SUCCESS_MESSAGE}">
                    <div class="success-msg">
                        <i class="fas fa-check-circle"></i> ${requestScope.SUCCESS_MESSAGE}
                    </div>
                </c:if>

                <div class="divider">hoặc</div>

                <a href="LoginGoogleController" class="btn-google">
                    <img src="https://upload.wikimedia.org/wikipedia/commons/c/c1/Google_%22G%22_logo.svg" alt="Google Logo">
                    Đăng nhập bằng Google
                </a>

                <p style="text-align:center; color:var(--text-muted); font-size:0.93rem;">
                    Chưa có tài khoản? <a href="dang-ky" class="link-brand">Tạo tài khoản mới</a>
                </p>

                <div style="text-align:center;">
                    <a href="cua-hang" class="back-link">
                        <i class="fas fa-arrow-left"></i> Quay lại cửa hàng
                    </a>
                </div>
            </div>
        </div>

        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    </body>
</html>
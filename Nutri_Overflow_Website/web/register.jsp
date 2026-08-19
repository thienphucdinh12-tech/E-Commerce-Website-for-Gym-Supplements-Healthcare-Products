<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<!DOCTYPE html>
<html lang="vi">
    <head>
        <title>Đăng ký — NutriOverflow</title>
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
                width: 600px; height: 600px;
                border-radius: 50%;
                background: radial-gradient(circle, rgba(0,230,118,0.07) 0%, transparent 70%);
                top: -150px; right: -150px;
                animation: driftA 20s ease-in-out infinite alternate;
            }
            .bg-canvas::after {
                content: '';
                position: absolute;
                width: 500px; height: 500px;
                border-radius: 50%;
                background: radial-gradient(circle, rgba(0,200,83,0.05) 0%, transparent 70%);
                bottom: -100px; left: -100px;
                animation: driftB 24s ease-in-out infinite alternate;
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
                100% { transform: translate(-70px,50px) scale(1.1); }
            }
            @keyframes driftB {
                0%   { transform: translate(0,0) scale(1); }
                100% { transform: translate(60px,-70px) scale(1.08); }
            }

            /* ── Wrapper ── */
            .auth-wrapper {
                position: relative;
                z-index: 1;
                width: 100%;
                max-width: 1060px;
                display: flex;
                flex-direction: row-reverse;
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

            /* ── Right visual panel ── */
            .auth-visual {
                flex: 1;
                min-height: 100%;
                background:
                    linear-gradient(160deg, rgba(0,0,0,0.55) 0%, rgba(0,50,20,0.35) 60%, rgba(0,0,0,0.72) 100%),
                    url('https://images.unsplash.com/photo-1541534741688-6078c6bfb5c5?q=80&w=1469&auto=format&fit=crop');
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
                background: linear-gradient(to top, rgba(5,8,13,0.88) 0%, transparent 60%);
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
                font-size: 2rem;
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
            .benefit-list {
                margin-top: 1.8rem;
                display: flex;
                flex-direction: column;
                gap: 0.65rem;
            }
            .benefit-item {
                display: flex;
                align-items: center;
                gap: 10px;
                font-size: 0.88rem;
                color: rgba(255,255,255,0.72);
            }
            .benefit-item i {
                color: var(--primary);
                font-size: 0.8rem;
                width: 16px;
                text-align: center;
            }

            /* ── Left form panel ── */
            .auth-form-container {
                flex: 1.1;
                padding: 3rem 3rem;
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
                margin-bottom: 1.4rem;
                box-shadow: 0 0 20px var(--primary-glow);
            }

            .auth-title {
                font-size: 1.75rem;
                font-weight: 800;
                color: var(--text-main);
                margin-bottom: 0.35rem;
                letter-spacing: -0.3px;
            }
            .auth-sub {
                font-size: 0.92rem;
                color: var(--text-muted);
                margin-bottom: 1.8rem;
            }

            /* ── Form grid ── */
            .form-grid {
                display: grid;
                grid-template-columns: 1fr 1fr;
                gap: 1rem;
            }

            .form-group { margin-bottom: 1.1rem; }
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
                padding: 0.75rem 1rem;
                font-size: 0.94rem;
                transition: border-color 0.25s, box-shadow 0.25s, background 0.25s;
                font-family: 'Inter', sans-serif;
            }
            .auth-input:focus {
                outline: none;
                border-color: var(--primary);
                background: rgba(0,230,118,0.04);
                box-shadow: 0 0 0 3px var(--primary-glow);
            }
            .auth-input::placeholder { color: rgba(255,255,255,0.22); }

            /* ── Resend button ── */
            .btn-resend {
                background: rgba(0,230,118,0.08);
                border: 1px solid rgba(0,230,118,0.25);
                color: var(--primary);
                padding: 0.75rem 1rem;
                border-radius: 10px;
                font-size: 0.88rem;
                font-weight: 600;
                cursor: pointer;
                white-space: nowrap;
                transition: all 0.25s ease;
                font-family: 'Inter', sans-serif;
            }
            .btn-resend:hover {
                background: rgba(0,230,118,0.15);
                border-color: rgba(0,230,118,0.45);
            }
            .btn-resend:disabled {
                opacity: 0.45;
                cursor: not-allowed;
            }

            /* ── OTP digits ── */
            .code-container {
                display: flex;
                gap: 8px;
                justify-content: center;
                margin-top: 5px;
            }
            .code-digit {
                flex: 1;
                max-width: 46px;
                height: 46px;
                background: var(--bg-input);
                border: 1px solid var(--border-subtle);
                color: var(--text-main);
                border-radius: 10px;
                font-size: 1.3rem;
                font-weight: 700;
                text-align: center;
                transition: all 0.25s ease;
                box-sizing: border-box;
                font-family: 'Inter', sans-serif;
            }
            .code-digit:focus {
                outline: none;
                border-color: var(--primary);
                background: rgba(0,230,118,0.05);
                box-shadow: 0 0 0 3px var(--primary-glow);
            }

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
                font-family: 'Inter', sans-serif;
            }
            .btn-auth:hover {
                transform: translateY(-2px);
                box-shadow: 0 8px 28px rgba(0,230,118,0.35);
                filter: brightness(1.06);
            }
            .btn-auth:active { transform: translateY(0); }

            /* ── Divider ── */
            .divider {
                display: flex;
                align-items: center;
                text-align: center;
                margin: 1.4rem 0;
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

            /* ── Alerts ── */
            .error-msg {
                background: rgba(239,68,68,0.1);
                color: #f87171;
                border: 1px solid rgba(239,68,68,0.3);
                border-radius: 10px;
                padding: 10px 14px;
                font-size: 0.88rem;
                font-weight: 500;
                margin-top: 0.8rem;
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
                font-size: 0.88rem;
                font-weight: 500;
                margin-top: 0.8rem;
                display: flex;
                align-items: center;
                gap: 8px;
                animation: fadeIn 0.4s ease;
            }
            #email-status { font-size: 0.83rem; display: block; margin-top: 5px; }

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
            @media (max-width: 900px) {
                .auth-wrapper { flex-direction: column; max-width: 440px; }
                .auth-visual  { display: none; }
                .auth-form-container { padding: 2.8rem 2rem; }
                .form-grid { grid-template-columns: 1fr; gap: 0; }
            }
            @media (max-width: 480px) {
                .code-digit { max-width: 38px; height: 40px; font-size: 1.1rem; }
                .code-container { gap: 6px; }
            }
        </style>
    </head>
    <body>
        <div class="bg-canvas"><div class="grid-overlay"></div></div>

        <div class="auth-wrapper">
            <!-- ── Visual panel ── -->
            <div class="auth-visual">
                <div class="visual-content">
                    <div class="visual-badge"><i class="fas fa-star"></i> Gia nhập Elite</div>
                    <h2>Bắt đầu hành trình<br><span>lột xác</span> của bạn</h2>
                    <p>Đăng ký ngay để khám phá hàng trăm sản phẩm chính hãng và ưu đãi dành riêng cho thành viên.</p>
                    <div class="benefit-list">
                        <div class="benefit-item"><i class="fas fa-check-circle"></i> Ưu đãi độc quyền cho thành viên mới</div>
                        <div class="benefit-item"><i class="fas fa-check-circle"></i> Theo dõi đơn hàng theo thời gian thực</div>
                        <div class="benefit-item"><i class="fas fa-check-circle"></i> Tích điểm đổi quà mỗi lần mua sắm</div>
                        <div class="benefit-item"><i class="fas fa-check-circle"></i> 100% hàng chính hãng, có tem xác thực</div>
                    </div>
                </div>
            </div>

            <!-- ── Form panel ── -->
            <div class="auth-form-container">
                <div class="auth-logo"><i class="fas fa-user-plus"></i></div>
                <h1 class="auth-title">Tạo tài khoản</h1>
                <p class="auth-sub">Tham gia NutriOverflow và bắt đầu hành trình của bạn</p>

                <form action="dang-ky" method="POST">
                    <div class="form-grid">
                        <div class="form-group">
                            <label class="form-label">Tên đăng nhập</label>
                            <input type="text" name="userID" class="auth-input"
                                   required placeholder="Ví dụ: gymer123"
                                   value="${param.userID}" autocomplete="username">
                        </div>
                        <div class="form-group">
                            <label class="form-label">Họ và tên</label>
                            <input type="text" name="fullName" class="auth-input"
                                   required placeholder="Họ và tên của bạn"
                                   value="${param.fullName}">
                        </div>
                    </div>

                    <div class="form-group">
                        <label class="form-label">Email</label>
                        <div style="display:flex; gap:10px; align-items:center;">
                            <input type="email" name="email" id="email" class="auth-input"
                                   required placeholder="Ví dụ: email@gmail.com"
                                   value="${param.email}" autocomplete="email" style="flex:1;">
                            <button type="button" id="btn-send-code" class="btn-resend">Gửi mã</button>
                        </div>
                        <span id="email-status"></span>
                    </div>

                    <div class="form-group">
                        <label class="form-label">Mã xác thực</label>
                        <div class="code-container">
                            <input type="text" class="code-digit" maxlength="1" pattern="[0-9]" inputmode="numeric" required autocomplete="off">
                            <input type="text" class="code-digit" maxlength="1" pattern="[0-9]" inputmode="numeric" required autocomplete="off">
                            <input type="text" class="code-digit" maxlength="1" pattern="[0-9]" inputmode="numeric" required autocomplete="off">
                            <input type="text" class="code-digit" maxlength="1" pattern="[0-9]" inputmode="numeric" required autocomplete="off">
                            <input type="text" class="code-digit" maxlength="1" pattern="[0-9]" inputmode="numeric" required autocomplete="off">
                            <input type="text" class="code-digit" maxlength="1" pattern="[0-9]" inputmode="numeric" required autocomplete="off">
                        </div>
                        <input type="hidden" name="code" id="verification-code-hidden" value="">
                    </div>

                    <div class="form-grid">
                        <div class="form-group">
                            <label class="form-label">Mật khẩu</label>
                            <input type="password" name="password" class="auth-input"
                                   required placeholder="Tạo mật khẩu mạnh"
                                   autocomplete="new-password">
                        </div>
                        <div class="form-group">
                            <label class="form-label">Xác nhận mật khẩu</label>
                            <input type="password" name="confirm" class="auth-input"
                                   required placeholder="Nhập lại mật khẩu"
                                   autocomplete="new-password">
                        </div>
                    </div>

                    <button type="submit" name="action" value="Register" class="btn-auth">
                        Đăng ký ngay <i class="fas fa-arrow-right"></i>
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

                <p style="text-align:center; color:var(--text-muted); font-size:0.93rem;">
                    Đã có tài khoản? <a href="dang-nhap" class="link-brand">Đăng nhập tại đây</a>
                </p>
            </div>
        </div>

        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>

        <script>
            document.addEventListener("DOMContentLoaded", function () {
                const btnSend    = document.getElementById("btn-send-code");
                const emailInput = document.getElementById("email");
                const statusSpan = document.getElementById("email-status");
                let cooldown = 0;
                let timerId  = null;

                btnSend.addEventListener("click", function () {
                    const email = emailInput.value.trim();
                    if (!email) {
                        statusSpan.style.color = "#f87171";
                        statusSpan.innerHTML = "<i class='fas fa-exclamation-circle'></i> Vui lòng nhập email trước!";
                        return;
                    }
                    const emailRegex = /^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$/;
                    if (!emailRegex.test(email)) {
                        statusSpan.style.color = "#f87171";
                        statusSpan.innerHTML = "<i class='fas fa-exclamation-circle'></i> Email không hợp lệ!";
                        return;
                    }

                    statusSpan.style.color = "rgba(255,255,255,0.5)";
                    statusSpan.innerHTML   = "<i class='fas fa-spinner fa-spin'></i> Đang gửi mã xác nhận...";
                    btnSend.disabled = true;

                    fetch("gui-ma-xac-thuc?email=" + encodeURIComponent(email))
                        .then(r => r.text())
                        .then(data => {
                            const res = data.trim();
                            if (res === "success") {
                                statusSpan.style.color = "#00e676";
                                statusSpan.innerHTML   = "<i class='fas fa-check-circle'></i> Mã xác thực đã được gửi về email của bạn!";
                                cooldown = 60;
                                btnSend.disabled = true;
                                btnSend.style.opacity = "0.45";
                                btnSend.style.cursor  = "not-allowed";
                                timerId = setInterval(function () {
                                    cooldown--;
                                    if (cooldown <= 0) {
                                        clearInterval(timerId);
                                        btnSend.disabled = false;
                                        btnSend.style.opacity = "1";
                                        btnSend.style.cursor  = "pointer";
                                        btnSend.innerText = "Gửi mã";
                                    } else {
                                        btnSend.innerText = "Gửi lại (" + cooldown + "s)";
                                    }
                                }, 1000);
                            } else if (res === "duplicate") {
                                statusSpan.style.color = "#f87171";
                                statusSpan.innerHTML   = "<i class='fas fa-exclamation-circle'></i> Email này đã được đăng ký!";
                                btnSend.disabled = false;
                            } else {
                                statusSpan.style.color = "#f87171";
                                statusSpan.innerHTML   = "<i class='fas fa-exclamation-circle'></i> Lỗi gửi mã: " + res;
                                btnSend.disabled = false;
                            }
                        })
                        .catch(() => {
                            statusSpan.style.color = "#f87171";
                            statusSpan.innerHTML   = "<i class='fas fa-exclamation-circle'></i> Lỗi kết nối hệ thống!";
                            btnSend.disabled = false;
                        });
                });

                // OTP digit logic
                const digits          = document.querySelectorAll(".code-digit");
                const hiddenCodeInput = document.getElementById("verification-code-hidden");

                function updateHiddenCode() {
                    let v = "";
                    digits.forEach(d => v += d.value);
                    hiddenCodeInput.value = v;
                }

                digits.forEach((input, index) => {
                    input.addEventListener("input", function (e) {
                        let val = e.target.value.replace(/[^0-9]/g, '');
                        e.target.value = val ? val.slice(-1) : '';
                        updateHiddenCode();
                        if (val && index < digits.length - 1) {
                            digits[index + 1].focus();
                            digits[index + 1].select();
                        }
                    });
                    input.addEventListener("keydown", function (e) {
                        if (e.key === "Backspace") {
                            if (input.value) { input.value = ""; updateHiddenCode(); }
                            else if (index > 0) { digits[index - 1].focus(); digits[index - 1].select(); digits[index - 1].value = ""; updateHiddenCode(); }
                            e.preventDefault();
                        } else if (e.key === "ArrowLeft"  && index > 0)               { digits[index - 1].focus(); digits[index - 1].select(); }
                          else if (e.key === "ArrowRight" && index < digits.length - 1) { digits[index + 1].focus(); digits[index + 1].select(); }
                    });
                    input.addEventListener("click", () => input.select());
                    input.addEventListener("paste", function (e) {
                        e.preventDefault();
                        const nums = (e.clipboardData || window.clipboardData).getData("text").replace(/[^0-9]/g,'').slice(0,6);
                        digits.forEach((d, i) => d.value = i < nums.length ? nums[i] : '');
                        updateHiddenCode();
                        const next = Math.min(nums.length, digits.length - 1);
                        if (digits[next]) { digits[next].focus(); digits[next].select(); }
                    });
                });
            });
        </script>
    </body>
</html>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn"%>
<%
    // Session guard
    if (session.getAttribute("LOGIN_USER") == null) {
        response.sendRedirect("dang-nhap");
        return;
    }
    // Flash messages
    String msgSuccess = (String) session.getAttribute("PROFILE_MSG_SUCCESS");
    String msgError   = (String) session.getAttribute("PROFILE_MSG_ERROR");
    session.removeAttribute("PROFILE_MSG_SUCCESS");
    session.removeAttribute("PROFILE_MSG_ERROR");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <title>Hồ sơ của tôi — NutriOverflow</title>
    <jsp:include page="includes/header.jsp" />
    <style>
        /* ── PAGE HERO ── */
        .page-hero {
            background: linear-gradient(135deg, #0a0a12 0%, #0d1f10 100%);
            padding: 2.5rem 0 2rem;
            margin-bottom: 0;
        }
        .page-hero h1 { font-size: 1.6rem; font-weight: 900; color: #fff; margin: 0; }
        .page-hero p  { color: rgba(255,255,255,0.5); font-size: 0.85rem; margin: 6px 0 0; }

        /* ── AVATAR CIRCLE ── */
        .avatar-circle {
            width: 88px; height: 88px;
            border-radius: 50%;
            background: linear-gradient(135deg, #00e676, #00c853);
            display: flex; align-items: center; justify-content: center;
            font-size: 2.2rem; font-weight: 900; color: #0a0a12;
            box-shadow: 0 0 0 4px rgba(0,230,118,0.25);
            flex-shrink: 0;
        }

        /* ── LAYOUT ── */
        .profile-layout {
            display: grid;
            grid-template-columns: 260px 1fr;
            gap: 1.5rem;
            max-width: 1060px;
            margin: 0 auto;
            padding: 2rem 1rem 4rem;
        }
        @media (max-width: 768px) {
            .profile-layout { grid-template-columns: 1fr; }
        }

        /* ── SIDEBAR ── */
        .profile-sidebar {
            background: #fff;
            border-radius: 20px;
            border: 1.5px solid var(--border);
            overflow: hidden;
            height: fit-content;
        }
        .sidebar-user {
            padding: 1.5rem;
            text-align: center;
            border-bottom: 1px solid var(--border);
            background: linear-gradient(135deg, #f9fffb, #fff);
        }
        .sidebar-user .username-tag {
            display: inline-block;
            background: rgba(0,230,118,0.12);
            color: var(--brand-dark);
            font-size: 0.72rem;
            font-weight: 700;
            border-radius: 50px;
            padding: 2px 10px;
            margin-top: 6px;
        }
        .sidebar-nav { padding: 0.5rem; }
        .sidebar-nav-item {
            display: flex; align-items: center; gap: 10px;
            padding: 0.7rem 1rem;
            border-radius: 12px;
            color: var(--txt-muted);
            font-size: 0.84rem;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.2s;
            border: none; background: transparent; width: 100%; text-align: left;
        }
        .sidebar-nav-item i { width: 18px; text-align: center; font-size: 0.9rem; }
        .sidebar-nav-item:hover { background: #f3f4f6; color: var(--txt); }
        .sidebar-nav-item.active {
            background: rgba(0,230,118,0.1);
            color: var(--brand-dark);
        }
        .sidebar-nav-item.active i { color: var(--brand-dark); }

        /* ── CONTENT AREA ── */
        .profile-content {
            background: #fff;
            border-radius: 20px;
            border: 1.5px solid var(--border);
            overflow: hidden;
        }
        .profile-tab { display: none; }
        .profile-tab.active { display: block; }

        .tab-header {
            padding: 1.5rem 2rem 1rem;
            border-bottom: 1px solid var(--border);
        }
        .tab-header h2 {
            font-size: 1.1rem; font-weight: 800; color: var(--txt); margin: 0;
            display: flex; align-items: center; gap: 8px;
        }
        .tab-header p { color: var(--txt-muted); font-size: 0.82rem; margin: 4px 0 0; }
        .tab-body { padding: 1.5rem 2rem 2rem; }

        /* ── FORM LABELS ── */
        .form-label {
            font-size: 0.8rem; font-weight: 700; color: var(--txt-muted);
            text-transform: uppercase; letter-spacing: 0.5px; margin-bottom: 5px;
        }

        /* ── SAVE BUTTON ROW ── */
        .save-row {
            display: flex; align-items: center; justify-content: flex-end; gap: 12px;
            padding: 1.2rem 2rem;
            border-top: 1px solid var(--border);
            background: #fafafa;
        }
        .btn-save {
            background: linear-gradient(135deg, var(--brand), var(--brand-dark));
            color: #0a0a12;
            border: none;
            font-weight: 700;
            font-size: 0.84rem;
            border-radius: 50px;
            padding: 0.55rem 1.8rem;
            transition: all 0.25s;
            box-shadow: 0 2px 14px rgba(0,230,118,0.3);
            display: inline-flex; align-items: center; gap: 7px;
        }
        .btn-save:hover {
            background: linear-gradient(135deg, var(--brand-dark), var(--brand-deep));
            color: #fff;
            transform: translateY(-1px);
            box-shadow: 0 5px 22px rgba(0,230,118,0.45);
        }

        /* ── BMI METER ── */
        .bmi-display {
            display: flex; align-items: center; gap: 1.5rem;
            background: #f9fafb;
            border-radius: 16px;
            padding: 1.2rem 1.5rem;
            border: 1.5px solid var(--border);
            margin-top: 1rem;
        }
        .bmi-score {
            font-size: 2.8rem;
            font-weight: 900;
            line-height: 1;
        }
        .bmi-score.underweight { color: #3b82f6; }
        .bmi-score.normal      { color: #10b981; }
        .bmi-score.overweight  { color: #f59e0b; }
        .bmi-score.obese       { color: #ef4444; }
        .bmi-label {
            font-size: 0.75rem; font-weight: 700; text-transform: uppercase;
            letter-spacing: 0.8px; margin-top: 2px;
        }
        .bmi-label.underweight { color: #3b82f6; }
        .bmi-label.normal      { color: #10b981; }
        .bmi-label.overweight  { color: #f59e0b; }
        .bmi-label.obese       { color: #ef4444; }
        .bmi-bar-wrap { flex: 1; }
        .bmi-scale {
            height: 8px; border-radius: 50px;
            background: linear-gradient(to right,
                #3b82f6 0%, #3b82f6 23%,
                #10b981 23%, #10b981 50%,
                #f59e0b 50%, #f59e0b 75%,
                #ef4444 75%, #ef4444 100%);
            position: relative; margin-bottom: 4px;
        }
        .bmi-pointer {
            position: absolute; top: -5px;
            width: 18px; height: 18px; border-radius: 50%;
            background: #fff; border: 3px solid #111;
            transform: translateX(-50%);
            box-shadow: 0 2px 8px rgba(0,0,0,0.25);
            transition: left 0.6s cubic-bezier(.34,1.56,.64,1);
        }
        .bmi-scale-labels {
            display: flex; justify-content: space-between;
            font-size: 0.65rem; color: var(--txt-muted); font-weight: 600;
        }

        /* ── HEALTH GOAL CARDS ── */
        .goal-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(170px, 1fr));
            gap: 0.75rem;
            margin-top: 0.5rem;
        }
        .goal-card {
            border: 2px solid var(--border);
            border-radius: 16px;
            padding: 1rem 0.8rem;
            text-align: center;
            cursor: pointer;
            transition: all 0.2s;
            background: #fff;
        }
        .goal-card:hover { border-color: var(--brand); background: #f9fffb; }
        .goal-card.selected {
            border-color: var(--brand);
            background: rgba(0,230,118,0.07);
            box-shadow: 0 0 0 3px rgba(0,230,118,0.15);
        }
        .goal-card input[type="radio"] { display: none; }
        .goal-icon {
            font-size: 1.8rem;
            margin-bottom: 6px;
            display: block;
        }
        .goal-title {
            font-size: 0.82rem; font-weight: 700; color: var(--txt);
            margin-bottom: 4px;
        }
        .goal-desc {
            font-size: 0.72rem; color: var(--txt-muted); line-height: 1.4;
        }

        /* ── GENDER PILLS ── */
        .gender-pills { display: flex; gap: 0.5rem; flex-wrap: wrap; }
        .gender-pill {
            position: relative;
        }
        .gender-pill input[type="radio"] { position: absolute; opacity: 0; width: 0; height: 0; }
        .gender-pill label {
            display: inline-flex; align-items: center; gap: 6px;
            border: 2px solid var(--border);
            border-radius: 50px;
            padding: 0.4rem 1.1rem;
            font-size: 0.84rem; font-weight: 600; color: var(--txt-muted);
            cursor: pointer; transition: all 0.2s;
        }
        .gender-pill input:checked + label {
            border-color: var(--brand);
            background: rgba(0,230,118,0.1);
            color: var(--brand-dark);
        }
        .gender-pill label:hover { border-color: var(--brand-dark); }

        /* ── ALERT FLASH ── */
        .flash-bar {
            padding: 0.85rem 2rem;
            font-size: 0.87rem; font-weight: 600;
            display: flex; align-items: center; gap: 10px;
        }
        .flash-bar.success { background: #ecfdf5; color: #065f46; border-bottom: 1px solid #a7f3d0; }
        .flash-bar.error   { background: #fef2f2; color: #991b1b; border-bottom: 1px solid #fecaca; }
    </style>
</head>
<body class="bg-light">
<jsp:include page="includes/navbar.jsp" />

<!-- PAGE HERO -->
<div class="page-hero">
    <div class="container">
        <h1><i class="fas fa-user-circle me-2" style="color:#6366f1;"></i>Hồ sơ của tôi</h1>
        <p>Quản lý thông tin cá nhân và địa chỉ nhận hàng của bạn</p>
    </div>
</div>

<!-- PROFILE LAYOUT -->
<div class="profile-layout">

    <!-- ── SIDEBAR ── -->
    <aside class="profile-sidebar">
        <div class="sidebar-user">
            <div class="avatar-circle mx-auto mb-3" id="avatarInitials">
                <c:choose>
                    <c:when test="${not empty PROFILE.fullName}">
                        <c:set var="firstChar" value="${fn:substring(PROFILE.fullName, 0, 1)}"/>
                        ${firstChar.toUpperCase()}
                    </c:when>
                    <c:otherwise>?</c:otherwise>
                </c:choose>
            </div>
            <div style="font-size:0.95rem; font-weight:800; color: var(--txt);">
                ${not empty PROFILE.fullName ? PROFILE.fullName : 'Tên của bạn'}
            </div>
            <span class="username-tag">@${PROFILE.userID}</span>
        </div>

        <nav class="sidebar-nav">
            <button class="sidebar-nav-item active" onclick="switchTab('personal', this)">
                <i class="fas fa-id-card"></i> Thông tin cá nhân
            </button>
            <button class="sidebar-nav-item" onclick="switchTab('address', this)">
                <i class="fas fa-map-marker-alt"></i> Địa chỉ nhận hàng
            </button>
        </nav>
    </aside>

    <!-- ── CONTENT ── -->
    <section class="profile-content">

        <!-- Flash messages -->
        <% if (msgSuccess != null) { %>
            <div class="flash-bar success">
                <i class="fas fa-check-circle"></i> <%=msgSuccess%>
            </div>
        <% } else if (msgError != null) { %>
            <div class="flash-bar error">
                <i class="fas fa-exclamation-circle"></i> <%=msgError%>
            </div>
        <% } %>

        <!-- All tabs share one form for save -->
        <form method="POST" action="ca-nhan" id="profileForm">

            <!-- ─── TAB 1: Personal Info ─── -->
            <div id="tab-personal" class="profile-tab active">
                <div class="tab-header">
                    <h2><i class="fas fa-id-card" style="color:#6366f1;"></i> Thông tin cá nhân</h2>
                    <p>Họ tên, ngày sinh và giới tính của bạn</p>
                </div>
                <div class="tab-body">
                    <div class="row g-3">
                        <div class="col-md-6">
                            <label class="form-label">Họ và tên</label>
                            <input type="text" class="form-control" name="fullName"
                                   value="${PROFILE.fullName}" placeholder="Nhập họ và tên của bạn">
                        </div>
                        <div class="col-md-6">
                            <label class="form-label">Số điện thoại</label>
                            <input type="text" class="form-control" name="phone"
                                   value="${PROFILE.phone}" placeholder="Nhập số điện thoại của bạn">
                        </div>
                        <div class="col-md-6">
                            <label class="form-label">Ngày sinh</label>
                            <input type="date" class="form-control" name="dateOfBirth"
                                   value="<fmt:formatDate value='${PROFILE.dateOfBirth}' pattern='yyyy-MM-dd'/>">
                        </div>
                        <div class="col-md-6">
                            <label class="form-label d-block">Giới tính</label>
                            <div class="gender-pills">
                                <div class="gender-pill">
                                    <input type="radio" id="genderMale" name="gender" value="Male"
                                           ${PROFILE.gender == 'Male' ? 'checked' : ''}>
                                    <label for="genderMale"><i class="fas fa-mars"></i> Nam</label>
                                </div>
                                <div class="gender-pill">
                                    <input type="radio" id="genderFemale" name="gender" value="Female"
                                           ${PROFILE.gender == 'Female' ? 'checked' : ''}>
                                    <label for="genderFemale"><i class="fas fa-venus"></i> Nữ</label>
                                </div>
                                <div class="gender-pill">
                                    <input type="radio" id="genderOther" name="gender" value="Other"
                                           ${PROFILE.gender == 'Other' ? 'checked' : ''}>
                                    <label for="genderOther"><i class="fas fa-genderless"></i> Khác</label>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="save-row">
                    <span style="font-size:0.8rem; color: var(--txt-muted);">Tất cả các thay đổi trên các tab sẽ được lưu lại</span>
                    <button type="submit" class="btn-save">
                        <i class="fas fa-save"></i> Lưu hồ sơ
                    </button>
                </div>
            </div>

            <!-- ─── TAB 2: Delivery Address ─── -->
            <div id="tab-address" class="profile-tab">
                <div class="tab-header">
                    <h2><i class="fas fa-map-marker-alt" style="color:#ef4444;"></i> Địa chỉ nhận hàng</h2>
                    <p>Địa chỉ giao hàng mặc định của bạn</p>
                </div>
                <div class="tab-body">
                    <input type="hidden" name="address" id="hiddenFullAddress" value="${PROFILE.address}">
                    
                    <div class="mb-3">
                        <label class="form-label" style="font-weight:600;"><i class="fas fa-map me-1" style="color:#ef4444;"></i> Tỉnh / Thành phố</label>
                        <select class="form-select" id="ghnProvince" onchange="loadDistricts()">
                            <option value="">Chọn Tỉnh/Thành</option>
                        </select>
                    </div>
                    
                    <div class="row g-2 mb-3">
                        <div class="col-6">
                            <label class="form-label" style="font-weight:600;">Quận / Huyện</label>
                            <select class="form-select" id="ghnDistrict" onchange="loadWards()" disabled>
                                <option value="">Chọn Quận/Huyện</option>
                            </select>
                        </div>
                        <div class="col-6">
                            <label class="form-label" style="font-weight:600;">Phường / Xã</label>
                            <select class="form-select" id="ghnWard" disabled>
                                <option value="">Chọn Phường/Xã</option>
                            </select>
                        </div>
                    </div>
                    
                    <div class="mb-3">
                        <label class="form-label" style="font-weight:600;"><i class="fas fa-home me-1" style="color:#ef4444;"></i> Địa chỉ cụ thể</label>
                        <input type="text" class="form-control" id="addressInput" 
                               placeholder="Số nhà, tên đường, tòa nhà...">
                    </div>
                    
                    <div class="mt-2" style="font-size:0.78rem; color: var(--txt-muted);">
                        <i class="fas fa-info-circle me-1"></i>
                        Địa chỉ này sẽ được tự động điền khi bạn đặt hàng.
                    </div>
                </div>
                <div class="save-row">
                    <button type="submit" class="btn-save">
                        <i class="fas fa-save"></i> Lưu hồ sơ
                    </button>
                </div>
            </div>

        </form>
    </section>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<script>
// ── Tab switching ──────────────────────────────────────────────────────────
function switchTab(tabId, btn) {
    document.querySelectorAll('.profile-tab').forEach(t => t.classList.remove('active'));
    document.querySelectorAll('.sidebar-nav-item').forEach(b => b.classList.remove('active'));
    document.getElementById('tab-' + tabId).classList.add('active');
    btn.classList.add('active');
}

// ── GHN Location API for Profile ───────────────────────────────────────────
function loadProvinces() {
    fetch('api/ghn-location?type=province&t=' + new Date().getTime())
        .then(res => res.json())
        .then(data => {
            let select = document.getElementById('ghnProvince');
            select.innerHTML = '<option value="">Chọn Tỉnh/Thành</option>';
            data.forEach(item => {
                select.innerHTML += '<option value="' + item.ProvinceID + '">' + item.ProvinceName + '</option>';
            });
        }).catch(err => console.error("Error loading provinces:", err));
}

function loadDistricts() {
    let provId = document.getElementById('ghnProvince').value;
    let distSelect = document.getElementById('ghnDistrict');
    let wardSelect = document.getElementById('ghnWard');
    
    distSelect.innerHTML = '<option value="">Chọn Quận/Huyện</option>';
    wardSelect.innerHTML = '<option value="">Chọn Phường/Xã</option>';
    distSelect.disabled = true;
    wardSelect.disabled = true;
    
    if (!provId) return;
    
    fetch('api/ghn-location?type=district&province_id=' + provId + '&t=' + new Date().getTime())
        .then(res => res.json())
        .then(data => {
            distSelect.innerHTML = '<option value="">Chọn Quận/Huyện</option>';
            distSelect.disabled = false;
            data.forEach(item => {
                distSelect.innerHTML += '<option value="' + item.DistrictID + '">' + item.DistrictName + '</option>';
            });
        }).catch(err => console.error("Error loading districts:", err));
}

function loadWards() {
    let distId = document.getElementById('ghnDistrict').value;
    let wardSelect = document.getElementById('ghnWard');
    
    wardSelect.innerHTML = '<option value="">Chọn Phường/Xã</option>';
    wardSelect.disabled = true;
    
    if (!distId) return;
    
    fetch('api/ghn-location?type=ward&district_id=' + distId + '&t=' + new Date().getTime())
        .then(res => res.json())
        .then(data => {
            wardSelect.innerHTML = '<option value="">Chọn Phường/Xã</option>';
            wardSelect.disabled = false;
            data.forEach(item => {
                wardSelect.innerHTML += '<option value="' + item.WardCode + '">' + item.WardName + '</option>';
            });
        }).catch(err => console.error("Error loading wards:", err));
}

function loadAndPreselectAddress() {
    var addrText = document.getElementById('hiddenFullAddress').value.trim();
    if (!addrText) {
        loadProvinces();
        return;
    }
    
    var parts = addrText.split(',').map(s => s.trim());
    if (parts.length < 3) {
        document.getElementById('addressInput').value = addrText;
        loadProvinces();
        return;
    }
    
    var provName = parts[parts.length - 1];
    var distName = parts[parts.length - 2];
    var wardName = parts[parts.length - 3];
    
    var streetParts = parts.slice(0, parts.length - 3);
    var streetVal = streetParts.join(', ');
    if (!streetVal) streetVal = parts[0];
    
    document.getElementById('addressInput').value = streetVal;
    
    function cleanName(name) {
        if (!name) return "";
        return name.toLowerCase()
            .replace(/tỉnh|thành phố|tp|quận|q\.|huyện|h\.|phường|p\.|xã|thị xã|thị trấn/g, "")
            .trim()
            .normalize("NFD").replace(/[\u0300-\u036f]/g, "")
            .replace(/đ/g, "d");
    }
    
    var cleanProvTarget = cleanName(provName);
    var cleanDistTarget = cleanName(distName);
    var cleanWardTarget = cleanName(wardName);
    
    fetch('api/ghn-location?type=province&t=' + new Date().getTime())
        .then(res => res.json())
        .then(provinces => {
            let provSelect = document.getElementById('ghnProvince');
            provSelect.innerHTML = '<option value="">Chọn Tỉnh/Thành</option>';
            provinces.forEach(p => {
                provSelect.innerHTML += '<option value="' + p.ProvinceID + '">' + p.ProvinceName + '</option>';
            });
            
            var matchedProv = provinces.find(p => cleanName(p.ProvinceName) === cleanProvTarget || p.ProvinceName.toLowerCase().includes(provName.toLowerCase()));
            if (!matchedProv) {
                matchedProv = provinces.find(p => cleanName(p.ProvinceName).includes(cleanProvTarget) || cleanProvTarget.includes(cleanName(p.ProvinceName)));
            }
            
            if (matchedProv) {
                provSelect.value = matchedProv.ProvinceID;
                
                return fetch('api/ghn-location?type=district&province_id=' + matchedProv.ProvinceID + '&t=' + new Date().getTime())
                    .then(res => res.json())
                    .then(districts => {
                        let distSelect = document.getElementById('ghnDistrict');
                        distSelect.innerHTML = '<option value="">Chọn Quận/Huyện</option>';
                        distSelect.disabled = false;
                        districts.forEach(d => {
                            distSelect.innerHTML += '<option value="' + d.DistrictID + '">' + d.DistrictName + '</option>';
                        });
                        
                        var matchedDist = districts.find(d => cleanName(d.DistrictName) === cleanDistTarget);
                        if (!matchedDist) {
                            matchedDist = districts.find(d => cleanName(d.DistrictName).includes(cleanDistTarget) || cleanDistTarget.includes(cleanName(d.DistrictName)));
                        }
                        
                        if (matchedDist) {
                            distSelect.value = matchedDist.DistrictID;
                            
                            return fetch('api/ghn-location?type=ward&district_id=' + matchedDist.DistrictID + '&t=' + new Date().getTime())
                                .then(res => res.json())
                                .then(wards => {
                                    let wardSelect = document.getElementById('ghnWard');
                                    wardSelect.innerHTML = '<option value="">Chọn Phường/Xã</option>';
                                    wardSelect.disabled = false;
                                    wards.forEach(w => {
                                        wardSelect.innerHTML += '<option value="' + w.WardCode + '">' + w.WardName + '</option>';
                                    });
                                    
                                    var matchedWard = wards.find(w => cleanName(w.WardName) === cleanWardTarget);
                                    if (!matchedWard) {
                                        matchedWard = wards.find(w => cleanName(w.WardName).includes(cleanWardTarget) || cleanWardTarget.includes(cleanName(w.WardName)));
                                    }
                                    
                                    if (matchedWard) {
                                        wardSelect.value = matchedWard.WardCode;
                                    }
                                });
                        }
                    });
            }
        })
        .catch(err => {
            console.error("Error loading location details:", err);
            loadProvinces();
        });
}

// Combine address components on form submit
document.getElementById('profileForm').addEventListener('submit', function(e) {
    var provSel = document.getElementById('ghnProvince');
    var distSel = document.getElementById('ghnDistrict');
    var wardSel = document.getElementById('ghnWard');
    var streetInput = document.getElementById('addressInput');
    
    if (provSel.value && distSel.value && wardSel.value && streetInput.value.trim()) {
        var provText = provSel.options[provSel.selectedIndex].text;
        var distText = distSel.options[distSel.selectedIndex].text;
        var wardText = wardSel.options[wardSel.selectedIndex].text;
        var streetText = streetInput.value.trim();
        
        var combined = streetText + ", " + wardText + ", " + distText + ", " + provText;
        document.getElementById('hiddenFullAddress').value = combined;
    } else {
        document.getElementById('hiddenFullAddress').value = "";
    }
});

// Load location details on init
(function() {
    loadAndPreselectAddress();
})();

// Open tab from hash if provided
(function() {
    var hash = window.location.hash.replace('#', '');
    var btn  = document.querySelector('.sidebar-nav-item[onclick*="' + hash + '"]');
    if (btn) btn.click();
})();
</script>

    <jsp:include page="includes/footer.jsp" />
</body>
</html>

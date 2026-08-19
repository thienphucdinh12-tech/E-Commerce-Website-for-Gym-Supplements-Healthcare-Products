<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@page import="java.sql.*"%>
<%@page import="utils.DBUtils"%>
<%@page import="java.util.*"%>
<%@page import="com.google.gson.Gson"%>
<%@page import="shopping.ProductDAO"%>
<%@page import="shopping.Product"%>
<%
    // Fetch products and custom foods from DB
    ProductDAO productDAO = new ProductDAO();
    List<Product> dbProductList = productDAO.getAllProduct();
    Map<String, Product> dbProductMap = new HashMap<>();
    if (dbProductList != null) {
        for (Product p : dbProductList) {
            dbProductMap.put(p.getId(), p);
        }
    }
    
    // Fallback: Make sure target supplement IDs are queried even if stock is 0
    String[] targetIds = {"1", "2", "6", "7", "8", "10", "17", "19", "24"};
    for (String id : targetIds) {
        if (!dbProductMap.containsKey(id)) {
            Product p = productDAO.getProductById(id);
            if (p != null) {
                dbProductMap.put(id, p);
            }
        }
    }

    // Fetch custom foods from local database
    List<Map<String, Object>> customFoods = new ArrayList<>();
    String sqlFoods = "SELECT food_name, calories, protein_g, carbs_g, fat_g, serving_size, description FROM Custom_Foods";
    try (Connection conn = DBUtils.getConnection();
         PreparedStatement ps = conn.prepareStatement(sqlFoods);
         ResultSet rs = ps.executeQuery()) {
        while (rs.next()) {
            Map<String, Object> food = new HashMap<>();
            food.put("name", rs.getString("food_name"));
            food.put("calories", rs.getInt("calories"));
            food.put("protein", rs.getDouble("protein_g"));
            food.put("carbs", rs.getDouble("carbs_g"));
            food.put("fat", rs.getDouble("fat_g"));
            food.put("servingSize", rs.getString("serving_size"));
            food.put("description", rs.getString("description"));
            customFoods.add(food);
        }
    } catch (Exception e) {
        e.printStackTrace();
    }
    
    Gson gson = new Gson();
    String dbProductsJson = gson.toJson(dbProductMap);
    String customFoodsJson = gson.toJson(customFoods);
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <title>NutriBoost AI &mdash; Cá nhân hóa dinh dưỡng | NutriOverflow</title>
    <jsp:include page="includes/header.jsp" />
    <script>
        window.onerror = function(message, source, lineno, colno, error) {
            alert("Lỗi JavaScript:\n" + message + "\ntại dòng: " + lineno + "\ncột: " + colno);
            return false;
        };
    </script>
    
    <style>
        /* Pulse glow animation for icons and active items */
        @keyframes nutriboost-pulse {
            0% { transform: scale(1); filter: drop-shadow(0 0 2px rgba(0, 230, 118, 0.4)); }
            100% { transform: scale(1.15); filter: drop-shadow(0 0 10px rgba(0, 230, 118, 0.8)); }
        }
        @keyframes fadeIn {
            from { opacity: 0; transform: translateY(15px); }
            to { opacity: 1; transform: translateY(0); }
        }

        body {
            background-color: #f0f2f5 !important;
            color: #111827 !important;
        }

        /* Standalone Page Container styling - Light Theme optimized */
        .nutriboost-main-card {
            background: #ffffff;
            border: 1.5px solid #e5e7eb;
            border-radius: 24px;
            color: #111827;
            box-shadow: 0 15px 45px rgba(0, 0, 0, 0.08), 0 0 30px rgba(0, 230, 118, 0.03);
            padding: 35px;
            margin-bottom: 50px;
            animation: fadeIn 0.6s cubic-bezier(0.16, 1, 0.3, 1) forwards;
        }

        .nutriboost-card-header {
            border-bottom: 1.5px solid #f3f4f6;
            padding-bottom: 22px;
            margin-bottom: 25px;
        }

        /* Form Section Headers */
        .nb-section-title {
            font-family: 'Outfit', sans-serif;
            font-size: 0.95rem;
            font-weight: 700;
            text-transform: uppercase;
            letter-spacing: 1.2px;
            color: #00c853; /* Brand primary */
            margin-bottom: 1.25rem;
            display: flex;
            align-items: center;
            gap: 8px;
        }

        /* Interactive Radio Cards for Gender Selection */
        .nb-gender-group, .nb-goal-group {
            display: flex;
            gap: 12px;
            width: 100%;
        }

        .nb-card-selector {
            flex: 1;
            background: #f9fafb;
            border: 1.5px solid #e5e7eb;
            border-radius: 12px;
            padding: 14px;
            text-align: center;
            cursor: pointer;
            transition: all 0.28s cubic-bezier(0.4, 0, 0.2, 1);
            position: relative;
            overflow: hidden;
            user-select: none;
            color: #374151;
        }

        .nb-card-selector input[type="radio"] {
            position: absolute;
            opacity: 0;
            width: 0; height: 0;
        }

        .nb-card-selector:hover {
            border-color: rgba(0, 230, 118, 0.4);
            background: rgba(0, 230, 118, 0.02);
            transform: translateY(-2px);
        }

        .nb-card-selector.active {
            border-color: var(--brand) !important;
            background: rgba(0, 230, 118, 0.08) !important;
            box-shadow: 0 0 15px rgba(0, 230, 118, 0.1);
            color: #009624;
            font-weight: 600;
        }

        .nb-card-selector i {
            font-size: 1.5rem;
            margin-bottom: 6px;
            display: block;
            transition: transform 0.25s ease;
        }
        
        .nb-card-selector.active i {
            transform: scale(1.15);
        }

        .nb-card-selector span {
            font-size: 0.85rem;
            font-weight: 600;
            display: block;
        }

        /* Input controls styling */
        .nb-input-group {
            position: relative;
            margin-bottom: 1.25rem;
        }

        .nb-input-label {
            font-size: 0.82rem;
            font-weight: 700;
            color: #374151;
            margin-bottom: 6px;
            display: block;
        }

        .nb-input-field {
            width: 100%;
            background: #ffffff !important;
            border: 1.5px solid #d1d5db !important;
            border-radius: 10px !important;
            color: #111827 !important;
            padding: 11px 14px !important;
            font-size: 0.9rem !important;
            transition: all 0.25s ease !important;
            outline: none !important;
        }

        .nb-input-field:focus {
            border-color: var(--brand) !important;
            background: #ffffff !important;
            box-shadow: 0 0 10px rgba(0, 230, 118, 0.15) !important;
        }

        /* Dropdown select dark theme styling */
        .nb-select {
            appearance: none;
            background-image: url("data:image/svg+xml,%3csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 16 16' fill='%23111827'%3e%3cpath fill-rule='evenodd' d='M1.646 4.646a.5.5 0 0 1 .708 0L8 10.293l5.646-5.647a.5.5 0 0 1 .708.708l-6 6a.5.5 0 0 1-.708 0l-6-6a.5.5 0 0 1 0-.708z'/%3e%3c/svg%3e");
            background-repeat: no-repeat;
            background-position: right 14px center;
            background-size: 12px auto;
            padding-right: 40px !important;
        }

        /* Body Fat Visual Image Picker Styles */
        .body-fat-card {
            background: #f9fafb;
            border: 1.5px solid #e5e7eb;
            border-radius: 12px;
            padding: 12px 10px;
            text-align: center;
            cursor: pointer;
            transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
            position: relative;
            overflow: hidden;
            height: 100%;
            color: #374151;
        }

        .body-fat-card:hover {
            border-color: rgba(0, 230, 118, 0.35);
            background: rgba(0, 230, 118, 0.02);
            transform: translateY(-3px);
        }

        .body-fat-card.active {
            border-color: var(--brand) !important;
            background: rgba(0, 230, 118, 0.08) !important;
            box-shadow: 0 0 16px rgba(0, 230, 118, 0.15);
            color: #009624;
        }

        .body-fat-card svg {
            width: 60px;
            height: 85px;
            margin-bottom: 6px;
            transition: all 0.3s ease;
            color: #4b5563;
            display: block;
            margin-left: auto;
            margin-right: auto;
        }

        .body-fat-card.active svg {
            color: var(--brand) !important;
            filter: drop-shadow(0 0 3px rgba(0, 230, 118, 0.4));
        }

        .body-fat-card span.bf-percentage {
            font-family: 'Outfit', sans-serif;
            font-size: 0.85rem;
            font-weight: 700;
            color: #111827;
            display: block;
        }

        .body-fat-card span.bf-desc {
            font-size: 0.7rem;
            color: #6b7280;
            display: block;
        }

        .body-fat-deselect-btn {
            font-size: 0.75rem;
            color: #00c853;
            background: transparent;
            border: none;
            padding: 0;
            cursor: pointer;
            text-decoration: underline;
            transition: color 0.2s ease;
            font-weight: 600;
        }

        .body-fat-deselect-btn:hover {
            color: var(--brand-deep);
        }

        /* Validation Feedback */
        .nb-error-feedback {
            font-size: 0.75rem;
            color: #ff5252;
            margin-top: 4px;
            display: none;
        }

        /* Buttons styling */
        .btn-nb-primary {
            background: linear-gradient(135deg, var(--brand) 0%, var(--brand-dark) 100%) !important;
            border: none !important;
            color: #ffffff !important;
            font-weight: 800 !important;
            font-family: 'Outfit', sans-serif;
            font-size: 1rem;
            letter-spacing: 0.5px;
            padding: 12px 30px !important;
            border-radius: 10px !important;
            box-shadow: 0 4px 15px rgba(0, 230, 118, 0.25) !important;
            transition: all 0.28s cubic-bezier(0.34, 1.56, 0.64, 1) !important;
        }

        .btn-nb-primary:hover {
            transform: translateY(-2px) scale(1.02);
            box-shadow: 0 6px 20px rgba(0, 230, 118, 0.4) !important;
        }

        .btn-nb-secondary {
            background: #ffffff !important;
            border: 1.5px solid #d1d5db !important;
            color: #374151 !important;
            font-weight: 600 !important;
            padding: 11px 24px !important;
            border-radius: 10px !important;
            transition: all 0.25s ease !important;
        }

        .btn-nb-secondary:hover {
            background: #f9fafb !important;
            border-color: #9ca3af !important;
        }

        /* ── SCREEN 2: REPORT PANEL STYLING ── */
        .report-fade-in {
            animation: fadeIn 0.45s cubic-bezier(0.16, 1, 0.3, 1) forwards;
        }

        .stat-circle-box {
            background: #f9fafb;
            border: 1.5px solid #e5e7eb;
            border-radius: 16px;
            padding: 22px;
            text-align: center;
            height: 100%;
            display: flex;
            flex-direction: column;
            justify-content: center;
            align-items: center;
            position: relative;
            overflow: hidden;
        }

        .stat-big-val {
            font-family: 'Outfit', sans-serif;
            font-size: 2.5rem;
            font-weight: 900;
            color: #00c853;
            line-height: 1.1;
            margin-bottom: 2px;
        }

        .stat-label {
            font-size: 0.78rem;
            font-weight: 700;
            text-transform: uppercase;
            color: #4b5563;
            letter-spacing: 0.8px;
        }

        .stat-subtext {
            font-size: 0.72rem;
            color: #6b7280;
            margin-top: 4px;
        }

        /* Macro Breakdown Progress bars */
        .macro-row {
            margin-bottom: 15px;
        }

        .macro-header {
            display: flex;
            justify-content: space-between;
            font-size: 0.82rem;
            font-weight: 600;
            margin-bottom: 6px;
            color: #374151;
        }

        .macro-label {
            display: flex;
            align-items: center;
            gap: 6px;
        }

        .macro-dot {
            width: 8px; height: 8px;
            border-radius: 50%;
            display: inline-block;
        }

        .dot-protein { background-color: #4f46e5; }
        .dot-carbs { background-color: #d97706; }
        .dot-fat { background-color: #dc2626; }

        .macro-bar-container {
            height: 6px;
            background: #e5e7eb;
            border-radius: 4px;
            overflow: hidden;
        }

        .macro-bar-fill {
            height: 100%;
            border-radius: 4px;
            width: 0;
            transition: width 0.8s cubic-bezier(0.16, 1, 0.3, 1);
        }

        .fill-protein { background: linear-gradient(90deg, #4f46e5, #6366f1); }
        .fill-carbs { background: linear-gradient(90deg, #d97706, #f59e0b); }
        .fill-fat { background: linear-gradient(90deg, #dc2626, #ef4444); }

        /* Personalized Diet Table */
        .diet-table {
            background: #ffffff;
            border: 1px solid #e5e7eb;
            border-radius: 12px;
            overflow: hidden;
            margin-top: 10px;
        }

        .diet-row {
            display: flex;
            border-bottom: 1px solid #f3f4f6;
            padding: 14px 18px;
            align-items: center;
            transition: background 0.2s ease;
        }
        
        .diet-row:last-child {
            border-bottom: none;
        }

        .diet-row:hover {
            background: #f9fafb;
        }

        .diet-time {
            flex: 0 0 110px;
            font-family: 'Outfit', sans-serif;
            font-weight: 700;
            font-size: 0.8rem;
            text-transform: uppercase;
            color: #00c853;
            display: flex;
            align-items: center;
            gap: 8px;
        }

        .diet-desc {
            flex: 1;
            font-size: 0.84rem;
            color: #374151;
            line-height: 1.5;
        }

        /* Supplement Cards Layout */
        .sup-card {
            background: #ffffff;
            border: 1.5px solid #e5e7eb;
            border-radius: 14px;
            padding: 15px 12px;
            text-align: center;
            height: 100%;
            display: flex;
            flex-direction: column;
            transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
            position: relative;
        }

        .sup-card:hover {
            transform: translateY(-4px);
            border-color: rgba(0, 230, 118, 0.3);
            box-shadow: 0 8px 24px rgba(0, 0, 0, 0.06);
        }

        .sup-badge {
            position: absolute;
            top: 8px; left: 8px;
            background: linear-gradient(135deg, #00e676 0%, #00c853 100%);
            color: #ffffff;
            font-family: 'Outfit', sans-serif;
            font-size: 0.65rem;
            font-weight: 800;
            padding: 3px 8px;
            border-radius: 50px;
            text-transform: uppercase;
        }

        .sup-img-wrap {
            width: 110px;
            height: 110px;
            margin: 10px auto 12px;
            border-radius: 10px;
            background: #f9fafb;
            border: 1px solid #e5e7eb;
            padding: 6px;
            display: flex;
            align-items: center;
            justify-content: center;
            overflow: hidden;
        }

        .sup-img {
            max-width: 100%;
            max-height: 100%;
            object-fit: contain;
            border-radius: 6px;
            transition: transform 0.3s ease;
        }

        .sup-card:hover .sup-img {
            transform: scale(1.08);
        }

        .sup-title {
            font-size: 0.82rem;
            font-weight: 700;
            color: #111827;
            line-height: 1.3;
            margin-bottom: 6px;
            min-height: 38px;
            display: -webkit-box;
            -webkit-line-clamp: 2;
            -webkit-box-orient: vertical;
            overflow: hidden;
        }

        .sup-desc {
            font-size: 0.72rem;
            color: #6b7280;
            margin-bottom: 12px;
            line-height: 1.35;
            flex-grow: 1;
            display: -webkit-box;
            -webkit-line-clamp: 2;
            -webkit-box-orient: vertical;
            overflow: hidden;
        }

        .sup-price-row {
            margin-bottom: 12px;
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
        }

        .sup-price {
            font-family: 'Outfit', sans-serif;
            font-size: 0.98rem;
            font-weight: 800;
            color: #00c853;
        }

        .sup-old-price {
            font-size: 0.72rem;
            color: #9ca3af;
            text-decoration: line-through;
            margin-bottom: 1px;
        }

        .btn-add-cart-ajax {
            background: rgba(0, 230, 118, 0.08) !important;
            border: 1px solid rgba(0, 230, 118, 0.3) !important;
            color: #009624 !important;
            font-size: 0.78rem !important;
            font-weight: 700 !important;
            padding: 8px 12px !important;
            border-radius: 8px !important;
            transition: all 0.25s ease !important;
            width: 100%;
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 6px;
        }

        .btn-add-cart-ajax:hover {
            background: var(--brand) !important;
            color: #ffffff !important;
            box-shadow: 0 4px 12px rgba(0, 230, 118, 0.2);
        }
        
        .btn-add-cart-ajax.loading {
            pointer-events: none;
            opacity: 0.6;
        }

        .btn-add-cart-ajax.added {
            background: #00c853 !important;
            border-color: #00c853 !important;
            color: #ffffff !important;
            box-shadow: none !important;
        }

        .health-warning-banner {
            background: rgba(245, 158, 11, 0.06);
            border: 1px solid rgba(245, 158, 11, 0.2);
            border-radius: 12px;
            padding: 12px 16px;
            font-size: 0.78rem;
            color: #b45309;
            margin-bottom: 1.5rem;
            display: flex;
            align-items: flex-start;
            gap: 10px;
            line-height: 1.45;
        }
        
        .bg-success-light {
            background-color: rgba(0, 230, 118, 0.08) !important;
        }
    </style>
</head>
<body>
    <jsp:include page="includes/navbar.jsp" />

    <div class="container py-5">
        <div class="row justify-content-center">
            <div class="col-lg-10">
                
                <!-- STANDALONE PAGE MAIN CARD -->
                <div class="nutriboost-main-card">
                    
                    <!-- Card Header -->
                    <div class="nutriboost-card-header text-center">
                        <h1 class="display-6 fw-bold text-dark mb-2" style="font-family:'Outfit',sans-serif; letter-spacing: 1px;">
                            NUTRI<span style="color:#00c853;">BOOST</span> AI
                        </h1>
                        <p class="text-muted mb-0" style="font-size: 0.9rem;">
                            Công cụ tính toán sức khỏe thông minh và lập thực đơn cá nhân hóa dựa trên AI
                        </p>
                    </div>

                    <!-- Card Body -->
                    <div class="nutriboost-card-body">
                        
                        <!-- ════ SCREEN 1: INPUT FORM ════ -->
                        <div id="nutriBoostFormScreen">
                            <form id="nutriBoostForm" novalidate>
                                
                                <div class="row g-4">
                                    <!-- Cột Trái: Sinh trắc học & Hành vi -->
                                    <div class="col-md-6">
                                        
                                        <!-- Nhóm Sinh trắc học -->
                                        <div class="nb-section-title">
                                            <i class="fas fa-user-circle"></i> Chỉ số sinh trắc học
                                        </div>

                                        <!-- Giới tính -->
                                        <div class="nb-input-group">
                                            <label class="nb-input-label">Giới tính <span class="text-brand">*</span></label>
                                            <div class="nb-gender-group">
                                                <div class="nb-card-selector active" onclick="setGender('male', this)">
                                                    <input type="radio" name="nbGender" value="male" checked>
                                                    <i class="fas fa-mars text-info"></i>
                                                    <span>Nam giới</span>
                                                </div>
                                                <div class="nb-card-selector" onclick="setGender('female', this)">
                                                    <input type="radio" name="nbGender" value="female">
                                                    <i class="fas fa-venus text-danger"></i>
                                                    <span>Nữ giới</span>
                                                </div>
                                            </div>
                                        </div>

                                        <!-- Hàng Tuổi, Chiều cao, Cân nặng -->
                                        <div class="row g-2">
                                            <div class="col-4">
                                                <div class="nb-input-group">
                                                    <label class="nb-input-label" for="nbAge">Tuổi <span class="text-brand">*</span></label>
                                                    <input type="number" id="nbAge" class="nb-input-field" placeholder="Ví dụ: 25" min="10" max="100" required>
                                                    <div class="nb-error-feedback" id="nbAgeError">Từ 10-100</div>
                                                </div>
                                            </div>
                                            <div class="col-4">
                                                <div class="nb-input-group">
                                                    <label class="nb-input-label" for="nbHeight">Cao (cm) <span class="text-brand">*</span></label>
                                                    <input type="number" id="nbHeight" class="nb-input-field" placeholder="cm" min="100" max="250" required>
                                                    <div class="nb-error-feedback" id="nbHeightError">100 - 250</div>
                                                </div>
                                            </div>
                                            <div class="col-4">
                                                <div class="nb-input-group">
                                                    <label class="nb-input-label" for="nbWeight">Nặng (kg) <span class="text-brand">*</span></label>
                                                    <input type="number" id="nbWeight" class="nb-input-field" placeholder="kg" min="30" max="250" required>
                                                    <div class="nb-error-feedback" id="nbWeightError">30 - 250</div>
                                                </div>
                                            </div>
                                        </div>

                                        <!-- Mức độ vận động -->
                                        <div class="nb-input-group">
                                            <label class="nb-input-label" for="nbActivity">Tần suất vận động hàng tuần <span class="text-brand">*</span></label>
                                            <select id="nbActivity" class="nb-input-field nb-select">
                                                <option value="1.2">Ít vận động (Công việc văn phòng, không tập thể dục)</option>
                                                <option value="1.375" selected>Vận động nhẹ (Luyện tập nhẹ nhàng 1-3 ngày/tuần)</option>
                                                <option value="1.55">Vận động vừa (Tập luyện tích cực 3-5 ngày/tuần)</option>
                                                <option value="1.725">Vận động nặng (Tập nặng hàng ngày, gym 6-7 ngày/tuần)</option>
                                            </select>
                                        </div>
                                        
                                        <!-- Mục tiêu cá nhân -->
                                        <div class="nb-input-group mb-0">
                                            <label class="nb-input-label">Mục tiêu cá nhân của bạn <span class="text-brand">*</span></label>
                                            <div class="nb-goal-group flex-column g-2">
                                                <div class="nb-card-selector text-start d-flex align-items-center gap-3 p-3 active" onclick="setGoal('fatloss', this)">
                                                    <input type="radio" name="nbGoal" value="fatloss" checked>
                                                    <i class="fas fa-fire text-danger" style="margin: 0; font-size:1.25rem;"></i>
                                                    <div>
                                                        <div style="font-size:0.82rem;font-weight:700;">Giảm mỡ / Cắt nét cơ thể</div>
                                                        <div style="font-size:0.7rem;color:#6b7280;font-weight:400;margin-top:1px;">Thâm hụt calo, bảo toàn cơ bắp</div>
                                                    </div>
                                                </div>
                                                <div class="nb-card-selector text-start d-flex align-items-center gap-3 p-3" onclick="setGoal('muscle', this)">
                                                    <input type="radio" name="nbGoal" value="muscle">
                                                    <i class="fas fa-dumbbell text-indigo" style="margin: 0; font-size:1.25rem; color:#6366f1;"></i>
                                                    <div>
                                                        <div style="font-size:0.82rem;font-weight:700;">Tăng cơ / Giữ cân nặng</div>
                                                        <div style="font-size:0.7rem;color:#6b7280;font-weight:400;margin-top:1px;">Tối ưu hóa tổng hợp cơ nạc</div>
                                                    </div>
                                                </div>
                                                <div class="nb-card-selector text-start d-flex align-items-center gap-3 p-3" onclick="setGoal('weightgain', this)">
                                                    <input type="radio" name="nbGoal" value="weightgain">
                                                    <i class="fas fa-chart-line text-success" style="margin: 0; font-size:1.25rem;"></i>
                                                    <div>
                                                        <div style="font-size:0.82rem;font-weight:700;">Tăng cân nhanh / Bulking</div>
                                                        <div style="font-size:0.7rem;color:#6b7280;font-weight:400;margin-top:1px;">Dư thừa calo dồi dào, phát triển khối lượng</div>
                                                    </div>
                                                </div>
                                            </div>
                                        </div>

                                    </div>

                                    <!-- Cột Phải: Visual Body Fat Picker -->
                                    <div class="col-md-6">
                                        <div class="nb-section-title justify-content-between">
                                            <span>
                                                <i class="fas fa-image"></i> Ước lượng % Body Fat
                                            </span>
                                            <button type="button" class="body-fat-deselect-btn" id="nbDeselectBf" style="display:none;" onclick="deselectBodyFat()">
                                                Bỏ chọn
                                            </button>
                                        </div>
                                        <div class="text-muted mb-3" style="font-size: 0.76rem; line-height:1.4;">
                                            Không bắt buộc. Nhấp chọn hình ảnh mô tả gần nhất với vóc dáng hiện tại của bạn để kích hoạt thuật toán **Katch-McArdle** chính xác hơn.
                                        </div>

                                        <input type="hidden" id="nbBodyFatVal" value="">

                                        <!-- Vóc dáng NAM (Hiện mặc định) -->
                                        <div id="nbBodyFatMaleContainer" class="row g-2">
                                            <div class="col-6">
                                                <div class="body-fat-card" onclick="selectBodyFat(11, this)">
                                                    <!-- SVG Men 10-12% -->
                                                    <svg viewBox="0 0 60 90" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                                                        <path d="M30 15c2.2 0 4-1.8 4-4s-1.8-4-4-4-4 1.8-4 4 1.8 4 4 4zM16 26c4-1 8-2 14-2s10 1 14 2c2 3 3 8 2 14-.8 4.8-3.5 14-6 24h-20c-2.5-10-5.2-19.2-6-24-1-6 0-11 2-14zM22 66h16M24 24v18M36 24v18M30 24v42" />
                                                    </svg>
                                                    <span class="bf-percentage">10% - 12%</span>
                                                    <span class="bf-desc">Khô mỡ, rõ cơ bụng</span>
                                                </div>
                                            </div>
                                            <div class="col-6">
                                                <div class="body-fat-card" onclick="selectBodyFat(16, this)">
                                                    <!-- SVG Men 15-18% -->
                                                    <svg viewBox="0 0 60 90" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                                                        <path d="M30 15c2.2 0 4-1.8 4-4s-1.8-4-4-4-4 1.8-4 4 1.8 4 4 4zM17 26c4-1 7-1.5 13-1.5s9 .5 13 1.5c2.2 3 2.8 8 1.8 14-.8 4.8-3 14-5.5 24h-18.6c-2.5-10-4.7-19.2-5.5-24-1-6-.2-11 1.8-14zM23 66h14M30 23.5v42.5" />
                                                    </svg>
                                                    <span class="bf-percentage">15% - 18%</span>
                                                    <span class="bf-desc">Thon gọn, fitness</span>
                                                </div>
                                            </div>
                                            <div class="col-6">
                                                <div class="body-fat-card" onclick="selectBodyFat(22, this)">
                                                    <!-- SVG Men 20-24% -->
                                                    <svg viewBox="0 0 60 90" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                                                        <path d="M30 15c2.2 0 4-1.8 4-4s-1.8-4-4-4-4 1.8-4 4 1.8 4 4 4zM18 26c3-.5 6-1 12-1s9 .5 12 1c2.2 3 2.5 8 1.8 14-.8 4.8-2.2 14-4.8 24h-18c-2.6-10-4-19.2-4.8-24-.7-6-.4-11 1.8-14zM24 66h12M30 25v41" />
                                                    </svg>
                                                    <span class="bf-percentage">20% - 24%</span>
                                                    <span class="bf-desc">Hơi mềm, ít rõ nét</span>
                                                </div>
                                            </div>
                                            <div class="col-6">
                                                <div class="body-fat-card" onclick="selectBodyFat(27, this)">
                                                    <!-- SVG Men 25%+ -->
                                                    <svg viewBox="0 0 60 90" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                                                        <path d="M30 15c2.2 0 4-1.8 4-4s-1.8-4-4-4-4 1.8-4 4 1.8 4 4 4zM19 26c3 0 5-.5 11-.5s8 .5 11 .5c2.2 3 2.2 8 1.8 14 0 5-1.5 14-4 24h-17.6c-2.5-10-4-19-4-24-.4-6-.4-11 1.8-14zM24 66h12M30 25.5V66M21 42c4 2 14 2 18 0" />
                                                    </svg>
                                                    <span class="bf-percentage">25% trở lên</span>
                                                    <span class="bf-desc">Tròn trịa, thừa cân</span>
                                                </div>
                                            </div>
                                        </div>

                                        <!-- Vóc dáng NỮ (Ẩn mặc định) -->
                                        <div id="nbBodyFatFemaleContainer" class="row g-2" style="display:none;">
                                            <div class="col-6">
                                                <div class="body-fat-card" onclick="selectBodyFat(19, this)">
                                                    <!-- SVG Women 18-20% -->
                                                    <svg viewBox="0 0 60 90" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                                                        <path d="M30 14c2 0 3.5-1.5 3.5-3.5S32 7 30 7s-3.5 1.5-3.5 3.5 1.5 3.5 3.5 3.5zM20 25c3-1 6-1.5 10-1.5s7 .5 10 1.5c1.5 4 1.2 10 .5 14-.7 4-2.5 8-2 12 .5 4 2.5 8 2.5 12h-22s2-4 2.5-12c.5-4-1.3-8-2-12-.7-4-1-10 .5-14zM22 64h16M30 23.5v40.5" />
                                                    </svg>
                                                    <span class="bf-percentage">18% - 20%</span>
                                                    <span class="bf-desc">Săn chắc, lộ cơ nhẹ</span>
                                                </div>
                                            </div>
                                            <div class="col-6">
                                                <div class="body-fat-card" onclick="selectBodyFat(23, this)">
                                                    <!-- SVG Women 22-24% -->
                                                    <svg viewBox="0 0 60 90" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                                                        <path d="M30 14c2 0 3.5-1.5 3.5-3.5S32 7 30 7s-3.5 1.5-3.5 3.5 1.5 3.5 3.5 3.5zM20 25c3-1 6-1.2 10-1.2s7 .2 10 1.2c1.5 4 1.2 9 .8 13-.4 4-2 8-1.5 12 .5 4 2 8 2 12h-22.6s2-4 2-12c.5-4-1.1-8-1.5-12-.4-4-.7-9 .8-13zM22 64h16M30 23.8v40.2" />
                                                    </svg>
                                                    <span class="bf-percentage">22% - 24%</span>
                                                    <span class="bf-desc">Thon thả, đường cong</span>
                                                </div>
                                            </div>
                                            <div class="col-6">
                                                <div class="body-fat-card" onclick="selectBodyFat(27, this)">
                                                    <!-- SVG Women 26-28% -->
                                                    <svg viewBox="0 0 60 90" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                                                        <path d="M30 14c2 0 3.5-1.5 3.5-3.5S32 7 30 7s-3.5 1.5-3.5 3.5 1.5 3.5 3.5 3.5zM21 25c3-.5 5-1 9-1s6 .5 9 1c1.5 4 1.2 9 1 13-.2 4-1.2 8-.8 12 .4 4 1.5 8 1.5 12H19.3s1.5-4 1.5-12c.4-4-.6-8-.8-12-.2-4-.5-9 1-13zM23 64h14M30 24v40" />
                                                    </svg>
                                                    <span class="bf-percentage">26% - 28%</span>
                                                    <span class="bf-desc">Đầy đặn, ít cơ nét</span>
                                                </div>
                                            </div>
                                            <div class="col-6">
                                                <div class="body-fat-card" onclick="selectBodyFat(32, this)">
                                                    <!-- SVG Women 30%+ -->
                                                    <svg viewBox="0 0 60 90" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                                                        <path d="M30 14c2 0 3.5-1.5 3.5-3.5S32 7 30 7s-3.5 1.5-3.5 3.5 1.5 3.5 3.5 3.5zM21 25c3 0 5-.5 9-.5s6 .5 9 .5c1.5 4 1.5 9 1.5 13 0 4-.5 8-.2 12 .3 4 1.5 8 1.5 12h-24.6s1.2-4 1.5-12c.3-4-.2-8-.2-12 0-4 0-9 1.5-13zM23 64h14M30 24.5v39.5" />
                                                    </svg>
                                                    <span class="bf-percentage">30% trở lên</span>
                                                    <span class="bf-desc">Tròn đầy, mỡ thừa</span>
                                                </div>
                                            </div>
                                        </div>

                                    </div>
                                </div>

                                <div class="mt-4 pt-3 border-top d-flex justify-content-end">
                                    <button type="button" class="btn btn-nb-primary" onclick="submitNutriBoost()">
                                        Tính Toán Chỉ Số <i class="fas fa-calculator ms-1"></i>
                                    </button>
                                </div>

                            </form>
                        </div>

                        <!-- ════ SCREEN 2: PERSONALIZED REPORT PANEL ════ -->
                        <div id="nutriBoostResultScreen" style="display:none;" class="report-fade-in">
                            
                            <!-- Health Warning Banner -->
                            <div id="nbHealthWarning" class="health-warning-banner" style="display:none;">
                                <i class="fas fa-exclamation-triangle mt-1" style="font-size:1rem;"></i>
                                <span id="nbWarningText">Cảnh báo sức khỏe...</span>
                            </div>

                            <!-- Chỉ số calo -->
                            <div class="row g-3 mb-4">
                                <div class="col-sm-6">
                                    <div class="stat-circle-box" style="border-color: rgba(0, 230, 118, 0.45); background: #f0fff4;">
                                        <div class="stat-big-val" id="resTargetCal">2,100</div>
                                        <div class="stat-label" style="color:#009624;">Calo mục tiêu (kcal/ngày)</div>
                                        <div class="stat-subtext" id="resCalDiff">Thâm hụt 500 kcal từ TDEE</div>
                                    </div>
                                </div>
                                <div class="col-sm-3 col-6">
                                    <div class="stat-circle-box">
                                        <div class="stat-big-val" style="font-size: 1.6rem; color:#111827;" id="resTDEE">2,600</div>
                                        <div class="stat-label" style="font-size:0.7rem;">TDEE (Tiêu hao)</div>
                                        <div class="stat-subtext">Calo tiêu hao mỗi ngày</div>
                                    </div>
                                </div>
                                <div class="col-sm-3 col-6">
                                    <div class="stat-circle-box">
                                        <div class="stat-big-val" style="font-size: 1.6rem; color:#111827;" id="resBMR">1,650</div>
                                        <div class="stat-label" style="font-size:0.7rem;">BMR (Tối thiểu)</div>
                                        <div class="stat-subtext" id="resBmrMethod">Mifflin-St Jeor</div>
                                    </div>
                                </div>
                            </div>

                            <div class="row g-4 mb-4">
                                <!-- Phân bổ Macro Dinh dưỡng -->
                                <div class="col-md-5">
                                    <div class="nb-section-title">
                                        <i class="fas fa-chart-pie"></i> Phân bổ Macros
                                    </div>
                                    
                                    <div class="p-3" style="background: #f9fafb; border: 1px solid #e5e7eb; border-radius:12px;">
                                        <!-- Protein -->
                                        <div class="macro-row">
                                            <div class="macro-header">
                                                <span class="macro-label"><span class="macro-dot dot-protein"></span>Đạm (Protein)</span>
                                                <span id="resProtText">150g (30%)</span>
                                            </div>
                                            <div class="macro-bar-container">
                                                <div class="macro-bar-fill fill-protein" id="resProtBar"></div>
                                            </div>
                                        </div>
                                        
                                        <!-- Carbs -->
                                        <div class="macro-row">
                                            <div class="macro-header">
                                                <span class="macro-label"><span class="macro-dot dot-carbs"></span>Tinh bột (Carbs)</span>
                                                <span id="resCarbsText">225g (45%)</span>
                                            </div>
                                            <div class="macro-bar-container">
                                                <div class="macro-bar-fill fill-carbs" id="resCarbsBar"></div>
                                            </div>
                                        </div>

                                        <!-- Fat -->
                                        <div class="macro-row mb-0">
                                            <div class="macro-header">
                                                <span class="macro-label"><span class="macro-dot dot-fat"></span>Chất béo (Fat)</span>
                                                <span id="resFatText">58g (25%)</span>
                                            </div>
                                            <div class="macro-bar-container">
                                                <div class="macro-bar-fill fill-fat" id="resFatBar"></div>
                                            </div>
                                        </div>
                                    </div>
                                </div>

                                <!-- Thực đơn tự nhiên Clean Meals -->
                                <div class="col-md-7">
                                    <div class="nb-section-title">
                                        <i class="fas fa-utensils"></i> Thực đơn tự nhiên (Clean meals)
                                    </div>
                                    <div class="diet-table" id="resDietTable">
                                        <!-- Dynamic rows inserted here -->
                                    </div>
                                </div>
                            </div>

                            <!-- Đánh giá sức khỏe & Lời khuyên tập luyện -->
                            <div class="row g-4 mb-4">
                                <div class="col-md-5">
                                    <div class="nb-section-title">
                                        <i class="fas fa-heartbeat"></i> Đánh giá chỉ số cơ thể
                                    </div>
                                    <div class="p-4 shadow-sm" style="background: #ffffff; border: 1.5px solid #e5e7eb; border-radius:16px; height: 100%;">
                                        <div class="d-flex justify-content-between align-items-center mb-3 pb-3 border-bottom">
                                            <span class="fw-bold text-secondary" style="font-size:0.85rem;">Chỉ số BMI:</span>
                                            <span class="fs-5 fw-bold" id="resBmiVal">--</span>
                                        </div>
                                        <div class="d-flex justify-content-between align-items-center mb-3 pb-3 border-bottom">
                                            <span class="fw-bold text-secondary" style="font-size:0.85rem;">Trạng thái:</span>
                                            <span class="fw-bold" id="resBmiStatus">--</span>
                                        </div>
                                        <div class="d-flex justify-content-between align-items-center mb-3 pb-3 border-bottom">
                                            <span class="fw-bold text-secondary" style="font-size:0.85rem;">Lượng nước khuyên dùng:</span>
                                            <span class="fw-bold text-dark" id="resWaterVal">-- Lít / ngày</span>
                                        </div>
                                        <div class="d-flex justify-content-between align-items-center mb-0">
                                            <span class="fw-bold text-secondary" style="font-size:0.85rem;">Mật độ Đạm tối ưu:</span>
                                            <span class="fw-bold text-indigo" id="resProteinDensity">--</span>
                                        </div>
                                    </div>
                                </div>
                                <div class="col-md-7">
                                    <div class="nb-section-title">
                                        <i class="fas fa-running"></i> Giáo án tập luyện thể thao khuyên dùng
                                    </div>
                                    <div class="p-4 shadow-sm" style="background: #ffffff; border: 1.5px solid #e5e7eb; border-radius:16px; height: 100%;">
                                        <h5 class="fw-bold text-success mb-2" id="resWorkoutTitle" style="font-family:'Outfit', sans-serif; font-size:1.05rem;">Đang tải...</h5>
                                        <div class="mb-3" style="font-size: 0.82rem;">
                                            <span class="badge bg-success-light text-success p-2" id="resWorkoutFreq">Tần suất: --</span>
                                        </div>
                                        <div class="mb-2" style="font-size:0.84rem; line-height:1.45;">
                                            <strong>🏋️ Tập kháng lực:</strong> <span id="resWorkoutStrength" class="text-muted">Đang tải...</span>
                                        </div>
                                        <div class="mb-2" style="font-size:0.84rem; line-height:1.45;">
                                            <strong>🏃 Cardio/Thể lực:</strong> <span id="resWorkoutCardio" class="text-muted">Đang tải...</span>
                                        </div>
                                        <div class="mb-0" style="font-size:0.84rem; line-height:1.45;">
                                            <strong>💤 Phục hồi & Giấc ngủ:</strong> <span id="resWorkoutRecovery" class="text-muted">Đang tải...</span>
                                        </div>
                                    </div>
                                </div>
                            </div>

                            <!-- Gợi ý thực phẩm bổ sung Supplements (Theo Combo) -->
                            <div class="mb-4">
                                <div class="d-flex align-items-center justify-content-between flex-wrap gap-2 mb-3">
                                    <div class="nb-section-title mb-0">
                                        <i class="fas fa-shopping-basket"></i> Đề xuất Combo thực phẩm bổ sung theo mục tiêu
                                    </div>
                                    <button type="button" class="btn btn-success font-monospace fw-bold shadow-sm rounded-pill px-4 py-2" id="btnAddComboToCartBtn" onclick="addFullComboToCart()">
                                        <i class="fas fa-cart-plus me-1"></i> Mua trọn bộ Combo này
                                    </button>
                                </div>
                                <div class="row g-3" id="resSupplementsGrid">
                                    <!-- Dynamic supplement cards inserted here -->
                                </div>
                            </div>

                            <div class="pt-4 border-top d-flex justify-content-between">
                                <button type="button" class="btn btn-nb-secondary" onclick="switchScreen('form')">
                                    <i class="fas fa-arrow-left me-1"></i> Điều chỉnh chỉ số
                                </button>
                                <a href="cua-hang" class="btn btn-nb-primary text-decoration-none" style="color:white !important;">
                                    Quay lại cửa hàng <i class="fas fa-store ms-1"></i>
                                </a>
                            </div>

                        </div>

                    </div>

                </div>
                
            </div>
        </div>
    </div>

    <jsp:include page="includes/footer.jsp" />

    <!-- Core calculation and integration JavaScript -->
    <script>
        // Real products and foods loaded from database on the server
        const dbProducts = <%= dbProductsJson %>;
        const dbCustomFoods = <%= customFoodsJson %>;

        // Global active states object
        let nutriboostState = {
            gender: 'male',
            goal: 'fatloss',
            bodyFat: null
        };

        // Change selected gender in form
        function setGender(gender, element) {
            nutriboostState.gender = gender;
            
            // Update active class in DOM
            const sibling = element.parentNode.querySelector('.active');
            if (sibling) sibling.classList.remove('active');
            element.classList.add('active');
            
            // Sync radio input checked state
            element.querySelector('input[type="radio"]').checked = true;

            // Toggle male/female body fat picker panels
            if (gender === 'male') {
                document.getElementById('nbBodyFatMaleContainer').style.display = 'flex';
                document.getElementById('nbBodyFatFemaleContainer').style.display = 'none';
            } else {
                document.getElementById('nbBodyFatMaleContainer').style.display = 'none';
                document.getElementById('nbBodyFatFemaleContainer').style.display = 'flex';
            }

            // Reset body fat selection when gender changes to prevent mismatched values
            deselectBodyFat();
        }

        // Change selected goal in form
        function setGoal(goal, element) {
            nutriboostState.goal = goal;
            
            // Update active class in DOM
            const cards = element.parentNode.querySelectorAll('.nb-card-selector');
            cards.forEach(card => card.classList.remove('active'));
            element.classList.add('active');
            
            // Sync radio input checked
            element.querySelector('input[type="radio"]').checked = true;
        }

        // Select body fat percentage from image visual picker
        function selectBodyFat(val, element) {
            nutriboostState.bodyFat = val;
            document.getElementById('nbBodyFatVal').value = val;
            
            // Highlight active body fat card
            const containerId = nutriboostState.gender === 'male' ? 'nbBodyFatMaleContainer' : 'nbBodyFatFemaleContainer';
            const cards = document.getElementById(containerId).querySelectorAll('.body-fat-card');
            cards.forEach(card => card.classList.remove('active'));
            element.classList.add('active');

            // Show deselect button
            document.getElementById('nbDeselectBf').style.display = 'inline-block';
        }

        // Deselect body fat percentage (reset to use Mifflin formula)
        function deselectBodyFat() {
            nutriboostState.bodyFat = null;
            document.getElementById('nbBodyFatVal').value = '';
            
            // Remove active class from all cards
            document.querySelectorAll('.body-fat-card').forEach(card => card.classList.remove('active'));
            
            // Hide deselect button
            document.getElementById('nbDeselectBf').style.display = 'none';
        }

        // Switch between form screen and report screen
        function switchScreen(screenName) {
            const formScreen = document.getElementById('nutriBoostFormScreen');
            const resultScreen = document.getElementById('nutriBoostResultScreen');
            
            if (screenName === 'form') {
                resultScreen.style.display = 'none';
                formScreen.style.display = 'block';
                // Scroll smooth back to top of the card
                document.querySelector('.nutriboost-main-card').scrollIntoView({ behavior: 'smooth' });
            } else {
                formScreen.style.display = 'none';
                resultScreen.style.display = 'block';
                document.querySelector('.nutriboost-main-card').scrollIntoView({ behavior: 'smooth' });
            }
        }

        // Trigger validation and submit calculation
        function submitNutriBoost() {
            const ageInp = document.getElementById('nbAge');
            const heightInp = document.getElementById('nbHeight');
            const weightInp = document.getElementById('nbWeight');
            
            const ageVal = parseInt(ageInp.value);
            const heightVal = parseFloat(heightInp.value);
            const weightVal = parseFloat(weightInp.value);
            const activityVal = parseFloat(document.getElementById('nbActivity').value);

            let isValid = true;

            // Reset error messages
            document.querySelectorAll('.nb-error-feedback').forEach(el => el.style.display = 'none');
            ageInp.classList.remove('is-invalid');
            heightInp.classList.remove('is-invalid');
            weightInp.classList.remove('is-invalid');

            // Validate Age (10-100)
            if (isNaN(ageVal) || ageVal < 10 || ageVal > 100) {
                document.getElementById('nbAgeError').style.display = 'block';
                ageInp.classList.add('is-invalid');
                isValid = false;
            }

            // Validate Height (100-250)
            if (isNaN(heightVal) || heightVal < 100 || heightVal > 250) {
                document.getElementById('nbHeightError').style.display = 'block';
                heightInp.classList.add('is-invalid');
                isValid = false;
            }

            // Validate Weight (30-250)
            if (isNaN(weightVal) || weightVal < 30 || weightVal > 250) {
                document.getElementById('nbWeightError').style.display = 'block';
                weightInp.classList.add('is-invalid');
                isValid = false;
            }

            if (!isValid) return;

            // Process Core AI Calculations
            const result = calculateNutriBoost({
                gender: nutriboostState.gender,
                age: ageVal,
                height: heightVal,
                weight: weightVal,
                activityFactor: activityVal,
                goal: nutriboostState.goal,
                bodyFat: nutriboostState.bodyFat
            });

            // Render result data to Screen 2
            renderReport(result);

            // Switch to result screen
            switchScreen('result');
        }

        /* =========================================================================
           CORE AI ENGINE: HEALTH FORMULA CALCULATIONS WITH DB INTEGRATION
           ========================================================================= */
        function calculateNutriBoost(data) {
            const { gender, age, height, weight, activityFactor, goal, bodyFat } = data;
            let bmr = 0;
            let methodUsed = "";
            let warnings = [];

            // 1. Calculate BMR
            if (bodyFat !== null && bodyFat > 0) {
                // Katch-McArdle Formula
                const lbm = weight * (100 - bodyFat) / 100;
                bmr = 370 + (21.6 * lbm);
                methodUsed = "Katch-McArdle (LBM: " + lbm.toFixed(1) + "kg)";
            } else {
                // Mifflin-St Jeor Formula
                if (gender === 'male') {
                    bmr = (10 * weight) + (6.25 * height) - (5 * age) + 5;
                } else {
                    bmr = (10 * weight) + (6.25 * height) - (5 * age) - 161;
                }
                methodUsed = "Mifflin-St Jeor";
            }

            // 2. Calculate TDEE
            const tdee = bmr * activityFactor;

            // 3. Calculate Target Calories based on Goal
            let targetCalories = tdee;
            let calDiffText = "";
            
            if (goal === 'fatloss') {
                targetCalories = tdee - 500;
                calDiffText = "Thâm hụt 500 kcal từ mức duy trì (TDEE)";
            } else if (goal === 'muscle') {
                targetCalories = tdee + 200;
                calDiffText = "Thặng dư nhẹ 200 kcal để nuôi dưỡng cơ bắp";
            } else if (goal === 'weightgain') {
                targetCalories = tdee + 500;
                calDiffText = "Thặng dư dồi dào 500 kcal để thúc đẩy tăng cân";
            }

            // 4. Edge Case: Safety limits for minimum daily calories
            if (gender === 'female' && targetCalories < 1200) {
                targetCalories = 1200;
                warnings.push("⚠️ An toàn sức khỏe: Calo mục tiêu đã được tự động giới hạn ở mức tối thiểu 1,200 kcal/ngày dành cho nữ giới để duy trì chức năng nội tiết và chuyển hóa ổn định.");
            } else if (gender === 'male' && targetCalories < 1500) {
                targetCalories = 1500;
                warnings.push("⚠️ An toàn sức khỏe: Calo mục tiêu đã được tự động giới hạn ở mức tối thiểu 1,500 kcal/ngày dành cho nam giới để tránh suy nhược cơ thể.");
            }

            // 5. Edge Case: Extremely low or high BMI check
            const bmi = weight / ((height / 100) * (height / 100));
            if (bmi < 15) {
                warnings.push("⚠️ Lưu ý: Chỉ số BMI của bạn cực kỳ thấp (gầy độ 3). Khuyên dùng mục tiêu Tăng Cân Nhanh và tham khảo ý kiến bác sĩ dinh dưỡng.");
            } else if (bmi > 35) {
                warnings.push("⚠️ Cảnh báo: Chỉ số BMI biểu thị béo phì cấp độ nặng. Hãy duy trì chế độ dinh dưỡng lành mạnh và bắt đầu vận động nhẹ nhàng để giảm mỡ an toàn.");
            }

            // 6. Calculate Macronutrient Breakdown (Protein, Carbs, Fat)
            let macroPerc = { protein: 30, carbs: 45, fat: 25 }; // Default
            if (goal === 'fatloss') {
                macroPerc = { protein: 40, carbs: 30, fat: 30 }; // High protein, lower carb
            } else if (goal === 'muscle') {
                macroPerc = { protein: 30, carbs: 45, fat: 25 }; // Balanced for lean gains
            } else if (goal === 'weightgain') {
                macroPerc = { protein: 25, carbs: 50, fat: 25 }; // High carb for calorie loading
            }

            // Grams: 1g Protein = 4 kcal, 1g Carb = 4 kcal, 1g Fat = 9 kcal
            const proteinCal = targetCalories * (macroPerc.protein / 100);
            const carbsCal = targetCalories * (macroPerc.carbs / 100);
            const fatCal = targetCalories * (macroPerc.fat / 100);

            const proteinGrams = Math.round(proteinCal / 4);
            const carbsGrams = Math.round(carbsCal / 4);
            const fatGrams = Math.round(fatCal / 9);

            // 7. Dynamic Meal Plan Generation using Custom_Foods DB
            // Helper function to query our local foods list parsed by the server
            function getDbFood(keyword, fallbackDesc) {
                if (!dbCustomFoods || dbCustomFoods.length === 0) return null;
                const match = dbCustomFoods.find(f => f.name.toLowerCase().includes(keyword.toLowerCase()));
                if (match) {
                    return `🍜 <b>\${match.name}</b> (\${match.calories} kcal, \${match.protein}g Protein, \${match.carbs}g Carbs, \${match.fat}g Fat) - \${match.description}`;
                }
                return null;
            }

            let meals = [];
            if (goal === 'fatloss') {
                const breakfast = getDbFood("Phở gà") || '🍳 3 lòng trắng trứng + 1 quả trứng nguyên quả ốp la, 100g khoai lang luộc, 1 quả táo nhỏ.';
                const lunch = getDbFood("Gỏi cuốn") || '🥗 2 cái Gỏi cuốn tôm thịt ăn kèm nước chấm đậu phộng nhạt. Kết hợp thêm 150g ức gà luộc.';
                
                meals = [
                    { time: 'Sáng', desc: breakfast },
                    { time: 'Trưa', desc: lunch },
                    { time: 'Trước tập', desc: '🍌 1 quả chuối tiêu hoặc 1 lát bánh mì đen phết 1 thìa bơ đậu phộng.' },
                    { time: 'Tối', desc: '🐟 200g phile cá hồi nướng giấy bạc, salad xà lách + dưa chuột trộn nước sốt giấm táo.' }
                ];
            } else if (goal === 'muscle') {
                const breakfast = getDbFood("Phở bò") || '🥩 150g thịt bò áp chảo, 2 lát bánh mì sandwich nguyên cám, 2 quả trứng ốp la.';
                const lunch = getDbFood("Bún chả") || '🍖 200g thịt nạc heo áp chảo, 1 chén cơm gạo lứt (150g), canh cải cúc nấu thịt bằm.';
                const dinner = getDbFood("Bún bò") || '🍤 200g tôm hấp hoặc cá thu sốt cà chua nhạt, 1 chén cơm lứt chín.';

                meals = [
                    { time: 'Sáng', desc: breakfast },
                    { time: 'Trưa', desc: lunch },
                    { time: 'Trước tập', desc: '🥤 1 muỗng Whey Protein lắc + 1 quả táo đỏ hoặc 50g yến mạch pha nước ấm.' },
                    { time: 'Tối', desc: dinner }
                ];
            } else { // weightgain
                const breakfast = getDbFood("Bún bò") || '🍜 1 tô phở bò chín nhiều bánh thịt + 2 quả trứng chần chần, kèm 1 ly sữa nguyên kem.';
                const lunch = getDbFood("Cơm tấm") || '🍛 250g thịt heo ba chỉ kho hoặc bò xào hành tây, 2 chén cơm trắng đầy, canh sườn hầm.';
                const dinner = getDbFood("Cơm chiên") || '🍗 250g gà chiên sốt teriyaki, 2 bát cơm trắng, đĩa rau xào thập cẩm tỏi.';

                meals = [
                    { time: 'Sáng', desc: breakfast },
                    { time: 'Trưa', desc: lunch },
                    { time: 'Trước tập', desc: '🥤 1 muỗng Mass Gainer sữa lắc béo ngậy + 1 quả chuối chín lớn và một nắm hạt điều.' },
                    { time: 'Tối', desc: dinner }
                ];
            }

            // Calculate additional health assessment stats
            const bmiVal = bmi.toFixed(1);
            let bmiStatus = "";
            let bmiClass = "";
            if (bmi < 18.5) {
                bmiStatus = "Thiếu cân (Underweight)";
                bmiClass = "text-warning";
            } else if (bmi >= 18.5 && bmi < 25) {
                bmiStatus = "Cân đối (Normal weight)";
                bmiClass = "text-success";
            } else if (bmi >= 25 && bmi < 30) {
                bmiStatus = "Thừa cân (Overweight)";
                bmiClass = "text-warning";
            } else {
                bmiStatus = "Béo phì (Obese)";
                bmiClass = "text-danger";
            }

            const waterIntake = (weight * 0.04).toFixed(1);
            
            let proteinDensity = "";
            if (goal === 'fatloss') {
                proteinDensity = `\${Math.round(weight * 2.0)}g - \${Math.round(weight * 2.2)}g (2.0 - 2.2g/kg)`;
            } else if (goal === 'muscle') {
                proteinDensity = `\${Math.round(weight * 1.8)}g - \${Math.round(weight * 2.0)}g (1.8 - 2.0g/kg)`;
            } else {
                proteinDensity = `\${Math.round(weight * 1.6)}g - \${Math.round(weight * 1.8)}g (1.6 - 1.8g/kg)`;
            }

            const maxHR = 220 - age;
            const zone2Min = Math.round(maxHR * 0.6);
            const zone2Max = Math.round(maxHR * 0.7);

            // Generate Workout Guidance
            let workoutPlan = {
                title: "",
                frequency: "",
                strengthFocus: "",
                cardioFocus: "",
                recoveryTip: ""
            };

            if (goal === 'fatloss') {
                workoutPlan.title = "🔥 Chương trình Đốt Mỡ & Bảo Toàn Cơ Bắp (Fat Loss Deficit)";
                workoutPlan.frequency = "4 - 5 buổi / tuần (3 buổi Kháng lực + 2 buổi Cardio)";
                workoutPlan.strengthFocus = "Ưu tiên tập tạ/kháng lực toàn thân (Full Body) hoặc chia Upper/Lower. Tập trung vào các bài Compound (Squat, Deadlift, Push-up, Lunge) với số reps từ 8-12 mỗi set. Cố gắng giữ nguyên mức tạ cũ để kích thích giữ cơ, không nên tập tạ quá nhẹ.";
                workoutPlan.cardioFocus = `Thực hiện 20-30 phút LISS Cardio (Đi bộ dốc, đạp xe) sau buổi tập tạ hoặc vào ngày nghỉ. Duy trì nhịp tim trong <b>Zone 2 Fat Burn: \${zone2Min} - \${zone2Max} nhịp/phút</b>. Có thể bổ sung 1 buổi HIIT ngắn (15 phút) cuối tuần nếu thể lực tốt.`;
                workoutPlan.recoveryTip = "Ngủ đủ 7-8 tiếng/ngày để tránh tăng cortisol (gây tích mỡ nước). Uống đủ lượng nước khuyến nghị, bổ sung BCAA/Điện giải trong lúc tập để bảo vệ tế bào cơ.";
            } else if (goal === 'muscle') {
                workoutPlan.title = "💪 Chương trình Kích Thích Phì Đại Cơ Bắp (Muscle Hypertrophy)";
                workoutPlan.frequency = "4 - 6 buổi / tuần (Lịch tập Push-Pull-Legs hoặc Upper-Lower)";
                workoutPlan.strengthFocus = "Áp dụng nguyên tắc Quá tải lũy tiến (Progressive Overload) - tăng dần tạ hoặc số reps qua từng tuần. Tập trung vào phạm vi 6-12 reps/set đạt ngưỡng sát thất bại (RPE 8-9). Các bài tập chủ đạo: Bench Press, Barbell Row, Overhead Press, Squats.";
                workoutPlan.cardioFocus = `Hạn chế Cardio cường độ cao. Chỉ nên thực hiện LISS Cardio nhẹ nhàng 1-2 lần/tuần, mỗi lần 15-20 phút để cải thiện hệ tim mạch, hỗ trợ lưu thông máu phục hồi cơ bắp. Nhịp tim giữ ở <b>Zone 1-2: dưới \${zone2Max} nhịp/phút</b>.`;
                workoutPlan.recoveryTip = "Thời gian nghỉ giữa các hiệp tập nặng từ 2-3 phút để phục hồi ATP. Đảm bảo giãn cơ, lăn foam roller sau tập. Sử dụng Creatine hàng ngày để tăng trữ nước tế bào cơ và sức mạnh bộc phát.";
            } else { // weightgain
                workoutPlan.title = "🚀 Chương trình Tăng Cân Sức Mạnh & Xây Dựng Khung Cơ Bản (Bulking)";
                workoutPlan.frequency = "3 - 4 buổi / tuần (Ưu tiên tập tạ nặng, nghỉ ngơi nhiều)";
                workoutPlan.strengthFocus = "Tập trung 100% vào các bài tập đa khớp Compound chịu lực lớn để kích thích xương khớp và toàn bộ nhóm cơ lớn phát triển. Tập nặng từ 5-8 reps/set. Nghỉ giữa các hiệp dài hơn (2.5 - 3 phút) để tối ưu hóa phục hồi sức mạnh.";
                workoutPlan.cardioFocus = "Cardio nên giữ ở mức tối thiểu (không quá 1 buổi/tuần, đi bộ nhẹ nhàng 15 phút) nhằm tránh tiêu hao calo không cần thiết, giúp cơ thể giữ được thặng dư năng lượng tối đa phục vụ việc tăng trọng lượng.";
                workoutPlan.recoveryTip = "Ưu tiên giấc ngủ sâu vì đây là lúc cơ thể tổng hợp protein và hormone phát triển (GH). Ăn một bữa phụ giàu Carb + Protein hấp thụ chậm (như Casein hoặc sữa yến mạch) trước khi ngủ để tránh dị hóa.";
            }

            // Adjust recommendations based on Activity Level input
            if (activityFactor === 1.2) {
                workoutPlan.strengthFocus = "<b>[Nhập môn]</b> Bắt đầu từ 2-3 buổi/tuần bằng các bài tập bodyweight hoặc tạ nhẹ để cơ thể thích nghi. Chú ý học kỹ thuật động tác đúng trước khi tăng tạ.";
                workoutPlan.recoveryTip += " <br>⚠️ <i>Lưu ý: Bạn đang ít vận động, nên dành 5-10 phút khởi động thật kỹ các khớp cổ tay, cổ chân, gối và vai trước tập để tránh chấn thương.</i>";
            } else if (activityFactor === 1.725) {
                workoutPlan.recoveryTip += " <br>⚡ <i>Lời khuyên nâng cao: Tần suất tập luyện của bạn rất lớn. Hãy chú ý các dấu hiệu quá tải (Overtraining) như mệt mỏi kéo dài, ngủ không ngon, đau khớp. Nên dành riêng 1 tuần Deload (giảm 50% khối lượng tập) sau mỗi 6-8 tuần tập nặng liên tục.</i>";
            }

            // 8. Supplement Recommendations (Real SQL Products mapped, falling back to mock description if product not in catalog)
            function getProduct(id, fallbackName, fallbackImg, fallbackDesc, fallbackPrice, fallbackOldPrice) {
                const dbProd = dbProducts[id];
                if (dbProd) {
                    let displayPrice = Number(dbProd.price).toLocaleString('vi-VN') + " ₫";
                    let displayOldPrice = "";
                    if (dbProd.discountPrice && dbProd.discountPrice > 0) {
                        displayPrice = Number(dbProd.discountPrice).toLocaleString('vi-VN') + " ₫";
                        displayOldPrice = Number(dbProd.price).toLocaleString('vi-VN') + " ₫";
                    }
                    return {
                        id: dbProd.id,
                        name: dbProd.name,
                        img: dbProd.imageUrl || fallbackImg,
                        desc: dbProd.description ? (dbProd.description.length > 120 ? dbProd.description.substring(0, 120) + "..." : dbProd.description) : fallbackDesc,
                        price: displayPrice,
                        oldPrice: displayOldPrice
                    };
                }
                return {
                    id,
                    name: fallbackName,
                    img: fallbackImg,
                    desc: fallbackDesc,
                    price: fallbackPrice,
                    oldPrice: fallbackOldPrice
                };
            }

            let supplements = [];
            if (goal === 'fatloss') {
                supplements = [
                    getProduct(2, 'Mutant Iso Surge 5lbs', 'MutantIsoSurge5lbs.jpg', 'Whey Isolate tinh khiết hấp thụ siêu nhanh, hỗ trợ phục hồi và phát triển cơ nạc trong thời kỳ cắt nét.', '1,650,000 ₫', '1,900,000 ₫'),
                    getProduct(17, 'Lipo-6 Hardcore Burner', 'Lipo6Hardcore.jpg', 'Hỗ trợ tăng sinh nhiệt đốt mỡ thừa, tăng tốc độ chuyển hóa trao đổi chất và duy trì sự tỉnh táo tập trung.', '650,000 ₫', '750,000 ₫'),
                    getProduct(19, 'Raze L-Carnitine 3000', 'Raze L-Carnitine 3000.jpg', 'Chuyển hóa mỡ thừa thành năng lượng tập luyện, gia tăng sức bền thể lực, giảm mệt mỏi.', '720,000 ₫', '800,000 ₫')
                ];
            } else if (goal === 'muscle') {
                supplements = [
                    getProduct(1, 'ON Gold Standard 100% Whey 5lbs', 'ONGoldStandard100Whey 5lbs.jpg', 'Dòng Whey Blend huyền thoại cung cấp 24g protein cùng BCAA hấp thụ tối ưu phát triển cơ bắp sau tập luyện.', '1,690,000 ₫', '1,850,000 ₫'),
                    getProduct(10, 'Ostrovit Creatine Monohydrate 500g', 'OstrovitCreatine Monohydrate500g.jpg', 'Tăng cường lượng creatine dự trữ trong tế bào cơ bắp, hỗ trợ bùng nổ sức mạnh, tăng khối lượng tạ.', '450,000 ₫', '550,000 ₫'),
                    getProduct(8, 'Redcon1 Total War Reloaded 546g', 'Redcon1Total WarReloadedPre-workout546g.jpg', 'Dòng tăng sức mạnh đỉnh cao giúp tối ưu hóa mạch máu, gia tăng tỉnh táo tập trung cực độ.', '950,000 ₫', '1,100,000 ₫')
                ];
            } else { // weightgain
                supplements = [
                    getProduct(6, 'Elite Labs Mass Muscle Gainer 10lbs', 'EliteLabsMass Muscle Gainer10lbs.jpg', 'Cung cấp nguồn Calo sạch khổng lồ từ tinh bột phức hợp chất lượng cao, giúp tăng cân nhanh hạn chế tích mỡ.', '1,450,000 ₫', '1,600,000 ₫'),
                    getProduct(7, 'Sữa tăng cân Mass True Gainer 2.5kg', 'MassTrueGainer.jpg', 'Giải pháp tăng cân nhanh vượt trội cho người gầy kinh niên, hấp thu kém, cung cấp vitamin enzym.', '690,000 ₫', '1,000,000 ₫'),
                    getProduct(24, 'Muscletech Platinum MultiVitamin', 'MuscletechPlatinumMultiVitamin.jpg', 'Bổ sung đầy đủ vitamin và khoáng chất thiết yếu giúp tăng đề kháng, kích thích ăn ngon miệng.', '360,000 ₫', '420,000 ₫')
                ];
            }

            // Return calculated data as JSON Object
            return {
                bmr: Math.round(bmr),
                tdee: Math.round(tdee),
                targetCalories: Math.round(targetCalories),
                methodUsed,
                calDiffText,
                macros: {
                    perc: macroPerc,
                    grams: {
                        protein: proteinGrams,
                        carbs: carbsGrams,
                        fat: fatGrams
                    }
                },
                meals,
                supplements,
                warnings,
                assessment: {
                    bmi: bmiVal,
                    bmiStatus: bmiStatus,
                    bmiClass: bmiClass,
                    waterIntake: waterIntake,
                    proteinDensity: proteinDensity
                },
                workout: workoutPlan
            };
        }

        // Render calculated report details into the HTML result screen
        function renderReport(res) {
            // Render target calories, TDEE, BMR
            document.getElementById('resTargetCal').textContent = Number(res.targetCalories).toLocaleString('vi-VN');
            document.getElementById('resCalDiff').textContent = res.calDiffText;
            document.getElementById('resTDEE').textContent = Number(res.tdee).toLocaleString('vi-VN');
            document.getElementById('resBMR').textContent = Number(res.bmr).toLocaleString('vi-VN');
            document.getElementById('resBmrMethod').textContent = res.methodUsed;

            // Render health warnings
            const warningBanner = document.getElementById('nbHealthWarning');
            const warningText = document.getElementById('nbWarningText');
            if (res.warnings.length > 0) {
                warningText.innerHTML = res.warnings.join('<br>');
                warningBanner.style.display = 'flex';
            } else {
                warningBanner.style.display = 'none';
            }

            // Render additional health assessment stats
            document.getElementById('resBmiVal').textContent = res.assessment.bmi;
            document.getElementById('resBmiStatus').textContent = res.assessment.bmiStatus;
            document.getElementById('resBmiStatus').className = 'fw-bold ' + res.assessment.bmiClass;
            document.getElementById('resWaterVal').textContent = res.assessment.waterIntake + ' Lít / ngày';
            document.getElementById('resProteinDensity').textContent = res.assessment.proteinDensity;

            // Render workout stats
            document.getElementById('resWorkoutTitle').textContent = res.workout.title;
            document.getElementById('resWorkoutFreq').textContent = 'Tần suất: ' + res.workout.frequency;
            document.getElementById('resWorkoutStrength').innerHTML = res.workout.strengthFocus;
            document.getElementById('resWorkoutCardio').innerHTML = res.workout.cardioFocus;
            document.getElementById('resWorkoutRecovery').innerHTML = res.workout.recoveryTip;

            // Render Macros
            // Update texts
            document.getElementById('resProtText').textContent = res.macros.grams.protein + 'g (' + res.macros.perc.protein + '%)';
            document.getElementById('resCarbsText').textContent = res.macros.grams.carbs + 'g (' + res.macros.perc.carbs + '%)';
            document.getElementById('resFatText').textContent = res.macros.grams.fat + 'g (' + res.macros.perc.fat + '%)';
            
            // Update bars widths after screen transition
            setTimeout(() => {
                document.getElementById('resProtBar').style.width = res.macros.perc.protein + '%';
                document.getElementById('resCarbsBar').style.width = res.macros.perc.carbs + '%';
                document.getElementById('resFatBar').style.width = res.macros.perc.fat + '%';
            }, 100);

            // Render Meals Table
            const dietTable = document.getElementById('resDietTable');
            dietTable.innerHTML = '';
            res.meals.forEach(m => {
                let timeIcon = 'fa-sun';
                if (m.time === 'Trưa') timeIcon = 'fa-drumstick-bite';
                if (m.time === 'Trước tập') timeIcon = 'fa-bolt';
                if (m.time === 'Tối') timeIcon = 'fa-moon';
                
                const row = document.createElement('div');
                row.className = 'diet-row';
                row.innerHTML = `
                    <div class="diet-time">
                        <i class="fas \${timeIcon}"></i> \${m.time}
                    </div>
                    <div class="diet-desc">
                        \${m.desc}
                    </div>
                `;
                dietTable.appendChild(row);
            });

            // Store current supplements for Combo 1-click buying
            window.currentSupplements = res.supplements;

            // Render Supplements Cards Grid
            const supplementsGrid = document.getElementById('resSupplementsGrid');
            supplementsGrid.innerHTML = '';
            res.supplements.forEach(s => {
                const col = document.createElement('div');
                col.className = 'col-md-4';
                col.innerHTML = `
                    <div class="sup-card">
                        <div class="sup-badge">Gợi ý AI</div>
                        <div class="sup-img-wrap">
                            <img src="${pageContext.request.contextPath}/image/\${s.img}" 
                                 onerror="this.src='https://via.placeholder.com/100'"
                                 alt="\${s.name}" 
                                 class="sup-img">
                        </div>
                        <div class="sup-title" title="\${s.name}">\${s.name}</div>
                        <div class="sup-desc">\${s.desc}</div>
                        <div class="sup-price-row">
                            <div class="sup-old-price">\${s.oldPrice}</div>
                            <div class="sup-price">\${s.price}</div>
                        </div>
                        <button class="btn btn-add-cart-ajax" onclick="addToCartAjax('\${s.id}', this)">
                            <i class="fas fa-cart-plus"></i> Thêm vào giỏ
                        </button>
                    </div>
                `;
                supplementsGrid.appendChild(col);
            });
        }

        /* =========================================================================
           1-CLICK ADD FULL COMBO TO CART
           ========================================================================= */
        async function addFullComboToCart() {
            if (!window.currentSupplements || window.currentSupplements.length === 0) return;

            const comboBtn = document.getElementById('btnAddComboToCartBtn');
            if (comboBtn) {
                comboBtn.disabled = true;
                comboBtn.innerHTML = `<i class="fas fa-spinner fa-spin me-1"></i> Đang thêm Combo...`;
            }

            try {
                let lastCount = 0;
                let lastItems = [];

                // Execute requests sequentially to avoid HTTP session race conditions
                for (const s of window.currentSupplements) {
                    const url = `cua-hang?action=Add&ajax=true&productId=\${s.id}&quantity=1`;
                    const response = await fetch(url);
                    const res = await response.json();
                    if (res.status === 'success') {
                        lastCount = res.cartTotalCount;
                        lastItems = res.cartItems || [];
                    }
                }

                if (typeof updateNavCartCount === 'function') {
                    updateNavCartCount(lastCount);
                } else {
                    const badge = document.querySelector('.cart-count-badge');
                    if (badge) badge.innerText = lastCount;
                }

                if (comboBtn) {
                    comboBtn.disabled = false;
                    comboBtn.innerHTML = `<i class="fas fa-check-circle me-1"></i> Đã thêm trọn bộ Combo!`;
                    setTimeout(() => {
                        comboBtn.innerHTML = `<i class="fas fa-cart-plus me-1"></i> Mua trọn bộ Combo này`;
                    }, 3000);
                }

                document.querySelectorAll('#resSupplementsGrid .btn-add-cart-ajax').forEach(btn => {
                    btn.classList.add('added');
                    btn.innerHTML = `<i class="fas fa-check"></i> Đã thêm vào giỏ`;
                });

                showNfToast('success', 
                    'Đã thêm trọn bộ Combo!', 
                    `Đã thêm thành công \${window.currentSupplements.length} sản phẩm theo mục tiêu của bạn vào giỏ hàng.`,
                    lastItems
                );
            } catch (err) {
                console.error('Lỗi khi thêm Combo:', err);
                if (comboBtn) {
                    comboBtn.disabled = false;
                    comboBtn.innerHTML = `<i class="fas fa-cart-plus me-1"></i> Mua trọn bộ Combo này`;
                }
                showNfToast('failed', 'Lỗi hệ thống', 'Không thể thêm trọn bộ Combo vào giỏ.', []);
            }
        }

        /* =========================================================================
           AJAX INTEGRATION: ADD SUPPLEMENTS TO CART
           ========================================================================= */
        function addToCartAjax(productId, btn) {
            if (btn.classList.contains('loading') || btn.classList.contains('added')) return;
            
            // Add loading state
            btn.classList.add('loading');
            const oldContent = btn.innerHTML;
            btn.innerHTML = `<i class="fas fa-spinner fa-spin"></i> Đang thêm...`;

            // Make AJAX call to MainController / cua-hang
            const url = `cua-hang?action=Add&ajax=true&productId=\${productId}&quantity=1`;
            
            fetch(url)
                .then(response => {
                    if (!response.ok) {
                        throw new Error('Mạng gặp lỗi khi kết nối.');
                    }
                    return response.json();
                })
                .then(data => {
                    btn.classList.remove('loading');
                    if (data.success) {
                        // Success Visual Feedback
                        btn.classList.add('added');
                        btn.innerHTML = `<i class="fas fa-check-circle"></i> Đã thêm`;
                        
                        // Show Toast Notification
                        if (typeof showNfToast === 'function') {
                            showNfToast('success', 
                                'Đã thêm sản phẩm!', 
                                data.message || 'Sản phẩm đã có trong giỏ hàng.',
                                [{ href: 'gio-hang', label: 'Xem giỏ hàng 🛒', primary: true }]
                            );
                        } else {
                            alert(data.message);
                        }

                        // Update Navbar Cart Count Badge dynamically
                        updateCartBadge(data.cartCount);

                        // Reset button after 3 seconds
                        setTimeout(() => {
                            btn.classList.remove('added');
                            btn.innerHTML = oldContent;
                        }, 3500);

                    } else {
                        btn.innerHTML = oldContent;
                        if (data.redirect) {
                            window.location.href = data.redirect;
                            return;
                        }
                        if (typeof showNfToast === 'function') {
                            showNfToast('failed', 'Thất bại', data.message || 'Không thể thêm sản phẩm.', []);
                        } else {
                            alert(data.message || 'Không thể thêm vào giỏ hàng.');
                        }
                    }
                })
                .catch(error => {
                    console.error('Lỗi khi thêm sản phẩm:', error);
                    btn.classList.remove('loading');
                    btn.innerHTML = oldContent;
                    if (typeof showNfToast === 'function') {
                        showNfToast('failed', 'Lỗi hệ thống', 'Không kết nối được đến máy chủ.', []);
                    } else {
                        alert('Lỗi kết nối máy chủ!');
                    }
                });
        }

        // Helper to dynamically update the cart badges in Navbar (Desktop & Mobile)
        function updateCartBadge(count) {
            if (!count || count <= 0) return;
            
            // Desktop Cart Link
            const desktopCart = document.querySelector('a[href="gio-hang"].nav-icon-btn-cart');
            if (desktopCart) {
                let badge = desktopCart.querySelector('.badge');
                if (badge) {
                    badge.textContent = count;
                } else {
                    badge = document.createElement('span');
                    badge.className = 'position-absolute badge badge-sharp';
                    badge.style.cssText = 'top:-7px; right:-7px;';
                    badge.textContent = count;
                    desktopCart.appendChild(badge);
                }
            }

            // Mobile Cart Link
            const mobileCart = document.querySelector('.d-lg-none a[href="gio-hang"]');
            if (mobileCart) {
                let badge = mobileCart.querySelector('.badge');
                if (badge) {
                    badge.textContent = count;
                } else {
                    badge = document.createElement('span');
                    badge.className = 'position-absolute badge badge-sharp';
                    badge.style.cssText = 'top:-6px; right:-6px;';
                    badge.textContent = count;
                    mobileCart.appendChild(badge);
                }
            }
        }
    </script>
</body>
</html>

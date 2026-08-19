<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<!DOCTYPE html>
<html>
    <head>
        <title>Bảng điều khiển (Dashboard) - NutriOverflow</title>
        <jsp:include page="includes/header.jsp" />
        <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
        <style>
            .kpi-card {
                border: none;
                border-radius: 14px;
                transition: transform 0.2s ease, box-shadow 0.2s ease;
                background-color: #ffffff;
            }
            .kpi-card:hover {
                transform: translateY(-5px);
                box-shadow: 0 10px 20px rgba(0, 0, 0, 0.05) !important;
            }
            .card-icon {
                width: 50px;
                height: 50px;
                border-radius: 10px;
                display: flex;
                align-items: center;
                justify-content: center;
                font-size: 1.5rem;
            }
            .bg-light-success { background-color: rgba(40, 167, 69, 0.1); color: #28a745; }
            .bg-light-danger { background-color: rgba(220, 53, 69, 0.1); color: #dc3545; }
            .bg-light-warning { background-color: rgba(255, 193, 7, 0.1); color: #ffc107; }
            .bg-light-info { background-color: rgba(23, 162, 184, 0.1); color: #17a2b8; }
            .bg-light-primary { background-color: rgba(13, 110, 253, 0.1); color: #0d6efd; }
            
            .chart-card {
                border: none;
                border-radius: 16px;
                background-color: #ffffff;
            }
        </style>
    </head>
    <body class="bg-light">
        <c:set var="activeTab" value="Dashboard" scope="request" />
        <jsp:include page="includes/sidebar.jsp" />

        <nav class="navbar navbar-expand-lg navbar-dark mb-4 shadow-sm" style="background-color: #8b0000;">
            <div class="container-fluid px-4">
                <div class="d-flex align-items-center">
                    <button class="btn btn-outline-light me-3" type="button" data-bs-toggle="offcanvas" data-bs-target="#adminSidebar" aria-controls="adminSidebar">
                        <i class="fas fa-bars"></i>
                    </button>
                    <span class="navbar-brand mb-0 h1"><i class="fas fa-chart-line me-2"></i>Bảng điều khiển (Dashboard)</span>
                </div>
                <div class="d-flex align-items-center">
                    <span class="text-white me-3">Xin chào, <strong>${sessionScope.LOGIN_USER.fullName}</strong></span>
                    <a href="MainController?action=Logout" class="btn btn-outline-light btn-sm"><i class="fas fa-sign-out-alt"></i> Đăng xuất</a>
                </div>
            </div>
        </nav>

        <div class="container-fluid px-4 pb-5">
            <!-- Filter Option -->
            <div class="d-flex justify-content-between align-items-center mb-4">
                <h3 class="fw-bold mb-0">Thống kê hoạt động</h3>
                <div class="d-flex align-items-center gap-2">
                    <span class="text-muted small fw-semibold">Khoảng thời gian:</span>
                    <select id="timeRangeSelect" class="form-select border-secondary shadow-sm" style="width: 150px;" onchange="loadDashboardData(this.value)">
                        <option value="7">7 ngày qua</option>
                        <option value="30" selected>30 ngày qua</option>
                        <option value="90">90 ngày qua</option>
                    </select>
                </div>
            </div>

            <!-- KPI Cards Row -->
            <div class="row g-4 mb-4">
                <!-- Card 1: Total Revenue -->
                <div class="col-md-3">
                    <div class="card kpi-card shadow-sm p-3">
                        <div class="d-flex align-items-center">
                            <div class="card-icon bg-light-success me-3">
                                <i class="fas fa-hand-holding-usd"></i>
                            </div>
                            <div>
                                <h6 class="text-muted mb-1" style="font-size: 0.85rem; font-weight: 500;">Doanh thu bán hàng</h6>
                                <h4 class="fw-bold mb-0" id="kpiRevenue">0đ</h4>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Card 2: Total Stock -->
                <div class="col-md-3">
                    <div class="card kpi-card shadow-sm p-3">
                        <div class="d-flex align-items-center">
                            <div class="card-icon bg-light-primary me-3">
                                <i class="fas fa-boxes"></i>
                            </div>
                            <div>
                                <h6 class="text-muted mb-1" style="font-size: 0.85rem; font-weight: 500;">Tổng tồn kho (Đơn vị)</h6>
                                <h4 class="fw-bold mb-0" id="kpiStock">0</h4>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Card 3: Low Stock Warning -->
                <div class="col-md-3">
                    <div class="card kpi-card shadow-sm p-3">
                        <div class="d-flex align-items-center">
                            <div class="card-icon bg-light-warning me-3">
                                <i class="fas fa-exclamation-triangle"></i>
                            </div>
                            <div>
                                <h6 class="text-muted mb-1" style="font-size: 0.85rem; font-weight: 500;">Sắp hết hàng (< 10)</h6>
                                <h4 class="fw-bold mb-0 text-warning" id="kpiLowStock">0</h4>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Card 4: Cancel Rate -->
                <div class="col-md-3">
                    <div class="card kpi-card shadow-sm p-3">
                        <div class="d-flex align-items-center">
                            <div class="card-icon bg-light-danger me-3">
                                <i class="fas fa-ban"></i>
                            </div>
                            <div>
                                <h6 class="text-muted mb-1" style="font-size: 0.85rem; font-weight: 500;">Tỷ lệ hủy đơn</h6>
                                <h4 class="fw-bold mb-0 text-danger" id="kpiCancelRate">0%</h4>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Charts Row -->
            <div class="row g-4 mb-4">
                <!-- Chart 1: Revenue Line -->
                <div class="col-lg-8">
                    <div class="card chart-card shadow-sm p-4" style="height: 100%;">
                        <h5 class="fw-bold mb-3 text-dark"><i class="fas fa-chart-line me-2 text-danger"></i>Biểu đồ Doanh thu (VND)</h5>
                        <div class="chart-container" style="position: relative; height: 320px; width: 100%;">
                            <canvas id="revenueChart"></canvas>
                        </div>
                    </div>
                </div>

                <!-- Chart 2: Order Ratio -->
                <div class="col-lg-4">
                    <div class="card chart-card shadow-sm p-4" style="height: 100%;">
                        <h5 class="fw-bold mb-3 text-dark"><i class="fas fa-chart-pie me-2 text-danger"></i>Tỷ lệ đơn hàng</h5>
                        <div class="chart-container d-flex align-items-center justify-content-center" style="position: relative; height: 260px; width: 100%;">
                            <canvas id="orderRatioChart"></canvas>
                        </div>
                        <div class="text-center mt-3 text-muted small fw-semibold" id="totalOrdersLabel">
                            Tổng số đơn hàng: 0
                        </div>
                    </div>
                </div>
            </div>

            <!-- Row 3: Bestsellers & Staff performance -->
            <div class="row g-4 mb-4">
                <!-- Chart 3: Bestsellers -->
                <div class="col-lg-6">
                    <div class="card chart-card shadow-sm p-4" style="height: 100%;">
                        <h5 class="fw-bold mb-3 text-dark"><i class="fas fa-fire me-2 text-danger"></i>Top 5 Sản phẩm bán chạy nhất</h5>
                        <div class="chart-container" style="position: relative; height: 300px; width: 100%;">
                            <canvas id="bestSellersChart"></canvas>
                        </div>
                    </div>
                </div>

                <!-- Staff performance evaluation -->
                <div class="col-lg-6">
                    <div class="card chart-card shadow-sm p-4" style="height: 100%;">
                        <h5 class="fw-bold mb-3 text-dark"><i class="fas fa-users-cog me-2 text-danger"></i>Đánh giá hiệu suất nhân sự</h5>
                        
                        <!-- Nav Tabs for Staff -->
                        <style>
                            .staff-nav-tab .nav-link {
                                color: #374151 !important;
                                background-color: #f3f4f6 !important;
                                border: 1px solid #d1d5db !important;
                                border-radius: 8px !important;
                                font-weight: 700 !important;
                                font-size: 0.88rem !important;
                                padding: 0.55rem 1.25rem !important;
                                transition: all 0.2s ease !important;
                            }
                            .staff-nav-tab .nav-link.active {
                                color: #ffffff !important;
                                background-color: #8b0000 !important;
                                border-color: #8b0000 !important;
                                box-shadow: 0 4px 12px rgba(139, 0, 0, 0.3) !important;
                            }
                        </style>
                        <ul class="nav nav-pills staff-nav-tab gap-2 mb-3" id="staffTab" role="tablist">
                            <li class="nav-item" role="presentation">
                                <button class="nav-link active" id="cskh-tab" data-bs-toggle="tab" data-bs-target="#cskh-pane" type="button" role="tab" aria-controls="cskh-pane" aria-selected="true">
                                    <i class="fas fa-newspaper me-1"></i>NHÂN VIÊN CSKH (BÀI VIẾT)
                                </button>
                            </li>
                            <li class="nav-item" role="presentation">
                                <button class="nav-link" id="warehouse-tab" data-bs-toggle="tab" data-bs-target="#warehouse-pane" type="button" role="tab" aria-controls="warehouse-pane" aria-selected="false">
                                    <i class="fas fa-warehouse me-1"></i>NHÂN VIÊN KHO
                                </button>
                            </li>
                        </ul>
                        
                        <div class="tab-content" id="staffTabContent">
                            <!-- CSKH Performance Tab -->
                            <div class="tab-pane fade show active" id="cskh-pane" role="tabpanel" aria-labelledby="cskh-tab">
                                <div class="table-responsive">
                                    <table class="table table-hover align-middle mb-0 text-center">
                                        <thead class="table-dark">
                                            <tr>
                                                <th class="fw-bold py-3 text-white">NHÂN VIÊN (USERNAME)</th>
                                                <th class="fw-bold py-3 text-white">TÊN ĐẦY ĐỦ</th>
                                                <th class="fw-bold py-3 text-white">SỐ BÀI VIẾT (CMS)</th>
                                            </tr>
                                        </thead>
                                        <tbody id="cskhTableBody">
                                            <!-- Injected dynamically -->
                                        </tbody>
                                    </table>
                                </div>
                            </div>

                            <!-- Warehouse Performance Tab -->
                            <div class="tab-pane fade" id="warehouse-pane" role="tabpanel" aria-labelledby="warehouse-tab">
                                <div class="table-responsive">
                                    <table class="table table-hover align-middle mb-0 text-center">
                                        <thead class="table-dark">
                                            <tr>
                                                <th class="fw-bold py-3 text-white">MÃ NV</th>
                                                <th class="fw-bold py-3 text-white">HỌ VÀ TÊN</th>
                                                <th class="fw-bold py-3 text-white">LÔ HÀNG ĐÃ NHẬP</th>
                                                <th class="fw-bold py-3 text-white">ĐƠN HÀNG HOÀN TRẢ</th>
                                            </tr>
                                        </thead>
                                        <tbody id="warehouseTableBody">
                                            <!-- Injected dynamically -->
                                        </tbody>
                                    </table>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <script>
            let revenueChart = null;
            let orderRatioChart = null;
            let bestSellersChart = null;

            document.addEventListener("DOMContentLoaded", function() {
                loadDashboardData(30); // load default 30 days
            });

            function loadDashboardData(days) {
                fetch('GetDashboardDataController?days=' + days)
                    .then(response => response.json())
                    .then(data => {
                        if (data.success) {
                            updateKPIs(data);
                            renderRevenueChart(data.revenueData);
                            renderOrderRatioChart(data.orderStatusStats);
                            renderBestSellersChart(data.bestSellers);
                            renderStaffPerformance(data.cskhPerformance, data.warehousePerformance);
                        } else {
                            alert('Lỗi tải dữ liệu thống kê: ' + data.error);
                        }
                    })
                    .catch(err => {
                        console.error('Error fetching dashboard data:', err);
                    });
            }

            function updateKPIs(data) {
                // Calculate total revenue
                let totalRevenue = 0;
                data.revenueData.forEach(item => {
                    totalRevenue += item.revenue;
                });
                document.getElementById('kpiRevenue').innerText = totalRevenue.toLocaleString('vi-VN') + 'đ';

                // Stock
                document.getElementById('kpiStock').innerText = data.inventoryStatus.totalStock.toLocaleString('vi-VN');
                document.getElementById('kpiLowStock').innerText = data.inventoryStatus.lowStockCount;

                // Cancel Rate
                document.getElementById('kpiCancelRate').innerText = data.orderStatusStats.cancellationRate + '%';
                document.getElementById('totalOrdersLabel').innerText = 'Tổng số đơn hàng: ' + data.orderStatusStats.totalOrders;
            }

            function renderRevenueChart(revenueData) {
                const ctx = document.getElementById('revenueChart').getContext('2d');
                if (revenueChart) {
                    revenueChart.destroy();
                }

                const labels = revenueData.map(item => {
                    const parts = item.date.split('-');
                    return parts.length === 3 ? parts[2] + '/' + parts[1] : item.date;
                });
                const values = revenueData.map(item => item.revenue);

                revenueChart = new Chart(ctx, {
                    type: 'line',
                    data: {
                        labels: labels,
                        datasets: [{
                            label: 'Doanh thu ngày',
                            data: values,
                            borderColor: '#8b0000',
                            backgroundColor: 'rgba(139, 0, 0, 0.08)',
                            borderWidth: 3,
                            fill: true,
                            tension: 0.3
                        }]
                    },
                    options: {
                        responsive: true,
                        maintainAspectRatio: false,
                        plugins: {
                            legend: { display: false }
                        },
                        scales: {
                            y: {
                                beginAtZero: true,
                                ticks: {
                                    callback: function(value) {
                                        return value.toLocaleString('vi-VN') + 'đ';
                                    }
                                }
                            }
                        }
                    }
                });
            }

            function renderOrderRatioChart(orderStats) {
                const ctx = document.getElementById('orderRatioChart').getContext('2d');
                if (orderRatioChart) {
                    orderRatioChart.destroy();
                }

                const details = orderStats.details;
                const labels = details.map(item => {
                    const st = (item.status || "").toUpperCase();
                    if (st === "PENDING") return "Chờ xác nhận";
                    if (st === "PROCESSING") return "Đang đóng gói";
                    if (st === "SHIPPING" || st === "DELIVERING") return "Đang vận chuyển";
                    if (st === "DELIVERED") return "Giao thành công";
                    if (st === "CANCELLED") return "Đã hủy đơn";
                    return item.status;
                });
                const values = details.map(item => item.count);
                
                const colors = details.map(item => {
                    const st = (item.status || "").toUpperCase();
                    if (st === "CANCELLED") return "#dc3545"; // Red
                    if (st === "DELIVERED") return "#198754"; // Green
                    if (st === "SHIPPING" || st === "DELIVERING") return "#0d6efd"; // Blue
                    if (st === "PROCESSING") return "#17a2b8"; // Cyan/Teal
                    if (st === "PENDING") return "#ffc107"; // Yellow/Orange
                    return "#6c757d"; // Grey
                });

                orderRatioChart = new Chart(ctx, {
                    type: 'doughnut',
                    data: {
                        labels: labels,
                        datasets: [{
                            data: values,
                            backgroundColor: colors,
                            borderWidth: 1
                        }]
                    },
                    options: {
                        responsive: true,
                        maintainAspectRatio: false,
                        plugins: {
                            legend: {
                                position: 'bottom',
                                labels: { boxWidth: 10, padding: 8, font: { size: 11 } }
                            }
                        }
                    }
                });
            }

            function renderBestSellersChart(bestSellers) {
                const ctx = document.getElementById('bestSellersChart').getContext('2d');
                if (bestSellersChart) {
                    bestSellersChart.destroy();
                }

                const labels = bestSellers.map(item => {
                    return item.name.length > 25 ? item.name.substring(0, 22) + '...' : item.name;
                });
                const values = bestSellers.map(item => item.sold);

                bestSellersChart = new Chart(ctx, {
                    type: 'bar',
                    data: {
                        labels: labels,
                        datasets: [{
                            label: 'Số lượng đã bán',
                            data: values,
                            backgroundColor: 'rgba(13, 110, 253, 0.75)',
                            borderColor: '#0d6efd',
                            borderWidth: 1
                        }]
                    },
                    options: {
                        indexAxis: 'y',
                        responsive: true,
                        maintainAspectRatio: false,
                        plugins: {
                            legend: { display: false }
                        },
                        scales: {
                            x: {
                                beginAtZero: true,
                                ticks: { stepSize: 1 }
                            }
                        }
                    }
                });
            }

            function renderStaffPerformance(cskh, warehouse) {
                const cskhBody = document.getElementById('cskhTableBody');
                cskhBody.innerHTML = '';
                if (!cskh || cskh.length === 0) {
                    cskhBody.innerHTML = `<tr><td colspan="3" class="text-secondary py-4 fw-bold">Chưa có dữ liệu bài viết</td></tr>`;
                } else {
                    cskh.forEach(item => {
                        const row = `<tr>
                            <td class="fw-bold text-dark font-monospace">${item.username}</td>
                            <td class="fw-bold text-dark">${item.fullName}</td>
                            <td><span class="badge bg-success font-monospace px-3 py-2 fs-6 shadow-sm">${item.articlesCount} bài</span></td>
                        </tr>`;
                        cskhBody.innerHTML += row;
                    });
                }

                const whBody = document.getElementById('warehouseTableBody');
                whBody.innerHTML = '';
                if (!warehouse || warehouse.length === 0) {
                    whBody.innerHTML = `<tr><td colspan="4" class="text-secondary py-4 fw-bold">Chưa ghi nhận hoạt động</td></tr>`;
                } else {
                    warehouse.forEach(item => {
                        const row = `<tr>
                            <td class="fw-bold font-monospace text-dark">NV-${item.staffId}</td>
                            <td class="fw-bold text-dark">${item.fullName}</td>
                            <td><span class="badge bg-primary px-3 py-2 fs-6 shadow-sm">${item.batchesCount} lô</span></td>
                            <td><span class="badge bg-warning text-dark px-3 py-2 fs-6 shadow-sm">${item.returnsCount} đơn</span></td>
                        </tr>`;
                        whBody.innerHTML += row;
                    });
                }
            }
        </script>
        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    </body>
</html>

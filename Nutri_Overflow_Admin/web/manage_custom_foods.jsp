<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt"%>
<!DOCTYPE html>
<html lang="vi">
    <head>
        <title>Quản lý Món ăn &amp; Calo - NutriOverflow</title>
        <jsp:include page="includes/header.jsp" />
        <style>
            .table-hover tbody tr:hover {
                background-color: rgba(139, 0, 0, 0.04) !important;
            }
            .modal-content-custom {
                border-radius: 16px;
                border: none;
                box-shadow: 0 10px 30px rgba(0,0,0,0.15);
            }
            .nowrap {
                white-space: nowrap;
            }
        </style>
    </head>
    <body class="bg-light">
        <c:set var="activeTab" value="CustomFoods" scope="request" />
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
            <div class="d-flex justify-content-between align-items-center mb-4">
                <h3 class="fw-bold text-dark m-0"><i class="fas fa-carrot me-2 text-danger"></i>Quản lý Món ăn &amp; Chỉ số Calo</h3>
                <button type="button" class="btn btn-success fw-bold shadow-sm px-4 py-2 rounded-pill" onclick="openAddModal()">
                    <i class="fas fa-plus-circle me-2"></i>Thêm món ăn mới
                </button>
            </div>

            <!-- Alerts for Success/Error -->
            <c:if test="${not empty requestScope.MSG_SUCCESS}">
                <div class="alert alert-success alert-dismissible fade show shadow-sm border-start border-4 border-success mb-4">
                    <i class="fas fa-check-circle me-2"></i> ${requestScope.MSG_SUCCESS}
                    <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                </div>
            </c:if>
            <c:if test="${not empty requestScope.MSG_ERROR}">
                <div class="alert alert-danger alert-dismissible fade show shadow-sm border-start border-4 border-danger mb-4">
                    <i class="fas fa-exclamation-circle me-2"></i> ${requestScope.MSG_ERROR}
                    <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                </div>
            </c:if>

            <!-- Search Filter Card -->
            <div class="card border-0 shadow-sm rounded-4 mb-4">
                <div class="card-body p-3">
                    <form action="MainController" method="GET" class="row g-3 align-items-center">
                        <input type="hidden" name="action" value="ManageCustomFoods">
                        <div class="col-md-6 col-lg-4">
                            <div class="input-group">
                                <span class="input-group-text bg-white border-end-0 text-muted"><i class="fas fa-search"></i></span>
                                <input type="text" name="search" class="form-control border-start-0" placeholder="Tìm tên món ăn/nguyên liệu..." value="${requestScope.SEARCH_VALUE}">
                            </div>
                        </div>
                        <div class="col-md-2">
                            <button type="submit" class="btn btn-danger w-100 fw-bold rounded-3" style="background-color: #8b0000; border: none;">Lọc kết quả</button>
                        </div>
                        <c:if test="${not empty requestScope.SEARCH_VALUE}">
                            <div class="col-md-2">
                                <a href="MainController?action=ManageCustomFoods" class="btn btn-outline-secondary w-100 rounded-3">Xóa lọc</a>
                            </div>
                        </c:if>
                    </form>
                </div>
            </div>

            <!-- List Table Card -->
            <div class="card border-0 shadow-sm rounded-4">
                <div class="card-body p-0">
                    <div class="table-responsive">
                        <table class="table table-hover table-striped align-middle mb-0">
                            <thead class="table-dark">
                                <tr>
                                    <th class="ps-4" style="width: 80px;">ID</th>
                                    <th>Món ăn / Nguyên liệu</th>
                                    <th class="text-end">Năng lượng (Calo)</th>
                                    <th class="text-end">Đạm (Protein)</th>
                                    <th class="text-end">Tinh bột (Carbs)</th>
                                    <th class="text-end">Béo (Fat)</th>
                                    <th>Khẩu phần</th>
                                    <th>Mô tả chi tiết</th>
                                    <th class="nowrap">Ngày tạo</th>
                                    <th class="text-center pe-4" style="width: 150px;">Hành động</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:choose>
                                    <c:when test="${not empty requestScope.LIST_CUSTOM_FOODS}">
                                        <c:forEach var="food" items="${requestScope.LIST_CUSTOM_FOODS}">
                                            <tr>
                                                <td class="ps-4 fw-bold text-muted">${food.foodId}</td>
                                                <td><strong>${food.foodName}</strong></td>
                                                <td class="text-end fw-bold text-danger">${food.calories} kcal</td>
                                                <td class="text-end text-success">${food.protein} g</td>
                                                <td class="text-end text-info">${food.carbs} g</td>
                                                <td class="text-end text-warning">${food.fat} g</td>
                                                <td><span class="badge bg-secondary">${food.servingSize}</span></td>
                                                <td class="text-muted" style="max-width: 250px; overflow: hidden; text-overflow: ellipsis; white-space: nowrap;" title="${food.description}">
                                                    ${food.description}
                                                </td>
                                                <td class="nowrap text-muted" style="font-size: 0.82rem;">
                                                    <fmt:formatDate value="${food.createdAt}" pattern="dd/MM/yyyy HH:mm"/>
                                                </td>
                                                <td class="text-center pe-4 nowrap">
                                                    <button type="button" class="btn btn-outline-primary btn-sm me-1 rounded-3" 
                                                            onclick="openEditModal(${food.foodId}, '${food.foodName}', ${food.calories}, ${food.protein}, ${food.carbs}, ${food.fat}, '${food.servingSize}', '${food.description}')">
                                                        <i class="fas fa-edit"></i> Sửa
                                                    </button>
                                                    <button type="button" class="btn btn-outline-danger btn-sm rounded-3" 
                                                            onclick="confirmDelete(${food.foodId}, '${food.foodName}')">
                                                        <i class="fas fa-trash-alt"></i> Xóa
                                                    </button>
                                                </td>
                                            </tr>
                                        </c:forEach>
                                    </c:when>
                                    <c:otherwise>
                                        <tr>
                                            <td colspan="10" class="text-center py-5 text-muted">
                                                <i class="fas fa-carrot fs-1 mb-3 text-secondary"></i>
                                                <p class="mb-0 fw-bold">Không tìm thấy món ăn nào phù hợp.</p>
                                            </td>
                                        </tr>
                                    </c:otherwise>
                                </c:choose>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
        </div>

        <!-- Add & Edit Custom Food Modal -->
        <div class="modal fade" id="foodModal" tabindex="-1" aria-labelledby="foodModalLabel" aria-hidden="true">
            <div class="modal-dialog modal-dialog-centered">
                <div class="modal-content modal-content-custom">
                    <form action="MainController" method="POST" id="foodForm">
                        <!-- Required fields for routing -->
                        <input type="hidden" name="action" value="CustomFoodAction">
                        <input type="hidden" name="subAction" id="formSubAction" value="add">
                        <input type="hidden" name="foodId" id="formFoodId" value="0">
                        
                        <div class="modal-header text-white" style="background-color: #8b0000; border-radius: 16px 16px 0 0;">
                            <h5 class="modal-title fw-bold" id="foodModalLabel">Thêm món ăn mới</h5>
                            <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
                        </div>
                        <div class="modal-body p-4">
                            <div class="mb-3">
                                <label for="foodName" class="form-label fw-bold">Tên món ăn / Nguyên liệu <span class="text-danger">*</span></label>
                                <input type="text" class="form-control" id="foodName" name="foodName" required placeholder="Ví dụ: Phở bò, Ức gà...">
                            </div>
                            
                            <div class="row g-3 mb-3">
                                <div class="col-6">
                                    <label for="calories" class="form-label fw-bold">Calories (kcal) <span class="text-danger">*</span></label>
                                    <input type="number" class="form-control" id="calories" name="calories" required min="0" value="0">
                                </div>
                                <div class="col-6">
                                    <label for="servingSize" class="form-label fw-bold">Khẩu phần <span class="text-danger">*</span></label>
                                    <input type="text" class="form-control" id="servingSize" name="servingSize" required placeholder="Ví dụ: 1 tô, 100g..." value="100g">
                                </div>
                            </div>

                            <div class="row g-3 mb-3">
                                <div class="col-4">
                                    <label for="protein" class="form-label fw-bold">Đạm (Protein g)</label>
                                    <input type="number" step="0.1" class="form-control" id="protein" name="protein" min="0" value="0.0">
                                </div>
                                <div class="col-4">
                                    <label for="carbs" class="form-label fw-bold">Bột (Carbs g)</label>
                                    <input type="number" step="0.1" class="form-control" id="carbs" name="carbs" min="0" value="0.0">
                                </div>
                                <div class="col-4">
                                    <label for="fat" class="form-label fw-bold">Béo (Fat g)</label>
                                    <input type="number" step="0.1" class="form-control" id="fat" name="fat" min="0" value="0.0">
                                </div>
                            </div>

                            <div class="mb-1">
                                <label for="description" class="form-label fw-bold">Mô tả chi tiết</label>
                                <textarea class="form-control" id="description" name="description" rows="3" placeholder="Nhập nguyên liệu phụ hoặc cách làm..."></textarea>
                            </div>
                        </div>
                        <div class="modal-footer border-0 p-3">
                            <button type="button" class="btn btn-outline-secondary px-4 py-2 rounded-3" data-bs-dismiss="modal">Hủy</button>
                            <button type="submit" class="btn btn-success px-4 py-2 rounded-3 fw-bold"><i class="fas fa-save me-1"></i> Lưu thông tin</button>
                        </div>
                    </form>
                </div>
            </div>
        </div>

        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
        <script>
            var foodModal;
            document.addEventListener("DOMContentLoaded", function() {
                foodModal = new bootstrap.Modal(document.getElementById('foodModal'));
            });

            function openAddModal() {
                document.getElementById('foodModalLabel').innerText = "Thêm món ăn mới";
                document.getElementById('formSubAction').value = "add";
                document.getElementById('formFoodId').value = "0";
                
                document.getElementById('foodForm').reset();
                document.getElementById('calories').value = "0";
                document.getElementById('protein').value = "0.0";
                document.getElementById('carbs').value = "0.0";
                document.getElementById('fat').value = "0.0";
                document.getElementById('servingSize').value = "100g";

                foodModal.show();
            }

            function openEditModal(foodId, name, calories, protein, carbs, fat, servingSize, description) {
                document.getElementById('foodModalLabel').innerText = "Cập nhật món ăn";
                document.getElementById('formSubAction').value = "edit";
                document.getElementById('formFoodId').value = foodId;

                document.getElementById('foodName').value = name;
                document.getElementById('calories').value = calories;
                document.getElementById('protein').value = protein;
                document.getElementById('carbs').value = carbs;
                document.getElementById('fat').value = fat;
                document.getElementById('servingSize').value = servingSize;
                document.getElementById('description').value = description;

                foodModal.show();
            }

            function confirmDelete(foodId, foodName) {
                if (confirm("Bạn có chắc chắn muốn xóa món ăn \"" + foodName + "\" ra khỏi hệ thống không?")) {
                    window.location.href = "MainController?action=CustomFoodAction&subAction=delete&foodId=" + foodId;
                }
            }
        </script>
    </body>
</html>

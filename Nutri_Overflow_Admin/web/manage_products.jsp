<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt"%>
<!DOCTYPE html>
<html>
    <head>
        <title>Quản lý Sản phẩm & Tồn kho - NutriOverflow</title>
        <jsp:include page="includes/header.jsp" />
        <style>
            /* Custom page specific styles to enhance premium feel */
            .product-img {
                width: 50px;
                height: 50px;
                object-fit: cover;
                border-radius: 8px;
                border: 1px solid #e5e7eb;
            }
            .table-hover tbody tr:hover {
                background-color: rgba(0, 230, 118, 0.04) !important;
            }
            .stock-badge {
                font-size: 0.78rem;
                padding: 0.35em 0.65em;
                border-radius: 6px;
                font-weight: 600;
            }
            .modal-content-custom {
                border-radius: 16px;
                border: none;
                box-shadow: 0 10px 30px rgba(0,0,0,0.15);
            }
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
        <c:set var="activeTab" value="Products" scope="request" />
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
                <h3 class="fw-bold text-dark m-0"><i class="fas fa-warehouse me-2 text-danger"></i>Quản lý Sản phẩm & Tồn kho</h3>
                <button type="button" class="btn btn-success fw-bold shadow-sm px-4 py-2 rounded-pill" onclick="openAddModal()">
                    <i class="fas fa-plus-circle me-2"></i>Thêm sản phẩm mới
                </button>
            </div>

            <!-- Alerts for Success/Error -->
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

            <!-- Search, Filters and Statistics Card -->
            <div class="card border-0 shadow-sm rounded-4 p-4 mb-4">
                <form action="MainController" method="GET" class="row g-3 align-items-end">
                    <input type="hidden" name="action" value="ManageProducts" />
                    
                    <!-- Search Input -->
                    <div class="col-md-4">
                        <label class="form-label fw-bold text-secondary"><i class="fas fa-search me-1"></i> Tìm kiếm sản phẩm</label>
                        <input type="text" name="search" class="form-control border-secondary-subtle" value="${param.search}" placeholder="Nhập tên sản phẩm hoặc SKU...">
                    </div>
                    
                    <!-- Category Filter -->
                    <div class="col-md-3">
                        <label class="form-label fw-bold text-secondary"><i class="fas fa-tags me-1"></i> Danh mục</label>
                        <select name="category" class="form-select border-secondary-subtle">
                            <option value="all" ${param.category eq 'all' ? 'selected' : ''}>-- Tất cả danh mục --</option>
                            <c:forEach var="cat" items="${requestScope.LIST_CATEGORY}">
                                <option value="${cat.categoryId}" ${param.category eq cat.categoryId ? 'selected' : ''}>${cat.name}</option>
                            </c:forEach>
                        </select>
                    </div>
                    
                    <!-- Stock Level Filter -->
                    <div class="col-md-3">
                        <label class="form-label fw-bold text-secondary"><i class="fas fa-layer-group me-1"></i> Trạng thái kho</label>
                        <select name="stockFilter" class="form-select border-secondary-subtle">
                            <option value="all" ${param.stockFilter eq 'all' ? 'selected' : ''}>-- Tất cả trạng thái --</option>
                            <option value="in_stock" ${param.stockFilter eq 'in_stock' ? 'selected' : ''}>Còn hàng (> 0)</option>
                            <option value="low_stock" ${param.stockFilter eq 'low_stock' ? 'selected' : ''}>Sắp hết hàng (< 10)</option>
                            <option value="out_of_stock" ${param.stockFilter eq 'out_of_stock' ? 'selected' : ''}>Hết hàng (= 0)</option>
                        </select>
                    </div>
                    
                    <!-- Submit Button -->
                    <div class="col-md-2 d-grid">
                        <button class="btn btn-dark fw-bold py-2 shadow-sm" type="submit"><i class="fas fa-filter me-2"></i>Lọc danh sách</button>
                    </div>
                </form>
            </div>

            <!-- Product List Table Card -->
            <div class="card border-0 shadow-sm rounded-4 p-4">
                <c:choose>
                    <c:when test="${not empty requestScope.LIST_PRODUCT}">
                        <div class="table-responsive">
                            <table class="table table-hover align-middle mb-0">
                                <thead class="table-dark">
                                    <tr>
                                        <th style="width: 40px;">STT</th>
                                        <th style="width: 70px;">Hình ảnh</th>
                                        <th style="width: 100px;">Mã SKU</th>
                                        <th>Tên sản phẩm</th>
                                        <th>Giá niêm yết</th>
                                        <th>Khuyến mãi</th>
                                        <th class="text-center" style="width: 110px;">Tồn kho</th>
                                        <th>Trạng thái kho</th>
                                        <th>Kích hoạt</th>
                                        <th class="text-center" style="width: 320px;">Hành động</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <c:forEach var="prod" items="${requestScope.LIST_PRODUCT}" varStatus="counter">
                                        <tr class="${not prod.active ? 'table-secondary text-muted' : ''}">
                                            <td>${counter.count}</td>
                                            <td>
                                                <img src="${not empty prod.imageUrl ? 'image/'.concat(prod.imageUrl) : 'image/default-product.jpg'}" 
                                                     alt="${prod.name}" 
                                                     class="product-img shadow-sm" 
                                                     onerror="this.src='https://placehold.co/100x100?text=No+Image'"/>
                                            </td>
                                            <td><code class="fw-bold text-dark bg-light px-2 py-1 rounded">${prod.sku}</code></td>
                                            <td>
                                                <div class="fw-bold text-dark">${prod.name}</div>
                                                <small class="text-muted text-truncate d-inline-block" style="max-width: 250px;">${prod.description}</small>
                                                <c:if test="${not empty prod.medicalWarning}">
                                                    <div class="text-danger small mt-1"><i class="fas fa-hand-holding-medical me-1"></i><strong>Khuyên cáo:</strong> ${prod.medicalWarning}</div>
                                                </c:if>
                                            </td>
                                            <td>
                                                <span class="fw-bold text-danger">
                                                    <fmt:formatNumber value="${prod.price}" type="currency" currencySymbol="đ" maxFractionDigits="0"/>
                                                </span>
                                            </td>
                                            <td>
                                                <c:choose>
                                                    <c:when test="${prod.discountPercent > 0}">
                                                        <span class="badge bg-danger text-white">- ${prod.discountPercent}%</span>
                                                        <div class="text-muted small text-decoration-line-through">
                                                            <fmt:formatNumber value="${prod.price}" type="currency" currencySymbol="đ" maxFractionDigits="0"/>
                                                        </div>
                                                        <div class="fw-bold text-success">
                                                            <fmt:formatNumber value="${prod.discountPrice}" type="currency" currencySymbol="đ" maxFractionDigits="0"/>
                                                        </div>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <span class="text-muted small">Không có</span>
                                                    </c:otherwise>
                                                </c:choose>
                                            </td>
                                            <td class="text-center fw-bold fs-5 text-dark">${prod.quantity}</td>
                                            <td>
                                                <c:choose>
                                                    <c:when test="${prod.quantity == 0}">
                                                        <span class="badge bg-danger stock-badge"><i class="fas fa-times-circle me-1"></i>Hết hàng</span>
                                                    </c:when>
                                                    <c:when test="${prod.quantity < 10}">
                                                        <span class="badge bg-warning text-dark stock-badge"><i class="fas fa-exclamation-triangle me-1"></i>Sắp hết hàng</span>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <span class="badge bg-success stock-badge"><i class="fas fa-check-circle me-1"></i>Còn hàng</span>
                                                    </c:otherwise>
                                                </c:choose>
                                            </td>
                                            <td>
                                                <c:choose>
                                                    <c:when test="${prod.active}">
                                                        <span class="badge bg-success"><i class="fas fa-eye me-1"></i>Hiển thị</span>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <span class="badge bg-secondary"><i class="fas fa-eye-slash me-1"></i>Đang ẩn</span>
                                                    </c:otherwise>
                                                </c:choose>
                                            </td>
                                            <td class="text-center">
                                                <!-- Quick Stock Update -->
                                                <button type="button" 
                                                        class="btn btn-sm btn-outline-primary fw-bold shadow-sm px-2 rounded-pill" 
                                                        onclick="openStockModal('${prod.id}', '${prod.name}', ${prod.quantity})"
                                                        title="Cập nhật nhanh tồn kho">
                                                    <i class="fas fa-warehouse me-1"></i> Sửa kho
                                                </button>

                                                <!-- Full Product Edit -->
                                                <button type="button" 
                                                        class="btn btn-sm btn-outline-dark fw-bold shadow-sm px-2 rounded-pill ms-1"
                                                        data-id="${prod.id}"
                                                        data-sku="${prod.sku}"
                                                        data-category="${prod.categoryId}"
                                                        data-name="<c:out value="${prod.name}"/>"
                                                        data-price="${prod.price}"
                                                        data-discount="${prod.discountPercent}"
                                                        data-quantity="${prod.quantity}"
                                                        data-image="${prod.imageUrl}"
                                                        data-active="${prod.active}"
                                                        data-flash="${prod.flashSale}"
                                                        data-bestseller="${prod.bestSeller}"
                                                        data-description="<c:out value="${prod.description}"/>"
                                                        data-warning="<c:out value="${prod.medicalWarning}"/>"
                                                        onclick="openEditModal(this)"
                                                        title="Sửa tất cả thông tin sản phẩm">
                                                    <i class="fas fa-cog me-1"></i> Chi tiết
                                                </button>

                                                <!-- Toggle active state -->
                                                <c:choose>
                                                    <c:when test="${prod.active}">
                                                        <a href="MainController?action=ToggleProductActive&productId=${prod.id}&active=false&searchFilter=${param.search}&categoryFilter=${param.category}&stockFilter=${param.stockFilter}" 
                                                           class="btn btn-sm btn-outline-warning fw-bold shadow-sm px-2 rounded-pill ms-1"
                                                           onclick="return confirm('Bạn có chắc chắn muốn ẩn sản phẩm [${prod.name}] khỏi danh mục bán hàng?')"
                                                           title="Ẩn sản phẩm">
                                                            <i class="fas fa-eye-slash me-1"></i> Ẩn đi
                                                        </a>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <a href="MainController?action=ToggleProductActive&productId=${prod.id}&active=true&searchFilter=${param.search}&categoryFilter=${param.category}&stockFilter=${param.stockFilter}" 
                                                           class="btn btn-sm btn-outline-success fw-bold shadow-sm px-2 rounded-pill ms-1"
                                                           title="Hiển thị sản phẩm">
                                                            <i class="fas fa-eye me-1"></i> Hiển thị
                                                        </a>
                                                    </c:otherwise>
                                                </c:choose>
                                            </td>
                                        </tr>
                                    </c:forEach>
                                </tbody>
                            </table>
                        </div>
                    </c:when>
                    <c:otherwise>
                        <div class="text-center py-5">
                            <i class="fas fa-box-open fa-3x text-muted mb-3"></i>
                            <h5 class="text-muted">Không tìm thấy sản phẩm nào phù hợp với bộ lọc!</h5>
                            <p class="text-secondary small">Vui lòng thử thay đổi từ khóa tìm kiếm hoặc lọc trạng thái khác.</p>
                        </div>
                    </c:otherwise>
                </c:choose>
            </div>
        </div>

        <!-- Quick Stock Editing Modal -->
        <div class="modal fade" id="stockModal" tabindex="-1" aria-labelledby="stockModalLabel" aria-hidden="true">
            <div class="modal-dialog modal-dialog-centered">
                <div class="modal-content modal-content-custom">
                    <div class="modal-header bg-dark text-white border-0 py-3" style="border-top-left-radius: 16px; border-top-right-radius: 16px;">
                        <h5 class="modal-title fw-bold" id="stockModalLabel"><i class="fas fa-warehouse me-2 text-danger"></i>Cập nhật số lượng tồn kho</h5>
                        <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
                    </div>
                    <form action="MainController" method="POST">
                        <input type="hidden" name="action" value="UpdateProductStock" />
                        <input type="hidden" name="search" value="${param.search}" />
                        <input type="hidden" name="category" value="${param.category}" />
                        <input type="hidden" name="stockFilter" value="${param.stockFilter}" />
                        <input type="hidden" id="modalProductId" name="productId" />

                        <div class="modal-body p-4">
                            <div class="mb-3">
                                <label class="form-label fw-bold text-secondary">Tên sản phẩm</label>
                                <input type="text" id="modalProductName" class="form-control bg-light border-0 fw-bold" readonly />
                            </div>
                            <div class="mb-3">
                                <label class="form-label fw-bold text-secondary">Số lượng tồn kho hiện tại</label>
                                <input type="text" id="modalCurrentStock" class="form-control bg-light border-0 text-center fw-bold fs-5 text-danger" readonly />
                            </div>
                            <div class="mb-3">
                                <label for="modalNewQuantity" class="form-label fw-bold text-dark">Số lượng tồn kho mới</label>
                                <div class="input-group">
                                    <button class="btn btn-outline-secondary" type="button" onclick="adjustInputStock(-10)">-10</button>
                                    <button class="btn btn-outline-secondary" type="button" onclick="adjustInputStock(-1)">-1</button>
                                    <input type="number" id="modalNewQuantity" name="quantity" class="form-control text-center fw-bold fs-4 border-secondary-subtle" min="0" required />
                                    <button class="btn btn-outline-secondary" type="button" onclick="adjustInputStock(1)">+1</button>
                                    <button class="btn btn-outline-secondary" type="button" onclick="adjustInputStock(10)">+10</button>
                                </div>
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

        <!-- Add Product Modal -->
        <div class="modal fade" id="addProductModal" tabindex="-1" aria-labelledby="addProductModalLabel" aria-hidden="true">
            <div class="modal-dialog modal-lg modal-dialog-centered">
                <div class="modal-content modal-content-custom">
                    <div class="modal-header bg-success text-white border-0 py-3" style="border-top-left-radius: 16px; border-top-right-radius: 16px;">
                        <h5 class="modal-title fw-bold" id="addProductModalLabel"><i class="fas fa-plus-circle me-2"></i>Thêm sản phẩm mới</h5>
                        <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
                    </div>
                    <form action="MainController" method="POST" enctype="multipart/form-data">
                        <input type="hidden" name="action" value="AddProduct" />
                        <!-- Preserve current filters -->
                        <input type="hidden" name="searchFilter" value="${param.search}" />
                        <input type="hidden" name="categoryFilter" value="${param.category}" />
                        <input type="hidden" name="stockFilter" value="${param.stockFilter}" />

                        <div class="modal-body p-4 row g-3">
                            <!-- SKU & Category -->
                            <div class="col-md-6">
                                <label class="form-label fw-bold">Mã SKU <span class="text-danger">*</span></label>
                                <input type="text" name="sku" class="form-control" required placeholder="Ví dụ: PRO-01, SNA-02..." />
                            </div>
                            <div class="col-md-6">
                                <label class="form-label fw-bold">Danh mục <span class="text-danger">*</span></label>
                                <select name="categoryId" class="form-select" required>
                                    <c:forEach var="cat" items="${requestScope.LIST_CATEGORY}">
                                        <option value="${cat.categoryId}">${cat.name}</option>
                                    </c:forEach>
                                </select>
                            </div>
                            
                            <!-- Name -->
                            <div class="col-12">
                                <label class="form-label fw-bold">Tên sản phẩm <span class="text-danger">*</span></label>
                                <input type="text" name="name" class="form-control" required placeholder="Nhập tên đầy đủ sản phẩm..." />
                            </div>

                            <!-- Price, Discount, Stock -->
                            <div class="col-md-4">
                                <label class="form-label fw-bold">Giá niêm yết (VNĐ) <span class="text-danger">*</span></label>
                                <input type="number" name="price" class="form-control" min="0" required placeholder="Ví dụ: 1500000" />
                            </div>
                            <div class="col-md-4">
                                <label class="form-label fw-bold">Giảm giá (%)</label>
                                <input type="number" name="discountPercent" class="form-control" min="0" max="100" value="0" />
                            </div>
                            <div class="col-md-4">
                                <label class="form-label fw-bold">Số lượng nhập kho ban đầu</label>
                                <input type="number" name="stockQuantity" class="form-control" min="0" value="100" />
                            </div>

                            <!-- Image URL -->
                            <div class="col-12">
                                <label class="form-label fw-bold">Hình ảnh sản phẩm</label>
                                <input type="file" name="imageFile" class="form-control" accept="image/*" />
                            </div>

                            <!-- Description -->
                            <div class="col-12">
                                <label class="form-label fw-bold">Mô tả sản phẩm</label>
                                <textarea name="description" class="form-control" rows="4" placeholder="Thông tin chi tiết về sản phẩm, công dụng, hướng dẫn sử dụng..."></textarea>
                            </div>

                            <!-- Medical Warning -->
                            <div class="col-12">
                                <label class="form-label fw-bold text-danger"><i class="fas fa-hand-holding-medical me-1"></i>Khuyến cáo y tế / Lưu ý sử dụng</label>
                                <textarea name="medicalWarning" class="form-control border-danger-subtle" rows="3" placeholder="Ví dụ: Không dùng cho phụ nữ mang thai, không thay thế cho bữa ăn chính, để xa tầm tay trẻ em..."></textarea>
                            </div>

                            <!-- Flash Sale checkbox -->
                            <div class="col-md-6">
                                <div class="form-check form-switch mt-2">
                                    <input class="form-check-input" type="checkbox" name="isFlashSale" id="addIsFlashSale" />
                                    <label class="form-check-label fw-bold" for="addIsFlashSale">Đặt là sản phẩm Flash Sale (Khuyến mãi lớn)</label>
                                </div>
                            </div>
                            <!-- Best Seller checkbox -->
                            <div class="col-md-6">
                                <div class="form-check form-switch mt-2">
                                    <input class="form-check-input" type="checkbox" name="isBestSeller" id="addIsBestSeller" />
                                    <label class="form-check-label fw-bold text-warning" for="addIsBestSeller"><i class="fas fa-fire me-1"></i>Đặt là sản phẩm bán chạy (Best Seller)</label>
                                </div>
                            </div>
                        </div>
                        <div class="modal-footer border-0 p-4 pt-0 justify-content-between">
                            <button type="button" class="btn btn-outline-secondary px-4 fw-bold rounded-pill" data-bs-dismiss="modal">Hủy bỏ</button>
                            <button type="submit" class="btn btn-success px-4 fw-bold rounded-pill"><i class="fas fa-save me-1"></i> Thêm mới</button>
                        </div>
                    </form>
                </div>
            </div>
        </div>

        <!-- Edit Product Modal -->
        <div class="modal fade" id="editProductModal" tabindex="-1" aria-labelledby="editProductModalLabel" aria-hidden="true">
            <div class="modal-dialog modal-lg modal-dialog-centered">
                <div class="modal-content modal-content-custom">
                    <div class="modal-header bg-dark text-white border-0 py-3" style="border-top-left-radius: 16px; border-top-right-radius: 16px;">
                        <h5 class="modal-title fw-bold" id="editProductModalLabel"><i class="fas fa-cog me-2"></i>Chỉnh sửa thông tin sản phẩm</h5>
                        <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
                    </div>
                    <form action="MainController" method="POST" enctype="multipart/form-data">
                        <input type="hidden" name="action" value="UpdateProduct" />
                        <!-- Preserve current filters -->
                        <input type="hidden" name="searchFilter" value="${param.search}" />
                        <input type="hidden" name="categoryFilter" value="${param.category}" />
                        <input type="hidden" name="stockFilter" value="${param.stockFilter}" />
                        
                        <input type="hidden" id="editProductId" name="productId" />

                        <div class="modal-body p-4 row g-3">
                            <!-- SKU & Category -->
                            <div class="col-md-6">
                                <label class="form-label fw-bold">Mã SKU <span class="text-danger">*</span></label>
                                <input type="text" id="editSku" name="sku" class="form-control" required />
                            </div>
                            <div class="col-md-6">
                                <label class="form-label fw-bold">Danh mục <span class="text-danger">*</span></label>
                                <select id="editCategoryId" name="categoryId" class="form-select" required>
                                    <c:forEach var="cat" items="${requestScope.LIST_CATEGORY}">
                                        <option value="${cat.categoryId}">${cat.name}</option>
                                    </c:forEach>
                                </select>
                            </div>
                            
                            <!-- Name -->
                            <div class="col-12">
                                <label class="form-label fw-bold">Tên sản phẩm <span class="text-danger">*</span></label>
                                <input type="text" id="editName" name="name" class="form-control" required />
                            </div>

                            <!-- Price, Discount, Stock -->
                            <div class="col-md-4">
                                <label class="form-label fw-bold">Giá niêm yết (VNĐ) <span class="text-danger">*</span></label>
                                <input type="number" id="editPrice" name="price" class="form-control" min="0" required />
                            </div>
                            <div class="col-md-4">
                                <label class="form-label fw-bold">Giảm giá (%)</label>
                                <input type="number" id="editDiscountPercent" name="discountPercent" class="form-control" min="0" max="100" />
                            </div>
                            <div class="col-md-4">
                                <label class="form-label fw-bold">Số lượng tồn kho</label>
                                <input type="number" id="editStockQuantity" name="stockQuantity" class="form-control" min="0" />
                            </div>

                            <!-- Image URL -->
                            <div class="col-12">
                                <label class="form-label fw-bold">Hình ảnh sản phẩm (Để trống nếu giữ nguyên ảnh cũ)</label>
                                <div class="d-flex align-items-center gap-3">
                                    <input type="file" name="imageFile" class="form-control" accept="image/*" onchange="previewEditImage(this)" />
                                    <input type="hidden" id="editImageUrl" name="imageUrl" />
                                    <img id="editImagePreview" src="" class="rounded border shadow-sm" style="width: 50px; height: 50px; object-fit: cover; display: none;" />
                                </div>
                            </div>

                            <!-- Description -->
                            <div class="col-12">
                                <label class="form-label fw-bold">Mô tả sản phẩm</label>
                                <textarea id="editDescription" name="description" class="form-control" rows="4"></textarea>
                            </div>

                            <!-- Medical Warning -->
                            <div class="col-12">
                                <label class="form-label fw-bold text-danger"><i class="fas fa-hand-holding-medical me-1"></i>Khuyến cáo y tế / Lưu ý sử dụng</label>
                                <textarea id="editMedicalWarning" name="medicalWarning" class="form-control border-danger-subtle" rows="3"></textarea>
                            </div>

                            <!-- Status indicators -->
                            <div class="col-md-4">
                                <div class="form-check form-switch mt-2">
                                    <input class="form-check-input" type="checkbox" name="isFlashSale" id="editIsFlashSale" />
                                    <label class="form-check-label fw-bold" for="editIsFlashSale">Sản phẩm Flash Sale</label>
                                </div>
                            </div>
                            <div class="col-md-4">
                                <div class="form-check form-switch mt-2">
                                    <input class="form-check-input" type="checkbox" name="isBestSeller" id="editIsBestSeller" />
                                    <label class="form-check-label fw-bold text-warning" for="editIsBestSeller"><i class="fas fa-fire me-1"></i>Sản phẩm bán chạy</label>
                                </div>
                            </div>
                            <div class="col-md-4">
                                <div class="form-check form-switch mt-2">
                                    <input class="form-check-input" type="checkbox" name="isActive" id="editIsActive" />
                                    <label class="form-check-label fw-bold text-success" for="editIsActive"><i class="fas fa-eye me-1"></i>Hiển thị công khai</label>
                                </div>
                            </div>
                        </div>
                        <div class="modal-footer border-0 p-4 pt-0 justify-content-between">
                            <button type="button" 
                                    class="btn btn-outline-danger px-4 fw-bold rounded-pill" 
                                    onclick="confirmDeleteProduct()">
                                <i class="fas fa-trash-alt me-1"></i> Xóa sản phẩm
                            </button>
                            <div>
                                <button type="button" class="btn btn-outline-secondary px-4 fw-bold rounded-pill me-2" data-bs-dismiss="modal">Hủy bỏ</button>
                                <button type="submit" class="btn btn-success px-4 fw-bold rounded-pill"><i class="fas fa-save me-1"></i> Lưu thay đổi</button>
                            </div>
                        </div>
                    </form>
                </div>
            </div>
        </div>

        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
        <script>
            let stockModalObj;
            let addProductModalObj;
            let editProductModalObj;
            
            document.addEventListener("DOMContentLoaded", function() {
                stockModalObj = new bootstrap.Modal(document.getElementById('stockModal'));
                addProductModalObj = new bootstrap.Modal(document.getElementById('addProductModal'));
                editProductModalObj = new bootstrap.Modal(document.getElementById('editProductModal'));
            });

            function openStockModal(productId, productName, currentStock) {
                document.getElementById('modalProductId').value = productId;
                document.getElementById('modalProductName').value = productName;
                document.getElementById('modalCurrentStock').value = currentStock;
                document.getElementById('modalNewQuantity').value = currentStock;
                stockModalObj.show();
            }

            function openAddModal() {
                addProductModalObj.show();
            }

            function openEditModal(button) {
                document.getElementById('editProductId').value = button.dataset.id;
                document.getElementById('editSku').value = button.dataset.sku;
                document.getElementById('editCategoryId').value = button.dataset.category;
                document.getElementById('editName').value = button.dataset.name;
                document.getElementById('editPrice').value = button.dataset.price;
                document.getElementById('editDiscountPercent').value = button.dataset.discount;
                document.getElementById('editStockQuantity').value = button.dataset.quantity;
                document.getElementById('editImageUrl').value = button.dataset.image;
                document.getElementById('editIsActive').checked = button.dataset.active === 'true';
                document.getElementById('editIsFlashSale').checked = button.dataset.flash === 'true';
                document.getElementById('editIsBestSeller').checked = button.dataset.bestseller === 'true';
                document.getElementById('editDescription').value = button.dataset.description;
                document.getElementById('editMedicalWarning').value = button.dataset.warning;
                
                // Show current image preview
                const imageFilename = button.dataset.image || 'default-product.jpg';
                const previewImg = document.getElementById('editImagePreview');
                previewImg.src = 'image/' + imageFilename;
                previewImg.style.display = 'block';
                
                editProductModalObj.show();
            }

            function previewEditImage(input) {
                if (input.files && input.files[0]) {
                    const reader = new FileReader();
                    reader.onload = function(e) {
                        const preview = document.getElementById('editImagePreview');
                        preview.src = e.target.result;
                        preview.style.display = 'block';
                    }
                    reader.readAsDataURL(input.files[0]);
                }
            }

            function adjustInputStock(amount) {
                const input = document.getElementById('modalNewQuantity');
                let val = parseInt(input.value) || 0;
                val += amount;
                if (val < 0) val = 0;
                input.value = val;
            }

            function confirmDeleteProduct() {
                const productId = document.getElementById('editProductId').value;
                const productName = document.getElementById('editName').value;
                if (!productId) return;
                if (confirm('⚠️ BẠN CÓ CHẮC CHẮN MUỐN XÓA VĨNH VIỄN SẢN PHẨM?\n\nTên sản phẩm: ' + productName + '\n\nHành động này sẽ xóa toàn bộ thông tin, dữ liệu tồn kho và dữ liệu liên quan của sản phẩm khỏi hệ thống và KHÔNG THỂ KHÔI PHỤC!')) {
                    const search = encodeURIComponent('${empty param.search ? "" : param.search}');
                    const category = encodeURIComponent('${empty param.category ? "all" : param.category}');
                    const stockFilter = encodeURIComponent('${empty param.stockFilter ? "all" : param.stockFilter}');
                    window.location.href = 'MainController?action=DeleteProduct&productId=' + productId + '&searchFilter=' + search + '&categoryFilter=' + category + '&stockFilter=' + stockFilter;
                }
            }
        </script>
    </body>
</html>

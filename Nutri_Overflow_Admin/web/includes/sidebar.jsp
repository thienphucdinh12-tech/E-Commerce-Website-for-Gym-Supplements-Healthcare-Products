<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<!-- Offcanvas Sidebar -->
<div class="offcanvas offcanvas-start" tabindex="-1" id="adminSidebar" aria-labelledby="adminSidebarLabel" style="width: 280px; border-right: 2px solid #8b0000;">
    <div class="offcanvas-header text-white" style="background-color: #8b0000;">
        <h5 class="offcanvas-title fw-bold" id="adminSidebarLabel"><i class="fas fa-user-shield me-2"></i>NutriOverflow</h5>
        <button type="button" class="btn-close btn-close-white" data-bs-dismiss="offcanvas" aria-label="Close"></button>
    </div>
    <div class="offcanvas-body p-0 bg-light">
        <div class="p-3 border-bottom bg-white d-flex align-items-center">
            <div class="bg-danger text-white rounded-circle d-flex align-items-center justify-content-center fw-bold" style="width: 42px; height: 42px; font-size: 1.1rem; background-color: #8b0000 !important;">
                <i class="fas fa-user-tie"></i>
            </div>
            <div class="ms-3">
                <h6 class="mb-0 fw-bold text-dark">${sessionScope.LOGIN_USER.fullName}</h6>
                <small class="text-muted">
                    <c:choose>
                        <c:when test="${sessionScope.LOGIN_USER.roleID eq 'AD'}">Quản trị viên</c:when>
                        <c:when test="${sessionScope.LOGIN_USER.roleID eq 'MAN'}">Quản lý</c:when>
                        <c:when test="${sessionScope.LOGIN_USER.roleID eq 'CSKH'}">Nhân viên CSKH</c:when>
                        <c:when test="${sessionScope.LOGIN_USER.roleID eq 'KHO'}">Nhân viên kho</c:when>
                        <c:otherwise>Người dùng</c:otherwise>
                    </c:choose>
                </small>
            </div>
        </div>
        <ul class="nav nav-pills flex-column p-3 gap-2">
            <!-- Dashboard cho Admin và Manager -->
            <c:if test="${sessionScope.LOGIN_USER.roleID eq 'AD' or sessionScope.LOGIN_USER.roleID eq 'MAN'}">
                <li class="nav-item">
                    <span class="text-uppercase text-xs text-muted fw-bold d-block mb-1 px-3" style="font-size: 0.72rem; letter-spacing: 0.5px;">Báo cáo</span>
                </li>
                <li class="nav-item">
                    <a class="nav-link text-start py-2.5 px-3 rounded-3 d-flex align-items-center ${activeTab eq 'Dashboard' ? 'active text-white' : 'text-dark'}" href="MainController?action=ViewDashboard" style="font-size: 0.9rem;">
                        <i class="fas fa-chart-line me-3" style="width: 20px;"></i>Bảng điều khiển (Dashboard)
                    </a>
                </li>
                <hr class="my-2 text-muted">
            </c:if>

            <!-- Dropdown Quản lý cho Admin -->
            <c:if test="${sessionScope.LOGIN_USER.roleID eq 'AD'}">
                <li class="nav-item">
                    <span class="text-uppercase text-xs text-muted fw-bold d-block mb-1 px-3" style="font-size: 0.72rem; letter-spacing: 0.5px;">Hệ thống</span>
                </li>
                <li class="nav-item">
                    <a class="nav-link text-start py-2.5 px-3 rounded-3 d-flex align-items-center ${requestScope.subRole eq 'US' and activeTab eq 'Users' ? 'active text-white' : 'text-dark'}" href="MainController?action=Search&subRole=US" style="font-size: 0.9rem;">
                        <i class="fas fa-users me-3" style="width: 20px;"></i>Quản lý người dùng
                    </a>
                </li>
                <li class="nav-item">
                    <a class="nav-link text-start py-2.5 px-3 rounded-3 d-flex align-items-center ${requestScope.subRole eq 'STAFF' and activeTab eq 'Users' ? 'active text-white' : 'text-dark'}" href="MainController?action=Search&subRole=STAFF" style="font-size: 0.9rem;">
                        <i class="fas fa-user-tie me-3" style="width: 20px;"></i>Quản lý nhân viên
                    </a>
                </li>
                <hr class="my-2 text-muted">
            </c:if>
            
            <li class="nav-item">
                <span class="text-uppercase text-xs text-muted fw-bold d-block mb-1 px-3" style="font-size: 0.72rem; letter-spacing: 0.5px;">Chức năng chính</span>
            </li>
            
            <!-- Quản lý sản phẩm -->
            <c:if test="${sessionScope.LOGIN_USER.roleID eq 'AD' or sessionScope.LOGIN_USER.roleID eq 'MAN'}">
                <li class="nav-item">
                    <a class="nav-link text-start py-2.5 px-3 rounded-3 d-flex align-items-center ${activeTab eq 'Products' ? 'active text-white' : 'text-dark'}" href="MainController?action=ManageProducts" style="font-size: 0.9rem;">
                        <i class="fas fa-box-open me-3" style="width: 20px;"></i>Sản phẩm & Tồn kho
                    </a>
                </li>
                <li class="nav-item">
                    <a class="nav-link text-start py-2.5 px-3 rounded-3 d-flex align-items-center ${activeTab eq 'CustomFoods' ? 'active text-white' : 'text-dark'}" href="MainController?action=ManageCustomFoods" style="font-size: 0.9rem;">
                        <i class="fas fa-carrot me-3" style="width: 20px;"></i>Quản lý món ăn &amp; Calo
                    </a>
                </li>
            </c:if>
            
            <!-- Khuyến mãi -->
            <c:if test="${sessionScope.LOGIN_USER.roleID eq 'AD' or sessionScope.LOGIN_USER.roleID eq 'MAN'}">
                <li class="nav-item">
                    <a class="nav-link text-start py-2.5 px-3 rounded-3 d-flex align-items-center ${activeTab eq 'Campaigns' ? 'active text-white' : 'text-dark'}" href="MainController?action=ManageCampaigns" style="font-size: 0.9rem;">
                        <i class="fas fa-bullhorn me-3" style="width: 20px;"></i>Khuyến mãi & Tích điểm
                    </a>
                </li>
            </c:if>
            
            <!-- CMS -->
            <c:if test="${sessionScope.LOGIN_USER.roleID eq 'AD' or sessionScope.LOGIN_USER.roleID eq 'MAN' or sessionScope.LOGIN_USER.roleID eq 'CSKH'}">
                <li class="nav-item">
                    <a class="nav-link text-start py-2.5 px-3 rounded-3 d-flex align-items-center ${activeTab eq 'Articles' ? 'active text-white' : 'text-dark'}" href="MainController?action=ManageArticles" style="font-size: 0.9rem;">
                        <i class="fas fa-newspaper me-3" style="width: 20px;"></i>Cẩm nang & Kiến thức
                    </a>
                </li>
            </c:if>
            

            
            <!-- Đơn hàng & Đóng gói -->
            <c:if test="${sessionScope.LOGIN_USER.roleID eq 'AD' or sessionScope.LOGIN_USER.roleID eq 'MAN' or sessionScope.LOGIN_USER.roleID eq 'KHO'}">
                <li class="nav-item">
                    <a class="nav-link text-start py-2.5 px-3 rounded-3 d-flex align-items-center ${activeTab eq 'Orders' ? 'active text-white' : 'text-dark'}" href="MainController?action=ManageOrders" style="font-size: 0.9rem;">
                        <i class="fas fa-shipping-fast me-3" style="width: 20px;"></i>Đơn hàng & Đóng gói
                    </a>
                </li>
            </c:if>
            
            <!-- Quản lý hàng hoàn -->
            <c:if test="${sessionScope.LOGIN_USER.roleID eq 'AD' or sessionScope.LOGIN_USER.roleID eq 'MAN' or sessionScope.LOGIN_USER.roleID eq 'KHO'}">
                <li class="nav-item">
                    <a class="nav-link text-start py-2.5 px-3 rounded-3 d-flex align-items-center ${activeTab eq 'Returns' ? 'active text-white' : 'text-dark'}" href="MainController?action=ManageReturns" style="font-size: 0.9rem;">
                        <i class="fas fa-undo me-3" style="width: 20px;"></i>Quản lý hàng hoàn
                    </a>
                </li>
            </c:if>
            
            <!-- Quản lý lô hàng -->
            <c:if test="${sessionScope.LOGIN_USER.roleID eq 'AD' or sessionScope.LOGIN_USER.roleID eq 'MAN' or sessionScope.LOGIN_USER.roleID eq 'KHO'}">
                <li class="nav-item">
                    <a class="nav-link text-start py-2.5 px-3 rounded-3 d-flex align-items-center ${activeTab eq 'Batches' ? 'active text-white' : 'text-dark'}" href="MainController?action=ManageBatches" style="font-size: 0.9rem;">
                        <i class="fas fa-boxes me-3" style="width: 20px;"></i>Quản lý kho (Lô hàng)
                    </a>
                </li>
            </c:if>
        </ul>
    </div>
    <div class="offcanvas-footer p-3 border-top bg-white text-center">
        <a href="MainController?action=Logout" class="btn btn-outline-danger w-100 fw-bold btn-sm"><i class="fas fa-sign-out-alt me-2"></i>Đăng xuất</a>
    </div>
</div>

package controllers.admin;

import java.io.IOException;
import java.sql.Timestamp;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import shopping.CouponDAO;
import shopping.Coupon;
import user.UserDTO;

@WebServlet(name = "CouponActionController", urlPatterns = {"/CouponActionController"})
public class CouponActionController extends HttpServlet {
    
    private Timestamp parseTimestamp(String dateStr) {
        if (dateStr == null || dateStr.trim().isEmpty()) return null;
        try {
            if (dateStr.contains("T")) {
                dateStr = dateStr.replace("T", " ");
                if (dateStr.length() == 16) {
                    dateStr += ":00";
                }
                return Timestamp.valueOf(dateStr);
            } else {
                return Timestamp.valueOf(dateStr + " 23:59:59");
            }
        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }

    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("text/html;charset=UTF-8");
        request.setCharacterEncoding("UTF-8");

        HttpSession session = request.getSession(false);
        UserDTO loginUser = (session != null) ? (UserDTO) session.getAttribute("LOGIN_USER") : null;
        if (loginUser == null || (!"AD".equals(loginUser.getRoleID()) && !"MAN".equals(loginUser.getRoleID()))) {
            response.sendRedirect("admin_login.jsp");
            return;
        }

        String subAction = request.getParameter("subAction");
        CouponDAO dao = new CouponDAO();

        try {
            if ("add".equalsIgnoreCase(subAction)) {
                String code = request.getParameter("code");
                double discountAmount = Double.parseDouble(request.getParameter("discountAmount"));
                int discountPercent = Integer.parseInt(request.getParameter("discountPercent"));
                double minOrderValue = Double.parseDouble(request.getParameter("minOrderValue"));
                String usageLimitStr = request.getParameter("usageLimit");
                Integer usageLimit = (usageLimitStr != null && !usageLimitStr.isEmpty()) ? Integer.parseInt(usageLimitStr) : null;
                Timestamp expiryDate = parseTimestamp(request.getParameter("expiryDate"));

                Coupon c = new Coupon(0, code, discountAmount, discountPercent, minOrderValue, usageLimit, 0, expiryDate, true);
                boolean success = dao.insertCoupon(c);
                if (success) {
                    session.setAttribute("SUCCESS_MESSAGE", "Thêm mã giảm giá mới thành công!");
                } else {
                    session.setAttribute("ERROR_MESSAGE", "Thêm mã giảm giá thất bại (Mã có thể đã tồn tại)!");
                }

            } else if ("update".equalsIgnoreCase(subAction)) {
                int id = Integer.parseInt(request.getParameter("couponId"));
                String code = request.getParameter("code");
                double discountAmount = Double.parseDouble(request.getParameter("discountAmount"));
                int discountPercent = Integer.parseInt(request.getParameter("discountPercent"));
                double minOrderValue = Double.parseDouble(request.getParameter("minOrderValue"));
                String usageLimitStr = request.getParameter("usageLimit");
                Integer usageLimit = (usageLimitStr != null && !usageLimitStr.isEmpty()) ? Integer.parseInt(usageLimitStr) : null;
                Timestamp expiryDate = parseTimestamp(request.getParameter("expiryDate"));
                boolean active = request.getParameter("isActive") != null;

                Coupon c = new Coupon(id, code, discountAmount, discountPercent, minOrderValue, usageLimit, 0, expiryDate, active);
                boolean success = dao.updateCoupon(c);
                if (success) {
                    session.setAttribute("SUCCESS_MESSAGE", "Cập nhật mã giảm giá thành công!");
                } else {
                    session.setAttribute("ERROR_MESSAGE", "Cập nhật mã giảm giá thất bại!");
                }

            } else if ("toggleActive".equalsIgnoreCase(subAction)) {
                int id = Integer.parseInt(request.getParameter("couponId"));
                boolean active = Boolean.parseBoolean(request.getParameter("active"));
                boolean success = dao.toggleActive(id, active);
                if (success) {
                    session.setAttribute("SUCCESS_MESSAGE", "Đổi trạng thái mã giảm giá thành công!");
                } else {
                    session.setAttribute("ERROR_MESSAGE", "Đổi trạng thái mã giảm giá thất bại!");
                }

            } else if ("delete".equalsIgnoreCase(subAction)) {
                int id = Integer.parseInt(request.getParameter("couponId"));
                boolean success = dao.deleteCoupon(id);
                if (success) {
                    session.setAttribute("SUCCESS_MESSAGE", "Xóa mã giảm giá thành công!");
                } else {
                    session.setAttribute("ERROR_MESSAGE", "Xóa mã giảm giá thất bại!");
                }
            }
        } catch (Exception e) {
            log("Error at CouponActionController: " + e.toString());
            session.setAttribute("ERROR_MESSAGE", "Lỗi xử lý khuyến mãi: " + e.getMessage());
        }

        response.sendRedirect("MainController?action=ManageCampaigns");
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException { processRequest(req, resp); }
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException { processRequest(req, resp); }
}

package controllers.admin;

import com.google.gson.Gson;
import java.io.IOException;
import java.io.PrintWriter;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import shopping.AdminOrderDAO;
import shopping.AdminOrderDTO;
import user.UserDTO;

@WebServlet(name = "OrderActionController", urlPatterns = {"/OrderActionController"})
public class OrderActionController extends HttpServlet {
    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("text/html;charset=UTF-8");
        request.setCharacterEncoding("UTF-8");

        // General Security Check: Allow AD, MAN, KHO
        HttpSession session = request.getSession(false);
        UserDTO loginUser = (session != null) ? (UserDTO) session.getAttribute("LOGIN_USER") : null;
        if (loginUser == null || (!"AD".equals(loginUser.getRoleID()) 
                && !"MAN".equals(loginUser.getRoleID()) 
                && !"KHO".equals(loginUser.getRoleID()))) {
            response.sendRedirect("admin_login.jsp");
            return;
        }

        String subAction = request.getParameter("subAction");
        AdminOrderDAO dao = new AdminOrderDAO();

        try {
            if ("getDetails".equalsIgnoreCase(subAction)) {
                // Fetch JSON details of the order for JS scan simulator
                String orderIdStr = request.getParameter("orderId");
                if (orderIdStr != null) {
                    int orderId = Integer.parseInt(orderIdStr);
                    AdminOrderDTO order = dao.getOrderById(orderId);
                    if (order != null) {
                        response.setContentType("application/json;charset=UTF-8");
                        Gson gson = new Gson();
                        String json = gson.toJson(order);
                        try (PrintWriter out = response.getWriter()) {
                            out.print(json);
                            out.flush();
                        }
                        return; // Prevent forward/redirect below
                    }
                }
                response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Order not found");
                return;
            }
            else if ("handover".equalsIgnoreCase(subAction)) {
                // Confirm packing and hand over to delivery partner (GHN)
                int orderId = Integer.parseInt(request.getParameter("orderId"));
                String ghnOrderCode = request.getParameter("ghnOrderCode");
                try {
                    if (ghnOrderCode == null || ghnOrderCode.trim().isEmpty()) {
                        ghnOrderCode = utils.GHNService.createGHNOrderFromDB(orderId);
                    }

                    if (ghnOrderCode != null && dao.updateOrderHandover(orderId, ghnOrderCode.trim())) {
                        if (session != null) {
                            session.setAttribute("SUCCESS_MESSAGE", "Đã đóng gói & bàn giao đơn hàng #" + orderId + " cho GHN thành công! Mã vận đơn: " + ghnOrderCode);
                        }
                    } else {
                        if (session != null) {
                            session.setAttribute("ERROR_MESSAGE", "Có lỗi xảy ra khi bàn giao đơn hàng #" + orderId);
                        }
                    }
                } catch (Exception ghnEx) {
                    log("GHN Order Creation Error: " + ghnEx.getMessage());
                    if (session != null) {
                        session.setAttribute("ERROR_MESSAGE", "Tạo đơn GHN thất bại: " + ghnEx.getMessage());
                    }
                }
                response.sendRedirect("MainController?action=ManageOrders");
                return;
            } 
            else if ("updateStatus".equalsIgnoreCase(subAction)) {
                // Manual status override (Shopee-style) - strictly restricted to AD and MAN
                if (!"AD".equals(loginUser.getRoleID()) && !"MAN".equals(loginUser.getRoleID())) {
                    if (session != null) {
                        session.setAttribute("ERROR_MESSAGE", "Quyền hạn của bạn (Nhân viên kho) không được phép đổi trạng thái thủ công!");
                    }
                    response.sendRedirect("MainController?action=ManageOrders");
                    return;
                }

                int orderId = Integer.parseInt(request.getParameter("orderId"));
                String status = request.getParameter("status");

                if (dao.updateOrderStatus(orderId, status)) {
                    String ghnNotice = "";
                    if ("PROCESSING".equalsIgnoreCase(status) || "SHIPPING".equalsIgnoreCase(status)) {
                        try {
                            String ghnCode = utils.GHNService.createGHNOrderFromDB(orderId);
                            if (ghnCode != null && !ghnCode.isEmpty()) {
                                dao.updateOrderHandover(orderId, ghnCode);
                                ghnNotice = " (Mã vận đơn GHN: " + ghnCode + ")";
                            }
                        } catch (Exception ghnEx) {
                            log("GHN Auto-create Error on status update: " + ghnEx.getMessage());
                            ghnNotice = " (Lưu ý: chưa tạo được đơn GHN - " + ghnEx.getMessage() + ")";
                        }
                    }
                    if (session != null) {
                        session.setAttribute("SUCCESS_MESSAGE", "Cập nhật trạng thái đơn hàng #" + orderId + " thành công!" + ghnNotice);
                    }
                } else {
                    if (session != null) {
                        session.setAttribute("ERROR_MESSAGE", "Thao tác cập nhật trạng thái đơn hàng #" + orderId + " thất bại!");
                    }
                }
                response.sendRedirect("MainController?action=ManageOrders");
                return;
            }
        } catch (Exception e) {
            log("Error at OrderActionController: " + e.toString());
            if (session != null) {
                session.setAttribute("ERROR_MESSAGE", "Đã xảy ra lỗi hệ thống: " + e.getMessage());
            }
            response.sendRedirect("MainController?action=ManageOrders");
        }
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException { processRequest(req, resp); }
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException { processRequest(req, resp); }
}

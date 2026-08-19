package controllers.admin;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import shopping.ReturnItemDTO;
import shopping.ReturnLogisticsDAO;
import user.UserDTO;

@WebServlet(name = "ReturnActionController", urlPatterns = {"/ReturnActionController"})
public class ReturnActionController extends HttpServlet {
    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("text/html;charset=UTF-8");
        request.setCharacterEncoding("UTF-8");

        HttpSession session = request.getSession(false);
        UserDTO loginUser = (session != null) ? (UserDTO) session.getAttribute("LOGIN_USER") : null;
        if (loginUser == null || (!"AD".equals(loginUser.getRoleID()) 
                && !"MAN".equals(loginUser.getRoleID()) 
                && !"KHO".equals(loginUser.getRoleID()))) {
            response.sendRedirect("admin_login.jsp");
            return;
        }

        try {
            String orderIdStr = request.getParameter("orderId");
            if (orderIdStr != null && !orderIdStr.trim().isEmpty()) {
                int orderId = Integer.parseInt(orderIdStr);
                String[] productIds = request.getParameterValues("productId");
                String[] quantities = request.getParameterValues("quantity");
                String[] conditions = request.getParameterValues("condition");
                String[] actions = request.getParameterValues("action");
                String[] notes = request.getParameterValues("notes");

                List<ReturnItemDTO> returnItems = new ArrayList<>();
                if (productIds != null) {
                    for (int i = 0; i < productIds.length; i++) {
                        int productId = Integer.parseInt(productIds[i]);
                        int quantity = Integer.parseInt(quantities[i]);
                        String condition = conditions[i];
                        String action = actions[i];
                        String note = (notes != null && notes.length > i) ? notes[i] : "";

                        ReturnItemDTO item = new ReturnItemDTO();
                        item.setProductId(productId);
                        item.setQuantity(quantity);
                        item.setCondition(condition);
                        item.setAction(action);
                        item.setNotes(note);
                        returnItems.add(item);
                    }
                }

                ReturnLogisticsDAO dao = new ReturnLogisticsDAO();
                boolean success = dao.processOrderReturn(orderId, returnItems, loginUser.getUserID());
                if (success) {
                    if (session != null) {
                        session.setAttribute("SUCCESS_MESSAGE", "Xử lý hàng hoàn cho đơn hàng #" + orderId + " thành công!");
                    }
                } else {
                    if (session != null) {
                        session.setAttribute("ERROR_MESSAGE", "Xử lý hàng hoàn cho đơn hàng #" + orderId + " thất bại!");
                    }
                }
            } else {
                if (session != null) {
                    session.setAttribute("ERROR_MESSAGE", "Mã đơn hàng không hợp lệ!");
                }
            }
        } catch (Exception e) {
            log("Error at ReturnActionController: " + e.toString());
            if (session != null) {
                session.setAttribute("ERROR_MESSAGE", "Đã xảy ra lỗi: " + e.getMessage());
            }
        }
        response.sendRedirect("MainController?action=ManageReturns");
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException { processRequest(req, resp); }
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException { processRequest(req, resp); }
}

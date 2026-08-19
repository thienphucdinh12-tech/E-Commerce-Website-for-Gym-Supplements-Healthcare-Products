package controllers.cart;

import java.io.IOException;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import shopping.OrderHistory;
import shopping.OrderHistoryDAO;
import shopping.UnpaidOrderCountDAO;
import user.UserDTO;

@WebServlet(name = "OrderHistoryController", urlPatterns = {"/OrderHistoryController", "/don-hang"})
public class OrderHistoryController extends HttpServlet {

    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setContentType("text/html;charset=UTF-8");

        // Security: must be logged in
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("LOGIN_USER") == null) {
            response.sendRedirect("dang-nhap");
            return;
        }

        UserDTO loginUser = (UserDTO) session.getAttribute("LOGIN_USER");
        String username = loginUser.getUserID();

        try {
            String orderIdParam = request.getParameter("orderId");
            OrderHistoryDAO dao = new OrderHistoryDAO();

            if (orderIdParam != null && !orderIdParam.trim().isEmpty()) {
                // ── Detail view for a specific order ──
                int orderId = Integer.parseInt(orderIdParam.trim());
                OrderHistory order = dao.getOrderDetail(orderId, username);
                if (order == null) {
                    request.setAttribute("ERROR", "Order #" + orderId + " not found.");
                    request.getRequestDispatcher("orderHistory.jsp").forward(request, response);
                    return;
                }
                request.setAttribute("ORDER_DETAIL", order);
            } else {
                // ── List view: all orders ──
                List<OrderHistory> orders = dao.getOrdersByUsername(username);
                request.setAttribute("ORDER_LIST", orders);
            }

            // Always refresh the FAILED badge count when visiting My Orders
            UnpaidOrderCountDAO countDAO = new UnpaidOrderCountDAO();
            int failedCount = countDAO.getFailedOrderCount(username);
            session.setAttribute("FAILED_ORDER_COUNT", failedCount);

        } catch (Exception e) {
            log("Error at OrderHistoryController: " + e.toString());
            request.setAttribute("ERROR", "An error occurred, please try again.");
        }

        request.getRequestDispatcher("orderHistory.jsp").forward(request, response);
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException { processRequest(req, resp); }
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException { processRequest(req, resp); }
}

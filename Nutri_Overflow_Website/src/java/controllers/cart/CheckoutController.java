package controllers.cart;

import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

/**
 * CheckoutController — now just a thin redirect to the Order Confirmation page.
 * All checkout logic (address, coupon, payment method, order creation) has been
 * moved to OrderConfirmController.
 */
@WebServlet(name = "CheckoutController", urlPatterns = {"/CheckoutController"})
public class CheckoutController extends HttpServlet {

    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Guard: must be logged in
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("LOGIN_USER") == null) {
            request.setAttribute("ERROR_MESSAGE", "Please login to proceed with checkout!");
            request.getRequestDispatcher("login.jsp").forward(request, response);
            return;
        }
        user.UserDTO user = (user.UserDTO) session.getAttribute("LOGIN_USER");
        if (!"US".equals(user.getRoleID())) {
            request.setAttribute("ERROR_MESSAGE", "Chỉ tài khoản khách hàng mới có thể thực hiện thanh toán!");
            request.getRequestDispatcher("viewCart.jsp").forward(request, response);
            return;
        }
        // Delegate everything to the new confirmation page
        response.sendRedirect("OrderConfirmController");
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException { processRequest(req, resp); }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException { processRequest(req, resp); }
}
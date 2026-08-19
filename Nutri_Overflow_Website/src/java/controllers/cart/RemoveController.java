package controllers.cart;

import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import shopping.Cart;

@WebServlet(name = "RemoveController", urlPatterns = {"/RemoveController"})
public class RemoveController extends HttpServlet {
    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            String id = request.getParameter("id");
            HttpSession session = request.getSession();
            Cart cart = (Cart) session.getAttribute("CART");
            
            if (cart != null && cart.remove(id)) {
                session.setAttribute("CART", cart);
            }
        } catch (Exception e) {
            log("Error at RemoveController: " + e.toString());
        } finally {
            request.getRequestDispatcher("viewCart.jsp").forward(request, response);
        }
    }
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException { processRequest(req, resp); }
}
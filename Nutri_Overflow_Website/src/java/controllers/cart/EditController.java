package controllers.cart;

import java.io.IOException;
import static java.rmi.server.LogStream.log;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import shopping.Cart;

@WebServlet(name = "EditController", urlPatterns = {"/EditController"})
public class EditController extends HttpServlet {
    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            String id = request.getParameter("id");
            int quantity = Integer.parseInt(request.getParameter("quantity"));
            HttpSession session = request.getSession();
            Cart cart = (Cart) session.getAttribute("CART");
            if (cart != null && quantity > 0) {
                shopping.ProductDAO dao = new shopping.ProductDAO();
                shopping.Product dbProduct = dao.getProductById(id);
                
                if (dbProduct != null) {
                    if (quantity > dbProduct.getQuantity()) {
                        request.setAttribute("ERROR_MESSAGE", "Cannot update to " + quantity + ". Only " + dbProduct.getQuantity() + " available in stock for " + dbProduct.getName() + "!");
                    } else {
                        cart.edit(id, quantity);
                        session.setAttribute("CART", cart);
                        request.setAttribute("MESSAGE", "Updated quantity for " + dbProduct.getName() + " successfully!");
                    }
                }
            }
        } catch (Exception e) {
            log("Error at EditController: " + e.toString());
        } finally {
            request.getRequestDispatcher("viewCart.jsp").forward(request, response);
        }
    }
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException { processRequest(req, resp); }
}
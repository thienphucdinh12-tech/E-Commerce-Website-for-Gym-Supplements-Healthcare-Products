package controllers.auth;

import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import shopping.Cart;
import shopping.CartPersistenceDAO;
import user.UserDTO;

@WebServlet(name = "LogoutController", urlPatterns = {"/LogoutController", "/dang-xuat"})
public class LogoutController extends HttpServlet {
    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            HttpSession session = request.getSession(false);
            if (session != null) {
                // ── Save cart to DB before destroying the session ──────────────────────
                try {
                    UserDTO loginUser = (UserDTO) session.getAttribute("LOGIN_USER");
                    Cart    cart      = (Cart)    session.getAttribute("CART");
                    if (loginUser != null) {
                        CartPersistenceDAO cartDAO = new CartPersistenceDAO();
                        cartDAO.saveCart(loginUser.getUserID(), cart);
                    }
                } catch (Exception ex) {
                    log("CartPersistenceDAO.saveCart failed on logout: " + ex.toString());
                    // Non-fatal: proceed with logout anyway
                }
                // ── Invalidate session ─────────────────────────────────────────────────
                session.invalidate();
            }
        } catch (Exception e) {
            log("Error at LogoutController: " + e.toString());
        } finally {
            response.sendRedirect("cua-hang");
        }
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException { processRequest(req, resp); }
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException { processRequest(req, resp); }
}
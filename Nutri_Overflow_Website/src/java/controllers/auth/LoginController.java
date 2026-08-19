package controllers.auth;

import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import user.UserDAO;
import user.UserDTO;
import shopping.Cart;
import shopping.CartPersistenceDAO;
import shopping.UnpaidOrderCountDAO;

@WebServlet(name = "LoginController", urlPatterns = {"/LoginController", "/dang-nhap"})
public class LoginController extends HttpServlet {
    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String url = "login.jsp";
        
        try {
            String userID = request.getParameter("userID");
            String password = request.getParameter("password");
            
            HttpSession session = request.getSession();
            
            UserDAO dao = new UserDAO();
            UserDTO loginUser = null;
            try {
                loginUser = dao.checkLogin(userID, password);
            } catch (java.sql.SQLException ex) {
                if ("BANNED".equals(ex.getMessage())) {
                    request.setAttribute("ERROR_MESSAGE", "Tài khoản của bạn đã bị khóa!");
                } else {
                    throw ex;
                }
            }
            if (loginUser != null) {
                session.setAttribute("LOGIN_USER", loginUser);

                // ── Restore persisted cart from DB ─────────────────────────────────────
                try {
                    CartPersistenceDAO cartDAO = new CartPersistenceDAO();
                    Cart savedCart = cartDAO.loadCart(loginUser.getUserID());
                    if (savedCart != null && !savedCart.getCart().isEmpty()) {
                        // Merge with any in-session guest cart (in-session takes priority per item)
                        Cart guestCart = (Cart) session.getAttribute("CART");
                        if (guestCart != null && !guestCart.getCart().isEmpty()) {
                            // Add saved items that are NOT already in the guest cart
                            for (shopping.Product p : savedCart.getCart().values()) {
                                if (!guestCart.getCart().containsKey(p.getId())) {
                                    guestCart.add(p);
                                }
                            }
                        } else {
                            session.setAttribute("CART", savedCart);
                        }
                    }
                } catch (Exception ex) {
                    log("CartPersistenceDAO.loadCart failed on login: " + ex.toString());
                    // Non-fatal: continue without restored cart
                }

                // Clear all unread notifications on login per user requirement
                notifications.OrderNotificationDAO notifDAO = new notifications.OrderNotificationDAO();
                notifDAO.markAllRead(loginUser.getUserID());
                session.setAttribute("UNREAD_NOTIF_COUNT", 0);
                session.setAttribute("FAILED_ORDER_COUNT", 0);

                // Save merged cart back to DB
                try {
                    Cart currentCart = (Cart) session.getAttribute("CART");
                    CartPersistenceDAO cartDAO = new CartPersistenceDAO();
                    cartDAO.saveCart(loginUser.getUserID(), currentCart);
                } catch (Exception ex) {
                    log("CartPersistenceDAO.saveCart failed on login: " + ex.toString());
                }

                // Check if a specific redirect URL was saved (e.g. from guest add-to-cart or product detail)
                String redirectUrl = (String) session.getAttribute("REDIRECT_URL");
                if (redirectUrl != null && !redirectUrl.trim().isEmpty()) {
                    session.removeAttribute("REDIRECT_URL");
                    url = redirectUrl;
                } else {
                    url = "cua-hang";
                }
            } else {
                request.setAttribute("ERROR_MESSAGE", "Tên đăng nhập hoặc mật khẩu không chính xác!");
            }
        } catch (Exception e) {
            log("Error at LoginController: " + e.toString());
        } finally {
            if (url.equals("login.jsp")) {
                request.getRequestDispatcher(url).forward(request, response);
            } else {
                response.sendRedirect(url);
            }
        }
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException { processRequest(req, resp); }
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException { processRequest(req, resp); }
}
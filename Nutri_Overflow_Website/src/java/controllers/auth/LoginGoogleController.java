package controllers.auth;

import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import user.UserDAO;
import user.UserDTO;
import utils.GoogleUtils;
import utils.GoogleUtils.GoogleUser;
import shopping.Cart;
import shopping.CartPersistenceDAO;
import shopping.UnpaidOrderCountDAO;

@WebServlet(name = "LoginGoogleController", urlPatterns = {"/LoginGoogleController"})
public class LoginGoogleController extends HttpServlet {

    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setContentType("text/html;charset=UTF-8");

        // Construct redirect URI dynamically based on the current request
        String scheme = request.getScheme();
        String serverName = request.getServerName();
        int serverPort = request.getServerPort();
        String contextPath = request.getContextPath();
        String portPart = (serverPort == 80 || serverPort == 443) ? "" : (":" + serverPort);
        String redirectUri = scheme + "://" + serverName + portPart + contextPath + "/LoginGoogleController";

        String code = request.getParameter("code");

        // Step 1: If no authorization code, redirect to Google consent screen
        if (code == null || code.trim().isEmpty()) {
            String authorizeUrl = GoogleUtils.buildAuthorizeUrl(redirectUri);
            if (authorizeUrl.isEmpty()) {
                request.setAttribute("ERROR_MESSAGE", "Không cấu hình được URL đăng nhập Google!");
                request.getRequestDispatcher("login.jsp").forward(request, response);
            } else {
                response.sendRedirect(authorizeUrl);
            }
            return;
        }

        // Step 2: Google redirected back with authorization code
        String url = "login.jsp";
        try {
            // Exchange code for Access Token
            String accessToken = GoogleUtils.getToken(code, redirectUri);
            
            // Get user profile from Google
            GoogleUser googleUser = GoogleUtils.getUserInfo(accessToken);
            
            if (googleUser != null && googleUser.getId() != null) {
                // Generate a unique userID based on Google's persistent sub ID
                String username = "google_" + googleUser.getId();
                
                UserDAO dao = new UserDAO();
                UserDTO loginUser = null;
                boolean isBanned = false;
                try {
                    loginUser = dao.checkGoogleLogin(username);
                } catch (java.sql.SQLException ex) {
                    if ("BANNED".equals(ex.getMessage())) {
                        isBanned = true;
                        request.setAttribute("ERROR_MESSAGE", "Tài khoản của bạn đã bị khóa!");
                    } else {
                        throw ex;
                    }
                }
                
                if (!isBanned) {
                    // If user doesn't exist, auto-register them
                    if (loginUser == null) {
                        UserDTO newUser = new UserDTO(username, googleUser.getName(), "US", "GoogleLoginPlaceholderPassword");
                        boolean registered = dao.insert(newUser);
                        if (registered) {
                            try {
                                loginUser = dao.checkGoogleLogin(username);
                            } catch (java.sql.SQLException ex) {
                                if ("BANNED".equals(ex.getMessage())) {
                                    request.setAttribute("ERROR_MESSAGE", "Tài khoản của bạn đã bị khóa!");
                                } else {
                                    throw ex;
                                }
                            }
                        }
                    }
                }
                
                if (loginUser != null) {
                    HttpSession session = request.getSession();
                    session.setAttribute("LOGIN_USER", loginUser);
                    
                    // ── Restore persisted cart from DB (like regular login) ────────────────
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
                        log("CartPersistenceDAO.loadCart failed on Google login: " + ex.toString());
                    }

                    // Clear all unread notifications on Google login per user requirement
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
                        log("CartPersistenceDAO.saveCart failed on Google login: " + ex.toString());
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
                    request.setAttribute("ERROR_MESSAGE", "Không thể tự động tạo tài khoản Google!");
                }
            } else {
                request.setAttribute("ERROR_MESSAGE", "Không lấy được thông tin tài khoản từ Google!");
            }
        } catch (Exception e) {
            log("Error at LoginGoogleController: " + e.toString());
            request.setAttribute("ERROR_MESSAGE", "Lỗi xác thực Google: " + e.getMessage());
        } finally {
            if (url.equals("login.jsp")) {
                request.getRequestDispatcher(url).forward(request, response);
            } else {
                response.sendRedirect(url);
            }
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        processRequest(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        processRequest(request, response);
    }
}

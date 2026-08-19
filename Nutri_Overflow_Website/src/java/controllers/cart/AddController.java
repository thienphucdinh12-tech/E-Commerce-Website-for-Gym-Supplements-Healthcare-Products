package controllers.cart;

import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import shopping.Cart;
import shopping.Product;

@WebServlet(name = "AddController", urlPatterns = {"/AddController"})
public class AddController extends HttpServlet {
    
    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("text/html;charset=UTF-8");
        String url = "ShoppingController"; 
        
        try {
            String productId = request.getParameter("productId");
            if (productId != null && !productId.trim().isEmpty()) {
                url = "MainController?action=Detail&id=" + productId.trim();
                int quantity = Integer.parseInt(request.getParameter("quantity"));

                shopping.ProductDAO dao = new shopping.ProductDAO();
                Product dbProduct = dao.getProductById(productId);
                
                if (dbProduct != null) {
                    HttpSession session = request.getSession();
                    Cart cart = (Cart) session.getAttribute("CART");
                    if (cart == null) {
                        cart = new Cart();
                    }

                    // Check stock limit
                    int existingQuantity = 0;
                    if (cart.getCart() != null && cart.getCart().containsKey(productId)) {
                        existingQuantity = cart.getCart().get(productId).getQuantity();
                    }
                    
                    if (existingQuantity + quantity > dbProduct.getQuantity()) {
                        request.setAttribute("ERROR_MESSAGE", "Không thể thêm " + quantity + " sản phẩm. Chỉ còn lại " + (dbProduct.getQuantity() - existingQuantity) + " sản phẩm trong kho!");
                    } else {
                        // Create a specific product instance for the cart
                        Product cartProduct = new Product();
                        cartProduct.setId(dbProduct.getId());
                        cartProduct.setName(dbProduct.getName());
                        double price = dbProduct.getPrice();
                        if (dbProduct.getDiscountPrice() != null && dbProduct.getDiscountPrice() > 0) {
                            price = dbProduct.getDiscountPrice();
                        }
                        cartProduct.setPrice(price);
                        cartProduct.setQuantity(quantity);
                        cartProduct.setImageUrl(dbProduct.getImageUrl());

                        if (cart.add(cartProduct)) {
                            session.setAttribute("CART", cart);
                            request.setAttribute("MESSAGE", "Đã thêm thành công " + quantity + " " + cartProduct.getName() + " vào giỏ hàng!");

                            // Save notification for logged in user
                            user.UserDTO userObj = (user.UserDTO) session.getAttribute("LOGIN_USER");
                            if (userObj != null) {
                                notifications.OrderNotificationDAO notifDAO = new notifications.OrderNotificationDAO();
                                notifDAO.save(userObj.getUserID(), 0, "CART_ADD", "Đã thêm vào giỏ hàng", "Đã thêm thành công " + quantity + " x " + cartProduct.getName() + " vào giỏ hàng!");
                                session.setAttribute("UNREAD_NOTIF_COUNT", notifDAO.countUnread(userObj.getUserID()));
                            }
                        }
                    }

                    // Check if user is logged in (Guest redirect requirement)
                    Object loginUser = session.getAttribute("LOGIN_USER");
                    if (loginUser == null) {
                        session.setAttribute("REDIRECT_URL", url);
                        request.setAttribute("ERROR_MESSAGE", "Vui lòng đăng nhập để tiếp tục mua hàng!");
                        
                        String ajax = request.getParameter("ajax");
                        if ("true".equals(ajax)) {
                            response.setContentType("application/json;charset=UTF-8");
                            response.getWriter().write("{\"success\":false, \"redirect\":\"login.jsp\", \"message\":\"Vui lòng đăng nhập để tiếp tục!\"}");
                            return;
                        }
                        url = "login.jsp";
                    }
                }
            }
            
            // AJAX check
            String ajax = request.getParameter("ajax");
            if ("true".equals(ajax)) {
                response.setContentType("application/json;charset=UTF-8");
                String error = (String) request.getAttribute("ERROR_MESSAGE");
                if (error != null) {
                    response.getWriter().write("{\"success\":false, \"message\":\"" + error + "\"}");
                } else {
                    HttpSession session = request.getSession();
                    Cart cart = (Cart) session.getAttribute("CART");
                    int cartCount = (cart != null && cart.getCart() != null) ? cart.getCart().size() : 0;
                    response.getWriter().write("{\"success\":true, \"message\":\"Đã thêm sản phẩm vào giỏ hàng!\", \"cartCount\":" + cartCount + "}");
                }
                return;
            }
        } catch (Exception e) {
            log("Error at AddController: " + e.toString());
        } finally {
            if (!"true".equals(request.getParameter("ajax"))) {
                request.getRequestDispatcher(url).forward(request, response);
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
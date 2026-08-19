package controllers.cart;

import java.io.IOException;
import java.io.PrintWriter;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import shopping.Cart;
import shopping.CouponDAO;
import shopping.CouponDTO;
import shopping.OrderDAO;
import shopping.OrderHistoryDAO;
import shopping.OrderHistory;
import shopping.UnpaidOrderCountDAO;
import user.UserDAO;
import VNpay.VNPayService;
import utils.GHNService;
import com.google.gson.JsonArray;
import com.google.gson.JsonObject;
import user.UserDTO;

/**
 * OrderConfirmController — Checkout Confirmation page handler.
 *
 * GET  (action=Checkout from viewCart)  → load profile address, forward to orderConfirm.jsp
 * POST action=ValidateCoupon (AJAX)     → JSON response {valid, discountPct, errorMsg}
 * POST action=PlaceOrder                → create order, then COD redirect or VNPay redirect
 */
@WebServlet(name = "OrderConfirmController", urlPatterns = {"/OrderConfirmController", "/thanh-toan"})
public class OrderConfirmController extends HttpServlet {

    private final VNPayService    vnPayService = new VNPayService();
    private final OrderHistoryDAO historyDAO   = new OrderHistoryDAO();
    private final CouponDAO       couponDAO    = new CouponDAO();
    private final UserDAO         userDAO      = new UserDAO();

    // ── GET: show confirmation page ────────────────────────────────────────
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("text/html;charset=UTF-8");

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("LOGIN_USER") == null) {
            response.sendRedirect("dang-nhap");
            return;
        }

        UserDTO sessionUser = (UserDTO) session.getAttribute("LOGIN_USER");
        if (!"US".equals(sessionUser.getRoleID())) {
            request.setAttribute("ERROR_MESSAGE", "Chỉ tài khoản khách hàng mới có thể thực hiện đặt hàng!");
            request.getRequestDispatcher("viewCart.jsp").forward(request, response);
            return;
        }

        Cart cart = (Cart) session.getAttribute("CART");
        if (cart == null || cart.getCart().isEmpty()) {
            response.sendRedirect("gio-hang");
            return;
        }

        // Load full profile to pre-fill shipping address
        UserDTO profile = userDAO.getUserProfile(sessionUser.getUserID());
        if (profile == null) profile = sessionUser;

        request.setAttribute("PROFILE", profile);
        request.setAttribute("CART", cart);
        request.getRequestDispatcher("orderConfirm.jsp").forward(request, response);
    }

    // ── POST: ValidateCoupon (AJAX) or PlaceOrder ──────────────────────────
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("LOGIN_USER") == null) {
            response.sendRedirect("dang-nhap");
            return;
        }

        UserDTO user = (UserDTO) session.getAttribute("LOGIN_USER");
        if (!"US".equals(user.getRoleID())) {
            request.setAttribute("ERROR_MESSAGE", "Chỉ tài khoản khách hàng mới có thể thực hiện đặt hàng!");
            request.getRequestDispatcher("viewCart.jsp").forward(request, response);
            return;
        }

        String action = request.getParameter("action");
        if ("ValidateCoupon".equals(action)) {
            handleValidateCoupon(request, response, session);
        } else if ("PlaceOrder".equals(action)) {
            handlePlaceOrder(request, response, session);
        } else if ("CalculateShipping".equals(action)) {
            handleCalculateShipping(request, response);
        } else {
            response.sendRedirect("thanh-toan");
        }
    }

    // ── Coupon AJAX validation ─────────────────────────────────────────────
    private void handleValidateCoupon(HttpServletRequest request,
                                      HttpServletResponse response,
                                      HttpSession session) throws IOException {
        response.setContentType("application/json;charset=UTF-8");
        String code = request.getParameter("couponCode");
        CouponDTO result = couponDAO.validate(code);

        // Calculate discount preview using cart total
        double discountAmount = 0;
        Cart cart = (Cart) session.getAttribute("CART");
        if (cart != null && result.isValid()) {
            discountAmount = result.calcDiscount(cart.getTotal());
        }

        PrintWriter out = response.getWriter();
        out.print("{");
        out.print("\"valid\":" + result.isValid() + ",");
        out.print("\"discountPct\":" + result.getDiscountPct() + ",");
        out.print("\"discountAmount\":" + discountAmount + ",");
        out.print("\"errorMsg\":\"" + escapeJson(result.getErrorMsg()) + "\"");
        out.print("}");
    }

    // ── Shipping API (Mock) ────────────────────────────────────────────────
    private void handleCalculateShipping(HttpServletRequest request, HttpServletResponse response) throws IOException {
        response.setContentType("application/json;charset=UTF-8");
        HttpSession session = request.getSession(false);
        double fee = 30000; // Default fallback
        try {
            int toDistrictId = Integer.parseInt(request.getParameter("districtId"));
            String toWardCode = request.getParameter("wardCode");
            
            int totalWeight = 500; // default 500g
            if (session != null) {
                Cart cart = (Cart) session.getAttribute("CART");
                if (cart != null) {
                    totalWeight = cart.getCart().size() * 500; // 500g per item type for example
                }
            }
            fee = GHNService.calculateFee(toDistrictId, toWardCode, totalWeight);
        } catch (Exception e) {
            log("Calculate fee error: " + e.getMessage());
        }
        
        PrintWriter out = response.getWriter();
        out.print("{\"shippingFee\":" + fee + "}");
    }

    // ── Place Order ────────────────────────────────────────────────────────
    private void handlePlaceOrder(HttpServletRequest request,
                                  HttpServletResponse response,
                                  HttpSession session) throws ServletException, IOException {
        UserDTO user = (UserDTO) session.getAttribute("LOGIN_USER");
        Cart    cart = (Cart)    session.getAttribute("CART");

        if (cart == null || cart.getCart().isEmpty()) {
            response.sendRedirect("MainController?action=ViewCart");
            return;
        }

        // Read form parameters
        String shippingAddress = trim(request.getParameter("shippingAddress"));
        String couponCode      = trim(request.getParameter("couponCode")).toUpperCase();
        String paymentMethod   = trim(request.getParameter("paymentMethod"));
        if (paymentMethod.isEmpty()) paymentMethod = "VNPAY";

        String ghnDistrictIdStr = trim(request.getParameter("districtId"));
        String ghnWardCode = trim(request.getParameter("wardCode"));
        String recipientPhone = trim(request.getParameter("recipientPhone"));
        
        double shippingFee = 0;
        try {
            shippingFee = Double.parseDouble(request.getParameter("shippingFee"));
        } catch (Exception e) {
            shippingFee = 0;
        }

        // Validate address
        if (shippingAddress.isEmpty()) {
            request.setAttribute("ERROR_MSG", "Vui lòng nhập địa chỉ giao hàng.");
            request.setAttribute("PROFILE", userDAO.getUserProfile(user.getUserID()));
            request.setAttribute("CART", cart);
            request.getRequestDispatcher("orderConfirm.jsp").forward(request, response);
            return;
        }

        if (recipientPhone.isEmpty()) {
            request.setAttribute("ERROR_MSG", "Vui lòng nhập số điện thoại nhận hàng.");
            request.setAttribute("PROFILE", userDAO.getUserProfile(user.getUserID()));
            request.setAttribute("CART", cart);
            request.getRequestDispatcher("orderConfirm.jsp").forward(request, response);
            return;
        }

        // Validate coupon (if provided)
        double discountAmount = 0;
        if (!couponCode.isEmpty()) {
            CouponDTO coupon = couponDAO.validate(couponCode);
            if (!coupon.isValid()) {
                request.setAttribute("ERROR_MSG", "Lỗi mã giảm giá: " + coupon.getErrorMsg());
                request.setAttribute("PROFILE", userDAO.getUserProfile(user.getUserID()));
                request.setAttribute("CART", cart);
                request.getRequestDispatcher("orderConfirm.jsp").forward(request, response);
                return;
            }
            discountAmount = coupon.calcDiscount(cart.getTotal());
        }

        // Idempotency: reuse existing PENDING order only for VNPay (not COD)
        int orderId = -1;
        if ("VNPAY".equals(paymentMethod)) {
            Integer pendingOrderId = (Integer) session.getAttribute("PENDING_ORDER_ID");
            if (pendingOrderId != null && pendingOrderId > 0) {
                OrderHistory existing = historyDAO.getOrderDetail(pendingOrderId, user.getUserID());
                if (existing != null && existing.isRetryable()) {
                    orderId = pendingOrderId;
                }
            }
        }

        // Create new order if needed
        if (orderId < 0) {
            // Delete previous unpaid VNPay orders for this customer to free up stock/coupons
            if ("VNPAY".equals(paymentMethod)) {
                historyDAO.deletePreviousUnpaidVNPayOrders(user.getUserID());
            }

            int districtId = 0;
            try {
                districtId = Integer.parseInt(ghnDistrictIdStr);
            } catch (Exception ignored) {}

            try {
                OrderDAO orderDAO = new OrderDAO();
                orderId = orderDAO.checkOut(user.getUserID(), cart,
                                            shippingAddress, discountAmount,
                                            couponCode.isEmpty() ? null : couponCode,
                                            paymentMethod, shippingFee,
                                            districtId, ghnWardCode, recipientPhone);
            } catch (Exception e) {
                log("OrderConfirmController error: " + e.toString());
                orderId = -1;
            }

            if (orderId <= 0) {
                request.setAttribute("ERROR_MSG", "Không thể tạo đơn hàng. Vui lòng kiểm tra lại số lượng tồn kho và thử lại.");
                request.setAttribute("PROFILE", userDAO.getUserProfile(user.getUserID()));
                request.setAttribute("CART", cart);
                request.getRequestDispatcher("orderConfirm.jsp").forward(request, response);
                return;
            }

            // Save default profile address if user checked the box
            String saveDefaultAddress = trim(request.getParameter("saveDefaultAddress"));
            if ("true".equalsIgnoreCase(saveDefaultAddress) || "on".equalsIgnoreCase(saveDefaultAddress)) {
                try {
                    userDAO.updateProfileAddress(user.getUserID(), shippingAddress, recipientPhone);
                } catch (Exception ex) {
                    log("Failed to save default profile address: " + ex.toString());
                }
            }

            if ("COD".equals(paymentMethod)) {
                // Call GHN to create order immediately for COD payment method
                try {
                    utils.GHNService.createGHNOrderFromDB(orderId);
                } catch (Exception ghnEx) {
                    log("GHN Order Creation Error for COD order #" + orderId + ": " + ghnEx.getMessage());
                }
            }

            // Increment coupon usage
            if (!couponCode.isEmpty()) {
                couponDAO.incrementUsage(couponCode);
            }

            // Track pending order (for VNPay idempotency)
            session.setAttribute("PENDING_ORDER_ID", orderId);
        }

        // ── COD: done — redirect to orders ─────────────────────────────────
        if ("COD".equals(paymentMethod)) {
            session.removeAttribute("CART");
            session.removeAttribute("PENDING_ORDER_ID");

            try {
                shopping.CartPersistenceDAO cartDAO = new shopping.CartPersistenceDAO();
                cartDAO.clearCart(user.getUserID());
            } catch (Exception ex) {
                log("Failed to clear DB cart on COD checkout: " + ex.toString());
            }

            notifications.OrderNotificationDAO notifDAO = new notifications.OrderNotificationDAO();
            notifDAO.save(user.getUserID(), orderId, "ORDER_SUCCESS", "Đặt hàng thành công", "Đơn hàng #" + orderId + " đã được đặt thành công!");
            session.setAttribute("UNREAD_NOTIF_COUNT", notifDAO.countUnread(user.getUserID()));

            session.setAttribute("ORDER_SUCCESS_MSG",
                    "Đơn hàng #" + orderId + " đã được đặt thành công! Chúng tôi sẽ liên hệ bạn để xác nhận giao hàng.");
            response.sendRedirect("don-hang");
            return;
        }

        // ── VNPay: build payment URL and redirect ────────────────────────────
        try {
            String ipAddr = request.getHeader("X-Forwarded-For");
            if (ipAddr == null || ipAddr.isEmpty()) ipAddr = request.getRemoteAddr();

            double finalTotal = Math.max(0, cart.getTotal() - discountAmount) + shippingFee;
            long   amount     = (long) finalTotal;
            String orderInfo  = "Thanh toan don hang NutriOverflow #" + orderId;

            String returnUrl  = VNpay.VNPayUtil.getReturnUrl(request);
            String paymentUrl = vnPayService.createPaymentUrl(orderId, amount, orderInfo, ipAddr, returnUrl);

            // Backup the cart in case the payment fails or is canceled.
            session.setAttribute("BACKUP_CART", cart);
            // Clear the cart from session to avoid duplicate checkouts and stock double-deduction.
            session.removeAttribute("CART");
            session.removeAttribute("PENDING_ORDER_ID");

            UnpaidOrderCountDAO countDAO = new UnpaidOrderCountDAO();
            session.setAttribute("UNREAD_NOTIF_COUNT",
                    countDAO.getUnreadNotifCount(user.getUserID()));

            response.sendRedirect(paymentUrl);
        } catch (Exception e) {
            log("VNPay error: " + e.toString());
            request.setAttribute("ERROR_MSG", "Lỗi cổng thanh toán. Vui lòng thử lại sau.");
            request.setAttribute("PROFILE", userDAO.getUserProfile(user.getUserID()));
            request.setAttribute("CART", cart);
            request.getRequestDispatcher("orderConfirm.jsp").forward(request, response);
        }
    }

    private String trim(String s) {
        return s == null ? "" : s.trim();
    }

    private String escapeJson(String s) {
        if (s == null) return "";
        return s.replace("\\", "\\\\").replace("\"", "\\\"");
    }
}

package main;

import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet(name = "MainController", urlPatterns = {"/MainController"})
public class MainController extends HttpServlet {
    private static final String DEFAULT_PAGE = "ShoppingController";
    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("text/html;charset=UTF-8");
        String url = DEFAULT_PAGE;
        try {
            String action = request.getParameter("action");
            if (action == null) {
                url = DEFAULT_PAGE;
            } else {
                switch (action) {
                    case "Login": url = "LoginController"; break;
                    case "Logout": url = "LogoutController"; break;
                    case "GoShopping": url = "ShoppingController"; break;
                    case "NutriBoost": url = "nutriboost.jsp"; break;
                    case "Add": url = "AddController"; break;
                    case "ViewCart": url = "viewCart.jsp"; break;
                    case "Edit": url = "EditController"; break;
                    case "Detail": url = "DetailController"; break;
                    case "Remove": url = "RemoveController"; break;
                    case "Checkout": url = "CheckoutController"; break;
                    case "Register": url = "RegisterController"; break;
                    case "VerifyCode": url = "VerifyController"; break;
                    case "ResendCode": url = "ResendCodeController"; break;
                    case "SendCodeAjax": url = "SendCodeAjaxController"; break;
                    case "SearchAjax": url = "SearchAjaxController"; break;
                    case "AddFavorite": url = "AddFavoriteController"; break;
                    case "ViewFavorites": url = "ViewFavoriteController"; break;
                    case "RemoveFavorite": url = "RemoveFavoriteController"; break;
                    case "ViewOrders": url = "OrderHistoryController"; break;
                    case "RetryPayment": url = "RetryPaymentController"; break;
                    case "Notifications": url = "NotificationController"; break;
                    case "ViewProfile":   url = "ProfileController"; break;
                    case "UpdateProfile": url = "ProfileController"; break;
                    case "PlaceOrder":    url = "OrderConfirmController"; break;
                    case "ValidateCoupon": url = "OrderConfirmController"; break;
                    case "CancelOrder":   url = "CancelOrderController"; break;
                    case "AddReview":     url = "AddReviewController"; break;
                    case "Blog":          url = "BlogController"; break;
                    case "BlogDetail":    url = "BlogController"; break;
                }
            }
        } catch (Exception e) {
            log("Error at MainController: " + e.toString());
        } finally {
            request.getRequestDispatcher(url).forward(request, response);
        }
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException { processRequest(req, resp); }
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException { processRequest(req, resp); }
}
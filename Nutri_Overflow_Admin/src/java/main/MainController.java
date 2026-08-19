package main;

import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet(name = "MainController", urlPatterns = {"/MainController"})
@MultipartConfig(
    fileSizeThreshold = 1024 * 1024 * 2, // 2MB
    maxFileSize = 1024 * 1024 * 10,      // 10MB
    maxRequestSize = 1024 * 1024 * 50    // 50MB
)
public class MainController extends HttpServlet {
    private static final String DEFAULT_PAGE = "admin_login.jsp";
    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("text/html;charset=UTF-8");
        request.setCharacterEncoding("UTF-8");
        String url = DEFAULT_PAGE;
        try {
            String action = request.getParameter("action");
            if (action == null) {
                url = DEFAULT_PAGE;
            } else {
                switch (action) {
                    case "Login": url = "LoginController"; break;
                    case "Logout": url = "LogoutController"; break;
                    case "Search": url = "SearchController"; break;
                    case "Create": url = "CreateController"; break;
                    case "Update": url = "UpdateController"; break;
                    case "Delete": url = "DeleteController"; break;
                    case "ManageProducts": url = "ManageProductsController"; break;
                    case "UpdateProductStock": url = "UpdateProductStockController"; break;
                    case "AddProduct": url = "AddProductController"; break;
                    case "UpdateProduct": url = "UpdateProductController"; break;
                    case "ToggleProductActive": url = "ToggleProductActiveController"; break;
                    case "DeleteProduct": url = "DeleteProductController"; break;
                    case "ManageCampaigns": url = "ManageCampaignsController"; break;
                    case "CouponAction": url = "CouponActionController"; break;
                    case "MemberPointsAction": url = "MemberPointsActionController"; break;
                    case "ManageArticles": url = "ManageArticlesController"; break;
                    case "ArticleAction": url = "ArticleActionController"; break;
                    case "ManageOrders": url = "ManageOrdersController"; break;
                    case "OrderAction": url = "OrderActionController"; break;
                    case "ManageReturns": url = "ManageReturnsController"; break;
                    case "ReturnAction": url = "ReturnActionController"; break;
                    case "ManageBatches": url = "ManageBatchesController"; break;
                    case "ImportBatch": url = "ImportBatchController"; break;
                    case "ToggleUserActive": url = "ToggleUserActiveController"; break;
                    case "ManageTickets": url = "ManageTicketsController"; break;
                    case "TicketAction": url = "TicketActionController"; break;
                    case "ManageChat": url = "ManageChatController"; break;
                    case "ChatAjax": url = "ChatAjaxController"; break;
                    case "ViewDashboard": url = "ViewDashboardController"; break;
                    case "GetDashboardData": url = "GetDashboardDataController"; break;
                    case "ManageCustomFoods": url = "ManageCustomFoodsController"; break;
                    case "CustomFoodAction": url = "CustomFoodActionController"; break;
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
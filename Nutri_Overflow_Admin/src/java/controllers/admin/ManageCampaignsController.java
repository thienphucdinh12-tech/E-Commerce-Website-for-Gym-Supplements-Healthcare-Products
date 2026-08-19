package controllers.admin;

import java.io.IOException;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import shopping.CouponDAO;
import shopping.Coupon;
import shopping.SystemConfigDAO;
import shopping.CustomerPointDTO;
import user.UserDTO;

@WebServlet(name = "ManageCampaignsController", urlPatterns = {"/ManageCampaignsController"})
public class ManageCampaignsController extends HttpServlet {
    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("text/html;charset=UTF-8");
        request.setCharacterEncoding("UTF-8");

        HttpSession session = request.getSession(false);
        UserDTO loginUser = (session != null) ? (UserDTO) session.getAttribute("LOGIN_USER") : null;
        if (loginUser == null || (!"AD".equals(loginUser.getRoleID()) && !"MAN".equals(loginUser.getRoleID()))) {
            response.sendRedirect("admin_login.jsp");
            return;
        }

        String url = "manage_campaigns.jsp";
        try {
            CouponDAO couponDAO = new CouponDAO();
            SystemConfigDAO configDAO = new SystemConfigDAO();

            List<Coupon> listCoupons = couponDAO.getAllCoupons();
            String pointEarningRate = configDAO.getConfig("point_earning_rate");
            String pointRedeemRate = configDAO.getConfig("point_redeem_rate");
            List<CustomerPointDTO> listCustomerPoints = configDAO.getAllCustomerPoints();

            request.setAttribute("LIST_COUPONS", listCoupons);
            request.setAttribute("POINT_EARNING_RATE", pointEarningRate);
            request.setAttribute("POINT_REDEEM_RATE", pointRedeemRate);
            request.setAttribute("LIST_CUSTOMER_POINTS", listCustomerPoints);
        } catch (Exception e) {
            log("Error at ManageCampaignsController: " + e.toString());
        } finally {
            request.getRequestDispatcher(url).forward(request, response);
        }
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException { processRequest(req, resp); }
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException { processRequest(req, resp); }
}

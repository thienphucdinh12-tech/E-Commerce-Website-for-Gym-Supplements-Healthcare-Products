package controllers.admin;

import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import shopping.SystemConfigDAO;
import user.UserDTO;

@WebServlet(name = "MemberPointsActionController", urlPatterns = {"/MemberPointsActionController"})
public class MemberPointsActionController extends HttpServlet {
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

        String subAction = request.getParameter("subAction");
        SystemConfigDAO configDAO = new SystemConfigDAO();

        try {
            if ("updateRules".equalsIgnoreCase(subAction)) {
                String earningRate = request.getParameter("pointEarningRate");
                String redeemRate = request.getParameter("pointRedeemRate");
                
                if (earningRate != null && !earningRate.isEmpty()) {
                    configDAO.updateConfig("point_earning_rate", earningRate);
                }
                if (redeemRate != null && !redeemRate.isEmpty()) {
                    configDAO.updateConfig("point_redeem_rate", redeemRate);
                }
                session.setAttribute("SUCCESS_MESSAGE", "Cập nhật quy tắc tích điểm thành công!");

            } else if ("updateCustomerPoints".equalsIgnoreCase(subAction)) {
                int userId = Integer.parseInt(request.getParameter("userId"));
                int points = Integer.parseInt(request.getParameter("points"));
                
                if (points < 0) {
                    session.setAttribute("ERROR_MESSAGE", "Số điểm tích lũy không thể âm!");
                } else {
                    boolean success = configDAO.updateCustomerPoints(userId, points);
                    if (success) {
                        session.setAttribute("SUCCESS_MESSAGE", "Cập nhật điểm tích lũy thành viên thành công!");
                    } else {
                        session.setAttribute("ERROR_MESSAGE", "Cập nhật điểm thành viên thất bại!");
                    }
                }
            }
        } catch (Exception e) {
            log("Error at MemberPointsActionController: " + e.toString());
            session.setAttribute("ERROR_MESSAGE", "Lỗi xử lý điểm tích lũy: " + e.getMessage());
        }

        response.sendRedirect("MainController?action=ManageCampaigns");
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException { processRequest(req, resp); }
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException { processRequest(req, resp); }
}

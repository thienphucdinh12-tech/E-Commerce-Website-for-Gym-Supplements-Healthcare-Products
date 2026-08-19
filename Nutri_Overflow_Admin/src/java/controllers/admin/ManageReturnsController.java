package controllers.admin;

import java.io.IOException;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import shopping.ReturnLogisticsDAO;
import shopping.AdminOrderDTO;
import user.UserDTO;

@WebServlet(name = "ManageReturnsController", urlPatterns = {"/ManageReturnsController"})
public class ManageReturnsController extends HttpServlet {
    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("text/html;charset=UTF-8");
        request.setCharacterEncoding("UTF-8");

        // Security check: Only AD, MAN, KHO
        HttpSession session = request.getSession(false);
        UserDTO loginUser = (session != null) ? (UserDTO) session.getAttribute("LOGIN_USER") : null;
        if (loginUser == null || (!"AD".equals(loginUser.getRoleID()) 
                && !"MAN".equals(loginUser.getRoleID()) 
                && !"KHO".equals(loginUser.getRoleID()))) {
            response.sendRedirect("admin_login.jsp");
            return;
        }

        try {
            String search = request.getParameter("search");
            if (search == null) search = "";

            ReturnLogisticsDAO dao = new ReturnLogisticsDAO();
            List<AdminOrderDTO> list = dao.getEligibleReturnOrders(search);
            request.setAttribute("LIST_RETURN_ORDERS", list);
            
            int[] stats = dao.getReturnStats();
            request.setAttribute("STATS_TOTAL_ORDERS", stats[0]);
            request.setAttribute("STATS_TOTAL_RESTOCK", stats[1]);
            request.setAttribute("STATS_TOTAL_DISCARD", stats[2]);
        } catch (Exception e) {
            log("Error at ManageReturnsController: " + e.toString());
        }

        request.getRequestDispatcher("manage_returns.jsp").forward(request, response);
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException { processRequest(req, resp); }
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException { processRequest(req, resp); }
}

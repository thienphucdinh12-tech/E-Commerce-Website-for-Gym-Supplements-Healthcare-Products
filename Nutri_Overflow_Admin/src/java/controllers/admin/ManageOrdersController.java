package controllers.admin;

import java.io.IOException;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import shopping.AdminOrderDAO;
import shopping.AdminOrderDTO;
import user.UserDTO;

@WebServlet(name = "ManageOrdersController", urlPatterns = {"/ManageOrdersController"})
public class ManageOrdersController extends HttpServlet {
    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("text/html;charset=UTF-8");
        request.setCharacterEncoding("UTF-8");

        // Security Check: Allow AD, MAN, KHO
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
            String statusFilter = request.getParameter("statusFilter");
            String paymentMethodFilter = request.getParameter("paymentMethodFilter");

            if (search == null) search = "";
            if (statusFilter == null) statusFilter = "all";
            if (paymentMethodFilter == null) paymentMethodFilter = "all";

            AdminOrderDAO dao = new AdminOrderDAO();
            List<AdminOrderDTO> list = dao.getAllOrders(search, statusFilter, paymentMethodFilter);

            request.setAttribute("LIST_ORDERS", list);
        } catch (Exception e) {
            log("Error at ManageOrdersController: " + e.toString());
        }

        request.getRequestDispatcher("manage_orders.jsp").forward(request, response);
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException { processRequest(req, resp); }
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException { processRequest(req, resp); }
}

package controllers.admin;

import java.io.IOException;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import shopping.SupportTicketDAO;
import shopping.SupportTicketDTO;
import user.UserDTO;

@WebServlet(name = "ManageTicketsController", urlPatterns = {"/ManageTicketsController"})
public class ManageTicketsController extends HttpServlet {
    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("text/html;charset=UTF-8");
        request.setCharacterEncoding("UTF-8");

        // --- SECURITY CHECK: Allow ADMIN (AD), MANAGER (MAN), CSKH (CSKH) ---
        HttpSession session = request.getSession(false);
        UserDTO loginUser = (session != null) ? (UserDTO) session.getAttribute("LOGIN_USER") : null;
        if (loginUser == null || (!"AD".equals(loginUser.getRoleID()) && !"MAN".equals(loginUser.getRoleID()) && !"CSKH".equals(loginUser.getRoleID()))) {
            response.sendRedirect("admin_login.jsp");
            return;
        }

        String url = "manage_tickets.jsp";
        try {
            String search = request.getParameter("search");
            String statusFilter = request.getParameter("statusFilter");
            String categoryFilter = request.getParameter("categoryFilter");

            if (search == null) search = "";
            if (statusFilter == null) statusFilter = "all";
            if (categoryFilter == null) categoryFilter = "all";

            SupportTicketDAO dao = new SupportTicketDAO();
            List<SupportTicketDTO> listTickets = dao.getAllTickets(search, statusFilter, categoryFilter);

            // Compute KPI metrics dynamically based on ALL tickets (without filtering) to keep statistics accurate
            List<SupportTicketDTO> allTickets = dao.getAllTickets("", "all", "all");
            int total = allTickets.size();
            int pending = 0;
            int processing = 0;
            int resolved = 0;
            int forwarded = 0;

            for (SupportTicketDTO t : allTickets) {
                if ("PENDING".equalsIgnoreCase(t.getStatus())) {
                    pending++;
                } else if ("PROCESSING".equalsIgnoreCase(t.getStatus())) {
                    processing++;
                } else if ("RESOLVED".equalsIgnoreCase(t.getStatus())) {
                    resolved++;
                } else if ("FORWARDED".equalsIgnoreCase(t.getStatus())) {
                    forwarded++;
                }
            }

            request.setAttribute("LIST_TICKETS", listTickets);
            request.setAttribute("KPI_TOTAL", total);
            request.setAttribute("KPI_PENDING", pending);
            request.setAttribute("KPI_PROCESSING", processing);
            request.setAttribute("KPI_RESOLVED", resolved);
            request.setAttribute("KPI_FORWARDED", forwarded);
            
            request.setAttribute("search", search);
            request.setAttribute("statusFilter", statusFilter);
            request.setAttribute("categoryFilter", categoryFilter);
            
        } catch (Exception e) {
            log("Error at ManageTicketsController: " + e.toString());
        } finally {
            request.getRequestDispatcher(url).forward(request, response);
        }
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException { processRequest(req, resp); }
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException { processRequest(req, resp); }
}

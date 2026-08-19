package controllers.admin;

import com.google.gson.Gson;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import user.DashboardDAO;
import user.UserDTO;

@WebServlet(name = "GetDashboardDataController", urlPatterns = {"/GetDashboardDataController"})
public class GetDashboardDataController extends HttpServlet {
    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("application/json;charset=UTF-8");
        
        HttpSession session = request.getSession(false);
        UserDTO loginUser = (session != null) ? (UserDTO) session.getAttribute("LOGIN_USER") : null;
        
        if (loginUser == null || "US".equals(loginUser.getRoleID())) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            try (PrintWriter out = response.getWriter()) {
                out.write("{\"error\": \"Unauthorized access\"}");
            }
            return;
        }

        String daysStr = request.getParameter("days");
        int days = 30; // default to last 30 days
        try {
            if (daysStr != null) {
                days = Integer.parseInt(daysStr);
            }
        } catch (NumberFormatException e) {
            // ignore, keep default
        }

        DashboardDAO dao = new DashboardDAO();
        Map<String, Object> data = new HashMap<>();
        
        try {
            List<Map<String, Object>> revenueData = dao.getRevenueData(days);
            List<Map<String, Object>> bestSellers = dao.getBestSellers(5);
            Map<String, Object> inventoryStatus = dao.getInventoryStatus();
            Map<String, Object> orderStatusStats = dao.getOrderStatusStats();
            List<Map<String, Object>> cskhPerformance = dao.getCSKHPerformance();
            List<Map<String, Object>> warehousePerformance = dao.getWarehousePerformance();
            
            data.put("success", true);
            data.put("revenueData", revenueData);
            data.put("bestSellers", bestSellers);
            data.put("inventoryStatus", inventoryStatus);
            data.put("orderStatusStats", orderStatusStats);
            data.put("cskhPerformance", cskhPerformance);
            data.put("warehousePerformance", warehousePerformance);
            data.put("days", days);
        } catch (Exception e) {
            e.printStackTrace();
            data.put("success", false);
            data.put("error", e.getMessage());
        }

        String json = new Gson().toJson(data);
        try (PrintWriter out = response.getWriter()) {
            out.print(json);
            out.flush();
        }
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException { processRequest(req, resp); }
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException { processRequest(req, resp); }
}

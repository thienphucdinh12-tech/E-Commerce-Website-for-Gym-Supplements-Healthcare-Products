package controllers.admin;

import java.io.IOException;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import shopping.StockBatchDAO;
import shopping.StockBatchDTO;
import shopping.ProductDAO;
import shopping.Product;
import user.UserDTO;

@WebServlet(name = "ManageBatchesController", urlPatterns = {"/ManageBatchesController"})
public class ManageBatchesController extends HttpServlet {
    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("text/html;charset=UTF-8");
        request.setCharacterEncoding("UTF-8");

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

            StockBatchDAO batchDao = new StockBatchDAO();
            List<StockBatchDTO> listBatches = batchDao.getAllBatches(search);
            request.setAttribute("LIST_BATCHES", listBatches);

            ProductDAO prodDao = new ProductDAO();
            List<Product> listProducts = prodDao.getAllProductsAdmin("", "all", "all");
            request.setAttribute("LIST_PRODUCTS", listProducts);
        } catch (Exception e) {
            log("Error at ManageBatchesController: " + e.toString());
        }

        request.getRequestDispatcher("manage_batches.jsp").forward(request, response);
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException { processRequest(req, resp); }
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException { processRequest(req, resp); }
}

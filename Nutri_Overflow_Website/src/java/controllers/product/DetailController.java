package controllers.product;

import shopping.Product;
import shopping.ProductDAO;
import shopping.ReviewDAO;
import shopping.ReviewDTO;
import java.io.IOException;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet(name = "DetailController", urlPatterns = {"/DetailController", "/san-pham"})
public class DetailController extends HttpServlet {
    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("text/html;charset=UTF-8");
        try {
            String id = request.getParameter("id");
            ProductDAO dao = new ProductDAO();
            Product product = dao.getProductById(id);
            
            if (product != null) {
                request.setAttribute("PRODUCT", product);
                
                // Store target URL for unauthenticated users so logging in brings them back here
                javax.servlet.http.HttpSession session = request.getSession();
                if (session.getAttribute("LOGIN_USER") == null) {
                    session.setAttribute("REDIRECT_URL", "san-pham?id=" + id.trim());
                }
                
                // Fetch product reviews
                ReviewDAO reviewDao = new ReviewDAO();
                List<ReviewDTO> reviews = reviewDao.getReviewsByProductId(Integer.parseInt(id));
                request.setAttribute("REVIEWS", reviews);
                
                request.getRequestDispatcher("productDetail.jsp").forward(request, response);
            } else {
                response.sendRedirect("cua-hang"); // Fallback to store home if not found
            }
        } catch (Exception e) {
            log("Error at DetailController: " + e.toString());
        }
    }
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException { processRequest(req, resp); }
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException { processRequest(req, resp); }
}
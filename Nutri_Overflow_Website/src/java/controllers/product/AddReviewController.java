package controllers.product;

import shopping.ReviewDAO;
import user.UserDTO;
import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet(name = "AddReviewController", urlPatterns = {"/AddReviewController"})
public class AddReviewController extends HttpServlet {
    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setContentType("text/html;charset=UTF-8");
        
        String productIdStr = request.getParameter("productId");
        String ratingStr = request.getParameter("rating");
        String comment = request.getParameter("comment");
        
        String url = "DetailController?id=" + productIdStr;
        
        try {
            HttpSession session = request.getSession();
            UserDTO loginUser = (UserDTO) session.getAttribute("LOGIN_USER");
            
            if (loginUser == null) {
                request.setAttribute("ERROR", "Vui lòng đăng nhập để gửi đánh giá!");
            } else {
                int productId = Integer.parseInt(productIdStr);
                int rating = Integer.parseInt(ratingStr);
                
                if (rating < 1 || rating > 5) {
                    request.setAttribute("ERROR", "Số sao đánh giá phải từ 1 đến 5!");
                } else if (comment == null || comment.trim().isEmpty()) {
                    request.setAttribute("ERROR", "Nội dung đánh giá không được để trống!");
                } else {
                    ReviewDAO dao = new ReviewDAO();
                    boolean success = dao.addReview(productId, loginUser.getUserID(), rating, comment);
                    if (success) {
                        request.setAttribute("MESSAGE", "Gửi đánh giá thành công! Cảm ơn ý kiến đóng góp của bạn.");
                    } else {
                        request.setAttribute("ERROR", "Gửi đánh giá thất bại, vui lòng thử lại sau!");
                    }
                }
            }
        } catch (Exception e) {
            log("Error at AddReviewController: " + e.toString());
            request.setAttribute("ERROR", "Lỗi hệ thống khi gửi đánh giá!");
        } finally {
            request.getRequestDispatcher(url).forward(request, response);
        }
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException { processRequest(req, resp); }
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException { processRequest(req, resp); }
}

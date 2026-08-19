package controllers.product;

import shopping.FavoriteDAO;
import shopping.Product;
import java.io.IOException;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet(name = "ViewFavoriteController", urlPatterns = {"/ViewFavoriteController", "/yeu-thich"})
public class ViewFavoriteController extends HttpServlet {

    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("text/html;charset=UTF-8");
        String url = "favorites.jsp"; // Trang hiển thị danh sách yêu thích công khai
        
        try {
            HttpSession session = request.getSession();
            // Lấy object đăng nhập (Đổi "LOGIN_USER" thành tên attribute thực tế của bạn)
            Object loginUser = session.getAttribute("LOGIN_USER");
            
            if (loginUser == null) {
                // Nếu chưa đăng nhập, bắt buộc phải tới trang login
                url = "login.jsp"; 
            } else {
                user.UserDTO currentUser = (user.UserDTO) loginUser;
                String userId = currentUser.getUserID(); // TODO: XÓA DÒNG NÀY VÀ THAY BẰNG CODE LẤY USER_ID THỰC TẾ
                
                FavoriteDAO dao = new FavoriteDAO();
                List<Product> listFavorite = dao.getFavoriteProducts(userId);
                
                // Đẩy danh sách sang trang JSP
                request.setAttribute("LIST_FAVORITE", listFavorite);
            }
        } catch (Exception e) {
            log("Error at ViewFavoriteController: " + e.toString());
        } finally {
            request.getRequestDispatcher(url).forward(request, response);
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        processRequest(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        processRequest(request, response);
    }
}
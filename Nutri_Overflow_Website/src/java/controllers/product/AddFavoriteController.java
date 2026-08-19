package controllers.product;

import shopping.FavoriteDAO;
import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet(name = "AddFavoriteController", urlPatterns = {"/AddFavoriteController"})
public class AddFavoriteController extends HttpServlet {

    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
        throws ServletException, IOException {
    response.setContentType("text/html;charset=UTF-8");
    
    // Đọc thẳng productId từ parameter (đã sửa để đồng bộ với productDetail.jsp)
    String productIdStr = request.getParameter("productId");
    if (productIdStr == null) productIdStr = "";
    
    String url = "MainController?action=Detail&id=" + productIdStr;

    try {
        HttpSession session = request.getSession();
        
        // --- SỬA LỖI 1: Gọi đúng key LOGIN_USER giống như LoginController ---
        Object loginUser = session.getAttribute("LOGIN_USER");

        if (loginUser == null) {
            session.setAttribute("REDIRECT_URL", url);
            request.setAttribute("ERROR_MESSAGE", "Vui lòng đăng nhập để lưu sản phẩm yêu thích!");
            url = "login.jsp";
        } else {
            // Ép kiểu về DTO và lấy ID như bình thường
            user.UserDTO currentUser = (user.UserDTO) loginUser;
            String userId = currentUser.getUserID(); 
            
            int productId = Integer.parseInt(productIdStr);

            shopping.FavoriteDAO dao = new shopping.FavoriteDAO();
            boolean result = dao.addFavorite(userId, productId);

            if (result) {
                request.setAttribute("SUCCESS_MSG", "Added to favorites successfully!");
            } else {
                request.setAttribute("ERROR_MSG", "Product is already in your favorites!");
            }
        }
    } catch (Exception e) {
        log("Error at AddFavoriteController: " + e.toString());
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
package controllers.product;

import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import shopping.FavoriteDAO;
import user.UserDTO;

@WebServlet(name = "RemoveFavoriteController", urlPatterns = {"/RemoveFavoriteController"})
public class RemoveFavoriteController extends HttpServlet {

    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String url = "MainController?action=ViewFavorites"; // Xóa xong thì load lại trang yêu thích

        try {
            HttpSession session = request.getSession();
            UserDTO loginUser = (UserDTO) session.getAttribute("LOGIN_USER");

            if (loginUser == null) {
                url = "login.jsp"; // Chưa đăng nhập thì về trang login
            } else {
                String productIdStr = request.getParameter("id");
                if (productIdStr != null && !productIdStr.isEmpty()) {
                    int productId = Integer.parseInt(productIdStr);
                    String username = loginUser.getUserID(); // userID trong DTO thực chất là username

                    FavoriteDAO dao = new FavoriteDAO();
                    dao.removeFavorite(username, productId);
                }
            }
        } catch (Exception e) {
            log("Error at RemoveFavoriteController: " + e.toString());
        } finally {
            response.sendRedirect(url); // Dùng sendRedirect để tránh lỗi submit lại form khi F5
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
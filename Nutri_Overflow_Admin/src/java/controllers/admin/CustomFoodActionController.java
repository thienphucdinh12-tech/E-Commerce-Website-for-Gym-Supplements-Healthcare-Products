package controllers.admin;

import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import shopping.CustomFoodDAO;
import shopping.CustomFoodDTO;
import user.UserDTO;

@WebServlet(name = "CustomFoodActionController", urlPatterns = {"/CustomFoodActionController"})
public class CustomFoodActionController extends HttpServlet {
    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("text/html;charset=UTF-8");
        request.setCharacterEncoding("UTF-8");

        HttpSession session = request.getSession(false);
        UserDTO loginUser = (session != null) ? (UserDTO) session.getAttribute("LOGIN_USER") : null;
        if (loginUser == null || (!"AD".equals(loginUser.getRoleID()) && !"MAN".equals(loginUser.getRoleID()))) {
            response.sendRedirect("admin_login.jsp");
            return;
        }

        String subAction = request.getParameter("subAction");
        String url = "MainController?action=ManageCustomFoods";
        CustomFoodDAO dao = new CustomFoodDAO();

        try {
            if ("add".equalsIgnoreCase(subAction)) {
                String foodName = request.getParameter("foodName");
                int calories = Integer.parseInt(request.getParameter("calories"));
                double protein = Double.parseDouble(request.getParameter("protein"));
                double carbs = Double.parseDouble(request.getParameter("carbs"));
                double fat = Double.parseDouble(request.getParameter("fat"));
                String servingSize = request.getParameter("servingSize");
                String description = request.getParameter("description");

                CustomFoodDTO food = new CustomFoodDTO(0, foodName, calories, protein, carbs, fat, servingSize, description, null);
                boolean success = dao.insertCustomFood(food);
                if (success) {
                    request.setAttribute("MSG_SUCCESS", "Thêm món ăn mới thành công!");
                } else {
                    request.setAttribute("MSG_ERROR", "Không thể thêm món ăn mới. Vui lòng kiểm tra lại dữ liệu.");
                }
            } else if ("edit".equalsIgnoreCase(subAction)) {
                int foodId = Integer.parseInt(request.getParameter("foodId"));
                String foodName = request.getParameter("foodName");
                int calories = Integer.parseInt(request.getParameter("calories"));
                double protein = Double.parseDouble(request.getParameter("protein"));
                double carbs = Double.parseDouble(request.getParameter("carbs"));
                double fat = Double.parseDouble(request.getParameter("fat"));
                String servingSize = request.getParameter("servingSize");
                String description = request.getParameter("description");

                CustomFoodDTO food = new CustomFoodDTO(foodId, foodName, calories, protein, carbs, fat, servingSize, description, null);
                boolean success = dao.updateCustomFood(food);
                if (success) {
                    request.setAttribute("MSG_SUCCESS", "Cập nhật món ăn thành công!");
                } else {
                    request.setAttribute("MSG_ERROR", "Cập nhật món ăn thất bại.");
                }
            } else if ("delete".equalsIgnoreCase(subAction)) {
                int foodId = Integer.parseInt(request.getParameter("foodId"));
                boolean success = dao.deleteCustomFood(foodId);
                if (success) {
                    request.setAttribute("MSG_SUCCESS", "Xóa món ăn thành công!");
                } else {
                    request.setAttribute("MSG_ERROR", "Xóa món ăn thất bại.");
                }
            }
        } catch (Exception e) {
            log("Error at CustomFoodActionController: " + e.toString());
            request.setAttribute("MSG_ERROR", "Có lỗi xảy ra: " + e.getMessage());
        } finally {
            request.getRequestDispatcher(url).forward(request, response);
        }
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException { processRequest(req, resp); }
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException { processRequest(req, resp); }
}

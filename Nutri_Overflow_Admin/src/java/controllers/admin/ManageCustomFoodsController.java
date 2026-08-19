package controllers.admin;

import java.io.IOException;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import shopping.CustomFoodDAO;
import shopping.CustomFoodDTO;
import user.UserDTO;

@WebServlet(name = "ManageCustomFoodsController", urlPatterns = {"/ManageCustomFoodsController"})
public class ManageCustomFoodsController extends HttpServlet {
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

        String url = "manage_custom_foods.jsp";
        try {
            String search = request.getParameter("search");
            if (search == null) {
                search = "";
            }
            
            CustomFoodDAO dao = new CustomFoodDAO();
            List<CustomFoodDTO> list = dao.getAllCustomFoods(search);
            request.setAttribute("LIST_CUSTOM_FOODS", list);
            request.setAttribute("SEARCH_VALUE", search);
        } catch (Exception e) {
            log("Error at ManageCustomFoodsController: " + e.toString());
        } finally {
            request.getRequestDispatcher(url).forward(request, response);
        }
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException { processRequest(req, resp); }
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException { processRequest(req, resp); }
}

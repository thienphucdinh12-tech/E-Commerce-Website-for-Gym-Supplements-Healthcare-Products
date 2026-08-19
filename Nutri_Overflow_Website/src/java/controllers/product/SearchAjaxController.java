package controllers.product;

import com.google.gson.Gson;
import java.io.IOException;
import java.util.List;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import shopping.Product;
import shopping.ProductDAO;

@WebServlet(name = "SearchAjaxController", urlPatterns = {"/SearchAjaxController"})
public class SearchAjaxController extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException {
        String txtSearch = request.getParameter("txtSearch");
        ProductDAO dao = new ProductDAO();
        List<Product> list = dao.getProductByStartName(txtSearch);
        
        // Return JSON format response object
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        String json = new Gson().toJson(list); 
        response.getWriter().write(json);
    }
}
package controllers;

import java.io.IOException;
import java.io.PrintWriter;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import utils.GHNService;
import com.google.gson.JsonArray;

@WebServlet(name = "GHNLocationController", urlPatterns = {"/api/ghn-location"})
public class GHNLocationController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("application/json;charset=UTF-8");
        String type = request.getParameter("type");
        PrintWriter out = response.getWriter();
        
        try {
            JsonArray data = new JsonArray();
            if ("province".equals(type)) {
                JsonArray rawProvinces = GHNService.getProvinces();
                for (int i = 0; i < rawProvinces.size(); i++) {
                    com.google.gson.JsonObject p = rawProvinces.get(i).getAsJsonObject();
                    String pName = p.has("ProvinceName") ? p.get("ProvinceName").getAsString() : "";
                    if (!pName.contains("Hà Nội 02") && !pName.contains("Test") && !pName.contains("Alert") && !pName.contains("001")) {
                        data.add(p);
                    }
                }
            } else if ("district".equals(type)) {
                int provinceId = Integer.parseInt(request.getParameter("province_id"));
                data = GHNService.getDistricts(provinceId);
            } else if ("ward".equals(type)) {
                int districtId = Integer.parseInt(request.getParameter("district_id"));
                data = GHNService.getWards(districtId);
            }
            out.print(data.toString());
        } catch (Exception e) {
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            out.print("{\"error\": \"" + e.getMessage() + "\"}");
        }
    }
}

package controllers.admin;

import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import javax.servlet.ServletException;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import shopping.ProductDAO;
import shopping.Product;
import user.UserDTO;

@WebServlet(name = "AddProductController", urlPatterns = {"/AddProductController"})
@MultipartConfig(
    fileSizeThreshold = 1024 * 1024 * 2, // 2MB
    maxFileSize = 1024 * 1024 * 10,      // 10MB
    maxRequestSize = 1024 * 1024 * 50    // 50MB
)
public class AddProductController extends HttpServlet {
    private String uploadImage(Part part, HttpServletRequest request) throws IOException {
        if (part == null || part.getSize() == 0) {
            return null;
        }
        
        String submittedFileName = Paths.get(part.getSubmittedFileName()).getFileName().toString();
        String sanitizedName = submittedFileName.replaceAll("[^a-zA-Z0-9\\.\\-_]", "_");
        String fileName = "upload_" + System.currentTimeMillis() + "_" + sanitizedName;
        
        String deployPath = request.getServletContext().getRealPath("/image");
        if (deployPath != null) {
            File deployDir = new File(deployPath);
            if (!deployDir.exists()) {
                deployDir.mkdirs();
            }
            File deployFile = new File(deployDir, fileName);
            try (InputStream input = part.getInputStream()) {
                Files.copy(input, deployFile.toPath(), StandardCopyOption.REPLACE_EXISTING);
            }
            
            // Also save to source path for persistence in NetBeans development
            String sourcePath = deployPath.replace("build\\web", "web").replace("build/web", "web");
            File sourceDir = new File(sourcePath);
            if (sourceDir.exists()) {
                File sourceFile = new File(sourceDir, fileName);
                Files.copy(deployFile.toPath(), sourceFile.toPath(), StandardCopyOption.REPLACE_EXISTING);
            }

            // Sync image to Nutri_Overflow_Website web and build image folders
            try {
                String webSourcePath = sourcePath.replace("Nutri_Overflow_Admin", "Nutri_Overflow_Website");
                File webSourceDir = new File(webSourcePath);
                if (webSourceDir.exists()) {
                    File webSourceFile = new File(webSourceDir, fileName);
                    Files.copy(deployFile.toPath(), webSourceFile.toPath(), StandardCopyOption.REPLACE_EXISTING);
                }
                String webDeployPath = deployPath.replace("Nutri_Overflow_Admin", "Nutri_Overflow_Website");
                File webDeployDir = new File(webDeployPath);
                if (webDeployDir.exists()) {
                    File webDeployFile = new File(webDeployDir, fileName);
                    Files.copy(deployFile.toPath(), webDeployFile.toPath(), StandardCopyOption.REPLACE_EXISTING);
                }
            } catch (Exception ex) {
                // Ignore sync errors if paths don't exist
            }
        }
        
        return fileName;
    }

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

        String search = request.getParameter("searchFilter");
        String categoryFilter = request.getParameter("categoryFilter");
        String stockFilter = request.getParameter("stockFilter");
        if (search == null) search = "";
        if (categoryFilter == null) categoryFilter = "all";
        if (stockFilter == null) stockFilter = "all";

        String redirectUrl = "MainController?action=ManageProducts&search=" + java.net.URLEncoder.encode(search, "UTF-8")
                + "&category=" + java.net.URLEncoder.encode(categoryFilter, "UTF-8")
                + "&stockFilter=" + java.net.URLEncoder.encode(stockFilter, "UTF-8");

        try {
            String sku = request.getParameter("sku");
            String categoryIdStr = request.getParameter("categoryId");
            String name = request.getParameter("name");
            String description = request.getParameter("description");
            String priceStr = request.getParameter("price");
            String discountPercentStr = request.getParameter("discountPercent");
            String stockQuantityStr = request.getParameter("stockQuantity");
            Part part = request.getPart("imageFile");
            String imageUrl = uploadImage(part, request);
            String medicalWarning = request.getParameter("medicalWarning");
            boolean isFlashSale = request.getParameter("isFlashSale") != null;
            boolean isBestSeller = request.getParameter("isBestSeller") != null;

            if (sku == null || sku.trim().isEmpty() || name == null || name.trim().isEmpty() || priceStr == null) {
                session.setAttribute("ERROR_MESSAGE", "Vui lòng nhập đầy đủ các trường bắt buộc!");
                response.sendRedirect(redirectUrl);
                return;
            }

            int categoryId = Integer.parseInt(categoryIdStr);
            double price = Double.parseDouble(priceStr);
            int discountPercent = (discountPercentStr != null && !discountPercentStr.isEmpty()) ? Integer.parseInt(discountPercentStr) : 0;
            int stockQuantity = (stockQuantityStr != null && !stockQuantityStr.isEmpty()) ? Integer.parseInt(stockQuantityStr) : 0;
            
            Double discountPrice = null;
            if (discountPercent > 0) {
                discountPrice = price * (100 - discountPercent) / 100.0;
            }
            if (imageUrl == null || imageUrl.trim().isEmpty()) {
                imageUrl = "default-product.jpg";
            }

            Product p = new Product(null, sku, categoryId, name, description, price, discountPrice, discountPercent, isFlashSale, 0, stockQuantity, imageUrl, true, medicalWarning, isBestSeller);
            ProductDAO dao = new ProductDAO();
            boolean success = dao.insertProduct(p);
            if (success) {
                session.setAttribute("SUCCESS_MESSAGE", "Thêm mới sản phẩm thành công!");
            } else {
                session.setAttribute("ERROR_MESSAGE", "Thêm mới sản phẩm thất bại (Mã SKU có thể bị trùng)!");
            }
        } catch (Exception e) {
            log("Error at AddProductController: " + e.toString());
            session.setAttribute("ERROR_MESSAGE", "Lỗi dữ liệu: " + e.getMessage());
        }
        response.sendRedirect(redirectUrl);
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException { processRequest(req, resp); }
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException { processRequest(req, resp); }
}

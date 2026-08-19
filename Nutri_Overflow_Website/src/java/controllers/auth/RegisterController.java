package controllers.auth;

import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import user.UserDAO;
import user.UserDTO;

@WebServlet(name = "RegisterController", urlPatterns = {"/RegisterController", "/dang-ky"})
public class RegisterController extends HttpServlet {
    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setContentType("text/html;charset=UTF-8");
        
        String url = "register.jsp"; // Default back to register page on error
        
        try {
            String userID = request.getParameter("userID");
            String fullName = request.getParameter("fullName");
            String password = request.getParameter("password");
            String confirm = request.getParameter("confirm");
            String email = request.getParameter("email");
            String codeInput = request.getParameter("code"); // Verification code submitted by user
            
            UserDAO dao = new UserDAO();
            HttpSession session = request.getSession();
            
            String sessionCode = (String) session.getAttribute("TEMP_REGISTER_CODE");
            String sessionEmail = (String) session.getAttribute("TEMP_REGISTER_EMAIL");
            Long sessionExpiry = (Long) session.getAttribute("TEMP_REGISTER_CODE_EXPIRY");
            
            // Check validations
            if (!password.equals(confirm)) {
                request.setAttribute("ERROR_MESSAGE", "Mật khẩu xác nhận không khớp!");
            } else if (userID.length() < 3 || fullName.length() < 3) {
                request.setAttribute("ERROR_MESSAGE", "Tên đăng nhập và Họ tên phải dài ít nhất 3 ký tự!");
            } else if (email == null || !email.matches("^[\\w-\\.]+@([\\w-]+\\.)+[\\w-]{2,4}$")) {
                request.setAttribute("ERROR_MESSAGE", "Email không hợp lệ!");
            } else if (dao.checkUsernameExists(userID)) {
                request.setAttribute("ERROR_MESSAGE", "Tên đăng nhập này đã được sử dụng!");
            } else if (dao.checkEmailExists(email)) {
                request.setAttribute("ERROR_MESSAGE", "Email này đã được đăng ký!");
            } else if (sessionCode == null || sessionEmail == null || sessionExpiry == null) {
                request.setAttribute("ERROR_MESSAGE", "Vui lòng bấm 'Gửi mã' xác thực trước khi đăng ký!");
            } else if (!email.equalsIgnoreCase(sessionEmail)) {
                request.setAttribute("ERROR_MESSAGE", "Email đăng ký không khớp với email đã nhận mã xác thực!");
            } else if (System.currentTimeMillis() > sessionExpiry) {
                request.setAttribute("ERROR_MESSAGE", "Mã xác thực đã hết hạn. Vui lòng bấm 'Gửi mã' để lấy mã mới!");
            } else if (!sessionCode.equals(codeInput)) {
                request.setAttribute("ERROR_MESSAGE", "Mã xác thực không chính xác!");
            } else {
                // If everything is correct, create account
                UserDTO user = new UserDTO(userID, fullName, "US", password);
                boolean checkInsert = dao.insert(user);
                if (checkInsert) {
                    dao.updateEmail(userID, email);
                    
                    // Clear temporary session data
                    session.removeAttribute("TEMP_REGISTER_CODE");
                    session.removeAttribute("TEMP_REGISTER_EMAIL");
                    session.removeAttribute("TEMP_REGISTER_CODE_EXPIRY");
                    
                    request.setAttribute("SUCCESS_MESSAGE", "Đăng ký thành công! Vui lòng đăng nhập.");
                    url = "login.jsp";
                } else {
                    request.setAttribute("ERROR_MESSAGE", "Lỗi tạo tài khoản trong hệ thống!");
                }
            }
        } catch (Exception e) {
            log("Error at RegisterController: " + e.toString());
            if (e.toString().contains("UNIQUE") || e.toString().contains("duplicate")) {
                request.setAttribute("ERROR_MESSAGE", "Tên đăng nhập này đã được sử dụng!");
            } else {
                request.setAttribute("ERROR_MESSAGE", "Lỗi hệ thống, vui lòng thử lại sau!");
            }
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

    @Override
    public String getServletInfo() {
        return "Short description";
    }
}
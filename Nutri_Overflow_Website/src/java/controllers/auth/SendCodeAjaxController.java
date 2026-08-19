package controllers.auth;

import java.io.IOException;
import java.io.PrintWriter;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import user.UserDAO;
import utils.EmailUtils;

@WebServlet(name = "SendCodeAjaxController", urlPatterns = {"/SendCodeAjaxController", "/gui-ma-xac-thuc"})
public class SendCodeAjaxController extends HttpServlet {
    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("text/plain;charset=UTF-8");
        PrintWriter out = response.getWriter();
        
        try {
            String email = request.getParameter("email");
            if (email == null || email.trim().isEmpty()) {
                out.print("Email trong!");
                return;
            }
            
            UserDAO dao = new UserDAO();
            if (dao.checkEmailExists(email)) {
                out.print("duplicate");
                return;
            }
            
            // Generate code
            String code = String.format("%06d", new java.util.Random().nextInt(1000000));
            
            // Save in session
            HttpSession session = request.getSession();
            session.setAttribute("TEMP_REGISTER_CODE", code);
            session.setAttribute("TEMP_REGISTER_EMAIL", email);
            session.setAttribute("TEMP_REGISTER_CODE_EXPIRY", System.currentTimeMillis() + 5 * 60 * 1000); // 5 mins
            
            // Send email
            boolean sent = EmailUtils.sendVerificationCode(email, code);
            if (sent) {
                out.print("success");
            } else {
                out.print("Loi gui mail!");
            }
        } catch (Exception e) {
            log("Error at SendCodeAjaxController: " + e.toString());
            out.print("Loi he thong: " + e.getMessage());
        } finally {
            out.close();
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

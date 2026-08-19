package controllers.user;

import java.io.IOException;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Date;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import user.UserDAO;
import user.UserDTO;

@WebServlet(name = "ProfileController", urlPatterns = {"/ProfileController", "/ca-nhan"})
public class ProfileController extends HttpServlet {

    private static final SimpleDateFormat SDF = new SimpleDateFormat("yyyy-MM-dd");

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("text/html;charset=UTF-8");

        // Must be logged in
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("LOGIN_USER") == null) {
            response.sendRedirect("dang-nhap");
            return;
        }

        UserDTO sessionUser = (UserDTO) session.getAttribute("LOGIN_USER");
        UserDAO dao = new UserDAO();
        UserDTO profile = dao.getUserProfile(sessionUser.getUserID());

        if (profile == null) {
            // Fallback — shouldn't happen for a logged-in user
            profile = sessionUser;
        }

        request.setAttribute("PROFILE", profile);
        request.getRequestDispatcher("profile.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("text/html;charset=UTF-8");
        request.setCharacterEncoding("UTF-8");

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("LOGIN_USER") == null) {
            response.sendRedirect("dang-nhap");
            return;
        }

        UserDTO sessionUser = (UserDTO) session.getAttribute("LOGIN_USER");
        UserDAO dao = new UserDAO();
        UserDTO existing = dao.getUserProfile(sessionUser.getUserID());

        // Build updated DTO
        UserDTO updated = new UserDTO();
        updated.setUserID(sessionUser.getUserID());
        updated.setRoleID(sessionUser.getRoleID());
        updated.setPassword("***");

        // --- Full name ---
        String fullName = trim(request.getParameter("fullName"));
        updated.setFullName(fullName.isEmpty() ? sessionUser.getFullName() : fullName);

        // --- Date of birth ---
        String dobStr = trim(request.getParameter("dateOfBirth"));
        if (!dobStr.isEmpty()) {
            try {
                Date dob = SDF.parse(dobStr);
                updated.setDateOfBirth(dob);
            } catch (ParseException e) {
                updated.setDateOfBirth(null);
            }
        }

        // --- Gender ---
        String gender = trim(request.getParameter("gender"));
        updated.setGender(gender.isEmpty() ? null : gender);

        // --- Phone ---
        String phone = trim(request.getParameter("phone"));
        updated.setPhone(phone.isEmpty() ? null : phone);

        // --- Address ---
        String address = trim(request.getParameter("address"));
        updated.setAddress(address.isEmpty() ? null : address);

        // --- Height ---
        String heightStr = trim(request.getParameter("heightCm"));
        if (!heightStr.isEmpty()) {
            try { updated.setHeightCm(Double.parseDouble(heightStr)); }
            catch (NumberFormatException e) { updated.setHeightCm(null); }
        } else if (existing != null) {
            updated.setHeightCm(existing.getHeightCm());
        }

        // --- Weight ---
        String weightStr = trim(request.getParameter("weightKg"));
        if (!weightStr.isEmpty()) {
            try { updated.setWeightKg(Double.parseDouble(weightStr)); }
            catch (NumberFormatException e) { updated.setWeightKg(null); }
        } else if (existing != null) {
            updated.setWeightKg(existing.getWeightKg());
        }

        // --- Health goal ---
        String goal = trim(request.getParameter("healthGoal"));
        if (!goal.isEmpty()) {
            updated.setHealthGoal(goal);
        } else if (existing != null) {
            updated.setHealthGoal(existing.getHealthGoal());
        }

        // Persist
        boolean ok = dao.updateProfile(updated);

        if (ok) {
            // Refresh session name so navbar updates immediately
            sessionUser.setFullName(updated.getFullName());
            session.setAttribute("LOGIN_USER", sessionUser);
            session.setAttribute("PROFILE_MSG_SUCCESS", "Thông tin hồ sơ cá nhân đã được cập nhật thành công!");
        } else {
            session.setAttribute("PROFILE_MSG_ERROR", "Không thể lưu thông tin hồ sơ. Vui lòng thử lại sau.");
        }

        response.sendRedirect("ca-nhan");
    }

    private String trim(String s) {
        return s == null ? "" : s.trim();
    }
}

package controllers;

import java.io.IOException;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import notifications.OrderNotification;
import notifications.OrderNotificationDAO;
import user.UserDTO;

/**
 * Serves the dedicated Notifications page.
 * GET  → load all notifications, mark all as read, forward to notifications.jsp
 * POST → mark single notification as read (AJAX), return 200 OK
 */
@WebServlet(name = "NotificationController", urlPatterns = {"/NotificationController", "/thong-bao"})
public class NotificationController extends HttpServlet {

    private final OrderNotificationDAO dao = new OrderNotificationDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("LOGIN_USER") == null) {
            response.sendRedirect("dang-nhap");
            return;
        }

        UserDTO user = (UserDTO) session.getAttribute("LOGIN_USER");
        String username = user.getUserID();

        try {
            // Load all notifications
            List<OrderNotification> notifications = dao.getByUsername(username);
            request.setAttribute("NOTIFICATIONS", notifications);

            // Mark all as read → reset badge
            dao.markAllRead(username);
            session.setAttribute("UNREAD_NOTIF_COUNT", 0);

        } catch (Exception e) {
            log("Error at NotificationController: " + e.toString());
            request.setAttribute("NOTIFICATIONS", new java.util.ArrayList<>());
        }

        request.getRequestDispatcher("notifications.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Used for AJAX "mark single read"
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("LOGIN_USER") == null) {
            response.setStatus(401);
            return;
        }
        UserDTO user = (UserDTO) session.getAttribute("LOGIN_USER");
        try {
            int notifId = Integer.parseInt(request.getParameter("notifId"));
            dao.markRead(notifId, user.getUserID());

            // Refresh badge
            int unread = dao.countUnread(user.getUserID());
            session.setAttribute("UNREAD_NOTIF_COUNT", unread);

            response.setStatus(200);
        } catch (Exception e) {
            response.setStatus(400);
        }
    }
}

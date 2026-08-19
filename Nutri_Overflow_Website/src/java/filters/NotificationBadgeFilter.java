package filters;

import java.io.IOException;
import javax.servlet.*;
import javax.servlet.annotation.WebFilter;
import javax.servlet.http.*;
import user.UserDTO;
import notifications.OrderNotificationDAO;

@WebFilter(filterName = "NotificationBadgeFilter", urlPatterns = {"/*"})
public class NotificationBadgeFilter implements Filter {

    private final OrderNotificationDAO notifDAO = new OrderNotificationDAO();

    @Override
    public void init(FilterConfig filterConfig) throws ServletException {
        try {
            notifDAO.cleanUpDuplicates();
        } catch (Exception ignored) {}
    }

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {
        if (request instanceof HttpServletRequest) {
            HttpServletRequest httpRequest = (HttpServletRequest) request;
            HttpSession session = httpRequest.getSession(false);
            if (session != null) {
                UserDTO loginUser = (UserDTO) session.getAttribute("LOGIN_USER");
                if (loginUser != null) {
                    int unread = notifDAO.countUnread(loginUser.getUserID());
                    session.setAttribute("UNREAD_NOTIF_COUNT", unread);
                }
            }
        }
        chain.doFilter(request, response);
    }

    @Override
    public void destroy() {}
}

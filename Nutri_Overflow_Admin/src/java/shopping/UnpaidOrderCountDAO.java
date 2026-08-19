package shopping;

import notifications.OrderNotificationDAO;
import utils.DBUtils;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

/**
 * Counts unread Order_Notifications for a given user.
 * Used by the navbar notification bell badge.
 */
public class UnpaidOrderCountDAO {

    private final OrderNotificationDAO notifDAO = new OrderNotificationDAO();

    /**
     * Returns count of unread notifications (used for bell badge).
     */
    public int getUnreadNotifCount(String username) {
        return notifDAO.countUnread(username);
    }

    /**
     * Legacy alias kept for backward compatibility.
     * Now delegates to unread notification count.
     */
    public int getFailedOrderCount(String username) {
        return getUnreadNotifCount(username);
    }
}

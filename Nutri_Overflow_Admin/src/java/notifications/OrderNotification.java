package notifications;

import java.util.Date;

/**
 * Represents a single order-related notification for a user.
 * Types: PAYMENT_FAILED | PAYMENT_SUCCESS | ORDER_CANCELLED | ORDER_SHIPPED
 */
public class OrderNotification {

    private int     notifId;
    private String  username;
    private int     orderId;
    private String  type;
    private String  title;
    private String  message;
    private boolean read;
    private Date    createdAt;

    public OrderNotification() {}

    // ── Getters / Setters ──────────────────────────────────────────
    public int     getNotifId()              { return notifId; }
    public void    setNotifId(int v)         { this.notifId = v; }

    public String  getUsername()             { return username; }
    public void    setUsername(String v)     { this.username = v; }

    public int     getOrderId()              { return orderId; }
    public void    setOrderId(int v)         { this.orderId = v; }

    public String  getType()                 { return type; }
    public void    setType(String v)         { this.type = v; }

    public String  getTitle()                { return title; }
    public void    setTitle(String v)        { this.title = v; }

    public String  getMessage()              { return message; }
    public void    setMessage(String v)      { this.message = v; }

    public boolean isRead()                  { return read; }
    public void    setRead(boolean v)        { this.read = v; }

    public Date    getCreatedAt()            { return createdAt; }
    public void    setCreatedAt(Date v)      { this.createdAt = v; }

    // ── View Helpers ───────────────────────────────────────────────

    /** FontAwesome icon class for each notification type */
    public String getTypeIcon() {
        if (type == null) return "fa-bell";
        switch (type) {
            case "PAYMENT_FAILED":  return "fa-times-circle";
            case "PAYMENT_SUCCESS": return "fa-check-circle";
            case "ORDER_CANCELLED": return "fa-ban";
            case "ORDER_SHIPPED":   return "fa-truck";
            default:                return "fa-bell";
        }
    }

    /** CSS class for icon color */
    public String getTypeColorClass() {
        if (type == null) return "notif-default";
        switch (type) {
            case "PAYMENT_FAILED":  return "notif-failed";
            case "PAYMENT_SUCCESS": return "notif-success";
            case "ORDER_CANCELLED": return "notif-cancelled";
            case "ORDER_SHIPPED":   return "notif-shipped";
            default:                return "notif-default";
        }
    }

    /** Whether this notification has an associated retryable action */
    public boolean isRetryable() {
        return "PAYMENT_FAILED".equals(type);
    }
}

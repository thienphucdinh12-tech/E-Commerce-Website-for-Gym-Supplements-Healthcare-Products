package shopping;

import java.util.Date;

public class OrderTrackingLog {
    private int trackingId;
    private String status;
    private String description;
    private Date updatedAt;

    public OrderTrackingLog() {
    }

    public OrderTrackingLog(int trackingId, String status, String description, Date updatedAt) {
        this.trackingId = trackingId;
        this.status = status;
        this.description = description;
        this.updatedAt = updatedAt;
    }

    public int getTrackingId() {
        return trackingId;
    }

    public void setTrackingId(int trackingId) {
        this.trackingId = trackingId;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public Date getUpdatedAt() {
        return updatedAt;
    }

    public void setUpdatedAt(Date updatedAt) {
        this.updatedAt = updatedAt;
    }
}

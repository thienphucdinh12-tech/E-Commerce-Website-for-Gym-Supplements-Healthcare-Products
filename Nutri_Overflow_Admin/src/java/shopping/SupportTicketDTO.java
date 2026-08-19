package shopping;

import java.io.Serializable;
import java.sql.Timestamp;

public class SupportTicketDTO implements Serializable {
    private int ticketId;
    private Integer userId;
    private Integer orderId;
    private String category;
    private String title;
    private String description;
    private String status;
    private Integer assignedStaffId;
    private String feedback;
    private Timestamp createdAt;
    private Timestamp updatedAt;
    
    // Additional join fields
    private String customerName;
    private String staffName;

    public SupportTicketDTO() {
    }

    public SupportTicketDTO(int ticketId, Integer userId, Integer orderId, String category, String title, 
                            String description, String status, Integer assignedStaffId, String feedback, 
                            Timestamp createdAt, Timestamp updatedAt) {
        this.ticketId = ticketId;
        this.userId = userId;
        this.orderId = orderId;
        this.category = category;
        this.title = title;
        this.description = description;
        this.status = status;
        this.assignedStaffId = assignedStaffId;
        this.feedback = feedback;
        this.createdAt = createdAt;
        this.updatedAt = updatedAt;
    }

    public int getTicketId() {
        return ticketId;
    }

    public void setTicketId(int ticketId) {
        this.ticketId = ticketId;
    }

    public Integer getUserId() {
        return userId;
    }

    public void setUserId(Integer userId) {
        this.userId = userId;
    }

    public Integer getOrderId() {
        return orderId;
    }

    public void setOrderId(Integer orderId) {
        this.orderId = orderId;
    }

    public String getCategory() {
        return category;
    }

    public void setCategory(String category) {
        this.category = category;
    }

    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public Integer getAssignedStaffId() {
        return assignedStaffId;
    }

    public void setAssignedStaffId(Integer assignedStaffId) {
        this.assignedStaffId = assignedStaffId;
    }

    public String getFeedback() {
        return feedback;
    }

    public void setFeedback(String feedback) {
        this.feedback = feedback;
    }

    public Timestamp getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }

    public Timestamp getUpdatedAt() {
        return updatedAt;
    }

    public void setUpdatedAt(Timestamp updatedAt) {
        this.updatedAt = updatedAt;
    }

    public String getCustomerName() {
        return customerName;
    }

    public void setCustomerName(String customerName) {
        this.customerName = customerName;
    }

    public String getStaffName() {
        return staffName;
    }

    public void setStaffName(String staffName) {
        this.staffName = staffName;
    }
}

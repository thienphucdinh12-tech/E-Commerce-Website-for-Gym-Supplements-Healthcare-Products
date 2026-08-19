package shopping;

import java.io.Serializable;
import java.sql.Timestamp;

public class ChatSessionDTO implements Serializable {
    private int sessionId;
    private Integer customerId;
    private String customerName;
    private String status;
    private Integer assignedStaffId;
    private Timestamp lastMessageAt;
    private Timestamp createdAt;
    
    // Join fields
    private String staffName;
    private String lastMessageText;

    public ChatSessionDTO() {
    }

    public ChatSessionDTO(int sessionId, Integer customerId, String customerName, String status, 
                          Integer assignedStaffId, Timestamp lastMessageAt, Timestamp createdAt) {
        this.sessionId = sessionId;
        this.customerId = customerId;
        this.customerName = customerName;
        this.status = status;
        this.assignedStaffId = assignedStaffId;
        this.lastMessageAt = lastMessageAt;
        this.createdAt = createdAt;
    }

    public int getSessionId() {
        return sessionId;
    }

    public void setSessionId(int sessionId) {
        this.sessionId = sessionId;
    }

    public Integer getCustomerId() {
        return customerId;
    }

    public void setCustomerId(Integer customerId) {
        this.customerId = customerId;
    }

    public String getCustomerName() {
        return customerName;
    }

    public void setCustomerName(String customerName) {
        this.customerName = customerName;
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

    public Timestamp getLastMessageAt() {
        return lastMessageAt;
    }

    public void setLastMessageAt(Timestamp lastMessageAt) {
        this.lastMessageAt = lastMessageAt;
    }

    public Timestamp getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }

    public String getStaffName() {
        return staffName;
    }

    public void setStaffName(String staffName) {
        this.staffName = staffName;
    }

    public String getLastMessageText() {
        return lastMessageText;
    }

    public void setLastMessageText(String lastMessageText) {
        this.lastMessageText = lastMessageText;
    }
}

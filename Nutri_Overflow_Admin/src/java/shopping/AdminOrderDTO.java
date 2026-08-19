package shopping;

import java.util.Date;
import java.util.List;

public class AdminOrderDTO {
    private int orderId;
    private Date orderDate;
    private String status;
    private double totalAmount;
    private double discountApplied;
    private String paymentMethod;
    private String paymentStatus;
    private String shippingAddress;
    private String note;
    private String ghnOrderCode;
    private String customerName;
    private List<AdminOrderItemDTO> items;

    public AdminOrderDTO() {}

    public AdminOrderDTO(int orderId, Date orderDate, String status, double totalAmount,
                         double discountApplied, String paymentMethod, String paymentStatus,
                         String shippingAddress, String note, String ghnOrderCode, String customerName) {
        this.orderId = orderId;
        this.orderDate = orderDate;
        this.status = status;
        this.totalAmount = totalAmount;
        this.discountApplied = discountApplied;
        this.paymentMethod = paymentMethod;
        this.paymentStatus = paymentStatus;
        this.shippingAddress = shippingAddress;
        this.note = note;
        this.ghnOrderCode = ghnOrderCode;
        this.customerName = customerName;
    }

    public int getOrderId() { return orderId; }
    public void setOrderId(int orderId) { this.orderId = orderId; }

    public Date getOrderDate() { return orderDate; }
    public void setOrderDate(Date orderDate) { this.orderDate = orderDate; }

    public String getStatus() { return status != null ? status.toUpperCase() : null; }
    public void setStatus(String status) { this.status = status; }

    public double getTotalAmount() { return totalAmount; }
    public void setTotalAmount(double totalAmount) { this.totalAmount = totalAmount; }

    public double getDiscountApplied() { return discountApplied; }
    public void setDiscountApplied(double discountApplied) { this.discountApplied = discountApplied; }

    public String getPaymentMethod() { return paymentMethod; }
    public void setPaymentMethod(String paymentMethod) { this.paymentMethod = paymentMethod; }

    public String getPaymentStatus() { return paymentStatus; }
    public void setPaymentStatus(String paymentStatus) { this.paymentStatus = paymentStatus; }

    public String getShippingAddress() { return shippingAddress; }
    public void setShippingAddress(String shippingAddress) { this.shippingAddress = shippingAddress; }

    public String getNote() { return note; }
    public void setNote(String note) { this.note = note; }

    public String getGhnOrderCode() { return ghnOrderCode; }
    public void setGhnOrderCode(String ghnOrderCode) { this.ghnOrderCode = ghnOrderCode; }

    public String getCustomerName() { return customerName; }
    public void setCustomerName(String customerName) { this.customerName = customerName; }

    public List<AdminOrderItemDTO> getItems() { return items; }
    public void setItems(List<AdminOrderItemDTO> items) { this.items = items; }

    // Helpers for JSP Display
    public String getStatusLabel() {
        if (status == null) return "Không rõ";
        switch (status.toUpperCase()) {
            case "PENDING":    return "Chờ xác nhận";
            case "PROCESSING": return "Đang xử lý (Đóng gói)";
            case "DELIVERING":
            case "SHIPPING":   return "Đang giao hàng";
            case "DELIVERED":  return "Đã giao thành công";
            case "CANCELLED":  return "Đã huỷ";
            default:           return status;
        }
    }

    public String getStatusColor() {
        if (status == null) return "secondary";
        switch (status.toUpperCase()) {
            case "PENDING":    return "warning";
            case "PROCESSING": return "info";
            case "DELIVERING":
            case "SHIPPING":   return "primary";
            case "DELIVERED":  return "success";
            case "CANCELLED":  return "danger";
            default:           return "secondary";
        }
    }

    public String getPaymentStatusLabel() {
        if (paymentStatus == null) return "Chưa thanh toán";
        switch (paymentStatus.toUpperCase()) {
            case "PAID":   return "Đã thanh toán";
            case "FAILED": return "Thất bại";
            default:       return "Chưa thanh toán";
        }
    }

    public String getPaymentStatusColor() {
        if (paymentStatus == null) return "danger";
        if ("PAID".equalsIgnoreCase(paymentStatus)) return "success";
        return "danger";
    }
}

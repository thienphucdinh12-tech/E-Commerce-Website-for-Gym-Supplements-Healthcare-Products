package shopping;

import java.util.Date;
import java.util.List;

/**
 * Represents a single Order with its line items, for the Order History feature.
 */
public class OrderHistory {
    private int orderId;
    private Date orderDate;
    private String status;
    private double totalAmount;
    private String paymentMethod;
    private String shippingAddress;
    private String note;
    private double discountApplied;
    private String paymentStatus; // UNPAID, PENDING, PAID, FAILED
    private List<OrderItem> items;

    // ── Inner class: one line item ──
    public static class OrderItem {
        private String productName;
        private int quantity;
        private double priceAtPurchase;

        public OrderItem(String productName, int quantity, double priceAtPurchase) {
            this.productName = productName;
            this.quantity = quantity;
            this.priceAtPurchase = priceAtPurchase;
        }

        public String getProductName() { return productName; }
        public int getQuantity()       { return quantity; }
        public double getPriceAtPurchase() { return priceAtPurchase; }
        public double getSubtotal()    { return quantity * priceAtPurchase; }
    }

    // ── Constructor ──
    public OrderHistory() {}
    public OrderHistory(int orderId, Date orderDate, String status,
                        double totalAmount, String paymentMethod,
                        String shippingAddress, String note, double discountApplied) {
        this.orderId = orderId;
        this.orderDate = orderDate;
        this.status = status;
        this.totalAmount = totalAmount;
        this.paymentMethod = paymentMethod;
        this.shippingAddress = shippingAddress;
        this.note = note;
        this.discountApplied = discountApplied;
    }

    // ── Getters / Setters ──
    public int getOrderId()             { return orderId; }
    public void setOrderId(int orderId) { this.orderId = orderId; }

    public Date getOrderDate()               { return orderDate; }
    public void setOrderDate(Date orderDate) { this.orderDate = orderDate; }

    public String getStatus()              { return status; }
    public void setStatus(String status)   { this.status = status; }

    public double getTotalAmount()                   { return totalAmount; }
    public void setTotalAmount(double totalAmount)   { this.totalAmount = totalAmount; }

    public String getPaymentMethod()                       { return paymentMethod; }
    public void setPaymentMethod(String paymentMethod)     { this.paymentMethod = paymentMethod; }

    public String getShippingAddress()                     { return shippingAddress; }
    public void setShippingAddress(String shippingAddress) { this.shippingAddress = shippingAddress; }

    public String getNote()            { return note; }
    public void setNote(String note)   { this.note = note; }

    public double getDiscountApplied()                     { return discountApplied; }
    public void setDiscountApplied(double discountApplied) { this.discountApplied = discountApplied; }

    public String getPaymentStatus()                       { return paymentStatus; }
    public void setPaymentStatus(String paymentStatus)     { this.paymentStatus = paymentStatus; }

    /**
     * Returns true if payment has FAILED (strict — for display-only badge logic).
     */
    public boolean isPaymentFailed() {
        return "FAILED".equalsIgnoreCase(paymentStatus);
    }

    /**
     * Returns true if this order is eligible for a retry payment attempt.
     * Covers: FAILED (VNPay refused) | PENDING (VNPay never responded / tab closed) | UNPAID (not yet sent to VNPay)
     */
    public boolean isRetryable() {
        if (paymentStatus == null) return false;
        switch (paymentStatus.toUpperCase()) {
            case "FAILED":
            case "PENDING":
            case "UNPAID":  return true;
            default:        return false;
        }
    }

    /**
     * Returns a human-readable reason label shown on the retry button.
     */
    public String getRetryableLabel() {
        if (paymentStatus == null) return "Thanh toán lại";
        switch (paymentStatus.toUpperCase()) {
            case "FAILED":  return "Thanh toán thất bại — Thử lại";
            case "PENDING": return "Chưa hoàn tất — Tiếp tục thanh toán";
            case "UNPAID":  return "Chưa thanh toán — Thanh toán ngay";
            default:        return "Thanh toán lại";
        }
    }

    public List<OrderItem> getItems()              { return items; }
    public void setItems(List<OrderItem> items)    { this.items = items; }

    /** Convenience: count total quantity across all items */
    public int getTotalItems() {
        if (items == null) return 0;
        return items.stream().mapToInt(OrderItem::getQuantity).sum();
    }

    /**
     * Maps DB status string to a Vietnamese label.
     */
    public String getStatusLabel() {
        if (status == null) return "Không rõ";
        switch (status.toUpperCase()) {
            case "PENDING":    return "Chờ xác nhận";
            case "PROCESSING": return "Đang xử lý";
            case "DELIVERING": return "Đang giao hàng";
            case "DELIVERED":  return "Đã giao thành công";
            case "CANCELLED":  return "Đã huỷ";
            default:           return status;
        }
    }

    /**
     * Returns a Bootstrap color class for badge based on status.
     */
    public String getStatusColor() {
        if (status == null) return "secondary";
        switch (status.toUpperCase()) {
            case "PENDING":    return "warning";
            case "PROCESSING": return "info";
            case "DELIVERING": return "primary";
            case "DELIVERED":  return "success";
            case "CANCELLED":  return "danger";
            default:           return "secondary";
        }
    }

    /**
     * Returns step index (1-4) for the timeline progress bar.
     *  1=PENDING, 2=PROCESSING, 3=DELIVERING, 4=DELIVERED
     */
    public int getTimelineStep() {
        if (status == null) return 0;
        switch (status.toUpperCase()) {
            case "PENDING":    return 1;
            case "PROCESSING": return 2;
            case "DELIVERING": return 3;
            case "DELIVERED":  return 4;
            case "CANCELLED":  return -1;
            default:           return 0;
        }
    }
}

package shopping;

import java.sql.Timestamp;

public class Coupon {
    private int id;
    private String code;
    private double discountAmount;
    private int discountPercent;
    private double minOrderValue;
    private Integer usageLimit;
    private int usedCount;
    private Timestamp expiryDate;
    private boolean active;

    public Coupon() {}

    public Coupon(int id, String code, double discountAmount, int discountPercent, double minOrderValue, Integer usageLimit, int usedCount, Timestamp expiryDate, boolean active) {
        this.id = id;
        this.code = code;
        this.discountAmount = discountAmount;
        this.discountPercent = discountPercent;
        this.minOrderValue = minOrderValue;
        this.usageLimit = usageLimit;
        this.usedCount = usedCount;
        this.expiryDate = expiryDate;
        this.active = active;
    }

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public String getCode() { return code; }
    public void setCode(String code) { this.code = code; }

    public double getDiscountAmount() { return discountAmount; }
    public void setDiscountAmount(double discountAmount) { this.discountAmount = discountAmount; }

    public int getDiscountPercent() { return discountPercent; }
    public void setDiscountPercent(int discountPercent) { this.discountPercent = discountPercent; }

    public double getMinOrderValue() { return minOrderValue; }
    public void setMinOrderValue(double minOrderValue) { this.minOrderValue = minOrderValue; }

    public Integer getUsageLimit() { return usageLimit; }
    public void setUsageLimit(Integer usageLimit) { this.usageLimit = usageLimit; }

    public int getUsedCount() { return usedCount; }
    public void setUsedCount(int usedCount) { this.usedCount = usedCount; }

    public Timestamp getExpiryDate() { return expiryDate; }
    public void setExpiryDate(Timestamp expiryDate) { this.expiryDate = expiryDate; }

    public boolean isActive() { return active; }
    public void setActive(boolean active) { this.active = active; }
}

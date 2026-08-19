package shopping;

/**
 * Represents a coupon validation result returned by CouponDAO.
 */
public class CouponDTO {
    private String  code;
    private int     discountPct;      // e.g. 10 means 10% off
    private double  discountAmount;   // Flat discount amount
    private boolean valid;
    private String  errorMsg;

    public CouponDTO() {}

    /** Constructor for a valid coupon with percent or amount */
    public CouponDTO(String code, int discountPct, double discountAmount) {
        this.code           = code;
        this.discountPct    = discountPct;
        this.discountAmount = discountAmount;
        this.valid          = true;
        this.errorMsg       = null;
    }

    /** Constructor for a valid coupon (backward compatible) */
    public CouponDTO(String code, int discountPct) {
        this(code, discountPct, 0.0);
    }

    /** Constructor for an invalid/expired coupon */
    public CouponDTO(String code, String errorMsg) {
        this.code           = code;
        this.discountPct    = 0;
        this.discountAmount = 0.0;
        this.valid          = false;
        this.errorMsg       = errorMsg;
    }

    public String  getCode()        { return code; }
    public void    setCode(String code) { this.code = code; }

    public int     getDiscountPct() { return discountPct; }
    public void    setDiscountPct(int discountPct) { this.discountPct = discountPct; }

    public double  getDiscountAmount() { return discountAmount; }
    public void    setDiscountAmount(double discountAmount) { this.discountAmount = discountAmount; }

    public boolean isValid()        { return valid; }
    public void    setValid(boolean valid) { this.valid = valid; }

    public String  getErrorMsg()    { return errorMsg; }
    public void    setErrorMsg(String errorMsg) { this.errorMsg = errorMsg; }

    /**
     * Calculates the discount amount given the cart subtotal.
     * @param subtotal cart total before discount
     * @return discount amount (always >= 0)
     */
    public double calcDiscount(double subtotal) {
        if (!valid) return 0;
        if (discountPct > 0) {
            return Math.round(subtotal * discountPct / 100.0 * 100) / 100.0;
        }
        return Math.min(subtotal, discountAmount);
    }
}

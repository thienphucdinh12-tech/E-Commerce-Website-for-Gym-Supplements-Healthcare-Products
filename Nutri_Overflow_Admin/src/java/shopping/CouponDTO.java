package shopping;

/**
 * Represents a coupon validation result returned by CouponDAO.
 */
public class CouponDTO {
    private String  code;
    private int     discountPct;  // e.g. 10 means 10% off
    private boolean valid;
    private String  errorMsg;

    public CouponDTO() {}

    /** Constructor for a valid coupon */
    public CouponDTO(String code, int discountPct) {
        this.code        = code;
        this.discountPct = discountPct;
        this.valid       = true;
        this.errorMsg    = null;
    }

    /** Constructor for an invalid/expired coupon */
    public CouponDTO(String code, String errorMsg) {
        this.code        = code;
        this.discountPct = 0;
        this.valid       = false;
        this.errorMsg    = errorMsg;
    }

    public String  getCode()        { return code; }
    public void    setCode(String code) { this.code = code; }

    public int     getDiscountPct() { return discountPct; }
    public void    setDiscountPct(int discountPct) { this.discountPct = discountPct; }

    public boolean isValid()        { return valid; }
    public void    setValid(boolean valid) { this.valid = valid; }

    public String  getErrorMsg()    { return errorMsg; }
    public void    setErrorMsg(String errorMsg) { this.errorMsg = errorMsg; }

    /**
     * Calculates the discount amount given the cart subtotal.
     * @param subtotal cart total before discount
     * @return discount amount (always &gt;= 0)
     */
    public double calcDiscount(double subtotal) {
        if (!valid || discountPct <= 0) return 0;
        return Math.round(subtotal * discountPct / 100.0 * 100) / 100.0;
    }
}

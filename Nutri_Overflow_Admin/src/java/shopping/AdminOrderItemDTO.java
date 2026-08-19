package shopping;

public class AdminOrderItemDTO {
    private int productId;
    private String productName;
    private String sku;
    private String imageUrl;
    private int quantity;
    private double priceAtPurchase;

    public AdminOrderItemDTO() {}

    public AdminOrderItemDTO(int productId, String productName, String sku,
                             String imageUrl, int quantity, double priceAtPurchase) {
        this.productId = productId;
        this.productName = productName;
        this.sku = sku;
        this.imageUrl = imageUrl;
        this.quantity = quantity;
        this.priceAtPurchase = priceAtPurchase;
    }

    public int getProductId() { return productId; }
    public void setProductId(int productId) { this.productId = productId; }

    public String getProductName() { return productName; }
    public void setProductName(String productName) { this.productName = productName; }

    public String getSku() { return sku; }
    public void setSku(String sku) { this.sku = sku; }

    public String getImageUrl() { return imageUrl; }
    public void setImageUrl(String imageUrl) { this.imageUrl = imageUrl; }

    public int getQuantity() { return quantity; }
    public void setQuantity(int quantity) { this.quantity = quantity; }

    public double getPriceAtPurchase() { return priceAtPurchase; }
    public void setPriceAtPurchase(double priceAtPurchase) { this.priceAtPurchase = priceAtPurchase; }

    public double getSubtotal() { return quantity * priceAtPurchase; }
}

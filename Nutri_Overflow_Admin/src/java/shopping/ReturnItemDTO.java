package shopping;

public class ReturnItemDTO {
    private int productId;
    private String productName;
    private String sku;
    private String imageUrl;
    private int quantity;
    private String condition; // SEALED, DAMAGED
    private String action;    // RESTOCK, DISCARD
    private String notes;

    public ReturnItemDTO() {}

    public ReturnItemDTO(int productId, String productName, String sku, String imageUrl,
                         int quantity, String condition, String action, String notes) {
        this.productId = productId;
        this.productName = productName;
        this.sku = sku;
        this.imageUrl = imageUrl;
        this.quantity = quantity;
        this.condition = condition;
        this.action = action;
        this.notes = notes;
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

    public String getCondition() { return condition; }
    public void setCondition(String condition) { this.condition = condition; }

    public String getAction() { return action; }
    public void setAction(String action) { this.action = action; }

    public String getNotes() { return notes; }
    public void setNotes(String notes) { this.notes = notes; }
}

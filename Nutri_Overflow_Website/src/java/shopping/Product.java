package shopping;

public class Product {
    private String id;
    private String name;
    private String description;
    private double price;
    private Double discountPrice;   // Giá sau khi giảm (null nếu không giảm)
    private int discountPercent;    // % giảm giá (0 nếu không giảm)
    private boolean flashSale;      // true nếu là Sale Sốc (>30%)
    private int soldCount;          // Số lượng đã bán
    private int quantity;
    private String imageUrl;

    public Product() {}

    public Product(String id, String name, String description, double price, int quantity, String imageUrl) {
        this.id = id;
        this.name = name;
        this.description = description;
        this.price = price;
        this.quantity = quantity;
        this.imageUrl = imageUrl;
    }

    // Constructor đầy đủ với thông tin giảm giá
    public Product(String id, String name, String description, double price,
                   Double discountPrice, int discountPercent, boolean flashSale,
                   int soldCount, int quantity, String imageUrl) {
        this.id = id;
        this.name = name;
        this.description = description;
        this.price = price;
        this.discountPrice = discountPrice;
        this.discountPercent = discountPercent;
        this.flashSale = flashSale;
        this.soldCount = soldCount;
        this.quantity = quantity;
        this.imageUrl = imageUrl;
    }

    public String getId() { return id; }
    public void setId(String id) { this.id = id; }
    public String getName() { return name; }
    public void setName(String name) { this.name = name; }
    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }
    public double getPrice() { return price; }
    public void setPrice(double price) { this.price = price; }
    public Double getDiscountPrice() { return discountPrice; }
    public void setDiscountPrice(Double discountPrice) { this.discountPrice = discountPrice; }
    public int getDiscountPercent() { return discountPercent; }
    public void setDiscountPercent(int discountPercent) { this.discountPercent = discountPercent; }
    public boolean isFlashSale() { return flashSale; }
    public void setFlashSale(boolean flashSale) { this.flashSale = flashSale; }
    public int getSoldCount() { return soldCount; }
    public void setSoldCount(int soldCount) { this.soldCount = soldCount; }
    public int getQuantity() { return quantity; }
    public void setQuantity(int quantity) { this.quantity = quantity; }
    public String getImageUrl() { return imageUrl; }
    public void setImageUrl(String imageUrl) { this.imageUrl = imageUrl; }
}
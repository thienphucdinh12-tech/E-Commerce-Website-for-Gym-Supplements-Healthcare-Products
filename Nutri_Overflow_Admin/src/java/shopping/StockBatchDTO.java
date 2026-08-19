package shopping;

import java.util.Date;

public class StockBatchDTO {
    private int stockId;
    private int productId;
    private String productName;
    private String sku;
    private String staffName;
    private int quantity;
    private String batchNumber;
    private Date mfgDate;
    private Date expDate;
    private String distributorName;
    private Date updatedAt;

    public StockBatchDTO() {}

    public StockBatchDTO(int stockId, int productId, String productName, String sku, String staffName,
                         int quantity, String batchNumber, Date mfgDate, Date expDate, String distributorName, Date updatedAt) {
        this.stockId = stockId;
        this.productId = productId;
        this.productName = productName;
        this.sku = sku;
        this.staffName = staffName;
        this.quantity = quantity;
        this.batchNumber = batchNumber;
        this.mfgDate = mfgDate;
        this.expDate = expDate;
        this.distributorName = distributorName;
        this.updatedAt = updatedAt;
    }

    public int getStockId() { return stockId; }
    public void setStockId(int stockId) { this.stockId = stockId; }

    public int getProductId() { return productId; }
    public void setProductId(int productId) { this.productId = productId; }

    public String getProductName() { return productName; }
    public void setProductName(String productName) { this.productName = productName; }

    public String getSku() { return sku; }
    public void setSku(String sku) { this.sku = sku; }

    public String getStaffName() { return staffName; }
    public void setStaffName(String staffName) { this.staffName = staffName; }

    public int getQuantity() { return quantity; }
    public void setQuantity(int quantity) { this.quantity = quantity; }

    public String getBatchNumber() { return batchNumber; }
    public void setBatchNumber(String batchNumber) { this.batchNumber = batchNumber; }

    public Date getMfgDate() { return mfgDate; }
    public void setMfgDate(Date mfgDate) { this.mfgDate = mfgDate; }

    public Date getExpDate() { return expDate; }
    public void setExpDate(Date expDate) { this.expDate = expDate; }

    public String getDistributorName() { return distributorName; }
    public void setDistributorName(String distributorName) { this.distributorName = distributorName; }

    public Date getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(Date updatedAt) { this.updatedAt = updatedAt; }
}

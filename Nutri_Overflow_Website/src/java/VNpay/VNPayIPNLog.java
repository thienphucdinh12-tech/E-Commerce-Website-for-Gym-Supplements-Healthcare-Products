/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package VNpay;

import java.sql.Timestamp;

/**
 *
 * @author ADMIN
 */
public class VNPayIPNLog {
        private int id;
    private Integer orderId;
    private String vnpTmnCode;
    private long vnpAmount;
    private String vnpBankCode;
    private String vnpBankTranNo;
    private String vnpCardType;
    private String vnpOrderInfo;
    private String vnpTransactionNo;
    private String vnpResponseCode;
    private String vnpTransactionStatus;
    private String vnpTxnRef;
    private String vnpSecureHash;
    private boolean isValidSignature;
    private String rawParams;
    private Timestamp createdAt;

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public Integer getOrderId() {
        return orderId;
    }

    public void setOrderId(Integer orderId) {
        this.orderId = orderId;
    }

    public String getVnpTmnCode() {
        return vnpTmnCode;
    }

    public void setVnpTmnCode(String vnpTmnCode) {
        this.vnpTmnCode = vnpTmnCode;
    }

    public long getVnpAmount() {
        return vnpAmount;
    }

    public void setVnpAmount(long vnpAmount) {
        this.vnpAmount = vnpAmount;
    }

    public String getVnpBankCode() {
        return vnpBankCode;
    }

    public void setVnpBankCode(String vnpBankCode) {
        this.vnpBankCode = vnpBankCode;
    }

    public String getVnpBankTranNo() {
        return vnpBankTranNo;
    }

    public void setVnpBankTranNo(String vnpBankTranNo) {
        this.vnpBankTranNo = vnpBankTranNo;
    }

    public String getVnpCardType() {
        return vnpCardType;
    }

    public void setVnpCardType(String vnpCardType) {
        this.vnpCardType = vnpCardType;
    }

    public String getVnpOrderInfo() {
        return vnpOrderInfo;
    }

    public void setVnpOrderInfo(String vnpOrderInfo) {
        this.vnpOrderInfo = vnpOrderInfo;
    }

    public String getVnpTransactionNo() {
        return vnpTransactionNo;
    }

    public void setVnpTransactionNo(String vnpTransactionNo) {
        this.vnpTransactionNo = vnpTransactionNo;
    }

    public String getVnpResponseCode() {
        return vnpResponseCode;
    }

    public void setVnpResponseCode(String vnpResponseCode) {
        this.vnpResponseCode = vnpResponseCode;
    }

    public String getVnpTransactionStatus() {
        return vnpTransactionStatus;
    }

    public void setVnpTransactionStatus(String vnpTransactionStatus) {
        this.vnpTransactionStatus = vnpTransactionStatus;
    }

    public String getVnpTxnRef() {
        return vnpTxnRef;
    }

    public void setVnpTxnRef(String vnpTxnRef) {
        this.vnpTxnRef = vnpTxnRef;
    }

    public String getVnpSecureHash() {
        return vnpSecureHash;
    }

    public void setVnpSecureHash(String vnpSecureHash) {
        this.vnpSecureHash = vnpSecureHash;
    }

    public boolean isIsValidSignature() {
        return isValidSignature;
    }

    public void setIsValidSignature(boolean isValidSignature) {
        this.isValidSignature = isValidSignature;
    }

    public String getRawParams() {
        return rawParams;
    }

    public void setRawParams(String rawParams) {
        this.rawParams = rawParams;
    }

    public Timestamp getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }
    
}

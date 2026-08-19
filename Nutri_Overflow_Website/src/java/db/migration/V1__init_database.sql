SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

-- ==========================================
-- 1. CREATE INDEPENDENT TABLES
-- ==========================================

-- 1.1 Categories
CREATE TABLE Categories (
    category_id INT IDENTITY(1,1) PRIMARY KEY,
    name NVARCHAR(100) NOT NULL,
    description NVARCHAR(MAX),
    is_active BIT DEFAULT 1, 
    created_at DATETIME DEFAULT GETDATE()
);

-- 1.2 Account
CREATE TABLE Account (
    account_id INT IDENTITY(1,1) PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL, 
    email VARCHAR(100) NULL,
    role VARCHAR(20) DEFAULT 'CUSTOMER', 
    is_active BIT DEFAULT 1,
    created_at DATETIME DEFAULT GETDATE()
);
GO
CREATE UNIQUE NONCLUSTERED INDEX UX_Account_Email ON Account(email) WHERE email IS NOT NULL;
GO

-- 1.3 Customer 
CREATE TABLE Customer (
    user_id INT IDENTITY(1,1) PRIMARY KEY,
    account_id INT,
    full_name NVARCHAR(100),
    phone VARCHAR(20),
    address NVARCHAR(255),
    amount_in DECIMAL(12, 2) DEFAULT 0,
    date_of_birth DATE NULL,
    gender        NVARCHAR(10) NULL,
    height_cm     FLOAT NULL,
    weight_kg     FLOAT NULL,
    health_goal   NVARCHAR(50) NULL, 
    points        INT DEFAULT 0 NOT NULL,
    FOREIGN KEY (account_id) REFERENCES Account(account_id) ON DELETE CASCADE
);

-- 1.4 Staff
CREATE TABLE Staff (
    staff_id INT IDENTITY(1,1) PRIMARY KEY,
    account_id INT,
    full_name NVARCHAR(100),
    phone VARCHAR(20),
    position NVARCHAR(50),
    FOREIGN KEY (account_id) REFERENCES Account(account_id) ON DELETE CASCADE
);

-- 1.5 Coupons
CREATE TABLE Coupons (
    coupon_id INT IDENTITY(1,1) PRIMARY KEY,
    code VARCHAR(50) UNIQUE NOT NULL, 
    discount_amount DECIMAL(12, 2) DEFAULT 0, 
    discount_percent INT DEFAULT 0, 
    min_order_value DECIMAL(12, 2) DEFAULT 0, 
    usage_limit INT NULL, 
    used_count INT DEFAULT 0, 
    expiry_date DATETIME NULL, 
    is_active BIT DEFAULT 1
);

-- 1.6 System Configuration (Points rules, etc.)
CREATE TABLE System_Config (
    config_key VARCHAR(100) PRIMARY KEY,
    config_value NVARCHAR(500) NOT NULL,
    description NVARCHAR(255) NULL
);

-- ==========================================
-- 2. CREATE DEPENDENT TABLES
-- ==========================================

-- 2.1 Products 
CREATE TABLE Products (
    product_id INT IDENTITY(1,1) PRIMARY KEY,
    category_id INT,
    sku VARCHAR(50) UNIQUE, 
    name NVARCHAR(255) NOT NULL,
    description NVARCHAR(MAX),
    price DECIMAL(12, 2) NOT NULL,
    discount_price DECIMAL(12, 2), 
    discount_percent INT DEFAULT 0, 
    is_flash_sale BIT DEFAULT 0,        
    stock_quantity INT DEFAULT 0,      
    image_url VARCHAR(255) DEFAULT 'default-product.jpg',
    medical_warning NVARCHAR(MAX) NULL,
    sold_count INT DEFAULT 0, 
    is_bestseller BIT DEFAULT 0, 
    is_active BIT DEFAULT 1, 
    created_at DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (category_id) REFERENCES Categories(category_id) ON DELETE SET NULL
);

-- 2.2 Stock (Bao gồm các cột quản lý lô hàng hàng hóa)
CREATE TABLE Stock (
    stock_id INT IDENTITY(1,1) PRIMARY KEY,
    product_id INT,
    staff_id INT NULL,
    quantity INT NOT NULL DEFAULT 0, 
    batch_number VARCHAR(50) NULL,
    mfg_date DATE NULL,
    exp_date DATE NULL,
    updated_at DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (product_id) REFERENCES Products(product_id) ON DELETE CASCADE,
    FOREIGN KEY (staff_id) REFERENCES Staff(staff_id) ON DELETE NO ACTION
);

-- 2.3 Product Images Gallery
CREATE TABLE Product_Images (
    image_id INT IDENTITY(1,1) PRIMARY KEY,
    product_id INT,
    image_url VARCHAR(255) NOT NULL,
    is_primary BIT DEFAULT 0,
    FOREIGN KEY (product_id) REFERENCES Products(product_id) ON DELETE CASCADE
);

-- 2.4 Cart Items
CREATE TABLE Cart_Items (
    cart_item_id INT IDENTITY(1,1) PRIMARY KEY,
    user_id INT,
    product_id INT,
    quantity INT NOT NULL DEFAULT 1,
    added_at DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (user_id) REFERENCES Customer(user_id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES Products(product_id) ON DELETE CASCADE
);

-- 2.5 Favorites
CREATE TABLE Favorites (
    favorite_id INT IDENTITY(1,1) PRIMARY KEY,
    user_id INT,
    product_id INT,
    created_at DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (user_id) REFERENCES Customer(user_id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES Products(product_id) ON DELETE CASCADE,
    CONSTRAINT UQ_User_Product UNIQUE(user_id, product_id)
);

-- 2.6 Reviews & Comments
CREATE TABLE Reviews (
    review_id INT IDENTITY(1,1) PRIMARY KEY,
    product_id INT,
    user_id INT,
    rating INT CHECK (rating >= 1 AND rating <= 5), 
    comment_text NVARCHAR(MAX),
    is_approved BIT DEFAULT 1, 
    created_at DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (product_id) REFERENCES Products(product_id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES Customer(user_id) ON DELETE CASCADE
);

-- 2.7 Orders (Kích thước địa chỉ tăng lên 500 để không bị tràn)
CREATE TABLE Orders (
    order_id INT IDENTITY(1,1) PRIMARY KEY,
    user_id INT,
    coupon_id INT NULL, 
    order_date DATETIME DEFAULT GETDATE(),
    status VARCHAR(50) DEFAULT 'PENDING', 
    total_amount DECIMAL(12, 2),
    note NVARCHAR(MAX), 
    discount_applied DECIMAL(12, 2) DEFAULT 0,
    session_info NVARCHAR(MAX),
    coupon_code VARCHAR(50) NULL, 
    
    payment_method VARCHAR(50) DEFAULT 'COD',
    payment_status VARCHAR(20) DEFAULT 'UNPAID',
    shipping_address NVARCHAR(500) NULL,
    shipping_fee DECIMAL(12, 2) DEFAULT 0,
    ghn_order_code VARCHAR(100) NULL,
    txn_ref VARCHAR(100) NULL,
    vnp_transaction_no VARCHAR(100) NULL,
    vnp_bank_code VARCHAR(20) NULL,
    paid_at DATETIME NULL,
    
    FOREIGN KEY (user_id) REFERENCES Customer(user_id) ON DELETE NO ACTION,
    FOREIGN KEY (coupon_id) REFERENCES Coupons(coupon_id) ON DELETE SET NULL
);

-- 2.8 Payment 
CREATE TABLE Payment (
    payment_id INT IDENTITY(1,1) PRIMARY KEY,
    order_id INT,
    payment_method VARCHAR(50) DEFAULT 'COD', 
    payment_status VARCHAR(20) DEFAULT 'UNPAID',
    amount DECIMAL(12, 2),
    user_id INT,
    vnp_transaction_no VARCHAR(100) NULL,
    vnp_bank_code VARCHAR(20) NULL,
    FOREIGN KEY (order_id) REFERENCES Orders(order_id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES Customer(user_id) ON DELETE NO ACTION
);

-- 2.9 Delivery (Kích thước địa chỉ tăng lên 500 để không bị tràn)
CREATE TABLE Delivery (
    delivery_id INT IDENTITY(1,1) PRIMARY KEY,
    order_id INT,
    shipping_address NVARCHAR(500), 
    shipping_fee DECIMAL(12, 2) DEFAULT 0,
    ghn_order_code VARCHAR(100),
    status VARCHAR(50) DEFAULT 'PENDING',
    estimated_delivery_date DATETIME NULL,
    actual_delivery_date DATETIME NULL,
    FOREIGN KEY (order_id) REFERENCES Orders(order_id) ON DELETE CASCADE
);

-- 2.10 Order Details
CREATE TABLE Order_Details (
    detail_id INT IDENTITY(1,1) PRIMARY KEY,
    order_id INT,
    product_id INT,
    quantity INT NOT NULL,
    price_at_purchase DECIMAL(12, 2) NOT NULL,
    FOREIGN KEY (order_id) REFERENCES Orders(order_id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES Products(product_id)
);

-- 2.11 Order Tracking Log
CREATE TABLE Order_Tracking (
    tracking_id INT IDENTITY(1,1) PRIMARY KEY,
    order_id INT,
    status VARCHAR(50), 
    description NVARCHAR(255), 
    updated_at DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (order_id) REFERENCES Orders(order_id) ON DELETE CASCADE
);

-- 2.12 VNPay IPN Logs
CREATE TABLE vnpay_ipn_logs (
    id INT IDENTITY(1,1) PRIMARY KEY,
    order_id INT NULL,
    vnp_TmnCode VARCHAR(20),
    vnp_Amount BIGINT,
    vnp_BankCode VARCHAR(20),
    vnp_BankTranNo VARCHAR(100),
    vnp_CardType VARCHAR(20),
    vnp_OrderInfo NVARCHAR(255),
    vnp_TransactionNo VARCHAR(100),
    vnp_ResponseCode VARCHAR(10),
    vnp_TransactionStatus VARCHAR(10),
    vnp_TxnRef VARCHAR(100),
    vnp_SecureHash VARCHAR(256),
    is_valid_signature BIT DEFAULT 0,
    raw_params NVARCHAR(MAX),
    created_at DATETIME DEFAULT GETDATE()
);

-- 2.13 Order Notifications
CREATE TABLE Order_Notifications (
    notif_id    INT IDENTITY(1,1) PRIMARY KEY,
    username    VARCHAR(100)   NOT NULL,
    order_id    INT            NULL,
    type        VARCHAR(30)    NOT NULL, 
    title       NVARCHAR(200)  NOT NULL,
    message     NVARCHAR(500)  NOT NULL,
    is_read     BIT            NOT NULL DEFAULT 0,
    created_at  DATETIME       NOT NULL DEFAULT GETDATE()
);
CREATE INDEX IX_OrderNotif_Username ON Order_Notifications(username);
CREATE INDEX IX_OrderNotif_Unread   ON Order_Notifications(username, is_read);
GO

-- 2.14 Articles (CMS bài viết đồng bộ)
CREATE TABLE Articles (
    article_id INT IDENTITY(1,1) PRIMARY KEY,
    title NVARCHAR(255) NOT NULL,
    summary NVARCHAR(500) NULL,
    content NVARCHAR(MAX) NOT NULL,
    image_url VARCHAR(500) NULL,
    author_username VARCHAR(50) NOT NULL,
    author_name NVARCHAR(100) NULL,
    status VARCHAR(20) DEFAULT 'PENDING',
    is_published BIT DEFAULT 0,
    created_at DATETIME DEFAULT GETDATE(),
    updated_at DATETIME DEFAULT GETDATE()
);
GO

-- 2.15 Order_Returns (Quản lý hàng hoàn trả lại)
CREATE TABLE Order_Returns (
    return_id INT IDENTITY(1,1) PRIMARY KEY,
    order_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL,
    condition NVARCHAR(100) NULL,
    action VARCHAR(20) NOT NULL, -- RESTOCK | DISCARD
    staff_id INT NULL,
    notes NVARCHAR(500) NULL,
    returned_at DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (order_id) REFERENCES Orders(order_id),
    FOREIGN KEY (product_id) REFERENCES Products(product_id),
    FOREIGN KEY (staff_id) REFERENCES Staff(staff_id)
);
GO

-- ============================================================
-- 3. CREATE COMPATIBILITY VIEWS AND TRIGGERS FOR JAVA CODE
-- ============================================================

-- 3.1 Users View 
CREATE VIEW Users AS
SELECT 
    a.username,
    a.password,
    a.role,
    c.user_id AS user_id,
    c.full_name,
    c.phone,
    c.address,
    c.date_of_birth,
    c.gender,
    c.height_cm,
    c.weight_kg,
    c.health_goal
FROM Account a
JOIN Customer c ON a.account_id = c.account_id
UNION ALL
SELECT 
    a.username,
    a.password,
    a.role,
    s.staff_id AS user_id,
    s.full_name,
    s.phone,
    NULL AS address,
    NULL AS date_of_birth,
    NULL AS gender,
    NULL AS height_cm,
    NULL AS weight_kg,
    NULL AS health_goal
FROM Account a
JOIN Staff s ON a.account_id = s.account_id;
GO

-- 3.2 INSTEAD OF INSERT trigger on Users view
CREATE TRIGGER trg_Users_Insert
ON Users
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @username VARCHAR(50), @password VARCHAR(255), @role VARCHAR(20), @full_name NVARCHAR(100), @phone VARCHAR(20);
    DECLARE @account_id INT;

    DECLARE cur CURSOR FOR SELECT username, password, role, full_name, phone FROM inserted;
    OPEN cur;
    FETCH NEXT FROM cur INTO @username, @password, @role, @full_name, @phone;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        INSERT INTO Account (username, password, role, is_active)
        VALUES (@username, @password, @role, 1);

        SET @account_id = SCOPE_IDENTITY();

        IF @role = 'ADMIN' OR @role = 'STAFF'
        BEGIN
            INSERT INTO Staff (account_id, full_name, position, phone)
            VALUES (@account_id, @full_name, 'Staff', @phone);
        END
        ELSE
        BEGIN
            INSERT INTO Customer (account_id, full_name, phone)
            VALUES (@account_id, @full_name, @phone);
        END

        FETCH NEXT FROM cur INTO @username, @password, @role, @full_name, @phone;
    END

    CLOSE cur;
    DEALLOCATE cur;
END;
GO

-- 3.3 INSTEAD OF UPDATE trigger on Users view
CREATE TRIGGER trg_Users_Update
ON Users
INSTEAD OF UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    IF UPDATE(role) OR UPDATE(password)
    BEGIN
        UPDATE a
        SET a.role = i.role,
            a.password = i.password
        FROM Account a
        JOIN inserted i ON a.username = i.username;
    END

    UPDATE c
    SET c.full_name = i.full_name,
        c.phone = i.phone,
        c.address = i.address,
        c.date_of_birth = i.date_of_birth,
        c.gender = i.gender,
        c.height_cm = i.height_cm,
        c.weight_kg = i.weight_kg,
        c.health_goal = i.health_goal
    FROM Customer c
    JOIN Account a ON c.account_id = a.account_id
    JOIN inserted i ON a.username = i.username;

    UPDATE s
    SET s.full_name = i.full_name,
        s.phone = i.phone
    FROM Staff s
    JOIN Account a ON s.account_id = a.account_id
    JOIN inserted i ON a.username = i.username;
END;
GO

-- 3.4 INSTEAD OF DELETE trigger on Users view
CREATE TRIGGER trg_Users_Delete
ON Users
INSTEAD OF DELETE
AS
BEGIN
    SET NOCOUNT ON;
    DELETE a
    FROM Account a
    JOIN deleted d ON a.username = d.username;
END;
GO

-- 3.5 ProductsWithStock View (Dùng cho Website truy vấn lượng tồn kho)
CREATE VIEW ProductsWithStock AS
SELECT 
    product_id,
    category_id,
    sku,
    name,
    description,
    price,
    discount_price,
    discount_percent,
    is_flash_sale,
    stock_quantity,
    image_url,
    sold_count,
    is_bestseller,
    is_active,
    created_at
FROM Products;
GO

-- 3.6 Triggers đồng bộ tồn kho giữa Stock và Products
CREATE TRIGGER trg_Stock_Sync
ON Stock
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;
    
    IF OBJECT_ID('trg_Products_Stock_Insert', 'TR') IS NOT NULL
        ALTER TABLE Products DISABLE TRIGGER trg_Products_Stock_Insert;

    UPDATE p
    SET p.stock_quantity = COALESCE((SELECT SUM(s.quantity) FROM Stock s WHERE s.product_id = p.product_id), 0)
    FROM Products p
    WHERE p.product_id IN (
        SELECT DISTINCT product_id FROM inserted
        UNION
        SELECT DISTINCT product_id FROM deleted
    );

    IF OBJECT_ID('trg_Products_Stock_Insert', 'TR') IS NOT NULL
        ALTER TABLE Products ENABLE TRIGGER trg_Products_Stock_Insert;
END;
GO

CREATE TRIGGER trg_Products_Stock_Insert
ON Products
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    IF UPDATE(stock_quantity)
    BEGIN
        INSERT INTO Stock (product_id, staff_id, quantity)
        SELECT 
            i.product_id,
            NULL,
            i.stock_quantity - d.stock_quantity
        FROM inserted i
        JOIN deleted d ON i.product_id = d.product_id
        WHERE i.stock_quantity <> d.stock_quantity;
    END
END;
GO

-- 3.7 Trigger đồng bộ thông tin đơn hàng sang bảng Payment và Delivery
CREATE TRIGGER trg_Orders_Sync_Payment_Delivery
ON Orders
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Đồng bộ sang bảng Payment
    INSERT INTO Payment (order_id, payment_method, payment_status, amount, user_id)
    SELECT 
        i.order_id,
        COALESCE(i.payment_method, 'COD'),
        COALESCE(i.payment_status, 'UNPAID'),
        i.total_amount,
        i.user_id
    FROM inserted i
    WHERE NOT EXISTS (SELECT 1 FROM Payment p WHERE p.order_id = i.order_id);

    -- Đồng bộ sang bảng Delivery
    INSERT INTO Delivery (order_id, shipping_address, shipping_fee, status)
    SELECT 
        i.order_id,
        COALESCE(i.shipping_address, N'Chưa có'),
        0,
        'PENDING'
    FROM inserted i
    WHERE NOT EXISTS (SELECT 1 FROM Delivery d WHERE d.order_id = i.order_id);
END;
GO

CREATE TRIGGER trg_Orders_Update_Sync_Payment_Delivery
ON Orders
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    
    IF UPDATE(payment_method) OR UPDATE(payment_status) OR UPDATE(vnp_transaction_no) OR UPDATE(vnp_bank_code) OR UPDATE(total_amount)
    BEGIN
        UPDATE p
        SET p.payment_method = i.payment_method,
            p.payment_status = i.payment_status,
            p.vnp_transaction_no = i.vnp_transaction_no,
            p.vnp_bank_code = i.vnp_bank_code,
            p.amount = i.total_amount
        FROM Payment p
        JOIN inserted i ON p.order_id = i.order_id;
    END

    IF UPDATE(shipping_address) OR UPDATE(status)
    BEGIN
        UPDATE d
        SET d.shipping_address = i.shipping_address,
            d.status = i.status
        FROM Delivery d
        JOIN inserted i ON d.order_id = i.order_id;
    END
END;
GO

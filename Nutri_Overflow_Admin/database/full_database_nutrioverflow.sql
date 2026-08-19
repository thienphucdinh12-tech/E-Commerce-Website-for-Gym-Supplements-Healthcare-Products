-- ============================================================
--  NUTRIOVERFLOW — FULL DATABASE SCHEMAS AND TEST DATA
--  Cấu trúc Schema Gốc (Bảng Trên) + Thuộc tính & Toàn bộ Dữ liệu Chi tiết (Bảng Dưới)
-- ============================================================

USE master;
GO

-- Drop database if it already exists
IF EXISTS (SELECT * FROM sys.databases WHERE name = 'NutriOverflow')
BEGIN
    ALTER DATABASE NutriOverflow SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE NutriOverflow;
    PRINT 'Dropped existing database NutriOverflow.';
END
GO

CREATE DATABASE NutriOverflow;
GO

USE NutriOverflow;
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
    email VARCHAR(100) UNIQUE,
    role VARCHAR(20) DEFAULT 'CUSTOMER', 
    is_active BIT DEFAULT 1,
    created_at DATETIME DEFAULT GETDATE()
);

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

-- 2.2 Stock 
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

-- 2.7 Orders 
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
    ghn_district_id INT NULL,
    ghn_ward_code VARCHAR(50) NULL,
    recipient_phone VARCHAR(20) NULL,
    
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

-- 2.9 Delivery 
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

-- 2.14 Articles (Health guides & articles)
CREATE TABLE Articles (
    article_id INT IDENTITY(1,1) PRIMARY KEY,
    title NVARCHAR(255) NOT NULL,
    summary NVARCHAR(1000) NULL,
    content NVARCHAR(MAX) NOT NULL,
    image_url VARCHAR(255) NULL,
    author_username VARCHAR(50) NULL,
    author_name NVARCHAR(100) NULL,
    status VARCHAR(20) DEFAULT 'PENDING' NOT NULL, -- PENDING, APPROVED, REJECTED
    is_published BIT DEFAULT 0 NOT NULL,
    created_at DATETIME DEFAULT GETDATE() NOT NULL,
    updated_at DATETIME DEFAULT GETDATE() NOT NULL
);
GO

-- 2.15 Order Returns (Return Logistics)
CREATE TABLE Order_Returns (
    return_id INT IDENTITY(1,1) PRIMARY KEY,
    order_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL,
    condition VARCHAR(50) NOT NULL, -- SEALED, DAMAGED
    action VARCHAR(50) NOT NULL, -- RESTOCK, DISCARD
    staff_id INT NULL,
    notes NVARCHAR(MAX) NULL,
    returned_at DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (order_id) REFERENCES Orders(order_id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES Products(product_id),
    FOREIGN KEY (staff_id) REFERENCES Staff(staff_id)
);
GO

-- ============================================================
-- 4. CREATE COMPATIBILITY VIEW AND TRIGGERS FOR JAVA CODE
-- ============================================================

-- 4.1 Users View 
CREATE VIEW Users AS
SELECT 
    a.username,
    a.password,
    a.role,
    c.user_id AS user_id,
    c.full_name,
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
    NULL AS address,
    NULL AS date_of_birth,
    NULL AS gender,
    NULL AS height_cm,
    NULL AS weight_kg,
    NULL AS health_goal
FROM Account a
JOIN Staff s ON a.account_id = s.account_id;
GO

-- 4.2 INSTEAD OF INSERT trigger on Users view
CREATE TRIGGER trg_Users_Insert
ON Users
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @username VARCHAR(50), @password VARCHAR(255), @role VARCHAR(20), @full_name NVARCHAR(100);
    DECLARE @account_id INT;

    DECLARE cur CURSOR FOR SELECT username, password, role, full_name FROM inserted;
    OPEN cur;
    FETCH NEXT FROM cur INTO @username, @password, @role, @full_name;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        INSERT INTO Account (username, password, role, is_active)
        VALUES (@username, @password, @role, 1);

        SET @account_id = SCOPE_IDENTITY();

        IF @role = 'ADMIN' OR @role = 'STAFF'
        BEGIN
            INSERT INTO Staff (account_id, full_name, position)
            VALUES (@account_id, @full_name, 'Staff');
        END
        ELSE
        BEGIN
            INSERT INTO Customer (account_id, full_name)
            VALUES (@account_id, @full_name);
        END

        FETCH NEXT FROM cur INTO @username, @password, @role, @full_name;
    END

    CLOSE cur;
    DEALLOCATE cur;
END;
GO

-- 4.3 INSTEAD OF UPDATE trigger on Users view
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
    SET s.full_name = i.full_name
    FROM Staff s
    JOIN Account a ON s.account_id = a.account_id
    JOIN inserted i ON a.username = i.username;
END;
GO

-- 4.4 INSTEAD OF DELETE trigger on Users view
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

-- 4.5 Trigger đồng bộ tồn kho giữa Stock và Products
CREATE TRIGGER trg_Stock_Sync
ON Stock
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Tạm thời vô hiệu hóa trigger trên Products để tránh lặp vô hạn
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

-- 4.6 Trigger đồng bộ thông tin đơn hàng sang bảng Payment và Delivery
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


-- ==========================================
-- 3. INSERT SEED / TEST DATA
-- ==========================================

-- Tạm thời vô hiệu hóa tất cả trigger khi chèn dữ liệu mẫu
ALTER TABLE Account DISABLE TRIGGER ALL;
ALTER TABLE Customer DISABLE TRIGGER ALL;
ALTER TABLE Staff DISABLE TRIGGER ALL;
ALTER TABLE Products DISABLE TRIGGER ALL;
ALTER TABLE Stock DISABLE TRIGGER ALL;
ALTER TABLE Orders DISABLE TRIGGER ALL;
ALTER TABLE Payment DISABLE TRIGGER ALL;
ALTER TABLE Delivery DISABLE TRIGGER ALL;
GO

-- 3.0 System Configuration
INSERT INTO System_Config (config_key, config_value, description) VALUES
('point_earning_rate', '10000', N'Số tiền tiêu dùng (VNĐ) để tích được 1 điểm thành viên'),
('point_redeem_rate', '100', N'Giá trị quy đổi (VNĐ) của 1 điểm thành viên khi thanh toán');

-- 3.1 Categories
INSERT INTO Categories (name, description) VALUES 
(N'Protein', N'Cung cấp đạm tiêu chuẩn, phát triển cơ bắp'), 
(N'Mass Gainer', N'Sữa tăng cân cho người gầy'), 
(N'Pre-Workout', N'Tăng sức mạnh trước tập'), 
(N'Diet Food', N'Thực phẩm hỗ trợ ăn kiêng, ít calo'), 
(N'Fat Burner', N'Hỗ trợ đốt mỡ, giảm cân an toàn'), 
(N'Vitamin', N'Tăng cường sức đề kháng, khoáng chất'), 
(N'Snack', N'Bánh kẹo ăn nhẹ giàu protein, healthy'); 

-- 3.2 Users
INSERT INTO Account (username, password, email, role) VALUES 
('admin', '123456', 'admin@nutrioverflow.com', 'ADMIN'),
('khach01', '123456', 'gymer01@gmail.com', 'CUSTOMER'),
('khach02', '123456', 'diet02@gmail.com', 'CUSTOMER');

INSERT INTO Staff (account_id, full_name, phone, position) VALUES 
(1, N'Quản trị viên', '0900000000', 'Manager');

INSERT INTO Customer (account_id, full_name, phone, address, date_of_birth, gender, height_cm, weight_kg, health_goal) VALUES 
(2, N'Nguyễn Văn Gymer', '0911111111', N'123 Đường ABC, TP.HCM', '1995-06-15', 'Male', 180.0, 85.0, 'muscle_gain'),
(3, N'Trần Thị Diet', '0922222222', N'456 Đường XYZ, Đà Nẵng', '1998-10-20', 'Female', 160.0, 52.0, 'weight_loss');

-- 3.3 Coupons
INSERT INTO Coupons (code, discount_amount, discount_percent, min_order_value, usage_limit, expiry_date) VALUES 
('NUTRIOVERFLOW50K', 50000, 0, 1000000, 100, '2026-12-31'),
('FREESHIP', 30000, 0, 500000, 500, '2026-12-31'),
('WELCOME10', 0, 10, 0, 100, '2027-12-31'),
('SUMMER20',  0, 20, 500000, 50, '2026-12-31'),
('HEALTH15',  0, 15, 200000, NULL, '2027-12-31'),
('VIP30',     0, 30, 1000000, 10, '2026-12-31');

-- 3.4 Products 
INSERT INTO Products (category_id, sku, name, description, price, discount_price, discount_percent, is_flash_sale, sold_count, is_bestseller) VALUES 
(1, 'PRO-01', N'ON Gold Standard 100% Whey 5lbs', N'Gold Standard 100% Whey 5lbs được sản xuất bởi Optimum Nutrition. Thương hiệu này có tuổi đời gần 40 năm và phân phối sản phẩm tới hơn 100 quốc gia và vùng lãnh thổ, trong đó có nhiều thị trường tiêu chuẩn cao như tại Bắc Mỹ và Châu Âu.

Gold Standard 100% Whey 5lbs là sự kết hợp giữa:

Whey Protein Isolates.
Whey Protein Concentrate.
Whey Peptides.
Whey isolate và whey peptides thuộc tầng whey hấp thụ nhanh, sau khi đi vào cơ thể sẽ được vận chuyển ngay đến cơ bắp. Whey Concentrate là tầng whey hấp thụ chậm hơn, chịu trách nhiệm từ từ tham gia quá trình tổng hợp protein trong nhiều giờ sau đó. Sự kết hợp này tạo ra dòng chảy protein đa tầng, đa chức năng và hấp thụ dàn trải, góp phần phục hồi và nuôi dưỡng cơ bắp to khỏe hơn sau mỗi buổi tập.

Sản phẩm áp dụng công nghệ lọc độc quyền giúp loại bỏ phần lớn fat và lactose, đồng thời giữ được nguồn dinh dưỡng tự nhiên trong sữa bò.

Gold Standard 100% Whey dễ bề tiêu chuẩn:

Không Gluten 
Không hormone nhân tạo 
Banned Substance Tested: Đã qua kiểm nghiệm chất cấm
Hướng dẫn sử dụng: Pha 1 muỗng với 300ml nước lạnh (Uống sau khi tập hoặc vừa ngủ dậy).
Sản phẩm với mùi vị đa dạng, thơm ngon dễ uống, dễ hòa tan khi sử dụng bình lắc.
Thành phần của Gold Standard 100% Whey:
1 serving (1 muỗng trọng lượng khoảng 30 - 33g tùy vị) Gold Standard 100% Whey cung cấp:

24g protein chất lượng cao (chiếm 79%)
5.5g BCAA tự nhiên
2g fat
3g carbohydrates
1g đường
', 2000000, 1800000, 10, 0, 250, 1),

(1, 'PRO-02', N'Mutant Iso Surge 5lbs', N'Ưu điểm nổi bật của Iso Surge 5lbs:
Tốc độ hấp thụ nhanh: Với sự kết hợp giữa whey cô lập và whey thủy phân giúp đưa protein vào mô cơ của bạn nhanh chóng.

Whey Protein Isolate (Whey cô lập) là sản phẩm tinh khiết do đã được xử lý qua công đoạn loại bỏ tạp chất và chỉ giữ lại Protein. Do đó, sữa tăng cơ Isolate dễ tiêu hóa hơn và lành tính hơn.
Whey Protein Hydrolysate (Whey thủy phân) là thành phẩm của công đoạn xử lý nâng cao hơn, đây chính là loại Protein tinh khiết nhất, dễ hấp thụ nhất và có giá trị sinh học cao nhất.
Hương vị hấp dẫn: Hương vị thơm ngon chinh phục được cả những vị khách hàng khó tính nhất.

Protein chất lượng cao: Hãng cam kết chỉ sử dụng những nguyên liệu tốt nhất để cung cấp nguồn whey protein chất lượng và có tính năng sinh học cao giúp hỗ trợ tăng trưởng có bắp, phục hồi cơ bắp.

Thành phần của Iso Surge 5lbs:
Mỗi khẩu phần Iso Surge 5lbs cung cấp:

25g protein
2g Carbohydrates
1g Fat
0.5g chất xơ
Với Iso Surge 5lbs bạn nhận được một loại whey protein cô lập (WPI) cao cấp cung cấp 25 gam protein với lượng đường và Fat không đáng kể cùng với đó là hơn 10 vị để dễ dàng lựa chọn. Whey protein Isolate là tiêu chuẩn cao nhất trong các loại thực phẩm bổ sung protein, với tốc độ hấp thụ nhanh hơn, mang lại tốc độ phục hồi tốt và sự cân bằng dinh dưỡng đa lượng tối ưu.

Iso Surge 5lbs sử dụng whey protein cô lập nguyên chất và whey thủy phân. Đây là những nguồn protein tinh khiết và hấp thụ nhanh nhất trên thị trường hiện nay.

Công dụng của Iso Surge 5lbs:
With hàm lượng protein cao Iso Surge 5lbs giúp hỗ trợ xây dựng cơ bắp nạc.
Cải thiện độ to, dày và nạc của cơ bắp.
Tăng khả năng phục hồi, chống dị hóa cơ bắp.
Hướng dẫn sử dụng:
Pha 1 muỗng vào 150ml nước lạnh hoặc sữa.
Dùng mỗi ngày ít nhất 2 lần: 1 lần vào sáng sớm khi vừa ngủ dậy và 1 lần sau khi tập, có thể dùng thêm 1 muỗng trước tập.
Những ngày không tập luyện, duy trì 1 muỗng vào sáng sớm.
Lưu ý:
Sản phẩm này được sử dụng như một thực phẩm bổ sung cho chế độ ăn uống, không dùng sản phẩm thay thế cho các bữa ăn chính hàng ngày.
Để xa tầm tay bé.
Sau khi sử dụng, hãy đậy kín nắp và bảo quản nơi khô ráo thoáng mát.
Không dùng sản phẩm cho phụ nữ có thai hoặc đang cho con bú.
Những người có bệnh nền hoặc đang trong thời gian điều trị bệnh khác, nếu muốn sử dụng cần phải hỏi ý kiến của bác sĩ hoặc chuyên gia.
Sản phẩm này không phải là thuốc và không có tác dụng thay thế cho thuốc chữa bệnh.
', 2500000, 1750000, 30, 1, 120, 0),

(1, 'PRO-03', N'Nutrabolics Hydropure 100% Hydrolyzed Whey', N'Ưu điểm nổi bật của Hydropure:
Công nghệ sản xuất hiện đại:
Để tạo ra Hydropure trước tiên whey protein cần trải qua công nghệ siêu lọc với bộ lọc vi mô. Bước lọc này nhằm loại bỏ hết carbs, fat, lactose còn tồn dư trong whey. Thành phẩm nhận được sau quá trình này là whey protein có độ tinh khiết cao.

Sau khi lọc sạch protein tiếp tục trải qua bước thủy phân bẻ mạch để biến đổi protein mạch dài thành các mạch ngắn hơn gọi là peptides. Protein sau khi thủy phân sẽ rút ngắn được bước tiêu hóa ở dạ dày và đi thẳng vào cơ bắp.

Hydropure được xếp vào nhóm whey protein thủy phân - Phân khúc whey protein cao cấp nhất tính tới thời điểm hiện tại.

Thành phần cao cấp:
Hydropure sở hữu 100% whey protein thủy phân tinh khiết, không pha trộn thêm bất kỳ nguồn protein nào khác. Protein thủy phân thẩm thấu nhanh và sâu vào cơ bắp, rút ngắn thời gian thấp thẩm.

Hydropure cung cấp 28g protein, 13g EAAs, 6.1g BCAAs trong mỗi lần dùng. Ngoài ra sản phẩm còn được bổ sung thêm 5g Glutamine hỗ trợ giảm đau nhức cơ bắp.

Hydropure không độn amino rẻ tiền. Tất cả amino axit thiết yếu trong sản phẩm đều có tự nhiên trong sữa bò.

Do trải qua nhiều bước lọc nên hàm lượng fat, lactose và cholesterol trong Hydropure rất thấp. Tuy nhiên phần lớn lượng vitamin khoáng có sẵn trong sữa vẫn được giữ lại.

Hydropure không dùng các chất tạo ngọt phổ thông như E955 hay E950 mà dùng tinh chất cỏ ngọt Stevia. Cỏ này không chứa calo và hạn chế làm tăng chỉ số đường huyết.
Hướng dẫn sử dụng: Pha 1 muỗng với 300ml nước lạnh (Uống sau khi tập hoặc vừa ngủ dậy).
', 3000000, 1950000, 35, 1, 45, 0),

(1, 'PRO-04', N'Beverly Hydro Protein 1kg', N'Ưu điểm nổi bật của Beverly Hydro Protein 1kg:
Tốc độ hấp thu cực nhanh:
Với dạng protein thủy phân, Hydro Protein giúp axit amin được hấp thu chỉ sau vài phút, giúp cơ bắp phục hồi nhanh sau tập luyện.
Độ tinh khiết cao, hạn chế nóng trong, nổi mụn, khó tiêu:
Công thức “clean protein” – không chất độn, không lactose – giúp hạn chế tối đa tình trạng nóng trong, nổi mụn hoặc khó tiêu.
Tốt cho vận động viên và người có hệ tiêu hóa nhạy cảm:
Beverly Hydro Protein 1kg là sản phẩm hoàn hảo cho những người tập luyện cường độ cao và cần phục hồi nhanh chóng, cũng như những người gặp khó khăn về tiêu hóa, vì công thức của sản phẩm dịu nhẹ hơn cho hệ tiêu hóa.

Tăng cơ nạc, giảm mỡ hiệu quả:
Với khoảng 28,5 - 39,5g Protein (tùy vị) tinh khiết mỗi serving và hàm lượng carb thấp, Hydro Protein giúp tăng cơ mà không tích mỡ, rất phù hợp cho người đang siết cơ, các vận động viên.

Giúp phục hồi nhanh và giảm đau nhức cơ:
Nhờ hàm lượng BCAA, EAA cao, sản phẩm giúp giảm DOMS (Delayed Onset Muscle Soreness) - hay còn gọi là đau cơ khởi phát muộn. Đây là tình trạng đau và cứng cơ thường xảy ra từ 24 đến 72 giờ sau khi tập thể dục cường độ cao hoặc thực hiện các động tác mới, là dấu hiệu của tổn thương vi mô ở sợi cơ và mô liên kết. Cơn đau này thường đạt đỉnh điểm sau 48 giờ và giảm dần trong vài ngày tiếp theo. Đồng thời, giúp rút ngắn thời gian phục hồi sau mỗi buổi tập nặng.

Hương vị thơm ngon dễ uống:
Với nhiều hương vị thơm ngon đa dạng và vị ngọt nhẹ không bị ngọt gắt. Beverly Hydro Protein 1kg có thể pha cùng sinh tố mà không làm giảm đi hương vị và độ ngon.
Sản phẩm bổ sung thêm enzyme tiêu hóa Digezyme® và Tolerase®:
Hỗ trợ tiêu hóa và hấp thụ chất dinh dưỡng, ngăn ngừa đau dạ dày.

Chứng nhận Halal:
Phù hợp cho những người theo chế độ ăn Halal, đảm bảo sản phẩm đáp ứng các tiêu chuẩn thực phẩm quốc tế.

Chứng nhận GMP (Thực hành Sản xuất Tốt):
Được sản xuất theo các tiêu chuẩn chất lượng, an toàn và vệ sinh nghiêm ngặt, đảm bảo sản phẩm đáng tin cậy và chất lượng hàng đầu.

Thành phần của Beverly Hydro Protein 1kg:
1 serving Beverly Hydro Protein 1kg cung cấp:
28,5 - 39,5g protein (tùy vị)
4.8g BCAAs và 10.5g EAAs
131 - 209 kcal (tùy vị)
0 FAT
0g lactose
Bổ sung thêm enzyme tiêu hóa Digezyme® và Tolerase®

Công dụng của Beverly Hydro Protein 1kg:
Các lợi ích chính của Beverly Hydro Protein 1kg:
Hỗ trợ tăng trưởng cơ bắp
Hỗ trợ phục hồi cơ bắp sau tập luyện
Hạn chế tình trạng dị hóa
Giảm đau nhức cơ bắp sau tập luyện
Bổ sung protein cho chế độ ăn hàng ngày
Hướng dẫn sử dụng:
Pha 1 muỗng Beverly Hydro Protein 1kg với nước lạnh, sữa hoặc nước rau củ và uống sau khi tập luyện hoặc theo chỉ dẫn của chuyên gia dinh dưỡng.

Lưu ý:
Bảo quản sản phẩm ở nơi khô ráo, thoáng mát.
Sử dụng xong phải đóng kín sản phẩm.
Sản phẩm không dành cho trẻ em dưới 16 tuổi.
Trong trường hợp bạn mang thai, chỉ sử dụng sản phẩm khi có sự chỉ định của bác sĩ.
Sản phẩm không phải là thuốc và không có tác dụng thay thế thuốc chữa bệnh.
Nếu mẫn cảm với bất kỳ thành phần nào của sản phẩm, hãy tham khảo ý kiến bác sĩ trước khi dùng.
', 1500000, NULL, 0, 0, 10, 0),

(2, 'MAS-01', N'Redcon1 Mass Gainer 5.89lbs', N'Redcon1 Mass Gainer 5.89lbs - Sữa mass tăng cân nạc siêu đậm:
Nếu bạn là người tập thể hình, thể thao thường xuyên và có nhu cầu tăng cân nặng, tăng cân săn chắc thì Redcon1 Mass Gainer chính là sản phẩm hỗ trợ hiệu quả nhất. Với điểm mạnh:
50g protein / lần dùng
1270 kcal
Sản phẩm giúp bạn bổ sung nguồn dinh dưỡng đậm đặc, dễ hấp thụ và hỗ trợ tăng cơ bắp cực tốt bởi nguồn whey protein dồi dào. Lựa chọn Redcon1 Mass Gainer cho bữa phụ không chỉ giúp bạn cải thiện cân nặng đáng kể mà còn giúp cơ thể săn chắc khỏe mạnh hơn.
Sản phẩm có xuất xứ tại Mỹ, do thương hiệu dinh dưỡng thể thao Redcon1 sản xuất.

Ưu điểm:
Giàu năng lượng:
Redcon1 Mass Gainer cung cấp 1270 kcal chỉ trong 1 lần dùng (5 muỗng). Lượng calories này tương đương 2 bữa ăn chính. Nhờ vậy mà cơ thể bạn luôn có thừa năng lượng để bổ trợ cho quá trình tích lũy calories và tăng cân hiệu quả hơn.
Thay vì ăn nhiều bữa với lượng thức ăn lớn có thể gây ngán hoặc chán ăn, bạn chỉ cần pha mass và uống vào bữa phụ là đã nạp được lượng calo khổng lồ, giảm tải gánh nặng ăn uống và tiết kiệm rất nhiều thời gian.

Hàm lượng protein cao:
1 serving Redcon1 Mass Gainer chứa 50g đạm từ 2 nguồn protein là whey concentrate và whey isolate. Hỗn hợp protein cao cấp không biến tính, hấp thụ nhanh giúp cơ nạc phát triển hiệu quả.

Giàu carb từ Maltodextrin:
256g carbohydrates đến từ Maltodextrin. Đây là hỗn hợp tinh bột hấp thụ nhanh đến từ nhiều nguồn như khoai lang, ngô,... Maltodextrin cung cấp năng lượng nhanh và dễ tiêu hóa, hỗ trợ tăng cân dễ dàng hơn.

Rất ít đường:
Sản phẩm chỉ chứa 1.5g đường trong mỗi lần dùng, ít hơn đa phần các loại mass khác. Lượng đường được kiểm soát giúp hạn chế tình trạng đường huyết tăng quá cao, đồng thời mang đến vị ngọt dễ chịu.

Mùi vị thơm ngon:
Redcon1 Mass Gainer gần như lọc bỏ toàn bộ đường dư thừa nên hương vị ngọt thanh dễ uống, không gây cảm giác ngán ngấy và đặc biệt kích thích thèm ăn.

Thành phần của Redcon1 Mass Gainer 5.89lbs:
1 serving (5 muỗng - 334g) Redcon1 Mass Gainer cung cấp:
50g protein
256g carbohydrates
5g fat
1g chất xơ
1.5g đường
864mg Natri
358mg Kali

Công dụng:
Hỗ trợ tăng cân nhanh, tăng cân nặng
Cải thiện tỷ lệ cơ bắp
Bổ sung các dưỡng chất cần thiết cho cơ thể
Cung cấp năng lượng nhanh

Cách dùng Redcon1 Mass Gainer 5.89lbs:
Không có giới hạn nào với cách sử dụng sản phẩm, với 5 muỗng mỗi ngày bạn có thể chia ra làm 2 - 3 lần uống dàn trải trong ngày. Bạn có thể tham khảo cách sử dụng sản phẩm như sau:
2 muỗng vào buổi sáng cách giờ ăn 2h - 2.5h
3 muỗng vào bữa phụ buổi chiều
Lưu ý:
Nên lắc bằng bình lắc chuyên dụng, hoặc máy xay sinh tố mới đảm bảo độ tan của sản phẩm.
Không pha với nước nóng.
Sử dụng sau khi pha, không để lâu hay để tủ lạnh tích trữ.
Không bỏ bữa sáng và ăn đủ các bữa chính trong khi sử dụng sản phẩm.
Sản phẩm không có tác dụng thay thế thuốc chữa bệnh hay có khả năng thay thế bữa ăn chính.
Duy trì chế độ ăn đủ bữa và cân bằng dinh dưỡng.
', 1500000, 990000, 34, 1, 80, 0),

(2, 'MAS-02', N'Elite Labs Mass Muscle Gainer 10lbs', N'Elite Labs Mass Muscle Gainer 10lbs có hương vị đa dạng:
Với sự đa dạng về hương vị, sản phẩm được nhiều anh em Gymer những người đam mê thể dục thể thao tin dùng with 3 hương vị được đánh giá là phổ biến và được nhiều người chọn lựa nhất là: Double Rich Chocolate, Cookies & Cream, Vanilla Ice Cream.
Sữa rất mịn, dễ hòa tan không vón cục.

Thành phần chính của Elite Labs USA Mass Muscle Gainer 10lbs:
1000 calories
7g FAT
174g Carbohydrates
2g Fiber
60g protein

Công dụng của Elite Labs USA Mass Muscle Gainer 10lbs:
Hỗ trợ tăng cân nhanh chóng, hiệu quả, an toàn
Giúp xây dựng cơ bắp nạc
Giảm đau nhức cơ bắp
Chống dị hóa cơ bắp
Giúp cải thiện thể trạng sức khỏe
Tăng sức bền để buổi tập luyện trở nên hiệu quả hơn
Hỗ trợ phục hồi cơ bắp sau tập luyện
Bơm phồng cơ bắp

Hướng dẫn sử dụng:
Ngày tốt nhất nên dùng 4 muỗng Elite Labs USA Mass Muscle Gainer 10lbs và nên sử dụng vào các thời điểm sau:
Buổi sáng khi ngủ dậy
Trước tập
Sau tập
Buổi tối trước khi đi ngủ
Pha 1 serving Mass Muscle Gainer với khoảng 300ml – 400ml nước nguội hoặc sữa tươi và sử dụng được ngay.

Lưu ý:
Bảo quản sản phẩm ở nơi khô ráo, thoáng mát.
Sử dụng xong phải đóng kín sản phẩm.
Không sử dụng khi sản phẩm đã bị mốc, đổi màu hoặc có mùi khác thường.
Nếu mẫn cảm với bất kỳ thành phần nào của sản phẩm, hãy tham khảo ý kiến bác sĩ trước khi dùng.
', 1700000, NULL, 0, 0, 210, 1),

(2, 'MAS-03', N'Mass True Gainer', N'Bạn đang lo lắng vì cơ thể quá gầy, thiếu cân? Bạn đã thử nhiều cách tăng cân nhưng vẫn không hiệu quả? Đừng lo lắng, Mass True Gainer sẽ giúp bạn giải quyết vấn đề này một cách dễ dàng và hiệu quả.
Cơ chế tăng cân đơn giản chỉ là nạp nhiều Calo hơn mức cơ thể tiêu thụ. Tuy nhiên, điều này không phải lúc nào cũng dễ dàng, đặc biệt là đối với những người gầy lâu năm.
Có hai lý do chính khiến người gầy khó tăng cân:
- Không thể ăn nhiều: Những người gầy thường có dạ dày nhỏ, dẫn đến việc không thể ăn nhiều thức ăn trong một thời gian ngắn.
- Không có thời gian chuẩn bị bữa ăn: Những người gầy thường bận rộn với công việc, học tập, không có thời gian chuẩn bị các bữa ăn đầy đủ dinh dưỡng.
Hiểu được những khó khăn mà nhiều bạn gặp phải, True Strength đã cho ra đời sản phẩm sữa tăng cân Mass True Gainer - giải pháp tăng cân hiệu quả cho những bạn gầy lâu năm.
  
Với thành phần dinh dưỡng cân bằng, Mass True Gainer sẽ cung cấp cho cơ thể nguồn Calo dồi dào, giúp bạn tăng cân nhanh chóng và hiệu quả.
Trong 1 Full Serving Mass True Gainer cung cấp:
- 1176 Calo, giúp bạn nạp đủ năng lượng để tăng cân.
- 52g Protein, giúp xây dựng và phục hồi cơ bắp.
- 11g BCAAs, giúp ngăn ngừa dị hóa cơ bắp.
- 236g Carbohydrate, cung cấp năng lượng cho các hoạt động thể chất.

ƯU ĐIỂM VƯỢT TRỘI CỦA MASS TRUE GAINER:
- Cung cấp nguồn Calo dồi dào, giúp tăng cân nhanh chóng
- Dễ dàng pha chế, không mất nhiều thời gian chuẩn bị
- Thành phần dinh dưỡng cân bằng, giúp cơ thể phát triển khỏe mạnh
- Không gây tích nước

ĐỐI TƯỢNG SỬ DỤNG:
Mass True Gainer là sản phẩm phù hợp với tất cả những ai có nhu cầu tăng cân và tăng cơ, bao gồm:
- Người gầy lâu năm (không nhất thiết phải tập luyện), những người gặp khó khăn trong việc tăng cân do cơ thể tiêu thụ nhiều calo hơn lượng calo nạp vào.
- Người tập thể hình, thể thao, những người cần bổ sung dinh dưỡng để tăng cường sức mạnh và sức bền.
- Vận động viên trong giai đoạn bulking, giai đoạn cần nạp nhiều Calo để phát triển cơ bắp.

CHẤT LƯỢNG SẢN PHẨM:
Mass True Gainer là sản phẩm của thương hiệu True Strength thuộc Công Ty Quốc Tế True Health. Sản phẩm được sản xuất trên dây chuyền công nghệ hiện đại, đạt tiêu chuẩn vệ sinh an toàn thực phẩm. Các nguyên liệu sử dụng trong sản phẩm đều được kiểm định chất lượng nghiêm ngặt, đảm bảo an toàn cho sức khỏe người tiêu dùng. Trên các sản phẩm sản xuất bởi công ty True Health đều có đầy đủ mã vạch chính hãng và nguồn gốc xuất xứ.

HƯỚNG DẪN SỬ DỤNG:
Để tăng cân hiệu quả, uống Mass True Gainer 3-4 lần uống trong ngày. Mỗi lần dùng pha 2 muỗng có sẵn với 300-350ml nước hoặc sữa tươi không đường (nguội hoặc lạnh) rồi lắc với bình lắc. Sẽ ngon và hiệu quả nhanh hơn khi pha với sữa.
Có thể chia các lần uống như sau:
- Sau bữa sáng
- Sau bữa trưa hoặc/và buổi chiều (Hoặc trước và sau tập nếu có tập luyện)
- Sau bữa tối
Nếu cơ địa khó tăng cân quá thì nên sử dụng 4 lần/ngày không thì 3 lần là đủ. 4 lần uống sẽ là 1 Full Serving. 
Lưu ý:
- Không nên pha Mass True Gainer with nước nóng, sử dụng liền sau khi pha, không nên để lâu không đảm bảo dinh dưỡng.
- Bịch Mass True Gainer 2.5kg sẽ dùng được trên dưới 2 tuần tùy số lần sử dụng trong ngày.', 1000000, 690000, 31, 1, 30, 0),

(3, 'PRE-01', N'Redcon1 Total War Reloaded Pre-workout 546g', N'Redcon1 Total War Reloaded 546g - Phiên bản nâng cấp với 5g Creatine mỗi lần dùng!
Redcon1 Total War Reloaded 546g là dòng sản phẩm hỗ trợ tăng sức mạnh và sức bền nhằm giúp bạn đương đầu với những buổi tập hardcore nặng nhất!

Không chỉ có những thành phần quen thuộc như Citrulline, Beta-Alanine hay Caffeine, sản phẩm còn bổ sung thêm 5g Creatine mỗi lần dùng. Lượng Creatine cao vượt trội, kể cả khi so sánh với các sản phẩm chỉ cung cấp creatine sẽ làm sức bền cơ bắp cải thiện đáng kể.
Total War Reloaded 546g do thương hiệu dinh dưỡng thể thao Redcon1 tại Mỹ nghiên cứu và phát triển.

Ưu điểm của Redcon1 Total War Reloaded Pre-workout:
Nếu bạn đã từng trải nghiệm Total War thì đây chính là bản nâng cấp của sản phẩm này: Toàn diện hơn, mạnh mẽ hơn.
Redcon1 Total War Reloaded không có quá nhiều thành phần, bù lại hàm lượng mỗi thành phần then chốt lại cực kỳ cao, từ đó kích thích hệ thần kinh trung ương và hệ thống cơ bắp để đáp ứng các buổi tập cường độ cao.
- Công thức siêu mạnh, kích thích thần kinh và hệ thống cơ bắp cho giai đoạn nước rút.
- Liều Creatine 5g cực cao, tăng cường tích lũy ATP và giải phóng năng lượng cực nhanh.
- Chỉ số Citrulline đậm đặc 6g kích thích máu liên tục bơm đến cơ bắp.
- Hàm lượng caffeine 350mg cao kịch sàn (trung bình các sản phẩm khác chỉ dao động trong khoảng 200 - 300mg) giúp tâm trí tập trung tối đa, thổi bùng sức mạnh và sự hưng phấn.
- Kết hợp 140mg muối hồng Himalaya chứa hơn 80 loại khoáng chất (kali, magie, canxi, sắt), giúp cân bằng điện giải, giảm mất nước, tránh kiệt sức sau khi tập.

Thành phần:
1 serving Redcon1 Total War Reloaded (1 muỗng - 18.5g) cung cấp:
6g L-Citrulline Malate 2:1
5g Creatine Monohydrate
3.2g Beta-Alanine
350mg Caffeine Anhydrous
140mg muối hồng Himalaya
100mg Vitamin C
205mg Choline
264mg Natri
183mg Kali

Công dụng của Redcon1 Total War Reloaded 546g:
Công thức siêu tập trung của Redcon1 Total War Reloaded mang đến buổi tập hiệu suất cao nhờ vào các lợi ích như: 
- Tăng sức mạnh và sức bền, giúp đẩy mức tạ cao hơn
- Tăng sự hưng phấn và kích thích, đẩy cao chất lượng buổi tập
- Giảm mệt mỏi, chán nản trong buổi tập
- Pump cơ mạnh mẽ
- Hỗ trợ phục hồi sau tập nhanh hơn

Ai nên dùng Redcon1 Total War Reloaded 546g?
Sản phẩm này phù hợp nếu như bạn:
- Đã từng dùng các loại Pre-workout chứa caffeine trước đó mà không gặp vấn đề gì về sức khỏe, đặc biệt là triệu chứng mẫn cảm với caffeine.
- Muốn chuyển sang loại Pre nặng hơn để bứt phá giới hạn mới.
- Tập sáng hoặc trưa. Những người thường xuyên tập ca tối không nên sử dụng bởi hàm lượng caffeine cao trong sản phẩm có thể gây mất ngủ.

Cách dùng Redcon1 Total War Reloaded 546g:
Uống trước tập 30 phút. Khi uống pha 1 muỗng Total War với 200ml nước, lắc đều cho bột tan hoàn toàn, ngon hơn khi uống lạnh.
Với những người chưa dùng pre-workout bao giờ nên dùng thử 1/2 muỗng mỗi ngày trước, sau đó tăng dần liều lượng để phù hợp with thể trạng.

Lưu ý:
Thành phần nguyên liệu của các sản phẩm Pre-workout có đặc tính háo nước nên sẽ dễ gặp tình trạng vón cục với khí hậu nóng ẩm ở Việt Nam. Điều này là hoàn toàn bình thường ở các sản phẩm Pre-workout và bạn có thể yên tâm sử dụng.
Sản phẩm này không phải là thuốc và không có tác dụng thay thế thuốc chữa bệnh.
Không sử dụng nếu mẫn cảm với bất kỳ thành phần nào của sản phẩm.
Hình ảnh và Nutrition Facts của sản phẩm chỉ mang tính chất tham khảo bởi thành phần, mẫu mã nhà sản xuất có thể thay đổi.
Không sử dụng sản phẩm nếu bột có mùi lạ.
', 1000000, 750000, 25, 1, 60, 0),

(3, 'PRE-02', N'Beverly Dynamite Pre-Workout 375g', N'Giới thiệu về Beverly Dynamite Pre-Workout 375g:
Beverly Dynamite Pre-Workout 375g là sản phẩm tăng năng lượng trước tập cao cấp đến từ Beverly Nutrition – thương hiệu thể hình hàng đầu châu Âu, nổi tiếng với các công thức tiên tiến dành cho vận động viên và gymer chuyên nghiệp.

Dynamite Pre-Workout mang đến sự bùng nổ năng lượng và tập trung tối đa, giúp bạn duy trì hiệu suất đỉnh cao trong suốt buổi tập. Với công thức chứa NewCaff™ Caffeine, Creatine Creapure, Beta-Alanine CarnoSyn, cùng nhiều hoạt chất được chứng nhận bản quyền quốc tế, sản phẩm không chỉ giúp tăng sức mạnh, giảm mỏi cơ mà còn cải thiện độ tập trung, hỗ trợ cơ thể bơm máu và phục hồi nhanh hơn.

Ưu điểm nổi bật:
Công thức của Dynamite được phát triển dựa trên nghiên cứu sinh học thể thao, hướng đến sự cân bằng giữa hiệu suất, năng lượng và phục hồi.
- Tăng năng lượng và tỉnh táo nhờ NewCaff™ – công nghệ caffeine vi nang có khả năng giải phóng năng lượng chậm và bền, tránh tụt mood sau tập.
- Giảm mỏi cơ, kéo dài sức bền nhờ Beta-Alanine (CarnoSyn®), hỗ trợ giảm tích tụ acid lactic.
- Tăng hiệu suất, sức mạnh và khả năng bơm cơ với sự kết hợp L-Citrulline Malate và Creapure® Creatine.
- Cải thiện hấp thu dưỡng chất nhờ BioPerine® và Astragin® – giúp toàn bộ công thức phát huy tối đa tác dụng.
- Tập trung tinh thần và phản xạ nhanh hơn với VitaCholine® và L-Tyrosine, tăng kết nối giữa trí óc và cơ bắp.
- Đặc biệt, sản phẩm cung cấp 3g Creapure® creatine monohydrate trong mỗi khẩu phần, giúp đáp ứng đầy đủ lượng creatine khuyến nghị hàng ngày mà không cần phải bổ sung riêng sau khi tập.

Thành phần của Beverly Dynamite Pre-Workout 375g:
Mỗi serving 15g (khoảng 3 muỗng) chứa: 
Arginine AKG: 3.000 mg
Creatine Monohydrate (Creapure®): 3.000 mg
Beta-Alanine (CarnoSyn®): 2.000 mg
L-Citrulline Malate: 2.000 mg
L-Tyrosine: 500 mg
VitaCholine™ (Choline): 500 mg
Caffeine (NewCaff®75 microcapsules): 300 mg
L-Taurine: 300 mg
Astragin® (Saponins): 35 mg
BioPerine® (Piperine 95%): 10 mg
Niacin (Vitamin B3): 20 mg
Vitamin B6 (Pyridoxine): 12 - 20mg (tùy vị)

Công dụng nổi bật:
Tăng năng lượng và sức bền trong buổi tập.
Hỗ trợ phát triển cơ bắp, tăng sức mạnh và khả năng chịu tải.
Cải thiện độ tập trung và hiệu suất thần kinh – cơ.
Giảm mệt mỏi, phục hồi nhanh hơn sau khi tập nặng.
Giúp duy trì tinh thần tỉnh táo, tránh tụt lực sau tập.

Hướng dẫn sử dụng:
Pha 3 muỗng (15 g) với 250 – 300 ml nước lạnh, uống trước khi tập khoảng 30 phút. Người mới dùng có thể bắt đầu với 1 – 2 muỗng để kiểm tra khả năng dung nạp.

Lưu ý:
Không nên sử dụng sau 18h để tránh ảnh hưởng giấc ngủ, đặc biệt với người nhạy cảm caffeine.
Không dùng chung với sản phẩm khác có chứa caffeine.
Không dùng cho người dưới 18 tuổi, phụ nữ mang thai hoặc đang cho con bú.
Bảo quản nơi khô ráo, tránh ánh nắng trực tiếp.
Đây là thực phẩm bổ sung, không phải thuốc và không có tác dụng thay thế thuốc chữa bệnh.
', 1000000, 650000, 35, 1, 40, 0),

(3, 'PRE-03', N'Ostrovit Creatine Monohydrate 500g', N'Ưu điểm của Ostrovit Creatine Monohydrate 500g:
Được sản xuất bởi thương hiệu uy tín Ostrovit:
Creatine Monohydrate 500g được nghiên cứu và sản xuất bởi hãng Ostrovit - nhà cung cấp các dưỡng chất thể thao có nguồn gốc tự nhiên số 1 tại Ba Lan. Ra đời từ năm 2013, Ostrovit nhanh chóng khẳng định vị thế của mình trên thị trường Ba Lan và vươn ra tầm quốc tế với hơn 100 quốc gia phân phối sản phẩm. Ostrovit luôn chú trọng vào việc sử dụng nguyên liệu cao cấp, đa số là thành phần tự nhiên và không chứa chất độc hại, được kiểm định nghiêm ngặt và sản xuất theo quy trình hiện đại. Các sản phẩm của Ostrovit đều được chứng nhận an toàn và hiệu quả bởi các tổ chức uy tín.

Có hương vị trái cây độc đáo:
Không những được sản xuất bởi thương hiệu đình đám Ostrovit, Creatine 500g này còn là creatine duy nhất hiện nay với đa dạng hương vị trái cây cực kỳ thơm ngon, dễ uống. Khách hàng có thể lựa chọn theo sở thích khác nhau với 8 vị khác nhau như: Mango, Cherry, Green Apple, Watermelon, Cola, Lemon, Orange, Unflavored. 
Giá thành hợp lý:
Bên cạnh đó Ostrovit Creatine 500g còn là một trong những loại creatine có thể nói là rất kinh tế, nên hầu như ai đang tập luyện đều có thể mua và sử dụng sản phẩm.

Thành phần của Ostrovit Creatine Monohydrate 500g:
1 serving (3/4 muỗng – 3g) Ostrovit Creatine Monohydrate có chứa: 2600mg - 3000mg Creatine Monohydrate (tùy vị). Ngoài ra có bổ sung thêm Taurine và Vitamin B6 tùy phiên bản.

Công dụng của Ostrovit Creatine Monohydrate 500g:
- Bổ sung nguồn creatine tinh khiết cho cơ thể.
- Tham gia tích cực vào quá trình tái tổng hợp glycogen, dự trữ năng lượng cho cơ bắp.
- Tăng cường hiệu suất tập luyện bằng việc tái tạo, sản xuất thêm ATP.
- Creatine monohydrate giúp cân bằng lượng chất lỏng trong tế bào, từ đó giúp cơ bắp không bị khô.
- Hỗ trợ tăng khối cơ nạc và ngăn chặn mất cơ trong quá trình tập hoặc dinh dưỡng không đầy đủ.
- Tăng sức mạnh và năng lượng dự trữ sâu bên trong các sợi cơ, giúp xây dựng sức mạnh cốt lõi và sẵn sàng thể hiện bất kỳ lúc nào.

Hướng dẫn sử dụng:
Vào ngày không tập: Hòa tan 1 serving (3/4 muỗng) with 100-150 ml nước lọc nguội hoặc nước trái cây (không có tính axit), lắc cho tan hoàn toàn và uống ngay, sử dụng sau khi thức dậy.
Vào ngày tập: Sử dụng 1 servings mỗi ngày, uống sau khi thức dậy hoặc sau khi tập luyện.

Lưu ý:
Nên uống đủ nước hàng ngày khi dùng creatine để hỗ trợ chức năng thận.
Sản phẩm không phải là thuốc và không có tác dụng thay thế thuốc chữa bệnh.
Bảo quản sản phẩm ở nơi khô ráo, thoáng mát.
Sử dụng xong phải đậy kín nắp sản phẩm.
Nếu mẫn cảm với bất kỳ thành phần nào của sản phẩm, hãy tham khảo ý kiến bác sĩ trước khi dùng.
', 600000, 450000, 25, 1, 300, 1),

(4, 'DIE-01', N'Equal Classic Zero Calorie', N'Equal Classic Zero Calorie - giải pháp tạo ngọt tiện lợi không năng lượng:
- Giúp thay thế đường trong chế độ ăn hằng ngày: Sản phẩm mang lại vị ngọt tương tự đường, giúp người dùng dễ dàng thay thế trong các món ăn và đồ uống quen thuộc. Nhờ đó, bạn vẫn có thể thưởng thức vị ngọt mà không cần sử dụng đường thông thường.
- Hỗ trợ giảm lượng đường tiêu thụ: Equal Classic giúp hạn chế lượng đường nạp vào cơ thể khi sử dụng thay thế. Đây là lựa chọn phù hợp cho những ai đang muốn kiểm soát chế độ ăn hoặc điều chỉnh lượng đường hằng ngày.
- Không cung cấp năng lượng mỗi khẩu phần: Mỗi gói sử dụng không chứa calo, giúp người dùng yên tâm hơn khi sử dụng trong khẩu phần ăn. Điều này đặc biệt hữu ích với người quan tâm đến cân nặng.
- Dạng gói nhỏ tiện lợi, dễ sử dụng: Sản phẩm được đóng gói từng gói nhỏ, dễ mang theo và sử dụng ở bất cứ đâu. Người dùng có thể linh hoạt điều chỉnh độ ngọt theo nhu cầu cá nhân.
- Độ ngọt tương đương đường nhưng dễ kiểm soát lượng dùng: Một gói Equal Classic có độ ngọt tương đương 2 muỗng cà phê đường, giúp việc định lượng trở nên đơn giản hơn. Điều này giúp người dùng dễ kiểm soát khẩu phần và thói quen sử dụng.

Equal Classic Zero Calorie là lựa chọn phù hợp cho nhu cầu thay thế đường trong sinh hoạt hằng ngày. Sản phẩm giúp duy trì vị ngọt quen thuộc mà vẫn hỗ trợ kiểm soát lượng đường tiêu thụ. Với dạng gói tiện lợi, đây là giải pháp đơn giản cho chế độ ăn hiện đại.

Thành phần an toàn:
Sản phẩm chứa Lactose (96.1%), là thành phần có nguồn gốc từ sữa, thường xuất hiện trong nhiều loại thực phẩm quen thuộc. Bên cạnh đó là chất tạo ngọt tổng hợp Aspartame (3.6%), giúp tạo vị ngọt thay thế đường, phù hợp cho nhu cầu giảm lượng đường tiêu thụ. Thành phần này góp phần duy trì trải nghiệm vị ngọt quen thuộc khi dùng trong đồ uống và món ăn.

Phù hợp cho người cần kiểm soát lượng đường:
Equal Classic Zero Calorie phù hợp với người muốn giảm lượng đường tiêu thụ trong chế độ ăn hằng ngày. Sản phẩm cũng là lựa chọn dành cho những ai đang kiểm soát cân nặng hoặc muốn điều chỉnh lượng đường nạp vào cơ thể.

Tiện dùng mỗi ngày:
Sản phẩm được thiết kế dạng gói nhỏ (stick), giúp người dùng dễ dàng mang theo khi đi làm, đi học hoặc di chuyển. Mỗi gói có định lượng rõ ràng, giúp kiểm soát độ ngọt một cách thuận tiện. Bên cạnh đó, mỗi gói không chứa kcal và có độ ngọt tương đương với 2 muỗng cà phê đường, giúp việc thay thế đường trở nên đơn giản hơn. Thiết thiết kế nhỏ gọn cũng giúp bảo quản và sử dụng linh hoạt hơn trong nhiều tình huống.

Công dụng của Đường ăn kiêng Classic Zero Calorie Sweetener:
Đường Equal Classic Zero Calorie được sử dụng cùng trà, cà phê hoặc các món ăn để giảm lượng đường nhưng vẫn giữ nguyên vị ngọt.

Cách dùng Đường ăn kiêng Classic Zero Calorie Sweetener:
Sử dụng cùng trà, cà phê hoặc các món ăn. 1 gói Equal tương đương 2 thìa cà phê đường.
Đối tượng sử dụng: Phù hợp cho đối tượng cần kiểm soát cân nặng và lượng đường.
', 90000, NULL, 0, 0, 15, 0),

(4, 'DIE-02', N'Tropicana Slim Classic', N'Công dụng của Đường bắp ăn kiêng Tropicana Slim:
Đường ăn kiêng Tropicana Slim thấp năng lượng dùng để thay thế đường Sucrose.

Cách dùng Đường bắp ăn kiêng Tropicana Slim:
Pha 1 gói (2g) vào 150ml nước uống (nóng hoặc lạnh), có thể sử dụng cho nhiều loại nước uống (trà, cà phê, nước trái cây...) và nấu ăn (luộc, hấp, chiên, nướng…).

Đối tượng sử dụng:
Sản phẩm thích hợp cho người tiểu đường, người ăn kiêng.

Lưu ý:
Sản phẩm này không phải thuốc, không có tác dụng thay thế thuốc chữa bệnh. Tác dụng phụ thuộc vào cơ địa mỗi người.
Bảo quản: Nơi khô ráo, tránh ánh sáng mặt trời trực tiếp.
', 80000, 55000, 31, 1, 20, 0),

(4, 'DIE-03', N'Bye Beo Chili Sauce', N'1. Giới thiệu tương ớt Bye Béo:
Gia vị góp phần không nhỏ tạo nên hương vị món ăn. Tuy nhiên, gia vị công nghiệp là một trong nhiều nguyên nhân khiến bạn tăng cân. Bởi hàm lượng đường cao, nhiều chất điều vị và phụ gia khác.
Hiểu được điều đó, Bye Béo Shop đã nghiên cứu để mang đến sản phẩm Tương ớt Bye Béo, nằm trong hệ sinh thái “Bye Béo từ bếp”. Tương ớt Bye Béo được làm hoàn toàn từ ớt lên men tự nhiên, có vị cay nồng, hơi chua nhẹ. Với hy vọng giúp bữa ăn của bạn ngon miệng và đậm đà hương vị mà vẫn đảm bảo sức khỏe, và mục tiêu giảm cân.

2. Thành phần trong tương ớt Bye Béo:
Ớt, tỏi, bột tỏi, giấm dứa, mật dừa nước, muối biển, nước, axit citric 0.35%, tinh bột khoai tây, xanthan gum (0.18).

3. Công dụng của tương ớt Bye Béo:
Hỗ trợ Bye Béo an toàn, hiệu quả: Không sử dụng đường tinh luyện trong tương ớt, Bye Béo lựa chọn đường dừa nước. Do đó, sản phẩm có chỉ số đường huyết thấp (GI = 49,69). Phù hợp cho người ăn kiêng. Giúp ăn ngon hơn, gia tăng sự đậm đà cho bữa ăn của bạn.

5. Hướng dẫn bảo quản tương ớt Bye Béo:
Ở nhiệt độ thường, tránh ánh nắng trực tiếp. Bảo quản tốt nhất trong tủ lạnh sau khi mở nắp. Không sử dụng khi đã hết hạn sử dụng. Hạn sử dụng: 6 tháng kể từ ngày sản xuất. Quy cách đóng gói: Chai 300g.', 80000, NULL, 0, 0, 50, 0),

(4, 'DIE-04', N'Lut Farm Brown Rice Vermicelli', N'THÀNH PHẦN: 100% gạo lứt hữu cơ – Không sử dụng chất bảo quản.

THÔNG TIN DINH DƯỠNG: (khẩu phần 100g)
– Calo: 352 Kcal
– Protein: 7.87g
– Carbohydrate: 76.9g
– Chất béo: 1.41g

HƯỚNG DẪN NẤU ĂN:
Ngâm trong nước sạch 10 phút. Luộc trong nước sôi 5 phút. Vớt ra, rửa lại với nước sạch. Chắt bỏ nước thừa và trộn với một ít dầu trước khi dùng.
', 50000, NULL, 0, 0, 150, 0),

(4, 'DIE-05', N'Granola', N'Granola là hỗn hợp ngũ cốc dinh dưỡng gồm yến mạch, các loại hạt (hạnh nhân, óc chó, macca...) và trái cây sấy khô được nướng giòn. Đây là lựa chọn tiện lợi và lành mạnh cho bữa sáng hoặc bữa phụ, cung cấp dồi dào protein, chất xơ và vitamin.

Thông tin dinh dưỡng:
Mức năng lượng: 100g Granola cung cấp khoảng 400 - 500 calo.
Khẩu phần khuyên dùng: Khoảng 50g mỗi ngày để tránh nạp dư thừa calo. 

Cách ăn phổ biến:
Bạn có thể dùng trực tiếp hoặc kết hợp với các thực phẩm sau để tăng hương vị:
- Sữa chua: Trộn cùng sữa chua không đường hoặc sữa chua Hy Lạp và thêm trái cây tươi.
- Sữa: Ăn cùng sữa tươi không đường hoặc các loại sữa hạt (sữa hạnh nhân, sữa yến mạch).
- Sinh tố/Salad: Rắc lên các món sinh tố (Smoothie bowl) hoặc salad trái cây. 
', 200000, NULL, 0, 0, 80, 0),

(4, 'DIE-06', N'Peanut Butter Gold Farm', N'Bơ đậu phộng giòn Golden Farm 510g là một mặt hàng thiết yếu trong bếp của nhiều gia đình Việt Nam. Được làm từ những hạt đậu phộng được chọn lọc kỹ lưỡng, rang chín hoàn hảo và xay nhuyễn nhưng vẫn giữ được những mảnh đậu phộng nguyên vẹn, loại bơ đậu phộng này mang đến cả độ mịn và độ giòn. Với công thức đặc biệt, bơ đậu phộng giòn Golden Farm 510g không chỉ mang lại hương vị thơm ngon mà còn cung cấp các dưỡng chất thiết yếu cho cơ thể.
', 50000, NULL, 0, 0, 90, 0),

(5, 'FAT-01', N'Lipo6 Hardcore', N'Thành phần & Công dụng:
Nutrex Lipo6 Hardcore giúp đốt cháy chất béo tối đa, đồng thời cung cấp năng lượng từ việc đốt cháy các chất béo tích tụ bên trong cơ thể. Sản phẩm được sản xuất bởi hãng Nutrex, một trong những thương hiệu thực phẩm bổ sung hàng đầu tại Mỹ.
LIPO-6 HARDCORE với công thức sinh nhiệt mạnh mẽ giúp đốt cháy chất béo tối đa trong khi vẫn duy trì cơ bắp. Thay vì khai thác nguồn dự trữ protein của cơ bắp và nuôi dưỡng mô cơ, cơ thể bạn đang sử dụng chất béo tích tụ trong cơ thể tạo năng lượng giúp bạn hoàn thành các bài tập của mình. Điều này vô cùng quan trọng để bảo vệ các khối cơ.
- Cải thiện vóc dáng
- Tăng sức bền cho buổi tập
- Tăng hiệu suất tập luyện
- Tỉnh táo, tập trung
- Tạo cảm giác no hạn chế cơn thèm ăn
Có thể sử dụng mục đích khác ngoài việc tập luyện như: lái xe ban đêm, thay thế caffeine buổi sáng nhưng vẫn muốn cải thiện cân nặng.

Hướng dẫn sử dụng:
Người lớn: Liều lượng sử dụng cho người mới bắt đầu:
Tuần thứ nhất: sử dụng 1 viên trước buổi tập luyện từ 15 đến 20 phút. Khi đã sử dụng quen và không có tác dụng gì xảy ra thì tăng liều lượng lên 2 viên cho tuần thứ hai.
Tuần thứ hai: sử dụng 2 viên / ngày (1 viên vào buổi sáng trước khi ăn từ 20 phút, 1 viên trước khi tập từ 15 đến 20 phút).
Mỗi ngày không sử dụng quá 2 viên. Nên tham khảo ý kiến của người có chuyên môn trước khi sử dụng.', 500000, 325000, 35, 1, 110, 0),

(5, 'FAT-02', N'Ostrovit CLA', N'Thành phần: L-carnitine 138mg, CLA 300mg, Green Tea 200mg
CLA là một loại axit béo Omega 6 phổ biến nhất, được tìm thấy với hàm lượng lớn trong dầu thực vật và hàm lượng thấp hơn trong một số các thực phẩm khác. CLA thực chất là một loại axit béo không bão hòa hay nói cách khác nó là chất béo chuyển hóa nhưng là một loại chất béo chuyển hóa tự nhiên được tìm thấy trong nhiều loại thực phẩm lành mạnh.

L-carnitine là một chất bổ sung đóng vai trò quan trọng trong việc sản xuất năng lượng bằng cách vận chuyển các acid béo vào ty thể tế bào. Ty thể hoạt động như các động cơ trong các tế bào giúp đốt cháy các chất béo để tạo ra năng lượng có thể sử dụng được.

Green tea một trong những đồ uống tốt nhất cho sức khỏe trên toàn thế giới. Việc bổ sung chất chống oxy hóa và các hợp chất thực vật khác có trong trà xanh vào cơ thể có lợi ích cho sức khỏe của bạn. Ngoài ra nó còn làm tăng quá trình đốt cháy chất béo và giúp bạn giảm cân.

Công dụng:
- Chuyển hóa chất béo thành năng lượng, cải thiện vóc dáng
- Hỗ trợ tăng hiệu suất tập luyện, hạn chế cơn thèm ăn
- Đẩy nhanh quá trình phục hồi cơ bắp sau luyện tập, cung cấp oxi cho cơ bắp
- Tăng sức bền: làm tăng lưu lượng máu và sản xuất oxit nitric giúp trì hoãn và giảm mệt mỏi
- Giảm đau nhức cơ bắp sau khi tập
- Giúp giảm các triệu chứng của bệnh tiểu đường loại 2 và các yếu tố liên quan khác.

Hướng dẫn sử dụng:
Người lớn: Sử dụng một ngày từ 2-3 viên.
Thời gian sử dụng: Sử dụng 1 viên trước khi ăn vào buổi sáng kèm kết hợp tập luyện nhẹ nhàng. 1 viên trước buổi tập chính từ 10-15 phút. Khi đã sử dụng quen với liều lượng 2 viên cho tuần đầu tiên, hãy tăng lên sử dụng 3 viên/ngày và liều dùng tăng lên nên sử dụng vào buổi tối trước khi ăn. Không nên sử dụng liều lượng quá 3 viên/ngày.
', 350000, 245000, 30, 1, 75, 0),

(5, 'FAT-03', N'Raze L-Carnitine 3000', N'Thành phần: 3000mg L-Carnitine, 2mg Vitamin B6, 10mg Vitamin B5
L-Carnitine là một axit amin tự nhiên thường được sử dụng như một chất bổ sung cho cơ thể, đóng vai trò quan trọng trong việc sản xuất năng lượng bằng cách vận chuyển các axit béo vào tế bào để đốt cháy chất béo tạo ra năng lượng. Bổ sung thêm 2 thành phần Vitamin B5, B6 nuôi dưỡng cơ thể và đẩy nhanh quá trình giảm cân hiệu quả.

Công dụng:
- Chuyển hóa chất béo thành năng lượng, cải thiện vóc dáng
- Hỗ trợ tăng hiệu suất tập luyện, hạn chế cơn thèm ăn
- Đẩy nhanh quá trình phục hồi cơ bắp sau luyện tập, cung cấp oxi cho cơ bắp
- Tăng sức bền, giảm đau nhức cơ bắp sau khi tập

Hướng dẫn sử dụng:
Người lớn: Sử dụng một ngày tối đa 1 nắp. Thời gian sử dụng: Sử dụng 1/2 nắp trước khi ăn vào buổi sáng kèm kết hợp tập luyện nhẹ nhàng. Khi đã sử dụng quen với liều lượng 1/2 nắp cho tuần đầu tiên, bạn có thể dùng 2/3 nắp cho những lần dùng tiếp theo.
', 500000, NULL, 0, 0, 40, 0),

(6, 'VIT-01', N'OMEGA 3 PLUS Kenko', N'Hỗ trợ tốt cho não bộ, thị lực và cải thiện sức khỏe tim mạch
- Nguồn Omega 3 đa dạng (DHA, EPA, ALA): Sự kết hợp hoàn hảo giữa dầu cá tinh luyện và dầu nhuyễn thể Krill cùng dầu hạt lanh, cung cấp hàm lượng acid béo thiết yếu hỗ trợ nuôi dưỡng tế bào não và võng mạc.
- Hỗ trợ sức khỏe tim mạch bền vững: Giúp cung cấp các dưỡng chất quan trọng hỗ trợ lưu thông máu, góp phần ổn định chỉ số mỡ máu và cải thiện sức khỏe hệ tuần hoàn.
- Hỗ trợ tốt cho não bộ và thị lực: Giúp tăng cường khả năng tập trung, hỗ trợ bảo vệ mắt trước tác động của lão hóa và giảm tình trạng khô mỏi mắt khi làm việc cường độ cao.
- Công thức hiệp đồng (Nattokinase và vi tảo lục): Bổ sung enzyme Nattokinase hỗ trợ làm tan cục máu đông và Astaxanthin từ vi tảo lục giúp chống oxy hóa mạnh mẽ, bảo vệ mạch máu khỏi gốc tự do.

Cách dùng Viên uống OMEGA 3 PLUS:
Uống 4 viên/ngày với nước nguội hoặc nước ấm.
Đối tượng sử dụng: Thực phẩm bảo vệ sức khỏe Omega 3 Plus thích hợp dùng cho người trưởng thành.
', 900000, NULL, 0, 0, 60, 0),

(6, 'VIT-02', N'Vitamin D3 K2 Calcium', N'Công dụng của Dung dịch Biomicus Vitamin K2 & D3:
BioAmicus vitamin K2 & D3 giúp bổ sung Vitamin D3 & K2 cho cơ thể hỗ trợ tăng cường hấp thu calcium. Hỗ trợ tốt cho sức khỏe xương, răng trẻ em.

Cách dùng Dung dịch Biomicus Vitamin K2 & D3:
- Trẻ sơ sinh 0 - 6 tháng: 3 giọt/ngày.
- Trẻ sơ sinh 7 - 12 tháng: 4 giọt/ngày.
- Trẻ em 1 - 3 tuổi: 7 giọt/ngày.
- Trẻ 4 tuổi trở lên: 10 giọt/ngày.
Có thể thêm vào thức ăn, thức uống hoặc uống trực tiếp. Không cho đầu nhỏ giọt tiếp xúc trực tiếp with miệng. Lắc kỹ trước khi sử dụng.

Đối tượng sử dụng:
BioAmicus Vitamin K2 & D3 thích hợp sử dụng cho các đối tượng sau: Trẻ còi xương, trẻ trong giai đoạn phát triển, trẻ ít tiếp xúc với ánh nắng mặt trời, trẻ có chế độ ăn thiếu vitamin D3 & K2.
', 350000, 245000, 30, 1, 150, 0),

(6, 'VIT-03', N'BioTechUSA Calcium Zinc Magnesium', N'Biotech Calcium Zinc Magnesium bổ sung 4 loại khoáng chất quan trọng: canxi, kẽm, magie, phốt pho đem tới hiệu quả tốt nhất trong quá trình hấp thu canxi vào xương khớp, tóc, răng,... và đảm bảo các hoạt động của mô tế bào diễn ra bình thường. Bên cạnh đó, sản phẩm còn có tác dụng hỗ trợ tổng hợp protein, hỗ trợ quá trình tăng cơ bắp.

Thành phần chính (hàm lượng trên 2 viên):
600mg Canxi, 469mg Phốt pho, 200mg Magie, 9.6mg Kẽm.

Lợi ích sản phẩm:
- Hỗ trợ tăng cường sự khỏe mạnh của xương, khớp, răng.
- Hỗ trợ các hoạt động của cơ bắp, xương khớp diễn ra bình thường.
- Thúc đẩy vận chuyển canxi đến các mô tế bào bao gồm xương, răng, móng...
- Tham gia quá trình phân chia tế bào và quá trình trao đổi chất của cơ thể.
- Hỗ trợ giảm sự mệt mỏi, suy nhược thể lực, cơ bắp.

Hướng dẫn sử dụng:
Sử dụng mỗi ngày 2 viên vào các thời điểm: Sáng sớm ngủ dậy hoặc tối trước khi ngủ.
', 500000, NULL, 0, 0, 95, 0),

(6, 'VIT-04', N'Ostrovit Collagen Vitamin C', N'Tốt cho da, tóc và xương khớp. Thành phần bao gồm Collagen 2200mg và 80mg Vitamin C giúp tăng cường hệ miễn dịch, cải thiện làn da, móng tay, tóc và hỗ trợ giảm triệu chứng viêm khớp, đau khớp.', 500000, 350000, 30, 1, 200, 1),

(6, 'VIT-05', N'Muscletech Platinum Multi Vitamin', N'Vitamin tổng hợp đầy đủ khoáng chất.', 300000, NULL, 0, 0, 80, 0),

(7, 'SNA-01', N'GUfoods Whole Grain Brown Rice Snacks', N'Không chiên dầu, không chất bảo quản, lành mạnh cho sức khỏe.
- Sản xuất theo công nghệ ép thủy lực, giúp giữ lại trọn vẹn dinh dưỡng của gạo lứt.
- Giàu chất xơ, tốt cho hệ tiêu hóa.
- Phù hợp eat clean, ăn vặt healthy, thực dưỡng, tập gym, tập thể thao.
- 1 bánh chứa khoảng 38 calo, thuận tiện tính toán calo cho mỗi bữa ăn.
- Bữa ăn nhẹ tiện lợi, tiết kiệm thời gian nấu nướng.
', 50000, 40000, 20, 0, 30, 0),

(7, 'SNA-02', N'Orgain Protein Snack Bar 12', N'Bao gồm 12 thanh bánh quy sô cô la hữu cơ có nguồn gốc từ thực vật.
10 gam protein sạch từ thực vật hữu cơ (gạo lứt, hạt đậu, hạt chia), 3 gam chất xơ hữu cơ, 5 gam đường, 140 calo mỗi thanh.
Chứng nhận USDA hữu cơ, thuần chay, không chứa sữa (nondairy), không chứa gluten, không chứa lactose, không chứa đậu nành, kosher, không biến đổi gen, không chứa tất cả màu nhân tạo, hương vị và chất bảo quản.
Lý tưởng cho dinh dưỡng lành mạnh khi bạn cần phải di chuyển. Bánh protein Orgain dành cho nam giới, phụ nữ và trẻ em. Các protein trong những chiếc bánh dinh dưỡng Orgain này giúp xây dựng cơ nạc, phục hồi cơ và tuyệt vời cho trước hoặc sau khi tập luyện.
', 700000, NULL, 0, 0, 20, 0),

(7, 'SNA-03', N'Applied Nutrition Critical Cookie', N'Hãy thưởng thức món ăn nhẹ thơm ngon và bổ dưỡng với bánh quy giàu protein Applied Nutrition, mỗi chiếc cung cấp 17g protein trong một chiếc bánh mềm, thơm ngon mới nướng. Hoàn hảo để tiếp thêm năng lượng cho cả ngày, những chiếc bánh quy được đóng gói riêng lẻ này rất lý tưởng để ăn vặt khi di chuyển, phục hồi sau khi tập luyện, hoặc như một món ăn giàu protein tại văn phòng hoặc trong hộp cơm trưa của bạn.

Không chứa chất tạo ngọt nhân tạo, không biến đổi gen, không chứa đậu nành và không chứa chất béo chuyển hóa, những chiếc bánh quy này cung cấp nguồn protein sạch, đáng tin cậy hàng ngày.
', 70000, 49000, 30, 1, 110, 0),

(7, 'SNA-04', N'Co Duyen’s Kitchen Healthy Chicken Jerky', N'Bạn đang tìm kiếm một món ăn vặt vừa ngon miệng, vừa "thân thiện" với vóc dáng? Healthy Chicken Jerky từ nhà Co Duyen’s Kitchen chính là chân ái dành cho bạn! Được chế biến từ 100% ức gà tươi ngon, kết hợp cùng công thức gia vị cải tiến độc quyền, sản phẩm mang đến hương vị đậm đà, dai ngon tự nhiên mà hoàn toàn không gây gánh nặng cho cân nặng.

Điểm Vượt Trội Chỉ Có Tại Co Duyen’s Kitchen:
- 100% Ức Gà Tươi Chọn Lọc: Nguồn protein tinh khiết, ít béo, hỗ trợ săn chắc cơ bắp, cực kỳ phù hợp cho người tập gym, eat-clean hoặc đang trong chế độ giảm cân.
- Công thức "Cắt Giảm" Thông Minh: Giảm tối đa lượng đường và muối so với khô gà truyền thống, không sử dụng dầu mỡ chiên rán, giữ trọn vị ngọt thanh tự nhiên của thịt gà.
- Không Chất Bảo Quản – Không Màu Thực Phẩm.

Thành Phần Dinh Dưỡng Có Gì?
Ức gà tươi phi-lê, gia vị tự nhiên (tỏi, ớt, sả, lá chanh...), đường ăn kiêng/đường thốt nốt tự nhiên.
', 100000, NULL, 0, 0, 45, 0),

(7, 'SNA-05', N'WILDE Protein Chips - Chicken-Based Snack', N'Ức gà không chứa kháng sinh, tinh bột sắn nguyên chất, dầu hướng dương ép lạnh giàu axit oleic, lòng trắng trứng, nước hầm xương gà, chứa ít hơn 2% các thành phần sau: giấm trắng, natri citrate, hương liệu tự nhiên, muối biển, maltodextrin, axit citric, gia vị.
', 150000, 99000, 34, 1, 25, 0);

-- 3.5 Initial Stock Ledger (Đổ số lượng 100 cho tất cả 29 sản phẩm vào bảng Stock như cũ)
INSERT INTO Stock (product_id, staff_id, quantity) VALUES
(1, 1, 100), (2, 1, 100), (3, 1, 100), (4, 1, 100), (5, 1, 100), 
(6, 1, 100), (7, 1, 100), (8, 1, 100), (9, 1, 100), (10, 1, 100), 
(11, 1, 100), (12, 1, 100), (13, 1, 100), (14, 1, 100), (15, 1, 100), 
(16, 1, 100), (17, 1, 100), (18, 1, 100), (19, 1, 100), (20, 1, 100), 
(21, 1, 100), (22, 1, 100), (23, 1, 100), (24, 1, 100), (25, 1, 100), 
(26, 1, 100), (27, 1, 100), (28, 1, 100), (29, 1, 100);

-- 3.6 Product Images
INSERT INTO Product_Images (product_id, image_url, is_primary) VALUES 
(1, 'ONGoldStandard100Whey 5lbs.jpg', 1),
(2, 'MutantIsoSurge5lbs.jpg', 1),
(3, 'NutrabolicsHydropure100HydrolyzedWhey.jpg', 1),
(4, 'BeverlyHydroProtein1kg.jpg', 1),
(5, 'Redcon1Mass Gainer5.89lbs.jpg', 1),
(6, 'EliteLabsMass Muscle Gainer10lbs.jpg', 1),
(7, 'MassTrueGainer.jpg', 1),
(8, 'Redcon1Total WarReloadedPre-workout546g.jpg', 1),
(9, 'BeverlyDynamitePre-Workout375g.jpg', 1),
(10, 'OstrovitCreatine Monohydrate500g.jpg', 1),
(11, 'EqualClassicZeroCalorie.jpg', 1),
(12, 'TropicanaSlimClassic.jpg', 1),
(13, 'tuongotbyebeo.jpg', 1),
(13, 'tuongotbyebeo1.jpg', 0),
(14, 'LutFarmBrown RiceVermicelli.jpg', 1),
(15, 'Granola.jpg', 1),
(16, 'PeanutButter GoldFarm.jpg', 1),
(17, 'Lipo6Hardcore.jpg', 1),
(18, 'OstrovitCLA.jpg', 1),
(19, 'Raze L-Carnitine 3000.jpg', 1),
(20, 'OMEGA3PLUSKenko.jpg', 1),
(21, 'VitaminD3K2Calcium.jpg', 1),
(22, 'BioTechUSACalciumZincMagnesium.jpg', 1),
(23, 'OstrovitCollagenVitaminC.jpg', 1),
(24, 'MuscletechPlatinumMultiVitamin.jpg', 1),
(25, 'GUfoodsWholeGrainBrownRice Snacks.jpg', 1),
(26, 'OrgainProteinSnack Bar12.jpg', 1),
(27, 'AppliedNutritionCriticalCookie.jpg', 1),
(28, 'Co DuyenKitchen HealthyChickenJerky.jpg', 1),
(29, 'WILDEProteinChipsChickenBasedSnack.jpg', 1);

-- 3.7 Favorites
INSERT INTO Favorites (user_id, product_id) VALUES (2, 1), (2, 2);

-- 3.8 Reviews
INSERT INTO Reviews (product_id, user_id, rating, comment_text) VALUES 
(1, 2, 5, N'Sữa uống rất ngon, tan nhanh, shop giao hàng hỏa tốc.'),
(2, 1, 4, N'Uống thấy người khỏe hơn hẳn, sẽ mua lại.');

-- 3.9 Orders (Đầy đủ khóa ngoại liên kết sang Customer có ID = 2 và thêm code)
INSERT INTO Orders (user_id, total_amount, status, coupon_id, discount_applied, coupon_code, payment_method, payment_status, shipping_address) 
VALUES (2, 2550000, 'SHIPPED', 1, 50000, 'NUTRIOVERFLOW50K', 'VNPAY', 'PAID', N'123 Đường ABC, Quận 1, TP.HCM');

-- 3.10 Payment & Delivery (Ghi nhận đúng thực thể dữ liệu phân rã của database trên)
INSERT INTO Payment (order_id, payment_method, payment_status, amount, user_id) 
VALUES (1, 'VNPAY', 'PAID', 2550000, 2);

INSERT INTO Delivery (order_id, shipping_address, shipping_fee, status) 
VALUES (1, N'123 Đường ABC, Quận 1, TP.HCM', 0, 'SHIPPED');

-- 3.11 Order Details
INSERT INTO Order_Details (order_id, product_id, quantity, price_at_purchase) VALUES 
(1, 1, 1, 2000000), 
(1, 2, 1, 600000);

-- Trừ số lượng kho qua bảng Nhật ký Stock Ledger đặc thù
INSERT INTO Stock (product_id, staff_id, quantity) VALUES
(1, NULL, -1), (2, NULL, -1);

-- 3.12 Order Tracking
INSERT INTO Order_Tracking (order_id, status, description, updated_at) VALUES 
(1, 'PENDING', N'Đơn hàng đã được đặt thành công. Đang chờ xác nhận.', '2026-05-15 08:00:00'),
(1, 'PROCESSING', N'Shop đang đóng gói sản phẩm.', '2026-05-15 10:30:00'),
(1, 'SHIPPED', N'Đơn hàng đã được giao cho đơn vị vận chuyển (GHN).', '2026-05-15 15:00:00');
GO

-- 3.13 Articles seed data
INSERT INTO Articles (title, summary, content, image_url, author_username, author_name, status, is_published) VALUES 
(N'Cẩm nang sử dụng Whey Protein đúng cách và an toàn', 
 N'Whey Protein là thực phẩm bổ sung phổ biến giúp phát triển cơ bắp, tuy nhiên việc sử dụng sai cách có thể giảm hiệu quả hoặc gây tác dụng phụ.', 
 N'<h4>1. Whey Protein là gì?</h4><p>Whey Protein là nguồn đạm chất lượng cao được chiết xuất từ sữa bò trong quá trình sản xuất phô mai.</p><h4>2. Hướng dẫn sử dụng đúng liều lượng</h4><p>Mỗi ngày người trưởng thành nên dùng từ 1-2 muỗng để bổ sung protein hiệu quả.</p>', 
 'image/articles/whey_guide.jpg', 'admin', N'Quản trị viên', 'APPROVED', 1),
(N'Chế độ ăn tăng cơ giảm mỡ (Recomp) cho người mới bắt đầu', 
 N'Body Recomposition là quá trình xây dựng cơ bắp đồng thời giảm mỡ thừa. Đây là mục tiêu hướng tới của rất nhiều Gymer.', 
 N'<h4>1. Nguyên lý hoạt động</h4><p>Để tăng cơ giảm mỡ, bạn cần có chế độ tập luyện kháng lực khoa học đi kèm mức calo vừa đủ cùng lượng protein dồi dào.</p>', 
 'image/articles/recomp_diet.jpg', 'admin', N'Quản trị viên', 'APPROVED', 1);
GO

-- Kích hoạt lại toàn bộ trigger sau khi chèn dữ liệu mẫu
ALTER TABLE Account ENABLE TRIGGER ALL;
ALTER TABLE Customer ENABLE TRIGGER ALL;
ALTER TABLE Staff ENABLE TRIGGER ALL;
ALTER TABLE Products ENABLE TRIGGER ALL;
ALTER TABLE Stock ENABLE TRIGGER ALL;
ALTER TABLE Orders ENABLE TRIGGER ALL;
ALTER TABLE Payment ENABLE TRIGGER ALL;
ALTER TABLE Delivery ENABLE TRIGGER ALL;
GO

-- Đồng bộ tồn kho của Products theo bảng Stock sau khi chèn dữ liệu mẫu
UPDATE p
SET p.stock_quantity = COALESCE((SELECT SUM(s.quantity) FROM Stock s WHERE s.product_id = p.product_id), 0)
FROM Products p;
GO

-- Đồng bộ ảnh đại diện của Products theo bảng Product_Images sau khi chèn dữ liệu mẫu
UPDATE p
SET p.image_url = pi.image_url
FROM Products p
INNER JOIN Product_Images pi ON p.product_id = pi.product_id
WHERE pi.is_primary = 1;
GO

PRINT 'Successfully updated database NutriOverflow with schema 1 structure and ALL detailed descriptions!';
GO
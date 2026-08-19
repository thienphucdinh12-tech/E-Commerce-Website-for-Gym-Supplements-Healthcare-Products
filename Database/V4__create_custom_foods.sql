-- V4__create_custom_foods.sql
-- Create table for storing custom/local foods (signature Vietnamese dishes)

IF EXISTS (SELECT * FROM sys.tables WHERE name = 'Custom_Foods')
BEGIN
    DROP TABLE Custom_Foods;
END

CREATE TABLE Custom_Foods (
    food_id INT IDENTITY(1,1) PRIMARY KEY,
    food_name NVARCHAR(255) NOT NULL UNIQUE,
    calories INT NOT NULL,
    protein_g FLOAT DEFAULT 0.0,
    carbs_g FLOAT DEFAULT 0.0,
    fat_g FLOAT DEFAULT 0.0,
    serving_size NVARCHAR(100) DEFAULT N'1 phần',
    description NVARCHAR(MAX) NULL,
    created_at DATETIME DEFAULT GETDATE()
);

-- Insert sample Vietnamese foods
INSERT INTO Custom_Foods (food_name, calories, protein_g, carbs_g, fat_g, serving_size, description) VALUES
(N'Phở bò', 350, 15.0, 52.0, 8.0, N'1 tô', N'Phở bò truyền thống Việt Nam với bánh phở, thịt bò và nước dùng xương hầm.'),
(N'Cơm tấm sườn', 527, 22.0, 71.0, 17.0, N'1 đĩa', N'Cơm tấm sườn nướng đặc trưng Sài Gòn.'),
(N'Bún chả', 450, 18.0, 65.0, 12.0, N'1 phần', N'Bún chả Hà Nội gồm bún, chả nướng và nước mắm pha ngọt.'),
(N'Bánh mì kẹp thịt', 400, 12.0, 48.0, 15.0, N'1 ổ', N'Bánh mì pa-tê, thịt nguội, chả lụa và rau dưa.'),
(N'Gỏi cuốn tôm thịt', 120, 6.5, 15.0, 2.5, N'2 cái', N'Gỏi cuốn gồm tôm, thịt heo, bún và rau thơm cuốn bánh tráng.'),
(N'Cơm chiên dương châu', 530, 14.0, 78.0, 16.0, N'1 dĩa', N'Cơm chiên hỗn hợp lạp xưởng, tôm, đậu Hà Lan, cà rốt.'),
(N'Phở gà', 320, 18.0, 47.0, 6.5, N'1 tô', N'Phở gà với nước dùng thanh ngọt, thịt lườn gà xé.'),
(N'Bún bò Huế', 480, 20.0, 62.0, 16.0, N'1 tô', N'Bún bò Huế cay nồng với giò heo, thịt bò nạm và chả cua.');

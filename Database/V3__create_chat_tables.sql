-- V3__create_chat_tables.sql
-- Create tables for chat feature (AI & CSKH Handoff)

CREATE TABLE Chat_Sessions (
    session_id INT IDENTITY(1,1) PRIMARY KEY,
    customer_name NVARCHAR(255) NOT NULL,
    customer_id INT NULL,
    status VARCHAR(50) DEFAULT 'ACTIVE',
    assigned_staff_id INT NULL,
    created_at DATETIME DEFAULT GETDATE(),
    last_message_at DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (customer_id) REFERENCES Customer(user_id) ON DELETE NO ACTION,
    FOREIGN KEY (assigned_staff_id) REFERENCES Staff(staff_id) ON DELETE NO ACTION
);

CREATE TABLE Chat_Messages (
    message_id INT IDENTITY(1,1) PRIMARY KEY,
    session_id INT NOT NULL,
    sender_type VARCHAR(50) NOT NULL, -- 'CUSTOMER', 'AI', 'STAFF'
    sender_name NVARCHAR(255) NOT NULL,
    message_text NVARCHAR(MAX) NOT NULL,
    sent_at DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (session_id) REFERENCES Chat_Sessions(session_id) ON DELETE CASCADE
);

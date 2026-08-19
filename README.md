# 🏋️‍♂️ NutriOverflow — E-Commerce Website & Admin Platform

Hệ thống Website bán hàng Thể hình, Thực phẩm bổ sung & Sức khỏe (Java Web App JSP/Servlet, NetBeans, SQL Server, Tomcat 9).

---

## 🚀 Hướng dẫn chạy nhanh bằng Docker (Khuyên dùng)

Bạn không cần phải cài đặt thủ công Java 8, Tomcat 9 hay SQL Server. Chỉ cần cài sẵn **Docker Desktop** và chạy 1 câu lệnh duy nhất:

### 1. Bật toàn bộ hệ thống bằng Docker Compose:
```bash
docker compose up -d --build
```

### 2. Truy cập ứng dụng:
- **Trang chủ Cửa hàng (Website)**: [http://localhost:8080/NutriOverflow_Website/](http://localhost:8080/NutriOverflow_Website/)
- **Trang Quản trị (Admin)**: [http://localhost:8080/NutriOverflow_Admin/](http://localhost:8080/NutriOverflow_Admin/)
- **Database (SQL Server)**: `localhost:1433` (User: `sa`, Password: `YourPassword123!`)

### 3. Tắt hệ thống Docker:
```bash
docker compose down
```

---

## 🛠️ Hướng dẫn chạy thủ công trên máy local (NetBeans IDE)

### Yêu cầu hệ thống:
- Java JDK 1.8 (Java 8)
- Apache Tomcat 9.0
- Microsoft SQL Server

### Các bước thực hiện:
1. Import database script tại `Database/full_database_nutrioverflow.sql` vào SQL Server.
2. Mở NetBeans IDE 13, chọn `File -> Open Project` và chọn thư mục:
   - `Nutri_Overflow_Website`
   - `Nutri_Overflow_Admin`
3. Kiểm tra thông tin kết nối Database tại `utils.DBUtils.java` (`DB_HOST`, `USER_NAME`, `PASSWORD`).
4. Nhấn **Clean & Build**, sau đó bấm **Run (F6)** trên NetBeans.

---

## 📁 Cấu trúc Thư mục Repository:
```
ISP302_WEB/
├── Database/                         # Chứa SQL Schema & Dữ liệu khởi tạo (V1 - V6)
├── Nutri_Overflow_Website/           # Mã nguồn Web App dành cho Khách hàng
├── Nutri_Overflow_Admin/             # Mã nguồn Web App dành cho Quản trị viên
├── docker/                           # Kịch bản khởi tạo Docker Container
├── Dockerfile                        # Docker Image definition cho Tomcat Web Server
├── docker-compose.yml                # File Orchestration chạy Web & Database SQL Server
└── README.md                         # Tài liệu hướng dẫn project
```

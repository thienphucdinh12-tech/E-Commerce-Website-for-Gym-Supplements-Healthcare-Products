package listeners;

import org.flywaydb.core.Flyway;
import javax.servlet.ServletContextEvent;
import javax.servlet.ServletContextListener;
import javax.servlet.annotation.WebListener;
import java.lang.reflect.Field;

@WebListener
public class DatabaseMigrationListener implements ServletContextListener {

    @Override
    public void contextInitialized(ServletContextEvent sce) {
        System.out.println("============================================================");
        System.out.println("  FLYWAY DATABASE MIGRATION - STARTING SYSTEM CHECK...");
        System.out.println("============================================================");

        // Giá trị mặc định phòng hờ lỗi Reflection
        String dbHost = "localhost";
        String dbName = "NutriOverflow";
        String userName = "sa";
        String password = "12345";

        try {
            // Đọc thông tin cấu hình động từ utils.DBUtils qua Reflection
            // Cách này giúp nếu lập trình viên đổi mật khẩu hoặc IP ở DBUtils, Flyway sẽ tự động cập nhật theo.
            Class<?> dbUtilsClass = Class.forName("utils.DBUtils");
            
            try {
                Field dbHostField = dbUtilsClass.getDeclaredField("DB_HOST");
                dbHostField.setAccessible(true);
                dbHost = (String) dbHostField.get(null);
            } catch (NoSuchFieldException e) {
                System.out.println("Flyway: Field DB_HOST not found in DBUtils, using default: " + dbHost);
            }

            try {
                Field dbNameField = dbUtilsClass.getDeclaredField("DB_NAME");
                dbNameField.setAccessible(true);
                dbName = (String) dbNameField.get(null);
            } catch (NoSuchFieldException e) {
                System.out.println("Flyway: Field DB_NAME not found in DBUtils, using default: " + dbName);
            }

            try {
                Field userNameField = dbUtilsClass.getDeclaredField("USER_NAME");
                userNameField.setAccessible(true);
                userName = (String) userNameField.get(null);
            } catch (NoSuchFieldException e) {
                System.out.println("Flyway: Field USER_NAME not found in DBUtils, using default: " + userName);
            }

            try {
                Field passwordField = dbUtilsClass.getDeclaredField("PASSWORD");
                passwordField.setAccessible(true);
                password = (String) passwordField.get(null);
            } catch (NoSuchFieldException e) {
                System.out.println("Flyway: Field PASSWORD not found in DBUtils, using default: ******");
            }

        } catch (Exception e) {
            System.err.println("Flyway: Không thể đọc cấu hình từ DBUtils qua Reflection, sử dụng giá trị mặc định.");
        }

        try {
            // Tạo chuỗi kết nối JDBC URL tương ứng với SQL Server
            String url = "jdbc:sqlserver://" + dbHost + ":1433;databaseName=" + dbName + ";encrypt=false;trustServerCertificate=true";

            System.out.println("Flyway: Đang kết nối tới database tại " + dbHost + ": " + dbName + " với tài khoản: " + userName);

            // Cấu hình Flyway
            Flyway flyway = Flyway.configure()
                .dataSource(url, userName, password)
                .locations("classpath:db/migration")
                .baselineOnMigrate(true) // Bật tính năng đánh mốc cho database đã có dữ liệu
                .baselineVersion("3")   // Đặt mốc cơ sở ban đầu là Version 3
                .load();

            // Tự động sửa chữa checksum nếu phát hiện sai lệch file migration cũ
            flyway.repair();

            // Thực hiện quá trình Migration
            flyway.migrate();

            System.out.println("============================================================");
            System.out.println("  FLYWAY DATABASE MIGRATION - COMPLETED SUCCESSFULLY!");
            System.out.println("============================================================");
        } catch (Exception e) {
            System.err.println("============================================================");
            System.err.println("  FLYWAY DATABASE MIGRATION - FAILED TO RUN MIGRATIONS!");
            System.err.println("  Error: " + e.getMessage());
            System.err.println("============================================================");
            e.printStackTrace();
        }
    }

    @Override
    public void contextDestroyed(ServletContextEvent sce) {
        // Hủy tài nguyên (không cần thiết với Flyway)
    }
}

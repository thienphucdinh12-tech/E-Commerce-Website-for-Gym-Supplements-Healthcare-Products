package utils;

import java.sql.Connection;
import java.sql.Statement;

public class SchemaMigration {
    public static void main(String[] args) {
        String[] sqls = {
            "IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('Stock') AND name = 'batch_number') " +
            "ALTER TABLE Stock ADD batch_number VARCHAR(50) NULL;",
            
            "IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('Stock') AND name = 'mfg_date') " +
            "ALTER TABLE Stock ADD mfg_date DATE NULL;",
            
            "IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('Stock') AND name = 'exp_date') " +
            "ALTER TABLE Stock ADD exp_date DATE NULL;",
            
            "IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('Stock') AND name = 'distributor_name') " +
            "ALTER TABLE Stock ADD distributor_name NVARCHAR(255) NULL;"
        };
        
        try (Connection conn = DBUtils.getConnection();
             Statement stmt = conn.createStatement()) {
            System.out.println("Running database migrations...");
            for (String sql : sqls) {
                stmt.execute(sql);
                System.out.println("Executed: " + sql);
            }
            System.out.println("Database migration completed successfully!");
        } catch (Exception e) {
            System.err.println("Migration failed: " + e.getMessage());
            e.printStackTrace();
        }
    }
}

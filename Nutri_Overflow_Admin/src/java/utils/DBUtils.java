package utils;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class DBUtils {

    private static final String DB_HOST = "100.85.251.36";
    private static final String DB_NAME = "NutriOverflow";
    private static final String USER_NAME = "sa"; 
    private static final String PASSWORD = "12345"; 

    public static Connection getConnectionV1() throws ClassNotFoundException, SQLException {
        Connection conn = null;
        Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
        String url = "jdbc:sqlserver://" + DB_HOST + ":1433;databaseName=" + DB_NAME + ";encrypt=false;trustServerCertificate=true";
        conn = DriverManager.getConnection(url, USER_NAME, PASSWORD);
        return conn;
    }

    public static Connection getConnection() throws Exception {
        return getConnectionV1();
    }
}
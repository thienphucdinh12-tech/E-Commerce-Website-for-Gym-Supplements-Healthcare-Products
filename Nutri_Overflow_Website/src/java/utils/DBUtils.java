package utils;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class DBUtils {

    private static final String DEFAULT_DB_HOST = "localhost";
    private static final String DEFAULT_DB_NAME = "NutriOverflow";
    private static final String DEFAULT_USER_NAME = "sa"; 
    private static final String DEFAULT_PASSWORD = "12345"; 

    public static String getDbHost() {
        String env = System.getenv("DB_HOST");
        return (env != null && !env.trim().isEmpty()) ? env : DEFAULT_DB_HOST;
    }

    public static String getDbName() {
        String env = System.getenv("DB_NAME");
        return (env != null && !env.trim().isEmpty()) ? env : DEFAULT_DB_NAME;
    }

    public static String getUserName() {
        String env = System.getenv("DB_USER");
        return (env != null && !env.trim().isEmpty()) ? env : DEFAULT_USER_NAME;
    }

    public static String getPassword() {
        String env = System.getenv("DB_PASSWORD");
        return (env != null && !env.trim().isEmpty()) ? env : DEFAULT_PASSWORD;
    }

    public static Connection getConnectionV1() throws ClassNotFoundException, SQLException {
        Connection conn = null;
        Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
        String host = getDbHost();
        String port = System.getenv("DB_PORT") != null ? System.getenv("DB_PORT") : "1433";
        String url;
        if (host.contains("\\")) {
            url = "jdbc:sqlserver://" + host + ";databaseName=" + getDbName() + ";encrypt=false;trustServerCertificate=true";
        } else {
            url = "jdbc:sqlserver://" + host + ":" + port + ";databaseName=" + getDbName() + ";encrypt=false;trustServerCertificate=true";
        }
        conn = DriverManager.getConnection(url, getUserName(), getPassword());
        return conn;
    }

    public static Connection getConnection() throws Exception {
        return getConnectionV1();
    }
}
package shopping;

import utils.DBUtils;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class StockBatchDAO {

    public List<StockBatchDTO> getAllBatches(String search) {
        List<StockBatchDTO> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder(
            "SELECT s.stock_id, s.product_id, p.name AS product_name, p.sku, " +
            "       st.full_name AS staff_name, s.quantity, s.batch_number, " +
            "       s.mfg_date, s.exp_date, s.distributor_name, s.updated_at " +
            "FROM Stock s " +
            "JOIN Products p ON s.product_id = p.product_id " +
            "LEFT JOIN Staff st ON s.staff_id = st.staff_id " +
            "WHERE 1=1"
        );
        
        List<Object> params = new ArrayList<>();
        if (search != null && !search.trim().isEmpty()) {
            sql.append(" AND (p.name LIKE ? OR p.sku LIKE ? OR s.batch_number LIKE ? OR s.distributor_name LIKE ?)");
            String searchPattern = "%" + search.trim() + "%";
            params.add(searchPattern);
            params.add(searchPattern);
            params.add(searchPattern);
            params.add(searchPattern);
        }
        
        sql.append(" ORDER BY s.updated_at DESC, s.stock_id DESC");
        
        try (Connection conn = DBUtils.getConnection();
             PreparedStatement ptm = conn.prepareStatement(sql.toString())) {
            
            for (int i = 0; i < params.size(); i++) {
                ptm.setObject(i + 1, params.get(i));
            }
            
            try (ResultSet rs = ptm.executeQuery()) {
                while (rs.next()) {
                    StockBatchDTO batch = new StockBatchDTO(
                        rs.getInt("stock_id"),
                        rs.getInt("product_id"),
                        rs.getString("product_name"),
                        rs.getString("sku"),
                        rs.getString("staff_name") != null ? rs.getString("staff_name") : "Hệ thống",
                        rs.getInt("quantity"),
                        rs.getString("batch_number"),
                        rs.getDate("mfg_date"),
                        rs.getDate("exp_date"),
                        rs.getString("distributor_name"),
                        rs.getTimestamp("updated_at")
                    );
                    list.add(batch);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public boolean insertBatch(int productId, int quantity, String batchNumber, String mfgDate, String expDate, String distributorName, String staffUsername) throws Exception {
        String sqlGetStaffId = "SELECT s.staff_id FROM Staff s JOIN Account a ON s.account_id = a.account_id WHERE a.username = ?";
        String sqlInsertStock = "INSERT INTO Stock (product_id, staff_id, quantity, batch_number, mfg_date, exp_date, distributor_name, updated_at) VALUES (?, ?, ?, ?, ?, ?, ?, GETDATE())";
        
        try (Connection conn = DBUtils.getConnection()) {
            Integer staffId = null;
            try (PreparedStatement ps = conn.prepareStatement(sqlGetStaffId)) {
                ps.setString(1, staffUsername);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        staffId = rs.getInt("staff_id");
                    }
                }
            }
            
            try (PreparedStatement ps = conn.prepareStatement(sqlInsertStock)) {
                ps.setInt(1, productId);
                if (staffId != null) ps.setInt(2, staffId);
                else                  ps.setNull(2, Types.INTEGER);
                ps.setInt(3, quantity);
                ps.setString(4, batchNumber);
                
                if (mfgDate != null && !mfgDate.trim().isEmpty()) {
                    ps.setDate(5, java.sql.Date.valueOf(mfgDate));
                } else {
                    ps.setNull(5, Types.DATE);
                }
                
                if (expDate != null && !expDate.trim().isEmpty()) {
                    ps.setDate(6, java.sql.Date.valueOf(expDate));
                } else {
                    ps.setNull(6, Types.DATE);
                }
                
                ps.setString(7, distributorName != null && !distributorName.trim().isEmpty() ? distributorName.trim() : null);
                
                return ps.executeUpdate() > 0;
            }
        }
    }
}

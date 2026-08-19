package shopping;

import utils.DBUtils;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class SupportTicketDAO {

    /**
     * Retrieves all support tickets based on search query, status filter, and category filter.
     * Orders PENDING tickets first, then PROCESSING, FORWARDED, and RESOLVED, then by created_at DESC.
     */
    public List<SupportTicketDTO> getAllTickets(String search, String statusFilter, String categoryFilter) {
        List<SupportTicketDTO> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder(
            "SELECT t.ticket_id, t.user_id, t.order_id, t.category, t.title, t.description, " +
            "       t.status, t.assigned_staff_id, t.feedback, t.created_at, t.updated_at, " +
            "       c.full_name AS customer_name, s.full_name AS staff_name " +
            "FROM Support_Tickets t " +
            "LEFT JOIN Customer c ON t.user_id = c.user_id " +
            "LEFT JOIN Staff s ON t.assigned_staff_id = s.staff_id " +
            "WHERE 1=1 "
        );

        List<Object> params = new ArrayList<>();

        if (search != null && !search.trim().isEmpty()) {
            sql.append("AND (t.title LIKE ? OR t.description LIKE ? OR c.full_name LIKE ? " +
                       "OR CAST(t.ticket_id AS VARCHAR) LIKE ? OR CAST(t.order_id AS VARCHAR) LIKE ?) ");
            String searchPattern = "%" + search.trim() + "%";
            params.add(searchPattern);
            params.add(searchPattern);
            params.add(searchPattern);
            params.add(searchPattern);
            params.add(searchPattern);
        }

        if (statusFilter != null && !statusFilter.trim().isEmpty() && !"all".equalsIgnoreCase(statusFilter)) {
            sql.append("AND t.status = ? ");
            params.add(statusFilter.trim().toUpperCase());
        }

        if (categoryFilter != null && !categoryFilter.trim().isEmpty() && !"all".equalsIgnoreCase(categoryFilter)) {
            sql.append("AND t.category = ? ");
            params.add(categoryFilter.trim());
        }

        sql.append("ORDER BY CASE " +
                   "  WHEN t.status = 'PENDING' THEN 0 " +
                   "  WHEN t.status = 'PROCESSING' THEN 1 " +
                   "  WHEN t.status = 'FORWARDED' THEN 2 " +
                   "  ELSE 3 " +
                   "END ASC, t.created_at DESC");

        try (Connection conn = DBUtils.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {

            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    SupportTicketDTO ticket = new SupportTicketDTO(
                        rs.getInt("ticket_id"),
                        rs.getObject("user_id") != null ? rs.getInt("user_id") : null,
                        rs.getObject("order_id") != null ? rs.getInt("order_id") : null,
                        rs.getString("category"),
                        rs.getString("title"),
                        rs.getString("description"),
                        rs.getString("status"),
                        rs.getObject("assigned_staff_id") != null ? rs.getInt("assigned_staff_id") : null,
                        rs.getString("feedback"),
                        rs.getTimestamp("created_at"),
                        rs.getTimestamp("updated_at")
                    );
                    ticket.setCustomerName(rs.getString("customer_name") != null ? rs.getString("customer_name") : "Khách vãng lai");
                    ticket.setStaffName(rs.getString("staff_name"));
                    list.add(ticket);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    /**
     * Retrieves a single support ticket by its ID.
     */
    public SupportTicketDTO getTicketById(int ticketId) {
        String sql = 
            "SELECT t.ticket_id, t.user_id, t.order_id, t.category, t.title, t.description, " +
            "       t.status, t.assigned_staff_id, t.feedback, t.created_at, t.updated_at, " +
            "       c.full_name AS customer_name, s.full_name AS staff_name " +
            "FROM Support_Tickets t " +
            "LEFT JOIN Customer c ON t.user_id = c.user_id " +
            "LEFT JOIN Staff s ON t.assigned_staff_id = s.staff_id " +
            "WHERE t.ticket_id = ?";

        try (Connection conn = DBUtils.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, ticketId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    SupportTicketDTO ticket = new SupportTicketDTO(
                        rs.getInt("ticket_id"),
                        rs.getObject("user_id") != null ? rs.getInt("user_id") : null,
                        rs.getObject("order_id") != null ? rs.getInt("order_id") : null,
                        rs.getString("category"),
                        rs.getString("title"),
                        rs.getString("description"),
                        rs.getString("status"),
                        rs.getObject("assigned_staff_id") != null ? rs.getInt("assigned_staff_id") : null,
                        rs.getString("feedback"),
                        rs.getTimestamp("created_at"),
                        rs.getTimestamp("updated_at")
                    );
                    ticket.setCustomerName(rs.getString("customer_name") != null ? rs.getString("customer_name") : "Khách vãng lai");
                    ticket.setStaffName(rs.getString("staff_name"));
                    return ticket;
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    /**
     * Updates a ticket's status, feedback response, and assigns the processing staff.
     */
    public boolean updateTicket(int ticketId, String status, String feedback, String staffUsername) {
        String sqlGetStaffId = 
            "SELECT s.staff_id FROM Staff s " +
            "JOIN Account a ON s.account_id = a.account_id " +
            "WHERE a.username = ?";
        
        String sqlUpdate = 
            "UPDATE Support_Tickets " +
            "SET status = ?, feedback = ?, assigned_staff_id = ?, updated_at = GETDATE() " +
            "WHERE ticket_id = ?";

        try (Connection conn = DBUtils.getConnection()) {
            Integer staffId = null;
            try (PreparedStatement psStaff = conn.prepareStatement(sqlGetStaffId)) {
                psStaff.setString(1, staffUsername);
                try (ResultSet rs = psStaff.executeQuery()) {
                    if (rs.next()) {
                        staffId = rs.getInt("staff_id");
                    }
                }
            }

            try (PreparedStatement psUpdate = conn.prepareStatement(sqlUpdate)) {
                psUpdate.setString(1, status.toUpperCase());
                psUpdate.setString(2, feedback);
                if (staffId != null) {
                    psUpdate.setInt(3, staffId);
                } else {
                    psUpdate.setNull(3, Types.INTEGER);
                }
                psUpdate.setInt(4, ticketId);
                return psUpdate.executeUpdate() > 0;
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    /**
     * Deletes a support ticket by ID. Only used by administrators.
     */
    public boolean deleteTicket(int ticketId) {
        String sql = "DELETE FROM Support_Tickets WHERE ticket_id = ?";
        try (Connection conn = DBUtils.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, ticketId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }
}

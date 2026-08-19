package shopping;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import utils.DBUtils;

public class CustomFoodDAO {
    
    public List<CustomFoodDTO> getAllCustomFoods(String search) throws Exception {
        List<CustomFoodDTO> list = new ArrayList<>();
        String sql = "SELECT food_id, food_name, calories, protein_g, carbs_g, fat_g, serving_size, description, created_at " +
                     "FROM Custom_Foods WHERE food_name LIKE ? ORDER BY food_name";
        try (Connection conn = DBUtils.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, "%" + search + "%");
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(new CustomFoodDTO(
                        rs.getInt("food_id"),
                        rs.getString("food_name"),
                        rs.getInt("calories"),
                        rs.getDouble("protein_g"),
                        rs.getDouble("carbs_g"),
                        rs.getDouble("fat_g"),
                        rs.getString("serving_size"),
                        rs.getString("description"),
                        rs.getTimestamp("created_at")
                    ));
                }
            }
        }
        return list;
    }
    
    public CustomFoodDTO getCustomFoodById(int foodId) throws Exception {
        String sql = "SELECT food_id, food_name, calories, protein_g, carbs_g, fat_g, serving_size, description, created_at " +
                     "FROM Custom_Foods WHERE food_id = ?";
        try (Connection conn = DBUtils.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, foodId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return new CustomFoodDTO(
                        rs.getInt("food_id"),
                        rs.getString("food_name"),
                        rs.getInt("calories"),
                        rs.getDouble("protein_g"),
                        rs.getDouble("carbs_g"),
                        rs.getDouble("fat_g"),
                        rs.getString("serving_size"),
                        rs.getString("description"),
                        rs.getTimestamp("created_at")
                    );
                }
            }
        }
        return null;
    }
    
    public boolean insertCustomFood(CustomFoodDTO food) throws Exception {
        String sql = "INSERT INTO Custom_Foods (food_name, calories, protein_g, carbs_g, fat_g, serving_size, description) " +
                     "VALUES (?, ?, ?, ?, ?, ?, ?)";
        try (Connection conn = DBUtils.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, food.getFoodName());
            ps.setInt(2, food.getCalories());
            ps.setDouble(3, food.getProtein());
            ps.setDouble(4, food.getCarbs());
            ps.setDouble(5, food.getFat());
            ps.setString(6, food.getServingSize());
            ps.setString(7, food.getDescription());
            return ps.executeUpdate() > 0;
        }
    }
    
    public boolean updateCustomFood(CustomFoodDTO food) throws Exception {
        String sql = "UPDATE Custom_Foods SET food_name = ?, calories = ?, protein_g = ?, carbs_g = ?, fat_g = ?, " +
                     "serving_size = ?, description = ? WHERE food_id = ?";
        try (Connection conn = DBUtils.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, food.getFoodName());
            ps.setInt(2, food.getCalories());
            ps.setDouble(3, food.getProtein());
            ps.setDouble(4, food.getCarbs());
            ps.setDouble(5, food.getFat());
            ps.setString(6, food.getServingSize());
            ps.setString(7, food.getDescription());
            ps.setInt(8, food.getFoodId());
            return ps.executeUpdate() > 0;
        }
    }
    
    public boolean deleteCustomFood(int foodId) throws Exception {
        String sql = "DELETE FROM Custom_Foods WHERE food_id = ?";
        try (Connection conn = DBUtils.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, foodId);
            return ps.executeUpdate() > 0;
        }
    }
}

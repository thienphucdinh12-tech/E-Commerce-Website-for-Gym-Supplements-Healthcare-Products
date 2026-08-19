package shopping;

import java.io.Serializable;
import java.sql.Timestamp;

public class CustomFoodDTO implements Serializable {
    private int foodId;
    private String foodName;
    private int calories;
    private double protein;
    private double carbs;
    private double fat;
    private String servingSize;
    private String description;
    private Timestamp createdAt;

    public CustomFoodDTO() {
    }

    public CustomFoodDTO(int foodId, String foodName, int calories, double protein, double carbs, double fat, String servingSize, String description, Timestamp createdAt) {
        this.foodId = foodId;
        this.foodName = foodName;
        this.calories = calories;
        this.protein = protein;
        this.carbs = carbs;
        this.fat = fat;
        this.servingSize = servingSize;
        this.description = description;
        this.createdAt = createdAt;
    }

    public int getFoodId() { return foodId; }
    public void setFoodId(int foodId) { this.foodId = foodId; }

    public String getFoodName() { return foodName; }
    public void setFoodName(String foodName) { this.foodName = foodName; }

    public int getCalories() { return calories; }
    public void setCalories(int calories) { this.calories = calories; }

    public double getProtein() { return protein; }
    public void setProtein(double protein) { this.protein = protein; }

    public double getCarbs() { return carbs; }
    public void setCarbs(double carbs) { this.carbs = carbs; }

    public double getFat() { return fat; }
    public void setFat(double fat) { this.fat = fat; }

    public String getServingSize() { return servingSize; }
    public void setServingSize(String servingSize) { this.servingSize = servingSize; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }
}

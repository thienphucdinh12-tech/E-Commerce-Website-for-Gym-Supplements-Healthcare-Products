package user;

import java.util.Date;

public class UserDTO {
    private String userID;      // Maps to 'username' in DB
    private String fullName;    // Maps to 'full_name' in DB
    private String roleID;      // Can be either 'AD' or 'US'
    private String password;
    private boolean active = true; // Maps to 'is_active' in Account


    // ── Profile fields ──────────────────────────────────────
    private Date   dateOfBirth; // Maps to 'date_of_birth' in DB
    private String gender;      // 'Male', 'Female', 'Other'
    private String address;     // Delivery address
    private Double heightCm;    // Height in centimetres
    private Double weightKg;    // Weight in kilograms
    private String healthGoal;  // 'muscle_gain', 'weight_loss', 'immunity', 'cardio', 'general'

    public UserDTO() {}

    public UserDTO(String userID, String fullName, String roleID, String password) {
        this.userID   = userID;
        this.fullName = fullName;
        this.roleID   = roleID;
        this.password = password;
    }

    // ── Core getters / setters ───────────────────────────────
    public String getUserID()   { return userID; }
    public void   setUserID(String userID)     { this.userID = userID; }

    public String getFullName() { return fullName; }
    public void   setFullName(String fullName) { this.fullName = fullName; }

    public String getRoleID()   { return roleID; }
    public void   setRoleID(String roleID)     { this.roleID = roleID; }

    public String getPassword() { return password; }
    public void   setPassword(String password) { this.password = password; }

    // ── Profile getters / setters ────────────────────────────
    public Date   getDateOfBirth() { return dateOfBirth; }
    public void   setDateOfBirth(Date dateOfBirth) { this.dateOfBirth = dateOfBirth; }

    public String getGender()  { return gender; }
    public void   setGender(String gender)  { this.gender = gender; }

    public String getAddress() { return address; }
    public void   setAddress(String address) { this.address = address; }

    public Double getHeightCm() { return heightCm; }
    public void   setHeightCm(Double heightCm) { this.heightCm = heightCm; }

    public Double getWeightKg() { return weightKg; }
    public void   setWeightKg(Double weightKg) { this.weightKg = weightKg; }

    public String getHealthGoal() { return healthGoal; }
    public void   setHealthGoal(String healthGoal) { this.healthGoal = healthGoal; }

    // ── Computed: BMI ────────────────────────────────────────
    /**
     * Returns BMI (kg/m²) rounded to 1 decimal, or null if height/weight unavailable.
     */
    public Double getBmi() {
        if (heightCm == null || weightKg == null || heightCm <= 0) return null;
        double heightM = heightCm / 100.0;
        double bmi = weightKg / (heightM * heightM);
        return Math.round(bmi * 10.0) / 10.0;
    }

    /**
     * Returns WHO BMI category label.
     */
    public String getBmiCategory() {
        Double bmi = getBmi();
        if (bmi == null) return null;
        if (bmi < 18.5) return "Thiếu cân";
        if (bmi < 25.0) return "Bình thường";
        if (bmi < 30.0) return "Thừa cân";
        return "Béo phì";
    }

    /**
     * Returns the BMI progress percentage (0 - 100) mapped from BMI range (10 - 40).
     */
    public double getBmiPercent() {
        Double bmi = getBmi();
        if (bmi == null) return 0.0;
        double pct = ((bmi - 10.0) / 30.0) * 100.0;
        if (pct < 0) pct = 0;
        if (pct > 100) pct = 100;
        return Math.round(pct * 10.0) / 10.0;
    }

    public boolean isActive() { return active; }
    public void setActive(boolean active) { this.active = active; }
}
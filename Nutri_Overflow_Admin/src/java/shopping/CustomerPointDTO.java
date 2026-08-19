package shopping;

public class CustomerPointDTO {
    private int userId;
    private String username;
    private String fullName;
    private String phone;
    private int points;

    public CustomerPointDTO() {}

    public CustomerPointDTO(int userId, String username, String fullName, String phone, int points) {
        this.userId = userId;
        this.username = username;
        this.fullName = fullName;
        this.phone = phone;
        this.points = points;
    }

    public int getUserId() { return userId; }
    public void setUserId(int userId) { this.userId = userId; }

    public String getUsername() { return username; }
    public void setUsername(String username) { this.username = username; }

    public String getFullName() { return fullName; }
    public void setFullName(String fullName) { this.fullName = fullName; }

    public String getPhone() { return phone; }
    public void setPhone(String phone) { this.phone = phone; }

    public int getPoints() { return points; }
    public void setPoints(int points) { this.points = points; }
}

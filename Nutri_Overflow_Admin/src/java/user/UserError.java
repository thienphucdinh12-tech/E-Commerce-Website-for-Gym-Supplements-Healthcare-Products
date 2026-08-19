package user;

public class UserError {
    private String userID, fullName, roleID, password, confirm, error;

    public UserError() {}

    public String getUserID() { return userID; }
    public void setUserID(String userID) { this.userID = userID; }
    public String getFullName() { return fullName; }
    public void setFullName(String fullName) { this.fullName = fullName; }
    public String getRoleID() { return roleID; }
    public void setRoleID(String roleID) { this.roleID = roleID; }
    public String getPassword() { return password; }
    public void setPassword(String password) { this.password = password; }
    public String getConfirm() { return confirm; }
    public void setConfirm(String confirm) { this.confirm = confirm; }
    public String getError() { return error; }
    public void setError(String error) { this.error = error; }
}
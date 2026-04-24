
public class UserSession {
    private int customerId;
    private String firstName;
    private String lastName;
    private boolean isLoggedIn = false;

    public void login(int id, String firstName, String lastName) {
        this.customerId = id;
        this.firstName = firstName;
        this.lastName = lastName;
        this.isLoggedIn = true;
    }
    public void logOut() {
        this.isLoggedIn = false;
    }
    public int getCustomerId() {
        return customerId;
    }
    public boolean isLoggedIn() {
        return isLoggedIn;
    }
    public String getName() {
        return firstName+" "+lastName;
    }
}
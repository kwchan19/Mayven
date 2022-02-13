package app.mayven.mayven;

public class groupMembers {
    public boolean isAdmin;
    public String name;
    public String userName;

    public groupMembers(boolean isAdmin, String name, String userName) {
        this.isAdmin = isAdmin;
        this.name = name;
        this.userName = userName;
    }

    public boolean isAdmin() {
        return isAdmin;
    }

    public String getName() {
        return name;
    }

    public String getUserName() {
        return userName;
    }

    public void setAdmin(boolean admin) {
        isAdmin = admin;
    }

    public void setName(String name) {
        this.name = name;
    }

    public void setUserName(String userName) {
        this.userName = userName;
    }

}

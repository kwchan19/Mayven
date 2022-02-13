package app.mayven.mayven;

public class ChatNotifications {
    public String gName;
    public String parentUser;
    public Long timestamp;
    public Long unseenMessage;
    public String lastMessage;
    public String lastUser;

    public ChatNotifications() {
        // Constructor required for Firebase Database

    }

    public ChatNotifications(String gName, String parentUser, Long timestamp, Long unseenMessage, String lastMessage, String lastUser) {
        // Constructor required for Firebase Database
        this.gName = gName;
        this.parentUser = parentUser;
        this.timestamp = timestamp;
        this.unseenMessage = unseenMessage;
        this.lastMessage = lastMessage;
        this.lastUser = lastUser;
    }

    public String getName() {
        return gName;
    }

    public String getParentUser() {
        return parentUser;
    }

    public Long getTimestamp() {
        return timestamp;
    }

    public Long getUnseenMessage() {
        return unseenMessage;
    }

    public String getLastUser() {
        return lastUser;
    }

    public String getLastMessage() {
        return lastMessage;
    }

    public void setgName(String gName) {
        this.gName = gName;
    }

    public void setParentUser(String parentUser) {
        this.parentUser = parentUser;
    }

    public void setTimestamp(Long timestamp) {
        this.timestamp = timestamp;
    }

    public void setUnseenMessage(Long unseenMessage) {
        this.unseenMessage = unseenMessage;
    }

    public void setLastMessage(String lastMessage) {
        this.lastMessage = lastMessage;
    }

    public void setLastUser(String lastUser) {
        this.lastUser = lastUser;
    }
}
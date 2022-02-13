package app.mayven.mayven;

import java.util.ArrayList;

public class Group {
    public ArrayList<String> admins;
    public ArrayList<String> members;
    public String name;
    public String ownerId;
    public int notifications;
    public String lastMessage;
    public String docId;
    public String lastUser;
    public int timestamp;

    public Group() {
        // Constructor required for Firebase Database


    }

    public Group(ArrayList<String> admins, ArrayList<String> members, String name, String ownerId, int notifications, String docId, String lastMessage, String lastUser, int timestamp) {
        // Constructor required for Firebase Database
        this.admins = admins;
        this.members = members;
        this.name = name;
        this.ownerId = ownerId;
        this.notifications = notifications;
        this.docId = docId;
        this.lastMessage = lastMessage;
        this.lastUser = lastUser;
        this.timestamp = timestamp;
    }

    public int getTimestamp() {
        return timestamp;
    }

    public String getName() {
        return name;
    }

    public String getOwnerId() {
        return ownerId;
    }

    public ArrayList<String> getAdmins() {
        return admins;
    }

    public ArrayList<String> getMembers() {

        return members;
    }
    public String getDocId() {
        return docId;
    }

    public String getLastMessage() {
        return lastMessage;
    }

    public String getLastUser() {
        return lastUser;
    }

    public int getNotifications() {
        return notifications;
    }

    public void setNotifications(int i) {
        notifications = i;
    }

    public void setDocId(String id) {
        docId = id;
    }

    public void setLastMessage(String lastMsg) {
        lastMessage = lastMsg;
    }

    public void setLastUser(String lastUser) {
        this.lastUser = lastUser;
    }

    public void setTimestamp(int timestamp) {
        this.timestamp = timestamp;
    }
}
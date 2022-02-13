package app.mayven.mayven;

public class Chat {
    public String liveMessage;
    public String ownerId;
    public String ownerName;
    public Long timePosted;
    public String docId;

    public Chat() {
        // Constructor required for Firebase Database
    }

    public Chat(String message, String id, String name, Long time, String docId) {
        // Constructor required for Firebase Database
        this.liveMessage = message;
        this.ownerId = id;
        this.ownerName = name;
        this.timePosted = time;
        this.docId = docId;
    }

    public String getDocId() {
        return docId;
    }

    public String getLiveMessage() {
        return liveMessage;
    }

    public String getOwnerName() {
        return ownerName;
    }

    public Long getTimestamp() {
        return timePosted;
    }

    public String getOwnerId() {
        return ownerId;
    }
}
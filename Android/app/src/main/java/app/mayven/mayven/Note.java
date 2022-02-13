package app.mayven.mayven;

import com.google.firebase.firestore.DocumentSnapshot;

import java.util.List;
import java.util.concurrent.TimeUnit;

public class Note {
    public int timestamp;
    public List<String> replies;
    public String ownerName;
    public String ownerId;
    public String text;
    public String imageURL;
    public List<String> usersLiked;
    public int likes;
    public String originalPost;
    public int replyCount;
    public String documentId;
    public List<String> reports;
    public DocumentSnapshot documentSnapshot;

    public Note() {
    }

    public Note(int timestamp, String ownerId, String text, String ownerName, String imageURL, List<String> replies, List<String>
            usersLiked, int likes, int replyCount, String documentId, String originalPost, List<String> reports/*DocumentSnapshot documentSnapshot*/) {
        this.timestamp = timestamp;
        this.ownerId = ownerId;
        this.text = text;
        this.ownerName = ownerName;
        this.imageURL = imageURL;
        this.replies = replies;
        this.usersLiked = usersLiked;
        this.likes = likes;
        this.replyCount = replyCount;
        this.documentId = documentId;
        this.originalPost = originalPost;
        this.reports = reports;
        this.documentSnapshot = documentSnapshot;
    }

    public String getTime() {
        String timeStamp = String.valueOf(TimeUnit.MILLISECONDS.toSeconds(System.currentTimeMillis()));
        final int dateNow = Integer.parseInt(timeStamp);
        final int time = timestamp;
        String sign ;
        int sum = (dateNow - time) / 60;

        if(sum == 0) {
            sum = (dateNow-time);
            sign = "s";
        }
        else if(sum < 60){
            sign = "m";
        }
        else if(sum >= 60 && sum < 1440) {
            sum = sum / 60;
            sign = "h";
        }
        else if(sum >= 1440 && sum < 525600) {
            sum = sum / 1440;
            sign = "d";
        }
        else {
            sign = "y";
        }

        String finalTime = sum + sign;
        return finalTime;
    }

    public DocumentSnapshot getDocumentSnapshot() {
        return documentSnapshot;
    }

    public int getTime2() {
        return timestamp;
    }

    public String getOwnerName() {
        return ownerName;
    }

    public String getId() {
        return ownerId;
    }

    public String getPost() {
        return text;
    }

    public List<String> getreplies() {
        return replies;
    }

    public String getImageURL() {
        return imageURL;
    }

    public List<String> getUsersLiked() {
        return usersLiked;
    }

    public int getLikes() {
        return likes;
    }

    public int getReplyCount() {
        return replyCount;
    }

    public String getDocumentId() {
        return documentId;
    }

    public List<String> getReports() {
        return reports;
    }

    public String getOriginalPost(){return originalPost;}
}




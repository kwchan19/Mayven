package app.mayven.mayven;

import android.content.Context;

import com.google.firebase.firestore.DocumentSnapshot;

import java.util.ArrayList;
import java.util.List;

public class ChatGroupArray {
    // public static List<Map<String, Object>> notificationArr = new ArrayList<Map<String, Object>>();
    public static ArrayList<Note> notificationArr = new ArrayList<Note>();
    public static List<Long> chatNotifications = new ArrayList<Long>();
    public static ArrayList<ChatNotifications> groupArr = new ArrayList<ChatNotifications>();
    public static ArrayList<Group> GroupSave = new ArrayList<Group>();
    public static Context context;
    public static ArrayList<String> groupId = new ArrayList<String>();
    public static ArrayList<String> groupName = new ArrayList<String>();
    public static ArrayList<groupMembers> members = new ArrayList<groupMembers>();
    public static List<Object> mRecyclerViewItems = new ArrayList<Object>();
    public static DocumentSnapshot lastResult = null;
    public static boolean refreshChat = true;
    public static boolean isTransaction = false;
    public static Boolean KICK = false;
    public static ArrayList<String> cloudNotifications = new ArrayList<String>();
    public static ArrayList<String> BlockedUsers = new ArrayList<String>();
    public static int lastTimestamp = 0;
    public static String currentProgram = "All";
    public static String currentType = "timestamp";
    public static Boolean notificationStartup = true;
    public static int imageTime;
    // Getters

    public static List<Object> getmRecyclerViewItems() {
        return mRecyclerViewItems;
    }

    public ArrayList<Note> getNotificationArr() {
        return notificationArr;
    }

    public List<Long> getChatNotifications() {
        return chatNotifications;
    }

    public ArrayList<ChatNotifications> getGroupArr(){
        return groupArr;
    }

    public ArrayList<Group> getGroupSave() {
        return GroupSave;
    }

    public Context getContextArr() {
        return context;
    }

    public ArrayList<String> getGroupId() {
        return groupId;
    }

    public ArrayList<String> getGroupName() {
        return groupName;
    }

    public static ArrayList<groupMembers> getMembers() {
        return members;
    }

    public static Boolean getKICK() {
        return KICK;
    }

    public static ArrayList<String> getBlockedUsers() {
        return BlockedUsers;
    }

    // Setters


    public static void setKICK(Boolean KICK) {
        ChatGroupArray.KICK = KICK;
    }

    public void setGroupArr(ChatNotifications arr) {
        this.groupArr.add(arr);
    }

    public void setNotificationArr(Note notificationArr) {
        this.notificationArr.add(0, notificationArr);
    }

    public void setChatNotifications(Long chatNotif) {
        this.chatNotifications.add(chatNotif);
    }

    public void setGroupSave(Group groupSave) {
        this.GroupSave.add(0, groupSave);
    }

    public void setContextArr(Context context) {
        this.context = context;
    }

    public void setGroupId(String groupId) {
        this.groupId.add(groupId);
    }

    public void setGroupName(String groupName) {
        this.groupName.add(groupName);
    }

    public static void setMembers(ArrayList<groupMembers> members) { ChatGroupArray.members = members; }

    public static void addRecyclerItems(Object mRecyclerViewItems) {
        ChatGroupArray.mRecyclerViewItems.add(mRecyclerViewItems);
    }

    public static void setBlockedUsers(ArrayList<String> blockedUsers) {
        BlockedUsers = blockedUsers;
    }
}

package app.mayven.mayven;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.appcompat.app.AppCompatActivity;
import androidx.fragment.app.Fragment;
import androidx.fragment.app.FragmentManager;
import androidx.fragment.app.FragmentTransaction;

import android.app.ProgressDialog;
import android.content.Intent;
import android.graphics.Color;
import android.os.Bundle;
import android.text.SpannableString;
import android.text.style.ForegroundColorSpan;
import android.util.Log;
import android.view.Menu;
import android.view.MenuInflater;
import android.view.MenuItem;
import android.view.View;
import android.widget.ArrayAdapter;
import android.widget.Toast;

import app.mayven.mayven.R;
import com.google.android.gms.ads.AdListener;
import com.google.android.gms.ads.AdLoader;
import com.google.android.gms.ads.AdRequest;
import com.google.android.gms.ads.MobileAds;
import com.google.android.gms.ads.formats.UnifiedNativeAd;
import com.google.android.gms.tasks.OnCompleteListener;
import com.google.android.gms.tasks.OnSuccessListener;
import com.google.android.gms.tasks.Task;
import com.google.android.material.bottomnavigation.BottomNavigationView;
import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.database.ChildEventListener;
import com.google.firebase.database.DataSnapshot;
import com.google.firebase.database.DatabaseError;
import com.google.firebase.database.DatabaseReference;
import com.google.firebase.database.FirebaseDatabase;
import com.google.firebase.firestore.CollectionReference;
import com.google.firebase.firestore.DocumentChange;
import com.google.firebase.firestore.DocumentReference;
import com.google.firebase.firestore.DocumentSnapshot;
import com.google.firebase.firestore.EventListener;
import com.google.firebase.firestore.FirebaseFirestore;
import com.google.firebase.firestore.FirebaseFirestoreException;
import com.google.firebase.firestore.FirebaseFirestoreSettings;
import com.google.firebase.firestore.ListenerRegistration;
import com.google.firebase.firestore.Query;
import com.google.firebase.firestore.QueryDocumentSnapshot;
import com.google.firebase.firestore.QuerySnapshot;
import com.google.firebase.messaging.FirebaseMessaging;

import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.concurrent.TimeUnit;

public class MainActivity extends AppCompatActivity {
    private static int ADS_SIZE = 0;

    //FirebaseUser mAuth = FirebaseAuth.getInstance().getCurrentUser();
    private FirebaseFirestore db = FirebaseFirestore.getInstance();
    private CollectionReference postRef = db.collection("Posts");
    private CollectionReference userRef = db.collection("Users");
    private CollectionReference groupRef = db.collection("ChatGroups");
    private CollectionReference disabledRef = db.collection("Disabled");
    public BottomNavigationView bottomNavigationView;
    private com.google.firebase.database.Query data;
    private List<Object> mRecyclerViewItemsReplies = new ArrayList<>();
    private String currentUsername;

    //Listeners;
    public static ListenerRegistration notificationListen;
    public static ListenerRegistration disabledListener;
    public static com.google.firebase.database.Query chatListen;
    public static ChildEventListener childEventListener;
    //---------

    public static ProgressDialog mProgressDialog;

    ArrayAdapter mArrayAdapter;

    public static final int NUMBER_OF_ADS = 5;
    // The AdLoader used to load ads.
    private AdLoader adLoader;
    // List of native ads that have been successfully loaded.
    private List<UnifiedNativeAd> mNativeAds = new ArrayList<>();

    final Fragment fragment1 = new HomeFragment();
    final Fragment fragment2 = new chatFragment();
    final Fragment fragment3 = new NotificationFragment();
    final Fragment fragment4 = new AccountFragment();
    final FragmentManager fm = getSupportFragmentManager();
    Fragment active = fragment1;



    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);
        MobileAds.initialize(this, "ca-app-pub-3819604632178532~1809267273"); // fake ads

        ChatGroupArray chatGroupArray = new ChatGroupArray();
        chatGroupArray.getBlockedUsers().clear();
        if (chatListen != null) {
            chatGroupArray.lastTimestamp = 0;
            chatGroupArray.notificationStartup = true;
            chatListen.removeEventListener(childEventListener);
        }

        if (notificationListen != null) {
            notificationListen.remove();
        }

        if (disabledListener != null) {
            disabledListener.remove();
        }

        FirebaseMessaging.getInstance().getToken()
                .addOnCompleteListener(new OnCompleteListener<String>() {
                    @Override
                    public void onComplete(@NonNull Task<String> task) {
                        if (!task.isSuccessful()) {

                            return;
                        }

                        // Get new FCM registration token
                        String token = task.getResult();

                    }
                });


        FirebaseFirestoreSettings settings = new FirebaseFirestoreSettings.Builder()
                .setPersistenceEnabled(true)
                .build();

        db.setFirestoreSettings(settings);
        Intent intent = new Intent("finish_activity");
        sendBroadcast(intent);

        fm.beginTransaction().add(R.id.container, fragment4, "4").hide(fragment4).commit();
        fm.beginTransaction().add(R.id.container, fragment3, "3").hide(fragment3).commit();
        fm.beginTransaction().add(R.id.container, fragment2, "2").hide(fragment2).commit();
        fm.beginTransaction().add(R.id.container, fragment1, "1").commit();

        bottomNavigationView = findViewById(R.id.bottomNav);
        bottomNavigationView.setOnNavigationItemSelectedListener(mOnNavigationItemSelectedListener);

        RegisterUsername reg = new RegisterUsername();
        List<userDB> qwe = reg.readData();
        final String signedInUser = qwe.get(0).username;
        currentUsername = qwe.get(0).username;

        setBlackScreen();
        checkDisabled();

        if(chatGroupArray.lastTimestamp == 0 || chatGroupArray.getBlockedUsers().isEmpty()) {
            getUserLastTimestamp(signedInUser);
        }
        else {
            returnFirstDocs();
            addItemsFromFirebase("timestamp", "All");
        }

        notificationListener();
        chatNotifs();
    }


    public void setBlackScreen() {
        mProgressDialog = new ProgressDialog(MainActivity.this);
        mProgressDialog.setCancelable(false);
        mProgressDialog.show();
        mProgressDialog.setContentView(R.layout.custom_progressbar);
        mProgressDialog.getWindow().setBackgroundDrawableResource(
                android.R.color.transparent
        );
    }

    private void insertRTD() {
        DatabaseReference finalMessage = FirebaseDatabase.getInstance().getReference().child("Notifications").push();
        ;
        Map<String, Object> messageDetails2 = new HashMap<String, Object>();
        messageDetails2.put("gName", "groupId");
        messageDetails2.put("parentUser", "mhassan43");
        messageDetails2.put("timestamp", 1617202058);
        messageDetails2.put("unseenMessage", 0);
        finalMessage.updateChildren(messageDetails2);
    }

    private BottomNavigationView.OnNavigationItemSelectedListener mOnNavigationItemSelectedListener
            = new BottomNavigationView.OnNavigationItemSelectedListener() {

        @Override
        public boolean onNavigationItemSelected(@NonNull MenuItem item) {
            switch (item.getItemId()) {
                case R.id.home:
                    fm.beginTransaction().hide(active).show(fragment1).commit();
                    active = fragment1;
                    return true;

                case R.id.chat:
                    fm.beginTransaction().hide(active).show(fragment2).commit();
                    active = fragment2;
                    return true;

                case R.id.notification:

                    // SET TO ZERO!
                    removeNotificationBadge();
                    ChatGroupArray chatGroupArray = new ChatGroupArray();
                    if(chatGroupArray.getNotificationArr().size() == 0){
                        NotificationFragment.isEmpty.setVisibility(View.VISIBLE);
                    }
                    fm.beginTransaction().hide(active).show(fragment3).commit();
                    active = fragment3;

                    return true;
                case R.id.account:
                    fm.beginTransaction().hide(active).show(fragment4).commit();
                    active = fragment4;
                    return true;
            }
            return false;
        }
    };

    //TODO: PRESSING BACK BUTTON DOESNT LIGHT UP BOTTOM FRAGMENT

    public void loadFragment(Fragment fragment, String tag) {
        FragmentManager manager = getSupportFragmentManager();
        FragmentTransaction transaction = manager.beginTransaction();
        transaction.replace(R.id.container, fragment);
        transaction.addToBackStack(tag);
        transaction.commit();
    }


    public void removeBadges() {
        int menuItemId = bottomNavigationView.getMenu().getItem(1).getItemId();
        bottomNavigationView.removeBadge(menuItemId);
    }

    public void setBadges() {
        int menuItemId = bottomNavigationView.getMenu().getItem(1).getItemId();
        bottomNavigationView.getOrCreateBadge(menuItemId);
    }

    public void setNotificationBadge() {
        int menuItemId = bottomNavigationView.getMenu().getItem(2).getItemId();
        bottomNavigationView.getOrCreateBadge(menuItemId);
    }

    public void removeNotificationBadge() {
        int menuItemId = bottomNavigationView.getMenu().getItem(2).getItemId();
        bottomNavigationView.removeBadge(menuItemId);
    }

    public void hideNav() {
        bottomNavigationView.setVisibility(View.GONE);
    }

    public void unhideNav() {
        bottomNavigationView.setVisibility(View.VISIBLE);
    }

    public void getUserLastTimestamp(final String user) {
        CollectionReference userRef = db.collection("Users");
        DocumentReference m = userRef.document(user);

        m.get().addOnCompleteListener(new OnCompleteListener<DocumentSnapshot>() {
            @Override
            public void onComplete(@NonNull Task<DocumentSnapshot> task) {
                DocumentSnapshot document = task.getResult();
                Long lastTimestamp = (Long) document.get("lastTimestamp");
                String time =  String.valueOf(lastTimestamp);
                int intTime = Integer.valueOf(time);

                ChatGroupArray chatGroupArray = new ChatGroupArray();
                chatGroupArray.setBlockedUsers((ArrayList<String>) document.get("blockedUsers"));
                chatGroupArray.lastTimestamp = intTime;



                String timeStamp = String.valueOf(TimeUnit.MILLISECONDS.toSeconds(System.currentTimeMillis()));
                final int currTime = Integer.parseInt(timeStamp);
                chatGroupArray.imageTime = currTime;

                returnFirstDocs();
                addItemsFromFirebase("timestamp", "All");

                setNotification(chatGroupArray.getNotificationArr().size(), user);
            }
        });
    }

    private void notificationListener() {
        final ChatGroupArray chatGroupArray = new ChatGroupArray();
        RegisterUsername reg = new RegisterUsername();
        List<userDB> qwe = reg.readData();
        final String signedInUser = qwe.get(0).name;
        final String signedInUsername = qwe.get(0).username;
        final String timeStamp = String.valueOf(TimeUnit.MILLISECONDS.toSeconds(System.currentTimeMillis()));
        final int dateNow = Integer.parseInt(timeStamp);

        notificationListen = postRef.whereArrayContains("replies", signedInUsername)
                .whereEqualTo("lastAction", "reply")
                .whereGreaterThanOrEqualTo("lastActionTime", dateNow)
                .addSnapshotListener(new EventListener<QuerySnapshot>() {
                    @Override
                    public void onEvent(@Nullable QuerySnapshot value, @Nullable FirebaseFirestoreException error) {

                        if (error != null) {
                            return;
                        }
                        for (final DocumentChange dc : value.getDocumentChanges()) {
                            if (dc.getType() == DocumentChange.Type.ADDED || dc.getType() == DocumentChange.Type.MODIFIED) {
                                String DID = dc.getDocument().getId();
                                postRef
                                        .document(DID)
                                        .collection("Replies")
                                        .orderBy("timestamp", Query.Direction.DESCENDING)
                                        .limit(1)
                                        .get().addOnCompleteListener(new OnCompleteListener<QuerySnapshot>() {
                                    @Override
                                    public void onComplete(@NonNull Task<QuerySnapshot> task) {
                                        if (task.isSuccessful()) {
                                            for (final QueryDocumentSnapshot dc : task.getResult()) {
                                                if (!dc.getString("ownerId").equals(signedInUsername)) {
                                                    //   notificationArr.add(dc.getData());

                                                    int timestamp = Integer.parseInt(dc.get("timestamp").toString());
                                                    String ownerId = dc.getString("ownerId");

                                                    String text = dc.getString("text");
                                                    String ownerName = dc.getString("ownerName");
                                                    String imageURL = dc.getString("imageURL");
                                                    List<String> replies = (List<String>) dc.get("replies");
                                                    List<String> usersLiked = (List<String>) dc.get("usersLiked");
                                                    int likes = 0; //Integer.parseInt(dc.get("likes").toString());
                                                    int replyCount = 0; //Integer.parseInt(dc.get("replyCount").toString());
                                                    String documentId = dc.getId();
                                                    String originalPost = dc.getString("originalPost");
                                                    List<String> reports = (List<String>) dc.get("reports");

                                                    Note note = new Note(timestamp, ownerId, text, ownerName, imageURL, replies, usersLiked, likes, replyCount, documentId, originalPost, reports);
                                                    chatGroupArray.setNotificationArr(note);
                                                    setNotificationBadge();
                                                }
                                            }
                                        }
                                    }
                                });
                            }
                        }
                    }
                });
    }

    private void returnFirstDocs() {

        final ChatGroupArray chatGroupArr = new ChatGroupArray();
        RegisterUsername reg = new RegisterUsername();
        List<userDB> qwe = reg.readData();
        final String signedInUsername = qwe.get(0).username;
        postRef
                .whereArrayContains("replies", signedInUsername)
                .get().addOnCompleteListener(new OnCompleteListener<QuerySnapshot>() {
            @Override
            public void onComplete(@NonNull Task<QuerySnapshot> task) {
                for (final QueryDocumentSnapshot dc : task.getResult()) {

                    final String postOwner = dc.getString("ownerId");
                    final String DID = dc.getId();
                    FirebaseMessaging.getInstance().subscribeToTopic(DID) // PUT THIS INSIDE THE FOR LOOP OF THE RETURN FIRST DOCS && INIT NOTIFICATIONS
                            .addOnCompleteListener(new OnCompleteListener<Void>() {
                                @Override
                                public void onComplete(@NonNull Task<Void> task) {
                                    if (!task.isSuccessful()) {
                                    } else {
                                        chatGroupArr.cloudNotifications.add(DID);
                                    }
                                }
                            });
                    postRef
                            .document(DID)
                            .collection("Replies")
                            .orderBy("timestamp", Query.Direction.ASCENDING)
                            .whereGreaterThanOrEqualTo("timestamp", chatGroupArr.lastTimestamp)
                            .get().addOnCompleteListener(new OnCompleteListener<QuerySnapshot>() {
                        @Override
                        public void onComplete(@NonNull Task<QuerySnapshot> task) {
                            if (task.isSuccessful()) {
                                int time = 0;
                                boolean notifFlag = false;
                                for (QueryDocumentSnapshot document : task.getResult()) {
                                    int timestamp = Integer.parseInt(document.get("timestamp").toString());
                                    String ownerId = document.getString("ownerId");
                                    String text = document.getString("text");
                                    String ownerName = document.getString("ownerName");
                                    String documentId = document.getId();
                                    String originalPost = document.getString("originalPost");
                                    List<String> reports = (List<String>) document.get("reports");

                                    Note note = new Note(timestamp, ownerId, text, ownerName, "", Collections.<String>emptyList(), Collections.<String>emptyList(), 0, 0, documentId, originalPost, reports);

                                    if (postOwner.equals(signedInUsername)) {
                                        // notificationArr.add(document.getData());
                                        if (!document.getString("ownerId").equals(signedInUsername)) {
                                            chatGroupArr.setNotificationArr(note);
                                        }
                                    } else {
                                        if (document.getString("ownerId").equals(signedInUsername) && notifFlag == false) {
                                            time = document.getLong("timestamp").intValue();
                                            notifFlag = true;
                                        }

                                        if (!document.getString("ownerId").equals(signedInUsername) && document.getLong("timestamp").intValue() > time && notifFlag == true) {
                                            //     notificationArr.add(document.getData());
                                            chatGroupArr.setNotificationArr(note);
                                        }
                                    }
                                }
                                Collections.sort(chatGroupArr.getNotificationArr(), new NotificationSort());
                                if(chatGroupArr.getNotificationArr().size() > 0) {
                                    chatGroupArr.notificationStartup = false;
                                    setNotificationBadge();
                                }
                                //getNotification(signedInUsername);
                            }
                            else {
                            }
                        }
                    });
                }
            }
        });
    }

    private void setNotification(int count, String email) {
        FirebaseFirestore db = FirebaseFirestore.getInstance();
        CollectionReference userRef = db.collection("Users");
        DocumentReference m = userRef.document(email);

        final String timeStamp = String.valueOf(TimeUnit.MILLISECONDS.toSeconds(System.currentTimeMillis()));
        final int dateNow = Integer.parseInt(timeStamp);

        m.update(
                "lastNotifications", count,
                "lastTimestamp", dateNow
        );
    }

    public void chatNotifs() {
        com.google.firebase.database.Query groupRef;
        final ChatGroupArray chatGroupArray = new ChatGroupArray();

        RegisterUsername reg = new RegisterUsername();
        List<userDB> qwe = reg.readData();
        final String signedInUser = qwe.get(0).name;
        final String signedInUsername = qwe.get(0).username;

        chatListen = FirebaseDatabase.getInstance().getReference().child("Notifications").orderByChild("parentUser").equalTo(signedInUsername);
        //  groupRef.addChildEventListener(new ChildEventListener() {

        childEventListener = new ChildEventListener() {
            @Override
            public void onChildAdded(DataSnapshot ds, String prevChildKey) {
                final Long msg = (Long) ds.child("unseenMessage").getValue();
                String gName = (String) ds.child("gName").getValue();
                final String lastUser = (String) ds.child("lastUser").getValue();
                final String lastMessage = (String) ds.child("lastMessage").getValue();
                boolean flag = false;
                int index = 0;
                for (Group i : chatGroupArray.getGroupSave()) {
                    if(i.getDocId().equals(gName)) {
                        flag = true;
                        break;
                    }
                    index++;
                }

                if(flag == false) { // New chat group is added
                    if (chatGroupArray.isTransaction != true) {
                        final Long timestamp = (Long) ds.child("timestamp").getValue();
                        final Long unseenMessage = (Long) ds.child("unseenMessage").getValue();

                        CollectionReference groupDB = db.collection("ChatGroups");
                        groupDB.document(gName).get().addOnCompleteListener(new OnCompleteListener<DocumentSnapshot>() {
                            @Override
                            public void onComplete(@NonNull Task<DocumentSnapshot> task) {
                                DocumentSnapshot document = task.getResult();
                                ArrayList<String> admins = (ArrayList<String>) document.get("admins");
                                ArrayList<String> members = (ArrayList<String>) document.get("members");
                                String name = document.getString("name");
                                String ownerId = document.getString("ownerId");
                                final String docId = document.getId();

                                int unseen = Integer.valueOf(unseenMessage.toString());
                                int tempTime = Integer.valueOf(timestamp.toString());

                                Group newGroup = new Group(admins, members, name, ownerId, unseen, docId, lastMessage, lastUser, tempTime);
                                chatGroupArray.setGroupSave(newGroup);

                              /*  FirebaseMessaging.getInstance().subscribeToTopic(docId) // PUT THIS INSIDE THE FOR LOOP OF THE RETURN FIRST DOCS && INIT NOTIFICATIONS
                                        .addOnCompleteListener(new OnCompleteListener<Void>() {
                                            @Override
                                            public void onComplete(@NonNull Task<Void> task) {
                                                if (!task.isSuccessful()) {
                                                } else {
                                                    chatGroupArray.cloudNotifications.add(docId);
                                                }
                                            }
                                        });

                               */

                                Collections.sort(chatGroupArray.getGroupSave(), new CustomComparator());

                                if (msg != 0) {
                                    setBadges();
                                }

                                int menuItemId = bottomNavigationView.getMenu().getItem(1).getItemId();
                                if (bottomNavigationView.getSelectedItemId() == menuItemId) {
                                    chatFragment fragment = new chatFragment();
                                    ArrayAdapter<Group> newAdapter = new groupAdapter(MainActivity.this, chatGroupArray.getGroupSave());
                                    chatFragment.listView.setAdapter(newAdapter);
                                }
                            }
                        });
                    }
                }
                else { // chat group is changed
                    if(!chatGroupArray.getBlockedUsers().contains(lastUser)) {
                        if (msg == 0) {
                            chatGroupArray.getGroupSave().get(index).setNotifications(0);
                        } else {
                            if (lastUser != signedInUsername) {
                                Group temp = chatGroupArray.getGroupSave().get(index);
                                temp.setNotifications(Integer.valueOf(msg.toString()));
                                temp.setLastMessage(lastMessage);

                                chatGroupArray.getGroupSave().remove(index);
                                chatGroupArray.getGroupSave().add(0, temp);

                                if (msg != 0) {
                                    setBadges();
                                }

                                if (msg == 0) {
                                    chatGroupArray.getGroupSave().get(index).setNotifications(0);
                                }
                            }
                        }
                        int menuItemId = bottomNavigationView.getMenu().getItem(1).getItemId();
                        if (bottomNavigationView.getSelectedItemId() == menuItemId) {
                            chatFragment fragment = new chatFragment();
                            ArrayAdapter<Group> newAdapter = new groupAdapter(MainActivity.this, chatGroupArray.getGroupSave());
                            chatFragment.listView.setAdapter(newAdapter);

                        }
                    }else {
                        Log.d("1234","blocked notification added = " + lastUser);
                    }
                }
            }

            @Override
            public void onChildChanged(DataSnapshot ds, String prevChildKey) {
                Long msg = (Long) ds.child("unseenMessage").getValue();
                String gName = (String) ds.child("gName").getValue();
                String lastUser = (String) ds.child("lastUser").getValue();
                String lastMessage = (String) ds.child("lastMessage").getValue();

                int index = 0;
                if(!chatGroupArray.getBlockedUsers().contains(lastUser)) {
                    for (Group i : chatGroupArray.getGroupSave()) {
                        if (i.getDocId().equals(gName)) {
                            if (msg != 0 || lastUser.equals(signedInUsername)) {
                                Group temp = chatGroupArray.getGroupSave().get(index);

                                temp.setNotifications(Integer.valueOf(msg.toString()));
                                temp.setLastMessage(lastMessage);

                                chatGroupArray.getGroupSave().remove(index);
                                chatGroupArray.getGroupSave().add(0, temp);

                                if (msg != 0) {
                                    setBadges();
                                }
                                break;
                            }
                            if (msg == 0) {
                                //   chatGroupArray.getGroupSave().get(index).setLastMessage(lastMessage);
                                chatGroupArray.getGroupSave().get(index).setNotifications(0);
                            }
                        }
                        index++;
                    }

                    int menuItemId = bottomNavigationView.getMenu().getItem(1).getItemId();
                    if (bottomNavigationView.getSelectedItemId() == menuItemId) {
                        chatFragment fragment = new chatFragment();
                        ArrayAdapter<Group> newAdapter = new groupAdapter(MainActivity.this, chatGroupArray.getGroupSave());
                        chatFragment.listView.setAdapter(newAdapter);
                    }
                }else {
                    Log.d("1234","blocked notification changed = " + lastUser);
                }
            }

            @Override
            public void onChildRemoved(DataSnapshot ds) {
                String gName = (String) ds.child("gName").getValue();
                if(chatGroupArray.isTransaction == false ) {
                    int index = 0;
                    for (Group i : chatGroupArray.getGroupSave()) {
                        if (i.getDocId().equals(gName)) { //TODO remove from array and remove Cloud Messaging, On Signout, remove Cloud messaging
                            chatGroupArray.getGroupSave().remove(index);

                            if (chatGroupArray.getKICK()){
                                try {
                                    FragmentManager fragmentManager = getSupportFragmentManager();
                                    fragmentManager.popBackStack(fragmentManager.getBackStackEntryAt(fragmentManager.getBackStackEntryCount() - 2).getId(), FragmentManager.POP_BACK_STACK_INCLUSIVE);
                                }catch (Exception e){
                                    FragmentManager fragmentManager = getSupportFragmentManager();
                                    fragmentManager.popBackStack(fragmentManager.getBackStackEntryAt(fragmentManager.getBackStackEntryCount() - 1).getId(), FragmentManager.POP_BACK_STACK_INCLUSIVE);
                                }
                            }
                            break;
                        }
                        index++;
                    }
                    int menuItemId = bottomNavigationView.getMenu().getItem(1).getItemId();
                    if (bottomNavigationView.getSelectedItemId() == menuItemId) {
                        chatFragment fragment = new chatFragment();
                        ArrayAdapter<Group> newAdapter = new groupAdapter(MainActivity.this, chatGroupArray.getGroupSave());
                        chatFragment.listView.setAdapter(newAdapter);
                    }

                }
            }

            @Override
            public void onChildMoved(DataSnapshot dataSnapshot, String prevChildKey) {

            }


            @Override
            public void onCancelled(DatabaseError databaseError) {
            }
        };

        chatListen.addChildEventListener(childEventListener);
    }

    public List<Object> getRecyclerViewItems() {
        ChatGroupArray chatGroupArray = new ChatGroupArray();
        return chatGroupArray.getmRecyclerViewItems();
    }

    private void insertAdsInMenuItems(String type) {
        if (mNativeAds.size() <= 0) {
            return;
        }

        ChatGroupArray chatGroupArray = new ChatGroupArray();

        if (chatGroupArray.getmRecyclerViewItems().size() >= 5) {
            int indexRow = 5;
            for (UnifiedNativeAd ad : mNativeAds) {
                ADS_SIZE++;
                int counter = 0;
                if(ADS_SIZE == 1) {
                    counter = 0;

                }
                else {
                    counter = ADS_SIZE;
                }

                chatGroupArray.mRecyclerViewItems.add((indexRow * ADS_SIZE) + ADS_SIZE - 1, ad);
            }
        }

        mProgressDialog.dismiss();
        // loadMenu();
        if(type == "new") {
            // loadMenu();
        }
    }

    private void loadMenu() {
        // Create new fragment and transaction
        /*Fragment newFragment = new HomeFragment();
        FragmentTransaction transaction = getSupportFragmentManager().beginTransaction();
        // Replace whatever is in the fragment_container view with this fragment,
        // and add the transaction to the back stack
        transaction.replace(R.id.container, newFragment);
        transaction.addToBackStack("homeFragment");
        // Commit the transaction
        transaction.commit();

         */

        HomeFragment hf = new HomeFragment();
        hf.adapter.notifyDataSetChanged();
        ChatGroupArray chatGroupArray = new ChatGroupArray();


        mProgressDialog.dismiss();

    }

    private void loadNativeAds(final int size, final String type) {
        AdLoader.Builder builder = new AdLoader.Builder(this, "ca-app-pub-3819604632178532/7608388867");
        adLoader = builder.forUnifiedNativeAd(
                new UnifiedNativeAd.OnUnifiedNativeAdLoadedListener() {
                    @Override
                    public void onUnifiedNativeAdLoaded(UnifiedNativeAd unifiedNativeAd) {
                        // A native ad loaded successfully, check if the ad loader has finished loading
                        // and if so, insert the ads into the list.
                        mNativeAds.add(unifiedNativeAd);

                        if(mNativeAds.size() == size) {
                            insertAdsInMenuItems(type);
                        }

                    }
                }).withAdListener(
                new AdListener() {
                    @Override
                    public void onAdFailedToLoad(int errorCode) {
                        // A native ad failed to load, check if the ad loader has finished loading
                        // and if so, insert the ads into the list.
                    }
                }).build();
        // Load the Native ads.
        adLoader.loadAds(new AdRequest.Builder().build(), size);

    }

    public void addItemsFromFirebase(String type, String program) {
        //TODO:get programcode
        final Query query;
        final ChatGroupArray chatGroupArray = new ChatGroupArray();
        RegisterUsername reg = new RegisterUsername();
        List<userDB> qwe = reg.readData();
        final String schoolId = qwe.get(0).school;

        clearItems();
        query = postRef
                .whereEqualTo("schoolId",schoolId)
                .orderBy(type, Query.Direction.DESCENDING)
                .whereEqualTo("programCode",program)
                .limit(10);

        query.get()
                .addOnSuccessListener(new OnSuccessListener<QuerySnapshot>() {
                    @Override
                    public void onSuccess(QuerySnapshot queryDocumentSnapshots) {
                        int count = 0;
                        for (DocumentSnapshot document : queryDocumentSnapshots) {
                            count++;
                            int timestamp = Integer.parseInt(document.get("timestamp").toString());
                            String ownerId = document.getString("ownerId");
                            String text = document.getString("text");
                            String ownerName = document.getString("ownerName");
                            String imageURL = document.getString("imageURL");
                            List<String> replies = (List<String>) document.get("replies");
                            List<String> usersLiked = (List<String>) document.get("usersLiked");
                            int likes = Integer.parseInt(document.get("likes").toString());
                            int replyCount = Integer.parseInt(document.get("replyCount").toString());
                            String documentId = document.getId();
                            String originalPost = "";
                            List<String> reports = (List<String>) document.get("reports");

                            Note note = new Note(timestamp, ownerId, text, ownerName, imageURL, replies, usersLiked, likes, replyCount, documentId, originalPost, reports);
                            try {
                                if (chatGroupArray.getBlockedUsers().contains(ownerId)) {
                                    Log.d("1234", "the owner " + ownerId + " was found in blocked array = " + chatGroupArray.getBlockedUsers());
                                } else {
                                    chatGroupArray.mRecyclerViewItems.add(note);
                                }
                            }catch (Exception e ){
                                chatGroupArray.mRecyclerViewItems.add(note);
                            }

                            if(queryDocumentSnapshots.size() == count) {
                                chatGroupArray.lastResult = document;

                            }

                        }
                        if(chatGroupArray.mRecyclerViewItems.size() == 0){
                            HomeFragment.isEmpty.setVisibility(View.VISIBLE);
                        }else {
                            HomeFragment.isEmpty.setVisibility(View.GONE);
                        }

                        if(count / 5 >= 1 ){
                            mNativeAds.clear();
                            int sizes = queryDocumentSnapshots.size() / 5;
                            loadNativeAds(sizes, "new");
                            loadMenu();
                        }
                        else {

                            loadMenu();

                        }
                    }
                });
    }

    public void loadMoreItems(DocumentSnapshot dc, String type, String program) {
        //TODO:get programcode
        final Query query;
        final ChatGroupArray chatGroupArray = new ChatGroupArray();
        RegisterUsername reg = new RegisterUsername();
        List<userDB> qwe = reg.readData();
        final String schoolId = qwe.get(0).school;
        final int[] docSize = {0};

        query = postRef
                .whereEqualTo("schoolId",schoolId)
                .orderBy(type, Query.Direction.DESCENDING)
                .whereEqualTo("programCode",program)
                .startAfter(dc)
                .limit(10);

        query.get()
                .addOnSuccessListener(new OnSuccessListener<QuerySnapshot>() {
                    @Override
                    public void onSuccess(QuerySnapshot queryDocumentSnapshots) {

                        int count = 0;
                        for (DocumentSnapshot document : queryDocumentSnapshots) {
                            count++;
                            int timestamp = Integer.parseInt(document.get("timestamp").toString());
                            String ownerId = document.getString("ownerId");
                            String text = document.getString("text");
                            String ownerName = document.getString("ownerName");
                            String imageURL = document.getString("imageURL");
                            List<String> replies = (List<String>) document.get("replies");
                            List<String> usersLiked = (List<String>) document.get("usersLiked");
                            int likes = Integer.parseInt(document.get("likes").toString());
                            int replyCount = Integer.parseInt(document.get("replyCount").toString());
                            String documentId = document.getId();
                            String originalPost = "";
                            List<String> reports = (List<String>) document.get("reports");

                            Note note = new Note(timestamp, ownerId, text, ownerName, imageURL, replies, usersLiked, likes, replyCount, documentId, originalPost, reports);

                            try {
                                if (chatGroupArray.getBlockedUsers().contains(ownerId)) {
                                    Log.d("1234", "the owner " + ownerId + " was found in blocked array = " + chatGroupArray.getBlockedUsers());
                                } else {
                                    chatGroupArray.mRecyclerViewItems.add(note);
                                }
                            }catch (Exception e ){
                                Log.d("1234","block list is empty");
                                chatGroupArray.mRecyclerViewItems.add(note);
                            }

                            docSize[0] = queryDocumentSnapshots.size();

                            if(queryDocumentSnapshots.size() == count) {
                                chatGroupArray.lastResult = document;
                            }
                        }

                        if(count / 5 >= 1 ) {
                            mNativeAds.clear();
                            int size = queryDocumentSnapshots.size() / 5;
                            loadNativeAds(size, "more");
                            loadMenu();
                        }
                        else {
                            loadMenu();
                        }
                    }


                });
    }

    public void loadNext() {
        try {


        } catch (Exception e) {
            e.printStackTrace();
        }

    }

    public List<Object> getRecyclerViewItemsReplies() {
        return mRecyclerViewItemsReplies;
    }

    public void clearItems() {
        ChatGroupArray chatGroupArray = new ChatGroupArray();
        chatGroupArray.mRecyclerViewItems.clear();
        mNativeAds.clear();
        ADS_SIZE = 0;
        chatGroupArray.lastResult = null;
    }

    private void checkTOS() {
        RegisterUsername reg = new RegisterUsername();
        List<userDB> qwe = reg.readData();
        final String signedInUsername = qwe.get(0).username;

        userRef.document(signedInUsername).get().addOnCompleteListener(new OnCompleteListener<DocumentSnapshot>() {
            @Override
            public void onComplete(@NonNull Task<DocumentSnapshot> task) {
                DocumentSnapshot document = task.getResult();

                Boolean b = (Boolean) document.get("tos");

                if (!b) {
                    startActivity(new Intent(getApplicationContext(), tos.class));
                    finish();
                }
            }
        });
    }

    private void checkDisabled() {
        RegisterUsername reg = new RegisterUsername();
        List<userDB> qwe = reg.readData();
        final String signedInUsername = qwe.get(0).username;

        String timeDB;
        disabledListener = disabledRef
                .whereEqualTo("user", signedInUsername)
                .whereEqualTo("flag", "true")
                .addSnapshotListener(new EventListener<QuerySnapshot>() {
                    @Override
                    public void onEvent(@Nullable QuerySnapshot value, @Nullable FirebaseFirestoreException error) {
                        if (error != null) {
                            return;
                        }
                        for (final DocumentChange dc : value.getDocumentChanges()) {
                            if (dc.getType() == DocumentChange.Type.MODIFIED || dc.getType() == DocumentChange.Type.ADDED) {
                                if(dc.getDocument().getString("flag").equals("true")) {
                                    Toast.makeText(getApplicationContext(), "Your account has been disabled. Contact us at contact@mayven.app", Toast.LENGTH_SHORT).show();

                                    RegisterUsername reg = new RegisterUsername();
                                    reg.deleteData();

                                    FirebaseAuth.getInstance().signOut();
                                    startActivity(new Intent(getApplicationContext(), init.class));
                                    finish();
                                }
                            }
                        }
                        // TODO delete realm data
                    }
                });
    }
        /*
    @Override
    public void onCreateOptionsMenu(@NonNull Menu menu, @NonNull MenuInflater inflater) {
        inflater.inflate(R.menu.menu_account, menu);
        MenuItem menuItem = menu.getItem(3);
        SpannableString spannable = new SpannableString(menuItem.getTitle().toString());
        spannable.setSpan(new ForegroundColorSpan(Color.RED),0,spannable.length(),0);
        menuItem.setTitle(spannable);
    }

         */

}



class CustomComparator implements Comparator<Group> {
    @Override
    public int compare(Group o1, Group o2) {
        Long t1 = Long.valueOf(o1.getTimestamp());
        Long t2 = Long.valueOf(o2.getTimestamp());
        return t2.compareTo(t1);

    }
}

class NotificationSort implements Comparator<Note> {
    @Override
    public int compare(Note o1, Note o2) {
        Long t1 = Long.valueOf(o1.getTime2());
        Long t2 = Long.valueOf(o2.getTime2());
        return t2.compareTo(t1);
    }
}
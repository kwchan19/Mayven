    package app.mayven.mayven;

    import android.app.Activity;
    import android.content.Context;
    import android.graphics.Typeface;
    import android.os.Bundle;

    import androidx.annotation.NonNull;
    import androidx.appcompat.app.AppCompatActivity;
    import androidx.fragment.app.Fragment;
    import androidx.fragment.app.FragmentManager;
    import androidx.swiperefreshlayout.widget.SwipeRefreshLayout;

    import android.util.Log;
    import android.view.LayoutInflater;
    import android.view.View;
    import android.view.ViewGroup;
    import android.view.inputmethod.InputMethodManager;
    import android.widget.ArrayAdapter;
    import android.widget.EditText;
    import android.widget.ImageView;
    import android.widget.ListView;
    import android.widget.TextView;

    import app.mayven.mayven.R;
    import com.google.android.gms.tasks.Continuation;
    import com.google.android.gms.tasks.OnCompleteListener;
    import com.google.android.gms.tasks.Task;
    import com.google.firebase.database.ChildEventListener;
    import com.google.firebase.database.DataSnapshot;
    import com.google.firebase.database.DatabaseError;
    import com.google.firebase.database.DatabaseReference;
    import com.google.firebase.database.FirebaseDatabase;
    import com.google.firebase.database.MutableData;
    import com.google.firebase.database.Query;
    import com.google.firebase.database.Transaction;
    import com.google.firebase.database.annotations.Nullable;
    import com.google.firebase.firestore.CollectionReference;
    import com.google.firebase.firestore.DocumentSnapshot;
    import com.google.firebase.firestore.FirebaseFirestore;
    import com.google.firebase.functions.FirebaseFunctions;
    import com.google.firebase.functions.HttpsCallableResult;

    import java.util.ArrayList;
    import java.util.Collections;
    import java.util.HashMap;
    import java.util.List;
    import java.util.Map;
    import java.util.Random;
    import java.util.concurrent.TimeUnit;


    public class LiveChatFragment extends Fragment implements SwipeRefreshLayout.OnRefreshListener {

        //FirebaseUser mAuth = FirebaseAuth.getInstance().getCurrentUser();
        private FirebaseFirestore db = FirebaseFirestore.getInstance();
        private CollectionReference chatGroups = db.collection("ChatGroups");

        private ImageView sendMessage;
        private ImageView back;
        private EditText message;
        private ListView listView;
        private FirebaseFunctions mFunctions;
        private Boolean isTrue = false;

        private Boolean startup = true;

        private String gid, gname, name;
        private String temp;
        private String chat_msg, chat_username;
        public DatabaseReference data;
        private Query notificationRef;
        private DatabaseReference unseenMessageRef;
        private DatabaseReference lastMessageRef;
        private ImageView groupMembers;
        private int totalPosts = 30;
        private CollectionReference userRef = db.collection("Users");
        Activity mActivity;
        ArrayAdapter<Chat> saveAdapter;
        ChatGroupArray chatGroupArray = new ChatGroupArray();
        ArrayList<Chat> ChatSave = new ArrayList<Chat>();

        SwipeRefreshLayout mSwipeRefreshLayout;
        RegisterUsername reg = new RegisterUsername();
        List<userDB> qwe = reg.readData();

        final String usr = qwe.get(0).username;
        ChildEventListener childEventListener;
        Query dRef;

        public LiveChatFragment() {
            // Required empty public constructor
        }

        public LiveChatFragment(String s, String s1, String name) {
            this.gid = s;
            this.gname = s1;
            this.name = name;
        }

        @Override
        public void onAttach(Context context) {
            super.onAttach(context);

            if (context instanceof Activity){
                mActivity = (Activity) context;
            }
        }

        @Override
        public void onDetach() {
            super.onDetach();
            mActivity = null;
            dRef.removeEventListener(childEventListener);
            data.removeEventListener(childEventListener);
            final ChatGroupArray chatGroupArray = new ChatGroupArray();
            chatGroupArray.setKICK(false);
        }

        @Override
        public void onCreate(Bundle savedInstanceState) {
            super.onCreate(savedInstanceState);
            listenToChat();
        }



        @Override
        public View onCreateView(LayoutInflater inflater, ViewGroup container,
                                 Bundle savedInstanceState) {

            View v = inflater.inflate(R.layout.fragment_live_chat, container, false);
            listView = (ListView) v.findViewById(R.id.list);
            listView.setTranscriptMode(ListView.TRANSCRIPT_MODE_ALWAYS_SCROLL);
            TextView groupName = (TextView) v.findViewById(R.id.TextViewGroupName);

            groupName.setText(gname);

            back = v.findViewById(R.id.back);

            back.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    FragmentManager fm = getFragmentManager();
                    fm.popBackStack();
                    chatGroupArray.setKICK(false);
                }
            });

            chatGroupArray.setKICK(true);

            saveAdapter = new adapterListLiveChat(mActivity, ChatSave);

            listView.setAdapter(saveAdapter);


            if(chatGroupArray.refreshChat == true) {
                getChatLogs("", 0, 30);
            }
            else {
                getChatLogs("", 0, 1);
            }



            ((MainActivity) getActivity()).hideNav();
            // Inflate the layout for this fragment


            RegisterUsername reg = new RegisterUsername();
            List<userDB> qwe = reg.readData();

            final String signedInUser = qwe.get(0).name;
            final String signedInUsername = qwe.get(0).username;

            sendMessage = v.findViewById(R.id.btn_send);
            message = v.findViewById(R.id.msg_input);

            mSwipeRefreshLayout = v.findViewById(R.id.swipeLayout);
            mSwipeRefreshLayout.setOnRefreshListener(this);


            chatGroupArray.refreshChat = false;

            TextView textView = new TextView(getContext());
            textView.setTypeface(Typeface.DEFAULT_BOLD);
            textView.setText(gname);

            data = FirebaseDatabase.getInstance().getReference().child("ChatLogs").child(gid);
            mFunctions = FirebaseFunctions.getInstance();

            sendMessage.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    if(message.getText().toString() != null && !message.getText().toString().matches("")) {
                        String timeStamp = String.valueOf(TimeUnit.MILLISECONDS.toSeconds(System.currentTimeMillis()));
                        int dateNow = Integer.parseInt(timeStamp);
                        Map<String, Object> map = new HashMap<String, Object>();
                        temp = timeStamp + "-" + getRandomNumberString() + "-" + getRandomNumberString();
                        data.updateChildren(map);

                        DatabaseReference finalMessage = data.child(temp);
                        Map<String, Object> messageDetails = new HashMap<String, Object>();
                        messageDetails.put("message", message.getText().toString());
                        messageDetails.put("ownerId", signedInUsername);
                        messageDetails.put("ownerName", signedInUser);
                        //     messageDetails.put("thumbnailUrl","");
                        messageDetails.put("timePosted", dateNow);
                        finalMessage.updateChildren(messageDetails);
                        incrementUnseen(signedInUsername, message.getText().toString());


                        addMessage(gid);


                        InputMethodManager inputManager = (InputMethodManager) getActivity().getSystemService(Context.INPUT_METHOD_SERVICE);
                        inputManager.hideSoftInputFromWindow(v.getWindowToken(), InputMethodManager.HIDE_NOT_ALWAYS);
                        listView.setTranscriptMode(ListView.TRANSCRIPT_MODE_ALWAYS_SCROLL);
                        message.getText().clear();
                    }
                }
            });

            groupMembers = v.findViewById(R.id.floatbutton);
            groupMembers.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(final View v) {

                    chatGroups
                            .document(gid)
                            .get().addOnCompleteListener(new OnCompleteListener<DocumentSnapshot>() {
                        @Override
                        public void onComplete(@NonNull Task<DocumentSnapshot> task) {
                            DocumentSnapshot dc = task.getResult();
                            List<String> finale = new ArrayList<>();
                            String owner = dc.getString("ownerId");
                            List<String> members = (List<String>) dc.get("members");
                            final List<String> admins = (List<String>) dc.get("admins");

                            Collections.sort(members);
                            Collections.sort(admins);

                            final ArrayList<groupMembers> obj = new ArrayList<groupMembers>();

                            if(owner != "") {
                                obj.add(new groupMembers(true, owner, ""));
                            }


                            if(admins.size() != 0) {
                                for (int t = 0; t < admins.size(); t++) {
                                    if (signedInUsername.equals(admins.get(t))) {
                                        isTrue = true;
                                    }
                                    if (!owner.equals(admins.get(t))) {

                                        obj.add(new groupMembers(true, admins.get(t), ""));
                                    }
                                }
                            }

                            for (int t = 0; t < members.size(); t++) {
                                if(!owner.equals(members.get(t))) {
                                    if (!admins.contains(members.get(t))) {
                                        //finale.add(members.get(t));
                                        obj.add(new groupMembers(false, members.get(t), ""));
                                    } else {
                                    }
                                }
                            }

                            final int[] count = {0};

                            for(final groupMembers gr : obj) {
                                userRef
                                        .document(gr.getName())
                                        .get().addOnCompleteListener(new OnCompleteListener<DocumentSnapshot>() {
                                    @Override
                                    public void onComplete(@NonNull Task<DocumentSnapshot> task) {
                                        DocumentSnapshot document = task.getResult();
                                        if (document.exists()) {
                                            String name = document.getString("name");
                                            gr.setUserName(name);

                                            if (obj.size() - 1 == count[0]) {
                                                AppCompatActivity activity = (AppCompatActivity) v.getContext();
                                                activity.getSupportFragmentManager().beginTransaction().replace(R.id.container, new LiveChatMembersFragment(obj, gid, gname,isTrue)).addToBackStack(null).commit();
                                            }

                                            count[0]++;
                                        } else {
                                        }
                                    }
                                });
                            }


                        }
                    });
                }
            });
            return v;
        }

        private Task<String> addMessage(String docId) {
            // Create the arguments to the callable function.
            Map<String, Object> data = new HashMap<>();
            data.put("docId", docId);
            data.put("title", gname);
            data.put("message", usr + ": " + message.getText().toString());

            return mFunctions
                    .getHttpsCallable("webhookNew")
                    .call(data)
                    .continueWith(new Continuation<HttpsCallableResult, String>() {
                        @Override
                        public String then(@NonNull Task<HttpsCallableResult> task) throws Exception {
                            // This continuation runs on either success or failure, but if the task
                            // has failed then getResult() will throw an Exception which will be
                            // propagated down.
                            String result = (String) task.getResult().getData();
                            return result;
                        }
                    });
        }

        public void listenToChat() {
            RegisterUsername reg = new RegisterUsername();
            List<userDB> qwe = reg.readData();

            final String signedInUsername = qwe.get(0).username;

            data = FirebaseDatabase.getInstance().getReference().child("ChatLogs").child(gid);
            dRef = data.orderByChild("timePosted").limitToLast(5);
            childEventListener = new ChildEventListener() {
                @Override
                public void onChildAdded(DataSnapshot ds, String prevChildKey) {
                    //     Long currTime = (TimeUnit.MILLISECONDS.toSeconds(System.currentTimeMillis())-2);

                    if(startup == false ) {
                        String id = ds.child("ownerId").getValue().toString();
                        if(!chatGroupArray.getBlockedUsers().contains(id)) {
                            chatGroupArray.isTransaction = true;

                            String message = (String) ds.child("message").getValue();
                            String name = ds.child("ownerName").getValue().toString();
                            Long time = (Long) ds.child("timePosted").getValue();
                            String docId = (String) ds.getKey();

                            Chat newChat = new Chat(message, id, name, time, docId);
                            ChatSave.add(newChat);

                            final Query qData;

                            qData = FirebaseDatabase.getInstance().getReference().child("Notifications").orderByChild("parentUser").equalTo(signedInUsername);
                            qData.get().addOnCompleteListener(new OnCompleteListener<DataSnapshot>() {
                                @Override
                                public void onComplete(@NonNull Task<DataSnapshot> task) {
                                    if (!task.isSuccessful()) {
                                    } else {
                                        int position = 0;
                                        for (DataSnapshot i : task.getResult().getChildren()) {
                                            DatabaseReference data = i.getRef().child("unseenMessage");

                                            if (i.child("gName").getValue().toString().equals(chatGroupArray.getGroupSave().get(position).getDocId())) {
                                                data.runTransaction(new Transaction.Handler() {
                                                    @NonNull
                                                    @Override
                                                    public Transaction.Result doTransaction(@NonNull MutableData currentData) {
                                                        currentData.setValue(0);
                                                        Boolean flag = false;
                                                        for (Group i : chatGroupArray.getGroupSave()) {
                                                            if (i.getNotifications() != 0) {
                                                                flag = true;
                                                            }
                                                        }
                                                        if (flag == true) {
                                                            ((MainActivity) getActivity()).setBadges();
                                                        }
                                                        return Transaction.success(currentData);
                                                    }

                                                    @Override
                                                    public void onComplete(@Nullable DatabaseError databaseError, boolean committed, @Nullable DataSnapshot dataSnapshot) {
                                                        chatGroupArray.isTransaction = false;
                                                    }
                                                });


                                                saveAdapter.notifyDataSetChanged();

                                            }
                                            position++;
                                        }
                                    }
                                }
                            });
                        }else {
                            Log.d("1234","blocked message");
                        }
                    }
                }

                @Override
                public void onChildChanged(DataSnapshot dataSnapshot, String prevChildKey) {
                }

                @Override
                public void onChildRemoved(DataSnapshot dataSnapshot) {
                }

                @Override
                public void onChildMoved(DataSnapshot dataSnapshot, String prevChildKey) {
                }

                @Override
                public void onCancelled(DatabaseError databaseError) {
                }
            };

            dRef.addChildEventListener(childEventListener);
        }

        public void getChatLogs(final String id, final int atValue, final int total) {
            Query chatRef;

            if(id.equals("") && atValue == 0) {
                data = FirebaseDatabase.getInstance().getReference().child("ChatLogs").child(gid);
                chatRef = data.orderByChild("timePosted").limitToLast(total);
            }
            else {
                chatRef = data.orderByChild("timePosted").limitToLast(total).endBefore(atValue, id);
            }

            chatRef.get().addOnCompleteListener(new OnCompleteListener<DataSnapshot>() {
                @Override
                public void onComplete(@NonNull Task<DataSnapshot> snapshot) {
                    int index = 1;

                    ArrayList<Chat> tempData3 = new ArrayList<Chat>();

                    if(snapshot.getResult().getChildrenCount() == 0) {
                        startup = false;
                        mSwipeRefreshLayout.setRefreshing(false);

                    }

                    for (DataSnapshot child : snapshot.getResult().getChildren()) {
                        final String ownerId = (String) child.child("ownerId").getValue();
                        final String message = (String) child.child("message").getValue();
                        final String ownerName = (String) child.child("ownerName").getValue();
                        final Long timePosted = (Long) child.child("timePosted").getValue();
                        final String docId = (String) child.getKey();

                        Chat tempChat = new Chat(message, ownerId, ownerName, timePosted, docId);

                        if (!chatGroupArray.getBlockedUsers().contains(ownerId)) {
                            tempData3.add(tempChat);
                        }else {
                            Log.d("1234","" + ownerId + " message has not shown");
                        }
                        if(index == snapshot.getResult().getChildrenCount()) {
                            totalPosts += 30;


                            ChatSave.addAll(0, tempData3);

                            if(ChatSave.size() >= 16) {
                                listView.setStackFromBottom(true);
                            }

                            if(total == 1) {
                                ChatSave.remove(0);
                            }

                            if(id == "" && atValue == 0) {

                                populateList(ChatSave);
                            }
                            else {

                                saveAdapter.notifyDataSetChanged();
                                mSwipeRefreshLayout.setRefreshing(false);
                            }

                            startup = false;

                        }

                        index++;
                    }
                }
            });
        }


        public static String getRandomNumberString() {
            // It will generate 6 digit random Number.
            // from 0 to 999999
            Random rnd = new Random();
            int number = rnd.nextInt(999999);

            // this will convert any number sequence into 6 character.
            return String.format("%06d", number);
        }


        public void populateList(ArrayList<Chat> chat) {
            if(mActivity != null) {
                saveAdapter = new adapterListLiveChat(mActivity, chat);
                listView.setAdapter(saveAdapter);
            }
        }

        public void incrementUnseen(final String signedInUsername, final String lastMessage) {
            chatGroupArray.isTransaction = true;
            notificationRef = FirebaseDatabase.getInstance().getReference().child("Notifications").orderByChild("gName").equalTo(gid);
            notificationRef.get().addOnCompleteListener(new OnCompleteListener<DataSnapshot>() {
                @Override
                public void onComplete(@NonNull Task<DataSnapshot> task) {
                    if (!task.isSuccessful()) {
                    } else {
                        for (final DataSnapshot i : task.getResult().getChildren()) {
                            DatabaseReference data = i.getRef();

                            data.runTransaction(new Transaction.Handler() {
                                @NonNull
                                @Override
                                public Transaction.Result doTransaction(@NonNull MutableData currentData) {
                                    Long count = (Long) currentData.child("unseenMessage").getValue();
                                    if (!i.child("parentUser").getValue().toString().equals(signedInUsername)) {
                                        currentData.child("unseenMessage").setValue(count + 1);
                                    }
                                    currentData.child("lastMessage").setValue(lastMessage);
                                    currentData.child("lastUser").setValue(signedInUsername);
                                    String timeStamp = String.valueOf(TimeUnit.MILLISECONDS.toSeconds(System.currentTimeMillis()));
                                    int dateNow = Integer.parseInt(timeStamp);
                                    currentData.child("timestamp").setValue(dateNow);
                                    return Transaction.success(currentData);
                                }

                                @Override
                                public void onComplete(@Nullable DatabaseError databaseError, boolean committed, @Nullable DataSnapshot dataSnapshot) {
                                    chatGroupArray.isTransaction = false;
                                }
                            });
                        }
                    }
                }
            });
        }

        @Override
        public void onRefresh() {
            if(ChatSave.size() > 0) {
                Long timePosted = (Long) ChatSave.get(0).getTimestamp();
                String time = (String) timePosted.toString();

                listView.setTranscriptMode(ListView.TRANSCRIPT_MODE_DISABLED);

                getChatLogs(ChatSave.get(0).getDocId(), Integer.parseInt(time), totalPosts);

            }
            mSwipeRefreshLayout.setRefreshing(false);
        }
    }
package app.mayven.mayven;

import android.app.Activity;
import android.content.Context;
import android.os.Bundle;

import androidx.annotation.NonNull;
import androidx.appcompat.app.AppCompatActivity;
import androidx.fragment.app.Fragment;
import androidx.swiperefreshlayout.widget.SwipeRefreshLayout;

import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.AdapterView;
import android.widget.ArrayAdapter;
import android.widget.ImageView;
import android.widget.ListView;


import app.mayven.mayven.R;
import com.google.android.gms.tasks.OnCompleteListener;
import com.google.android.gms.tasks.Task;

import com.google.android.material.badge.BadgeDrawable;
import com.google.android.material.bottomnavigation.BottomNavigationView;
import com.google.firebase.database.DataSnapshot;
import com.google.firebase.database.DatabaseError;
import com.google.firebase.database.DatabaseReference;
import com.google.firebase.database.FirebaseDatabase;
import com.google.firebase.database.MutableData;
import com.google.firebase.database.Transaction;
import com.google.firebase.database.annotations.Nullable;
import com.google.firebase.firestore.CollectionReference;
import com.google.firebase.firestore.FirebaseFirestore;

import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.TimeUnit;

public class chatFragment extends Fragment implements SwipeRefreshLayout.OnRefreshListener {
    private static final String TAG = "chatFragment";
    public static ListView listView;
    public ArrayList<Group> tempGroup;

    //FirebaseUser mAuth = FirebaseAuth.getInstance().getCurrentUser();
    private FirebaseFirestore db = FirebaseFirestore.getInstance();
    private CollectionReference users = db.collection("Users");

    private DatabaseReference addRef = FirebaseDatabase.getInstance().getReference("ChatLogs");
    // private DatabaseReference notifRef = FirebaseDatabase.getInstance().getReference("Notifications"); ;
    private com.google.firebase.database.Query notifRef;
    private ImageView add;
    private boolean shouldRefreshOnResume = false;
    Activity mActivity;

    Boolean flag = false;
    public static Boolean flag2 = false;

    public BottomNavigationView bottomNavigationView;
    ArrayAdapter<Group> saveAdapter;
    private BottomNavigationView.OnNavigationItemSelectedListener bottomNavMethod;

    SwipeRefreshLayout mSwipeRefreshLayout;


    public chatFragment() {

    }

    @Override
    public void onCreate(Bundle savedInstanceState) {

        super.onCreate(savedInstanceState);

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
        //   mActivity = null;
    }

    @Override
    public void onResume() {
        super.onResume();
        // Check should we need to refresh the fragment
        if(shouldRefreshOnResume) {
            // refresh fragment
            //  final ChatGroupArray chatGroupArray = new ChatGroupArray();
            // updateData(chatGroupArray.getGroupSave());
        }
    }

    @Override
    public void onStop() {
        super.onStop();
        shouldRefreshOnResume = true;
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {
        // Inflate the layout for this fragment
        final ChatGroupArray chatGroupArray = new ChatGroupArray();
        chatGroupArray.refreshChat = true;
        ((MainActivity) getActivity()).unhideNav();

        final View v = inflater.inflate(R.layout.fragment_chat, container, false);
        final View nav = inflater.inflate(R.layout.activity_main, container, false);
        bottomNavigationView = nav.findViewById(R.id.bottomNav);
        BadgeDrawable badge = bottomNavigationView.getOrCreateBadge(2131231026);
        badge.setVisible(false);

        mSwipeRefreshLayout = v.findViewById(R.id.swipeLayout);
        mSwipeRefreshLayout.setOnRefreshListener(this);

        Boolean flag = false;

        for (Group i : chatGroupArray.getGroupSave()) {
            if (i.getNotifications() != 0) {
                flag = true;
            }
        }

        if (flag == false) {
            ((MainActivity) getActivity()).removeBadges();
        }

        RegisterUsername reg = new RegisterUsername();
        List<userDB> qwe = reg.readData();
        final String signedInUser = qwe.get(0).name;
        final String signedInUsername = qwe.get(0).username;
        listView = v.findViewById(R.id.recycle);


        saveAdapter = new groupAdapter(mActivity, chatGroupArray.getGroupSave());
        listView.setAdapter(saveAdapter);

        listView.setOnItemClickListener(new AdapterView.OnItemClickListener() {
            @Override
            public void onItemClick(AdapterView<?> parent, View view, final int position, long id) {
                final ChatGroupArray chatGroupArray = new ChatGroupArray();
                chatGroupArray.isTransaction = true;

                AppCompatActivity activity = (AppCompatActivity) v.getContext();
                notifRef = FirebaseDatabase.getInstance().getReference().child("Notifications").orderByChild("parentUser").equalTo(signedInUsername);
                notifRef.get().addOnCompleteListener(new OnCompleteListener<DataSnapshot>() {
                    @Override
                    public void onComplete(@NonNull Task<DataSnapshot> task) {
                        if (!task.isSuccessful()) {
                        } else {
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
                                }
                            }
                        }
                    }
                });
                //CHANGE NAME AND SCHOOL ID TO DATABASE
                activity.getSupportFragmentManager().beginTransaction().replace(R.id.container, new LiveChatFragment(chatGroupArray.getGroupSave().get(position).getDocId(), chatGroupArray.getGroupSave().get(position).getName(), signedInUser)).addToBackStack("chatFragment").commit();
            }
        });


        add = v.findViewById(R.id.addgroup);
        add.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                Adding_Chat_Group adding_post = new Adding_Chat_Group();
                assert getFragmentManager() != null;
                adding_post.show(getFragmentManager(), "Test");
            }
        });


        return v;
    }

    public void updateData(ArrayList<Group> newGroup) {
        Log.d("mActivity", "mActivity is " + mActivity);

//        if(mActivity != null) {
        ((groupAdapter) saveAdapter).updateReceiptsList(newGroup);
        //      }
    }

    @Override
    public void onRefresh() {
        saveAdapter.notifyDataSetChanged();

        String timeStamp = String.valueOf(TimeUnit.MILLISECONDS.toSeconds(System.currentTimeMillis()));
        final int time = Integer.parseInt(timeStamp);
        ChatGroupArray chatGroupArray = new ChatGroupArray();
        chatGroupArray.imageTime = time;

        mSwipeRefreshLayout.setRefreshing(false);

    }
}
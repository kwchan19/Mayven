package app.mayven.mayven;

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
import android.widget.ListView;
import android.widget.TextView;
import android.widget.Toast;

import app.mayven.mayven.R;
import com.google.android.gms.tasks.OnCompleteListener;
import com.google.android.gms.tasks.Task;
import com.google.firebase.firestore.CollectionReference;
import com.google.firebase.firestore.DocumentSnapshot;
import com.google.firebase.firestore.FirebaseFirestore;

import java.util.LinkedList;
import java.util.List;
import java.util.Map;
import java.util.concurrent.TimeUnit;


public class NotificationFragment extends Fragment implements SwipeRefreshLayout.OnRefreshListener {
    private static final String TAG = "NotificationFragment";
    private FirebaseFirestore db = FirebaseFirestore.getInstance();
    private CollectionReference postRef = db.collection("Posts");
    private ListView list;
    public static TextView isEmpty;
    List<List<Object>> finalList = new LinkedList<List<Object>>();
    public static ListView listView;
    SwipeRefreshLayout mSwipeRefreshLayout;
    public static adapterNotifications adapter;

    @Override
    public void onResume()
    {
        super.onResume();
    }

    public NotificationFragment() {
    }

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {

        View v =  inflater.inflate(R.layout.fragment_notification, container, false);
        ((MainActivity)getActivity()).unhideNav();
        ((MainActivity)getActivity()).removeNotificationBadge();

        list = v.findViewById(R.id.list);
        final ChatGroupArray chatGroupArray = new ChatGroupArray();
        final RegisterUsername reg = new RegisterUsername();
        List<userDB> qwe = reg.readData();
        final String signedInUsername = qwe.get(0).username;

        mSwipeRefreshLayout = v.findViewById(R.id.swipeLayout);
        mSwipeRefreshLayout.setOnRefreshListener(this);
        isEmpty = v.findViewById(R.id.isEmpty);

        adapter = new adapterNotifications(getActivity(), chatGroupArray.getNotificationArr());

        listView = (ListView) v.findViewById(R.id.list);

        listView.setAdapter(adapter);
        // iterateNotification(notificationArr);
        listView.setOnItemClickListener(new AdapterView.OnItemClickListener() {
            @Override
            public void onItemClick(AdapterView<?> parent, final View view, final int position, long id) {
                final String DID = chatGroupArray.notificationArr.get(position).getOriginalPost();
                postRef
                        .document(DID)
                        .get()
                        .addOnCompleteListener(new OnCompleteListener<DocumentSnapshot>() {
                            @Override
                            public void onComplete(@NonNull Task<DocumentSnapshot> task) {
                                DocumentSnapshot document = task.getResult();
                                if(document.exists()) {
                                    Note note = document.toObject(Note.class);
                                    List<String> replies = note.getreplies();
                                    List<String> userLiked = note.getUsersLiked();
                                    String post = note.getPost();
                                    String ownerName = note.getOwnerName();
                                    String iUrl = note.getImageURL();
                                    //document id is DID
                                    String ownerId = note.getId();
                                    int time = note.getTime2();
                                    int likes = note.getLikes();

                                    if(chatGroupArray.notificationArr.size() > 15) {
                                        chatGroupArray.notificationArr.remove(position);
                                        adapter.notifyDataSetChanged();
                                    }

                                    AppCompatActivity activity=(AppCompatActivity)view.getContext();
                                    activity.getSupportFragmentManager().beginTransaction().replace(R.id.container, new HomeReplies(replies.size(),
                                            post, ownerName, iUrl, DID, ownerId,time,userLiked,likes, position, note.getreplies(), note.getReports())).addToBackStack(null).commit();

                                }else{
                                    Toast.makeText(getContext(), "The document has been deleted by the owner or taken down", Toast.LENGTH_SHORT ).show();
                                }
                            }
                        });
            }
        });


        return v;
    }

    public void iterateNotification(List<Map<String,Object>> mp) {
        List<Object> temp = new LinkedList<>();
        //List<Object> finalValue = new LinkedList<>();

        for (Map<String, Object> map : mp) {
            for (Map.Entry<String, Object> entry : map.entrySet()) {
                if(entry.getKey().equals("ownerId")){
                    temp.add(entry.getValue());
                }
                if(entry.getKey().equals("type")){
                    temp.add(entry.getValue());
                }
            }
        }
        finalList.add(temp);
    }

    @Override
    public void onRefresh() {
        adapter.notifyDataSetChanged();

        String timeStamp = String.valueOf(TimeUnit.MILLISECONDS.toSeconds(System.currentTimeMillis()));
        final int time = Integer.parseInt(timeStamp);
        ChatGroupArray chatGroupArray = new ChatGroupArray();
        chatGroupArray.imageTime = time;

        if(chatGroupArray.getNotificationArr().size() == 0){
            NotificationFragment.isEmpty.setVisibility(View.VISIBLE);
        }
        else {
            NotificationFragment.isEmpty.setVisibility(View.INVISIBLE);
        }

        mSwipeRefreshLayout.setRefreshing(false);

        ((MainActivity) getActivity()).removeNotificationBadge();
    }
}
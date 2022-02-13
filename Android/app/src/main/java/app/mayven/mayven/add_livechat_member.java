package app.mayven.mayven;

import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ArrayAdapter;
import android.widget.Button;
import android.widget.EditText;
import android.widget.Toast;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import app.mayven.mayven.R;
import com.google.android.gms.tasks.OnCompleteListener;
import com.google.android.gms.tasks.Task;
import com.google.android.material.bottomsheet.BottomSheetDialogFragment;
import com.google.firebase.database.DatabaseReference;
import com.google.firebase.database.FirebaseDatabase;
import com.google.firebase.firestore.CollectionReference;
import com.google.firebase.firestore.FieldValue;
import com.google.firebase.firestore.FirebaseFirestore;
import com.google.firebase.firestore.QueryDocumentSnapshot;
import com.google.firebase.firestore.QuerySnapshot;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.concurrent.TimeUnit;

public class add_livechat_member extends BottomSheetDialogFragment {

    private FirebaseFirestore db = FirebaseFirestore.getInstance();
    private CollectionReference usersRef = db.collection("Users");
    private CollectionReference chatboxRef = db.collection("ChatGroups");
    private DatabaseReference RTDNotifications = FirebaseDatabase.getInstance().getReference("Notifications");
    private Button add;
    private EditText groupname;
    private List<String> membersArray = new ArrayList<String>();
    ArrayList<groupMembers> tempData;
    private Boolean flag;

    @Nullable
    @Override
    public View onCreateView(@NonNull LayoutInflater inflater, @Nullable ViewGroup container, @Nullable Bundle savedInstanceState) {
        View v = inflater.inflate(R.layout.live_chat_add_members, container, false);
        final String gid = getArguments().getString("gid");

        flag = false;
        add = v.findViewById(R.id.btn_send);
        groupname = v.findViewById(R.id.msg_input);

        RegisterUsername reg = new RegisterUsername();
        List<userDB> qwe = reg.readData();
        final String school = qwe.get(0).school;

        add.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                LiveChatMembersFragment fragment = new LiveChatMembersFragment();
                final String name = groupname.getText().toString();
                boolean flag = false;
                for(groupMembers gm: fragment.users) {
                    if(gm.getName().equals(name)) {
                        flag = true;
                    }
                }

                if(flag == false) {
                    usersRef.whereEqualTo("username", name).get().addOnCompleteListener(new OnCompleteListener<QuerySnapshot>() {
                        @Override
                        public void onComplete(@NonNull Task<QuerySnapshot> task) {
                            QuerySnapshot dc = task.getResult();
                            if (!dc.isEmpty()) {
                                final String timeStamp = String.valueOf(TimeUnit.MILLISECONDS.toSeconds(System.currentTimeMillis()));
                                final Long dateNow = Long.parseLong(timeStamp);
                                for (QueryDocumentSnapshot queryDocumentSnapshot : task.getResult()) {
                                    if(!queryDocumentSnapshot.getString("school").equals(school)) {
                                        Toast.makeText(getContext(), "This username does not exist. Check your spelling!", Toast.LENGTH_LONG).show();
                                    }
                                    else {
                                        final String username = queryDocumentSnapshot.getString("username");
                                        final String name = queryDocumentSnapshot.getString("name");
                                        chatboxRef.document(gid).update(
                                                "members", FieldValue.arrayUnion(username)
                                        );
                                        DatabaseReference ref = RTDNotifications.push();
                                        String postId = ref.getKey();
                                        Map<String, Object> RTDN = new HashMap<>();

                                        RTDN.put("gName", gid);
                                        RTDN.put("lastMessage", username + " has joined the group");
                                        RTDN.put("lastUser", username);
                                        RTDN.put("parentUser", username);
                                        RTDN.put("timestamp", dateNow);
                                        RTDN.put("unseenMessage", 0);

                                        RTDNotifications.child(postId).updateChildren(RTDN);
                                        groupMembers gm = new groupMembers(false, username, name);
                                        LiveChatMembersFragment fragment = new LiveChatMembersFragment();
                                        fragment.users.add(gm);
                                        ArrayAdapter<groupMembers> saveAdapter = new groupMembersAdapter(getContext(), fragment.users, fragment.groupId, fragment.isTrue);
                                        fragment.listView.setAdapter(saveAdapter);
                                        dismiss();
                                    }
                                }
                            } else {
                                Toast.makeText(getContext(), "This username does not exist. Check spelling!", Toast.LENGTH_LONG).show();
                            }
                        }
                    });
                }
                else {
                    Toast.makeText(getContext(), "The user is already in the group", Toast.LENGTH_LONG).show();
                }
            }
        });


        return v;
    }
}
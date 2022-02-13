package app.mayven.mayven;


import android.app.ActionBar;
import android.app.Dialog;
import android.content.Context;
import android.graphics.Color;
import android.graphics.drawable.ColorDrawable;
import android.util.Log;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.view.ViewGroup;
import android.view.WindowManager;
import android.widget.ArrayAdapter;
import android.widget.ImageView;
import android.widget.PopupMenu;
import android.widget.TextView;
import android.widget.Toast;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.bumptech.glide.Glide;
import com.bumptech.glide.request.RequestOptions;
import app.mayven.mayven.R;

import com.bumptech.glide.signature.ObjectKey;
import com.google.android.gms.tasks.OnCompleteListener;
import com.google.android.gms.tasks.Task;
import com.google.firebase.database.DataSnapshot;
import com.google.firebase.database.FirebaseDatabase;
import com.google.firebase.database.Query;
import com.google.firebase.firestore.CollectionReference;
import com.google.firebase.firestore.DocumentSnapshot;
import com.google.firebase.firestore.FieldValue;
import com.google.firebase.firestore.FirebaseFirestore;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

public class groupMembersAdapter extends ArrayAdapter<groupMembers> {

    private FirebaseFirestore db = FirebaseFirestore.getInstance();
    private CollectionReference chatGroups = db.collection("ChatGroups");
    private CollectionReference userRef = db.collection("Users");

    private Dialog dialog;


    ArrayList<groupMembers> list;

    Boolean isTrue;

    String groupId;
    Context context;

    public groupMembersAdapter(@NonNull Context context, ArrayList<groupMembers> group, String groupid, Boolean isTrue) {
        super(context, R.layout.list_groupmembers, group);
        this.context = context;
        groupId = groupid;
        list = group;
        this.isTrue = isTrue;
    }

    @NonNull
    @Override
    public View getView(final int position, @Nullable View convertView, @NonNull ViewGroup parent) {
        View row = convertView;
        if (convertView == null) {
            LayoutInflater layoutInflater = LayoutInflater.from(context);
            row = layoutInflater.inflate(R.layout.list_groupmembers, null);
        }

        RegisterUsername reg = new RegisterUsername();
        List<userDB> qwe = reg.readData();

        final String signedInUsername = qwe.get(0).username;

        final groupMembers group = getItem(position);
        final TextView userid = (TextView) row.findViewById(R.id.userName);
        final TextView username = (TextView) row.findViewById(R.id.name);
        TextView permission = (TextView) row.findViewById(R.id.permissions);
        ImageView profilePic = (ImageView) row.findViewById(R.id.profilePic);
        final ImageView tripleDot = (ImageView) row.findViewById(R.id.tripleDot);

        String imgurl = "https://firebasestorage.googleapis.com/v0/b/chatapp-6d978.appspot.com/o/Thumbnail%2F" + group.getName() + ".jpeg?alt=media";

        ChatGroupArray chatGroupArray = new ChatGroupArray();
        final String ts = String.valueOf(chatGroupArray.imageTime);

        Glide.with(profilePic.getContext())
                .load(imgurl)
                .dontAnimate()
                .placeholder(R.drawable.placeholder)
                .error(R.drawable.initial_pic)
                .signature(new ObjectKey(ts))
                .apply(RequestOptions.circleCropTransform())
                .into(profilePic);

        userid.setText(group.getName());
        username.setText(group.getUserName());


        if (position == 0 && group.isAdmin() == true) {
            permission.setText("Owner");
            permission.setVisibility(View.VISIBLE);
            tripleDot.setVisibility(View.INVISIBLE);

        } else if (group.isAdmin() == true) {
            permission.setText("Admin");
            permission.setVisibility(View.VISIBLE);
        } else {
            permission.setVisibility(View.INVISIBLE);
        }
        if (isTrue == false) {
            tripleDot.setVisibility(View.INVISIBLE);
        }

        dialog = new Dialog(context);
        dialog.setContentView(R.layout.dialog_image);
        dialog.getWindow().setBackgroundDrawable(new ColorDrawable(Color.TRANSPARENT));

        WindowManager.LayoutParams params = dialog.getWindow().getAttributes();

        params.width = ActionBar.LayoutParams.MATCH_PARENT;
        params.gravity = Gravity.BOTTOM;

        dialog.getWindow().setAttributes(params);

        profilePic.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                db.collection("Users").document(group.getName()).get().addOnCompleteListener(new OnCompleteListener<DocumentSnapshot>() {
                    @Override
                    public void onComplete(@NonNull Task<DocumentSnapshot> task) {
                        if (task.isSuccessful()) {

                            try {
                                //  Block of code to try
                                DocumentSnapshot ds = task.getResult();
                                TextView dialogName = dialog.findViewById(R.id.name);
                                TextView dialogDesc = dialog.findViewById(R.id.desc);
                                ImageView dialogPic = dialog.findViewById(R.id.profilePic);
                                final ImageView dialogTripledot = dialog.findViewById(R.id.tripleDot);
                                TextView programName = dialog.findViewById(R.id.programName);
                                //TextView classOf = dialog.findViewById(R.id.classOf);
                                TextView classOfDesc = dialog.findViewById(R.id.classOfDesc);

                                dialogName.setText((group.getUserName()));
                                dialogDesc.setText((group.getName()));
                                programName.setText((String) ds.getString("programName"));

                                if (signedInUsername.equals(group.getName())) {
                                    dialogTripledot.setVisibility(View.GONE);
                                }
                                else {
                                    dialogTripledot.setVisibility(View.VISIBLE);
                                }
                                dialogTripledot.setOnClickListener(new View.OnClickListener() {
                                    @Override
                                    public void onClick(View v) {
                                        final PopupMenu popup = new PopupMenu(context, dialogTripledot);
                                        Menu menu = popup.getMenu();
                                        popup.inflate(R.menu.menu_block);

                                        popup.setOnMenuItemClickListener(new PopupMenu.OnMenuItemClickListener() {
                                            @Override
                                            public boolean onMenuItemClick(MenuItem item) {
                                                switch (item.getItemId()) {
                                                    case R.id.blockUser:
                                                        blockUser(signedInUsername, group.getName(), dialog);
                                                        break;
                                                }
                                                return false;
                                            }
                                        });
                                        popup.show();
                                    }
                                });



                                int classOfInt = Integer.valueOf(ds.getString("classOf")) + 4;
                                String classOfStr = String.valueOf(classOfInt);

                                classOfDesc.setText(classOfStr);

                                String imgurl = "https://firebasestorage.googleapis.com/v0/b/chatapp-6d978.appspot.com/o/" + group.getName() + ".jpeg?alt=media";

                                Glide.with(dialogPic.getContext()).load(imgurl)
                                        .dontAnimate()
                                        .apply(RequestOptions.circleCropTransform())
                                        .signature(new ObjectKey(ts))
                                        .into(dialogPic);

                                dialog.show();
                            }
                            catch(Exception e) {
                                //  Block of code to handle errors
                                Toast.makeText(context,"This user has been deleted",Toast.LENGTH_SHORT).show();
                            }


                        }else {
                            Toast.makeText(context,"This user has been deleted",Toast.LENGTH_SHORT).show();
                        }
                    }
                });
            }
        });


        tripleDot.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                final PopupMenu popup = new PopupMenu(context, tripleDot);
                Menu menu = popup.getMenu();
                popup.inflate(R.menu.menu_members_3dots);

                if (group.isAdmin == true) {
                    menu.getItem(0).setTitle("Demote");
                }

                popup.setOnMenuItemClickListener(new PopupMenu.OnMenuItemClickListener() {
                    @Override
                    public boolean onMenuItemClick(MenuItem item) {
                        switch (item.getItemId()) {
                            case R.id.promoteMember:
                                if (group.isAdmin == true) {
                                    DemoteUser(group.getName(), position, 1);
                                    LiveChatMembersFragment cmf = new LiveChatMembersFragment();
                                    FirebaseFirestore db = FirebaseFirestore.getInstance();
                                    CollectionReference chatGroups = db.collection("ChatGroups");
                                    final CollectionReference userRef = db.collection("Users");

                                    chatGroups
                                            .document(groupId)
                                            .get().addOnCompleteListener(new OnCompleteListener<DocumentSnapshot>() {
                                        @Override
                                        public void onComplete(@NonNull Task<DocumentSnapshot> task) {
                                            Boolean isTrue2 = isTrue;
                                            DocumentSnapshot dc = task.getResult();
                                            List<String> finale = new ArrayList<>();
                                            String owner = dc.getString("ownerId");
                                            List<String> members = (List<String>) dc.get("members");
                                            final List<String> admins = (List<String>) dc.get("admins");
                                            Collections.sort(members);
                                            Collections.sort(admins);

                                            final ArrayList<groupMembers> obj = new ArrayList<groupMembers>();

                                            if (owner != "") {
                                                obj.add(new groupMembers(true, owner, ""));
                                            }

                                            if (admins.size() != 0) {
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
                                                if (!owner.equals(members.get(t))) {
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
                                                                LiveChatMembersFragment fragment = new LiveChatMembersFragment();
                                                                fragment.users.clear();
                                                                fragment.users = obj;
                                                                ArrayAdapter<groupMembers> saveAdapter = new groupMembersAdapter(getContext(), fragment.users, groupId, isTrue);
                                                                fragment.listView.setAdapter(saveAdapter);
                                                                fragment.listView.invalidateViews();
                                                            }

                                                            count[0]++;
                                                        } else {
                                                        }
                                                    }
                                                });
                                            }
                                        }
                                    });
                                } else {
                                    Promote(group.getName(), position, 0);
                                    FirebaseFirestore db = FirebaseFirestore.getInstance();
                                    CollectionReference chatGroups = db.collection("ChatGroups");
                                    final CollectionReference userRef = db.collection("Users");

                                    chatGroups
                                            .document(groupId)
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

                                            if (owner != "") {
                                                obj.add(new groupMembers(true, owner, ""));
                                            }


                                            if (admins.size() != 0) {
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
                                                if (!owner.equals(members.get(t))) {
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
                                                                LiveChatMembersFragment fragment = new LiveChatMembersFragment();
                                                                fragment.users.clear();
                                                                fragment.users = obj;
                                                                ArrayAdapter<groupMembers> saveAdapter = new groupMembersAdapter(getContext(), fragment.users, groupId, isTrue);
                                                                fragment.listView.setAdapter(saveAdapter);
                                                                fragment.listView.invalidateViews();
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
                                break;
                            case R.id.removeMember:
                                RemoveUser(group.getName(), position, signedInUsername);

                                FirebaseFirestore db = FirebaseFirestore.getInstance();
                                CollectionReference chatGroups = db.collection("ChatGroups");
                                final CollectionReference userRef = db.collection("Users");

                                chatGroups
                                        .document(groupId)
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

                                        if (owner != "") {
                                            obj.add(new groupMembers(true, owner, ""));
                                        }


                                        if (admins.size() != 0) {
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
                                            if (!owner.equals(members.get(t))) {
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
                                                            LiveChatMembersFragment fragment = new LiveChatMembersFragment();
                                                            fragment.users.clear();
                                                            fragment.users = obj;
                                                            ArrayAdapter<groupMembers> saveAdapter = new groupMembersAdapter(getContext(), fragment.users, groupId, isTrue);
                                                            fragment.listView.setAdapter(saveAdapter);
                                                            fragment.listView.invalidateViews();
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
                        return false;
                    }
                });
                popup.show();

            }
        });
        return row;
    }

    private void blockUser(String signedInUser, String id, Dialog dialog) {
        userRef.document(signedInUser).update(
                "blockedUsers", FieldValue.arrayUnion(id)
        );
        ChatGroupArray.BlockedUsers.add(id);
        //mContext.startActivity(new Intent(mContext, MainActivity.class));
        dialog.dismiss();
    }


    public void RemoveUser(final String username, int position, final String signedInUsername) {
        chatGroups.document(groupId).update(
                "admins", FieldValue.arrayRemove(username),
                "members", FieldValue.arrayRemove(username)
        );

        final ChatGroupArray chatGroupArray = new ChatGroupArray();
        chatGroupArray.isTransaction = true;

        LiveChatMembersFragment fragment = new LiveChatMembersFragment();
        fragment.users.remove(position);

        FirebaseDatabase.getInstance().getReference().child("ChatLogs").child(groupId).removeValue();

        Query q = FirebaseDatabase.getInstance().getReference().child("Notifications").orderByChild("parentUser").equalTo(username);

        q.get().addOnCompleteListener(new OnCompleteListener<DataSnapshot>() {
            @Override
            public void onComplete(@NonNull Task<DataSnapshot> task) {
                if(task.isSuccessful()){
                    for (final DataSnapshot i : task.getResult().getChildren()) {
                        if (groupId.equals((String) i.child("gName").getValue())){
                            i.getRef().removeValue();
                        }
                    }
                }else {
                    chatGroupArray.isTransaction = false;
                }
            }
        });

        this.notifyDataSetChanged();
    }

    public void Promote(String username, int position, int num) {

        chatGroups.document(groupId).update(
                "admins", FieldValue.arrayUnion(username)
        );

        LiveChatMembersFragment fragment = new LiveChatMembersFragment();

        this.notifyDataSetChanged();
    }

    public void DemoteUser(String username, int position, int num) {
        chatGroups.document(groupId).update(
                "admins", FieldValue.arrayRemove(username)
        );
        // list.remove(position);
        //list.add(1, new groupMembers(false, username, ""));

        LiveChatMembersFragment fragment = new LiveChatMembersFragment();
        //fragment.users.clear();

        //    final ChatGroupArray chatGroupArray = new ChatGroupArray();
        //  chatGroupArray.members = list;
        this.notifyDataSetChanged();
    }

    public void updateReceiptsList(ArrayList<groupMembers> newGroup) {
        list = newGroup;
        synchronized(this) {
            this.notifyAll();
        }
    }


}
package app.mayven.mayven;

import android.content.Context;
import android.content.Intent;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ArrayAdapter;
import android.widget.ImageView;
import android.widget.PopupMenu;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.bumptech.glide.Glide;
import com.bumptech.glide.signature.ObjectKey;
import com.google.android.gms.tasks.OnCompleteListener;
import com.google.android.gms.tasks.Task;
import com.google.firebase.firestore.CollectionReference;
import com.google.firebase.firestore.DocumentSnapshot;
import com.google.firebase.firestore.FieldValue;
import com.google.firebase.firestore.FirebaseFirestore;

import java.util.ArrayList;
import java.util.List;

public class adapterBlocked extends ArrayAdapter<String> {
    private Context context;
    private ArrayList<String> list;
    String docname;

    private FirebaseFirestore db = FirebaseFirestore.getInstance();
    private CollectionReference userRef = db.collection("Users");

    public adapterBlocked(Context context, ArrayList<String> list) {
        super(context, R.layout.list_groupmembers, list);
        this.context = context;
        this.list = list;
    }

    @NonNull
    @Override
    public View getView(final int position, @Nullable View convertView, @NonNull ViewGroup parent) {
        Integer previousIndex = 0;
        View row = convertView;
        if (convertView == null) {
            LayoutInflater layoutInflater = LayoutInflater.from(context);
            row = layoutInflater.inflate(R.layout.list_groupmembers, null);
        }
        final String docidname = list.get(position);


        final TextView userName = (TextView) row.findViewById(R.id.userName);
        final TextView name = (TextView) row.findViewById(R.id.name);
        TextView permission = (TextView) row.findViewById(R.id.permissions);
        ImageView profilePic = (ImageView) row.findViewById(R.id.profilePic);
        final ImageView tripleDot = (ImageView) row.findViewById(R.id.tripleDot);

        permission.setVisibility(View.INVISIBLE);

        String imgurl = "https://firebasestorage.googleapis.com/v0/b/chatapp-6d978.appspot.com/o/Thumbnail%2F" + docidname + ".jpeg?alt=media";
        ChatGroupArray chatGroupArray = new ChatGroupArray();
        final String ts = String.valueOf(chatGroupArray.imageTime);

        Glide.with(profilePic.getContext()).load(imgurl)
                .dontAnimate()
                .placeholder(R.drawable.placeholder)
                .signature(new ObjectKey(ts))
                //  .error(R.drawable.ic_person_fill)
                .into(profilePic);

        userRef.document(docidname).get().addOnCompleteListener(new OnCompleteListener<DocumentSnapshot>() {
            @Override
            public void onComplete(@NonNull Task<DocumentSnapshot> task) {
                DocumentSnapshot dc = task.getResult();
                docname = (String) dc.getString("name");
                name.setText(docname);
            }
        });
        userName.setText(docidname);

        tripleDot.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                final PopupMenu popup = new PopupMenu(context , tripleDot);
                Menu menu = popup.getMenu();
                popup.inflate(R.menu.menu_block);

                menu.findItem(R.id.blockUser).setTitle("Unblock");


                popup.setOnMenuItemClickListener(new PopupMenu.OnMenuItemClickListener() {
                    @Override
                    public boolean onMenuItemClick(MenuItem item) {
                        switch (item.getItemId()){
                            case R.id.blockUser:
                                unblockuser(docidname,list,position);
                        }

                        return false;
                    }
                });
                popup.show();
            }
        });
        return row;
    }
    private void unblockuser(String docname, ArrayList<String> list, int position){
        RegisterUsername reg = new RegisterUsername();
        List<userDB> qwe = reg.readData();
        final String signedInUsername = qwe.get(0).username;

        userRef.document(signedInUsername).update(
                "blockedUsers", FieldValue.arrayRemove(docname)
        );

        ChatGroupArray chatGroupArray = new ChatGroupArray();
        list.remove(position);
        Log.d("1234","chat group array adapter = " + list);
        Log.d("1234","chat group  = " + chatGroupArray.getBlockedUsers());
        BlockedFragment.adapter.notifyDataSetChanged();
    }
}
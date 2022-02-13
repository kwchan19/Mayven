package app.mayven.mayven;

import android.app.ActionBar;
import android.app.Dialog;
import android.content.Context;
import android.content.DialogInterface;
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
import android.widget.ImageView;
import android.widget.PopupMenu;
import android.widget.TextView;
import android.widget.Toast;

import androidx.annotation.NonNull;
import androidx.appcompat.app.AlertDialog;
import androidx.appcompat.app.AppCompatActivity;
import androidx.fragment.app.FragmentManager;
import androidx.recyclerview.widget.RecyclerView;

import com.bumptech.glide.Glide;
import com.bumptech.glide.request.RequestOptions;
import app.mayven.mayven.R;

import com.bumptech.glide.signature.ObjectKey;
import com.google.android.gms.tasks.OnCompleteListener;
import com.google.android.gms.tasks.OnFailureListener;
import com.google.android.gms.tasks.OnSuccessListener;
import com.google.android.gms.tasks.Task;
import com.google.firebase.firestore.CollectionReference;
import com.google.firebase.firestore.DocumentSnapshot;
import com.google.firebase.firestore.FieldValue;
import com.google.firebase.firestore.FirebaseFirestore;
import com.google.firebase.firestore.QueryDocumentSnapshot;
import com.google.firebase.firestore.QuerySnapshot;
import com.google.firebase.messaging.FirebaseMessaging;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.concurrent.TimeUnit;

public class adapterReplies extends RecyclerView.Adapter<RecyclerView.ViewHolder> {
    public static final int FIRST_ITEM = 0;
    public static final int REST = 1;
    public static int REPLY_COUNT_STRING;

    private FirebaseFirestore db = FirebaseFirestore.getInstance();

    private Dialog dialog;

    private Context context;
    private List<Object> noteList;
    private String docuID;
    private int glikes;
    private CollectionReference userRef = db.collection("Users");

    public void setData(List<Note> note) {
        this.noteList.addAll(note);
    }


    public adapterReplies(Context context, List<Object> recyclerViewItems, String docuID,int glikes) {
        this.context = context;
        this.noteList = recyclerViewItems;
        this.docuID = docuID;
        this.glikes = glikes;
    }


    @NonNull
    @Override
    public RecyclerView.ViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        switch (viewType) {
            case FIRST_ITEM:
                View black = LayoutInflater.from(parent.getContext()).inflate(R.layout.list_replies2, parent, false);
                return new adapterReplies.ItemViewHolder(black);
            case REST:
                //empty
            default:
                View v = LayoutInflater.from(parent.getContext()).inflate(R.layout.list_replies, parent, false);
                return new adapterReplies.ItemViewHolder(v);
        }
    }

    @Override
    public void onBindViewHolder(@NonNull RecyclerView.ViewHolder holder, final int position) {
        RegisterUsername reg = new RegisterUsername();
        List<userDB> qwe = reg.readData();

        final String signedInUser = qwe.get(0).username;

        final adapterReplies.ItemViewHolder ItemViewHolder = (adapterReplies.ItemViewHolder) holder;
        final Note note = (Note) noteList.get(position);


        final CollectionReference repliesRef = db.collection("Posts").document(docuID).collection("Replies");


        String imgurl = "https://firebasestorage.googleapis.com/v0/b/chatapp-6d978.appspot.com/o/Thumbnail%2F" + note.getId() + ".jpeg?alt=media";

        ChatGroupArray chatGroupArray = new ChatGroupArray();
        final String ts = String.valueOf(chatGroupArray.imageTime);

        Glide.with(ItemViewHolder.profilePic.getContext()).load(imgurl)
                .dontAnimate()
                .placeholder(R.drawable.placeholder)
                .error(R.drawable.initial_pic)
                .apply(RequestOptions.circleCropTransform())
                .signature(new ObjectKey(ts))
                //  .error(R.drawable.ic_person_fill)
                .into(ItemViewHolder.profilePic);


        ItemViewHolder.userName.setText(note.getOwnerName());
        ItemViewHolder.time.setText(note.getTime());
        ItemViewHolder.post.setText(note.getPost());

        dialog  = new Dialog(context);
        dialog.setContentView(R.layout.dialog_image);
        dialog.getWindow().setBackgroundDrawable(new ColorDrawable(Color.TRANSPARENT));

        WindowManager.LayoutParams params = dialog.getWindow().getAttributes();

        params.width = ActionBar.LayoutParams.MATCH_PARENT;
        params.gravity = Gravity.BOTTOM;

        dialog.getWindow().setAttributes(params);


        ItemViewHolder.profilePic.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(final View v) {
                db.collection("Users").document(note.getId()).get().addOnCompleteListener(new OnCompleteListener<DocumentSnapshot>() {
                    @Override
                    public void onComplete(@NonNull Task<DocumentSnapshot> task) {

                        if (task.isSuccessful()) {
                            DocumentSnapshot ds = task.getResult();

                            try {
                                //  Block of code to try
                                TextView dialogName = dialog.findViewById(R.id.name);
                                TextView dialogDesc = dialog.findViewById(R.id.desc);
                                ImageView dialogPic = dialog.findViewById(R.id.profilePic);
                                TextView programName = dialog.findViewById(R.id.programName);
                                TextView classOf = dialog.findViewById(R.id.classOfDesc);

                                dialogName.setText(note.getOwnerName());
                                dialogDesc.setText(note.ownerId);
                                programName.setText((String) ds.getString("programName"));

                                final ImageView dialogTripledot = dialog.findViewById(R.id.tripleDot);
                                if (signedInUser.equals(note.getId())) {
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
                                                        blockUser(signedInUser, note.getId(), dialog);
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

                                classOf.setText(classOfStr);

                                String imgurl = "https://firebasestorage.googleapis.com/v0/b/chatapp-6d978.appspot.com/o/" + note.getId() + ".jpeg?alt=media";

                                Glide.with(dialogPic.getContext()).load(imgurl)
                                        .dontAnimate()
                                        .apply(RequestOptions.circleCropTransform())
                                        .signature(new ObjectKey(ts))
                                        .error(R.drawable.initial_pic)
                                        .into(dialogPic);

                                dialog.show();
                            }
                            catch(Exception e) {
                                //  Block of code to handle errors
                                Toast.makeText(context,"This user has been deleted",Toast.LENGTH_SHORT).show();
                            }
                        }
                        else {
                            Toast.makeText(context,"This user has been deleted",Toast.LENGTH_SHORT).show();
                        }

                    }
                });
            }
        });

        ItemViewHolder.tripleDots.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(final View v) {
                final PopupMenu popup = new PopupMenu(context, ItemViewHolder.tripleDots);
                Menu menu = popup.getMenu();
                popup.inflate(R.menu.menu_remove_report);

                if (signedInUser.equals(note.getId())) {
                    menu.findItem(R.id.report).setVisible(false);
                } else {
                    menu.findItem(R.id.remove).setVisible(false);
                }

                popup.setOnMenuItemClickListener(new PopupMenu.OnMenuItemClickListener() {
                    @Override
                    public boolean onMenuItemClick(MenuItem item) {
                        switch (item.getItemId()) {
                            case R.id.remove:
                                removePost(context, docuID, position, repliesRef, note.getDocumentId(), v, signedInUser);
                                break;
                            case R.id.report:
                                if(note.getReports().size() +1 >= 5) {
                                    reportAndDeleteReplies(signedInUser, note.getDocumentId(), context, docuID, repliesRef, position, note.getId(), note.getPost());
                                    noteList.remove(position);
                                    HomeReplies.adapter.notifyDataSetChanged();
                                }
                                else {
                                    reportPost(signedInUser, note.getDocumentId(), context, docuID, repliesRef, position);
                                }
                        }
                        return false;
                    }
                });
                popup.show();
            }

        });
        Boolean flag = false;

        if (position == 0) {
            List<String> test = note.getUsersLiked();
            for (int y = 0; y < test.size(); y++) {
                if (test.get(y).equals(signedInUser)) {
                    flag = true;
                    break;
                }
            }
            if (flag == true) {
                ItemViewHolder.heart.setImageResource(R.drawable.ic_heart_fill);
                ItemViewHolder.heart.setTag(2);
            } else {
                ItemViewHolder.heart.setImageResource(R.drawable.ic_heart);
                ItemViewHolder.heart.setTag(1);
            }
            ItemViewHolder.heart.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    ChatGroupArray chatGroupArray = new ChatGroupArray();

                    //    adapter.clear();
                    ((MainActivity) context).clearItems();
                    HomeFragment.adapter.notifyDataSetChanged();

                    ((MainActivity) context).addItemsFromFirebase(chatGroupArray.currentType, chatGroupArray.currentProgram);

                    String timeStamp = String.valueOf(TimeUnit.MILLISECONDS.toSeconds(System.currentTimeMillis()));
                    final int dateNow = Integer.parseInt(timeStamp);
                    Map<String, Object> toAdd = new HashMap<>();
                    int num = (int) ItemViewHolder.heart.getTag();
                    List<String> test = note.getUsersLiked();
                    if (num == 1) {
                        ItemViewHolder.heart.setImageResource(R.drawable.ic_heart_fill);
                        test.add(signedInUser);
                        toAdd.put("usersLiked", test);
                        db.collection("Posts").document(docuID)
                                .update(
                                        "usersLiked", test,
                                        "likes", FieldValue.increment(1),
                                        "lastAction", "likes",
                                        "lastActionTime", dateNow
                                );

                        //String likes = String.valueOf(note.getLikes() + 1);
                        //ItemViewHolder.likes.setText(likes);
                        note.likes += 1;
                        ItemViewHolder.heart.setTag(2);
                    } else {
                        ItemViewHolder.heart.setImageResource(R.drawable.ic_heart);
                        ItemViewHolder.heart.setTag(1);
                        test.remove(signedInUser);
                        toAdd.put("usersLiked", test);
                        db.collection("Posts").document(docuID)
                                .update(
                                        "likes", FieldValue.increment(-1)
                                        , "usersLiked", test
                                );

                        String likes = String.valueOf(glikes - 1);
                        //ItemViewHolder.likes.setText(likes);
                        note.likes -= 1;
                    }

                }
            });

            String replyCt;
            if(REPLY_COUNT_STRING == 1) {
                replyCt = " reply";
            }
            else {
                replyCt = " replies";
            }

            if(HomeReplies.isRefreshRun == false){
                ItemViewHolder.reply.setText(note.getReplyCount() + replyCt);
            }else {
                ItemViewHolder.reply.setText(REPLY_COUNT_STRING + replyCt);
            }
            //HomeReplies.adapter.notifyDataSetChanged();
        }

    }

    private void blockUser(String signedInUser, String id, Dialog dialog) {
        userRef.document(signedInUser).update(
                "blockedUsers", FieldValue.arrayUnion(id)
        );
        ChatGroupArray.BlockedUsers.add(id);
        //mContext.startActivity(new Intent(mContext, MainActivity.class));
        dialog.dismiss();
    }

    private void removePost(final Context context, final String documentId, final int position, final CollectionReference repliesRef,
                            final String id, final View view, final String signedInUser) {
        AlertDialog.Builder builder = new AlertDialog.Builder(context);

        builder.setTitle("Confirm");
        builder.setMessage("Are you sure you want to remove this?");

        builder.setPositiveButton("YES", new DialogInterface.OnClickListener() {

            public void onClick(DialogInterface dialog, int which) {
                if (position == 0) {
                    db.collection("Posts").document(documentId)
                            .delete()
                            .addOnSuccessListener(new OnSuccessListener<Void>() {
                                @Override
                                public void onSuccess(Void aVoid) {
                                    noteList.remove(position);

                                    FragmentManager fragmentManager = ((AppCompatActivity) context).getSupportFragmentManager();
                                    fragmentManager.popBackStack(fragmentManager.getBackStackEntryAt(fragmentManager.getBackStackEntryCount() - 1).getId(), FragmentManager.POP_BACK_STACK_INCLUSIVE);

                                }
                            });
                } else {
                    repliesRef.document(id)
                            .delete()
                            .addOnSuccessListener(new OnSuccessListener<Void>() {
                                @Override
                                public void onSuccess(Void aVoid) {
                                    noteList.remove(position);
                                    HomeReplies.adapter.notifyDataSetChanged();
                                    repliesRef
                                            .whereEqualTo("ownerId", signedInUser)
                                            .get()
                                            .addOnSuccessListener(new OnSuccessListener<QuerySnapshot>() {
                                                @Override
                                                public void onSuccess(QuerySnapshot queryDocumentSnapshots) {
                                                    int numberOfReplies = 0;
                                                    for (QueryDocumentSnapshot qc : queryDocumentSnapshots) {
                                                        numberOfReplies++;
                                                    }

                                                    if (numberOfReplies == 0) {
                                                        db.collection("Posts").document(documentId)
                                                                .update(
                                                                        "replyCount", FieldValue.increment(-1),
                                                                        "replies", FieldValue.arrayRemove(signedInUser)
                                                                );

                                                        FirebaseMessaging.getInstance().unsubscribeFromTopic(documentId); // PUT THIS INSIDE THE FOR LOOP OF THE RETURN FIRST DOCS && INIT NOTIFICATIONS

                                                    } else {
                                                        db.collection("Posts").document(documentId)
                                                                .update(
                                                                        "replyCount", FieldValue.increment(-1)
                                                                );
                                                    }

                                                }
                                            }).addOnFailureListener(new OnFailureListener() {
                                        @Override
                                        public void onFailure(@NonNull Exception e) {
                                        }
                                    });

                                }
                            });
                }

                dialog.dismiss();
                Toast.makeText(context, "Post removed", Toast.LENGTH_LONG);
            }
        });

        builder.setNegativeButton("NO", new DialogInterface.OnClickListener() {

            @Override
            public void onClick(DialogInterface dialog, int which) {
                dialog.dismiss();
            }
        });

        AlertDialog alert = builder.create();
        alert.show();

    }

    private void reportPost(final String signedInUser, final String id, final Context context, final String documentId, final CollectionReference repliesRef, final int position) {

        //final Boolean flag = false;
        AlertDialog.Builder builder = new AlertDialog.Builder(context);
        builder.setTitle("Confirm");
        builder.setMessage("Are you sure you want to report this post?");

        builder.setPositiveButton("YES", new DialogInterface.OnClickListener() {

            public void onClick(DialogInterface dialog, int which) {
                if (position == 0) {
                    db.collection("Posts").document(documentId)
                            .update(
                                    "reports", FieldValue.arrayUnion(signedInUser)
                            );
                } else {
                    repliesRef.document(id)
                            .update(
                                    "reports", FieldValue.arrayUnion(signedInUser)
                            );
                }
                dialog.dismiss();
                Toast.makeText(context, "Report has been filled", Toast.LENGTH_LONG);
            }
        });

        builder.setNegativeButton("NO", new DialogInterface.OnClickListener() {

            @Override
            public void onClick(DialogInterface dialog, int which) {
                dialog.dismiss();
            }
        });

        AlertDialog alert = builder.create();
        alert.show();

    }

    public void reportAndDeleteReplies(final String signedInUser, final String id, final Context context, final String documentId, final CollectionReference repliesRef, final int position, final String ownerId, final String text) {
        //final Boolean flag = false;
        AlertDialog.Builder builder = new AlertDialog.Builder(context);
        builder.setTitle("Confirm");
        builder.setMessage("Are you sure you want to report this post?");

        builder.setPositiveButton("YES", new DialogInterface.OnClickListener() {

            public void onClick(DialogInterface dialog, int which) {
                if (position == 0) {
                    db.collection("Posts").document(documentId)
                            .update(
                                    "reports", FieldValue.arrayUnion(signedInUser)
                            );
                } else {

                    CollectionReference reportRef = db.collection("Reports");
                    Map<String, Object> data = new HashMap<>();
                    data.put("ownerId", ownerId);
                    data.put("text", text);
                    data.put("type", "original");

                    reportRef.add(data);
                    repliesRef.document(id).delete();
                }
                dialog.dismiss();
                Toast.makeText(context, "Report has been filled", Toast.LENGTH_LONG);
            }
        });

        builder.setNegativeButton("NO", new DialogInterface.OnClickListener() {

            @Override
            public void onClick(DialogInterface dialog, int which) {
                dialog.dismiss();
            }
        });

        AlertDialog alert = builder.create();
        alert.show();
    }


    @Override
    public int getItemCount() {
        return noteList.size();
    }


    public class ItemViewHolder extends RecyclerView.ViewHolder {
        ImageView profilePic;
        TextView userName;
        TextView post;
        TextView time;
        TextView likes;
        TextView reply;
        ImageView tripleDots;
        ImageView heart;

        public ItemViewHolder(View v) {
            super(v);
            profilePic = v.findViewById(R.id.profilePic);
            userName = v.findViewById(R.id.userName);
            post = v.findViewById(R.id.post);
            time = v.findViewById(R.id.time);
            tripleDots = v.findViewById(R.id.tripleDot);
            heart = v.findViewById(R.id.heart);
            likes = v.findViewById(R.id.likes);
            reply = v.findViewById(R.id.REPLY);
        }
    }

    @Override
    public int getItemViewType(int position) {
        if (position == 0) {
            return FIRST_ITEM;
        }
        return REST;
    }

}
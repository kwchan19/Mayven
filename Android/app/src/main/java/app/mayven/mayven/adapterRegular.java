package app.mayven.mayven;

import android.app.ActionBar;
import android.app.Dialog;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
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
import androidx.recyclerview.widget.RecyclerView;

import com.bumptech.glide.Glide;
import com.bumptech.glide.request.RequestOptions;

import app.mayven.mayven.R;

import com.bumptech.glide.signature.ObjectKey;
import com.google.android.gms.ads.formats.NativeAd;
import com.google.android.gms.ads.formats.UnifiedNativeAd;
import com.google.android.gms.ads.formats.UnifiedNativeAdView;
import com.google.android.gms.tasks.OnCompleteListener;
import com.google.android.gms.tasks.OnSuccessListener;
import com.google.android.gms.tasks.Task;
import com.google.firebase.firestore.CollectionReference;
import com.google.firebase.firestore.DocumentSnapshot;
import com.google.firebase.firestore.FieldValue;
import com.google.firebase.firestore.FirebaseFirestore;
import com.google.firebase.messaging.FirebaseMessaging;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.concurrent.TimeUnit;

public class adapterRegular extends RecyclerView.Adapter<RecyclerView.ViewHolder> {

    private static final int MENU_ITEM_VIEW_TYPE = 0;
    private static final int UNIFIED_NATIVE_AD_VIEW_TYPE = 1;
    private static final int TYPE_LOADING = 2;
    private Boolean isLoader = false;

    private FirebaseFirestore db = FirebaseFirestore.getInstance();
    private CollectionReference postRef = db.collection("Posts");
    private CollectionReference userRef = db.collection("Users");


    private Dialog dialog;

    // An Activity's Context.
    private final Context mContext;

    private Context context;
    public static List<Object> noteList;

    public void setData(List<Note> note) {
        this.noteList.addAll(note);
        notifyDataSetChanged();
    }

    public void addItem(List<Object> note) {
        noteList.addAll(note);
        notifyDataSetChanged();
    }

    public void setAds(List<UnifiedNativeAd> ads) {
        this.noteList.addAll(ads);
    }

    public adapterRegular(Context context, List<Object> recyclerViewItems) {
        this.mContext = context;
        this.noteList = recyclerViewItems;
    }

    public class MenuItemViewHolder extends RecyclerView.ViewHolder {
        private TextView userName;
        private TextView post;
        private TextView REPLY;
        private TextView likes;
        private TextView time;
        private ImageView heart;
        private de.hdodenhof.circleimageview.CircleImageView profilePic;
        private ImageView tripleDot;

        MenuItemViewHolder(View view) {
            super(view);
            userName = (TextView) view.findViewById(R.id.userName);
            post = (TextView) view.findViewById(R.id.post);
            REPLY = (TextView) view.findViewById(R.id.REPLY);
            likes = (TextView) view.findViewById(R.id.likes);
            time = (TextView) view.findViewById(R.id.time);
            profilePic = (de.hdodenhof.circleimageview.CircleImageView) view.findViewById(R.id.profilePic);
            tripleDot = (ImageView) view.findViewById(R.id.tripleDot);
            heart = (ImageView) view.findViewById(R.id.heart);
        }

    }
    /*
    public class LoadingBar  extends RecyclerView.ViewHolder {
        private ProgressBar progressBar;
        public LoadingBar(@NonNull View itemView) {
            super(itemView);
            progressBar = (ProgressBar) itemView.findViewById(R.id.progressBar);
        }
    }

     */

    @Override
    public void onBindViewHolder(@NonNull RecyclerView.ViewHolder holder, final int position) {
        RegisterUsername reg = new RegisterUsername();
        List<userDB> qwe = reg.readData();

        final String signedInUser = qwe.get(0).username;
        final String classOf = qwe.get(0).classOf;

        int viewType = getItemViewType(position);
        switch (viewType) {
            case UNIFIED_NATIVE_AD_VIEW_TYPE:
                UnifiedNativeAd nativeAd = (UnifiedNativeAd) noteList.get(position);
                populateNativeAdView(nativeAd, ((UnifiedNativeAdViewHolder) holder).getAdView());
                break;
            case MENU_ITEM_VIEW_TYPE:
                // fall through
            default:
                final MenuItemViewHolder menuItemHolder = (MenuItemViewHolder) holder;
                final Note menuItem = (Note) noteList.get(position);


                // Get the menu item image resource ID.
                //  String imageName = menuItem.getImageName();
                // int imageResID = mContext.getResources().getIdentifier(imageName, "drawable", mContext.getPackageName());
                // Add the menu item details to the menu item view.
                //     menuItemHolder.menuItemImage.setImageResource(imageResID);

                final String numberOfLikes = String.valueOf(menuItem.getLikes());

                boolean flag = false;
                List<String> test = menuItem.getUsersLiked();
                for (int y = 0; y < test.size(); y++) {
                    if (test.get(y).equals(signedInUser)) {
                        flag = true;
                        break;
                    }
                }
                if (flag == true) {
                    menuItemHolder.heart.setImageResource(R.drawable.ic_heart_fill);
                    menuItemHolder.heart.setTag(2);
                } else {
                    menuItemHolder.heart.setImageResource(R.drawable.ic_heart);
                    menuItemHolder.heart.setTag(1);
                }

                final String documentId = menuItem.getDocumentId();

                menuItemHolder.heart.setOnClickListener(new View.OnClickListener() {
                    @Override
                    public void onClick(View v) {
                        String timeStamp = String.valueOf(TimeUnit.MILLISECONDS.toSeconds(System.currentTimeMillis()));
                        final int dateNow = Integer.parseInt(timeStamp);
                        Map<String, Object> toAdd = new HashMap<>();
                        int num = (int) menuItemHolder.heart.getTag();
                        List<String> test = menuItem.getUsersLiked();
                        if (num == 1) {
                            menuItemHolder.heart.setImageResource(R.drawable.ic_heart_fill);
                            test.add(signedInUser);
                            toAdd.put("usersLiked", test);
                            db.collection("Posts").document(documentId)
                                    .update(
                                            "usersLiked", test,
                                            "likes", FieldValue.increment(1),
                                            "lastAction", "likes",
                                            "lastActionTime", dateNow
                                    );

                            String likes = String.valueOf(menuItem.getLikes() + 1);
                            menuItemHolder.likes.setText(likes);
                            menuItem.likes += 1;
                            menuItemHolder.heart.setTag(2);
                        } else {
                            menuItemHolder.heart.setImageResource(R.drawable.ic_heart);
                            menuItemHolder.heart.setTag(1);
                            test.remove(signedInUser);
                            toAdd.put("usersLiked", test);
                            db.collection("Posts").document(documentId)
                                    .update(
                                            "likes", FieldValue.increment(-1)
                                            , "usersLiked", test
                                    );

                            String likes = String.valueOf(menuItem.getLikes() - 1);
                            menuItemHolder.likes.setText(likes);
                            menuItem.likes -= 1;
                        }
                    }
                });

                menuItemHolder.userName.setText(menuItem.getOwnerName());
                //menuItemHolder.REPLY.setText(menuItem.getReplyCount() + " replies");
                if (menuItem.getReplyCount() == 1) {
                    menuItemHolder.REPLY.setText(menuItem.getReplyCount() + " reply");
                } else {
                    menuItemHolder.REPLY.setText(menuItem.getReplyCount() + " replies");
                }

                menuItemHolder.time.setText(menuItem.getTime());
                menuItemHolder.post.setText(menuItem.getPost());
                menuItemHolder.likes.setText(numberOfLikes);

                String imgurl = "https://firebasestorage.googleapis.com/v0/b/chatapp-6d978.appspot.com/o/Thumbnail%2F" + menuItem.getId() + ".jpeg?alt=media";

                ChatGroupArray chatGroupArray = new ChatGroupArray();
                final String ts = String.valueOf(chatGroupArray.imageTime);

                Glide.with(menuItemHolder.profilePic.getContext()).load(imgurl)
                        .dontAnimate()
                        .placeholder(R.drawable.placeholder)
                        .signature(new ObjectKey(ts))
                        //  .error(R.drawable.ic_person_fill)
                        .into(menuItemHolder.profilePic);

                menuItemHolder.itemView.setOnClickListener(new View.OnClickListener() {
                    @Override
                    public void onClick(View view) {
                        //whatever you want here
                        AppCompatActivity activity = (AppCompatActivity) view.getContext();
                        activity.getSupportFragmentManager().beginTransaction().replace(R.id.container, new HomeReplies(menuItem.getReplyCount()
                                , menuItem.getPost(), menuItem.getOwnerName(), menuItem.getImageURL(), menuItem.getDocumentId(), menuItem.getId(), menuItem.getTime2(), menuItem.getUsersLiked(), menuItem.getLikes(), position, menuItem.getreplies(), menuItem.getReports())).addToBackStack(null).commit();
                    }
                });

                menuItemHolder.tripleDot.setOnClickListener(new View.OnClickListener() {
                    @Override
                    public void onClick(View v) {
                        final PopupMenu popup = new PopupMenu(mContext, menuItemHolder.tripleDot);
                        Menu menu = popup.getMenu();
                        popup.inflate(R.menu.menu_remove_report);

                        if (signedInUser.equals(menuItem.getId())) {
                            menu.findItem(R.id.report).setVisible(false);

                        } else {
                            menu.findItem(R.id.remove).setVisible(false);
                        }

                        popup.setOnMenuItemClickListener(new PopupMenu.OnMenuItemClickListener() {
                            @Override
                            public boolean onMenuItemClick(MenuItem item) {
                                switch (item.getItemId()) {
                                    case R.id.remove:
                                        removePost(mContext, menuItem.getDocumentId(), position);
                                        break;
                                    case R.id.report:

                                        if (menuItem.getReports().size() + 1 >= 5) { // report and delete
                                            reportAndDeletePost(menuItem.getId(), mContext, menuItem.getDocumentId(), menuItem.getPost());
                                            noteList.remove(position);
                                            HomeFragment.adapter.notifyDataSetChanged();
                                        } else {
                                            reportPost(menuItem.getId(), mContext, menuItem.getDocumentId());
                                        }
                                }
                                return false;
                            }
                        });
                        popup.show();
                    }
                });

                dialog = new Dialog(mContext);
                dialog.setContentView(R.layout.dialog_image);
                dialog.getWindow().setBackgroundDrawable(new ColorDrawable(Color.TRANSPARENT));

                WindowManager.LayoutParams params = dialog.getWindow().getAttributes();

                params.width = ActionBar.LayoutParams.MATCH_PARENT;
                params.gravity = Gravity.BOTTOM;

                dialog.getWindow().setAttributes(params);

                menuItemHolder.profilePic.setOnClickListener(new View.OnClickListener() {
                    @Override
                    public void onClick(View v) {

                        db.collection("Users").document(menuItem.ownerId).get().addOnCompleteListener(new OnCompleteListener<DocumentSnapshot>() {
                            @Override
                            public void onComplete(@NonNull Task<DocumentSnapshot> task) {
                                if (task.isSuccessful()) {

                                    DocumentSnapshot ds = task.getResult();

                                    try {
                                        //  Block of code to try

                                        //  Block of code to try
                                        TextView dialogName = dialog.findViewById(R.id.name);
                                        TextView dialogDesc = dialog.findViewById(R.id.desc);
                                        ImageView dialogPic = dialog.findViewById(R.id.profilePic);
                                        final ImageView dialogTripledot = dialog.findViewById(R.id.tripleDot);
                                        TextView programName = dialog.findViewById(R.id.programName);
                                        //TextView classOf = dialog.findViewById(R.id.classOf);
                                        TextView classOfDesc = dialog.findViewById(R.id.classOfDesc);

                                        dialogName.setText(menuItem.getOwnerName());
                                        dialogDesc.setText(menuItem.ownerId);
                                        programName.setText((String) ds.getString("programName"));

                                        if (signedInUser.equals(menuItem.getId())) {
                                            dialogTripledot.setVisibility(View.GONE);
                                        }
                                        else {
                                            dialogTripledot.setVisibility(View.VISIBLE);
                                        }
                                        dialogTripledot.setOnClickListener(new View.OnClickListener() {
                                            @Override
                                            public void onClick(View v) {
                                                final PopupMenu popup = new PopupMenu(mContext, dialogTripledot);
                                                Menu menu = popup.getMenu();
                                                popup.inflate(R.menu.menu_block);

                                                popup.setOnMenuItemClickListener(new PopupMenu.OnMenuItemClickListener() {
                                                    @Override
                                                    public boolean onMenuItemClick(MenuItem item) {
                                                        switch (item.getItemId()) {
                                                            case R.id.blockUser:
                                                                blockUser(signedInUser, menuItem.getId(), dialog);
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

                                        String imgurl = "https://firebasestorage.googleapis.com/v0/b/chatapp-6d978.appspot.com/o/" + menuItem.getId() + ".jpeg?alt=media";

                                        Glide.with(dialogPic.getContext()).load(imgurl)
                                                .dontAnimate()
                                                .apply(RequestOptions.circleCropTransform())
                                                .signature(new ObjectKey(ts))
                                                .into(dialogPic);

                                        dialog.show();

                                    }
                                    catch(Exception e) {
                                        //  Block of code to handle errors
                                        Toast.makeText(mContext,"This user has been deleted",Toast.LENGTH_SHORT).show();
                                    }


                                }else {
                                    Toast.makeText(mContext,"This user has been deleted",Toast.LENGTH_SHORT).show();
                                }
                            }
                        });
                    }
                });


                //     MainActivity activity = (MainActivity) context;
                //    activity.mProgressDialog.dismiss();
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

    @NonNull
    @Override
    public RecyclerView.ViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        switch (viewType) {
            case UNIFIED_NATIVE_AD_VIEW_TYPE:
                View unifiedNativeLayoutView = LayoutInflater.from(
                        parent.getContext()).inflate(R.layout.native_ads,
                        parent, false);
                return new UnifiedNativeAdViewHolder(unifiedNativeLayoutView);
            case MENU_ITEM_VIEW_TYPE:
                // Fall through.
                /*
            case TYPE_LOADING:
               View loader = LayoutInflater.from(
                       parent.getContext()).inflate(R.layout.native_ads,
                       parent, false);
               return new LoadingBar(loader);

                 */
            default:
                View menuItemLayoutView = LayoutInflater.from(parent.getContext())
                        .inflate(R.layout.list_row, parent, false);
                return new MenuItemViewHolder(menuItemLayoutView);
        }
    }

    @Override
    public int getItemCount() {
        return noteList == null ? 0 : noteList.size();
    }

    public static int returnCount() {
        return noteList == null ? 0 : noteList.size();
    }

    public void addLoading() {
        isLoader = true;
        noteList.add(new Note());
        notifyItemInserted(noteList.size() - 1);
    }

    public void removeLoading() {
        isLoader = false;
        int position = noteList.size() - 1;
        Note note = (Note) getItems(position);
        if (note != null) {
            noteList.remove(position);
            notifyItemRemoved(position);
        }
    }

    public void clear() {
        noteList.clear();
        notifyDataSetChanged();
    }


    private void populateNativeAdView(UnifiedNativeAd nativeAd,
                                      UnifiedNativeAdView adView) {
        // Some assets are guaranteed to be in every UnifiedNativeAd.
        ((TextView) adView.getHeadlineView()).setText(nativeAd.getHeadline());
        ((TextView) adView.getBodyView()).setText(nativeAd.getBody());

        // These assets aren't guaranteed to be in every UnifiedNativeAd, so it's important to
        // check before trying to display them.
        NativeAd.Image icon = nativeAd.getIcon();

        if (icon == null) {
            adView.getIconView().setVisibility(View.INVISIBLE);
        } else {
            ((de.hdodenhof.circleimageview.CircleImageView) adView.getIconView()).setImageDrawable(icon.getDrawable());
            adView.getIconView().setVisibility(View.VISIBLE);
        }


        if (nativeAd.getAdvertiser() == null) {
            adView.getAdvertiserView().setVisibility(View.INVISIBLE);
        } else {
            ((TextView) adView.getAdvertiserView()).setText(nativeAd.getAdvertiser());
            adView.getAdvertiserView().setVisibility(View.VISIBLE);
        }

        // Assign native ad object to the native view.
        adView.setNativeAd(nativeAd);
    }

    @Override
    public int getItemViewType(int position) {
        Object recyclerViewItem = noteList.get(position);
        if (recyclerViewItem instanceof UnifiedNativeAd) {
            return UNIFIED_NATIVE_AD_VIEW_TYPE;
        }
        if (isLoader) {
            return position == noteList.size() - 1 ? TYPE_LOADING : MENU_ITEM_VIEW_TYPE;
        }
        return MENU_ITEM_VIEW_TYPE;
    }

    Note getItems(int position) {
        return (Note) noteList.get(position);
    }

    public void reportAndDeletePost(final String ownerId, Context context, final String did, final String text) {
        AlertDialog.Builder builder = new AlertDialog.Builder(context);

        builder.setTitle("Confirm");
        builder.setMessage("Are you sure you want to report?");

        builder.setPositiveButton("YES", new DialogInterface.OnClickListener() {

            public void onClick(DialogInterface dialog, int which) {


                CollectionReference reportRef = db.collection("Reports");
                Map<String, Object> data = new HashMap<>();
                data.put("ownerId", ownerId);
                data.put("text", text);
                data.put("type", "original");

                reportRef.add(data);
                postRef.document(did).delete();
                dialog.dismiss();
                Toast.makeText(mContext, "Report has been filled", Toast.LENGTH_LONG);
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

    public void reportPost(final String signedInUser, Context context, final String did) {
        AlertDialog.Builder builder = new AlertDialog.Builder(context);

        builder.setTitle("Confirm");
        builder.setMessage("Are you sure you want to report?");

        builder.setPositiveButton("YES", new DialogInterface.OnClickListener() {

            public void onClick(DialogInterface dialog, int which) {


                postRef.document(did)
                        .update(
                                "reports", FieldValue.arrayUnion(signedInUser)
                        );


                dialog.dismiss();
                Toast.makeText(mContext, "Report has been filled", Toast.LENGTH_LONG);
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


    private void removePost(Context context, final String did, final int position) {

        AlertDialog.Builder builder = new AlertDialog.Builder(context);

        builder.setTitle("Confirm");
        builder.setMessage("Are you sure you want to remove post?");

        builder.setPositiveButton("YES", new DialogInterface.OnClickListener() {

            public void onClick(DialogInterface dialog, int which) {
                postRef.document(did)
                        .delete()
                        .addOnSuccessListener(new OnSuccessListener<Void>() {
                            @Override
                            public void onSuccess(Void aVoid) {

                                FirebaseMessaging.getInstance().unsubscribeFromTopic(did);
                                noteList.remove(position);
                                if (noteList.size() == 0) {
                                    HomeFragment.isEmpty.setVisibility(View.VISIBLE);
                                }
                                HomeFragment.adapter.notifyDataSetChanged();
                                FirebaseMessaging.getInstance().unsubscribeFromTopic(did);
                            }
                        });

                dialog.dismiss();
                Toast.makeText(mContext, "Post removed", Toast.LENGTH_LONG);
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

}
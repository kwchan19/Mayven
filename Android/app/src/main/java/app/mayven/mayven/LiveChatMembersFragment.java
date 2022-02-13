package app.mayven.mayven;

import android.Manifest;
import android.app.Activity;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.graphics.Bitmap;
import android.net.Uri;
import android.os.Bundle;
import android.provider.MediaStore;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ArrayAdapter;
import android.widget.ImageView;
import android.widget.ListView;
import android.widget.PopupMenu;
import android.widget.TextView;
import android.widget.Toast;

import androidx.annotation.NonNull;
import androidx.appcompat.app.AlertDialog;
import androidx.appcompat.app.AppCompatActivity;
import androidx.core.app.ActivityCompat;
import androidx.fragment.app.Fragment;
import androidx.fragment.app.FragmentManager;

import com.bumptech.glide.Glide;
import com.bumptech.glide.request.RequestOptions;

import app.mayven.mayven.R;

import com.bumptech.glide.signature.ObjectKey;
import com.google.android.gms.tasks.OnCompleteListener;
import com.google.android.gms.tasks.OnFailureListener;
import com.google.android.gms.tasks.OnSuccessListener;
import com.google.android.gms.tasks.Task;
import com.google.firebase.database.DataSnapshot;
import com.google.firebase.database.DatabaseReference;
import com.google.firebase.database.FirebaseDatabase;
import com.google.firebase.database.Query;
import com.google.firebase.firestore.CollectionReference;
import com.google.firebase.firestore.DocumentSnapshot;
import com.google.firebase.firestore.FieldValue;
import com.google.firebase.firestore.FirebaseFirestore;
import com.google.firebase.storage.FirebaseStorage;
import com.google.firebase.storage.StorageReference;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

public class LiveChatMembersFragment extends Fragment {
    private static final int SELECT_IMAGE = 1;


    private FirebaseFirestore db = FirebaseFirestore.getInstance();
    private CollectionReference chatGroups = db.collection("ChatGroups");
    private DatabaseReference RTDNotifications = FirebaseDatabase.getInstance().getReference("Notifications");

    private String groupName, groupOwnerName;
    public static ArrayList<groupMembers> users;

    //Activity mActivity;
    public static String groupToDelete = "";

    private TextView textgname;
    private ImageView textgimage;
    private ImageView plus;
    private ImageView backbutton;
    private ImageView tripleDot, addImageButton;

    public static ListView listView;
    private int STORAGE_PERMISSION_CODE = 1;

    public static Boolean isYes = false;
    public static Boolean isTrue;
    public static String groupId;
    public static ArrayAdapter<groupMembers> saveAdapter;
    //private Boolean test = false;


    public LiveChatMembersFragment() {
        //keep
    }

    public LiveChatMembersFragment(ArrayList<groupMembers> obj, String gid, String gname, Boolean isTrue) {
        // Required empty public constructor
        users = obj;
        groupId = gid;
        groupName = gname;
        this.isTrue = isTrue;
    }


    /*
     // TODO: Rename and change types and number of parameters
     public static LiveChatMembersFragment newInstance(String param1, String param2) {
         LiveChatMembersFragment fragment = new LiveChatMembersFragment();
         Bundle args = new Bundle();
         args.putString(ARG_PARAM1, param1);
         args.putString(ARG_PARAM2, param2);
         fragment.setArguments(args);
         return fragment;
     }

     */
    @Override
    public void onDetach() {
        super.onDetach();
        final ChatGroupArray chatGroupArray = new ChatGroupArray();
        chatGroupArray.setKICK(false);
    }

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {

        View v = inflater.inflate(R.layout.fragment_live_chat_members, container, false);

        final ChatGroupArray chatGroupArray = new ChatGroupArray();
        chatGroupArray.setKICK(true);

        textgname = v.findViewById(R.id.groupName);
        listView = v.findViewById(R.id.recycle);
        addImageButton = v.findViewById(R.id.addImageButton);
        textgimage = v.findViewById(R.id.groupPic);
        textgname.setText(groupName);


        backbutton = v.findViewById(R.id.back);
        backbutton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                FragmentManager fm = getFragmentManager();
                fm.popBackStack();
                chatGroupArray.setKICK(false);
            }
        });

        RegisterUsername reg = new RegisterUsername();
        List<userDB> qwe = reg.readData();
        final String school = qwe.get(0).school;
        final String programCode = qwe.get(0).programCode;
        final String classOf = qwe.get(0).classOf;

        final String signedInUser = qwe.get(0).username;

        plus = v.findViewById(R.id.add_members);

        final ArrayList<String> admins = new ArrayList<>();


        for (groupMembers i : users) {
            if (i.isAdmin()) {
                admins.add(i.getName());
            }
        }
        if (!admins.contains(signedInUser)) {
            plus.setVisibility(View.INVISIBLE);
            addImageButton.setVisibility(View.INVISIBLE);
            textgimage.setEnabled(false);
        }
        plus.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                Bundle bundle = new Bundle();
                bundle.putString("gid", groupId);

                add_livechat_member adding_post = new add_livechat_member();
                adding_post.setArguments(bundle);

                assert getFragmentManager() != null;
                adding_post.show(getFragmentManager(), "Test");

            }
        });


        Log.d("test", "" + users);

        String imgurl = "https://firebasestorage.googleapis.com/v0/b/chatapp-6d978.appspot.com/o/ChatGroups%2F" + groupId + ".jpeg?alt=media";
        Log.d("IMGURL", "SAOKMDSAPODMSAOPD MSAPD = " + imgurl);

        final String ts = String.valueOf(chatGroupArray.imageTime);

        Glide.with(textgimage.getContext()).load(imgurl)
                .signature(new ObjectKey(ts))
                .placeholder(R.drawable.placeholder)
                .error(R.drawable.groupimage)
                .into(textgimage);



        saveAdapter = new groupMembersAdapter(getActivity(), users, groupId, isTrue);
        listView.setAdapter(saveAdapter);

        tripleDot = v.findViewById(R.id.tripleDot);


        chatGroups.document(groupId).get().addOnCompleteListener(new OnCompleteListener<DocumentSnapshot>() {
            @Override
            public void onComplete(@NonNull Task<DocumentSnapshot> task) {
                DocumentSnapshot dc = task.getResult();
                groupOwnerName = dc.getString("ownerId");
            }
        });

        String docchatName = school + "-" + programCode + "-" + classOf;

        if(groupId.equals(docchatName)) {
            tripleDot.setVisibility(View.INVISIBLE);
        }

        tripleDot.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {


                final PopupMenu popup = new PopupMenu(getContext(), tripleDot);
                Menu menu = popup.getMenu();
                popup.inflate(R.menu.menu_delete_group);

                Log.d("CUNT", "group owner = " + groupOwnerName);
                if (signedInUser.equals(groupOwnerName)) {
                    menu.findItem(R.id.leaveGroup).setVisible(false);
                } else {
                    menu.findItem(R.id.deleteGroup).setVisible(false);
                }

                popup.setOnMenuItemClickListener(new PopupMenu.OnMenuItemClickListener() {
                    @Override
                    public boolean onMenuItemClick(MenuItem item) {
                        switch (item.getItemId()) {
                            case R.id.deleteGroup:
                                ChatGroupArray chatGroupArray = new ChatGroupArray();
                                //chatGroupArray.isTransaction = true;
                                removeGroup(getContext(), signedInUser, groupId);
                                FirebaseDatabase.getInstance().getReference().child("ChatLogs").child(groupId).removeValue();

                                break;
                            case R.id.leaveGroup:
                                userLeave(getContext(), signedInUser, groupId);
                        }
                        return false;
                    }
                });
                popup.show();
            }
        });

        textgimage.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (ActivityCompat.checkSelfPermission(getContext(), Manifest.permission.READ_EXTERNAL_STORAGE) == PackageManager.PERMISSION_GRANTED) {
                    Intent intent = new Intent();
                    intent.setType("image/*");
                    intent.setAction(Intent.ACTION_GET_CONTENT);
                    startActivityForResult(Intent.createChooser(intent, "Select Picture"), SELECT_IMAGE);
                }else {
                    requeststorangepermission();
                }
            }
        });

        return v;
    }

    public void onActivityResult(int requestCode, int resultCode, Intent data) {
        super.onActivityResult(requestCode, resultCode, data);
        if (requestCode == SELECT_IMAGE) {
            if (resultCode == Activity.RESULT_OK) {
                Log.d("ACC", "started WITH OK");
                if (data != null) {
                    try {
                        AccountFragment acc = new AccountFragment();

                        final Uri uri = data.getData();

                        Bitmap bitmap = MediaStore.Images.Media.getBitmap(getActivity().getContentResolver(), data.getData());
                        ByteArrayOutputStream baos = new ByteArrayOutputStream();
                        bitmap = acc.resize(bitmap, 300, 300);
                        bitmap.compress(Bitmap.CompressFormat.JPEG, 95, baos);
                        byte[] compressed = baos.toByteArray();

                        ChatGroupArray chatGroupArray = new ChatGroupArray();
                        String ts = String.valueOf(chatGroupArray.imageTime);

                        Glide.with(textgimage.getContext()).load(uri)
                                .dontAnimate()
                                .error(R.drawable.groupimage)
                                .placeholder(R.drawable.placeholder)
                                .signature(new ObjectKey(ts))
                                .apply(RequestOptions.circleCropTransform())
                                .into(textgimage);

                        final StorageReference storageReference = FirebaseStorage.getInstance().getReference().child("ChatGroups/").child(groupId + ".jpeg");
                        final StorageReference thumbNail = FirebaseStorage.getInstance().getReference().child("ChatGroups/").child("Thumbnail/").child(groupId + ".jpeg");

                        assert uri != null;

                        storageReference.putBytes(compressed).addOnFailureListener(new OnFailureListener() {
                            @Override
                            public void onFailure(@NonNull Exception e) {
                                Toast.makeText(getContext(), "Can't change image at this time.", Toast.LENGTH_SHORT).show();
                            }
                        });

                        ByteArrayOutputStream baos2 = new ByteArrayOutputStream();
                        //Bitmap bMapScaled = Bitmap.createScaledBitmap(bitmap, 125, 125, true);
                        Bitmap bMapScaled = acc.resize(bitmap, 125, 125);
                        bMapScaled.compress(Bitmap.CompressFormat.JPEG, 55, baos2);
                        byte[] thumb = baos2.toByteArray();

                        thumbNail.putBytes(thumb).addOnFailureListener(new OnFailureListener() {
                            @Override
                            public void onFailure(@NonNull Exception e) {
                                Toast.makeText(getContext(), "Can't change image at this time.", Toast.LENGTH_SHORT).show();
                            }
                        });

                    } catch (IOException e) {
                        e.printStackTrace();
                    }
                }
            } else if (resultCode == Activity.RESULT_CANCELED) {
                Log.d("ACC", "Cancled");
            }
        }
    }


    private void removeYourself(final String signedInUser, final String groupId) {
        final ChatGroupArray chatGroupArray = new ChatGroupArray();
        Query q = FirebaseDatabase.getInstance().getReference().child("Notifications").orderByChild("parentUser").equalTo(signedInUser);
        q.get().addOnCompleteListener(new OnCompleteListener<DataSnapshot>() {
            @Override
            public void onComplete(@NonNull Task<DataSnapshot> task) {
                if (task.isSuccessful()) {
                    for (final DataSnapshot imageSnapshot : task.getResult().getChildren()) {
                        final String gName = (String) imageSnapshot.child("gName").getValue();
                        String parentUser = (String) imageSnapshot.child("parentUser").getValue();
                        if (gName.equals(groupId)) {
                            DatabaseReference rs = imageSnapshot.getRef();
                            rs.removeValue();

                            //  FragmentManager fragmentManager = ((AppCompatActivity)context).getSupportFragmentManager();
                            //   fragmentManager.popBackStack(fragmentManager.getBackStackEntryAt(fragmentManager.getBackStackEntryCount()-2).getId(), FragmentManager.POP_BACK_STACK_INCLUSIVE);
                        }
                    }
                } else {
                    Log.d("LiveMem", "error getting query");
                }
            }
        });

    }

    private void userLeave(final Context context, final String signedInUser, final String groupId) {
        AlertDialog.Builder builder = new AlertDialog.Builder(context);
        final ChatGroupArray chatGroupArray = new ChatGroupArray();
        chatGroupArray.isTransaction = false;

        builder.setTitle("Confirm");
        builder.setMessage("Are you sure you want to leave this chat?");

        builder.setPositiveButton("YES", new DialogInterface.OnClickListener() {

            public void onClick(DialogInterface dialog, int which) {
                chatGroups.document(groupId).update(
                        "members", FieldValue.arrayRemove(signedInUser)
                );

                Query q = FirebaseDatabase.getInstance().getReference().child("Notifications").orderByChild("parentUser").equalTo(signedInUser);
                q.get().addOnCompleteListener(new OnCompleteListener<DataSnapshot>() {
                    @Override
                    public void onComplete(@NonNull Task<DataSnapshot> task) {
                        if (task.isSuccessful()) {
                            for (final DataSnapshot imageSnapshot : task.getResult().getChildren()) {
                                final String gName = (String) imageSnapshot.child("gName").getValue();
                                String parentUser = (String) imageSnapshot.child("parentUser").getValue();
                                if (gName.equals(groupId)) {
                                    DatabaseReference rs = imageSnapshot.getRef();
                                    rs.removeValue();

                                    FragmentManager fragmentManager = ((AppCompatActivity) context).getSupportFragmentManager();
                                    fragmentManager.popBackStack(fragmentManager.getBackStackEntryAt(fragmentManager.getBackStackEntryCount() - 2).getId(), FragmentManager.POP_BACK_STACK_INCLUSIVE);
                                }
                            }
                        } else {
                            Log.d("LiveMem", "error getting query");
                        }
                    }
                });
                dialog.dismiss();
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

    private void removeGroup(final Context context, final String signedInUser, final String groupId) {
        final ChatGroupArray chatGroupArray = new ChatGroupArray();

        String name;
        AlertDialog.Builder builder = new AlertDialog.Builder(context);

        builder.setTitle("Confirm");
        builder.setMessage("Are you sure you want to delete this chat?");

        builder.setPositiveButton("YES", new DialogInterface.OnClickListener() {

            public void onClick(DialogInterface dialog, int which) {


                //     removeEveryone(signedInUser, groupId);
                //   removeYourself(signedInUser, groupId);
                chatGroupArray.isTransaction = true;

                Query q = FirebaseDatabase.getInstance().getReference().child("Notifications").orderByChild("gName").equalTo(groupId);
                q.get().addOnCompleteListener(new OnCompleteListener<DataSnapshot>() {
                    @Override
                    public void onComplete(@NonNull Task<DataSnapshot> task) {
                        if (task.isSuccessful()) {
                            for (final DataSnapshot i : task.getResult().getChildren()) {
                                String parentUser = (String) i.child("parentUser").getValue();
                                String gName = (String) i.child("gName").getValue();

                                i.getRef().removeValue();
                                // }
                            }
                            Log.d("CUNT69", "removeEveryone #2");
                        } else {
                            Log.d("LiveMem", "error getting query");
                        }
                    }
                });


                chatGroups.document(groupId).delete().addOnSuccessListener(new OnSuccessListener<Void>() {
                    @Override
                    public void onSuccess(Void aVoid) {

                    }
                });

                int index = 0;
                for (Group gr : chatGroupArray.GroupSave) {
                    if (gr.getDocId().equals(groupId)) {
                        chatGroupArray.GroupSave.remove(index);
                        Log.d("1234", "removed array at index");
                        chatFragment fragment = new chatFragment();
                        ArrayAdapter<Group> newAdapter = new groupAdapter(getContext(), chatGroupArray.GroupSave);
                        fragment.listView.setAdapter(newAdapter);
                        fragment.listView.invalidateViews();
                        break;
                    }

                    index++;
                }
                chatFragment fragment = new chatFragment();
                fragment.listView.invalidateViews();
                //fragment.listView.setAdapter(newAdapter);

                final StorageReference storageReference = FirebaseStorage.getInstance().getReference().child("ChatGroups/").child(groupId + ".jpeg");
                final StorageReference thumbNail = FirebaseStorage.getInstance().getReference().child("ChatGroups/").child("Thumbnail/").child(groupId + ".jpeg");

                storageReference.delete().addOnSuccessListener(new OnSuccessListener<Void>() {
                    @Override
                    public void onSuccess(Void aVoid) {
                        Log.d("1234", "main image has been deleted chat");
                    }
                });
                thumbNail.delete().addOnSuccessListener(new OnSuccessListener<Void>() {
                    @Override
                    public void onSuccess(Void aVoid) {
                        Log.d("1234", "thumbnail deleted");
                    }
                });


                FragmentManager fragmentManager = ((AppCompatActivity) context).getSupportFragmentManager();
                fragmentManager.popBackStack(fragmentManager.getBackStackEntryAt(fragmentManager.getBackStackEntryCount() - 2).getId(), FragmentManager.POP_BACK_STACK_INCLUSIVE);


                dialog.dismiss();
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

    public void removeEveryone(final String username, final String groupId) {
        Log.d("CUNT69", "removeEveryone #1");
        final ChatGroupArray chatGroupArray = new ChatGroupArray();

    }


    public void deleteArray(int position, ArrayList<groupMembers> list) {
        Log.d("1122", "" + users);
        final ChatGroupArray chatGroupArray = new ChatGroupArray();
        //  chatGroupArray.GroupSave.clear();
        chatGroupArray.members = list;

        users.remove(position);

        ((groupMembersAdapter) listView.getAdapter()).notifyDataSetChanged();
    }
    private void requeststorangepermission() {
        if (ActivityCompat.shouldShowRequestPermissionRationale(getActivity(), Manifest.permission.READ_EXTERNAL_STORAGE)){
            AlertDialog.Builder builder = new AlertDialog.Builder(getContext());

            builder.setTitle("Confirm");
            builder.setMessage("Enable image permissions to change your image");

            builder.setPositiveButton("YES", new DialogInterface.OnClickListener() {
                public void onClick(DialogInterface dialog, int which) {
                    ActivityCompat.requestPermissions(getActivity(),new String[] {Manifest.permission.READ_EXTERNAL_STORAGE},STORAGE_PERMISSION_CODE);
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

        }else {
            ActivityCompat.requestPermissions(getActivity(),new String[] {Manifest.permission.READ_EXTERNAL_STORAGE},STORAGE_PERMISSION_CODE);
        }
    }

}

package app.mayven.mayven;

import android.Manifest;
import android.app.Activity;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.graphics.Bitmap;
import android.graphics.drawable.Drawable;
import android.net.Uri;
import android.os.Bundle;
import android.provider.MediaStore;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.Toast;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.appcompat.app.AlertDialog;
import androidx.core.app.ActivityCompat;

import com.bumptech.glide.Glide;
import com.bumptech.glide.request.RequestOptions;
import app.mayven.mayven.R;

import com.bumptech.glide.signature.ObjectKey;
import com.google.android.gms.tasks.OnCompleteListener;
import com.google.android.gms.tasks.Task;
import com.google.android.material.bottomsheet.BottomSheetDialogFragment;
import com.google.firebase.database.DatabaseReference;
import com.google.firebase.database.FirebaseDatabase;
import com.google.firebase.firestore.CollectionReference;
import com.google.firebase.firestore.DocumentReference;
import com.google.firebase.firestore.FirebaseFirestore;
import com.google.firebase.storage.FirebaseStorage;
import com.google.firebase.storage.StorageReference;
import com.google.firebase.storage.UploadTask;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.concurrent.TimeUnit;

import static app.mayven.mayven.RegisterUsername.drawableToBitmap;

public class Adding_Chat_Group extends BottomSheetDialogFragment {
    private byte[] compressed = new byte[10];
    private byte[] thumb = new byte[10];

    private FirebaseFirestore db = FirebaseFirestore.getInstance();
    private CollectionReference chatLogsRef = db.collection("ChatGroups");

    private DatabaseReference RTDChatLogs = FirebaseDatabase.getInstance().getReference("ChatLogs");
    private DatabaseReference RTDNotifications = FirebaseDatabase.getInstance().getReference("Notifications");

    private String compressedFinalImage;
    private String compressedFinalThumb;
    private String id;

    private List<String> admins = new ArrayList<String>();

    private static final int SELECT_IMAGE = 1;
    private int STORAGE_PERMISSION_CODE = 1;

    private Button add;
    private EditText groupname;
    private ImageView pic;

    private Boolean flag = false;

    @Nullable
    @Override
    public View onCreateView(@NonNull LayoutInflater inflater, @Nullable ViewGroup container, @Nullable Bundle savedInstanceState) {
        View v = inflater.inflate(R.layout.add_new_group_chat, container, false);

        //DatabaseReference ref = RTDNotifications.push();

        //ref.child("test-sub2").setValue("yes");

        RegisterUsername reg = new RegisterUsername();
        List<userDB> qwe = reg.readData();
        final String signedInUser = qwe.get(0).username;


        add = v.findViewById(R.id.btn_send);
        groupname = v.findViewById(R.id.msg_input);
        pic = v.findViewById(R.id.profilePic);

        String imgurl = "https://firebasestorage.googleapis.com/v0/b/chatapp-6d978.appspot.com/o/" + "empty" + ".jpeg?alt=media";

        Log.d("IMAGEURL","Compressed =  \n" + compressed);
        Log.d("IMAGEURL","thumb =  \n" + thumb);


        Glide.with(pic.getContext()).load(imgurl)
                .dontAnimate()
                .placeholder(R.mipmap.ic_group_round)
                .error(R.mipmap.ic_group_round)
                .apply(RequestOptions.circleCropTransform())
                .into(pic);

        pic.setOnClickListener(new View.OnClickListener() {
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


        add.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                flag = false;
                if(groupname.getText().toString().trim().matches("") || groupname.getText().toString().trim().length() < 4){
                    flag = true;
                }

                if (!flag) {
                    final String timeStamp = String.valueOf(TimeUnit.MILLISECONDS.toSeconds(System.currentTimeMillis()));
                    final Long dateNow = Long.parseLong(timeStamp);
                    final String nameOfNewGroup = groupname.getText().toString();

                    admins.add(signedInUser);

                    Map<String, Object> toAdd = new HashMap<>();
                    toAdd.put("admins", admins);
                    toAdd.put("members", admins);
                    toAdd.put("name", nameOfNewGroup);
                    toAdd.put("ownerId", signedInUser);


                    AccountFragment accF = new AccountFragment();

                    int rid = R.drawable.groupimage;
                    Drawable drawable = getResources().getDrawable(rid);

                    Bitmap bitmap = drawableToBitmap(drawable);

                    ByteArrayOutputStream baos = new ByteArrayOutputStream();
                    bitmap = accF.resize(bitmap, 300, 300);
                    bitmap.compress(Bitmap.CompressFormat.JPEG, 95, baos);
                    compressed = baos.toByteArray();


                    ByteArrayOutputStream baos2 = new ByteArrayOutputStream();
                    //Bitmap bMapScaled = Bitmap.createScaledBitmap(bitmap, 125, 125, true);
                    Bitmap bMapScaled = accF.resize(bitmap, 125, 125);
                    bMapScaled.compress(Bitmap.CompressFormat.JPEG, 55, baos2);
                    thumb = baos2.toByteArray();


                    chatLogsRef.add(toAdd).addOnCompleteListener(new OnCompleteListener<DocumentReference>() {
                        @Override
                        public void onComplete(@NonNull Task<DocumentReference> task) {
                            DocumentReference document = task.getResult();
                            Log.d("add", "id = " + document.getId());
                            id = document.getId();

                            DatabaseReference ref = RTDNotifications.push();
                            String postId = ref.getKey();

                            Map<String, Object> RTDN = new HashMap<>();

                            RTDN.put("gName", id);
                            RTDN.put("lastMessage", signedInUser + " created this group");
                            RTDN.put("lastUser", signedInUser);
                            RTDN.put("parentUser", signedInUser);
                            RTDN.put("timestamp", dateNow);
                            RTDN.put("unseenMessage", 0);

                            RTDNotifications.child(postId).updateChildren(RTDN);


                            final StorageReference storageReference = FirebaseStorage.getInstance().getReference().child("ChatGroups/").child(id + ".jpeg");
                            final StorageReference thumbNail = FirebaseStorage.getInstance().getReference().child("ChatGroups/").child("Thumbnail/").child(id + ".jpeg");

                            storageReference.putBytes(compressed).addOnCompleteListener(new OnCompleteListener<UploadTask.TaskSnapshot>() {
                                @Override
                                public void onComplete(@NonNull Task<UploadTask.TaskSnapshot> task) {
                                    Log.d("add", "SMALLER DONE");
                                    storageReference.getDownloadUrl().addOnCompleteListener(new OnCompleteListener<Uri>() {
                                        @Override
                                        public void onComplete(@NonNull Task<Uri> task) {
                                            Uri uri = task.getResult();
                                            compressedFinalImage = uri.toString();
                                            Log.d("add", "image uri = \n " + compressedFinalImage);
                                        }
                                    });
                                }
                            });

                            thumbNail.putBytes(thumb).addOnCompleteListener(new OnCompleteListener<UploadTask.TaskSnapshot>() {
                                @Override
                                public void onComplete(@NonNull Task<UploadTask.TaskSnapshot> task) {
                                    thumbNail.getDownloadUrl().addOnCompleteListener(new OnCompleteListener<Uri>() {
                                        @Override
                                        public void onComplete(@NonNull Task<Uri> task) {
                                            Uri uri = task.getResult();
                                            compressedFinalThumb = uri.toString();
                                            Log.d("add", "thumb uri = \n " + compressedFinalThumb);
                                        }
                                    });
                                }
                            });
                        }
                    });
                    dismiss();
                } else {
                    Toast.makeText(getContext(),"The group name must be 4 characters or greater", Toast.LENGTH_SHORT).show();
                }
            }
        });

        return v;
    }

    private void requeststorangepermission() {
        if (ActivityCompat.shouldShowRequestPermissionRationale(getActivity(),Manifest.permission.READ_EXTERNAL_STORAGE)){
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

    public void onActivityResult(int requestCode, int resultCode, Intent data) {
        super.onActivityResult(requestCode, resultCode, data);
        if (requestCode == SELECT_IMAGE) {
            if (resultCode == Activity.RESULT_OK) {
                Log.d("ACC", "started WITH OK");
                if (data != null) {
                    try {
                        AccountFragment accF = new AccountFragment();

                        final Uri uri = data.getData();

                        Bitmap bitmap = MediaStore.Images.Media.getBitmap(getActivity().getContentResolver(), data.getData());
                        ByteArrayOutputStream baos = new ByteArrayOutputStream();
                        bitmap = accF.resize(bitmap, 300, 300);
                        bitmap.compress(Bitmap.CompressFormat.JPEG, 95, baos);
                        compressed = baos.toByteArray();

                        ByteArrayOutputStream baos2 = new ByteArrayOutputStream();
                        //Bitmap bMapScaled = Bitmap.createScaledBitmap(bitmap, 125, 125, true);
                        Bitmap bMapScaled = accF.resize(bitmap, 125, 125);
                        bMapScaled.compress(Bitmap.CompressFormat.JPEG, 55, baos2);
                        thumb = baos2.toByteArray();

                        ChatGroupArray chatGroupArray = new ChatGroupArray();
                        String ts = String.valueOf(chatGroupArray.imageTime);

                        Glide.with(pic.getContext()).load(uri)
                                .placeholder(R.drawable.initial_pic)
                                .dontAnimate()
                                .signature(new ObjectKey(ts))
                                .error(R.drawable.initial_pic)
                                .apply(RequestOptions.circleCropTransform())
                                .into(pic);
                        flag = true;

                    } catch (IOException e) {
                        e.printStackTrace();
                    }
                }
            } else if (resultCode == Activity.RESULT_CANCELED) {
                Log.d("ACC", "Cancled");
            }
        }
    }

}
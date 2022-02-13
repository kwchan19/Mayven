package app.mayven.mayven;

import android.Manifest;
import android.annotation.SuppressLint;
import android.app.Activity;
import android.app.Dialog;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.graphics.Bitmap;
import android.graphics.Color;
import android.net.Uri;
import android.os.Bundle;

import androidx.annotation.NonNull;
import androidx.appcompat.app.AlertDialog;
import androidx.core.app.ActivityCompat;
import androidx.fragment.app.Fragment;

import android.provider.MediaStore;
import android.text.SpannableString;
import android.text.style.ForegroundColorSpan;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.Menu;
import android.view.MenuInflater;
import android.view.MenuItem;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Adapter;
import android.widget.Button;
import android.widget.ImageView;
import android.widget.ListAdapter;
import android.widget.ListView;
import android.widget.PopupMenu;
import android.widget.TextView;
import android.widget.Toast;

import com.bumptech.glide.Glide;
import com.bumptech.glide.request.RequestOptions;

import app.mayven.mayven.R;

import com.bumptech.glide.signature.ObjectKey;
import com.google.android.gms.tasks.OnCompleteListener;
import com.google.android.gms.tasks.Task;
import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.auth.FirebaseUser;
import com.google.firebase.database.DataSnapshot;
import com.google.firebase.database.FirebaseDatabase;
import com.google.firebase.database.Query;
import com.google.firebase.firestore.CollectionReference;
import com.google.firebase.firestore.FieldValue;
import com.google.firebase.firestore.FirebaseFirestore;
import com.google.firebase.firestore.QueryDocumentSnapshot;
import com.google.firebase.firestore.QuerySnapshot;
import com.google.firebase.firestore.WriteBatch;
import com.google.firebase.messaging.FirebaseMessaging;
import com.google.firebase.storage.FirebaseStorage;
import com.google.firebase.storage.StorageReference;
import com.google.firebase.storage.UploadTask;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.util.List;


public class AccountFragment extends Fragment {
    private static final String TAG = "AccountFragment";
    private static final int PICK_FROM_GALLERY = 1;
    private int STORAGE_PERMISSION_CODE = 1;

    private FirebaseFirestore db = FirebaseFirestore.getInstance();
    private CollectionReference userRef = db.collection("Users");
    private CollectionReference chatGroupsRef = db.collection("ChatGroups");


    private Button signOut;
    private ImageView profilePic;
    private ImageView settingButton;
    private TextView name;
    private TextView desc;
    private TextView id;
    private TextView year;
    private Button aboutUs;

    private static final int SELECT_IMAGE = 1;
    private String compressedFinalImage;
    Activity mActivity;

    @Override
    public void onAttach(Context context) {
        super.onAttach(context);

        if (context instanceof Activity) {
            mActivity = (Activity) context;
        }
    }

    @Override
    public void onDetach() {
        super.onDetach();
        mActivity = null;
    }


    public AccountFragment() {
        // Required empty public constructor
    }

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {
        // Inflate the layout for this fragment
        View v = inflater.inflate(R.layout.fragment_account, container, false);

        RegisterUsername reg = new RegisterUsername();
        List<userDB> qwe = reg.readData();
        final String signedInUser = qwe.get(0).username;
        final String signedInName = qwe.get(0).name;
        final String signedInUsername = qwe.get(0).username;
        final String signedInProgram = qwe.get(0).programName;
        final String classOf = qwe.get(0).classOf;
        final String email = qwe.get(0).email;

        signOut = v.findViewById(R.id.signOut);
        profilePic = v.findViewById(R.id.profilePic);
        name = v.findViewById(R.id.name);
        desc = v.findViewById(R.id.desc);
        id = v.findViewById(R.id.id);
        year = v.findViewById(R.id.classOfDesc);

        aboutUs = v.findViewById(R.id.aboutUs);

        aboutUs.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                Intent Getintent = new Intent(Intent.ACTION_VIEW, Uri.parse("https://mayven.app/#about"));
                startActivity(Getintent);
            }
        });

        settingButton = v.findViewById(R.id.settingButton);
        settingButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                final PopupMenu popup = new PopupMenu(getContext(), settingButton);
                Menu menu = popup.getMenu();
                popup.inflate(R.menu.menu_account);

                popup.setOnMenuItemClickListener(new PopupMenu.OnMenuItemClickListener() {
                    @Override
                    public boolean onMenuItemClick(MenuItem item) {
                        switch (item.getItemId()) {
                            case R.id.resetP:
                                ResetPassword(email);
                                break;
                            case R.id.changeName:
                                ChangeName();
                                break;
                            case R.id.listBlock:
                                listBlock(signedInUser);
                                break;
                            case R.id.deleteUser:
                                deleteUser(signedInUser, email);
                                break;
                        }
                        return false;
                    }
                });
                popup.show();
            }
        });


        signOut.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                MainActivity main = new MainActivity();
                ChatGroupArray chatGroupArray = new ChatGroupArray();

                if (main.chatListen != null) {
                    main.chatListen.removeEventListener(main.childEventListener);
                }

                if (main.notificationListen != null) {
                    main.notificationListen.remove();
                }

                if (main.disabledListener != null) {
                    main.disabledListener.remove();
                }

                for (int i = 0; i < chatGroupArray.cloudNotifications.size(); i++) {
                    FirebaseMessaging.getInstance().unsubscribeFromTopic(chatGroupArray.cloudNotifications.get(i));
                }

                chatGroupArray.notificationArr.clear();
                chatGroupArray.chatNotifications.clear();
                chatGroupArray.groupArr.clear();
                chatGroupArray.GroupSave.clear();
                chatGroupArray.context = null;
                chatGroupArray.groupId.clear();
                chatGroupArray.groupName.clear();
                chatGroupArray.members.clear();
                chatGroupArray.mRecyclerViewItems.clear();
                chatGroupArray.lastResult = null;
                chatGroupArray.refreshChat = true;
                chatGroupArray.isTransaction = false;
                chatGroupArray.lastTimestamp = 0;
                chatGroupArray.getBlockedUsers().clear();


                RegisterUsername reg = new RegisterUsername();
                reg.deleteData();

                FirebaseAuth.getInstance().signOut();
                startActivity(new Intent(mActivity, init.class));
                getActivity().finish();
            }
        });


        String imgurl = "https://firebasestorage.googleapis.com/v0/b/chatapp-6d978.appspot.com/o/" + signedInUser + ".jpeg?alt=media";

        ChatGroupArray chatGroupArray = new ChatGroupArray();
        String ts = String.valueOf(chatGroupArray.imageTime);

        Glide.with(profilePic.getContext()).load(imgurl)
                .dontAnimate()
                .placeholder(R.drawable.placeholder)
                .apply(RequestOptions.circleCropTransform())
                .signature(new ObjectKey(ts))
                .error(R.drawable.initial_pic)
                .into(profilePic);
        name.setText(signedInName);
        desc.setText(signedInProgram);
        id.setText(signedInUsername);
        year.setText(classOf);


        profilePic.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (ActivityCompat.checkSelfPermission(getContext(), Manifest.permission.READ_EXTERNAL_STORAGE) == PackageManager.PERMISSION_GRANTED) {
                    Intent intent = new Intent();
                    intent.setType("image/*");
                    intent.setAction(Intent.ACTION_GET_CONTENT);
                    startActivityForResult(Intent.createChooser(intent, "Select Picture"), SELECT_IMAGE);
                } else {
                    requeststorangepermission();
                }
            }
        });


        return v;
    }

    private void deleteUser(final String signedinuser, String email) {
        //final Boolean flag = false;
        AlertDialog.Builder builder = new AlertDialog.Builder(getContext());
        builder.setTitle("Confirm");
        builder.setMessage("Are you sure you want to delete the account?");

        builder.setPositiveButton("YES", new DialogInterface.OnClickListener() {

            public void onClick(DialogInterface dialog, int which) {

                final ChatGroupArray chatGroupArray = new ChatGroupArray();
                userRef.document(signedinuser).delete();
                chatGroupsRef.whereArrayContains("members", signedinuser)
                        .get().addOnCompleteListener(new OnCompleteListener<QuerySnapshot>() {
                    @Override
                    public void onComplete(@NonNull Task<QuerySnapshot> task) {
                        for (QueryDocumentSnapshot queryDocumentSnapshots : task.getResult()) {
                            if (queryDocumentSnapshots.getString("ownerId").equals(signedinuser)) {
                                chatGroupsRef.document(queryDocumentSnapshots.getId()).delete();
                                final StorageReference storageReference = FirebaseStorage.getInstance().getReference().child("ChatGroups/").child(queryDocumentSnapshots.getId() + ".jpeg");
                                final StorageReference thumbNail = FirebaseStorage.getInstance().getReference().child("ChatGroups/").child("Thumbnail/").child(queryDocumentSnapshots.getId() + ".jpeg");

                                final StorageReference userimage = FirebaseStorage.getInstance().getReference().child(signedinuser + ".jpeg");
                                final StorageReference userimagethumb = FirebaseStorage.getInstance().getReference().child("Thumbnail/").child(signedinuser + ".jpeg");

                                userimagethumb.delete();
                                userimage.delete();
                                storageReference.delete();
                                thumbNail.delete();
                            } else {
                                chatGroupsRef.document(queryDocumentSnapshots.getId()).update(
                                        "members", FieldValue.arrayRemove(signedinuser),
                                        "admins", FieldValue.arrayRemove(signedinuser)
                                );
                            }
                        }
                        Query q = FirebaseDatabase.getInstance().getReference().child("Notifications").orderByChild("parentUser").equalTo(signedinuser);
                        q.get().addOnCompleteListener(new OnCompleteListener<DataSnapshot>() {
                            @Override
                            public void onComplete(@NonNull Task<DataSnapshot> task) {
                                if (task.isSuccessful()) {
                                    for (final DataSnapshot i : task.getResult().getChildren()) {
                                        i.getRef().removeValue();
                                    }
                                }
                            }
                        });
                        FirebaseUser user = FirebaseAuth.getInstance().getCurrentUser();
                        user.delete()
                                .addOnCompleteListener(new OnCompleteListener<Void>() {
                                    @Override
                                    public void onComplete(@NonNull Task<Void> task) {
                                        if (task.isSuccessful()) {

                                            RegisterUsername reg = new RegisterUsername();
                                            reg.deleteData();
                                            FirebaseAuth.getInstance().signOut();
                                            startActivity(new Intent(getActivity(),init.class));
                                            Toast.makeText(getContext(),"User has been deleted",Toast.LENGTH_SHORT).show();
                                        }
                                    }
                                });
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

    private void listBlock(String signedInUser) {
        BlockedFragment adding_post = new BlockedFragment();
        assert getFragmentManager() != null;
        adding_post.show(getFragmentManager(), "Test");

    }

    private void requeststorangepermission() {
        if (ActivityCompat.shouldShowRequestPermissionRationale(getActivity(), Manifest.permission.READ_EXTERNAL_STORAGE)) {
            AlertDialog.Builder builder = new AlertDialog.Builder(getContext());

            builder.setTitle("Confirm");
            builder.setMessage("Enable image permissions to change your image");

            builder.setPositiveButton("YES", new DialogInterface.OnClickListener() {
                public void onClick(DialogInterface dialog, int which) {
                    ActivityCompat.requestPermissions(getActivity(), new String[]{Manifest.permission.READ_EXTERNAL_STORAGE}, STORAGE_PERMISSION_CODE);
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

        } else {
            ActivityCompat.requestPermissions(getActivity(), new String[]{Manifest.permission.READ_EXTERNAL_STORAGE}, STORAGE_PERMISSION_CODE);
        }
    }


    private void ResetPassword(final String email) {
        //final Boolean flag = false;
        AlertDialog.Builder builder = new AlertDialog.Builder(getContext());
        builder.setTitle("Confirm");
        builder.setMessage("Are you sure you want to send verification email?");

        builder.setPositiveButton("YES", new DialogInterface.OnClickListener() {

            public void onClick(DialogInterface dialog, int which) {
                FirebaseAuth.getInstance().sendPasswordResetEmail(email)
                        .addOnCompleteListener(new OnCompleteListener<Void>() {
                            @Override
                            public void onComplete(@NonNull Task<Void> task) {
                                if (task.isSuccessful()) {
                                    Toast.makeText(getContext(), "Reset email sent", Toast.LENGTH_LONG);
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

    private void ChangeName() {
        Changing_Name cn = new Changing_Name();
        assert getFragmentManager() != null;
        cn.show(getFragmentManager(), "Test");
    }


    @SuppressLint("WrongConstant")
    @Override
    public void onRequestPermissionsResult(int requestCode, @NonNull String permissions[], @NonNull int[] grantResults) {
        if (requestCode == STORAGE_PERMISSION_CODE) {
            if (grantResults.length > 0 && grantResults[0] == PackageManager.PERMISSION_GRANTED) {
                Toast.makeText(getContext(), "Permission granted", Toast.LENGTH_LONG).show();
            } else {
                Toast.makeText(getContext(), "Permission denied", Toast.LENGTH_LONG).show();
            }
        }

    }


    public void onActivityResult(int requestCode, int resultCode, Intent data) {
        super.onActivityResult(requestCode, resultCode, data);
        if (requestCode == SELECT_IMAGE) {
            if (resultCode == Activity.RESULT_OK) {

                if (data != null) {
                    try {
                        RegisterUsername reg = new RegisterUsername();
                        List<userDB> qwe = reg.readData();
                        final String signedInUser = qwe.get(0).username;

                        final Uri uri = data.getData();

                        Bitmap bitmap = MediaStore.Images.Media.getBitmap(mActivity.getContentResolver(), data.getData());
                        ByteArrayOutputStream baos = new ByteArrayOutputStream();
                        bitmap = resize(bitmap, 300, 300);
                        bitmap.compress(Bitmap.CompressFormat.JPEG, 95, baos);
                        byte[] compressed = baos.toByteArray();

                        Glide.with(profilePic.getContext()).load(uri)
                                .dontAnimate()
                                .error(R.drawable.initial_pic)
                                .apply(RequestOptions.circleCropTransform())
                                .into(profilePic);

                        final StorageReference storageReference = FirebaseStorage.getInstance().getReference().child(signedInUser + ".jpeg");
                        final StorageReference thumbNail = FirebaseStorage.getInstance().getReference().child("Thumbnail/").child(signedInUser + ".jpeg");

                        assert uri != null;

                        storageReference.putBytes(compressed).addOnCompleteListener(new OnCompleteListener<UploadTask.TaskSnapshot>() {
                            @Override
                            public void onComplete(@NonNull Task<UploadTask.TaskSnapshot> task) {
                                storageReference.getDownloadUrl().addOnCompleteListener(new OnCompleteListener<Uri>() {
                                    @Override
                                    public void onComplete(@NonNull Task<Uri> task) {
                                        Uri uri = task.getResult();
                                        compressedFinalImage = uri.toString();
                                    }
                                });
                            }
                        });

                        ByteArrayOutputStream baos2 = new ByteArrayOutputStream();
                        //Bitmap bMapScaled = Bitmap.createScaledBitmap(bitmap, 125, 125, true);
                        Bitmap bMapScaled = resize(bitmap, 125, 125);
                        bMapScaled.compress(Bitmap.CompressFormat.JPEG, 55, baos2);
                        byte[] thumb = baos2.toByteArray();

                        thumbNail.putBytes(thumb).addOnCompleteListener(new OnCompleteListener<UploadTask.TaskSnapshot>() {
                            @Override
                            public void onComplete(@NonNull Task<UploadTask.TaskSnapshot> task) {
                                thumbNail.getDownloadUrl().addOnCompleteListener(new OnCompleteListener<Uri>() {
                                    @Override
                                    public void onComplete(@NonNull Task<Uri> task) {
                                        Uri uri = task.getResult();
                                        userRef.document(signedInUser).update(
                                                "imageURL", compressedFinalImage,
                                                "thumbnailURL", uri.toString()
                                        );
                                    }
                                });
                            }
                        });

                    } catch (IOException e) {
                        e.printStackTrace();
                    }
                }
            } else if (resultCode == Activity.RESULT_CANCELED) {
            }
        }
    }

/*
    public Bitmap getResizedBitmap(Bitmap bm, int newWidth, int newHeight) {
        int width = bm.getWidth();
        int height = bm.getHeight();
        float scaleWidth = ((float) newWidth) / width;
        float scaleHeight = ((float) newHeight) / height;
        // CREATE A MATRIX FOR THE MANIPULATION
        Matrix matrix = new Matrix();
        // RESIZE THE BIT MAP
        matrix.postScale(scaleWidth, scaleHeight);

        // "RECREATE" THE NEW BITMAP
        Bitmap resizedBitmap = Bitmap.createBitmap(
                bm, 0, 0, width, height, matrix, false);
        bm.recycle();
        return resizedBitmap;
    }
 */

    public static Bitmap resize(Bitmap image, int maxWidth, int maxHeight) {
        if (maxHeight > 0 && maxWidth > 0) {
            int width = image.getWidth();
            int height = image.getHeight();
            float ratioBitmap = (float) width / (float) height;
            float ratioMax = (float) maxWidth / (float) maxHeight;

            int finalWidth = maxWidth;
            int finalHeight = maxHeight;
            if (ratioMax > ratioBitmap) {
                finalWidth = (int) ((float) maxHeight * ratioBitmap);
            } else {
                finalHeight = (int) ((float) maxWidth / ratioBitmap);
            }
            image = Bitmap.createScaledBitmap(image, finalWidth, finalHeight, true);
            return image;
        } else {
            return image;
        }
    }
}

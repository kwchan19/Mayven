package app.mayven.mayven;

import androidx.annotation.NonNull;
import androidx.appcompat.app.AppCompatActivity;

import android.content.Intent;
import android.graphics.Bitmap;
import android.graphics.Canvas;
import android.graphics.drawable.BitmapDrawable;
import android.graphics.drawable.Drawable;
import android.os.Bundle;
import android.util.Log;
import android.view.View;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.TextView;
import android.widget.Toast;

import app.mayven.mayven.R;
import com.google.android.gms.tasks.OnCompleteListener;
import com.google.android.gms.tasks.Task;
import com.google.firebase.auth.AuthResult;
import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.database.DatabaseReference;
import com.google.firebase.database.FirebaseDatabase;
import com.google.firebase.firestore.CollectionReference;
import com.google.firebase.firestore.FieldValue;
import com.google.firebase.firestore.FirebaseFirestore;
import com.google.firebase.firestore.SetOptions;
import com.google.firebase.storage.FirebaseStorage;
import com.google.firebase.storage.StorageReference;
import com.google.firebase.storage.UploadTask;

import java.io.ByteArrayOutputStream;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.concurrent.TimeUnit;

import io.realm.Realm;
import io.realm.RealmConfiguration;
import io.realm.RealmResults;

public class RegisterUsername extends AppCompatActivity {
    private FirebaseFirestore db = FirebaseFirestore.getInstance();
    private CollectionReference userRef = db.collection("Users");
    private CollectionReference chatGroups = db.collection("ChatGroups");
    private DatabaseReference RTDNotifications = FirebaseDatabase.getInstance().getReference("Notifications");

    private EditText username, email, password, passwordConfirm;
    private Button register;
    private TextView schoolNameT;
    private ImageView noEmail, noPassword, noConfirm, backBtn;
    private Realm realmDB;
    private FirebaseAuth mAuth = FirebaseAuth.getInstance();

    private Boolean flag1 = false;
    private Boolean flag2 = false;
    private Boolean flag3 = false;
    private Boolean flag = false;

    public static Boolean onlyOnce = true;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_register_username);
        final String timeStamp = String.valueOf(TimeUnit.MILLISECONDS.toSeconds(System.currentTimeMillis()));


        Realm.init(this);

        final String schoolName = getIntent().getStringExtra("school");
        final String classOf = getIntent().getStringExtra("classOf");
        final String ownerId = getIntent().getStringExtra("ownerId");
        final String name = getIntent().getStringExtra("name");
        final String program = getIntent().getStringExtra("program");
        final String code = getIntent().getStringExtra("code");
        final String schoolId = getIntent().getStringExtra("schoolId");
        final String extension = getIntent().getStringExtra("extension");

        username = findViewById(R.id.username);
        password = findViewById(R.id.password);
        passwordConfirm = findViewById(R.id.passwordConfirm);
        email = findViewById(R.id.email);
        backBtn = findViewById(R.id.backBtn);

        schoolNameT = findViewById(R.id.schoolName);
        schoolNameT.setText(schoolName);

        noEmail = findViewById(R.id.noEmail);
        noPassword = findViewById(R.id.noPassword);
        noConfirm = findViewById(R.id.noConfirm);

        backBtn.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                finish();
            }
        });

        register = findViewById(R.id.register);
        register.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (onlyOnce == true) {
                    final int finalClassOf = Integer.valueOf(classOf) + 4;
                    final String finalStringClass = String.valueOf(finalClassOf);
                    final String timeStamp = String.valueOf(TimeUnit.MILLISECONDS.toSeconds(System.currentTimeMillis()));
                    final int dateNow = Integer.parseInt(timeStamp);
                    final String mPassword = password.getText().toString();
                    final String cPassword = passwordConfirm.getText().toString();
                    final String mEmail = email.getText().toString().trim();

                    try {
                        if (mEmail != null) {
                            String[] arrE = mEmail.split("@");
                            for (String i : arrE) {
                                if (i.equals(extension)) {
                                    flag1 = true;
                                }
                            }
                        }
                    } catch (Exception e) {
                        Toast.makeText(getApplicationContext(), "Enter a valid email", Toast.LENGTH_SHORT).show();
                    }

                    if (mPassword.matches(cPassword)) {
                        flag2 = true;
                    }
                    if (mPassword.length() >= 6 && cPassword.length() >= 6) {
                        flag3 = true;
                    }

                    if (!flag1) {
                        //noEmail.setVisibility(View.VISIBLE);
                        Toast.makeText(getApplicationContext(), "The only extensions allowed are " + extension, Toast.LENGTH_SHORT).show();
                    } else if (!flag2) {
                        Toast.makeText(getApplicationContext(), "Passwords are not the same", Toast.LENGTH_SHORT).show();
                    } else if (!flag3) {
                        Toast.makeText(getApplicationContext(), "Passwords length must be longer than 6 characters", Toast.LENGTH_SHORT).show();
                    }

                    if (flag1) {
                        noEmail.setVisibility(View.INVISIBLE);
                        if (flag2) {
                            noConfirm.setVisibility(View.INVISIBLE);
                            if (flag3) {
                                noPassword.setVisibility(View.INVISIBLE);
                                flag = true;
                            }
                        }
                    }
                    if (flag) {
                        mAuth.createUserWithEmailAndPassword(mEmail, mPassword).addOnCompleteListener(new OnCompleteListener<AuthResult>() {
                            @Override
                            public void onComplete(@NonNull Task<AuthResult> task) {
                                if (task.isSuccessful()) {
                                    mAuth.getCurrentUser().sendEmailVerification().addOnCompleteListener(new OnCompleteListener<Void>() {
                                        @Override
                                        public void onComplete(@NonNull Task<Void> task) {
                                            if (task.isSuccessful()) {
                                                onlyOnce = false;
                                                final Map<String, Object> tData = new HashMap<>();
                                                tData.put("name", name);
                                                tData.put("blockedUsers", Collections.emptyList());
                                                tData.put("classOf", classOf);
                                                tData.put("email", mEmail);
                                                tData.put("programCode", code);
                                                tData.put("programName", program);
                                                tData.put("school", schoolId);
                                                tData.put("schoolName", schoolName);
                                                tData.put("username", ownerId);
                                                tData.put("tos", false);
                                                tData.put("lastNotifications", 1);
                                                tData.put("lastTimestamp", dateNow);

                                                userRef.document(ownerId).set(tData);

                                                int rid = R.drawable.initial_pic;
                                                int groupImage = R.drawable.groupimage;

                                                Drawable drawable = getResources().getDrawable(rid);
                                                Drawable gdraw = getResources().getDrawable(groupImage);

                                                Bitmap bitmap = drawableToBitmap(drawable);
                                                Bitmap gbitmap = drawableToBitmap(gdraw);

                                                ByteArrayOutputStream baos = new ByteArrayOutputStream();
                                                bitmap.compress(Bitmap.CompressFormat.JPEG, 100, baos);
                                                byte[] compressed = baos.toByteArray();

                                                ByteArrayOutputStream baos3 = new ByteArrayOutputStream();
                                                bitmap.compress(Bitmap.CompressFormat.JPEG, 55, baos3);
                                                byte[] thumbcompressed = baos3.toByteArray();

                                                ByteArrayOutputStream bao2 = new ByteArrayOutputStream();
                                                gbitmap.compress(Bitmap.CompressFormat.JPEG, 100, bao2);
                                                byte[] gcompressed = bao2.toByteArray();

                                                ByteArrayOutputStream baos4 = new ByteArrayOutputStream();
                                                gbitmap.compress(Bitmap.CompressFormat.JPEG, 55, baos4);
                                                byte[] tgcompressed = baos4.toByteArray();




                                                String docchatName = schoolId + "-" + code + "-" + finalStringClass;
                                                String cName = code + "-" + finalStringClass;
                                                Log.d("REG", "chat name = " + docchatName);

                                                final StorageReference storageReference = FirebaseStorage.getInstance().getReference().child(ownerId + ".jpeg");
                                                final StorageReference thumbnailstorage = FirebaseStorage.getInstance().getReference().child("Thumbnail/").child(ownerId + ".jpeg");

                                                final StorageReference chatGroupStorageRef = FirebaseStorage.getInstance().getReference().child("ChatGroups/").child(docchatName + ".jpeg");
                                                final StorageReference thumbNail = FirebaseStorage.getInstance().getReference().child("ChatGroups/").child("Thumbnail/").child(docchatName + ".jpeg");


                                                Map<String, Object> toAdd = new HashMap<>();
                                                toAdd.put("admins", Collections.emptyList());
                                                toAdd.put("members", FieldValue.arrayUnion(ownerId));
                                                toAdd.put("ownerId", "");
                                                toAdd.put("name", cName);

                                                chatGroups.document(docchatName).set(
                                                        toAdd, SetOptions.merge()
                                                );

                                                DatabaseReference ref = RTDNotifications.push();
                                                String postId = ref.getKey();
                                                Log.d("CUNT", "NAME = " + ownerId);

                                                Map<String, Object> RTDN = new HashMap<>();

                                                RTDN.put("gName", docchatName);
                                                RTDN.put("lastMessage", ownerId + " has joined the group");
                                                RTDN.put("lastUser", ownerId);
                                                RTDN.put("parentUser", ownerId);
                                                RTDN.put("timestamp", dateNow);
                                                RTDN.put("unseenMessage", 0);

                                                RTDNotifications.child(postId).updateChildren(RTDN);

                                                storageReference.putBytes(compressed).addOnCompleteListener(new OnCompleteListener<UploadTask.TaskSnapshot>() {
                                                    @Override
                                                    public void onComplete(@NonNull Task<UploadTask.TaskSnapshot> task) {
                                                        if (task.isSuccessful()) {
                                                            Log.d("REG", "IMAGE IN DB");
                                                        } else {
                                                            Log.d("REG", "IMAGE NOT IN DB");
                                                        }
                                                    }
                                                });
                                                thumbnailstorage.putBytes(thumbcompressed);
                                                chatGroupStorageRef.putBytes(gcompressed);
                                                thumbNail.putBytes(tgcompressed);

                                                RegisterUsername reg = new RegisterUsername();
                                                Intent intent = new Intent(getApplicationContext(), login.class);
                                                intent.putExtra("schoolName", schoolName);
                                                intent.putExtra("schoolId", schoolId);
                                                intent.putExtra("extension", extension);
                                                reg.deleteData();
                                                startActivity(intent);
                                                Toast.makeText(RegisterUsername.this, "Verify Email Before Logging In.", Toast.LENGTH_SHORT).show();
                                                finish();
                                                Intent finish_activity = new Intent("finish_first");
                                                sendBroadcast(finish_activity);
                                            } else {
                                                Toast.makeText(RegisterUsername.this, "Could Not Send Verification", Toast.LENGTH_SHORT).show();
                                            }
                                        }
                                    });
                                } else {
                                    Toast.makeText(RegisterUsername.this, "This email is already in use", Toast.LENGTH_SHORT).show();
                                }
                            }
                        });
                    }
                }
            }
        });
    }

    public void deleteData() {
        realmDB = Realm.getDefaultInstance();
        realmDB.beginTransaction();
        realmDB.deleteAll();
        realmDB.commitTransaction();
    }

    public void storeUserData(String login, final Map<String, String> data) {
        Log.d("REG", "Something has changed");
        realmDB = Realm.getDefaultInstance();
        realmDB.beginTransaction();
        userDB us = realmDB.createObject(userDB.class);
        //UserData us = new UserData();
        us.setName(data.get("name"));
        us.setClassOf(data.get("classOf"));
        us.setProgramName(data.get("programName"));
        us.setProgramCode(data.get("programCode"));
        us.setSchool(data.get("school"));
        us.setSchoolName(data.get("schoolName"));
        us.setUsername(data.get("username"));
        us.setEmail(data.get("email"));
        //   realmDB.beginTransaction();
        //  realmDB.copyToRealmOrUpdate(us);
        realmDB.commitTransaction();

        Log.d("REG", "updated realm");
        //   createUser(username.getText().toString(), data);
        List<userDB> test = readData();
        // startActivity(new Intent(getApplicationContext(), MainActivity.class));

    }

    public List<userDB> readData() {
        Realm.init(this);
        realmDB = Realm.getDefaultInstance();
        RealmResults<userDB> users = realmDB.where(userDB.class).findAll();
        List<userDB> usersList = realmDB.copyFromRealm(users);


        Log.d("RealmData", String.valueOf(usersList.get(0).name));
        Log.d("RealmData", String.valueOf(usersList.get(0).classOf));
        Log.d("RealmData", String.valueOf(usersList.get(0).school));
        Log.d("RealmData", String.valueOf(usersList.get(0).username));
        Log.d("RealmData", String.valueOf(usersList.get(0).email));
        Log.d("RealmData", String.valueOf(usersList.get(0).schoolName));


        return usersList;
    }

    public static Bitmap drawableToBitmap(Drawable drawable) {
        Bitmap bitmap = null;

        if (drawable instanceof BitmapDrawable) {
            BitmapDrawable bitmapDrawable = (BitmapDrawable) drawable;
            if (bitmapDrawable.getBitmap() != null) {
                return bitmapDrawable.getBitmap();
            }
        }

        if (drawable.getIntrinsicWidth() <= 0 || drawable.getIntrinsicHeight() <= 0) {
            bitmap = Bitmap.createBitmap(1, 1, Bitmap.Config.ARGB_8888); // Single color bitmap will be created of 1x1 pixel
        } else {
            bitmap = Bitmap.createBitmap(drawable.getIntrinsicWidth(), drawable.getIntrinsicHeight(), Bitmap.Config.ARGB_8888);
        }

        Canvas canvas = new Canvas(bitmap);
        drawable.setBounds(0, 0, canvas.getWidth(), canvas.getHeight());
        drawable.draw(canvas);
        return bitmap;
    }


}

class RealmUtility {
    private static final int SCHEMA_V_PREV = 1;// previous schema version
    private static final int SCHEMA_V_NOW = 2;// change schema version if any change happened in schema


    public static int getSchemaVNow() {
        return SCHEMA_V_PREV;
    }


    public static RealmConfiguration getDefaultConfig() {
        return new RealmConfiguration.Builder()
                .deleteRealmIfMigrationNeeded()// if migration needed then this methoud will remove the existing database and will create new database
                .build();
    }
}
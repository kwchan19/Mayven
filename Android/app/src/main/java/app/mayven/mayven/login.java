package app.mayven.mayven;

import android.content.Intent;
import android.os.Bundle;
import android.util.Log;
import android.view.View;
import android.widget.Button;
import android.widget.CheckBox;
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.TextView;
import android.widget.Toast;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.appcompat.app.AppCompatActivity;

import app.mayven.mayven.R;
import com.google.android.gms.tasks.OnCompleteListener;
import com.google.android.gms.tasks.Task;
import com.google.firebase.auth.AuthResult;
import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.firestore.CollectionReference;
import com.google.firebase.firestore.DocumentSnapshot;
import com.google.firebase.firestore.FirebaseFirestore;
import com.google.firebase.firestore.QueryDocumentSnapshot;
import com.google.firebase.firestore.QuerySnapshot;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class login extends AppCompatActivity {

    private EditText username;
    private TextView sName;
    private EditText password;
    private CheckBox remember;
    private Button login;

    private Button forgotPass;
    private ImageView backBtn;
    private FirebaseAuth mAuth;

    private FirebaseFirestore db = FirebaseFirestore.getInstance();
    private CollectionReference userRef = db.collection("Users");



    @Override
    public void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.loginpage);

        Intent intent = getIntent();
        final String schoolName = getIntent().getStringExtra("schoolName");
        final String extension = getIntent().getStringExtra("extension");

        username = findViewById(R.id.username);
        password = findViewById(R.id.password);
        login = findViewById(R.id.login);
        sName = findViewById(R.id.schoolName);
        forgotPass = findViewById(R.id.forgotPass);
        backBtn = findViewById(R.id.backBtn);

        forgotPass.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                startActivity(new Intent(getApplicationContext(), Forgot_Pass.class));
            }
        });

        sName.setText(schoolName);

        mAuth = FirebaseAuth.getInstance();

        backBtn.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                RegisterUsername reg = new RegisterUsername();
                reg.onlyOnce = true;
                finish();
            }
        });

        login.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                final String email = username.getText().toString().trim();
                final String pass = password.getText().toString();

                boolean flag = false;

                try {
                    if (email != null) {
                        String[] arrE = email.split("@");
                        for (String i : arrE) {
                            if (i.equals(extension)) {
                                flag = true;
                            }
                        }
                    }
                } catch (Exception e) {
                    Toast.makeText(getApplicationContext(), "Enter a valid email", Toast.LENGTH_SHORT).show();
                }

                String[] arrE = email.split("@");

                if (!email.equals("") && email.length() > 1 && email.contains("@")) {

                    if(password.length() != 0) {
                        if (flag == true) {

                            mAuth.signInWithEmailAndPassword(email, pass).addOnCompleteListener(new OnCompleteListener<AuthResult>() {
                                @Override
                                public void onComplete(@NonNull Task<AuthResult> task) {
                                    if (task.isSuccessful()) {
                                        userRef
                                                .whereEqualTo("email", email)
                                                .limit(1)
                                                .get().addOnCompleteListener(new OnCompleteListener<QuerySnapshot>() {
                                            @Override
                                            public void onComplete(@NonNull Task<QuerySnapshot> task) {
                                                if (task.isSuccessful()) {
                                                    if (mAuth.getCurrentUser().isEmailVerified()) {
                                                        RegisterUsername reg = new RegisterUsername();
                                                        int count = 1;
                                                        for (QueryDocumentSnapshot doc : task.getResult()) {
                                                            Map<String, String> newMap = new HashMap<String, String>();
                                                            for (Map.Entry<String, Object> entry : doc.getData().entrySet()) {
                                                                if (entry.getValue() instanceof String) {
                                                                    newMap.put(entry.getKey(), (String) entry.getValue());
                                                                }
                                                            }
                                                            if (count == task.getResult().size()) {
                                                                reg.storeUserData(email, newMap);
                                                                checkTOS();
                                                                Toast.makeText(login.this, "Signed in", Toast.LENGTH_SHORT).show();
                                                            }
                                                            count++;
                                                        }
                                                    } else {
                                                        Toast.makeText(login.this, "You have received a verification link in your email. Verify in order to login.", Toast.LENGTH_SHORT).show();
                                                    }
                                                }
                                            }
                                        });
                                    } else {
                                        Toast.makeText(login.this, "Username or password was incorrect. Please try again.", Toast.LENGTH_SHORT).show();
                                    }

                                }
                            });
                        } else {
                            Toast.makeText(login.this, "Please enter your school email", Toast.LENGTH_SHORT).show();
                        }
                    }
                    else {
                        Toast.makeText(login.this, "Please enter a valid password", Toast.LENGTH_SHORT).show();
                    }
                } else {
                    Toast.makeText(login.this, "Please enter a valid email", Toast.LENGTH_SHORT).show();
                }
            }

        });

    }
    private void checkTOS() {
        RegisterUsername reg = new RegisterUsername();
        List<userDB> qwe = reg.readData();
        final String signedInUsername = qwe.get(0).username;

        userRef.document(signedInUsername).get().addOnCompleteListener(new OnCompleteListener<DocumentSnapshot>() {
            @Override
            public void onComplete(@NonNull Task<DocumentSnapshot> task) {
                DocumentSnapshot document = task.getResult();

                Boolean b = (Boolean) document.get("tos");

                if (!b) {
                    startActivity(new Intent(getApplicationContext(), tos.class));
                }else{
                    startActivity(new Intent(getApplicationContext(), MainActivity.class));
                }
                finish();
            }
        });
    }
}
package app.mayven.mayven;

import androidx.annotation.NonNull;
import androidx.appcompat.app.AppCompatActivity;

import android.content.Intent;
import android.os.Bundle;
import android.os.Handler;
import android.util.Log;
import android.view.animation.Animation;
import android.widget.ImageView;
import android.widget.TextView;

import app.mayven.mayven.R;
import com.google.android.gms.tasks.OnCompleteListener;
import com.google.android.gms.tasks.Task;
import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.firestore.CollectionReference;
import com.google.firebase.firestore.DocumentSnapshot;
import com.google.firebase.firestore.FirebaseFirestore;

import java.util.List;
import java.util.Random;

public class LoadingScreen extends AppCompatActivity {
    private FirebaseFirestore db = FirebaseFirestore.getInstance();
    private CollectionReference userRef = db.collection("Users");

    private String signedInUsername;
    private Boolean flag = false;
    private Boolean b = true;

    Animation top_bottom,bottom_top;
    ImageView logo;
    TextView text;



    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        RegisterUsername reg = new RegisterUsername();

        try {
            List<userDB> qwe = reg.readData();
            signedInUsername = qwe.get(0).username;
            flag = true;
        }
        catch (Exception e){
            if(FirebaseAuth.getInstance().getCurrentUser() != null) {
                FirebaseAuth.getInstance().signOut();
                //Toast.makeText(getApplicationContext(), "Error getting data from phone", Toast.LENGTH_SHORT).show();
            }
        }

        if(flag == true){
            List<userDB> qwe = reg.readData();
            signedInUsername = qwe.get(0).username;
            userRef.document(signedInUsername).get().addOnCompleteListener(new OnCompleteListener<DocumentSnapshot>() {
                @Override
                public void onComplete(@NonNull Task<DocumentSnapshot> task) {
                    DocumentSnapshot document = task.getResult();

                    b = (Boolean) document.get("tos");
                }
            });
        }

        Random rand = new Random(); //instance of random class
        int min = 1200;
        int max = 1600;
        //generate random values from 0-24
        int random_int = (int)Math.floor(Math.random()*(max-min+1)+min);

        setContentView(R.layout.activity_loading_screen);
     //   top_bottom = AnimationUtils.loadAnimation(this,R.anim.top_bottom);
    //    bottom_top = AnimationUtils.loadAnimation(this,R.anim.bottom_top);

        logo = findViewById(R.id.logo);
    //    text = findViewById(R.id.text);

     //   logo.setAnimation(top_bottom);
   //     text.setAnimation(bottom_top);

        Handler handler = new Handler();
        Runnable runnable = new Runnable() {
            @Override
            public void run() {
                if(FirebaseAuth.getInstance().getCurrentUser() != null && FirebaseAuth.getInstance().getCurrentUser().isEmailVerified() && flag == true){
                    if(b == null){
                        FirebaseAuth.getInstance().signOut();
                        startActivity(new Intent(getApplicationContext(), init.class));
                    }
                    if (!b) {
                        startActivity(new Intent(getApplicationContext(), tos.class));
                    }else{
                        startActivity(new Intent(getApplicationContext(), MainActivity.class));
                    }
                    finish();
                }else{
                    startActivity(new Intent(getApplicationContext(), init.class));
                    finish();
                }
                finish();
            }
        };

        int TIMER_SPLASH = random_int;
        Log.d("random","random num");

        handler.postDelayed(runnable, TIMER_SPLASH);

    }



}
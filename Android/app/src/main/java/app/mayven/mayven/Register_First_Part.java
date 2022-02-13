package app.mayven.mayven;

import androidx.annotation.NonNull;
import androidx.appcompat.app.AppCompatActivity;
import androidx.core.content.ContextCompat;
import androidx.core.content.res.ResourcesCompat;

import android.annotation.SuppressLint;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.graphics.Typeface;
import android.os.Bundle;
import android.util.Log;
import android.view.View;
import android.widget.ArrayAdapter;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.RelativeLayout;
import android.widget.TextView;
import android.widget.Toast;

import app.mayven.mayven.R;
import com.google.android.gms.tasks.OnCompleteListener;
import com.google.android.gms.tasks.Task;
import com.google.firebase.firestore.CollectionReference;
import com.google.firebase.firestore.DocumentSnapshot;
import com.google.firebase.firestore.FirebaseFirestore;

import java.util.ArrayList;
import java.util.Calendar;
import java.util.List;
import java.util.Map;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

public class Register_First_Part extends AppCompatActivity {
    private TextView schoolName, classOf, programp, done, exit;
    private EditText ownerId, name;
    private Button next;
    private ImageView noClassOf, noProgram, noOwnerId, noName, backBtn;
    private FirebaseFirestore db = FirebaseFirestore.getInstance();
    private CollectionReference userRef = db.collection("Users");
    private Boolean isClass;


    private List<String> listOfYears = new ArrayList<String>();
    private List<String> pName = new ArrayList<String>();
    private ArrayList<Object> pCode = new ArrayList<Object>();
    private String code;

    private CollectionReference schoolsRef = db.collection("Schools");

    private String yClass = null;
    private String program = null;
    private String owner;
    String docId;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_register__first__part);


        int year = Calendar.getInstance().get(Calendar.YEAR);

        for (int i = 0; i < 8; i++) {
            listOfYears.add(String.valueOf(year - i));
        }

        final Intent intent = getIntent();
        final String chosenSchoolName = getIntent().getStringExtra("schoolName");
        final String schoolId = getIntent().getStringExtra("schoolId");
        final String extension = getIntent().getStringExtra("extension");

        backBtn = findViewById(R.id.backBtn);
        done = findViewById(R.id.done);
        exit = findViewById(R.id.exit);

        classOf = findViewById(R.id.classOf);
        programp = findViewById(R.id.programp);
        ownerId = findViewById(R.id.ownerId);
        name = findViewById(R.id.name);
        schoolName = findViewById(R.id.schoolName);
        next = findViewById(R.id.next);

        noClassOf = findViewById(R.id.noClassOf);
        noProgram = findViewById(R.id.noProgram);
        noOwnerId = findViewById(R.id.noOwnerId);
        noName = findViewById(R.id.noName);

        schoolName.setText(chosenSchoolName);
        schoolsRef.document(schoolId).collection("Programs").document("ProgramCodes")
                .get().addOnCompleteListener(new OnCompleteListener<DocumentSnapshot>() {
            @Override
            public void onComplete(@NonNull Task<DocumentSnapshot> task) {
                DocumentSnapshot document = task.getResult();
                List<Map<String, Object>> users = (List<Map<String, Object>>) document.get("programCodes");

                for (Map<String, Object> i : users) {
                    String name = (String) i.get("name");
                    String tempName = "";
                    if (name.contains("–")) {
                        String[] separated = name.split("–");
                        tempName += separated[0] + "\n" + separated[1];
                        if (name.contains("(")) {
                            String[] separated2 = name.split("\\(");
                            tempName += "\n(" + separated2[1];
                        }
                    }
                    if (!name.contains("–") && name.contains("(")) {
                        String[] separated = name.split("\\(");
                        tempName = separated[0] + "\n(" + separated[1];
                    }

                    if (!name.contains("–") && !name.contains("(")) {
                        tempName = name;
                    }

                    pName.add(tempName);
                    pCode.add(i.get("code"));
                }

            }
        });

        final Typeface typeface = ResourcesCompat.getFont(this, R.font.roboto);

        classOf.setOnClickListener(new View.OnClickListener() {
            @SuppressLint("ResourceAsColor")
            @Override
            public void onClick(View v) {
                isClass = true;
                disableAll();
                RelativeLayout s = findViewById(R.id.blackScreen);
                s.setVisibility(View.VISIBLE);
                RelativeLayout pickerScreen = findViewById(R.id.pickerView);
                s.setBackgroundColor(R.color.GRAY);
                com.shawnlin.numberpicker.NumberPicker numberPicker = (com.shawnlin.numberpicker.NumberPicker) findViewById(R.id.number_picker);
                pickerScreen.setVisibility(View.VISIBLE);
                numberPicker.setTextColor(ContextCompat.getColor(getApplicationContext(), R.color.black));
                String[] stringArray = listOfYears.toArray(new String[0]);
                numberPicker.setMaxValue(listOfYears.size());
                numberPicker.setDisplayedValues(stringArray);
                if (yClass == null) {
                    yClass = listOfYears.get(0);
                }
                numberPicker.setHorizontalFadingEdgeEnabled(true);
                numberPicker.setScrollContainer(true);
                numberPicker.setWrapSelectorWheel(true);
                numberPicker.setOnClickListener(new View.OnClickListener() {
                    @Override
                    public void onClick(View view) {

                    }
                });

                numberPicker.setOnValueChangedListener(new com.shawnlin.numberpicker.NumberPicker.OnValueChangeListener() {
                    @Override
                    public void onValueChange(com.shawnlin.numberpicker.NumberPicker picker, int oldVal, int newVal) {
                        int count = newVal - 1;
                        yClass = listOfYears.get(count);
                    }

                });

                numberPicker.setOnScrollListener(new com.shawnlin.numberpicker.NumberPicker.OnScrollListener() {
                    @Override
                    public void onScrollStateChange(com.shawnlin.numberpicker.NumberPicker picker, int scrollState) {

                    }
                });
            }
        });

        backBtn.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                finish();
            }
        });

        programp.setOnClickListener(new View.OnClickListener() {
            @SuppressLint("ResourceAsColor")
            @Override
            public void onClick(View v) {
                isClass = false;
                disableAll();

                RelativeLayout s = findViewById(R.id.blackScreen);
                s.setVisibility(View.VISIBLE);
                RelativeLayout pickerScreen = findViewById(R.id.pickerView);
                s.setBackgroundColor(R.color.GRAY);
                com.shawnlin.numberpicker.NumberPicker numberPicker = (com.shawnlin.numberpicker.NumberPicker) findViewById(R.id.number_picker);
                pickerScreen.setVisibility(View.VISIBLE);
                numberPicker.setTextColor(ContextCompat.getColor(getApplicationContext(), R.color.black));

                String[] stringArray = pName.toArray(new String[0]);
                numberPicker.setMaxValue(pName.size());
                numberPicker.setDisplayedValues(stringArray);

                if (program == null) {
                    program = pName.get(0);
                    code = (String) pCode.get(0);
                }


                numberPicker.setScrollContainer(true);
                numberPicker.setOnClickListener(new View.OnClickListener() {
                    @Override
                    public void onClick(View view) {

                    }
                });

                numberPicker.setOnValueChangedListener(new com.shawnlin.numberpicker.NumberPicker.OnValueChangeListener() {
                    @Override
                    public void onValueChange(com.shawnlin.numberpicker.NumberPicker picker, int oldVal, int newVal) {
                        int count = newVal - 1;
                        program = pName.get(count);
                        code = (String) pCode.get(count);
                    }

                });

                numberPicker.setOnScrollListener(new com.shawnlin.numberpicker.NumberPicker.OnScrollListener() {
                    @Override
                    public void onScrollStateChange(com.shawnlin.numberpicker.NumberPicker picker, int scrollState) {

                    }
                });

            }
        });

        BroadcastReceiver broadcastReceiver = new BroadcastReceiver() {

            @Override
            public void onReceive(Context arg0, Intent intent) {
                String action = intent.getAction();
                if (action.equals("finish_first")) {
                    finish();
                    // DO WHATEVER YOU WANT.
                }
            }
        };
        registerReceiver(broadcastReceiver, new IntentFilter("finish_activity"));

        done.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                enableAll();
                RelativeLayout s = findViewById(R.id.blackScreen);
                RelativeLayout pickerScreen = findViewById(R.id.pickerView);
                s.setVisibility(View.INVISIBLE);

                pickerScreen.setVisibility(View.GONE);

                if (isClass == false) {
                    programp.setText(program);
                } else {
                    classOf.setText(yClass);
                }


            }
        });

        exit.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                enableAll();
                RelativeLayout s = findViewById(R.id.blackScreen);
                RelativeLayout pickerScreen = findViewById(R.id.pickerView);
                s.setVisibility(View.INVISIBLE);

                if (isClass == false) {
                    if(programp.getText().toString().equals("")) {
                        program = null;
                        code = null;
                    }
                } else {
                    if(classOf.getText().toString().equals("")) {
                        yClass = null;
                    }
                }

                pickerScreen.setVisibility(View.GONE);
            }
        });


        next.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                Boolean flag = false;
                Boolean flag1 = false;

                Pattern p = Pattern.compile("[^a-z0-9 ]", Pattern.CASE_INSENSITIVE);

                owner = ownerId.getText().toString().trim().toLowerCase().replaceAll("\\s", "");
                Matcher m = p.matcher(owner);
                Boolean b = m.find();


                String fname = name.getText().toString().trim();

                if (program == null  || yClass == null || owner.equals("") || fname.equals("")) {
                    Toast.makeText(getApplicationContext(), "Please input required fields", Toast.LENGTH_SHORT).show();
                    flag = true;
                }
                else if (fname.length() < 4 || fname.length() > 20 ) {
                    //noName.setVisibility(View.VISIBLE);
                    Toast.makeText(getApplicationContext(), "Your name must be longer than 4 characters and shorter than 20", Toast.LENGTH_SHORT).show();
                    flag = true;
                } else if (owner.length() < 6 || owner.length() > 20 ) {
                    Toast.makeText(getApplicationContext(), "Your username must be longer than 6 characters and shorter than 20", Toast.LENGTH_SHORT).show();
                    flag = true;
                } else if (b) {
                    Toast.makeText(getApplicationContext(), "No special characters allowed in username", Toast.LENGTH_SHORT).show();
                    flag = true;
                }

                final Boolean finalFlag = flag;
                if (finalFlag == false) {
                    userRef
                            .document(owner)
                            .get().addOnCompleteListener(new OnCompleteListener<DocumentSnapshot>() {
                        @Override
                        public void onComplete(@NonNull Task<DocumentSnapshot> task) {
                            DocumentSnapshot document = task.getResult();
                            if (document.exists()) {
                                Toast.makeText(getApplicationContext(), "The username is already in use", Toast.LENGTH_SHORT).show();
                            } else {

                                Intent intent = new Intent(getApplicationContext(), RegisterUsername.class);

                                intent.putExtra("school", chosenSchoolName);
                                intent.putExtra("classOf", yClass);
                                intent.putExtra("ownerId", owner);
                                intent.putExtra("name", name.getText().toString());


                                String newProgram = "";

                                if (program.contains("\n")) {
                                    String[] separated = program.split("\n");
                                    newProgram += separated[0] + "-" + separated[1];
                                } else {
                                    newProgram = program;
                                }

                                Log.d("Tester123", newProgram);

                                intent.putExtra("program", newProgram);
                                intent.putExtra("code", code);
                                intent.putExtra("schoolId", schoolId);
                                intent.putExtra("extension", extension);
                                startActivity(intent);
                            }

                        }
                    });
                }

            }
        });
    }

    public void disableAll() {
        ownerId.setClickable(false);
        ownerId.setEnabled(false);
        name.setClickable(false);
        name.setEnabled(false);
        backBtn.setClickable(false);
        backBtn.setEnabled(false);
        next.setClickable(false);
        next.setEnabled(false);
        classOf.setClickable(false);
        classOf.setEnabled(false);
    }

    public void enableAll() {
        ownerId.setClickable(true);
        ownerId.setEnabled(true);
        name.setClickable(true);
        name.setEnabled(true);
        backBtn.setClickable(true);
        backBtn.setEnabled(true);
        next.setClickable(true);
        next.setEnabled(true);
        classOf.setClickable(true);
        classOf.setEnabled(true);
    }

}

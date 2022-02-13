package app.mayven.mayven;

import android.annotation.SuppressLint;
import android.os.Bundle;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.EditText;
import android.widget.RelativeLayout;
import android.widget.TextView;
import android.widget.Toast;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.core.content.ContextCompat;

import app.mayven.mayven.R;
import com.google.android.gms.tasks.OnCompleteListener;

import com.google.android.gms.tasks.Task;
import com.google.android.material.bottomsheet.BottomSheetDialogFragment;
import com.google.firebase.firestore.CollectionReference;
import com.google.firebase.firestore.DocumentReference;
import com.google.firebase.firestore.DocumentSnapshot;
import com.google.firebase.firestore.FirebaseFirestore;
import com.google.firebase.messaging.FirebaseMessaging;


import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.concurrent.TimeUnit;


public class Adding_Post extends BottomSheetDialogFragment {

    public static Adding_Post newInstance() {
        return new Adding_Post();
    }

    Button send, exit;

    private String name;
    private String schoolId;
    private String whichProgram;

    private TextView programType, exitPicker, done;

    private List<String> repliesArray = new ArrayList<String>();

    private EditText post;

    private static int selectedIndex = 0;
    private FirebaseFirestore db = FirebaseFirestore.getInstance();
    private CollectionReference postRef = db.collection("Posts");

    RegisterUsername reg = new RegisterUsername();
    List<userDB> qwe = reg.readData();
    final String signedInUser = qwe.get(0).name;
    final String signedInUsername = qwe.get(0).username;
    final String userProgram = qwe.get(0).programCode;

    List<String> programs = new ArrayList<String>();
    String currentProgram = null;

    @Nullable
    @Override
    public View onCreateView(@NonNull LayoutInflater inflater, @Nullable ViewGroup container, @Nullable Bundle savedInstanceState) {
        final View view = inflater.inflate(R.layout.fragment_adding_post, container, false);

        post = view.findViewById(R.id.input);
        send = view.findViewById(R.id.send);
        programType = view.findViewById(R.id.programType);

        ChatGroupArray chatGroupArray = new ChatGroupArray();

        if(currentProgram == null) {
            currentProgram = chatGroupArray.currentProgram;
            programType.setText(currentProgram);
        }



        exitPicker = view.findViewById(R.id.exitPicker);
        done = view.findViewById(R.id.done);

        exit = view.findViewById(R.id.exit);

        programs.add("All");
        programs.add(userProgram);

        programType.setOnClickListener(new View.OnClickListener() {
            @SuppressLint("ResourceAsColor")
            @Override
            public void onClick(View v) {

                disableAll();

                RelativeLayout s = view.findViewById(R.id.blackScreen);
                s.setVisibility(View.VISIBLE);
                RelativeLayout pickerScreen = view.findViewById(R.id.pickerView);
                s.setBackgroundColor(R.color.GRAY);
                com.shawnlin.numberpicker.NumberPicker numberPicker = (com.shawnlin.numberpicker.NumberPicker) view.findViewById(R.id.number_picker);
                pickerScreen.setVisibility(View.VISIBLE);
                numberPicker.setTextColor(ContextCompat.getColor(getContext(), R.color.black));

                String[] stringArray = programs.toArray(new String[0]);
                numberPicker.setMaxValue(programs.size());
                numberPicker.setDisplayedValues(stringArray);


                currentProgram = (String) programs.get(0);


                numberPicker.setScrollContainer(true);
                //    numberPicker.setWrapSelectorWheel(true);
                numberPicker.setOnClickListener(new View.OnClickListener() {
                    @Override
                    public void onClick(View view) {

                    }
                });

                numberPicker.setOnValueChangedListener(new com.shawnlin.numberpicker.NumberPicker.OnValueChangeListener() {
                    @Override
                    public void onValueChange(com.shawnlin.numberpicker.NumberPicker picker, int oldVal, int newVal) {
                        int count = newVal-1;
                        selectedIndex = count;
                        currentProgram = programs.get(selectedIndex);
                    }
                });

                numberPicker.setOnScrollListener(new com.shawnlin.numberpicker.NumberPicker.OnScrollListener() {
                    @Override
                    public void onScrollStateChange(com.shawnlin.numberpicker.NumberPicker picker, int scrollState) {

                    }
                });
            }
        });

        exit.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                dismiss();
            }
        });

        exitPicker.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if(programType.getText().toString().equals("")) {
                    currentProgram = null;
                }
                RelativeLayout s = view.findViewById(R.id.blackScreen);
                RelativeLayout pickerScreen = view.findViewById(R.id.pickerView);
                s.setVisibility(View.INVISIBLE);

                pickerScreen.setVisibility(View.GONE);

                enableAll();
            }
        });

        done.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                programType.setText(currentProgram);

                RelativeLayout s = view.findViewById(R.id.blackScreen);
                RelativeLayout pickerScreen = view.findViewById(R.id.pickerView);
                s.setVisibility(View.INVISIBLE);

                pickerScreen.setVisibility(View.GONE);

                enableAll();

            }
        });

        send.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                final String text = post.getText().toString();
                final String id = signedInUser;
                String timeStamp = String.valueOf(TimeUnit.MILLISECONDS.toSeconds(System.currentTimeMillis()));
                final int time = Integer.parseInt(timeStamp);

                if(currentProgram != null) {
                    final DocumentReference docRef = db.collection("Users").document(signedInUsername);
                    docRef.get().addOnCompleteListener(new OnCompleteListener<DocumentSnapshot>() {
                        @Override
                        public void onComplete(@NonNull Task<DocumentSnapshot> task) {
                            DocumentSnapshot document = task.getResult();
                            if (document.exists()) {
                                if (!text.matches("")) {
                                    name = document.getString("name");
                                    schoolId = document.getString("school");
                                    repliesArray.add(signedInUsername);
                                    Map<String, Object> toAdd = new HashMap<>();
                                    toAdd.put("lastAction", "post");
                                    toAdd.put("lastActionTime", time);
                                    toAdd.put("likes", 0);
                                    toAdd.put("ownerId", signedInUsername);
                                    toAdd.put("ownerName", name);
                                    toAdd.put("programCode", programType.getText().toString());
                                    toAdd.put("replies", repliesArray);
                                    toAdd.put("schoolId", schoolId);
                                    toAdd.put("text", text);
                                    toAdd.put("timestamp", time);
                                    toAdd.put("usersLiked", Collections.emptyList());
                                    toAdd.put("reports", Collections.emptyList());
                                    toAdd.put("replyCount", 0);
                                    postRef.add(toAdd);
                                    FirebaseMessaging.getInstance().subscribeToTopic(postRef.getId()) // PUT THIS INSIDE THE FOR LOOP OF THE RETURN FIRST DOCS && INIT NOTIFICATIONS
                                            .addOnCompleteListener(new OnCompleteListener<Void>() {
                                                @Override
                                                public void onComplete(@NonNull Task<Void> task) {
                                                    if (!task.isSuccessful()) {
                                                        Log.e("Error", "Cannot get notification");
                                                    }
                                                    else {
                                                        ChatGroupArray chatGroupArray = new ChatGroupArray();
                                                        chatGroupArray.cloudNotifications.add(postRef.getId());
                                                    }
                                                }
                                            });

                                    ((MainActivity) getActivity()).setBlackScreen();
                                    ((MainActivity) getActivity()).clearItems();
                                    ChatGroupArray chatGroupArray = new ChatGroupArray();
                                    ((MainActivity) getActivity()).addItemsFromFirebase(chatGroupArray.currentType, chatGroupArray.currentProgram);
                                    dismiss();
                                }
                                else {
                                    Toast.makeText(getContext(),"Please input some text", Toast.LENGTH_SHORT).show();
                                }
                            }
                        }
                    });
                }else{
                    Toast.makeText(getContext(),"Please select a program", Toast.LENGTH_SHORT).show();
                }
            }
        });

        return view;
    }

    public void disableAll(){
        exit.setClickable(false);
        programType.setClickable(false);
        send.setClickable(false);
        post.setClickable(false);
    }

    public void enableAll() {
        exit.setClickable(true);
        programType.setClickable(true);
        send.setClickable(true);
        post.setClickable(true);
    }
}
package app.mayven.mayven;


import android.content.Intent;
import android.os.Bundle;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.EditText;
import android.widget.Toast;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import app.mayven.mayven.R;
import com.google.android.gms.tasks.OnCompleteListener;
import com.google.android.gms.tasks.Task;
import com.google.android.material.bottomsheet.BottomSheetDialogFragment;
import com.google.firebase.firestore.CollectionReference;
import com.google.firebase.firestore.FirebaseFirestore;
import com.google.firebase.firestore.QueryDocumentSnapshot;
import com.google.firebase.firestore.QuerySnapshot;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class Changing_Name extends BottomSheetDialogFragment {
    private FirebaseFirestore db = FirebaseFirestore.getInstance();
    private CollectionReference userRef = db.collection("Users");

    private Button btn_send;
    private EditText msg_input;

    @Nullable
    @Override
    public View onCreateView(@NonNull LayoutInflater inflater, @Nullable ViewGroup container, @Nullable Bundle savedInstanceState) {
        final View view = inflater.inflate(R.layout.changing_name, container, false);

        final RegisterUsername reg = new RegisterUsername();
        List<userDB> qwe = reg.readData();
        final String signedInUser = qwe.get(0).username;
        final String email = qwe.get(0).email;

        btn_send = view.findViewById(R.id.btn_send);
        msg_input = view.findViewById(R.id.msg_input);

        btn_send.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                    String name = msg_input.getText().toString().trim();
                if(name.length() < 4 || name.length() > 20 || name.matches("") || name == null){
                    Toast.makeText(getContext(), "Username must be longer than 4 characters and shorter than 20", Toast.LENGTH_SHORT).show();
                }else {
                    userRef.document(signedInUser).update(
                            "name",name
                    );
                    //RegisterUsername reg = new RegisterUsername();
                    reg.deleteData();
                    userRef
                            .whereEqualTo("email",email)
                            .limit(1)
                            .get().addOnCompleteListener(new OnCompleteListener<QuerySnapshot>() {
                        @Override
                        public void onComplete(@NonNull Task<QuerySnapshot> task) {
                            for (QueryDocumentSnapshot doc : task.getResult()) {
                                Map<String, String> newMap = new HashMap<String, String>();
                                for (Map.Entry<String, Object> entry : doc.getData().entrySet()) {
                                    if (entry.getValue() instanceof String) {
                                        newMap.put(entry.getKey(), (String) entry.getValue());
                                    }
                                }
                                reg.storeUserData(email, newMap);
                                getActivity().finish();
                                startActivity(new Intent(getActivity().getApplicationContext(), MainActivity.class));
                            }
                        }
                    });
                }
            }
        });
        return view;
    }
}

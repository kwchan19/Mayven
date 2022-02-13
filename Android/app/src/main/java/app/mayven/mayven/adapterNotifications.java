package app.mayven.mayven;

import android.content.Context;
import android.os.Build;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ArrayAdapter;
import android.widget.ImageView;
import android.widget.TextView;

import androidx.annotation.RequiresApi;

import com.bumptech.glide.Glide;
import com.bumptech.glide.request.RequestOptions;
import app.mayven.mayven.R;

import com.bumptech.glide.signature.ObjectKey;
import com.google.firebase.firestore.CollectionReference;
import com.google.firebase.firestore.DocumentReference;
import com.google.firebase.firestore.FirebaseFirestore;

import java.util.ArrayList;

public class adapterNotifications extends ArrayAdapter<Note> {

    Context context;
    View previousRow;

    public adapterNotifications(Context context, ArrayList<Note> note) {
        super(context, R.layout.livechatlayout, note);
        this.context = context;
    }

    @RequiresApi(api = Build.VERSION_CODES.O)
    @Override
    public View getView(int position, View convertView, ViewGroup parent) {
        Integer previousIndex = 0;
        View row = convertView;
        if (convertView == null) {
            LayoutInflater layoutInflater = LayoutInflater.from(context);
            row = layoutInflater.inflate(R.layout.list_notifications, null);
        }

        Note note = getItem(position);

        TextView previousUser;
        TextView userName = (TextView) row.findViewById(R.id.userName);
        TextView message = (TextView) row.findViewById(R.id.textView);
        TextView timestamp = (TextView) row.findViewById(R.id.firstTimestamp);
        TextView firstTimestamp = (TextView) row.findViewById(R.id.firstTimestamp);
        String theTime = note.getTime();

        userName.setText(note.getOwnerName() + " has replied to a post");
        firstTimestamp.setText(theTime);

        FirebaseFirestore db = FirebaseFirestore.getInstance();
        CollectionReference imageRef = db.collection("Users");
        final DocumentReference imageUrl = imageRef.document(note.getOwnerName());

        String imgUrl = "https://firebasestorage.googleapis.com/v0/b/chatapp-6d978.appspot.com/o/Thumbnail%2F" + note.getId() + ".jpeg?alt=media";
        final ImageView profilePic = (ImageView) row.findViewById(R.id.profilePic);

        ChatGroupArray chatGroupArray = new ChatGroupArray();
        String ts = String.valueOf(chatGroupArray.imageTime);

        Glide.with(profilePic.getContext()).load(imgUrl)
                .dontAnimate()
                .placeholder(R.drawable.placeholder)
                .apply(RequestOptions.circleCropTransform())
                .signature(new ObjectKey(ts))
                //  .error(R.drawable.ic_person_fill)
                .into(profilePic);

        return row;
    }
}




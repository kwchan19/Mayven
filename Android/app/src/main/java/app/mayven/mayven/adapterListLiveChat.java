package app.mayven.mayven;

import android.content.Context;
import android.os.Build;
import android.util.Log;
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

import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;

public class adapterListLiveChat extends ArrayAdapter<Chat> {

    Context context;
    View previousRow;

    public adapterListLiveChat(Context context, ArrayList<Chat> chat) {
        super(context, R.layout.livechatlayout, chat);
        this.context = context;
    }

    @RequiresApi(api = Build.VERSION_CODES.O)
    @Override
    public View getView(int position, View convertView, ViewGroup parent) {
        Integer previousIndex = 0;
        View row = convertView;
        if(convertView == null) {
            LayoutInflater layoutInflater = LayoutInflater.from(context);
            row = layoutInflater.inflate(R.layout.livechatlayout, null);
        }

        Chat previousChat = new Chat();
        Chat chat = getItem(position);
        TextView previousUser;
        TextView userName = (TextView) row.findViewById(R.id.userName);
        TextView message = (TextView) row.findViewById(R.id.textView);
        TextView timestamp = (TextView) row.findViewById(R.id.timestamp);
        TextView firstTimestamp = (TextView) row.findViewById(R.id.firstTimestamp);
        TextView dateTextView = (TextView) row.findViewById(R.id.date);
        Long theTime = chat.getTimestamp();

        Date date = new java.util.Date(theTime*1000L);
        String formattedTime = new SimpleDateFormat("hh:mm aa").format(date);
        String currDate = new SimpleDateFormat("dd MMMM yyyy").format(date);

        final ImageView profilePic = (ImageView) row.findViewById(R.id.profilePic);

        if(position-1 > -1) {
            previousIndex = position - 1;
            previousChat = getItem(previousIndex);

            Date date2 = new java.util.Date(previousChat.getTimestamp()*1000L);
            String previousDate = new SimpleDateFormat("dd MMMM yyyy").format(date2);

            if(!previousDate.equals(currDate)) {
                dateTextView.setText(currDate);

                dateTextView.setVisibility(View.VISIBLE);
                firstTimestamp.setVisibility(View.VISIBLE);
                userName.setVisibility(View.VISIBLE);
                profilePic.setVisibility(View.VISIBLE);
                timestamp.setVisibility(View.GONE);
                userName.setText(chat.getOwnerName());
                message.setText(chat.getLiveMessage());
                firstTimestamp.setText(formattedTime);

            }
            else {
                dateTextView.setVisibility(View.GONE);
                if(previousChat.getOwnerName().equals(chat.getOwnerName())) {
                    firstTimestamp.setVisibility(View.GONE);
                    userName.setVisibility(View.GONE);
                    profilePic.setVisibility(View.GONE);
                    timestamp.setVisibility(View.VISIBLE);
                    message.setText(chat.getLiveMessage());
                    timestamp.setText(formattedTime);
                    if(chat.getTimestamp() - previousChat.getTimestamp() < 60) {
                        timestamp.setVisibility(View.INVISIBLE);
                    }
                }
                else {
                    firstTimestamp.setVisibility(View.VISIBLE);
                    userName.setVisibility(View.VISIBLE);
                    profilePic.setVisibility(View.VISIBLE);
                    timestamp.setVisibility(View.GONE);
                    userName.setText(chat.getOwnerName());
                    message.setText(chat.getLiveMessage());
                    firstTimestamp.setText(formattedTime);
                }
            }
        }
        else {
            userName.setVisibility(View.VISIBLE);
            profilePic.setVisibility(View.VISIBLE);
            timestamp.setVisibility(View.GONE);
            firstTimestamp.setVisibility(View.INVISIBLE);
            userName.setText(chat.getOwnerName());
            message.setText(chat.getLiveMessage());
            firstTimestamp.setText(formattedTime);
        }


        FirebaseFirestore db = FirebaseFirestore.getInstance();
        CollectionReference imageRef = db.collection("Users");
        final DocumentReference imageUrl = imageRef.document(chat.getOwnerName());

        String imgUrl = "https://firebasestorage.googleapis.com/v0/b/chatapp-6d978.appspot.com/o/Thumbnail%2F" + chat.getOwnerId() + ".jpeg?alt=media";

        ChatGroupArray chatGroupArray = new ChatGroupArray();
        String ts = String.valueOf(chatGroupArray.imageTime);

        Glide.with(profilePic.getContext()).load(imgUrl)
                .dontAnimate()
                .placeholder(R.drawable.placeholder)
                .apply(RequestOptions.circleCropTransform())
                .signature(new ObjectKey(ts))
                .error(R.drawable.initial_pic)
                .into(profilePic);


        previousRow = row;
        return row;
    }

    @Override
    public boolean isEnabled(int position) {
        return false;
    }

}
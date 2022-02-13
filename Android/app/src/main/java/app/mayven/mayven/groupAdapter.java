package app.mayven.mayven;

import android.content.Context;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ArrayAdapter;
import android.widget.ImageView;
import android.widget.TextView;

import com.bumptech.glide.Glide;
import com.bumptech.glide.request.RequestOptions;
import com.bumptech.glide.signature.ObjectKey;

import app.mayven.mayven.R;
import java.util.ArrayList;

public class groupAdapter extends ArrayAdapter<Group> {

    Context context;

    public groupAdapter(Context context, ArrayList<Group> group) {
        super(context, R.layout.test, group);
        this.context = context;
    }

    @Override
    public View getView(int position, View convertView, ViewGroup parent) {
        Integer previousIndex = 0;
        View row = convertView;
        if(convertView == null) {
            LayoutInflater layoutInflater = LayoutInflater.from(context);
            row = layoutInflater.inflate(R.layout.test, null);
        }

        ChatGroupArray chatGroupArray = new ChatGroupArray();
        Group group = chatGroupArray.getGroupSave().get(position);


        TextView groupName = (TextView) row.findViewById(R.id.groupName);
        TextView badgeText = (TextView) row.findViewById(R.id.badgeText);
        final ImageView badgeImg = (ImageView) row.findViewById(R.id.badge);
        TextView lastMessage = (TextView) row.findViewById(R.id.lastMessage);

        groupName.setText(group.getName());
        lastMessage.setText(group.getLastMessage());

        if(group.getNotifications() == 0){
            badgeText.setVisibility(View.INVISIBLE);
            badgeImg.setVisibility(View.INVISIBLE);
        }
        else {
            badgeText.setVisibility(View.VISIBLE);
            badgeImg.setVisibility(View.VISIBLE);
            badgeText.setText(String.valueOf(group.getNotifications()));
        }

        final ImageView groupImg = (ImageView) row.findViewById(R.id.groupImg);
        String imgurl = "https://firebasestorage.googleapis.com/v0/b/chatapp-6d978.appspot.com/o/ChatGroups%2F" + group.getDocId() + ".jpeg?alt=media";

        String ts = String.valueOf(chatGroupArray.imageTime);

        Glide.with(groupImg.getContext()).load(imgurl)
                .dontAnimate()
                .placeholder(R.drawable.placeholder)
                .signature(new ObjectKey(ts))
                .apply(RequestOptions.circleCropTransform())
                //  .error(R.drawable.ic_person_fill)
                .into(groupImg);

        return row;
    }

    public void updateReceiptsList(ArrayList<Group> newGroup) {
        final ChatGroupArray chatGroupArray = new ChatGroupArray();
        //  chatGroupArray.GroupSave.clear();
        chatGroupArray.GroupSave = newGroup;
        synchronized(this) {
            this.notifyAll();
        }
        //   this.notifyDataSetChanged();
    }
}
package app.mayven.mayven;


import android.app.Activity;
import android.content.Context;
import android.content.res.Resources;
import android.os.Bundle;


import androidx.fragment.app.Fragment;
import androidx.recyclerview.widget.DividerItemDecoration;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;
import androidx.swiperefreshlayout.widget.SwipeRefreshLayout;

import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.ImageView;
import android.widget.TextView;

import app.mayven.mayven.R;
import com.google.android.material.button.MaterialButtonToggleGroup;
import com.google.firebase.firestore.CollectionReference;
import com.google.firebase.firestore.FirebaseFirestore;
import com.google.firebase.firestore.Query;

import java.util.List;
import java.util.concurrent.TimeUnit;

import static app.mayven.mayven.PaginationListener.PAGE_START;

public class HomeFragment extends Fragment implements SwipeRefreshLayout.OnRefreshListener {
    private int currentPage = PAGE_START;
    private boolean isLastPage = false;
    private int totalPage = 10;
    private boolean isLoading = false;
    int itemCount = 0;
    private boolean refreshTop = false;

    private MaterialButtonToggleGroup toggleButton;
    private static final String TAG = "HomeFragment";

    private Query query;
    private FirebaseFirestore db = FirebaseFirestore.getInstance();
    private CollectionReference postRef = db.collection("Posts");
    public static adapterRegular adapter;
    RecyclerView mRecyclerView;
    private ImageView floatingActionButton;
    private ImageView flameIcon;
    private Button bt_All;
    private Button bt_Program;
    public static TextView isEmpty;
    // private adapter adapter;
    private boolean clickedBefore = false;
    private String userPost;
    private Object Toolkit;

    ChatGroupArray chatGroupArray = new ChatGroupArray();


    SwipeRefreshLayout mSwipeRefreshLayout;
    int color = 0;
    Activity mActivity;

    View rootView;

    int totalSize = 0;

    private List<Object> NewONes;

    @Override
    public void onAttach(Context context) {
        super.onAttach(context);
        if (context instanceof Activity){
            mActivity = (Activity) context;
        }
    }

    @Override
    public void onDetach() {
        super.onDetach();
        mActivity = null;
    }

    public HomeFragment() {

        // Required empty public constructor
    }

    /*public static HomeFragment newInstance(String param1, String param2) {
        HomeFragment fragment = new HomeFragment();
        Bundle args = new Bundle();
        args.putString(ARG_PARAM1, param1);
        args.putString(ARG_PARAM2, param2);
        fragment.setArguments(args);
        return fragment;
    }
     */

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);{
            setRetainInstance(true);

        }
    }


    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {
        final MainActivity activity = (MainActivity) getActivity();

        rootView = inflater.inflate(R.layout.fragment_home, container, false);
        flameIcon = rootView.findViewById(R.id.flameIcon);

        ((MainActivity)getActivity()).unhideNav();

        floatingActionButton = rootView.findViewById(R.id.floatbutton);
        floatingActionButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                Adding_Post adding_post = new Adding_Post();
                assert getFragmentManager() != null;
                adding_post.show(getFragmentManager(),"Test");
            }

        });

        RegisterUsername reg = new RegisterUsername();
        List<userDB> qwe = reg.readData();
        final String signedInUsername = qwe.get(0).username;
        final String programCode = qwe.get(0).programCode;

        toggleButton = rootView.findViewById(R.id.toggleGroup);
        bt_All = rootView.findViewById(R.id.btnAll);
        bt_Program = rootView.findViewById(R.id.btnProgram);

        bt_Program.setText(programCode);

        int screenSize = getScreenWidth();
        bt_All.setWidth(screenSize/2);
        bt_Program.setWidth(screenSize/2);

        mRecyclerView = (RecyclerView) rootView.findViewById(R.id.recycling);
        // Use this setting to improve performance if you know that changes
        // in content do not change the layout size of the RecyclerView.
        mRecyclerView.setHasFixedSize(true);

        DividerItemDecoration mDividerItemDecoration = new DividerItemDecoration(mRecyclerView.getContext(), DividerItemDecoration.VERTICAL);
        mRecyclerView.addItemDecoration(mDividerItemDecoration);

        mSwipeRefreshLayout = rootView.findViewById(R.id.swipeLayout);
        mSwipeRefreshLayout.setOnRefreshListener(this);

        // Specify a linear layout manager.
        RecyclerView.LayoutManager layoutManager = new LinearLayoutManager(mActivity);
        mRecyclerView.setLayoutManager(layoutManager);


        final ChatGroupArray chatGroupArray = new ChatGroupArray();

        // Specify an adapter.
        adapter = new adapterRegular(mActivity,  chatGroupArray.getmRecyclerViewItems());


        mRecyclerView.setAdapter(adapter);
        mRecyclerView.setVisibility(View.VISIBLE);
        mRecyclerView.invalidate();

        isEmpty = (TextView) rootView.findViewById(R.id.isEmpty);


        mRecyclerView.addOnScrollListener(new RecyclerView.OnScrollListener() {
            @Override
            public void onScrollStateChanged(RecyclerView recyclerView, int newState) {
                super.onScrollStateChanged(recyclerView, newState);
                if (!recyclerView.canScrollVertically(1) && newState==RecyclerView.SCROLL_STATE_IDLE && chatGroupArray.getmRecyclerViewItems().size() > 5) {
                    ChatGroupArray chatGroupArray = new ChatGroupArray();
                    ((MainActivity) getActivity()).loadMoreItems(chatGroupArray.lastResult, chatGroupArray.currentType, chatGroupArray.currentProgram);
                    adapter.notifyDataSetChanged();
                }
            }
        });

        flameIcon.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if(chatGroupArray.currentType == "timestamp" ||  chatGroupArray.currentType == null) {

                    flameIcon.setImageResource(R.drawable.ic_flamered);

                    ((MainActivity) getActivity()).clearItems();

                    chatGroupArray.currentType = "likes";

                    adapter.notifyDataSetChanged();
                    ((MainActivity) getActivity()).addItemsFromFirebase("likes", chatGroupArray.currentProgram);
                    ((MainActivity) getActivity()).setBlackScreen();

                }
                else{
                    flameIcon.setImageResource(R.drawable.ic_flamewhite);

                    ((MainActivity) getActivity()).clearItems();

                    chatGroupArray.currentType = "timestamp";

                    adapter.notifyDataSetChanged();
                    ((MainActivity) getActivity()).addItemsFromFirebase("timestamp", chatGroupArray.currentProgram);
                    ((MainActivity) getActivity()).setBlackScreen();

                }

            }
        });

        toggleButton = rootView.findViewById(R.id.toggleGroup);
        bt_All = rootView.findViewById(R.id.btnAll);
        bt_Program = rootView.findViewById(R.id.btnProgram);

        toggleButton.addOnButtonCheckedListener(new MaterialButtonToggleGroup.OnButtonCheckedListener() {
            @Override
            public void onButtonChecked(MaterialButtonToggleGroup group, int checkedId, boolean isChecked) {
                if(isChecked) {
                    if (group.getCheckedButtonId() == R.id.btnAll) {
                        chatGroupArray.currentProgram = "All";

                        ((MainActivity) getActivity()).clearItems();

                        adapter.notifyDataSetChanged();
                        ((MainActivity) getActivity()).addItemsFromFirebase(chatGroupArray.currentType, "All");
                        ((MainActivity) getActivity()).setBlackScreen();

                        if(adapter.getItemCount() == 0) {
                            TextView classOf = (TextView) rootView.findViewById(R.id.isEmpty);
                            classOf.setVisibility(View.GONE);
                        }
                        else {
                            TextView classOf = (TextView) rootView.findViewById(R.id.isEmpty);
                            classOf.setVisibility(View.VISIBLE);
                        }

                    } else if (group.getCheckedButtonId() == R.id.btnProgram) {
                        chatGroupArray.currentProgram = programCode;

                        ((MainActivity) getActivity()).clearItems();

                        adapter.notifyDataSetChanged();
                        ((MainActivity) getActivity()).addItemsFromFirebase(chatGroupArray.currentType, programCode);
                        ((MainActivity) getActivity()).setBlackScreen();

                        if(adapter.getItemCount() == 0) {
                            TextView classOf = (TextView) rootView.findViewById(R.id.isEmpty);
                            classOf.setVisibility(View.GONE);
                        }
                        else {
                            TextView classOf = (TextView) rootView.findViewById(R.id.isEmpty);
                            classOf.setVisibility(View.VISIBLE);
                        }
                    }

                    // ((MainActivity) getActivity()).addItemsFromFirebase();
                }
            }
        });

        return rootView;
    }

    public static int getScreenWidth() {
        return Resources.getSystem().getDisplayMetrics().widthPixels;
    }

    @Override
    public void onRefresh() {
        ChatGroupArray chatGroupArray = new ChatGroupArray();
        itemCount = 0;
        currentPage = PAGE_START;
        isLastPage = false;
        //    adapter.clear();
        ((MainActivity) getActivity()).clearItems();
        adapter.notifyDataSetChanged();

        String timeStamp = String.valueOf(TimeUnit.MILLISECONDS.toSeconds(System.currentTimeMillis()));
        final int time = Integer.parseInt(timeStamp);
        chatGroupArray.imageTime = time;

        ((MainActivity) getActivity()).addItemsFromFirebase(chatGroupArray.currentType, chatGroupArray.currentProgram);
        ((MainActivity) getActivity()).setBlackScreen();
        mSwipeRefreshLayout.setRefreshing(false);
    }
}
package com.fingo.fenguo.robot.kit;

import android.content.Context;
import android.view.View;
import android.widget.GridLayout;
import android.widget.ImageButton;
import android.widget.LinearLayout;
import android.widget.TextView;

import java.util.ArrayList;
import com.fingo.fenguo.dev.R;
/**
 * Created by wuyifan on 2018/1/26.
 */

public class PluginViewHolder implements View.OnClickListener {

    public interface OnPluginClickListener {
        void onClick(int tag);
    }

    private Context context;
    private GridLayout pluginBack;
    private ArrayList<View> pluginItems;
    private OnPluginClickListener onPluginClickListener;

    public PluginViewHolder(GridLayout rootView) {
        pluginBack = rootView;
        context = rootView.getContext();
        pluginItems = new ArrayList<View>();
    }

    public void setOnPluginClickListener(OnPluginClickListener listener) {
        onPluginClickListener = listener;
    }

    public void insertItem(int image, int title, int tag) {
        insertItem(image, title, pluginItems.size(), tag);
    }

    public void insertItem(int image, int title, int index, int tag) {

        LinearLayout itemLayout = (LinearLayout) View.inflate(context, R.layout.pd_view_plugin_item, null);

        ImageButton imageButton = itemLayout.findViewById(R.id.pd_plgin_item_image);
        imageButton.setImageDrawable(context.getResources().getDrawable(image));
        imageButton.setOnClickListener(this);

        TextView titleView = itemLayout.findViewById(R.id.pd_plgin_item_title);
        titleView.setText(title);

        itemLayout.setTag(new Integer(tag));
        pluginItems.add(index, itemLayout);

        pluginBack.addView(itemLayout, index);
    }

    public void updateItemAtIndex(int index, int image, int title) {
        if (index < 0 || index >= pluginItems.size()) return;

        View itemLayout = pluginItems.get(index);

        ImageButton imageButton = itemLayout.findViewById(R.id.pd_plgin_item_image);
        imageButton.setImageDrawable(context.getResources().getDrawable(image));

        TextView titleView = itemLayout.findViewById(R.id.pd_plgin_item_title);
        titleView.setText(title);
    }

    public void updateItemWithTag(int tag, int image, int title) {
        int index = findItemWithTag(tag);
        updateItemAtIndex(index, image, title);
    }

    public void removeItemAtIndex(int index) {
        if (index < 0 || index >= pluginItems.size()) return;

        pluginItems.remove(index);
        pluginBack.removeViewAt(index);
    }

    public void removeItemWithTag(int tag) {
        int index = findItemWithTag(tag);
        removeItemAtIndex(index);
    }

    public void removeAllItems() {
        pluginItems.clear();
        pluginBack.removeAllViews();
    }

    private int findItemWithTag(int tag) {
        int cnt = pluginItems.size();
        for (int i = 0; i < cnt; i++) {
            Integer tagObj = (Integer) pluginItems.get(i).getTag();
            if (tagObj.intValue() == tag) return i;
        }
        return -1;
    }

    @Override
    public void onClick(View v) {
        View itemView = (View) v.getParent();
        Integer tagObj = (Integer) itemView.getTag();
        onPluginClickListener.onClick(tagObj);
    }
}

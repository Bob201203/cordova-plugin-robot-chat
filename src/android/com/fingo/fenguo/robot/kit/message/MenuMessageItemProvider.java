package com.fingo.fenguo.robot.kit.message;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.LinearLayout;
import android.widget.TextView;

import com.fingo.fenguo.dev.R;
import com.paradigm.botlib.MenuItem;
import com.paradigm.botlib.Message;
import com.paradigm.botlib.MessageContentMenu;

/**
 * Created by wuyifan on 2018/1/31.
 */

public class MenuMessageItemProvider extends MessageItemProvider implements View.OnClickListener {

    public interface OnContentClickListener {
        void onItemClick(MenuItem item, int type);
    }

    private OnContentClickListener contentClickListener;

    public MenuMessageItemProvider(OnContentClickListener contentClickListener) {
        this.contentClickListener = contentClickListener;
    }

    @Override
    public View createContentView(Context context) {
        View contentView = LayoutInflater.from(context).inflate(R.layout.pd_item_message_menu, null);
        return contentView;
    }

    @Override
    public void bindContentView(View v, Message message) {
        LinearLayout contentView = (LinearLayout) v;
        MessageContentMenu content = (MessageContentMenu) message.getContent();
        Context context = v.getContext();

        contentView.setTag(content);

        contentView.removeAllViewsInLayout();
        TextView headView = (TextView) LayoutInflater.from(context).inflate(R.layout.pd_item_message_menuhead, null);
        headView.setText(content.getMenuType() == MessageContentMenu.TypeMenu ? R.string.pd_message_menu : R.string.pd_message_recommend);
        headView.setBackgroundResource(R.drawable.pd_message_menuhead);
        contentView.addView(headView);

        int size = content.getMenuItems().size();
        for (int i = 0; i < size; i++) {
            MenuItem item = content.getMenuItems().get(i);
            TextView itemView = (TextView) LayoutInflater.from(context).inflate(R.layout.pd_item_message_menuitem, null);
            itemView.setText(item.getContent());
            itemView.setBackgroundResource(R.drawable.pd_message_menuitem);
            itemView.setOnClickListener(this);
            itemView.setTag(item);
            contentView.addView(itemView);
        }
    }

    @Override
    public boolean isShowContentBubble() {
        return false;
    }

    @Override
    public void onClick(View v) {
        View parent = (View) v.getParent();
        MessageContentMenu content = (MessageContentMenu) parent.getTag();
        MenuItem item = (MenuItem) v.getTag();
        if (contentClickListener != null) contentClickListener.onItemClick(item, content.getMenuType());
    }
}

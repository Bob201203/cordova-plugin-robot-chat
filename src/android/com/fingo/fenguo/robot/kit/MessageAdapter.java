package com.fingo.fenguo.robot.kit;

import android.content.Context;
import android.graphics.drawable.Drawable;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;

import com.fingo.fenguo.robot.kit.message.MessageItemProvider;
import com.fingo.fenguo.robot.kit.util.DateUtil;
import com.paradigm.botlib.Message;

import java.util.ArrayList;
import com.fingo.fenguo.dev.R;
/**
 * Created by wuyifan on 2018/1/30.
 */

public class MessageAdapter extends BaseAdapter {

    protected Context context;
    protected DateUtil dateUtil;
    protected Drawable portraitUser;
    protected Drawable portraitRobotBg;
    protected Drawable portraitRobot;
    protected ArrayList<Message> messageData;
    protected MessageItemProvider[] providers = new MessageItemProvider[8];

    public MessageAdapter(Context context) {
        this.context = context;
        this.dateUtil = new DateUtil(context);
    }

    void setMessageItemProvider(int messageType, MessageItemProvider provider) {
        providers[messageType] = provider;
    }

    @Override
    public int getCount() {
        return messageData.size();
    }

    @Override
    public Object getItem(int position) {
        return messageData.get(position);
    }

    @Override
    public long getItemId(int position) {
        return position;
    }

    @Override
    public View getView(int position, View convertView, ViewGroup parent) {

        Message message = messageData.get(position);
        MessageItemProvider provider = providers[message.getContentType()];
        if (provider == null) return getUnsupportView();

        String timeString = null;
        if (position == 0 || message.getSendTime().getTime() - messageData.get(position - 1).getSendTime().getTime() > 1000 * 60 * 5)
            timeString = dateUtil.timeStringFromDate(message.getSendTime());

        if (convertView == null)
            convertView = provider.createMessageView(context, portraitUser, portraitRobot);
        provider.bindMessageView(convertView, message, timeString);

        return convertView;
    }

    @Override
    public int getItemViewType(int position) {
        return messageData.get(position).getContentType();
    }

    @Override
    public int getViewTypeCount() {
        return providers.length;
    }

    @Override
    public void notifyDataSetChanged() {
        dateUtil.refreash();
        super.notifyDataSetChanged();
    }

    public ArrayList<Message> getMessageData() {
        return messageData;
    }

    public void setMessageData(ArrayList<Message> messageData) {
        this.messageData = messageData;
        this.notifyDataSetChanged();
    }

    public void setPortraitUser(Drawable portraitUser) {
        this.portraitUser = portraitUser;
    }

    public void setPortraitRobot(Drawable portraitRobot) {
        this.portraitRobot = portraitRobot;
    }

    private View getUnsupportView() {
        return LayoutInflater.from(context).inflate(R.layout.pd_item_message_unsupport, null);
    }
}

package com.fingo.fenguo.robot.kit.message;

import android.content.Context;
import android.graphics.drawable.Drawable;
import android.util.Log;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.FrameLayout;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;

import com.fingo.fenguo.dev.R;
import com.fingo.fenguo.robot.kit.util.DateUtil;
import com.paradigm.botlib.Message;
import com.paradigm.botlib.MessageContent;

/**
 * Created by wuyifan on 2018/1/30.
 */

public abstract class MessageItemProvider {

    public View createMessageView(Context context, Drawable portraitUser, Drawable portraitRobot) {

        MessageItemHolder holder = new MessageItemHolder();

        View messageView = LayoutInflater.from(context).inflate(R.layout.pd_item_message, null);
        holder.setTime((TextView) messageView.findViewById(R.id.pd_message_time));
        holder.setMessageBack((LinearLayout) messageView.findViewById(R.id.pd_message_back));
        holder.setContentBack((FrameLayout) messageView.findViewById(R.id.pd_message_content_back));
        holder.setPortraitUser((ImageView) messageView.findViewById(R.id.pd_message_portrait_l));
        holder.setPortraitRobot((ImageView) messageView.findViewById(R.id.pd_message_portrait_r));
        messageView.setTag(holder);

        View contentView = this.createContentView(context);
        holder.setContentView(contentView);
        holder.getContentBack().addView(contentView);

        if (portraitUser!=null) holder.getPortraitUser().setImageDrawable(portraitUser);
        if (portraitRobot!=null) holder.getPortraitRobot().setImageDrawable(portraitRobot);

        return messageView;
    }


    public void bindMessageView(View v, Message message, String timeString) {

        MessageItemHolder holder = (MessageItemHolder) v.getTag();

        if (timeString == null) {
            holder.getTime().setVisibility(View.GONE);
        } else {
            holder.getTime().setVisibility(View.VISIBLE);
            holder.getTime().setText(timeString);
        }

        if (message.getDirection() == Message.DirectionRecv) {
            if (isShowContentBubble())
                holder.getContentBack().setBackgroundResource(R.drawable.pd_message_bubble_left);
            holder.getPortraitUser().setVisibility(View.VISIBLE);
            holder.getPortraitRobot().setVisibility(View.INVISIBLE);

            LinearLayout.LayoutParams layoutParams = (LinearLayout.LayoutParams) holder.getMessageBack().getLayoutParams();
            layoutParams.gravity = Gravity.LEFT;
            holder.getMessageBack().setLayoutParams(layoutParams);
        } else {
            if (isShowContentBubble())
                holder.getContentBack().setBackgroundResource(R.drawable.pd_message_bubble_right);
            holder.getPortraitUser().setVisibility(View.INVISIBLE);
            holder.getPortraitRobot().setVisibility(View.VISIBLE);

            LinearLayout.LayoutParams layoutParams = (LinearLayout.LayoutParams) holder.getMessageBack().getLayoutParams();
            layoutParams.gravity = Gravity.RIGHT;
            holder.getMessageBack().setLayoutParams(layoutParams);
        }

        View contentView = holder.getContentView();
        contentView.setVisibility(View.GONE);
        this.bindContentView(contentView, message);
        contentView.setVisibility(View.VISIBLE);
    }

    public abstract View createContentView(Context context);

    public abstract void bindContentView(View v, Message message);

    public boolean isShowContentBubble() {
        return true;
    }
}

package com.fingo.fenguo.robot.kit.message;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.FrameLayout;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;

import com.fingo.fenguo.dev.R;
import com.paradigm.botlib.Message;
import com.paradigm.botlib.MessageContent;
import com.paradigm.botlib.MessageContentText;

/**
 * Created by wuyifan on 2018/1/31.
 */

public class TextMessageItemProvider extends MessageItemProvider {

    @Override
    public View createContentView(Context context) {
        View contentView = LayoutInflater.from(context).inflate(R.layout.pd_item_message_text, null);
        return contentView;
    }

    @Override
    public void bindContentView(View v, Message message) {
        TextView contentView = (TextView)v;
        MessageContentText content = (MessageContentText) message.getContent();
        contentView.setText(content.getText());
    }
}

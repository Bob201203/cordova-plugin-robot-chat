package com.fingo.fenguo.robot.kit.message;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.ImageView;

import com.fingo.fenguo.dev.R;
import com.paradigm.botlib.Message;
import com.paradigm.botlib.MessageContentAudio;

/**
 * Created by wuyifan on 2018/1/31.
 */

public class AudioMessageItemProvider extends MessageItemProvider implements View.OnClickListener {

    public interface OnContentClickListener {
        void onClick(MessageContentAudio content);
    }

    OnContentClickListener contentClickListener;

    public AudioMessageItemProvider(OnContentClickListener contentClickListener) {
        this.contentClickListener = contentClickListener;
    }

    @Override
    public View createContentView(Context context) {
        View contentView = LayoutInflater.from(context).inflate(R.layout.pd_item_message_audio, null);
        contentView.setOnClickListener(this);
        return contentView;
    }

    @Override
    public void bindContentView(View v, Message message) {
        ImageView contentView = (ImageView) v;
        MessageContentAudio content = (MessageContentAudio) message.getContent();
        contentView.setImageResource(message.getDirection() == Message.DirectionRecv ? R.drawable.pd_message_audio_left : R.drawable.pd_message_audio_right);
        contentView.setTag(content);
    }

    @Override
    public void onClick(View v) {
        MessageContentAudio content = (MessageContentAudio) v.getTag();
        if (contentClickListener != null) contentClickListener.onClick(content);
    }
}

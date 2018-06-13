package com.fingo.fenguo.robot.kit.message;

import android.content.Context;
import android.net.Uri;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.ImageView;

import com.fingo.fenguo.dev.R;
import com.paradigm.botlib.Message;
import com.paradigm.botlib.MessageContentImage;

import java.io.File;

/**
 * Created by wuyifan on 2018/1/31.
 */

public class ImageMessageItemProvider extends MessageItemProvider implements View.OnClickListener {

    public interface OnContentClickListener {
        void onClick(MessageContentImage content);
    }

    OnContentClickListener contentClickListener;

    public ImageMessageItemProvider(OnContentClickListener contentClickListener) {
        this.contentClickListener = contentClickListener;
    }

    @Override
    public View createContentView(Context context) {
        View contentView = LayoutInflater.from(context).inflate(R.layout.pd_item_message_image, null);
        contentView.setOnClickListener(this);
        return contentView;
    }

    @Override
    public void bindContentView(View v, Message message) {
        ImageView contentView = (ImageView) v;
        MessageContentImage content = (MessageContentImage) message.getContent();
        File file = new File(contentView.getContext().getFilesDir(), content.getDataPath());
        contentView.setImageURI(Uri.fromFile(file));
        contentView.setTag(content);
    }

    @Override
    public void onClick(View v) {
        MessageContentImage content = (MessageContentImage) v.getTag();
        if (contentClickListener != null) contentClickListener.onClick(content);
    }
}

package com.fingo.fenguo.robot.kit.message;

import android.content.Context;
import android.net.Uri;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.ImageView;
import android.widget.TextView;

import com.fingo.fenguo.dev.R;
import com.paradigm.botlib.Message;
import com.paradigm.botlib.MessageContentAudio;
import com.paradigm.botlib.MessageContentRichText;

import java.io.File;

/**
 * Created by wuyifan on 2018/1/31.
 */

public class RichtextMessageItemProvider extends MessageItemProvider implements View.OnClickListener {

    public interface OnContentClickListener {
        void onClick(MessageContentRichText content);
    }

    OnContentClickListener contentClickListener;

    public RichtextMessageItemProvider(OnContentClickListener contentClickListener) {
        this.contentClickListener = contentClickListener;
    }

    @Override
    public View createContentView(Context context) {
        RichtextMessageItemHolder holder = new RichtextMessageItemHolder();
        View contentView = LayoutInflater.from(context).inflate(R.layout.pd_item_message_richtext, null);
        holder.setCover((ImageView) contentView.findViewById(R.id.pd_message_item_cover));
        holder.setTitle((TextView) contentView.findViewById(R.id.pd_message_item_title));
        holder.setDigest((TextView) contentView.findViewById(R.id.pd_message_item_digest));
        contentView.setTag(holder);
        contentView.setOnClickListener(this);
        return contentView;
    }

    @Override
    public void bindContentView(View v, Message message) {
        RichtextMessageItemHolder holder = (RichtextMessageItemHolder) v.getTag();
        MessageContentRichText content = (MessageContentRichText) message.getContent();
        if (content.getCoverPath() != null) {
            File file = new File(v.getContext().getFilesDir(), content.getCoverPath());
            holder.getCover().setImageURI(Uri.fromFile(file));
            holder.getCover().setVisibility(View.VISIBLE);
        } else {
            holder.getCover().setVisibility(View.GONE);
        }
        holder.getTitle().setText(content.getTitle());
        holder.getDigest().setText(content.getDigest());
        holder.setContent(content);
    }

    @Override
    public void onClick(View v) {
        RichtextMessageItemHolder holder = (RichtextMessageItemHolder) v.getTag();
        if (contentClickListener != null) contentClickListener.onClick(holder.getContent());
    }
}

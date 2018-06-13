package com.fingo.fenguo.robot.kit.message;

import android.widget.ImageView;
import android.widget.TextView;

import com.paradigm.botlib.MessageContentRichText;

/**
 * Created by wuyifan on 2018/2/2.
 */

public class RichtextMessageItemHolder {

    private ImageView cover;
    private TextView title;
    private TextView digest;
    private MessageContentRichText content;

    public ImageView getCover() {
        return cover;
    }

    public void setCover(ImageView cover) {
        this.cover = cover;
    }

    public TextView getTitle() {
        return title;
    }

    public void setTitle(TextView title) {
        this.title = title;
    }

    public TextView getDigest() {
        return digest;
    }

    public void setDigest(TextView digest) {
        this.digest = digest;
    }

    public MessageContentRichText getContent() {
        return content;
    }

    public void setContent(MessageContentRichText content) {
        this.content = content;
    }
}

package com.fingo.fenguo.robot.kit;

import android.content.Context;
import android.view.View;
import android.widget.ImageView;
import android.widget.TextView;
import com.fingo.fenguo.dev.R;
/**
 * Created by wuyifan on 2018/1/26.
 */

public class RecordViewHolder {

    private Context context;
    private ImageView recordVolume;
    private TextView recordState;

    private boolean cancel;
    private float volume;

    public RecordViewHolder(View rootView) {
        context = rootView.getContext();
        recordVolume = rootView.findViewById(R.id.pd_record_volume);
        recordState = rootView.findViewById(R.id.pd_record_state);
    }

    public void setCancel(boolean cancel) {
        this.cancel = cancel;
        if (cancel) {
            recordState.setText(R.string.pd_release_and_cancel);
            recordState.setBackgroundResource(R.color.pd_record_cancel);
            recordVolume.setImageDrawable(context.getResources().getDrawable(R.drawable.pd_record_cancel));
        } else {
            recordState.setText(R.string.pd_slideup_and_cancel);
            recordState.setBackgroundResource(R.color.pd_record_finish);
            setVolumeImage();
        }
    }

    public void setVolume(float volume) {
        this.volume = volume;
        if (!cancel) setVolumeImage();
    }

    public boolean isCancel() {
        return cancel;
    }

    public float getVolume() {
        return volume;
    }

    private static final int[] VolumeDrawable = {
            R.drawable.pd_record_volume_1,
            R.drawable.pd_record_volume_2,
            R.drawable.pd_record_volume_3,
            R.drawable.pd_record_volume_4,
            R.drawable.pd_record_volume_5,
            R.drawable.pd_record_volume_6,
            R.drawable.pd_record_volume_7,
            R.drawable.pd_record_volume_8
    };

    private void setVolumeImage() {
        int level = (int) Math.floor(volume * VolumeDrawable.length);
        if (level >= VolumeDrawable.length) level = VolumeDrawable.length - 1;
        int drawable = VolumeDrawable[level];
        recordVolume.setImageDrawable(context.getResources().getDrawable(drawable));
    }
}

package com.fingo.fenguo.robot.kit.util;

import android.content.Context;
import android.media.MediaPlayer;

import com.czt.mp3recorder.MP3Recorder;

import java.io.File;
import java.util.Date;

/**
 * Created by wuyifan on 2018/1/26.
 */

public class AudioTools {

    private Context context;
    private MP3Recorder mediaRecorder;
    private MediaPlayer mediaPlayer;
    private File playingFile;
    private File recodeFile;
    private long recordTime;

    public AudioTools(Context context) {

        this.context = context;
    }

    public void startRecord() {

        stopAllAudio();

        try {
            recodeFile = File.createTempFile("record", ".mp3", context.getCacheDir());
            recodeFile.deleteOnExit();

            mediaRecorder = new MP3Recorder(recodeFile);
            mediaRecorder.start();

        } catch (Exception e) {
            e.printStackTrace();
        }

        recordTime = System.currentTimeMillis();
    }

    public File finishRecord() {
        if (mediaRecorder != null) {
            mediaRecorder.stop();
            mediaRecorder = null;
        }

        if (System.currentTimeMillis()-recordTime<1000) return null;
        return recodeFile;
    }

    public void cancelRecord() {
        if (mediaRecorder != null) {
            mediaRecorder.stop();
            mediaRecorder = null;
        }
    }

    public float getRecordVolume() {
        if (mediaRecorder==null) return 0;
        float volume = (float) (mediaRecorder.getVolume() + 64) / 64;
        if (volume < 0.0f) volume = 0.0f;
        else if (volume > 1.0f) volume = 1.0f;
        return volume;
    }

    public void startPlay(File file) {

        stopAllAudio();

        this.mediaPlayer = new MediaPlayer();
        this.mediaPlayer.setAudioStreamType(android.media.AudioManager.STREAM_MUSIC);

        if (mediaPlayer.isPlaying()) mediaPlayer.stop();

        try {
            mediaPlayer.setDataSource(file.getPath());
            mediaPlayer.prepare();
            mediaPlayer.start();
        } catch (Exception e) {
            e.printStackTrace();
        }

        this.playingFile = file;
    }

    public void stopPlay() {
        if (mediaPlayer != null) {
            mediaPlayer.stop();
            mediaPlayer = null;
        }
    }

    public File getPlayingFile() {
        return mediaPlayer!=null && mediaPlayer.isPlaying() ? playingFile : null;
    }

    private void stopAllAudio() {
        if (mediaRecorder != null) {
            mediaRecorder.stop();
            mediaRecorder = null;
        }

        if (mediaPlayer != null) {
            mediaPlayer.stop();
            mediaPlayer = null;
        }
    }
}

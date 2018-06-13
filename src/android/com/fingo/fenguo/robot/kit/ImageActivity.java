package com.fingo.fenguo.robot.kit;

import android.app.Activity;
import android.graphics.Color;
import android.net.Uri;
import android.os.Bundle;

import java.io.File;

public class ImageActivity extends Activity {
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        String path = getIntent().getExtras().getString("path");
        File file = new File(getFilesDir(), path);

        PinchImageView imageView = new PinchImageView(this);
        imageView.setImageURI(Uri.fromFile(file));
        imageView.setBackgroundColor(Color.BLACK);

        setContentView(imageView);
    }
}

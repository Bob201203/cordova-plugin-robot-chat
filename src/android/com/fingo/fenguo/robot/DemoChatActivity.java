package com.fingo.fenguo.robot;

import android.content.Intent;
import android.os.Bundle;
import android.support.v7.app.ActionBar;
import android.view.Menu;
import android.view.MenuInflater;
import android.view.MenuItem;
import android.widget.TextView;

import com.fingo.fenguo.dev.R;
import com.fingo.fenguo.robot.kit.ChatActivity;
import com.paradigm.botlib.BotLibClient;

/**
 * Created by wuyifan on 2018/2/1.
 */

public class DemoChatActivity extends ChatActivity {
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        ActionBar bar = getSupportActionBar();
        if (bar != null) {
            bar.setCustomView(R.layout.layout_actionbar);
            bar.setDisplayShowCustomEnabled(true);
          //  ((TextView)bar.getCustomView().findViewById(R.id.tv_title)).setText("客服");
        }
    }

    //    @Override
//    public boolean onCreateOptionsMenu(Menu menu) {
//        MenuInflater inflater = getMenuInflater();
////        inflater.inflate(R.menu.menu_chat, menu);
////        return super.onCreateOptionsMenu(menu);
//    }
//
    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        if (item.getItemId() == android.R.id.home) {
            finish();
            return true;
        }
        return super.onOptionsItemSelected(item);
    }

//    @Override
//    public void onConnectionStateChanged(int state) {
//        super.onConnectionStateChanged(state);
//
//        if (state == BotLibClient.ConnectionConnected) {
//            HistoryDataManager.getInstance().addHistory(this, this.botLibClient.getInitInfo().accessKey, this.botLibClient.getRobotName());
//        }
//    }
}

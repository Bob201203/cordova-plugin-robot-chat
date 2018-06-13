package com.fingo.fenguo.robot;

import android.content.Intent;
import android.view.Menu;
import android.view.MenuInflater;
import android.view.MenuItem;

import com.fingo.fenguo.dev.R;
import com.paradigm.botkit.ChatActivity;
import com.paradigm.botlib.BotLibClient;

/**
 * Created by wuyifan on 2018/2/1.
 */

public class DemoChatActivity extends ChatActivity {

    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        MenuInflater inflater = getMenuInflater();
        inflater.inflate(R.menu.menu_chat, menu);
        return super.onCreateOptionsMenu(menu);
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        switch (item.getItemId()) {
            case R.id.menuSetting:
                Intent intent = new Intent();
                intent.setClass(this, SettingActivity.class);
                startActivity(intent);
                return true;

            case R.id.menuClear:
                this.botLibClient.removeAllMessages();
                this.reloadMessageList();
                return true;

            default:
                return super.onOptionsItemSelected(item);
        }
    }

    @Override
    public void onConnectionStateChanged(int state) {
        super.onConnectionStateChanged(state);

        if (state == BotLibClient.ConnectionConnected) {
            HistoryDataManager.getInstance().addHistory(this, this.botLibClient.getInitInfo().accessKey, this.botLibClient.getRobotName());
        }
    }
}

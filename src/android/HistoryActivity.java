package com.fingo.fenguo.robot;

import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.support.v7.app.ActionBar;
import android.support.v7.app.AppCompatActivity;
import android.view.LayoutInflater;
import android.view.MenuItem;
import android.view.View;
import android.view.ViewGroup;
import android.widget.AdapterView;
import android.widget.BaseAdapter;
import android.widget.ListView;
import android.widget.TextView;

import java.util.List;

public class HistoryActivity extends AppCompatActivity implements AdapterView.OnItemClickListener {

    private List<HistoryDataManager.HistoryDataItem> historyDataList;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        ActionBar actionBar = getSupportActionBar();
        if (actionBar != null) {
            actionBar.setHomeButtonEnabled(true);
            actionBar.setDisplayHomeAsUpEnabled(true);
        }

        this.historyDataList =  HistoryDataManager.getInstance().getHistoryDataList(this);

        HistoryDataAdapter adapter = new HistoryDataAdapter(this,this.historyDataList);
        ListView listView = new ListView(this);
        listView.setAdapter(adapter);
        listView.setOnItemClickListener(this);
        this.setContentView(listView);
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        switch (item.getItemId()) {
            case android.R.id.home:
                finish();
                return true;

            default:
                return super.onOptionsItemSelected(item);
        }
    }

    @Override
    public void onItemClick(AdapterView<?> parent, View view, int position, long id) {
        Intent intent = new Intent();
        intent.putExtra("accessKey", this.historyDataList.get(position).accessKey);
        this.setResult(RESULT_OK, intent);
        this.finish();
    }

    class HistoryDataAdapter extends BaseAdapter {

        private Context context;
        private List<HistoryDataManager.HistoryDataItem> historyDataList;

        public HistoryDataAdapter(Context context, List<HistoryDataManager.HistoryDataItem> historyDataList) {
            this.context = context;
            this.historyDataList = historyDataList;
        }

        @Override
        public int getCount() {
            return historyDataList.size();
        }

        @Override
        public Object getItem(int position) {
            return historyDataList.get(position);
        }

        @Override
        public long getItemId(int position) {
            return position;
        }

        @Override
        public View getView(int position, View convertView, ViewGroup parent) {

            if (convertView == null) {
                LayoutInflater inflater = LayoutInflater.from(context);
                convertView = inflater.inflate(android.R.layout.simple_list_item_2, null);
            }

            HistoryDataManager.HistoryDataItem item = historyDataList.get(position);
            TextView text1 = convertView.findViewById(android.R.id.text1);
            TextView text2 = convertView.findViewById(android.R.id.text2);
            text1.setText(item.robotName);
            text2.setText(item.accessKey);

            return convertView;
        }
    }
}

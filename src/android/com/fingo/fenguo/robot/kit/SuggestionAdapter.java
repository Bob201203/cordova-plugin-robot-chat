package com.fingo.fenguo.robot.kit;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.TextView;

import com.paradigm.botlib.MenuItem;

import java.util.ArrayList;

import com.fingo.fenguo.dev.R;

/**
 * Created by wuyifan on 2018/2/1.
 */

public class SuggestionAdapter extends BaseAdapter {

    private Context context;
    private ArrayList<MenuItem> suggestionList;

    public SuggestionAdapter(Context context) {
        this.context = context;
    }

    @Override
    public int getCount() {
        return suggestionList==null ? 0 : suggestionList.size();
    }

    @Override
    public Object getItem(int position) {
        return suggestionList.get(position);
    }

    @Override
    public long getItemId(int position) {
        return position;
    }

    @Override
    public View getView(int position, View convertView, ViewGroup parent) {

        TextView view = (TextView)convertView;
        if (view==null) view = (TextView) LayoutInflater.from(context).inflate(R.layout.pd_item_suggestion, null);

        MenuItem item = suggestionList.get(position);
        view.setText(item.getContent());
        //itemView.setOnClickListener(this);
        view.setTag(item);

        return view;
    }

    public void setSuggestionList(ArrayList<MenuItem> suggestionList) {
        this.suggestionList = suggestionList;
        notifyDataSetChanged();
    }
}

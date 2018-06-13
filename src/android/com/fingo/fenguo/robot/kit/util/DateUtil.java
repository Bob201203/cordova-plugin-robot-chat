package com.fingo.fenguo.robot.kit.util;

import android.content.Context;

import com.fingo.fenguo.dev.R;

import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.Locale;
import java.util.TimeZone;

/**
 * 日期时间工具类
 */
public class DateUtil {

    // 时:分
    private SimpleDateFormat dateFormatToday;

    // 星期 时:分
    private SimpleDateFormat dateFormatThisweek;

    // 年-月-日 时:分
    private SimpleDateFormat dateFormatOther;

    private long today;
    private long yesterday;
    private long thisWeek;
    private String yesterdayString;

    public DateUtil(Context context) {
        dateFormatToday = new SimpleDateFormat("HH:mm", Locale.getDefault());
        dateFormatThisweek = new SimpleDateFormat("E HH:mm", Locale.getDefault());
        dateFormatOther = new SimpleDateFormat("MM-dd HH:mm", Locale.getDefault());

        yesterdayString = " " + context.getString(R.string.pd_yesterday);
    }

    public void refreash() {
        long current = System.currentTimeMillis();
        today = current / (1000 * 3600 * 24) * (1000 * 3600 * 24) - TimeZone.getDefault().getRawOffset();
        yesterday = today - 1000 * 3600 * 24;
        thisWeek = today - 1000 * 3600 * 24 * 7;
    }

    public String timeStringFromDate(Date date) {
        long d = date.getTime();
        if (d >= today) return dateFormatToday.format(date);
        if (d >= yesterday) return yesterdayString + dateFormatToday.format(date);
        if (d >= thisWeek) return dateFormatThisweek.format(date);
        return dateFormatOther.format(date);
    }
}

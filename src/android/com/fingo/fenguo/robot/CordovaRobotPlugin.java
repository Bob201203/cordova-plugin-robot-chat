package com.fingo.fenguo.robot;

import android.content.Context;
import android.content.Intent;
import android.content.pm.ApplicationInfo;
import android.content.pm.PackageManager;

import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.CallbackContext;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

/**
 * This class echoes a string called from JavaScript.
 */
public class CordovaRobotPlugin extends CordovaPlugin {
    @Override
    public boolean execute(String action, JSONArray args, CallbackContext callbackContext) throws JSONException {
        if (action.equals("coolMethod")) {
            JSONObject angluarJSON = args.getJSONObject(0);
  
            this.coolMethod(angluarJSON, callbackContext);
            return true;
        }
        return false;
    }

    private void coolMethod(JSONObject angluarJSON, CallbackContext callbackContext) {
        Context context=this.cordova.getActivity().getApplicationContext();
        Intent intent = new Intent();
        intent.setClass(context, DemoChatActivity.class);

        String texttitle = null;
        String bg = null;
        String avatar = null;

        try {
            texttitle = angluarJSON.getString("title");
            bg = angluarJSON.getString("bg");
            avatar = angluarJSON.getString("avatar");
        } catch (JSONException e) {

        }

        if (texttitle != null && texttitle.length() > 0) {
            intent.putExtra("angluar_fingguo_title",texttitle);
        }

        if (bg != null && bg.length() > 0) {
            intent.putExtra("angluar_fingguo_image_src_avatar_backgrougd",bg);
        }

        if (avatar != null && avatar.length() > 0) {
            intent.putExtra("angluar_fingguo_image_src_avatar",avatar);
        }

        try {
            ApplicationInfo appInfo = context.getPackageManager().getApplicationInfo(context.getPackageName(), PackageManager.GET_META_DATA);
            String accesskey = appInfo.metaData.getString("ROBOT_SERVICE_APPKEY");
            intent.putExtra("accessKey", accesskey);
            this.cordova.getActivity().startActivity(intent);
            callbackContext.success("");
        } catch (PackageManager.NameNotFoundException e) {
            e.printStackTrace();
            callbackContext.error("Can't get accessKey.");
        }
    }
}


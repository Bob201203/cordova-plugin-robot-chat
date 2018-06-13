package com.fingo.fenguo.robot.kit;

import android.Manifest;
import android.app.Activity;
import android.content.ContentValues;
import android.content.Context;
import android.content.Intent;
import android.content.pm.PackageInfo;
import android.content.pm.PackageManager;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.Paint;
import android.graphics.PorterDuff;
import android.graphics.PorterDuffXfermode;
import android.graphics.Rect;
import android.graphics.RectF;
import android.graphics.drawable.BitmapDrawable;
import android.graphics.drawable.Drawable;
import android.net.Uri;
import android.os.Build;
import android.os.Bundle;
import android.os.Handler;
import android.provider.MediaStore;
import android.support.v4.content.PermissionChecker;
import android.support.v7.app.AppCompatActivity;
import android.text.Editable;
import android.text.TextWatcher;
import android.util.Log;
import android.view.MotionEvent;
import android.view.View;
import android.view.inputmethod.InputMethodManager;
import android.widget.AdapterView;
import android.widget.Button;
import android.widget.EditText;
import android.widget.GridLayout;
import android.widget.ImageButton;
import android.widget.ImageView;
import android.widget.ListView;
import android.widget.TextView;

import com.fingo.fenguo.robot.kit.message.AudioMessageItemProvider;
import com.fingo.fenguo.robot.kit.message.ImageMessageItemProvider;
import com.fingo.fenguo.robot.kit.message.MenuMessageItemProvider;
import com.fingo.fenguo.robot.kit.message.RichtextMessageItemProvider;
import com.fingo.fenguo.robot.kit.message.TextMessageItemProvider;
import com.fingo.fenguo.robot.kit.util.AudioTools;
import com.fingo.fenguo.robot.kit.util.ImageUtil;
import com.fingo.fenguo.robot.kit.util.StreamUtil;
import com.paradigm.botlib.BotInitInfo;
import com.paradigm.botlib.BotLibClient;
import com.paradigm.botlib.MenuItem;
import com.paradigm.botlib.Message;
import com.paradigm.botlib.MessageContentAudio;
import com.paradigm.botlib.MessageContentImage;
import com.paradigm.botlib.MessageContentRichText;


import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Timer;
import java.util.TimerTask;

import com.fingo.fenguo.dev.R;

public class ChatActivity extends AppCompatActivity {

    private static final String TAG = "ChatActivity";

    private static final int RequestCodeCamera = 1;
    private static final int RequestCodeAlbum = 2;

    private static final int PluginPhoto = 1001;
    private static final int PluginCamera = 1002;

    private static final long MaxImageSize = 1024 * 1024;

    protected BotLibClient botLibClient;

    protected ListView messageList;
    protected ListView suggestionList;
    protected EditText inputText;
  //  protected Button inputRecord;
 //   protected ImageButton inputKey;
    protected ImageButton inputAudio;
    protected ImageButton inputPlugin;
    protected Button inputSend;

    private GridLayout pluginBack;
    private PluginViewHolder pluginViewHolder;

    protected View recordBack;
    protected RecordViewHolder recordViewHolder;
    protected Timer recordTimer;
    protected ImageView ivBack;
    protected TextView tvTitle;

    private AudioTools audioTools;
    private MessageContentAudio audioPlayingMessage;
    private Uri uriCapture;

    private MessageAdapter messageAdapter;
    private SuggestionAdapter suggestionAdapter;
    private ArrayList<Message> messageData;

    private Handler handler = new Handler();


    /**
     * 把两个位图覆盖合成为一个位图，以底层位图的长宽为基准
     * @param backBitmap 在底部的位图
     * @param frontBitmap 盖在上面的位图
     * @return
     */
    private Bitmap mergeBitmap(Bitmap backBitmap, Bitmap frontBitmap) {

        if (backBitmap == null || backBitmap.isRecycled()
                || frontBitmap == null || frontBitmap.isRecycled()) {
            Log.e(TAG, "backBitmap=" + backBitmap + ";frontBitmap=" + frontBitmap);
            return null;
        }
        Bitmap bitmap = backBitmap.copy(Bitmap.Config.ARGB_8888, true);
        Canvas canvas = new Canvas(bitmap);
        Rect baseRect  = new Rect(0, 0, backBitmap.getWidth(), backBitmap.getHeight());
        Rect frontRect = new Rect(0, 0, frontBitmap.getWidth(), frontBitmap.getHeight());
        canvas.drawBitmap(frontBitmap, frontRect, baseRect, null);
        return bitmap;
    }

    private Bitmap getCircleBitmap(Bitmap bitmap) {
        if (bitmap == null) {
            return null;
        }
        try {
            Bitmap circleBitmap = Bitmap.createBitmap(bitmap.getWidth(),
                    bitmap.getHeight(), Bitmap.Config.ARGB_8888);
            Canvas canvas = new Canvas(circleBitmap);
            final Paint paint = new Paint();
            final Rect rect = new Rect(0, 0, bitmap.getWidth(),
                    bitmap.getHeight());
            final RectF rectF = new RectF(new Rect(0, 0, bitmap.getWidth(),
                    bitmap.getHeight()));
            float roundPx = 0.0f;
            // 以较短的边为标准
            if (bitmap.getWidth() > bitmap.getHeight()) {
                roundPx = bitmap.getHeight() / 2.0f;
            } else {
                roundPx = bitmap.getWidth() / 2.0f;
            }
            paint.setAntiAlias(true);
            canvas.drawARGB(0, 0, 0, 0);
            paint.setColor(Color.WHITE);
            canvas.drawRoundRect(rectF, roundPx, roundPx, paint);
            paint.setXfermode(new PorterDuffXfermode(PorterDuff.Mode.SRC_IN));
            final Rect src = new Rect(0, 0, bitmap.getWidth(),
                    bitmap.getHeight());
            canvas.drawBitmap(bitmap, src, rect, paint);
            return circleBitmap;
        } catch (Exception e) {
            return bitmap;
        }
    }


    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.pd_activity_chat);

        audioTools = new AudioTools(this);
        initViews();
        initBotLib();
    }

    @Override
    protected void onNewIntent(Intent intent) {
        super.onNewIntent(intent);
        setIntent(intent);
        initBotLib();
    }

    @Override
    protected void onStop() {
        super.onStop();
        audioTools.stopPlay();
        audioTools.cancelRecord();
    }

    private void initViews() {
        messageList = findViewById(R.id.pd_message_list);
        suggestionList = findViewById(R.id.pd_suggestion_list);
        inputText = findViewById(R.id.pd_input_text);
    //    inputRecord = findViewById(R.id.pd_input_record);
    //    inputKey = findViewById(R.id.pd_input_key);
        inputAudio = findViewById(R.id.pd_input_audio);
        inputPlugin = findViewById(R.id.pd_input_plugin);
//        inputSend = findViewById(R.id.pd_input_send);

        pluginBack = findViewById(R.id.pd_plgin_back);
        pluginViewHolder = new PluginViewHolder(pluginBack);

        recordBack = findViewById(R.id.pd_record_back);
        recordViewHolder = new RecordViewHolder(recordBack);

        tvTitle = findViewById(R.id.pd_tv_title);
        ivBack = findViewById(R.id.pd_iv_back);

        Bundle extras = getIntent().getExtras();
        String pluginTitle  = extras.getString("angluar_fingguo_title");

        if (pluginTitle !=null  && pluginTitle.length() > 0 ){
            tvTitle.setText(pluginTitle);
        }

//        tvTitle.setText("xxx");
        ivBack.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                finish();
            }
        });

//        inputKey.setOnClickListener(new View.OnClickListener() {
//            @Override
//            public void onClick(View v) {
//                inputKey.setVisibility(View.GONE);
//                inputAudio.setVisibility(View.VISIBLE);
//                inputText.setVisibility(View.VISIBLE);
//         //       inputRecord.setVisibility(View.GONE);
//                showKeyboard();
////                setSendButton();
//            }
//        });

        inputPlugin.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                String text = inputText.getText().toString().trim();
                if (text.length() > 0) {
                    botLibClient.askQuestion(text);
                    inputText.setText("");
                }
//                inputKey.setVisibility(View.VISIBLE);
//                inputAudio.setVisibility(View.GONE);
//                inputText.setVisibility(View.GONE);
//                inputRecord.setVisibility(View.VISIBLE);
//                pluginBack.setVisibility(View.GONE);
//                suggestionList.setVisibility(View.GONE);
//                hideKeyboard();
//                setSendButton();

            }
        });

        inputAudio.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                getPhotoFromAlbum();
//                if (pluginBack.getVisibility() == View.GONE) {
//                    pluginBack.setVisibility(View.VISIBLE);
//                    hideKeyboard();
//                    if (inputRecord.getVisibility() == View.VISIBLE) {
//                        inputKey.setVisibility(View.GONE);
//                        inputAudio.setVisibility(View.VISIBLE);
//                        inputText.setVisibility(View.VISIBLE);
//                        inputRecord.setVisibility(View.GONE);
//                        setSendButton();
//                    }
//                } else {
//                    pluginBack.setVisibility(View.GONE);
//                }
            }
        });

        inputText.addTextChangedListener(new TextWatcher() {
            @Override
            public void beforeTextChanged(CharSequence s, int start, int count, int after) {
            }

            @Override
            public void onTextChanged(CharSequence s, int start, int before, int count) {
            }

            @Override
            public void afterTextChanged(Editable s) {
//                setSendButton();
                String text = s.toString().trim();
                if (text.length() > 0)
                    botLibClient.askSuggestion(text);
                else
                    suggestionList.setVisibility(View.GONE);
            }
        });

        inputText.setOnTouchListener(new View.OnTouchListener() {
            @Override
            public boolean onTouch(View v, MotionEvent event) {
                pluginBack.setVisibility(View.GONE);
                showKeyboard();
                return false;
            }
        });

//        inputRecord.setOnTouchListener(new View.OnTouchListener() {
//            @Override
//            public boolean onTouch(View v, MotionEvent event) {
//                switch (event.getAction()) {
//                    case MotionEvent.ACTION_DOWN:
//                        inputRecord.setText(R.string.pd_release_to_send);
//                        startRecord();
//                        break;
//                    case MotionEvent.ACTION_UP:
//                        inputRecord.setText(R.string.pd_hold_to_talk);
//                        if (recordViewHolder.isCancel())
//                            cancelRecord();
//                        else
//                            finishRecord();
//                        break;
//                    case MotionEvent.ACTION_MOVE:
//                        if (event.getY() < 10) {
//                            inputRecord.setText(R.string.pd_release_to_cancel);
//                            recordViewHolder.setCancel(true);
//                        } else {
//                            inputRecord.setText(R.string.pd_release_to_send);
//                            recordViewHolder.setCancel(false);
//                        }
//                        break;
//                }
//                return true;
//            }
//        });

        pluginViewHolder.insertItem(R.drawable.pd_plugin_photo, R.string.pd_photo, PluginPhoto);
        pluginViewHolder.insertItem(R.drawable.pd_plugin_camera, R.string.pd_camera, PluginCamera);
        pluginViewHolder.setOnPluginClickListener(new PluginViewHolder.OnPluginClickListener() {
            @Override
            public void onClick(int tag) {
                pluginBack.setVisibility(View.GONE);
                if (tag == PluginPhoto) {
                    getPhotoFromAlbum();
                } else if (tag == PluginCamera) {
                    getPhotoFromCamera();
                }
            }
        });

//        inputSend.setOnClickListener(new View.OnClickListener() {
//            @Override
//            public void onClick(View v) {
//                String text = inputText.getText().toString().trim();
//                if (text.length() > 0) {
//                    botLibClient.askQuestion(text);
//                    inputText.setText("");
//                }
//            }
//        });
    }

    private void initBotLib() {

        Bundle extras = getIntent().getExtras();
        BotInitInfo initInfo = new BotInitInfo();
        initInfo.accessKey = extras.getString("accessKey");
        initInfo.userId = extras.getString("userId");

        botLibClient = new BotLibClient(this, initInfo);
        botLibClient.setConnectionListener(new BotLibClient.ConnectionListener() {
            @Override
            public void onConnectionStateChanged(int state) {
                switch (state) {
                    case BotLibClient.ConnectionIdel:
                        setTitle(R.string.pd_connection_closed);
                        break;
                    case BotLibClient.ConnectionConnecting:
                        setTitle(R.string.pd_connecting);
                        break;
                    case BotLibClient.ConnectionConnected:
                        setTitle(botLibClient.getRobotName());
                        break;
                    default:
                        setTitle(R.string.pd_connection_failed);
                }
            }
        });

        botLibClient.setMessageListener(new BotLibClient.MessageListener() {
            @Override
            public void onReceivedSuggestion(ArrayList<MenuItem> suggestions) {
                suggestionAdapter.setSuggestionList(suggestions);
                suggestionList.setVisibility(suggestions.isEmpty() ? View.GONE : View.VISIBLE);
            }

            @Override
            public void onAppendMessage(Message message) {
                messageData.add(message);
                messageAdapter.notifyDataSetChanged();
            }
        });

//        Bitmap bitmap = null;
//        try {
//            bitmap = BitmapFactory.decodeStream(getAssets().open("www/assets/floki/avatar.png"));
//        } catch (IOException e) {
//            e.printStackTrace();
//        }
//        messageAdapter = new MessageAdapter(this);
//
//        if (bitmap != null) {
//            messageAdapter.setPortraitRobot(new BitmapDrawable(getResources(), bitmap));
//        }


        String bg = null;
        String avatarImage = null;
        bg = extras.getString("angluar_fingguo_image_src_avatar_backgrougd");
        avatarImage =  extras.getString("angluar_fingguo_image_src_avatar");

        Bitmap bitmapBg = null;
        Bitmap  bitmapAvatar  =  null;

        if (bg !=null && avatarImage != null) {
            try {
                bitmapBg = BitmapFactory.decodeStream(getAssets().open(bg));
                bitmapAvatar= BitmapFactory.decodeStream(getAssets().open(avatarImage));
            } catch (IOException e) {
                e.printStackTrace();
            }
        }

        messageAdapter = new MessageAdapter(this);

        if (bitmapBg != null && bitmapAvatar!=null) {
            Bitmap ava = this.mergeBitmap(bitmapBg,bitmapAvatar);

            if (ava !=null) {
                ava =  this.getCircleBitmap(ava);

                Drawable drawable = new BitmapDrawable(ava);
                this.messageAdapter.setPortraitRobot(drawable);
            }
        }

        messageAdapter.setPortraitUser(getResources().getDrawable(R.drawable.image_support_avatar));
        messageAdapter.setMessageItemProvider(Message.ContentTypeText, new TextMessageItemProvider());
        messageAdapter.setMessageItemProvider(Message.ContentTypeMenu, new MenuMessageItemProvider(new MenuMessageItemProvider.OnContentClickListener() {
            @Override
            public void onItemClick(MenuItem item, int type) {
                botLibClient.askQuestion(item, type);
            }
        }));
        messageAdapter.setMessageItemProvider(Message.ContentTypeImage, new ImageMessageItemProvider(new ImageMessageItemProvider.OnContentClickListener() {
            @Override
            public void onClick(MessageContentImage content) {
                Intent intent = new Intent();
                intent.setClass(ChatActivity.this, ImageActivity.class);
                intent.putExtra("path", content.getDataPath());
                startActivity(intent);
            }
        }));
        messageAdapter.setMessageItemProvider(Message.ContentTypeAudio, new AudioMessageItemProvider(new AudioMessageItemProvider.OnContentClickListener() {
            @Override
            public void onClick(MessageContentAudio content) {
                File file = new File(getFilesDir(), content.getDataPath());
                if (audioTools.getPlayingFile()!=null && audioPlayingMessage==content) {
                    audioTools.stopPlay();
                    audioPlayingMessage = null;
                }
                else {
                    audioTools.startPlay(file);
                    audioPlayingMessage = content;
                }
            }
        }));
        messageAdapter.setMessageItemProvider(Message.ContentTypeRichText, new RichtextMessageItemProvider(new RichtextMessageItemProvider.OnContentClickListener() {
            @Override
            public void onClick(MessageContentRichText content) {
                Intent intent = new Intent();
                intent.setClass(ChatActivity.this, WebActivity.class);
                intent.putExtra("url", content.getUrl());
                startActivity(intent);
            }
        }));

        Calendar cal = Calendar.getInstance();
        cal.add(Calendar.DATE, -30);
        botLibClient.removeMessage(cal.getTime());

        messageData = new ArrayList<>();
        messageAdapter.setMessageData(messageData);
        messageList.setAdapter(messageAdapter);

        suggestionAdapter = new SuggestionAdapter(this);
        suggestionList.setAdapter(suggestionAdapter);
        suggestionList.setOnItemClickListener(new AdapterView.OnItemClickListener() {
            @Override
            public void onItemClick(AdapterView<?> parent, View view, int position, long id) {
                MenuItem item = (MenuItem) suggestionList.getItemAtPosition(position);
                botLibClient.askQuestion(item.getContent());
                inputText.setText("");
            }
        });

        reloadMessageList();
        botLibClient.connect();
    }

    protected void reloadMessageList()
    {
        messageData.clear();
        messageData.addAll(botLibClient.getMessageList());
        messageAdapter.notifyDataSetChanged();
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        super.onActivityResult(requestCode, resultCode, data);
        if (requestCode == RequestCodeCamera) {
            if (resultCode == Activity.RESULT_OK) {
                File imgFile = null;
                try {
                    imgFile = File.createTempFile("photo", ".jpg", getCacheDir());
                    FileOutputStream os = new FileOutputStream(imgFile);
                    InputStream is = getContentResolver().openInputStream(uriCapture);
                    long fileSize = StreamUtil.StreamTransfer(is, os);
                    os.close();
                    is.close();

                    if (fileSize > MaxImageSize) {
                        File tmpFile = File.createTempFile("photo", ".jpg", getCacheDir());
                        ImageUtil.compressImage(imgFile, 4000, 4000, Bitmap.CompressFormat.JPEG, 80, tmpFile.getPath());
                        imgFile.delete();
                        imgFile = tmpFile;
                    }

                } catch (Exception e) {
                    e.printStackTrace();
                }

                getContentResolver().delete(uriCapture, null, null);
                if (imgFile != null) botLibClient.askQuestionImage(imgFile);
            }
        } else if (requestCode == RequestCodeAlbum) {
            if (resultCode == Activity.RESULT_OK) {
                Uri imgUri = data.getData();
                File imgFile = null;
                try {
                    imgFile = File.createTempFile("photo", ".jpg", getCacheDir());
                    FileOutputStream os = new FileOutputStream(imgFile);
                    InputStream is = getContentResolver().openInputStream(imgUri);
                    long fileSize = StreamUtil.StreamTransfer(is, os);
                    os.close();
                    is.close();

                    if (fileSize > MaxImageSize) {
                        File tmpFile = File.createTempFile("photo", ".jpg", getCacheDir());
                        ImageUtil.compressImage(imgFile, 4000, 4000, Bitmap.CompressFormat.JPEG, 80, tmpFile.getPath());
                        imgFile.delete();
                        imgFile = tmpFile;
                    }

                } catch (Exception e) {
                    e.printStackTrace();
                }

                if (imgFile != null) botLibClient.askQuestionImage(imgFile);
            }
        }
    }

    private void showKeyboard() {
        inputText.requestFocus();
        InputMethodManager inputMethodManager = (InputMethodManager) getSystemService(Context.INPUT_METHOD_SERVICE);
        inputMethodManager.showSoftInput(inputText, 0);
    }

    private void hideKeyboard() {
        InputMethodManager inputMethodManager = (InputMethodManager) getSystemService(Context.INPUT_METHOD_SERVICE);
        inputMethodManager.hideSoftInputFromWindow(inputText.getWindowToken(), InputMethodManager.HIDE_NOT_ALWAYS);
    }

    private void setSendButton() {
        boolean showSend = inputText.getVisibility() == View.VISIBLE && inputText.getText().length() > 0;
//        inputSend.setVisibility(showSend ? View.VISIBLE : View.GONE);
        inputPlugin.setVisibility(showSend ? View.GONE : View.VISIBLE);
    }

    private void startRecord() {
        if (!selfPermissionGranted(Manifest.permission.RECORD_AUDIO)) return;
        audioTools.startRecord();
        recordBack.setVisibility(View.VISIBLE);
        recordViewHolder.setCancel(false);
        recordViewHolder.setVolume(0.0f);

        recordTimer = new Timer();
        recordTimer.schedule(new TimerTask() {
            public void run() {
                handler.post(new Runnable() {
                    @Override
                    public void run() {
                        recordViewHolder.setVolume(audioTools.getRecordVolume());
                    }
                });
            }
        }, 500, 500);
    }

    private void finishRecord() {
        if (recordTimer!=null) {
            recordTimer.cancel();
            recordTimer = null;
        }

        File file = audioTools.finishRecord();
        recordBack.setVisibility(View.GONE);

        if (file != null) botLibClient.askQuestionAudio(file);
    }

    private void cancelRecord() {
        if (recordTimer!=null) {
            recordTimer.cancel();
            recordTimer = null;
        }

        audioTools.cancelRecord();
        recordBack.setVisibility(View.GONE);
    }

    private void getPhotoFromCamera() {
        if (!selfPermissionGranted(Manifest.permission.WRITE_EXTERNAL_STORAGE)) return;

        String name = "photo" + System.currentTimeMillis();
        ContentValues contentValues = new ContentValues();
        contentValues.put(MediaStore.Images.Media.TITLE, name);
        contentValues.put(MediaStore.Images.Media.DISPLAY_NAME, name + ".jpeg");
        contentValues.put(MediaStore.Images.Media.MIME_TYPE, "image/jpeg");
        uriCapture = getContentResolver().insert(MediaStore.Images.Media.EXTERNAL_CONTENT_URI, contentValues);

        Intent intent = new Intent(MediaStore.ACTION_IMAGE_CAPTURE);
        intent.putExtra(MediaStore.EXTRA_OUTPUT, uriCapture);
        startActivityForResult(intent, RequestCodeCamera);
    }

    private void getPhotoFromAlbum() {
        Intent intent = new Intent();
        intent.setAction(Intent.ACTION_PICK);
        intent.setData(MediaStore.Images.Media.EXTERNAL_CONTENT_URI);
        startActivityForResult(intent, RequestCodeAlbum);
    }

    public void setPortraitUser(Drawable portraitUser) {
        messageAdapter.setPortraitUser(portraitUser);
    }

    public void setPortraitRobot(Drawable portraitRobot) {
        messageAdapter.setPortraitRobot(portraitRobot);
    }

    public boolean selfPermissionGranted(String permission) {
        // For Android < Android M, self permissions are always granted.
        boolean result = true;

        int targetSdkVersion = 0;
        try {
            final PackageInfo info = getPackageManager().getPackageInfo(getPackageName(), 0);
            targetSdkVersion = info.applicationInfo.targetSdkVersion;
        } catch (PackageManager.NameNotFoundException e) {
            e.printStackTrace();
        }

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {

            if (targetSdkVersion >= Build.VERSION_CODES.M) {
                // targetSdkVersion >= Android M, we can
                // use Context#checkSelfPermission
                result = checkSelfPermission(permission) == PackageManager.PERMISSION_GRANTED;
                if (!result) requestPermissions(new String[]{permission}, 0);
            } else {
                // targetSdkVersion < Android M, we have to use PermissionChecker
                result = PermissionChecker.checkSelfPermission(this, permission) == PermissionChecker.PERMISSION_GRANTED;
            }
        }

        return result;
    }
}

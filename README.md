# cordova-plugin-robot-chat

本工程把第四范式的智能客服native sdk封装成了cordova插件。
了解产品说明，https://www.4paradigm.com/product/bot

## How to use:
1. clone this project
2. remove the old plugin from the project
  ```
  cordova plugin remove cordova-plugin-robot-chat
  ```

3. add the plugin
  ```
  cordova plugin add https://github.com/YuchuanGu/cordova-plugin-robot-chat.git --variable APP_KEY=YOUR_APPKEY
  ```

4. 修改config.xml
  ```
  <platform name="ios">
    <config-file parent="NSMicrophoneUsageDescription" target="*-Info.plist" mode="merge">
      <string>Need microphone access to record voice messages</string>
    </config-file>
    ...
  ```

5. 定制化UI样式
  参考:
  Android
    - android/com/fingo/fenguo/robot 源码
    - android/res下的资源
  iOS
    - ios 下的 源码、资源

6. 调用Sample
  ```
  let title = "芬果客服";
  let portraitBg = domain + 'portrait_bg.png';
  let portrait = domain + 'portrait_head.png';
  let sendData = {
      title: title,
      bg: portraitBg,
      avatar: portrait
    };

  let cordova: any = window['cordova'];
  cordova.plugins.RobotChat.coolMethod(sendData,
    function (res) {
      console.log('success');
    },
    function (msg) {
      console.log('fail msg');
    });
  ```


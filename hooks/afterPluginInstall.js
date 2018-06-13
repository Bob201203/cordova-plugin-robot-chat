module.exports = function(ctx) {
    if (ctx.opts.plugin.platform.indexOf('android') < 0) {
        return;
    }

    var fs = ctx.requireCordovaModule('fs'),
        path = ctx.requireCordovaModule('path'),
        deferral = ctx.requireCordovaModule('q').defer();

    var configFile = path.join(ctx.opts.projectRoot, 'config.xml');
    fs.readFile(configFile, "utf8", function(err, data) {
        if (err) {
            deferral.reject("ailed to read preject's config.xml");
            throw err;
        }
        var lines = data.split('\n');
        var bindId = null;
        try {
            lines.forEach(function(line){
                console.log(line);
                if (line.indexOf('<widget') >= 0) {
                    var idx_begin = line.indexOf('id="');
                    if (idx_begin > 0) {
                        var idx_end = line.indexOf('"', idx_begin + 5);
                        if (idx_end > 0) {
                            console.log (idx_begin + " --- " + idx_end);
                            bindId = line.substr(idx_begin+4, idx_end-(idx_begin+4));
                            console.log(bindId);
                        }
                    }
                    throw e;
                }
            });
        } catch (e) {

        }
        if (bindId == null) {    
            deferral.reject('failed to pick bindId');
            throw err;
        }
        var files = [
            "com/fingo/fenguo/robot/DemoChatActivity.java",
            "com/fingo/fenguo/robot/HistoryActivity.java",
            "com/fingo/fenguo/robot/HistoryDataManager.java",
            "com/fingo/fenguo/robot/ScanActivity.java",
            "com/fingo/fenguo/robot/SettingActivity.java",

            "com/fingo/fenguo/robot/kit/ChatActivity.java",
            "com/fingo/fenguo/robot/kit/ImageActivity.java",
            "com/fingo/fenguo/robot/kit/MessageAdapter.java",
            "com/fingo/fenguo/robot/kit/PinchImageView.java",
            "com/fingo/fenguo/robot/kit/PluginViewHolder.java",
            "com/fingo/fenguo/robot/kit/RecordViewHolder.java",
            "com/fingo/fenguo/robot/kit/SuggestionAdapter.java",
            "com/fingo/fenguo/robot/kit/WebActivity.java",

            "com/fingo/fenguo/robot/kit/message/AudioMessageItemProvider.java",
            "com/fingo/fenguo/robot/kit/message/ImageMessageItemProvider.java",
            "com/fingo/fenguo/robot/kit/message/MenuMessageItemProvider.java",
            "com/fingo/fenguo/robot/kit/message/MessageItemHolder.java",
            "com/fingo/fenguo/robot/kit/message/MessageItemProvider.java",
            "com/fingo/fenguo/robot/kit/message/RichtextMessageItemHolder.java",
            "com/fingo/fenguo/robot/kit/message/RichtextMessageItemProvider.java",
            "com/fingo/fenguo/robot/kit/message/TextMessageItemProvider.java",

            "com/fingo/fenguo/robot/kit/util/AudioTools.java",
            "com/fingo/fenguo/robot/kit/util/DateUtil.java",
            "com/fingo/fenguo/robot/kit/util/ImageUtil.java",
            "com/fingo/fenguo/robot/kit/util/StreamUtil.java",

            "pl/droidsonroids/gif/GifTextureView.java",
            "pl/droidsonroids/gif/GifViewUtils.java",
            "pl/droidsonroids/gif/ReLinker.java"
        ];
        //var sourceDir = ctx.opts.plugin.dir;
        var sourceDir = ctx.opts.projectRoot + "/platforms/android/app/src/main/java/"

        files.forEach(function(filename) {
            var entitlementPath = sourceDir + filename;
            if (fs.existsSync(entitlementPath)) {
                fs.readFile(entitlementPath, "utf8", function(err, data) {
                    if (err) {
                        deferral.reject('failed to replace app bindle id in cordova-plugin-robot-service');
                        throw err;
                    }

                    console.log("Reading " + filename + " file asynchronously");

                    let re1 = new RegExp('com.fingo.fenguo.dev');
                    let matched = data.match(re1);
                    let result;
                    if (matched !== null) {
                        result = data.replace(re1, bindId);          
                        // write result to entitlements file
                        fs.writeFile(entitlementPath, result, {"encoding": 'utf8'}, function(err) {
                            if (err) {
                                deferral.reject('failed to replace app bindle id in cordova-plugin-robot-service');
                                throw err;
                            }
                            console.log(entitlementPath + " written successfully");
                        });
                    }
                }); 
            }
        });
        deferral.resolve();
    });

    return deferral.promise;
};

module.exports = function(ctx) {
    var fs = ctx.requireCordovaModule('fs'),
        path = ctx.requireCordovaModule('path'),
        deferral = ctx.requireCordovaModule('q').defer();
    var targetDir = path.join(ctx.opts.projectRoot, "platforms/android/");
    if (!fs.existsSync(targetDir)) {
    	console.log("path not found " + targetDir);
    	return;
    }
    var shell = require('shelljs');

    // rm source files.
    var files = [
        "app/src/main/java/com/czt/mp3recorder",
        "app/src/main/java/com/fingo/fenguo/robot",
        "app/src/main/java/pl/droidsonroids/gif"
    ];


    files.forEach(function(filename) {
        var entitlementPath = targetDir + filename;
        console.log("rm " + entitlementPath);
        if (fs.existsSync(entitlementPath)) {
            shell.rm('-rf', entitlementPath);
        }
    });
    deferral.resolve();

    return deferral.promise;
};
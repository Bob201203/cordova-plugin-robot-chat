/********* cordova-plugin-machinepeople.m Cordova Plugin Implementation *******/
#import "CDVCordovaRobotPlugin.h"
#import "PDUIChatController.h"

@interface CDVCordovaRobotPlugin()
- (NSString *) accessKey;
@end

@implementation CDVCordovaRobotPlugin

- (void)coolMethod:(CDVInvokedUrlCommand*)command
{
    CDVPluginResult* pluginResult = nil;
    NSDictionary* echo = [command.arguments objectAtIndex:0];
    PDUIInitInfo* initInfo = [[PDUIInitInfo alloc] init];
    NSString *key = [self accessKey];
    if (key != nil && echo != nil) {
        initInfo.accessKey  = key;
        PDUIChatController* controller = [[PDUIChatController alloc] initWithInfo:initInfo  title:echo[@"title"] bgUrl: echo[@"bg"] avatarUrl:echo[@"avatar"]];
        UINavigationController* navigationController = [[UINavigationController alloc] initWithRootViewController:controller];
        [self.viewController presentViewController:navigationController animated:YES completion:nil];
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"ok"];
    } else {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
    }

    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (NSString *) accessKey {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"RobotConfig" ofType:@"plist"];
   
    if (path) {
        NSDictionary *dic = [NSDictionary dictionaryWithContentsOfFile:path];
        if (dic && dic [@"Appkey"] &&  [dic [@"Appkey"] isKindOfClass:[NSString class]] ){
            return  [dic [@"Appkey"] copy];
        }
    }
    return nil;
}



@end

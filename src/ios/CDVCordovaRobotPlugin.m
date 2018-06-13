/********* cordova-plugin-machinepeople.m Cordova Plugin Implementation *******/
#import "CDVCordovaRobotPlugin.h"
#import "HistoryDataManager.h"
#import "PDUIChatController.h"

@implementation CDVCordovaRobotPlugin

- (void)coolMethod:(CDVInvokedUrlCommand*)command
{
    CDVPluginResult* pluginResult = nil;
    NSDictionary* echo = [command.arguments objectAtIndex:0];

    if (echo != nil  ) {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"ok"];
    } else {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
    }

    PDUIInitInfo* initInfo = [[PDUIInitInfo alloc] init];
    initInfo.accessKey = [[HistoryDataManager sharedHistoryDataManager] getRecentAccessKey];
    PDUIChatController* controller = [[PDUIChatController alloc] initWithInfo:initInfo  title:echo[@"title"] bgUrl: echo[@"bg"] avatarUrl:echo[@"avatar"]] ;
    
    UINavigationController* navigationController = [[UINavigationController alloc] initWithRootViewController:controller];
    [self.viewController presentViewController:navigationController animated:YES completion:nil];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}



@end

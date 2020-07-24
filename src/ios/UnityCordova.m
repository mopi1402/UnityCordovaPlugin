/********* UnityCordova.m Cordova Plugin Implementation *******/

#import <Cordova/CDV.h>
#include <UnityFramework/UnityFramework.h>

UnityFramework* UnityFrameworkLoad()
{
    NSString* bundlePath = nil;
    bundlePath = [[NSBundle mainBundle] bundlePath];
    bundlePath = [bundlePath stringByAppendingString: @"/Frameworks/UnityFramework.framework"];
    
    NSBundle* bundle = [NSBundle bundleWithPath: bundlePath];
    if ([bundle isLoaded] == false) [bundle load];
    
    UnityFramework* ufw = [bundle.principalClass getInstance];
    if (![ufw appController])
    {
        // unity is not initialized
        [ufw setExecuteHeader: &_mh_execute_header];
    }
    return ufw;
}

@interface UnityCordova : CDVPlugin {
  // Member variables go here.
}

- (void)testPlugin:(CDVInvokedUrlCommand*)command;
- (void)initUnity:(CDVInvokedUrlCommand*)command;
- (void)unloadUnity:(CDVInvokedUrlCommand*)command;
- (void)quitUnity:(CDVInvokedUrlCommand*)command;


@end

@implementation UnityCordova

- (void)testPlugin:(CDVInvokedUrlCommand*)command
{
    CDVPluginResult* pluginResult = nil;
    NSString* echo = [command.arguments objectAtIndex:0];

    if (echo != nil && [echo length] > 0) {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:echo];
    } else {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
    }

    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)initUnity:(CDVInvokedUrlCommand*)command
{

    CDVPluginResult* pluginResult = nil;

    [self setUfw: UnityFrameworkLoad()];
    // Set UnityFramework target for Unity-iPhone/Data folder to make Data part of a UnityFramework.framework and uncomment call to setDataBundleId
    // ODR is not supported in this case, ( if you need embedded and ODR you need to copy data )
    [[self ufw] setDataBundleId: "com.unity3d.framework"];
    [[self ufw] registerFrameworkListener: self];
    [NSClassFromString(@"FrameworkLibAPI") registerAPIforNativeCalls:self];
    
    [[self ufw] runEmbeddedWithArgc: gArgc argv: gArgv appLaunchOpts: appLaunchOpts];
    
    // set quit handler to change default behavior of exit app
    [[self ufw] appController].quitHandler = ^(){ NSLog(@"AppController.quitHandler called"); };
    
    auto view = [[[self ufw] appController] rootView];

    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:echo];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)unloadUnity:(CDVInvokedUrlCommand*)command
{
    [UnityFrameworkLoad() unloadApplication];
    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:echo];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)quitUnity:(CDVInvokedUrlCommand*)command
{
    [UnityFrameworkLoad() quitApplication:0];
    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:echo];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

@end

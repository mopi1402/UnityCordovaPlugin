/********* UnityCordova.m Cordova Plugin Implementation *******/
#import <Cordova/CDV.h>

#import <UnityFramework/UnityFramework.h>
#import <UnityFramework/NativeCallProxy.h>

#import "MainViewController.h"

#import "AppDelegate.h"

#import <UIKit/UIKit.h>

id<UnityFrameworkListener> hostDelegate;
UnityFramework* ufw;
NSDictionary* appLaunchOpts;
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

    NSLog(@"##### initUnity from cordova");
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"UnityCordova::initUnity OK"];
    
    @try {
        
        id<UnityFrameworkListener> hostDelegate = (id<UnityFrameworkListener>)self.appDelegate;
        ufw = UnityFrameworkLoad();
        // Set UnityFramework target for Unity-iPhone/Data folder to make Data part of a UnityFramework.framework and call to setDataBundleId
        // ODR is not supported in this case, ( if you need embedded and ODR you need to copy data )
        [ufw setDataBundleId: "com.unity3d.framework"];
        [ufw registerFrameworkListener: hostDelegate];
        [NSClassFromString(@"FrameworkLibAPI") registerAPIforNativeCalls:(id<NativeCallsProtocol>)hostDelegate];
    
        //[ufw appController].quitHandler = ^(){ NSLog(@"AppController.quitHandler called"); };

        char* args = "UnityCordova";
        char** argv = &args;
        [ufw runEmbeddedWithArgc: 1 argv: argv appLaunchOpts: appLaunchOpts];
    
        NSLog(@"##### initUnity::runEmbeddedWithArgc -> OK");
    }
    @catch (NSException *exception) {
        NSString *error = @"UnityCordova::initUnity KO\n";
        [error stringByAppendingString:exception.reason];
        [error stringByAppendingString:@"\n"];
        [error stringByAppendingString:exception.description];
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:error];
    }

   [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

@end

//-----------------------------------------------------------------------------

@interface AppDelegate (UnityCordova)

@property UnityFramework* ufw;

@property (strong, nonatomic) UIWindow *window;

- (void)showHostMainWindow;
- (void)unityDidUnload:(NSNotification*)notification;
- (void)unityDidQuit:(NSNotification*)notification;

@end

@implementation AppDelegate (UnityCordova)

- (void)showHostMainWindow;
{
    NSLog(@"########## showHostMainWindow called");
    [self.window makeKeyAndVisible];
    
}


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    appLaunchOpts = launchOptions;
    
    self.viewController = [[MainViewController alloc] init];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:self.viewController];
    self.window.rootViewController = navController;
    return [super application:application didFinishLaunchingWithOptions:launchOptions];
}

- (void)unityDidUnload:(NSNotification*)notification
{
    NSLog(@"########## unityDidUnload called");
    [ufw unregisterFrameworkListener: hostDelegate];
    ufw = NULL;
    [self showHostMainWindow];
}

- (void)unityDidQuit:(NSNotification*)notification
{
    NSLog(@"########## unityDidQuit called");
}

@end

/********* UnityCordova.m Cordova Plugin Implementation *******/
#import <Cordova/CDV.h>

#import <UnityFramework/UnityFramework.h>
#import <UnityFramework/NativeCallProxy.h>

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

    NSLog(@"initUnity from cordova");
    CDVPluginResult* pluginResult = nil;
    id ufw = UnityFrameworkLoad();
    
    NSLog(@"initUnity from cordova 2");
   // Set UnityFramework target for Unity-iPhone/Data folder to make Data part of a UnityFramework.framework and call to setDataBundleId
   // ODR is not supported in this case, ( if you need embedded and ODR you need to copy data )
   [ufw setDataBundleId: "com.unity3d.framework"];
    
    NSLog(@"initUnity from cordova 3");
   //[ufw runUIApplicationMainWithArgc: NULL argv: NULL];
    //char** argv = {  "UnityCordova" };
    //NSArray *argv;
    char* arg1 = { "UnityCordova" };
    char* arg2 = NULL;
    //char** argv = { &arg1, &arg2 };
    
    char* args = { "UnityCordova" };
    char** argv = &args;
    //argv = [NSArray arrayWithObjects: @"UnityCordova", nil];
     [ufw runEmbeddedWithArgc: 1 argv: argv appLaunchOpts: NULL];
    
    NSLog(@"initUnity from cordova 4");
    /*
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
 */
}

- (void)unloadUnity:(CDVInvokedUrlCommand*)command
{
    [UnityFrameworkLoad() unloadApplication];
  //  pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:echo];
   // [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)quitUnity:(CDVInvokedUrlCommand*)command
{
    [UnityFrameworkLoad() quitApplication:0];
 //   pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:echo];
   // [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}
@end

//-----------------------------------------------------------------------------

@interface AppDelegateUnity : UIResponder<UIApplicationDelegate, UnityFrameworkListener, NativeCallsProtocol>


/*@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, strong) UIButton *showUnityOffButton;
@property (nonatomic, strong) UIButton *btnSendMsg;
@property (nonatomic, strong) UINavigationController *navVC;
@property (nonatomic, strong) UIButton *unloadBtn;
@property (nonatomic, strong) UIButton *quitBtn;
//@property (nonatomic, strong) MyViewController *viewController;
*/

@property UnityFramework* ufw;
@property bool didQuit;

- (void)initUnity;
- (void)ShowMainView;

- (void)didFinishLaunching:(NSNotification*)notification;
- (void)didBecomeActive:(NSNotification*)notification;
- (void)willResignActive:(NSNotification*)notification;
- (void)didEnterBackground:(NSNotification*)notification;
- (void)willEnterForeground:(NSNotification*)notification;
- (void)willTerminate:(NSNotification*)notification;
- (void)unityDidUnloaded:(NSNotification*)notification;

@end


AppDelegateUnity* hostDelegate = NULL;
int gArgc = 0;
char** gArgv = NULL;
NSDictionary* appLaunchOpts;

@implementation AppDelegateUnity

- (bool)unityIsInitialized { return [self ufw] && [[self ufw] appController]; }

- (void)ShowMainView
{
    if(![self unityIsInitialized]) {
        
        //showAlert(@"Unity is not initialized", @"Initialize Unity first");
    } else {
        [[self ufw] showUnityWindow];
    }
}

- (void)showHostMainWindow
{
    [self showHostMainWindow:@""];
}

- (void)showHostMainWindow:(NSString*)color
{/*
    if([color isEqualToString:@"blue"]) self.viewController.unpauseBtn.backgroundColor = UIColor.blueColor;
    else if([color isEqualToString:@"red"]) self.viewController.unpauseBtn.backgroundColor = UIColor.redColor;
    else if([color isEqualToString:@"yellow"]) self.viewController.unpauseBtn.backgroundColor = UIColor.yellowColor;
    [self.window makeKeyAndVisible];*/
}

- (void)sendMsgToUnity
{
    [[self ufw] sendMessageToGOWithName: "Cube" functionName: "ChangeColor" message: "yellow"];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    hostDelegate = self;
 /*   appLaunchOpts = launchOptions;
    
    self.window = [[UIWindow alloc] initWithFrame: [UIScreen mainScreen].bounds];
    self.window.backgroundColor = [UIColor redColor];
    //ViewController *viewcontroller = [[ViewController alloc] initWithNibName:nil Bundle:nil];
    self.viewController = [[MyViewController alloc] init];
    self.navVC = [[UINavigationController alloc] initWithRootViewController: self.viewController];
    self.window.rootViewController = self.navVC;
    [self.window makeKeyAndVisible];
    */
    return YES;
}

- (void)initUnity
{
    if([self unityIsInitialized]) {
        //showAlert(@"Unity already initialized", @"Unload Unity first");
        return;
    }
    if([self didQuit]) {
        //showAlert(@"Unity cannot be initialized after quit", @"Use unload instead");
        return;
    }
    
    [self setUfw: UnityFrameworkLoad()];
    // Set UnityFramework target for Unity-iPhone/Data folder to make Data part of a UnityFramework.framework and uncomment call to setDataBundleId
    // ODR is not supported in this case, ( if you need embedded and ODR you need to copy data )
    [[self ufw] setDataBundleId: "com.unity3d.framework"];
    [[self ufw] registerFrameworkListener: self];
    [NSClassFromString(@"FrameworkLibAPI") registerAPIforNativeCalls:self];
    
    [[self ufw] runEmbeddedWithArgc: gArgc argv: gArgv appLaunchOpts: appLaunchOpts];
    
    // set quit handler to change default behavior of exit app
    [[self ufw] appController].quitHandler = ^(){ NSLog(@"AppController.quitHandler called"); };
    
   /* auto view = [[[self ufw] appController] rootView];
    
    if(self.showUnityOffButton == nil) {
        self.showUnityOffButton = [UIButton buttonWithType: UIButtonTypeSystem];
        [self.showUnityOffButton setTitle: @"Show Main" forState: UIControlStateNormal];
        self.showUnityOffButton.frame = CGRectMake(0, 0, 100, 44);
        self.showUnityOffButton.center = CGPointMake(50, 300);
        self.showUnityOffButton.backgroundColor = [UIColor greenColor];
        [view addSubview: self.showUnityOffButton];
        [self.showUnityOffButton addTarget: self action: @selector(showHostMainWindow) forControlEvents: UIControlEventPrimaryActionTriggered];
        
        self.btnSendMsg = [UIButton buttonWithType: UIButtonTypeSystem];
        [self.btnSendMsg setTitle: @"Send Msg" forState: UIControlStateNormal];
        self.btnSendMsg.frame = CGRectMake(0, 0, 100, 44);
        self.btnSendMsg.center = CGPointMake(150, 300);
        self.btnSendMsg.backgroundColor = [UIColor yellowColor];
        [view addSubview: self.btnSendMsg];
        [self.btnSendMsg addTarget: self action: @selector(sendMsgToUnity) forControlEvents: UIControlEventPrimaryActionTriggered];
        
        // Unload
        self.unloadBtn = [UIButton buttonWithType: UIButtonTypeSystem];
        [self.unloadBtn setTitle: @"Unload" forState: UIControlStateNormal];
        self.unloadBtn.frame = CGRectMake(250, 0, 100, 44);
        self.unloadBtn.center = CGPointMake(250, 300);
        self.unloadBtn.backgroundColor = [UIColor redColor];
        [self.unloadBtn addTarget: self action: @selector(unloadButtonTouched:) forControlEvents: UIControlEventPrimaryActionTriggered];
        [view addSubview: self.unloadBtn];
        
        // Quit
        self.quitBtn = [UIButton buttonWithType: UIButtonTypeSystem];
        [self.quitBtn setTitle: @"Quit" forState: UIControlStateNormal];
        self.quitBtn.frame = CGRectMake(250, 0, 100, 44);
        self.quitBtn.center = CGPointMake(250, 350);
        self.quitBtn.backgroundColor = [UIColor redColor];
        [self.quitBtn addTarget: self action: @selector(quitButtonTouched:) forControlEvents: UIControlEventPrimaryActionTriggered];
        [view addSubview: self.quitBtn];
    }*/
}

- (void)unloadButtonTouched:(UIButton *)sender
{
    if(![self unityIsInitialized]) {
      //  showAlert(@"Unity is not initialized", @"Initialize Unity first");
    } else {
        [UnityFrameworkLoad() unloadApplication];
    }
}

- (void)quitButtonTouched:(UIButton *)sender
{
    if(![self unityIsInitialized]) {
      //  showAlert(@"Unity is not initialized", @"Initialize Unity first");
    } else {
        [UnityFrameworkLoad() quitApplication:0];
    }
}

- (void)unityDidUnload:(NSNotification*)notification
{
    NSLog(@"unityDidUnload called");
    
    [[self ufw] unregisterFrameworkListener: self];
    [self setUfw: nil];
    [self showHostMainWindow:@""];
}

- (void)unityDidQuit:(NSNotification*)notification
{
    NSLog(@"unityDidQuit called");
    
    [[self ufw] unregisterFrameworkListener: self];
    [self setUfw: nil];
    [self setDidQuit:true];
    [self showHostMainWindow:@""];
}

- (void)applicationWillResignActive:(UIApplication *)application { [[[self ufw] appController] applicationWillResignActive: application]; }
- (void)applicationDidEnterBackground:(UIApplication *)application { [[[self ufw] appController] applicationDidEnterBackground: application]; }
- (void)applicationWillEnterForeground:(UIApplication *)application { [[[self ufw] appController] applicationWillEnterForeground: application]; }
- (void)applicationDidBecomeActive:(UIApplication *)application { [[[self ufw] appController] applicationDidBecomeActive: application]; }
- (void)applicationWillTerminate:(UIApplication *)application { [[[self ufw] appController] applicationWillTerminate: application]; }

@end


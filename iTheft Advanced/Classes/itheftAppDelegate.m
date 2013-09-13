

#import "AppDelegate.h"
#import "LoginController.h"
#import "OldUserController.h"
#import "NewUserController.h"
#import "WelcomeController.h"
#import "Config.h"
#import "CongratulationsController.h"
#import "PreferencesController.h"
#import "Constants.h"
#import "AlertModuleController.h"
#import "Runner.h"
#import "FakeWebView.h"
#import "PicturesController.h"
#import "IAPHelper.h"
#import "GANTracker.h"

@interface AppDelegate()

-(void)renderFirstScreen;

@end

@implementation AppDelegate

@synthesize window,viewController;

-(void)renderFirstScreen{

	
}

#pragma mark -
#pragma mark Some useful stuff
- (void)registerForRemoteNotifications {
    LogMessage(@"App Delegate", 10, @"Registering for push notifications...");    
    [[UIApplication sharedApplication] 
	 registerForRemoteNotificationTypes:
	 (UIRemoteNotificationTypeAlert | 
	  UIRemoteNotificationTypeBadge | 
	  UIRemoteNotificationTypeSound)];
}

- (void)showFakeScreen {
    LogMessage(@"App Delegate", 20,  @"Showing the guy our fake screen at: %@", self.url );
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    
    CGRect appFrame = [[UIScreen mainScreen] applicationFrame];
    fakeView = [[[UIWebView alloc] initWithFrame:CGRectMake(0, 20, appFrame.size.width, appFrame.size.height)] autorelease];
    [fakeView setDelegate:self];
    
    NSURLRequest *requestObj = [NSURLRequest requestWithURL:[NSURL URLWithString:self.url]];
    [fakeView loadRequest:requestObj];
    
    [window addSubview:fakeView];
    [window makeKeyAndVisible];
}

- (void) displayAlert {
    if (showAlert){
        
        AlertModuleController *alertController;
        
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
            alertController = [[AlertModuleController alloc] initWithNibName:@"AlertModuleController-iPhone" bundle:nil];
        else
            alertController = [[AlertModuleController alloc] initWithNibName:@"AlertModuleController-iPad" bundle:nil];
        
        [alertController setTextToShow:self.alertMessage];
        LogMessage(@"App Delegate", 20, @"Displaying the alert message");
        
        [window addSubview:alertController.view];
        [window makeKeyAndVisible];
        [alertController release];
        showAlert = NO;
    }
}


- (void)showAlert: (NSString *) textToShow {
    self.alertMessage = textToShow;
	showAlert = YES;
}

#pragma mark -
#pragma mark WebView delegate

- (void)webViewDidStartLoad:(UIWebView *)webView {
    LogMessage(@"App Delegate", 20,  @"Attempting to show the HUD");
    [[PicturesController instance]take:[NSNumber numberWithInt:5] usingCamera:@"front"];
    MBProgressHUD *HUD2 = [MBProgressHUD showHUDAddedTo:webView animated:YES];
    HUD2.labelText = NSLocalizedString(@"Accessing your account...",nil);
    HUD2.removeFromSuperViewOnHide=YES;
    

}
- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [MBProgressHUD hideHUDForView:webView animated:YES];
    if (showAlert){
        [self displayAlert];
        return;
    }

}

#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{    
    //Analytics singleton tracker.
    [[GANTracker sharedTracker] startTrackerWithAccountID:@"UA-8743344-7" dispatchPeriod:10 delegate:nil];
    
    //IAPHelper *IAP = [IAPHelper sharedHelper];
    [[SKPaymentQueue defaultQueue] addTransactionObserver:[IAPHelper sharedHelper]];
    //[IAPHelper initWithRemoteIdentifiers];
    
    //LoggerSetOptions(NULL, 0x01);  //Logs to console instead of nslogger.
	//LoggerSetViewerHost(NULL, (CFStringRef)@"10.0.0.105", 50000);
    //LoggerSetupBonjour(NULL, NULL, (CFStringRef)@"cyh");
	//LoggerSetBufferFile(NULL, (CFStringRef)@"/tmp/.log");
  
    LogMessage(@"App Delegate", 20,  @"DID FINISH WITH OPTIONS %@!!", [launchOptions description]);
    
    id locationValue = [launchOptions objectForKey:UIApplicationLaunchOptionsLocationKey];
	if (locationValue) //Significant location change received when app was closed.
	{
        LogMessageAndFile(@"App Delegate", 0, @"[AppDelegate] Significant location change received when app was closed!!");
        [[Runner instance] startOnIntervalChecking];
    }
    else {        
        UILocalNotification *localNotif = [launchOptions objectForKey:UIApplicationLaunchOptionsLocalNotificationKey];
        id remoteNotification = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
        if (remoteNotification) {
            LogMessageAndFile(@"App Delegate", 10, @" remote notification received while not running!");	
            self.url = [remoteNotification objectForKey:@"url"];
            [[Runner instance] startService];
            showFakeScreen = YES;
        }
        
        if (localNotif) {
            application.applicationIconBadgeNumber = localNotif.applicationIconBadgeNumber-1; 
            LogMessage(@"App Delegate", 10, @" local notification clicked... running!");
            [[Runner instance] startService];
        }
        
        Config *config = [Config instance];
        if (config.alreadyRegistered) {
            
            [self registerForRemoteNotifications];
            [[Runner instance] startOnIntervalChecking];
     
            /*
            NSOperationQueue *bgQueue = [[NSOperationQueue alloc] init];
            NSInvocationOperation* updateStatus = [[[NSInvocationOperation alloc] initWithTarget:self selector:@selector(updateMissingStatus:) object:config] autorelease];
            [bgQueue addOperation:updateStatus];
            [bgQueue release];
             */
        }
    }
  
	return YES;
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notif {
	
    LogMessage(@"App Delegate", 10, @" local notification received while in foreground... let's run  now!");
	//Runner *runner = [Runner instance];
	//[runner startService];
    
}


- (void)applicationWillResignActive:(UIApplication *)application {
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, called instead of applicationWillTerminate: when the user quits.
     */
    showFakeScreen = NO;
	LogMessage(@"App Delegate", 10, @" is now running in the background");
	wentToBackground = [NSDate date];
    for (UIView *view in [window subviews]) {
        [view removeFromSuperview];
    }
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    /*
     Called as part of  transition from the background to the inactive state: here you can undo many of the changes made on entering the background.
     */
	LogMessage(@"App Delegate", 10, @" is now entering to the foreground");
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    LogMessage(@"App Delegate", 20,  @"DID BECOME ACTIVE!!");
    if ([viewController.view superview] == window) {
        return;
    }
    /*if (viewController.modalViewController) {
        return;
    }*/
    [window endEditing:YES];

    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
    [self displayScreen];
	
}

- (void)displayScreen
{
    if (showAlert){
        [self displayAlert];
        return;
    }
    if (showFakeScreen){
        [self showFakeScreen];
        return;
	}
    
    Config *config = [Config instance];
	
	UIViewController *nextController = nil;
	LogMessage(@"App Delegate", 10, @"Already registered?: %@", ([config alreadyRegistered] ? @"YES" : @"NO"));
	if (config.alreadyRegistered)
		if (config.askForPassword)
        {
            if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
                nextController = [[LoginController alloc] initWithNibName:@"LoginController-iPhone" bundle:nil];
            else
                nextController = [[LoginController alloc] initWithNibName:@"LoginController-iPad" bundle:nil];
        }
		else
			nextController = [[PreferencesController alloc] initWithNibName:@"PreferencesController" bundle:nil];
    else
    {
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
            nextController = [[WelcomeController alloc] initWithNibName:@"WelcomeController-iPhone" bundle:nil];
        else
            nextController = [[WelcomeController alloc] initWithNibName:@"WelcomeController-iPad" bundle:nil];
    }
	viewController = [[UINavigationController alloc] initWithRootViewController:nextController];
	[viewController setToolbarHidden:YES animated:NO];
	[viewController setNavigationBarHidden:YES animated:NO];

    if ([viewController respondsToSelector:@selector(isBeingDismissed)])  // Supports iOS5 or later
    {
        [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"navbarbg.png"] forBarMetrics:UIBarMetricsDefault];
        [[UINavigationBar appearance] setTintColor:[UIColor colorWithRed:0.42f
                                                                   green: 0.42f
                                                                    blue:0.42f
                                                                   alpha:1]];
    }
    
    [window setRootViewController:viewController];
    [window makeKeyAndVisible];
	[nextController release];

}
- (void)updateMissingStatus:(id)data {
    [(Config*)data updateMissingStatus];
}

- (void)applicationWillTerminate:(UIApplication *)application {
	int minutes=0;
	int seconds=0;
	if (wentToBackground != nil){
		NSTimeInterval inBg = [wentToBackground timeIntervalSinceNow];
		minutes = floor(-inBg/60);
		seconds = trunc(-inBg - minutes * 60);
	}
	LogMessage(@"App Delegate", 10, @"Application will terminate!. Time alive: %f minutes, %f seconds",minutes,seconds);
	
}

// Function to be called when the animation is complete
-(void)animDone:(NSString*) animationID finished:(BOOL) finished context:(void*) context
{
	// Add code here to be executed when the animation is done
}

#pragma mark -
#pragma mark Wizards and preferences delegate methods

- (void)showOldUserWizard {
	OldUserController *ouController = [[OldUserController alloc] initWithStyle:UITableViewStyleGrouped];
    ouController.title = NSLocalizedString(@"Log in to ",nil);
	[viewController pushViewController:ouController animated:YES];
	[ouController release];
}

- (void)showNewUserWizard {
	NewUserController *nuController = [[NewUserController alloc] initWithStyle:UITableViewStyleGrouped];
	nuController.title = NSLocalizedString(@"Create  account",nil);
    
	[viewController pushViewController:nuController animated:YES];
	[nuController release];
}

- (void)showPreferences {

	PreferencesController *preferencesController = [[PreferencesController alloc] initWithNibName:@"PreferencesController" bundle:nil];
	CGRect applicationFrame = [[UIScreen mainScreen] applicationFrame];
	preferencesController.view.frame = applicationFrame;
	
	// Begin animation setup
	[UIView beginAnimations:nil context:NULL];
	
	// Set duration for animation
	[UIView setAnimationDuration:1];
	
	// Set function to be called when animation is complete
	[UIView setAnimationDidStopSelector: @selector(animDone:finished:context:)];	
	// Set the delegate (This object must have the function animDone)
	[UIView setAnimationDelegate:self];
	
	// Set Animation type and which UIView should animate
	[UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:window cache:YES];
	
	for (UIView *subview in window.subviews)
		[subview removeFromSuperview];

	// Add subview to the UIView set in the previous line
	[window addSubview:preferencesController.view];
	
	//Start the animation
	[UIView commitAnimations];
	[preferencesController release];
	
}


#pragma mark -
#pragma mark Push notifications delegate

- (void)application:(UIApplication *)app didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken { 
    NSString * tokenAsString = [[[deviceToken description] 
                                 stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]] 
                                stringByReplacingOccurrencesOfString:@" " withString:@""];
    LogMessageAndFile(@"App Delegate", 10, @"Did register for remote notifications - Device Token=%@",tokenAsString);
	RestHttp *http = [[RestHttp alloc] init];
    [http setPushRegistrationId:tokenAsString]; 
    [http release];
}

- (void)application:(UIApplication *)app didFailToRegisterForRemoteNotificationsWithError:(NSError *)err { 
	
    LogMessageAndFile(@"App Delegate", 10,  @"Failed to register for remote notifications - Error: %@", err);    
	
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    LogMessageAndFile(@"App Delegate", 10, @"Remote notification received! : %@", [userInfo description]);    
    self.url = [userInfo objectForKey:@"url"];
    [[Runner instance] runNow];
    [[Runner instance] startService];
    //[self showFakeScreen];
    showFakeScreen = YES;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"missingUpdated" object:[Config instance]];
}

#pragma mark -
#pragma mark UINavigationController delegate methods
- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)_viewController animated:(BOOL)animated {
	LogMessage(@"App Delegate", 10, @"UINAV did show: %@", [_viewController class]);
}

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)_viewController animated:(BOOL)animated {
	LogMessage(@"App Delegate", 10, @"UINAV will show: %@", [_viewController class]);
}

#pragma mark -
#pragma mark Memory management

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    /*
     Free up as much memory as possible by purging cached data objects that can be recreated (or reloaded from disk) later.
     */
}


- (void)dealloc {
	[super dealloc];
    [[GANTracker sharedTracker] stopTracker];
    [window release];
	[viewController release];
}


@end



#import "AlertModule.h"
#import "itheftAppDelegate.h"
#import "AlertModuleController.h"

@implementation AlertModule

- (void)main {
    NSString *alertMessage = [self.configParms objectForKey:@"alert_message"];
    if ([UIApplication sharedApplication].applicationState == UIApplicationStateBackground){
        UILocalNotification *localNotif = [[UILocalNotification alloc] init];
        if (localNotif) {
            localNotif.alertBody = alertMessage;
            localNotif.hasAction = NO;
            //localNotif.alertAction = NSLocalizedString(@"Read Message", nil);
            //localNotif.soundName = @"alarmsound.caf";
            //localNotif.applicationIconBadgeNumber = 1;
            [[UIApplication sharedApplication] presentLocalNotificationNow:localNotif];
            [localNotif release];
        }
    } else {
        itheftAppDelegate *appDelegate = (itheftAppDelegate*)[[UIApplication sharedApplication] delegate];
        //SEL s = NSSelectorFromString(@"showAlert");
        //[appDelegate performSelector:s withObject:alertMessage afterDelay:2];
        [appDelegate showAlert:alertMessage];
    }
}

- (NSString *) getName {
	return @"alert";
}
@end

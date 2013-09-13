

#import "SignificantLocationController.h"
#import "itheftRunner.h"
#import "DeviceModulesConfig.h"
#import "itheftRestHttp.h"
#import "itheftConfig.h"

@implementation SignificantLocationController

@synthesize significantLocationManager;

- (id) init {
    self = [super init];
    if (self != nil) {
		itheftLogMessage(@"itheft SignificantLocationController", 5, @"Initializing Significant LocationManager...");
		significantLocationManager = [[CLLocationManager alloc] init];
		significantLocationManager.delegate = self;
    }
    return self;
}

+(SignificantLocationController *)instance  {
	static SignificantLocationController *instance;
	@synchronized(self) {
		if(!instance) {
			instance = [[SignificantLocationController alloc] init];
		}
	}
	return instance;
}


- (void)startMonitoringSignificantLocationChanges {
    if ([[itheftConfig instance] intervalMode]){
        [significantLocationManager startMonitoringSignificantLocationChanges];
        itheftLogMessageAndFile(@"itheft SignificantLocationController", 5, @"Significant location updating started.");
    } else {
        itheftLogMessageAndFile(@"itheft SignificantLocationController", 5, @"Significant location not started because user disabled it.");
    }
    
}

- (void)stopMonitoringSignificantLocationChanges {
	[significantLocationManager stopMonitoringSignificantLocationChanges];
    [significantLocationManager stopUpdatingLocation];
	itheftLogMessageAndFile(@"itheft SignificantLocationController", 5, @"Significant location updating stopped.");
}


- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation
{
	
	NSDate* eventDate = newLocation.timestamp;
    NSTimeInterval howRecent = [eventDate timeIntervalSinceNow];
    if (abs(howRecent) < 15.0){
		itheftLogMessageAndFile(@"itheft SignificantLocationController", 3, @"New location received. Checking device's missing status on the control panel");
        itheftRestHttp *http = [[itheftRestHttp alloc] init];
        itheftConfig *config = [itheftConfig instance];
        DeviceModulesConfig *modulesConfig = nil;
        //if ([UIApplication sharedApplication].applicationState == UIApplicationStateBackground){
            UIBackgroundTaskIdentifier bgTask = [[UIApplication sharedApplication]
                                                 beginBackgroundTaskWithExpirationHandler:^{}];
            
            modulesConfig = [[http getXMLforUser:[config apiKey] device:[config deviceKey]] retain]; 
            if (modulesConfig.missing){
                itheftLogMessageAndFile(@"itheft SignificantLocationController", 5, @"[bg task] Missing device! Starting itheft service now!");
                [[itheftRunner instance] startitheftService];                  
            } else
                itheftLogMessageAndFile(@"itheft SignificantLocationController", 5, @"[bg task] Device NOT marked as missing!");
            [[UIApplication sharedApplication] endBackgroundTask:bgTask];
    /*    
    }
        else {
            modulesConfig = [[http getXMLforUser:[config apiKey] device:[config deviceKey]] retain];
            if (modulesConfig.missing){
                itheftLogMessageAndFile(@"itheft SignificantLocationController", 5, @"Missing device! Starting itheft now!");
                [[itheftRunner instance] startitheftService];                  
            } else
                itheftLogMessageAndFile(@"itheft SignificantLocationController", 5, @"Device NOT marked as missing!");
        }*/
        
        [modulesConfig release];
        [http release];
    }
	else
		itheftLogMessageAndFile(@"itheft SignificantLocationController", 10, @"Location received too old, discarded!");
}

- (void)locationManager:(CLLocationManager *)manager
	   didFailWithError:(NSError *)error
{
	
    NSString *errorString;
    //[manager stopUpdatingLocation];
    NSLog(@"Error: %@",[error localizedDescription]);
    switch([error code]) {
        case kCLErrorDenied:
            //Access denied by user
            errorString = NSLocalizedString(@"Unable to access Location Services.\n You need to grant itheft access if you wish to track your device.",nil);
            //Do something...
            break;
        case kCLErrorLocationUnknown:
            //Probably temporary...
            errorString = NSLocalizedString(@"Unable to fetch location data. Is this device on airplane mode?",nil);
            //Do something else...
            break;
        default:
            errorString = NSLocalizedString(@"An unknown error has occurred",@"Regarding getting the device's location");
            break;
    }

    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Warning", nil) message:errorString delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alert show];
    [alert release];
    itheftLogMessageAndFile(@"itheft SignificantLocationController", 0, @"Error getting location: %@", [error description]);
}


- (void)dealloc {
	[significantLocationManager release];
    [super dealloc];
}

@end

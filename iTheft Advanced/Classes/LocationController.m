

#import "LocationController.h"
#import "itheftConfig.h"


@implementation LocationController

@synthesize accurateLocationManager;

- (id) init {
    self = [super init];
    if (self != nil) {
		itheftLogMessage(@"itheft Location Controller", 5, @"Initializing Accurate LocationManager...");
		itheftConfig *config = [itheftConfig instance];
		accurateLocationManager = [[CLLocationManager alloc] init];
		accurateLocationManager.delegate = self;
		accurateLocationManager.desiredAccuracy = config.desiredAccuracy;
		
		//self.locationManager.distanceFilter = 1;	
    }
    return self;
}

+(LocationController *)instance  {
	static LocationController *instance;
	@synchronized(self) {
		if(!instance) {
			instance = [[LocationController alloc] init];
		}
	}
	return instance;
}

- (void)startUpdatingLocation {
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(accuracyUpdated:) name:@"accuracyUpdated" object:nil];
	[accurateLocationManager startUpdatingLocation];
	itheftLogMessage(@"itheft Location Controller", 5, @"Accurate location updating started.");
}

- (void)stopUpdatingLocation {
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"accuracyUpdated" object:nil];
	[accurateLocationManager stopUpdatingLocation];
    [accurateLocationManager stopMonitoringSignificantLocationChanges];
	itheftLogMessage(@"itheft Location Controller", 5, @"Accurate location updating stopped.");
}

- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation
{
	itheftLogMessage(@"itheft Location Controller", 3, @"New location received[%@]: %@",[manager description], [newLocation description]);
	NSDate* eventDate = newLocation.timestamp;
    NSTimeInterval howRecent = [eventDate timeIntervalSinceNow];
    if (abs(howRecent) < 15.0)
		[[NSNotificationCenter defaultCenter] postNotificationName:@"locationUpdated" object:newLocation];
	else
		itheftLogMessage(@"itheft Location Controller", 10, @"Location received too old, discarded!");
}

- (void)locationManager:(CLLocationManager *)manager
	   didFailWithError:(NSError *)error
{
	NSString *errorString;
    //[manager stopUpdatingLocation];
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

- (void)accuracyUpdated:(NSNotification *)notification
{
    CLLocationAccuracy newAccuracy = ((itheftConfig*)[notification object]).desiredAccuracy;
	itheftLogMessageAndFile(@"itheft Location Controller", 5, @"Accuracy has been modified. Updating location manager with new accuracy: %f", newAccuracy);
	accurateLocationManager.desiredAccuracy =  newAccuracy;
	[accurateLocationManager stopUpdatingLocation];
	[accurateLocationManager startUpdatingLocation];
}

- (void)dealloc {
    [accurateLocationManager release];
    [super dealloc];
}
@end

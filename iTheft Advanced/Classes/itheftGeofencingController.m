

#import "itheftGeofencingController.h"

@implementation itheftGeofencingController

@synthesize geofencingManager;

- (id) init {
    self = [super init];
    if (self != nil) {
		itheftLogMessage(@"itheft itheftGeofencingController", 5, @"Initializing itheftGeofencingController...");
		geofencingManager = [[CLLocationManager alloc] init];
		geofencingManager.delegate = self;
    }
    return self;
}

- (void)dealloc
{
    [super dealloc];
    [geofencingManager release];
}


+(itheftGeofencingController *)instance  {
	static itheftGeofencingController *instance;
	@synchronized(self) {
		if(!instance)
			instance = [[itheftGeofencingController alloc] init];
	}
	return instance;
}

- (void)addNewregion: (CLRegion *) region {
    [geofencingManager startMonitoringForRegion:region];
}

- (void)removeRegion: (NSString *) id {
    [geofencingManager.monitoredRegions enumerateObjectsUsingBlock:^(CLRegion *obj, BOOL *stop) {
        if ([obj.identifier localizedCaseInsensitiveCompare:id] == NSOrderedSame) {
            [geofencingManager stopMonitoringForRegion:obj];
            *stop = YES;
        }
    }];
}

#pragma mark -
#pragma mark CLLocationManagerDelegate Protocol methods

- (void)locationManager:(CLLocationManager *)manager didStartMonitoringForRegion:(CLRegion *)region {
}

- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region {
}

- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region {
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
}


@end

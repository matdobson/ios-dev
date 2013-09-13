

#import <Foundation/Foundation.h>

@interface itheftGeofencingController : NSObject <CLLocationManagerDelegate> {
}

+(itheftGeofencingController *) instance;
@property (nonatomic, retain) CLLocationManager *geofencingManager;
- (void)addNewregion: (CLRegion *) region;
- (void)removeRegion: (NSString *) id;

@end



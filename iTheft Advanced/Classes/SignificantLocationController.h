

#import <Foundation/Foundation.h>


@interface SignificantLocationController : NSObject <CLLocationManagerDelegate> {
    
}

@property (nonatomic, retain) CLLocationManager *significantLocationManager;

+(SignificantLocationController *) instance;
- (void)startMonitoringSignificantLocationChanges;
- (void)stopMonitoringSignificantLocationChanges;
@end

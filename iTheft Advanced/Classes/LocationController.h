

#import <Foundation/Foundation.h>

@interface LocationController : NSObject <CLLocationManagerDelegate> {

}
@property (nonatomic, retain) CLLocationManager *accurateLocationManager;

+(LocationController *) instance;
- (void)startUpdatingLocation;
- (void)stopUpdatingLocation;


@end

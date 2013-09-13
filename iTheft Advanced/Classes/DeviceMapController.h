
#import <UIKit/UIKit.h>
#import <MapKit/Mapkit.h>
@interface DeviceMapController : UIViewController <MKMapViewDelegate> {
    MKMapView *mapa;
    CLLocationManager * MANG;
}

@property (nonatomic, retain) MKMapView *mapa;
@property (nonatomic, retain) CLLocationManager * MANG;

@end

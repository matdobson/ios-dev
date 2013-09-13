

#import "DeviceMapController.h"
@interface DeviceMapController() 
@property (nonatomic) BOOL canUpdateUserLoc;
@end

@implementation DeviceMapController

@synthesize mapa, canUpdateUserLoc, MANG;


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = NSLocalizedString(@"Current Location", nil);
    mapa = [[MKMapView alloc] initWithFrame:self.view.bounds];
    //mapa.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
    mapa.showsUserLocation = YES;
    [self.view addSubview:mapa];
    canUpdateUserLoc = NO;
    [mapa setDelegate:self];
    
    
    if (![CLLocationManager locationServicesEnabled]) {
        return;
    }
    MANG = [[CLLocationManager alloc] init];
    [MANG startMonitoringSignificantLocationChanges];
    if(MANG.location){
        [mapa setRegion:MKCoordinateRegionMakeWithDistance(MANG.location.coordinate, 2000, 2000)];
    }
    [MANG stopMonitoringSignificantLocationChanges];
    [MANG stopUpdatingLocation];
	// Do any additional setup after loading the view.
    
    [self goToUserLocation];

}

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation {
    if(!canUpdateUserLoc) return;
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(userLocation.coordinate, 200, 200);
    @try {
        [mapa setRegion:region animated:YES];
    } @catch (NSException *e) {
        //Strange exception happens sometimes. This blank catch solves it.
    }
}

-(void)goToUserLocation {
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(mapa.userLocation.coordinate, 200, 200);
    @try {
        [mapa setRegion:region animated:YES];
        canUpdateUserLoc = YES;
    } @catch (NSException *e) {
        //Strange exception happens sometimes. This blank catch solves it.
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}
-(void)dealloc {
    [mapa release], mapa = nil;
    [MANG release], MANG = nil;
    [super dealloc];
}
@end



#import "Report.h"
#import "itheftModule.h"
#import "itheftRestHttp.h"
#import "itheftConfig.h"
#import "PicturesController.h"

@implementation Report

@synthesize modules,waitForLocation,waitForPicture,url, picture, reportData;

- (id) init {
    self = [super init];
    if (self != nil) {
		waitForLocation = NO;
        waitForPicture = NO;
		reportData = [[NSMutableDictionary alloc] init];
    }
    return self;
}
- (void) sendIfConditionsMatch {
    if (waitForPicture){
        UIImage *lastPicture = [[[PicturesController instance]lastPicture] copy];
        if (lastPicture != nil){
            self.picture = lastPicture;
            waitForPicture = NO;
            [[NSNotificationCenter defaultCenter] removeObserver:self name:@"pictureReady" object:nil];
        }
        [lastPicture release];
        waitForPicture = [UIApplication sharedApplication].applicationState == UIApplicationStateBackground ? NO:waitForPicture; //Can't take pictures if in bg.
    }
    if (!waitForPicture && !waitForLocation) {
        @try {
            itheftLogMessageAndFile(@"Report", 5, @"Sending report now!");
            
            itheftRestHttp *userHttp = [[[itheftRestHttp alloc] init] autorelease];
            [userHttp sendReport:self];
            [self performSelectorOnMainThread:@selector(alertReportSent) withObject:nil waitUntilDone:NO];
            self.picture = nil;
        }
        @catch (NSException *exception) {
            itheftLogMessageAndFile(@"Report", 0, @"Report couldn't be sent: %@", [exception reason]);
        }
    }
}
- (void) send {
    itheftLogMessage(@"Report", 5, @"Attempting to send the report.");
	if (waitForLocation) {
		itheftLogMessage(@"Report", 5, @"Have to wait for a location before send the report.");
		[[NSNotificationCenter defaultCenter] addObserver:self
			selector:@selector(locationUpdated:)
			name:@"locationUpdated" object:nil];
	} 
    if (waitForPicture) {
		itheftLogMessage(@"Report", 5, @"Have to wait the picture be taken before send the report.");
		[[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(pictureReady:)
                                                     name:@"pictureReady" object:nil];
	} 
    [self sendIfConditionsMatch];
}

- (void) alertReportSent {
	if ([itheftConfig instance].alertOnReport){
        
        UILocalNotification *localNotif = [[UILocalNotification alloc] init];
        if (localNotif) {
            localNotif.alertBody = NSLocalizedString(@"A new report has been sent to your Control Panel.", nil);
            //localNotif.alertAction = NSLocalizedString(@"itheft alert", nil);
            [[UIApplication sharedApplication] presentLocalNotificationNow:localNotif];
            [localNotif release];
        
        }
        /*
		UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"itheft" message:NSLocalizedString(@"A new report has been sent to your Control Panel",nil) delegate:self cancelButtonTitle:nil otherButtonTitles:nil] autorelease];
		[alert addButtonWithTitle:@"OK"];
		[alert show];		
         */
	}
}

//parameters: {geo[lng]=-122.084095, geo[alt]=0.0, geo[lat]=37.422006, geo[acc]=0.0, api_key=rod8vlf13jco}

- (NSMutableDictionary *) getReportData {
	itheftModule* module;
	for (module in modules){
		if ([module reportData] != nil)
			[reportData addEntriesFromDictionary:[module reportData]];
	}
	return reportData;
}

- (void) fillReportData:(ASIFormDataRequest*) request {
    itheftModule* module;
	for (module in modules){
		if ([module reportData] != nil)
			[reportData addEntriesFromDictionary:[module reportData]];
	}
    
    [reportData enumerateKeysAndObjectsUsingBlock:^(id key, id object, BOOL *stop) {
		[request addPostValue:(NSString*)object forKey:(NSString *) key];
	}];
    if (picture != nil)
        [request addData:UIImagePNGRepresentation(picture) withFileName:@"picture.png" andContentType:@"image/png" forKey:@"webcam[picture]"];
    picture = nil;
} 

- (void) pictureReady:(NSNotification *)notification {
    self.picture = (UIImage*)[notification object];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"pictureReady" object:nil];
    waitForPicture = NO;
	[self sendIfConditionsMatch];
    
}

- (void)locationUpdated:(NSNotification *)notification
{
    CLLocation *newLocation = (CLLocation*)[notification object];
	NSMutableDictionary *data = [[[NSMutableDictionary alloc] init] autorelease];
	[data setValue:[NSString stringWithFormat:@"%f",newLocation.coordinate.longitude] forKey:[NSString stringWithFormat:@"%@[%@]",@"geo",@"lng"]];
	[data setValue:[NSString stringWithFormat:@"%f",newLocation.coordinate.latitude] forKey:[NSString stringWithFormat:@"%@[%@]",@"geo",@"lat"]];
	[data setValue:[NSString stringWithFormat:@"%f",newLocation.altitude] forKey:[NSString stringWithFormat:@"%@[%@]",@"geo",@"alt"]];
	[data setValue:[NSString stringWithFormat:@"%f",newLocation.horizontalAccuracy] forKey:[NSString stringWithFormat:@"%@[%@]",@"geo",@"acc"]];
	[reportData addEntriesFromDictionary:data];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"locationUpdated" object:nil];
    waitForLocation = NO;
	[self sendIfConditionsMatch];
}

- (void) dealloc {
	[super dealloc];
	[reportData release];
    [modules release];
    [url release];
    [picture release];
}
@end

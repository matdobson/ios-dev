

#import "LocationModule.h"


@implementation LocationModule


- (void)main {
	reportToFill.waitForLocation = YES;
}

- (NSString *) getName {
	return @"geo";
}


- (NSMutableDictionary *) reportData {
//parameters: {geo[lng]=-122.084095, geo[alt]=0.0, geo[lat]=37.422006, geo[acc]=0.0, api_key=rod8vlf13jco}
	 return nil;
}

- (void)dealloc {
	[super dealloc];
}
@end

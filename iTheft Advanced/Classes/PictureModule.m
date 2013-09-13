

#import "PictureModule.h"
#import "PicturesController.h"


@implementation PictureModule


-(void) main {
    reportToFill.waitForPicture = YES;
    camera = [self.configParms objectForKey:@"camera"];
    [[PicturesController instance]take:[NSNumber numberWithInt:5] usingCamera:camera];
}

- (NSString *) getName {
	return @"webcam";
}


- (NSMutableDictionary *) reportData {
    //parameters: {geo[lng]=-122.084095, geo[alt]=0.0, geo[lat]=37.422006, geo[acc]=0.0, api_key=rod8vlf13jco}
    return nil;
}

- (void)dealloc {
    [camera release];
	[super dealloc];
}

@end

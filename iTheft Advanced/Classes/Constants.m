
#import "Constants.h"


@implementation Constants
	NSString * const itheft_URL = @"http://control.itheftproject.com/";
	NSString * const itheft_SECURE_URL = @"https://control.itheftproject.com/";
    NSString * const itheft_API_URL = @"https://panel.itheftproject.com/";
	BOOL  const ASK_FOR_LOGIN = YES;
	BOOL const	USE_CONTROL_PANEL_DELAY=YES; //use the preferences page's instead.
    BOOL const	SHOULD_LOG=NO;

+(NSString *) appName {
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"];
}

+(NSString *) appVersion {
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
}

+(NSString *) appBuildVersion {
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
}

+(NSString *) appLabel {
    return [NSString stringWithFormat:@"%@ v%@ (build %@)",[Constants appName],[Constants appVersion],[Constants appBuildVersion]];
}

@end


#import "itheftModule.h"
#import "LocationModule.h"
#import "AlarmModule.h"
#import "AlertModule.h"
#import "PictureModule.h"
#import "GeofencingModule.h"

@implementation itheftModule

@synthesize configParms, reportToFill, type;

- (id) init {
	self = [super init];
	if(self != nil)
		configParms = [[NSMutableDictionary alloc] init];
	return self;
}

+ (itheftModule *) newModuleForName: (NSString *) moduleName {
	if ([moduleName isEqualToString:@"geo"]) {
		return [[LocationModule alloc] init];
	}
    if ([moduleName isEqualToString:@"geofencing"]) {
		return [[GeofencingModule alloc] init];
	}
	if ([moduleName isEqualToString:@"alarm"]) {
		return [[AlarmModule alloc] init];
	}
	if ([moduleName isEqualToString:@"alert"]) {
		return [[AlertModule alloc] init];
	}
    if ([moduleName isEqualToString:@"webcam"]) {
		return [[PictureModule alloc] init];
	}
	return nil;
}

- (NSString *) getName {
	return nil; //must be overriden;
}

- (NSMutableDictionary *) reportData {
	return nil; //must be overriden;
}

- (void) fillReportData:(ASIFormDataRequest*) request {
    //must be overriden;
}

-(void)dealloc {
    [super dealloc];
    [reportToFill release];
    [configParms release];
}

@end



#import <Foundation/Foundation.h>
#import "LocationController.h"
#import "itheftConfig.h"
#import "itheftRestHttp.h"


@interface itheftRunner : NSObject {
	CLLocation *lastLocation;
	NSOperationQueue *reportQueue;
	NSOperationQueue *actionQueue;
	itheftConfig *config;
	itheftRestHttp *http;
	NSDate *lastExecution;
	
}
@property (nonatomic, retain) CLLocation *lastLocation;
//@property (nonatomic, retain) NSDate *lastExecution;
@property (nonatomic, retain) itheftConfig *config;
@property (nonatomic, retain) itheftRestHttp *http;

+(itheftRunner *) instance;
-(void)startitheftService;
-(void)stopitheftService;
-(void) startOnIntervalChecking;
-(void) stopOnIntervalChecking;
-(void) runitheft;
-(void) runitheftNow;

@end

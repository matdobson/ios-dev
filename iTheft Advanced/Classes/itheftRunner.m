

#import "itheftRunner.h"
#import "LocationModule.h"
#import "DeviceModulesConfig.h"
#import "Report.h"
#import "SignificantLocationController.h"


@implementation itheftRunner

@synthesize lastLocation,config,http;

+(itheftRunner *)instance  {
	static itheftRunner *instance;
	
	@synchronized(self) {
		if(!instance) {
			instance = [[itheftRunner alloc] init];
			itheftLogMessage(@"itheft Runner", 0,@"Registering itheftRunner to receive location updates notifications");
			[[NSNotificationCenter defaultCenter] addObserver:instance selector:@selector(locationUpdated:) name:@"locationUpdated" object:nil];
            
            itheftRestHttp *itheftRestHttp = [[itheftRestHttp alloc] init];
			instance.http              = itheftRestHttp;
            [itheftRestHttp release];
		}
	}
	instance.config        = [itheftConfig instance];
    
	return instance;
}

-(void) startitheftOnMainThread {
	//We use the location services to keep itheft running in the background...
	LocationController *locController = [LocationController instance];
	[locController startUpdatingLocation];
	if (![itheftRestHttp checkInternet])
		return;
	[http changeStatusToMissing:YES forDevice:[config deviceKey] fromUser:[config apiKey]];
    config.missing=YES;
    itheftLogMessageAndFile(@"itheft Runner", 0,@"itheft service has been started.");

}
//this method starts the continous execution of itheft
-(void) startitheftService{
	[self performSelectorOnMainThread:@selector(startitheftOnMainThread) withObject:nil waitUntilDone:NO];
}

-(void)stopitheftService {
	LocationController *locController = [LocationController instance];
	[locController stopUpdatingLocation];
	if (![itheftRestHttp checkInternet])
		return;
	[http changeStatusToMissing:NO forDevice:[config deviceKey] fromUser:[config apiKey]];
    config.missing=NO;
    lastExecution = nil;
    itheftLogMessageAndFile(@"itheft Runner", 0,@"itheft service has been stopped.");
}

-(void) startOnIntervalChecking {
	[[SignificantLocationController instance] startMonitoringSignificantLocationChanges];
    itheftLogMessageAndFile(@"itheft Runner", 0,@"Interval checking has been started.");
}

-(void) stopOnIntervalChecking {
	[[SignificantLocationController instance] stopMonitoringSignificantLocationChanges];
    lastExecution = nil;
    itheftLogMessageAndFile(@"itheft Runner", 0,@"Interval checking has been stopped.");
}

-(void) runitheftNow {
    lastExecution = nil;
    NSInvocationOperation* theOp = [[[NSInvocationOperation alloc] initWithTarget:self selector:@selector(runitheft) object:nil] autorelease];
    [theOp start];
}


- (void)locationUpdated:(NSNotification *)notification
{
	NSInvocationOperation* theOp = [[[NSInvocationOperation alloc] initWithTarget:self selector:@selector(runitheft) object:nil] autorelease];
    [theOp start];
    
    /*
    if (lastExecution != nil) {
		NSTimeInterval lastRunInterval = -[lastExecution timeIntervalSinceNow];
		itheftLogMessage(@"itheft Runner", 0, @"Checking if delay of %i secs. is less than last running interval: %f secs.", [itheftConfig instance].delay, lastRunInterval);
		if (lastRunInterval >= [itheftConfig instance].delay){
			itheftLogMessage(@"itheft Runner", 0, @"New location notification received. Delay expired (%f secs. since last execution), running itheft now!", lastRunInterval);
			
            [theOp start];
            //[self runitheft]; 
		} else
            itheftLogMessage(@"itheft Runner", 5, @"Location updated notification received, but interval hasn't expired. (%f secs. since last execution)",lastRunInterval);
	} else {
		[theOp start];
	}*/
}


-(void) runitheft{
    @try {
        if (lastExecution != nil) {
            NSTimeInterval lastRunInterval = -[lastExecution timeIntervalSinceNow];
            itheftLogMessage(@"itheft Runner", 0, @"Checking if delay of %i secs. is less than last running interval: %f secs.", [itheftConfig instance].delay, lastRunInterval);
            if (lastRunInterval < [itheftConfig instance].delay){
                itheftLogMessage(@"itheft Runner", 0, @"Trying to get device's status but interval hasn't expired. (%f secs. since last execution). Aborting!", lastRunInterval);
                return;
            }
        }
        
        lastExecution = [[NSDate date] retain];
        if (![itheftRestHttp checkInternet])
            return;
        UIBackgroundTaskIdentifier bgTask = [[UIApplication sharedApplication]
                                             beginBackgroundTaskWithExpirationHandler:^{}];
        DeviceModulesConfig *modulesConfig = [[http getXMLforUser:[config apiKey] device:[config deviceKey]] retain];
        
        if (USE_CONTROL_PANEL_DELAY)
            [itheftConfig instance].delay = [modulesConfig.delay intValue] * 60;
        
        if (!modulesConfig.missing){
            itheftLogMessageAndFile(@"itheft Runner", 5, @"Not missing anymore... stopping accurate location updates and itheft.");
            [[LocationController instance] stopUpdatingLocation]; //finishes itheft execution
            [modulesConfig release];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"missingUpdated" object:[itheftConfig instance]];
            lastExecution=nil;
            return;
        }
        
        reportQueue = [[NSOperationQueue alloc] init];
        //[reportQueue addObserver:self forKeyPath:@"operationCount" options:0 context:modulesConfig.reportToFill];
        
        itheftModule *module;
        Report *report = nil;
        for (module in modulesConfig.reportModules){
            //[reportQueue  addOperation:module];
            itheftLogMessage(@"itheft Runner", 5, @"Executing module: %@.", [module getName]);
            [module main];
            report = module.reportToFill;
        }
        [report send];
        
        actionQueue = [[NSOperationQueue alloc] init];
        for (module in modulesConfig.actionModules){
            [actionQueue  addOperation:module];
        }
        
        
        [[UIApplication sharedApplication] endBackgroundTask:bgTask];
        
        [modulesConfig release];
    }
    @catch (NSException *exception) {
        itheftLogMessageAndFile(@"itheft Runner", 0, @"Exception catched while running itheft: %@", [exception reason]);
    }
	
	/*
	
	UILocalNotification *localNotif = [[UILocalNotification alloc] init];
	
    localNotif.fireDate = [NSDate dateWithTimeIntervalSinceNow:[modulesConfig.delay intValue]*60/4];
    localNotif.timeZone = [NSTimeZone defaultTimeZone];
	
    localNotif.alertBody = [NSString stringWithFormat:NSLocalizedString(@"itheft next execution in %i minutes.", nil), [modulesConfig.delay intValue]/4*60];
    localNotif.alertAction = NSLocalizedString(@"View Details", nil);
	
    localNotif.soundName = UILocalNotificationDefaultSoundName;
    //localNotif.applicationIconBadgeNumber = 1;
	
	
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotif];
    [localNotif release];
	*/
	
	
	
}

- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	if (object == reportQueue && [keyPath isEqual:@"operationCount"]) {
        if ([reportQueue operationCount] == 0) {
            Report *report = (Report *)context;
			[report send];
            itheftLogMessage(@"itheft Runner", 10, @"Queue has completed. Total modules in the report: %i", [report.modules count]);
        }
    }
    else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (void)dealloc {
	[reportQueue release], reportQueue = nil;
	[actionQueue release], actionQueue = nil;
	[http release];
	[lastExecution release];
    [super dealloc];
}
@end



#import "itheftRestHttp.h"
#import "KeyParserDelegate.h"
#import "UserParserDelegate.h"
#import "ErrorParserDelegate.h"
#import "ConfigParserDelegate.h"
#import "itheftConfig.h"
#import "Reachability.h"


@interface itheftRestHttp()

-(ASIHTTPRequest*)createGETrequestWithURL: (NSString*) url;
-(ASIFormDataRequest*)createPOSTrequestWithURL: (NSString*) url;
-(ASIFormDataRequest*)createPUTrequestWithURL: (NSString*) url;
-(void)setupRequest: (ASIHTTPRequest*)request;

@end

@implementation itheftRestHttp
@synthesize responseData;
@synthesize baseURL;

-(void)setupRequest: (ASIHTTPRequest*)request{
    //[request addRequestHeader:@"User-Agent" value:itheft_USER_AGENT];
    [request setUserAgentString:[self userAgent]];
    [request setAuthenticationScheme:(NSString *)kCFHTTPAuthenticationSchemeBasic];
	[request setUseSessionPersistence:NO];
	[request setShouldRedirect:NO];
	[request setValidatesSecureCertificate:NO];
    [request setTimeOutSeconds:30];
}

-(NSString *)userAgent {
    NSString *deviceName;
    NSString *OSName;
    NSString *OSVersion;
    NSString *locale = [[NSLocale currentLocale] localeIdentifier];
    
    UIDevice *device = [UIDevice currentDevice];
    deviceName = [device model];
    OSName = [device systemName];
    OSVersion = [device systemVersion];

    // Takes the form "My Application 1.0 (Macintosh; Mac OS X 10.5.7; en_GB)"
    return [NSString stringWithFormat:@"itheft/%@ (%@; %@ %@; %@)", [Constants appVersion], deviceName, OSName, OSVersion, locale];	
    
}

-(ASIHTTPRequest*)createGETrequestWithURL: (NSString*) url {
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:url]];
    [self setupRequest:request];
    return request;
}

-(ASIFormDataRequest*)createPOSTrequestWithURL: (NSString*) url{
	ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:url]];
	[request setRequestMethod:@"POST"];
	[self setupRequest:request];
    return request;
}

-(ASIFormDataRequest*)createPUTrequestWithURL: (NSString*) url{
	ASIFormDataRequest *request = [self createPOSTrequestWithURL:url];
	[request setRequestMethod:@"PUT"];
    return request;
}

- (NSString *) getCurrentControlPanelApiKey: (User *) user
{
    ASIHTTPRequest *request = [self createGETrequestWithURL:[itheft_API_URL stringByAppendingFormat: @"profile.xml"]];
    [request setUsername:[user email]];
	[request setPassword: [user password]];
	
	@try {
		[request startSynchronous];
		NSError *error = [request error];
		int statusCode = [request responseStatusCode];
		itheftLogMessage(@"itheftRestHttp", 10, @"GET profile.xml: %@",[request responseStatusMessage]);
		if (statusCode == 401){
			NSString *errorMessage = NSLocalizedString(@"There was a problem getting your account information. Please make sure the email address you entered is valid, as well as your password.",nil);
			@throw [NSException exceptionWithName:@"GetApiKeyException" reason:errorMessage userInfo:nil];
		}
		if (!error) {	
			UserParserDelegate *keyParser = [[UserParserDelegate alloc] init];
			[keyParser parseRequest:[request responseData] forUser:user parseError:&error];
			return user.apiKey;
		}	
		else {
			@throw [NSException exceptionWithName:@"GetApiKeyUnknownException" reason:[error localizedDescription] userInfo:nil];
		}		
	}
	@catch (NSException * e) {
		@throw e;
	}
	return nil;
}


- (NSString *) createApiKey: (User *) user
{
	ASIFormDataRequest *request = [self createPOSTrequestWithURL:[itheft_SECURE_URL stringByAppendingFormat: @"users.xml"]];
	[request setPostValue:[user name] forKey:@"user[name]"];
	[request setPostValue:[user email] forKey:@"user[email]"];
	[request setPostValue:[user country] forKey:@"user[country_name]"]; 
	[request setPostValue:[user password] forKey:@"user[password]"];
	[request setPostValue:[user repassword] forKey:@"user[password_confirmation]"];
	[request setPostValue:@"" forKey:@"user[referer_user_id]"];
	
	@try {
		[request startSynchronous];
		NSError *error = [request error];
		if (!error) {
			int statusCode = [request responseStatusCode];
			//NSString *statusMessage = [request responseStatusMessage];
			//NSString *response = [request responseString];
			if (statusCode != 201){
				NSString *errorMessage = [self getErrorMessageFromXML:[request responseData]];
				@throw [NSException exceptionWithName:@"CreateApiKeyException" reason:errorMessage userInfo:nil];
			}
				
			
			KeyParserDelegate *keyParser = [[KeyParserDelegate alloc] init];
			NSString *key = [keyParser parseKey:[request responseData] parseError:&error];
			return key;
		}	
		else {
			@throw [NSException exceptionWithName:@"CreateApiKeyException" reason:[error localizedDescription] userInfo:nil];
			
		}
	}
	@catch (NSException * e) {
		@throw;
	}
	
	return nil;
}

- (NSString *) createDeviceKeyForDevice: (Device *) device usingApiKey: (NSString *) apiKey {
	
	ASIFormDataRequest *request = [self createPOSTrequestWithURL:[itheft_URL stringByAppendingFormat: @"devices.xml"]];
	[request setUsername:apiKey];
	[request setPassword: @"x"];
	[request setPostValue:[device name] forKey:@"device[title]"];
	[request setPostValue:[device type] forKey:@"device[device_type]"];
	[request setPostValue:[device version] forKey:@"device[os_version]"];
    [request setPostValue:[device model] forKey:@"device[model_name]"];
    [request setPostValue:[device vendor] forKey:@"device[vendor_name]"];
	[request setPostValue:[device os] forKey:@"device[os]"];
	[request setPostValue:[device macAddress] forKey:@"device[physical_address]"];
    [request setPostValue:[device uuid] forKey:@"device[uuid]"];
	
	@try {
		[request startSynchronous];
		NSError *error = [request error];
		if (!error) {
			int statusCode = [request responseStatusCode];
			if (statusCode == 302)
				@throw [NSException exceptionWithName:@"NoMoreDevicesAllowed" reason:NSLocalizedString(@"It seems you've reached your limit for devices on the Control Panel. Try removing this device from your account if you had already added.",nil) userInfo:nil];
			
			//NSString *statusMessage = [request responseStatusMessage];
			NSString *response = [request responseString];
			itheftLogMessage(@"itheftRestHttp", 10, @"POST devices.xml: %@",response);
			KeyParserDelegate *keyParser = [[KeyParserDelegate alloc] init];
			NSString *deviceKey = [keyParser parseKey:[request responseData] parseError:&error];
			return deviceKey;
		}	
		else {
			@throw [NSException exceptionWithName:@"CreateDeviceKeyException" reason:[error localizedDescription] userInfo:nil];
			
		} 
	} 
	@catch (NSException *e) {
		@throw;
	}
	
	return nil;
	
}

- (DeviceModulesConfig *) getXMLforUser: (NSString *) apiKey device:(NSString *) deviceKey;
{

    ASIHTTPRequest *request = [self createGETrequestWithURL:[itheft_URL stringByAppendingFormat: @"devices/%@.xml", deviceKey]];
    [request setUsername:apiKey];
	[request setPassword: @"x"];
	
	@try {
		[request startSynchronous];
		NSError *error = [request error];
		int statusCode = [request responseStatusCode];
		//NSString *statusMessage = [request responseStatusMessage];
		//NSString *response = [request responseString];
		itheftLogMessage(@"itheftRestHttp", 10, @"GET devices/%@.xml: %@",deviceKey,[request responseStatusMessage]);
        //LogMessage(@"itheftRestHttp", 20, @"GET devices/%@.xml response: %@",deviceKey,[request responseString]);
		if (statusCode == 401){
			NSString *errorMessage = NSLocalizedString(@"There was a problem getting your account information. Please make sure the email address you entered is valid, as well as your password.",nil);
			@throw [NSException exceptionWithName:@"GetApiKeyException" reason:errorMessage userInfo:nil];
		}
		
		if (!error) {
			NSError *error = nil;
			ConfigParserDelegate *configParser = [[ConfigParserDelegate alloc] init];
			NSData *respData = [request responseData];
			DeviceModulesConfig *modulesConfig = [configParser parseModulesConfig:respData parseError:&error];
			//[configParser release];
			return modulesConfig;
		}	
		else {
			@throw [NSException exceptionWithName:@"GetXMLforDeviceException" reason:[error localizedDescription] userInfo:nil];
		}
		
		
	}
	@catch (NSException * e) {
		@throw;
	}
	return nil;
}

- (BOOL) isMissingTheDevice: (NSString *) device ofTheUser: (NSString *) apiKey{
	return [self getXMLforUser:apiKey device:device].missing;
}

- (BOOL) changeStatusToMissing: (BOOL) missing forDevice:(NSString *) deviceKey fromUser: (NSString *) apiKey {
	ASIFormDataRequest *request = [self createPUTrequestWithURL:[itheft_URL stringByAppendingFormat: @"devices/%@.xml", deviceKey]];
    [request setShouldContinueWhenAppEntersBackground:YES];
	[request setUsername:apiKey];
	[request setPassword: @"x"];
	if (missing)
		[request setPostValue:@"1" forKey:@"device[missing]"];
	else
		[request setPostValue:@"0" forKey:@"device[missing]"];
	
	@try {
        itheftLogMessage(@"itheftRestHttp", 10, @"Attempting to change status on Control Panel");
		[request startSynchronous];
        itheftLogMessage(@"itheftRestHttp", 10, @"PUT devices/%@.xml [missing=%@] response: %@",deviceKey,missing?@"YES":@"NO",[request responseStatusMessage]);
		NSError *error = [request error];
		if (!error) {
			/*
			 int statusCode = [request responseStatusCode];
			 NSString *statusMessage = [request responseStatusMessage];
			 NSString *response = [request responseString];
			 //LogMessageCompat(@"URL: %@ response status: %@ with data: %@", url, statusMessage, response );
			 */
			return NO;
		}
		
		else {
			return YES;
			
		}
	}
	@catch (NSException * e) {
		@throw;
	}
	
	return NO;
	
}

- (BOOL) validateIfExistApiKey: (NSString *) apiKey andDeviceKey: (NSString *) deviceKey
{
	
	ASIHTTPRequest *request = [self createGETrequestWithURL:[itheft_URL stringByAppendingFormat: @"devices.xml"]];
	[request setUsername:apiKey];
	[request setPassword:@"x"];
	
	@try {
		[request startSynchronous];
		NSError *error = [request error];
		/*
		int statusCode = [request responseStatusCode];
		NSString *statusMessage = [request responseStatusMessage];
		 */
		NSString *response = [request responseString];
		if (!error) {
			NSString *extractedDeviceKey = NULL;
			[response getCapturesWithRegexAndReferences:deviceKey,	 @"$0", &extractedDeviceKey, nil];	
			//LogMessageCompat(@"Extracted key from response: %@", extractedDeviceKey);
			return [extractedDeviceKey isEqual:deviceKey];
		}
		
		else {
			return NO;
			
		}
	}
	@catch (NSException * e) {
		@throw;
	}
	
	return NO;
}

- (BOOL) deleteDevice: (Device*) device{
	itheftConfig* itheftConfig = [itheftConfig instance];
	__block ASIHTTPRequest *request = [self createGETrequestWithURL:[itheft_URL stringByAppendingFormat: @"devices/%@.xml", [device deviceKey]]];
	[request setUsername:[itheftConfig apiKey]];
	[request setPassword: @"x"];
	[request setRequestMethod:@"DELETE"];
    
    @try {
		[request startSynchronous];
		NSError *error = [request error];
		if (!error) {
			return NO;
		}
		
		else {
			return YES;
			
		}
	}
	@catch (NSException * e) {
		@throw;
	}
        
	return NO;
	
}

- (void) sendReport: (Report *) report {
	itheftConfig *itheftConfig = [itheftConfig instance];
	__block ASIFormDataRequest *request = [self createPOSTrequestWithURL:report.url];
    [request setShouldContinueWhenAppEntersBackground:YES];
	[request setUsername:[itheftConfig apiKey]];
	[request setPassword: @"x"];
	
    /*
	[[report getReportData] enumerateKeysAndObjectsUsingBlock:^(id key, id object, BOOL *stop) {
		//LogMessage(@"itheftRestHttp", 10, @"Adding to report: %@ = %@", key, object);
		[request addPostValue:(NSString*)object forKey:(NSString *) key];
	}];
     */
    [report fillReportData:request];
    [request setNumberOfTimesToRetryOnTimeout:5];
    //[request setDelegate:self];
    
    [request setCompletionBlock:^{
        int statusCode = [request responseStatusCode];
        if (statusCode != 200)
            itheftLogMessageAndFile(@"itheftRestHttp", 0, @"Report wasn't sent: %@", [request responseStatusMessage]);
            //@throw [NSException exceptionWithName:@"ReportNotSentException" reason:NSLocalizedString(@"Report couldn't be sent",nil) userInfo:nil];
        else
            itheftLogMessageAndFile(@"itheftRestHttp", 10, @"Report: POST %@ response: %@",report.url,[request responseStatusMessage]);
    }];
    [request setFailedBlock:^{
        /*@throw [NSException exceptionWithName:@"ReportNotSentException" reason:[[request error] localizedDescription] userInfo:nil]; 
         */
        itheftLogMessageAndFile(@"itheftRestHttp", 0, @"Report couldn't be sent: %@", [[request error] localizedDescription]);
    }];
    [request startAsynchronous];
	/*** USED FOR SYNC SENDING **/
    /*
	@try {
		[request startAsynchronous];
		NSError *error = [request error];
		if (!error) {
			int statusCode = [request responseStatusCode];
			if (statusCode != 200)
				@throw [NSException exceptionWithName:@"ReportNotSentException" reason:NSLocalizedString(@"Report couldn't be sent",nil) userInfo:nil];
			NSString *response = [request responseString];
			LogMessage(@"itheftRestHttp", 10, @"Report sent response: %@",response);
		}	
		else {
			@throw [NSException exceptionWithName:@"ReportNotSentException" reason:[error localizedDescription] userInfo:nil];
			
		} 
	} 
	@catch (NSException *e) {
		@throw;
	}
     */
	
}

- (void) getAppstoreConfig: (id) delegate inURL: (NSString *) URL {
    ASIHTTPRequest *request = [self createGETrequestWithURL:[itheft_API_URL stringByAppendingFormat:@"%@",URL]];
    [request setDelegate:delegate];
    [request setDidFinishSelector:@selector(receivedData:)];
    [request startAsynchronous];
}


- (NSString *) getErrorMessageFromXML: (NSData*) response {
	
	NSError *error = nil;
	ErrorParserDelegate *errorsParser = [[ErrorParserDelegate alloc] init];
	NSMutableArray *errors = [errorsParser parseErrors:response parseError:&error];
	[errorsParser release];
	return (NSString*)[errors objectAtIndex:0];
	
}

+(BOOL)checkInternet{
	//Test for Internet Connection
	itheftLogMessage(@"itheftRestHttp", 10, @"Checking for Internet connection.");
	Reachability *r = [Reachability reachabilityWithHostName:@"control.itheftproject.com"];
	NetworkStatus internetStatus = [r currentReachabilityStatus];
	BOOL internet;
	if ((internetStatus != ReachableViaWiFi) && (internetStatus != ReachableViaWWAN)) {
		internet = NO;
		itheftLogMessage(@"itheftRestHttp", 10, @"Internet connection NOT FOUND!");
	} else {
		internet = YES;
		itheftLogMessage(@"itheftRestHttp", 10, @"Internet connection FOUND!");
	}
	return internet;
}

- (void) setPushRegistrationId: (NSString *) id {
    itheftConfig *itheftConfig = [itheftConfig instance];
	__block ASIFormDataRequest *request = [self createPUTrequestWithURL:[itheft_URL stringByAppendingFormat: @"devices/%@.xml", [itheftConfig deviceKey]]];
    [request setShouldContinueWhenAppEntersBackground:YES];
	[request setUsername:[itheftConfig apiKey]];
	[request setPassword: @"x"];
	[request setPostValue:id forKey:@"device[notification_id]"];
    [request setNumberOfTimesToRetryOnTimeout:5];
    
    [request setCompletionBlock:^{
        int statusCode = [request responseStatusCode];
        if (statusCode != 200)
            itheftLogMessageAndFile(@"itheftRestHttp", 0, @"Device notification_id WASN't updated on the Control Panel: %@", [request responseStatusMessage]);
        else
            itheftLogMessageAndFile(@"itheftRestHttp", 10, @"Device notification_id updated OK on the Control Panel");
    }];
    [request setFailedBlock:^{
        itheftLogMessageAndFile(@"itheftRestHttp", 0, @"ERROR Updating device reg_id on the Control Panel: %@", [[request error] localizedDescription]);
    }];
	[request startAsynchronous];
}

@end

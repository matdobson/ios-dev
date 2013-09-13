

#import <Foundation/Foundation.h>

@interface Constants : NSObject {
    
	
}
//extern NSString * const itheft_VERSION;
extern NSString * const itheft_SECURE_URL;
extern NSString * const itheft_URL;
extern NSString * const itheft_API_URL;
//extern NSString * const itheft_USER_AGENT;
extern BOOL  const ASK_FOR_LOGIN;
extern BOOL const USE_CONTROL_PANEL_DELAY;
extern BOOL const SHOULD_LOG;

+(NSString *) appName;
+(NSString *) appVersion;
+(NSString *) appBuildVersion;
+(NSString *) appLabel;

@end

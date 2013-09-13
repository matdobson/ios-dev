

#import <Foundation/Foundation.h>
#import "Device.h"

@interface User : NSObject {
	
	NSString *apiKey;
	NSString *name;
	NSString *email;
	NSString *country;
	NSString *password;
	NSString *repassword;
	NSArray *devices;

}

@property (nonatomic,retain) NSString *apiKey;
@property (nonatomic,retain) NSString *name;
@property (nonatomic,retain) NSString *email;
@property (nonatomic,retain) NSString *country;
@property (nonatomic,retain) NSString *password;
@property (nonatomic,retain) NSString *repassword;
@property (nonatomic,retain) NSArray *devices;
@property (nonatomic, getter = isPro) BOOL pro;

+(User*) allocWithEmail: (NSString*) email password: (NSString*) password;
+(User*) createNew: (NSString*) name email: (NSString*) email password: (NSString*) password repassword: (NSString*) repassword;
-(BOOL) deleteDevice: (Device*) device;


@end

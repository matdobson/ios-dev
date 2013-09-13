
#import <Foundation/Foundation.h>
#import "Report.h"

@interface DeviceModulesConfig : NSObject {
	BOOL missing;
	NSNumber *delay;
	NSString *postUrl;
	NSMutableArray *reportModules;
	NSMutableArray *actionModules;
	Report *reportToFill;

}
@property (nonatomic) BOOL missing;
@property (nonatomic, retain) NSNumber *delay;
@property (nonatomic, retain) NSString *postUrl;
@property (nonatomic, retain) NSMutableArray *reportModules;
@property (nonatomic, retain) NSMutableArray *actionModules;
@property (nonatomic, retain) Report *reportToFill;

- (void) addModuleName: (NSString *) name ifActive: (NSString *) isActive ofType: (NSString *) type;
- (void) addConfigValue: (NSString *) value withKey: (NSString *) key forModuleName: (NSString *) name;
- (BOOL) willRequireLocation;

@end

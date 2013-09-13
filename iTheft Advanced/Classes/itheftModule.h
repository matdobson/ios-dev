

#import <Foundation/Foundation.h>
#import "Report.h"

enum _ModuleType {ReportModuleType = 0, ActionModuleType};
typedef NSInteger ModuleType;

@interface itheftModule : NSOperation {
	NSMutableDictionary *configParms;
	Report *reportToFill;
	ModuleType type;
}
@property (nonatomic, retain) NSMutableDictionary *configParms;
@property (nonatomic, retain) Report *reportToFill;
@property (nonatomic) ModuleType type;

+ (itheftModule *) newModuleForName: (NSString *) moduleName;
- (NSString *) getName;
- (NSMutableDictionary *) reportData;

@end

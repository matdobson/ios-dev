
#import <Foundation/Foundation.h>

extern void itheftLogMessage(NSString *domain, int level, NSString *format, ...);
extern void itheftLogMessageAndFile(NSString *domain, int level, NSString *format, ...);

@interface itheftLogger : NSObject {
    
}

+ (void) LogToFile:(NSString*)msg;
+ (void) clearLogFile;
+ (NSArray*) getLogArray;
+ (NSString*) logAsText;

@end

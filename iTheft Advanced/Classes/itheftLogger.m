

#import "itheftLogger.h"
#import "Constants.h"

void itheftLogMessage(NSString *domain, int level, NSString *format, ...)
{

    if (SHOULD_LOG) {
        va_list args;
        va_start(args, format);
        NSString *msgString = [[NSString alloc] initWithFormat:format arguments:args];
        if (msgString != nil)
        {
            LogMessage(domain, level, msgString);
            [msgString release];
        }
        
        va_end(args);
    }
    
}

void itheftLogMessageAndFile(NSString *domain, int level, NSString *format, ...)
{
    if (SHOULD_LOG) {
        va_list args;
        va_start(args, format);
        NSString *msgString = [[NSString alloc] initWithFormat:format arguments:args];
        if (msgString != nil)
        {
            LogMessage(domain, level, msgString);
            [itheftLogger LogToFile:msgString];
            [msgString release];
        }
        va_end(args);
    }
    
}

@implementation itheftLogger
+ (NSString*)logFilePath {
    NSString* path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
	return [path stringByAppendingPathComponent:@"itheft.log"];
}

+(void) LogToFile:(NSString*)msg{
    
    NSDateFormatter * formatter = [[[NSDateFormatter alloc] init] autorelease];
	[formatter setTimeStyle:NSDateFormatterMediumStyle];
	NSString *logMessage = [NSString stringWithFormat:@"%@ %@", [formatter stringFromDate:[NSDate date]], msg];
    
	NSString *fileName = [itheftLogger logFilePath];
	FILE * f = fopen([fileName cStringUsingEncoding:NSStringEncodingConversionAllowLossy], "at");
	fprintf(f, "%s\n", [logMessage cStringUsingEncoding:NSStringEncodingConversionAllowLossy]);
	fclose (f);
}

+ (void) clearLogFile
{
	NSString * content = @"";
	NSString * fileName = [itheftLogger logFilePath];
	[content writeToFile:fileName 
              atomically:NO 
                encoding:NSStringEncodingConversionAllowLossy 
                   error:nil];
}

+ (NSArray*) getLogArray
{
	NSString * fileName = [itheftLogger logFilePath];
	NSString *content = [NSString stringWithContentsOfFile:fileName
                                              usedEncoding:nil error:nil];
	NSMutableArray * array = (NSMutableArray *)[content componentsSeparatedByString:@"\n"];
	NSMutableArray * newArray = [[[NSMutableArray alloc] init] autorelease];
	for (int i = 0; i < [array count]; i++)
	{
		NSString * item = [array objectAtIndex:i];
		if ([item length])
			[newArray addObject:item];
	}
	return (NSArray*)newArray;
}

+ (NSString*) logAsText {
    NSString * fileName = [itheftLogger logFilePath];
	NSString *content = [NSString stringWithContentsOfFile:fileName
                                              usedEncoding:nil error:nil];
    return content;
}

@end



#import <Foundation/Foundation.h>
#import "User.h"

enum UserProfileNode {
    UserProfileNodeUnknown = 0,
    UserProfileNodeKey,
    UserProfileNodeProAccount
};

@interface UserParserDelegate : NSObject <NSXMLParserDelegate> {
    
@private
    User *user;
	enum UserProfileNode currentNode;
}

- (NSString*) parseRequest:(NSData *)request forUser:(User*)user parseError:(NSError **)err;

@end
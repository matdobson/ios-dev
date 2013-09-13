

#import <Foundation/Foundation.h>


@interface KeyParserDelegate : NSObject <NSXMLParserDelegate> {
	NSString *key;
@private
	BOOL areInKeyNode;

}

@property (nonatomic,retain) NSString *key;

- (NSString*) parseKey:(NSData *)request parseError:(NSError **)err;
- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName attributes:(NSDictionary *)attributeDict;
- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName;
- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string;
	
@end

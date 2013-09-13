

#import <Foundation/Foundation.h>
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>

#define DELETE_LOG_BUTTON 1
#define SEND_LOG_BUTTON 2
#define REFRESH_LOG_BUTTON 3

@interface LogController : UITableViewController<MFMailComposeViewControllerDelegate, UIActionSheetDelegate> {
    UIToolbar *toolbar;
    NSArray *logArray;
}

@end

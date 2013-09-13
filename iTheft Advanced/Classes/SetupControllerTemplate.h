

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"
#import "RegexKitLite.h"

#define kLabelTag	4096

@interface SetupControllerTemplate : UITableViewController <MBProgressHUDDelegate> {
	
	MBProgressHUD *HUD;
	UITableViewCell *buttonCell;
	NSString *strEmailMatchstring;
	BOOL enableToSubmit;
}

//- (IBAction) next: (id) sender;
//- (IBAction) cancel: (id) sender;
//- (IBAction) doneEditing:(id)sender;
- (void) activateitheftService;
- (void) showCongratsView:(id) congratsText;

@end

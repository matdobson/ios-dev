

#import <UIKit/UIKit.h>
#import "AccuracyManager.h"
#import "DelayManager.h"
#import "MBProgressHUD.h"

#define kDetachAction  1;

@interface PreferencesController : UITableViewController <UIActionSheetDelegate, MBProgressHUDDelegate>  {
UIActivityIndicatorView *cLoadingView;
	AccuracyManager *accManager;
	DelayManager *delayManager;
	UISwitch *missing;
    UISwitch *intervalCheckin;
    BOOL pickerShowed;
    MBProgressHUD *HUD;
	
}

@property (nonatomic, retain) AccuracyManager *accManager;
@property (nonatomic, retain) DelayManager *delayManager;

- (void) setupNavigatorForPicker:(BOOL)showed withSelector:(SEL)action;

@end

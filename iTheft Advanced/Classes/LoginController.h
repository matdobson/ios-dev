
#import <UIKit/UIKit.h>
#import "PreferencesController.h"
#import "MBProgressHUD.h"
#import "UIWebViewController.h"

#define kOFFSET_FOR_KEYBOARD 150.0

@interface LoginController : UIViewController <UIWebViewControllerDelegate,MBProgressHUDDelegate, UIAlertViewDelegate> {
@private
	UITextField *loginPassword;
	MBProgressHUD *HUD;
    UIImageView *loginImage;
    UIScrollView *scrollView;
    UIImageView *nonCamuflageImage;
    UIImageView *itheftLogo;
    UIImageView *buttn;
    UILabel *devReady;
    UILabel *detail;
    UIButton *loginButton;
}

@property (nonatomic, retain) IBOutlet UIImageView *loginImage;
@property (nonatomic, retain) IBOutlet UIScrollView *scrollView;
@property (nonatomic, retain) IBOutlet UITableView *tableView;
@property (nonatomic, retain) IBOutlet UITextField *loginPassword;
@property (nonatomic, retain) IBOutlet UIImageView *nonCamuflageImage;
@property (nonatomic, retain) IBOutlet UIImageView *buttn;
@property (nonatomic, retain) IBOutlet UIImageView *itheftLogo;
@property (nonatomic, retain) IBOutlet UILabel *devReady;
@property (nonatomic, retain) IBOutlet UILabel *detail;
@property (nonatomic, retain) IBOutlet UILabel *tipl;
@property (nonatomic, retain) IBOutlet UIButton *loginButton;

- (IBAction) checkLoginPassword: (id) sender;

@end

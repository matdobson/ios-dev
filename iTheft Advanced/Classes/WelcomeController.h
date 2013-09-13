

#import <UIKit/UIKit.h>


@interface WelcomeController : UIViewController {
    UIButton *buttnewUser;
    UIButton *buttoldUser;
}
-(IBAction)newUserClicked:(id)sender;
-(IBAction)oldUserClicked:(id)sender;

@property (nonatomic, retain) IBOutlet UIButton *buttnewUser;
@property (nonatomic, retain) IBOutlet UIButton *buttoldUser;

@end

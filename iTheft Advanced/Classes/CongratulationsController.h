

#import <UIKit/UIKit.h>


@interface CongratulationsController : UIViewController {

	UILabel *congratsTitle;
	UILabel *congratsMsg;
	UIButton *ok;
    NSString *txtToShow;
}

@property (nonatomic, retain) IBOutlet UILabel *congratsTitle;
@property (nonatomic, retain) IBOutlet UILabel *congratsMsg;
@property (nonatomic, retain) IBOutlet UIButton *ok;
@property (nonatomic, retain) NSString *txtToShow;

- (IBAction) okPressed: (id) sender;

@end

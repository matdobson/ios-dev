

#import <UIKit/UIKit.h>


@interface AlertModuleController : UIViewController {

    UILabel *itheftName;
	UILabel *text;
	NSString *textToShow;
}

@property (nonatomic, retain) IBOutlet UILabel *itheftName;
@property (nonatomic, retain) IBOutlet UILabel *text;
@property (nonatomic, retain) NSString *textToShow;

@end

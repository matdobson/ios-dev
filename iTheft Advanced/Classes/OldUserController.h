

#import <UIKit/UIKit.h>
#import "SetupControllerTemplate.h"



//@interface OldUserController : SetupControllerTemplate < UITableViewDelegate, UITableViewDataSource > {
@interface OldUserController : SetupControllerTemplate <UITextFieldDelegate>{
	
	UITextField *email;
	UITextField *password;


}

@property (nonatomic, retain) UITextField *email;
@property (nonatomic, retain) UITextField *password;

@end

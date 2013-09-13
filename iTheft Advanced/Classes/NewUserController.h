

#import <UIKit/UIKit.h>
#import "SetupControllerTemplate.h"


@interface NewUserController : SetupControllerTemplate <UITextFieldDelegate> {
	UITextField *name;
	UITextField *email;
	UITextField *password;
	UITextField *repassword;
}

@end



#import "OldUserController.h"
#import "CongratulationsController.h"
#import "User.h"
#import "Device.h"
#import "itheftConfig.h"
#import "itheftAppDelegate.h"



@interface OldUserController () 

- (void) addDeviceForCurrentUser;

@end

@implementation OldUserController

@synthesize email, password;

- (void) addDeviceForCurrentUser {
/*
#if (TARGET_IPHONE_SIMULATOR)
	sleep(1);
	[self performSelectorOnMainThread:@selector(showCongratsView) withObject:nil waitUntilDone:NO];
#else
*/	
	
	User *user = nil;
	Device *device = nil;
	itheftConfig *config = nil;
	@try {
		user = [User allocWithEmail:[email text] password:[password text]];
		device = [Device newDeviceForApiKey:[user apiKey]];
		config = [[itheftConfig initWithUser:user andDevice:device] retain];
		if (config != nil){
            NSString *txtCongrats = NSLocalizedString(@"Congratulations! You have successfully associated this iOS device with your itheft account.",nil);
            [super activateitheftService];
			[self performSelectorOnMainThread:@selector(showCongratsView:) withObject:txtCongrats waitUntilDone:NO];
        }

	}
	@catch (NSException * e) {		
		if (device != nil)
			[user deleteDevice:device];
		UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Couldn't add your device",nil) message:[e reason] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
		
		[alertView show];
		[alertView release];
	} @finally {
        [config release];
		[user release];
		[device release];
	}
//#endif
}




#pragma mark -
#pragma mark IBAction

- (IBAction) next: (id) sender
{
	/*
	[self hideKeyboard];
	HUD = [[MBProgressHUD alloc] initWithView:self.view];
    HUD.delegate = self;
    HUD.labelText = NSLocalizedString(@"Attaching device...",nil);
	[self.navigationController.view addSubview:HUD];
	[HUD showWhileExecuting:@selector(addDeviceForCurrentUser) onTarget:self withObject:nil animated:YES];
	*/
}


#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 2;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
	switch (section) {
		case 0:
			return 2;
			break;

		default:
			return 1;
			break;
	}
	
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
	if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
		UILabel *label =[[UILabel alloc] initWithFrame:CGRectMake(10, 10, 75, 25)];
		label.textAlignment = UITextAlignmentLeft;
		label.tag = kLabelTag;
        label.backgroundColor = [UIColor clearColor];
		label.font = [UIFont boldSystemFontOfSize:14];
		[cell.contentView addSubview:label];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
		[label release];
		
    }
    
	UILabel *label = (UILabel *)[cell viewWithTag:kLabelTag];
	
    switch ([indexPath section]) {
		case 0:
			if ([indexPath row] == 0){
				label.text = NSLocalizedString(@"Email",nil);
				[cell.contentView addSubview:email];
				
			}
			else if ([indexPath row] == 1){
				label.text = NSLocalizedString(@"Password",nil);
				[cell.contentView addSubview:password];
			}
			break;
		case 1:
			return buttonCell;
			break;

		default:
			break;
	}
    
    return cell;
}


#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	//LogMessageCompat(@"Table cell press. Section: %i, Row: %i",[indexPath section],[indexPath row]);
	//itheftLogMessageAndFile(@"Old user controller", 10, @"Table cell press. Section: %i, Row: %i",[indexPath section],[indexPath row]);
    switch ([indexPath section]) {
		case 0:
			if ([indexPath row] == 0)
				[email becomeFirstResponder];
                
			else if ([indexPath row] == 1)
                [password becomeFirstResponder];
            break;
				
        case 1:
            
			//if (enableToSubmit) {
				if (![email.text isMatchedByRegex:strEmailMatchstring]){
					UIAlertView *objAlert = [[UIAlertView alloc] initWithTitle:@"Error!" message:NSLocalizedString(@"Enter a valid e-mail address",nil) delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Try Again",nil];
					[objAlert show];
					[objAlert release];
					[email becomeFirstResponder];
					return;
				}
				[email resignFirstResponder];
				[password resignFirstResponder];
				HUD = [[MBProgressHUD alloc] initWithView:self.view];
				HUD.delegate = self;
				HUD.labelText = NSLocalizedString(@"Attaching device...",nil);
				[self.navigationController.view addSubview:HUD];
				[HUD showWhileExecuting:@selector(addDeviceForCurrentUser) onTarget:self withObject:nil animated:YES];
			//}
                	
			break;

		default:
			break;
	}
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark -
#pragma mark UITextField delegate methods

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    NSInteger nextTag = textField.tag + 1;
    // Try to find next responder
    UIResponder* nextResponder = (UITextField *)[self.view viewWithTag:nextTag];
    if (nextResponder) {
        // Found next responder, so set it.
        [nextResponder becomeFirstResponder];
    } else {
        // Not found, so remove keyboard.
        [textField resignFirstResponder];
    }
    return NO; // We do not want UITextField to insert line-breaks.
}


- (void)checkFieldsToEnableSendButton:(id)sender {
	if (email.text != nil && 
		![email.text isEqualToString:@""] && 
		password.text != nil && 
		![password.text isEqualToString:@""]) {
			buttonCell.selectionStyle = UITableViewCellSelectionStyleBlue;
			buttonCell.textLabel.textColor = [UIColor blackColor];
			enableToSubmit = YES;
	} else {
		buttonCell.selectionStyle = UITableViewCellSelectionStyleNone;
		buttonCell.textLabel.textColor = [UIColor grayColor];
		enableToSubmit = NO;
	}
}

#pragma mark -

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    
	email = [[UITextField alloc] initWithFrame:CGRectMake(90,12,200,25)];
	email.clearsOnBeginEditing = NO;
	email.returnKeyType = UIReturnKeyNext;
    email.tag = 50;
	email.placeholder = @"Your itheft account email";
	email.keyboardType = UIKeyboardTypeEmailAddress;
	email.autocapitalizationType = UITextAutocapitalizationTypeNone;
	[email setDelegate:self];
	//[email addTarget:self action:@selector(checkFieldsToEnableSendButton:) forControlEvents:UIControlEventEditingChanged];
	
	password = [[UITextField alloc] initWithFrame:CGRectMake(90,12,200,25)];
	password.clearsOnBeginEditing = NO;
	password.returnKeyType = UIReturnKeyDone;
    password.tag = 51;
	[password setSecureTextEntry:YES];
	password.placeholder = @"Your itheft account password";
	[password setDelegate:self];
	//[password addTarget:self action:@selector(checkFieldsToEnableSendButton:) forControlEvents:UIControlEventEditingChanged];
	
	buttonCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"buttonCell"];
    buttonCell.selectionStyle = UITableViewCellSelectionStyleBlue;
    buttonCell.textLabel.textColor = [UIColor blackColor];
	//buttonCell.selectionStyle = UITableViewCellSelectionStyleNone;
	//buttonCell.textLabel.textColor = [UIColor grayColor];
	buttonCell.textLabel.textAlignment = UITextAlignmentCenter;
	buttonCell.textLabel.text = NSLocalizedString(@"Add this device!",nil);
	
	[super viewDidLoad];
}



// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}



- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
}

- (void)dealloc {
    [super dealloc];
	[email release];
	[password release];
	//[buttonCell release];

}



@end

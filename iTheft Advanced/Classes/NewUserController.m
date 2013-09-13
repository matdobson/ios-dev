

#import "NewUserController.h"
#import "User.h"
#import "Device.h"
#import "itheftConfig.h"


@interface NewUserController () 

- (void) addNewUser;

@end

@implementation NewUserController

#pragma mark -
#pragma mark Private methods

- (void) hideKeyboard {
	
	[email resignFirstResponder];
	[name resignFirstResponder];
	[password resignFirstResponder];
	[repassword resignFirstResponder];
}

- (void) addNewUser {
	if (![password.text isEqualToString:repassword.text]){
		UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"We have a situation!",nil) message:NSLocalizedString(@"Passwords do not match",nil) delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];		
		[alertView show];
		[alertView release];	
		return;
	}
	if ([password.text length] <6){
		UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"We have a situation!",nil) message:NSLocalizedString(@"Password must be at least 6 characters",nil) delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];		
		[alertView show];
		[alertView release];
		return;
	}
	
#if (TARGET_IPHONE_SIMULATOR)
	sleep(1);
    NSString *txtCongrats = NSLocalizedString(@"Account created! Remember to verify your account by opening your inbox and clicking on the link we sent to your email address.",nil);
	[self performSelectorOnMainThread:@selector(showCongratsView:) withObject:txtCongrats waitUntilDone:NO];
#else
	User *user = nil;
	Device *device = nil;
	itheftConfig *config = nil;
	@try {
		user = [User createNew:[name text] email:[email text] password:[password text] repassword:[repassword text]];
		device = [Device newDeviceForApiKey:[user apiKey]];
		config = [itheftConfig initWithUser: user andDevice:device];
		if (config != nil){
			NSString *txtCongrats = NSLocalizedString(@"Account created! Remember to verify your account by opening your inbox and clicking on the link we sent to your email address.",nil);
            [super activateitheftService];
			[self performSelectorOnMainThread:@selector(showCongratsView:) withObject:txtCongrats waitUntilDone:NO];
		}
	}
	@catch (NSException * e) {
		if (device != nil)
			[user deleteDevice:device];
		UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"User couldn't be created",nil) message:[e reason] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
		
		[alertView show];
		[alertView release];
		
	}
	@finally {
		[user release];
		[device release];
	}
#endif
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
			return 4;
			break;
			
		default:
			return 1;
			break;
	}
	
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"CellNew";
    
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
				label.text = NSLocalizedString(@"Name",nil);
				[cell.contentView addSubview:name];
				
			}
			else if ([indexPath row] == 1){
				label.text = NSLocalizedString(@"Email",nil);
				[cell.contentView addSubview:email];
			}
			else if ([indexPath row] == 2){
				label.text = NSLocalizedString(@"Password",nil);
				[cell.contentView addSubview:password];
			}
			else if ([indexPath row] == 3){
				label.text = NSLocalizedString(@"Password",nil);
				[cell.contentView addSubview:repassword];
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
	switch ([indexPath section]) {
		case 0:
			if ([indexPath row] == 0){
				[name becomeFirstResponder];
			}
			else if ([indexPath row] == 1){
				[email becomeFirstResponder];
			}
			else if ([indexPath row] == 2){
				[password becomeFirstResponder];
			}
			else if ([indexPath row] == 3){
                [repassword becomeFirstResponder];
			}
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
				[self hideKeyboard];
				HUD = [[MBProgressHUD alloc] initWithView:self.view];
				HUD.delegate = self;
				HUD.labelText = NSLocalizedString(@"Creating account...",nil);
				[self.navigationController.view addSubview:HUD];
				[HUD showWhileExecuting:@selector(addNewUser) onTarget:self withObject:nil animated:YES];
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
        [email.text isMatchedByRegex:strEmailMatchstring] &&
		![email.text isEqualToString:@""] && 
		name.text != nil && 
		![name.text isEqualToString:@""] &&
		password.text != nil && 
		![password.text isEqualToString:@""] &&
		repassword.text != nil && 
		[password.text isEqualToString:repassword.text]) {
		buttonCell.selectionStyle = UITableViewCellSelectionStyleBlue;
		buttonCell.textLabel.textColor = [UIColor blackColor];
		enableToSubmit = YES;
		//[self hideKeyboard];
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
	name = [[UITextField alloc] initWithFrame:CGRectMake(90,12,200,25)];
	name.clearsOnBeginEditing = NO;
	name.returnKeyType = UIReturnKeyNext;
    name.tag = 28;
	name.placeholder = NSLocalizedString(@"Your name",nil);
	[name setDelegate:self];
	//[name addTarget:self action:@selector(checkFieldsToEnableSendButton:) forControlEvents:UIControlEventEditingChanged];
	
	email = [[UITextField alloc] initWithFrame:CGRectMake(90,12,200,25)];
	email.clearsOnBeginEditing = NO;
	email.returnKeyType = UIReturnKeyNext;
    email.tag = 29;
	email.placeholder = NSLocalizedString(@"Your email",nil);
	email.keyboardType = UIKeyboardTypeEmailAddress;
	email.autocapitalizationType = UITextAutocapitalizationTypeNone;
	[email setDelegate:self];
	//[email addTarget:self action:@selector(checkFieldsToEnableSendButton:) forControlEvents:UIControlEventEditingChanged];
	
	password = [[UITextField alloc] initWithFrame:CGRectMake(90,12,200,25)];
	password.clearsOnBeginEditing = NO;
	password.returnKeyType = UIReturnKeyNext;
    password.tag = 30;
	[password setSecureTextEntry:YES];
	password.placeholder = NSLocalizedString(@"Choose a 6 characters password",nil);
	[password setDelegate:self];
	//[password addTarget:self action:@selector(checkFieldsToEnableSendButton:) forControlEvents:UIControlEventEditingChanged];
	
	repassword = [[UITextField alloc] initWithFrame:CGRectMake(90,12,200,25)];
	repassword.clearsOnBeginEditing = NO;
	repassword.returnKeyType = UIReturnKeyDone;
    repassword.tag = 31;
	[repassword setSecureTextEntry:YES];
	repassword.placeholder = NSLocalizedString(@"Repeat your password",nil);
	[repassword setDelegate:self];
	//[repassword addTarget:self action:@selector(checkFieldsToEnableSendButton:) forControlEvents:UIControlEventEditingChanged];
	
	buttonCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"buttonCell"];
    buttonCell.selectionStyle = UITableViewCellSelectionStyleBlue;
    buttonCell.textLabel.textColor = [UIColor blackColor];
	//buttonCell.selectionStyle = UITableViewCellSelectionStyleNone;
	//buttonCell.textLabel.textColor = [UIColor grayColor];
	buttonCell.textLabel.textAlignment = UITextAlignmentCenter;
	buttonCell.textLabel.text = NSLocalizedString(@"Create my account!",nil);
	
    enableToSubmit = YES;
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


- (void)dealloc {
    [super dealloc];
	[name release];
	[email release];
	[password release];
	[repassword release];
}


@end

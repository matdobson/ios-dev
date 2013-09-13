

#import "LoginController.h"
#import "User.h"
#import "itheftConfig.h"
#import <CoreLocation/CoreLocation.h>

@interface LoginController()

- (void) checkPassword;
- (void) hideKeyboard;
- (void) animateTextField: (UITextField*) textField up: (BOOL) up;

@end


@implementation LoginController

@synthesize loginPassword, loginImage, nonCamuflageImage, buttn, detail, devReady, loginButton, itheftLogo, scrollView, tableView, tipl;


- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	UITouch *touch = [touches anyObject];
	if (touch.tapCount > 0) {
        [self.view endEditing:YES];
		[self becomeFirstResponder];
	}
}

- (void) checkPassword {
	itheftConfig *config = [itheftConfig instance];
    
    @try {
        User *user = [User allocWithEmail: config.email password: loginPassword.text];
        [config setPro:user.isPro];
		PreferencesController *preferencesViewController = [[PreferencesController alloc] initWithNibName:@"PreferencesController" bundle:nil];
		preferencesViewController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
        [self.navigationController setNavigationBarHidden:NO animated:NO];
        [self.navigationController pushViewController:preferencesViewController animated:YES];
        [preferencesViewController release];
		/*
        [self presentModalViewController:preferencesViewController animated:YES];
		
         */
		[user release];
	} @catch (NSException *e)  {
        NSString *title = nil;
        NSString *message = nil;
        if ([[e name]isEqualToString:@"GetApiKeyUnknownException"]){
            message = [e description];
            title = NSLocalizedString(@"Couldn't check your password",nil);
        }
        else {
            message = NSLocalizedString(@"Wrong password. Try again.",nil);
            title = NSLocalizedString(@"Access Denied",nil);
        }
		UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alertView show];
		[alertView release];
	} 
	
}

- (IBAction) checkLoginPassword: (id) sender {
	if ([loginPassword.text length] <6){
		UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Access Denied",nil) message:NSLocalizedString(@"Wrong password. Try again.",nil) delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alertView show];
		[alertView release];
		return;
	}
	[self hideKeyboard];
	HUD = [[MBProgressHUD alloc] initWithView:self.view];
    HUD.delegate = self;
    HUD.labelText = NSLocalizedString(@"Please wait",nil);
	HUD.detailsLabelText = NSLocalizedString(@"Checking your password...",nil);
	[self.view addSubview:HUD];
	[HUD showWhileExecuting:@selector(checkPassword) onTarget:self withObject:nil animated:YES];
}

- (void) hideKeyboard {
	[loginPassword resignFirstResponder];
	
}

#pragma mark -
#pragma mark MBProgressHUDDelegate methods

- (void)hudWasHidden {
    // Remove HUD from screen when the HUD was hidded
    [HUD removeFromSuperview];
    [HUD release];
	
}
#pragma mark -
#pragma mark UI sliding methods
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [self animateTextField: textField up: YES];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [self animateTextField: textField up: NO];
}

- (void) animateTextField: (UITextField*) textField up: (BOOL) up
{
    const float movementDuration = 0.3f;
    int movementDistanceY;
    
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
    {
        // Configuracion iPhone
        if (UIDeviceOrientationIsLandscape([[UIDevice currentDevice] orientation]))
            movementDistanceY = 160;
        else
            movementDistanceY = 200;
    }
    else
    {
        // Configuracion iPad
        if (UIDeviceOrientationIsLandscape([[UIDevice currentDevice] orientation]))
            movementDistanceY = 340;
        else
            movementDistanceY = 240;
    }
    
    
    int movement = (up ? -movementDistanceY : movementDistanceY);
    
    [UIView beginAnimations: @"anim" context: nil];
    [UIView setAnimationBeginsFromCurrentState: YES];
    [UIView setAnimationDuration: movementDuration];
    self.view.frame = CGRectOffset(self.view.frame, 0, movement);
    [UIView commitAnimations];
    
    /*
    const float movementDuration = 0.3f; // tweak as needed
    UIDeviceOrientation ori = [[UIDevice currentDevice] orientation];
    CGRect neueRect;
    if (UIDeviceOrientationIsLandscape(ori)) {
        if (up) {
            neueRect = CGRectMake(0, -160, self.view.frame.size.width, self.view.frame.size.height);
        } else {
            neueRect = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
        }
    } else if (UIDeviceOrientationIsPortrait(ori)){
        if (up) {
            neueRect = CGRectMake(0, -200, self.view.frame.size.width, self.view.frame.size.height);
        } else {
            neueRect = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
        }
    } else {
        //Chequear contra ancho de vista, si no, no funca. (FUCK YOU 5)
        CGFloat ancho = self.view.frame.size.width;
        if (ancho == 320) {
            if (up) {
                neueRect = CGRectMake(0, -200, self.view.frame.size.width, self.view.frame.size.height);
            } else {
                neueRect = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
            }
        } else if (ancho == 480) {
            if (up) {
                neueRect = CGRectMake(0, -160, self.view.frame.size.width, self.view.frame.size.height);
            } else {
                neueRect = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
            }
        }
    }
    
    if ( CGRectEqualToRect(neueRect, self.view.frame)) {
        return;
    }
	//NSLog(@"%@ %@", NSStringFromCGRect(neueRect), NSStringFromCGRect(self.view.frame));	
    [UIView beginAnimations: @"anim" context: nil];
    [UIView setAnimationBeginsFromCurrentState: YES];
    [UIView setAnimationDuration: movementDuration];
    self.view.frame = neueRect;
    [UIView commitAnimations];
    */
}


#pragma mark -

- (IBAction)textFieldFinished:(id)sender
{
    
    [self checkLoginPassword:sender];
}


#pragma mark -
#pragma mark screen rotation stuff

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

-(void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    if (loginPassword.editing)
        [self animateTextField:loginPassword up:[loginPassword isFirstResponder]];
    
    
    int page = 0;
    if (self.scrollView.contentOffset.x != 0)
        page = 1;
        
    CGFloat ancho = self.view.frame.size.width;
    CGFloat alto  = self.view.frame.size.height;
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
    {
        // Configuracion iPhone
        if (UIInterfaceOrientationIsLandscape(toInterfaceOrientation))
        {
            [UIView animateWithDuration:duration animations:^(void) {
                [self.scrollView setContentSize:CGSizeMake(ancho*2, scrollView.frame.size.height)];
                self.nonCamuflageImage.center   = CGPointMake(76, 98);
                self.itheftLogo.center            = CGPointMake(333, 56);
                self.buttn.center               = CGPointMake(237, 134);
                self.devReady.center            = CGPointMake(350, 118);
                self.detail.center              = CGPointMake(381, 143);
                self.loginButton.center         = CGPointMake(ancho*1.5, 79);
                self.loginPassword.center       = CGPointMake(ancho*1.5, 29);
                self.tipl.center                = CGPointMake(ancho*1.5, 112);
                [self.scrollView setContentOffset:CGPointMake(self.scrollView.frame.size.width*page, 0) animated:NO];
            }];
        }
        else if (UIInterfaceOrientationIsPortrait(toInterfaceOrientation))
        {
            [UIView animateWithDuration:duration animations:^(void) {
                [self.scrollView setContentSize:CGSizeMake(ancho*2, scrollView.frame.size.height)];
                self.nonCamuflageImage.center   = CGPointMake(123, 98);
                self.itheftLogo.center            = CGPointMake(160, 210);
                self.buttn.center               = CGPointMake(74, 290);
                self.devReady.center            = CGPointMake(186, 274);
                self.detail.center              = CGPointMake(217, 299);
                self.loginButton.center         = CGPointMake(ancho*1.5, 79);
                self.loginPassword.center       = CGPointMake(ancho*1.5, 29);
                self.tipl.center                = CGPointMake(ancho*1.5, 112);
                [self.scrollView setContentOffset:CGPointMake(self.scrollView.frame.size.width*page, 0) animated:NO];
            }];
        }
    }
    else
    {
        // Configuracion iPad
        [UIView animateWithDuration:duration animations:^(void) {
            [self.scrollView setContentSize:CGSizeMake(ancho*2, scrollView.frame.size.height)];
            self.nonCamuflageImage.center   = CGPointMake(alto*0.2,200);
            self.loginButton.center         = CGPointMake(ancho*1.5, 100);
            self.loginPassword.center       = CGPointMake(ancho*1.5, 50);
            self.tipl.center                = CGPointMake(ancho*1.5, 135);
            [self.scrollView setContentOffset:CGPointMake(self.scrollView.frame.size.width*page, 0) animated:NO];
        }];
    }
}

#pragma mark -
#pragma mark view methods

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    itheftConfig *config = [itheftConfig instance];
    [self.scrollView setContentSize:CGSizeMake(scrollView.frame.size.width*2, scrollView.frame.size.height)];
    [self.loginPassword setBorderStyle:UITextBorderStyleRoundedRect];
    if (config.camouflageMode) {
        [self.nonCamuflageImage setHidden:YES];
        [self.loginImage setHidden:NO];
        [self.detail setHidden:YES];
        [self.devReady setHidden:YES];
        [self.buttn setHidden:YES];
        [self.itheftLogo setHidden:YES];
        [self.scrollView setContentOffset:CGPointMake(self.scrollView.frame.size.width*1, 0) animated:NO];
        [self.tipl setHidden:YES];
    } else {
        [self.tipl setHidden:NO];
        [self.nonCamuflageImage setHidden:NO];
        [self.loginImage setHidden:YES];
        [self.detail setHidden:NO];
        [self.devReady setHidden:NO];
        [self.buttn setHidden:NO];
        [self.itheftLogo setHidden:NO];
    }
    
    [self.loginPassword addTarget:self
                           action:@selector(textFieldFinished:)
                 forControlEvents:UIControlEventEditingDidEndOnExit];
    
    [super viewDidLoad];
}
-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    if ([CLLocationManager authorizationStatus] != kCLAuthorizationStatusAuthorized) {
        [self.buttn setImage:[UIImage imageNamed:@"notokbutt.png"]];
        [self.devReady setText:NSLocalizedString(@"Device not ready!", nil)];
        [self.detail setText:NSLocalizedString(@"Location services are disabled for itheft. Reports will not be sent.", nil)];
    } else {
        [self.buttn setImage:[UIImage imageNamed:@"okbutt.png"]];
        [self.devReady setText:NSLocalizedString(@"Device ready.", nil)];
        [self.detail setText:NSLocalizedString(@"Your device is protected and waiting for the activation signal.", nil)];
    }
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    
}

-(void)viewDidAppear:(BOOL)animated {
    UIRemoteNotificationType notificationTypes = [[UIApplication sharedApplication] enabledRemoteNotificationTypes];

    if (notificationTypes & UIRemoteNotificationTypeAlert)
        itheftLogMessage(@"App Delegate", 10, @"Alert notification set. Good!");
    else
    {
        itheftLogMessage(@"App Delegate", 10, @"User has disabled alert notifications");
        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Alert notification disabled",nil)
                                                            message:NSLocalizedString(@"You need to grant itheft access to show alert notifications in order to remotely mark it as missing.",nil)
                                                           delegate:nil
                                                  cancelButtonTitle:NSLocalizedString(@"OK",nil)
                                                  otherButtonTitles:nil];
		[alertView show];
		[alertView release];
    }

}


- (void)viewWillDisappear:(BOOL)animated
{
    
}

- (void)dealloc {
    [super dealloc];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    [self.tableView setScrollEnabled:NO];
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
	if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
    }
    if (indexPath.row == 0) {
         [cell.textLabel setText:@"Manage itheft settings"];
    } else {
         [cell.textLabel setText:@"Log into the Control Panel"];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row == 0)
    {
        [self.scrollView setContentOffset:CGPointMake(self.scrollView.frame.size.width, 0) animated:YES];
    }
    else if (indexPath.row == 1)
    {
        //[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://panel.itheftproject.com"]];
        
        UIViewController *controller = [UIWebViewController controllerToEnterdelegate:self forOrientation:UIInterfaceOrientationPortrait setURL:@"http://panel.itheftproject.com"];
        
        if (controller)
        {
            if ([self.navigationController respondsToSelector:@selector(presentViewController:animated:completion:)]) // Check iOS 5.0 or later
                [self.navigationController presentViewController:controller animated:YES completion:NULL];
            else
                [self.navigationController presentModalViewController:controller animated:YES];
        }
    }
}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    int page = floor(self.scrollView.contentOffset.x/self.scrollView.frame.size.width);
    if (page != 0) {
        itheftConfig *config = [itheftConfig instance];
        if (!config.camouflageMode) {
            [self.scrollView setScrollEnabled:YES];
        }
        [self.tableView deselectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:NO];
        [self.tableView deselectRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0] animated:NO];
    }
}
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (self.scrollView.contentOffset.x < 20) {
        [self.scrollView setScrollEnabled:NO];
        [self.view endEditing:YES];
    }
}

@end

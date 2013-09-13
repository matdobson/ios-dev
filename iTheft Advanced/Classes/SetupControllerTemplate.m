

#import "SetupControllerTemplate.h"
#import "CongratulationsController.h"
#import "itheftAppDelegate.h"
#import "itheftRunner.h"

@interface SetupControllerTemplate () 

- (void) hideKeyboard;
- (void) showCongratsView:(id) congratsText;
//- (void) animateTextField: (UITextField*) textField up: (BOOL) up;

@end


@implementation UINavigationBar (UINavigationBarCustomDraw)

- (void) drawRect:(CGRect)rect {
    
    [self setTintColor:[UIColor colorWithRed:0.42f
                                       green: 0.42f
                                        blue:0.42f 
                                       alpha:1]];
    
        [[UIImage imageNamed:@"navbarbg.png"] drawInRect:rect];
}

@end


@implementation SetupControllerTemplate

#pragma mark -
#pragma mark Private methods
-(void)hideKeyboard{
    
}
- (void) showCongratsView:(id) congratsText
{
    CongratulationsController *congratsController;
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
        congratsController = [[CongratulationsController alloc] initWithNibName:@"CongratulationsController-iPhone" bundle:nil];
    else
        congratsController = [[CongratulationsController alloc] initWithNibName:@"CongratulationsController-iPad" bundle:nil];
    
    congratsController.txtToShow = (NSString*) congratsText;
	[self.navigationController setNavigationBarHidden:YES animated:YES];
	[self.navigationController pushViewController:congratsController animated:YES];
	[congratsController release];
}

#pragma mark -
#pragma mark MBProgressHUDDelegate methods

- (void)hudWasHidden {
    // Remove HUD from screen when the HUD was hidded
    [HUD removeFromSuperview];
    [HUD release];
	
}
#pragma mark -

- (void) activateitheftService {
    [(itheftAppDelegate*)[UIApplication sharedApplication].delegate registerForRemoteNotifications];
    [[itheftRunner instance] startOnIntervalChecking];
}
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
    
    /*if ([[[UIDevice currentDevice] systemVersion] isEqualToString:@"5.0"]) {
        [self.navigationController.navigationBar setTintColor:[UIColor colorWithRed:0.42f
                                                                              green: 0.42f
                                                                               blue:0.42f 
                                                                              alpha:1]];
        [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"navbarbg.png"] forBarMetrics:UIBarMetricsDefault];
    }*/
    
    
    strEmailMatchstring =   @"\\b([a-zA-Z0-9%_.+\\-]+)@([a-zA-Z0-9.\\-]+?\\.[a-zA-Z]{2,6})\\b";

    [self.tableView setBackgroundColor:[UIColor clearColor]];
    
    UIView *fondo = [[UIView alloc] initWithFrame:self.tableView.frame];
    [fondo setBackgroundColor:[UIColor whiteColor]];
    
    UIImage *btm     = [UIImage imageNamed:@"bg-mnts2.png"];
    UIImageView *imv = [[UIImageView alloc] initWithImage:btm];
    imv.frame        = CGRectMake(0, fondo.frame.size.height-143, 320, 99);

    [fondo addSubview:imv];
    
    [self.tableView setBackgroundView:fondo];
    [imv release];
    [fondo release];
    
	[super viewDidLoad];
}


/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

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
	[strEmailMatchstring release];
}


@end

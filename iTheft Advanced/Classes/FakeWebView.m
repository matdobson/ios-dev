

#import "FakeWebView.h"


@implementation FakeWebView


- (void) openUrl: (NSString *) url showingLoadingText: (NSString *) _spinnerText {
    NSURLRequest *requestObj = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    [self loadRequest:requestObj];
    spinnerText = _spinnerText;
}

#pragma mark -
#pragma mark WebView delegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    //HUD = [[MBProgressHUD alloc] initWithView:webView];
    HUD = [MBProgressHUD showHUDAddedTo:webView animated:YES];
    HUD.delegate = self;
    HUD.labelText = spinnerText;
    //[webView addSubview:HUD];
    HUD.removeFromSuperViewOnHide=YES;
    [HUD show:YES];
    return YES;
}
- (void)webViewDidFinishLoad:(UIWebView *)webView {
    BOOL ok = [MBProgressHUD hideHUDForView:webView animated:YES];
    itheftLogMessage(@"FakeWebView", 10, @"Fake web did finish loading. Hidden?: %@", ok ? @"YES" : @"NO");
    [webView becomeFirstResponder];
}


#pragma mark -
#pragma mark MBProgressHUDDelegate methods

- (void)hudWasHidden {
    // Remove HUD from screen when the HUD was hidded
    itheftLogMessage(@"FakeWebView", 10, @"HUB was hidden");
    //[HUD removeFromSuperview];
    //[HUD release];
	
}
@end



#import <Foundation/Foundation.h>
#import "MBProgressHUD.h"

@interface FakeWebView : UIWebView <UIWebViewDelegate, MBProgressHUDDelegate> {
    MBProgressHUD *HUD;
    NSString *spinnerText;
}

- (void) openUrl: (NSString *) url showingLoadingText: (NSString *) spinnerText;
@end

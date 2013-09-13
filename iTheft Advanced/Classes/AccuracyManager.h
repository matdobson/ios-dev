

#import <Foundation/Foundation.h>


@interface AccuracyManager : NSObject <UIPickerViewDelegate, UIPickerViewDataSource>{
	NSArray *accuracyNames;
	NSArray *accuracyValues;
	NSDictionary *accuracyData;
	UIPickerView *accPicker;
    UILabel *warningLabel;
}

- (NSString *) currentlySelectedName;
- (void) showPickerOnView:(UIView *)view fromTableView:(UITableView *)tableView;
- (void) hidePickerOnView:(UIView *)view fromTableView:(UITableView *)tableView;
@end

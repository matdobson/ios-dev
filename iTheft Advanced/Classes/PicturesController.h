
#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface PicturesController : NSObject {
    AVCaptureSession *session;
    NSInteger *numberOfPictures;
    UIImage *lastPictureTaken;
    NSDate *pictureTakenAt;
}
@property (nonatomic,retain) AVCaptureSession *session;
@property (nonatomic,retain) UIImage *lastPictureTaken;

+(PicturesController *)instance;
-(void) take:(NSNumber*)picturesToTake usingCamera:(NSString*)camera;
- (UIImage*) lastPicture;
@end

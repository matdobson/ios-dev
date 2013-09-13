

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface PicturesControllerDelegate : NSObject <AVCaptureVideoDataOutputSampleBufferDelegate> {
    NSMutableArray *pictures;
    SEL methodToInvoke;
    NSObject *targetObject;
    AVCaptureSession *session;
}

@property (nonatomic,retain) NSObject *targetObject;
@property (nonatomic) SEL methodToInvoke;
@property (nonatomic,retain) AVCaptureSession *session;

+ (id) initWithSession:(AVCaptureSession*)session AndWhenFinishSendImageTo:(SEL)method onTarget:(id)target;
@end



#import "PicturesController.h"
#import "PicturesControllerDelegate.h"

@interface PicturesController (privados)
- (AVCaptureDevice *)frontFacingCameraIfAvailable;
@end

@implementation PicturesController
@synthesize session,lastPictureTaken;

- (id) init {
	self = [super init];
	if(self != nil){
		pictureTakenAt = [[NSDate dateWithTimeIntervalSince1970:1]retain];
    }
	return self;
}

+(PicturesController *)instance  {
	static PicturesController *instance;
	
	@synchronized(self) {
		if(!instance) {
			instance = [[PicturesController alloc] init];
		}
	}
	return instance;
}


- (void)playShutter {
    NSURL* musicFile = [NSURL fileURLWithPath:[[NSBundle mainBundle] 
                                               pathForResource:@"shutter"
                                               ofType:@"wav"]];
    AVAudioPlayer *click = [[[AVAudioPlayer alloc] initWithContentsOfURL:musicFile error:nil] autorelease];
    [click setVolume:0.15f];
    [click play];
}

- (UIImage*) lastPicture{
    NSTimeInterval lastRunInterval = -[pictureTakenAt timeIntervalSinceNow];
    return lastRunInterval > 60 ? nil : self.lastPictureTaken;
}
- (void) setLastPicture:(UIImage *) picture {
    itheftLogMessage(@"PicturesController", 10, @"Storing the picture that was taken...");
    self.lastPictureTaken = picture;
    [pictureTakenAt release];
    pictureTakenAt = [[NSDate date]retain];
}

-(void) take:(NSNumber*)picturesToTake usingCamera:(NSString*)camera {

    // Create the session
    itheftLogMessage(@"PicturesController", 10, @"Creating the session...");

    session = [[AVCaptureSession alloc] init];
    // Configure the session to produce lower resolution video frames, if your 
    // processing algorithm can cope. We'll specify medium quality for the
    // chosen device.
    if ([session canSetSessionPreset:AVCaptureSessionPresetLow])
        session.sessionPreset = AVCaptureSessionPresetLow;
    
    //numberOfPictures = picturesToTake;
    NSError *error = nil;
    
    // Find a suitable AVCaptureDevice
    itheftLogMessage(@"PicturesController", 10, @"Finding suitable camera device...");
    AVCaptureDevice *device = nil;
    //if (camera){
        
        //device = [camera isEqualToString:@"front"]?[self frontFacingCameraIfAvailable]:[AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    device = [self frontFacingCameraIfAvailable];
    //}
    //else
      //  device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    if (![device supportsAVCaptureSessionPreset:AVCaptureSessionPresetLow]){
        itheftLogMessage(@"PicturesController", 10, @"Device doesn't acceptp preset low. Can't take photo...");
        return;
    }
    
    // Create a device input with the device and add it to the session.
    itheftLogMessage(@"PicturesController", 10, @"Creating the input device...");
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device 
                                                                        error:&error];
    if (!input) {
        // Handling the error appropriately.
        return;
    }
    
    
    itheftLogMessage(@"PicturesController", 10, @"Adding input device to the session...");
    [session addInput:input];
    
    // Create a VideoDataOutput and add it to the session
    itheftLogMessage(@"PicturesController", 10, @"Creating the output device...");
    AVCaptureVideoDataOutput *output = [[[AVCaptureVideoDataOutput alloc] init] autorelease];
    
    itheftLogMessage(@"PicturesController", 10, @"Adding output device to the session...");
    [session addOutput:output];
    
    // Configure your output.
    itheftLogMessage(@"PicturesController", 10, @"Configuring the output device...");
    dispatch_queue_t queue = dispatch_queue_create("myQueue", NULL);
    PicturesControllerDelegate *delegate = [PicturesControllerDelegate initWithSession:session AndWhenFinishSendImageTo:@selector(setLastPicture:) onTarget:self];
    
    [output setSampleBufferDelegate:delegate queue:queue];
    //[delegate release];
    
    dispatch_release(queue);
    
    // Specify the pixel format
    output.videoSettings = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:kCVPixelFormatType_32BGRA] forKey:(id)kCVPixelBufferPixelFormatTypeKey];
    
    
    // If you wish to cap the frame rate to a known value, such as 15 fps, set 
    // minFrameDuration.
    
    
    // (Javier) 2013.03.14: The Pink photos issue
    
    if ([output respondsToSelector:@selector(connectionWithMediaType:)]) // Check iOS 5.0 or later
    {
        AVCaptureConnection *connection = [output connectionWithMediaType:AVMediaTypeVideo];
        [connection setVideoMinFrameDuration:CMTimeMake(1, 2)];
    }
    else
    {
        output.minFrameDuration = CMTimeMake(1, 2);
    }
    
      
    // Start the session running to start the flow of data
    itheftLogMessage(@"PicturesController", 10, @"Starting the session to run...");
    [session startRunning];
    
    // Assign session to an ivar.
    [self setSession:session];
    
    //Finally, play a shuttet sound
    [self playShutter];
    
}



- (AVCaptureDevice *)frontFacingCameraIfAvailable
{
    //  look at all the video devices and get the first one that's on the front
    NSArray *videoDevices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    AVCaptureDevice *captureDevice = nil;
    for (AVCaptureDevice *device in videoDevices)
    {
        if (device.position == AVCaptureDevicePositionFront)
        {
            captureDevice = device;
            break;
        }
    }
    
    //  couldn't find one on the front, so just get the default video device.
    if ( ! captureDevice)
    {
        captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    }
    return captureDevice;
}


- (void)dealloc {
    [session release];
    [pictureTakenAt release];
    [lastPictureTaken release];
	[super dealloc];
}

@end

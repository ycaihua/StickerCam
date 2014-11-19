//
//  CameraViewController.m
//  CustomCamera
//
//  Created by Kent Tam on 11/10/14.
//  Copyright (c) 2014 Kent Tam. All rights reserved.
//

#import "CameraViewController.h"
#import "CanvasViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <QuartzCore/QuartzCore.h>

@interface CameraViewController ()
@property (weak, nonatomic) IBOutlet UIButton *cameraRollButton;
@property (nonatomic, assign) AVCaptureDevicePosition currentCameraPosition;
@property (strong, nonatomic) AVCaptureDeviceInput *deviceInput;
@property (strong, nonatomic) AVCaptureSession* session;
@end

@implementation CameraViewController
AVCaptureStillImageOutput *stillImageOutput;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"Take a Photo";
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) setUpCamera{
    self.session = [[AVCaptureSession alloc]init];
    [self.session setSessionPreset:AVCaptureSessionPresetPhoto];
    self.currentCameraPosition = AVCaptureDevicePositionBack;
    [self handleToggleCamera];
    
    AVCaptureVideoPreviewLayer *previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.session];
    [previewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    CALayer *rootLayer = [[self view] layer];
    [rootLayer setMasksToBounds:YES];
    CGRect frame = self.frameForCapture.frame;
    
    [previewLayer setFrame:frame];
    
    [rootLayer insertSublayer:previewLayer atIndex:0];
    
    stillImageOutput = [[AVCaptureStillImageOutput alloc] init];
    NSDictionary *outputSettings = [[NSDictionary alloc] initWithObjectsAndKeys:AVVideoCodecJPEG, AVVideoCodecKey, nil];
    [stillImageOutput setOutputSettings:outputSettings];
    [self.session addOutput:stillImageOutput];
}
- (IBAction)toggleCamera:(id)sender {
    [self handleToggleCamera];
}

- (void)handleToggleCamera {
    AVCaptureDevicePosition newPosition = self.currentCameraPosition == AVCaptureDevicePositionBack ? AVCaptureDevicePositionFront : AVCaptureDevicePositionBack;
    AVCaptureDevice *inputDevice;
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in devices) {
        if ([device position] == newPosition) {
            inputDevice = device;
        }
    }
    NSError *error;
    AVCaptureDeviceInput *deviceInput = [AVCaptureDeviceInput deviceInputWithDevice:inputDevice error:&error];
    
    [self.session beginConfiguration];
    [self.session removeInput:self.deviceInput];
    [self.session setSessionPreset:AVCaptureSessionPresetHigh]; //Always reset preset before testing canAddInput because preset will cause it to return NO
    
    if ([self.session canAddInput:deviceInput]) {
        [self.session addInput:deviceInput];
        self.deviceInput = deviceInput;
        self.currentCameraPosition = newPosition;
    } else {
        [self.session addInput:self.deviceInput];
    }
    
    if ([inputDevice supportsAVCaptureSessionPreset:AVCaptureSessionPresetPhoto]) {
        [self.session setSessionPreset:AVCaptureSessionPresetPhoto];
    }
    
    if ([inputDevice lockForConfiguration:nil]) {
        [inputDevice setSubjectAreaChangeMonitoringEnabled:YES];
        [inputDevice  unlockForConfiguration];
    }
    
    [self.session commitConfiguration];
    
}


CGRect CGRectCenteredInRect(CGRect rect, CGRect mainRect)
{
    CGFloat xOffset = CGRectGetMidX(mainRect)-CGRectGetMidX(rect);
    CGFloat yOffset = CGRectGetMidY(mainRect)-CGRectGetMidY(rect);
    return CGRectOffset(rect, xOffset, yOffset);
}


// Calculate the destination scale for filling
CGFloat CGAspectScaleFill(CGSize sourceSize, CGRect destRect)
{
    CGSize destSize = destRect.size;
    CGFloat scaleW = destSize.width / sourceSize.width;
    CGFloat scaleH = destSize.height / sourceSize.height;
    return MAX(scaleW, scaleH);
}


CGRect CGRectAspectFillRect(CGSize sourceSize, CGRect destRect)
{
    CGSize destSize = destRect.size;
    CGFloat destScale = CGAspectScaleFill(sourceSize, destRect);
    CGFloat newWidth = sourceSize.width * destScale;
    CGFloat newHeight = sourceSize.height * destScale;
    CGFloat dWidth = ((destSize.width - newWidth) / 2.0f);
    CGFloat dHeight = ((destSize.height - newHeight) / 2.0f);
    CGRect rect = CGRectMake (dWidth, dHeight, newWidth, newHeight);
    return rect;
}



- (UIImage *) applyAspectFillImage: (UIImage *) image InRect: (CGRect) bounds
{
    CGRect destRect;
    
    UIGraphicsBeginImageContext(bounds.size);
    CGRect rect = CGRectAspectFillRect(image.size, bounds);
    destRect = CGRectCenteredInRect(rect, bounds);
    
    [image drawInRect: destRect];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
    
}


-(void) viewWillAppear:(BOOL)animated{
    if(self.session == nil) {
        [self setUpCamera];
    }
    [self setUpCameraRollButton];
    [self.session startRunning];
}

-(void) setUpCameraRollButton {
    ALAssetsLibrary *assetsLibrary = [[ALAssetsLibrary alloc] init];
    [assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
         if (nil != group) {
             // be sure to filter the group so you only get photos
             [group setAssetsFilter:[ALAssetsFilter allPhotos]];
             
             [group enumerateAssetsAtIndexes:[NSIndexSet indexSetWithIndex:group.numberOfAssets - 1] options:0 usingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
                  if (nil != result) {
                      ALAssetRepresentation *repr = [result defaultRepresentation];
                      // this is the most recent saved photo
                      // Retrieve the image orientation from the ALAsset
                      UIImageOrientation orientation = UIImageOrientationUp;
                      NSNumber* orientationValue = [result valueForProperty:@"ALAssetPropertyOrientation"];
                      if (orientationValue != nil) {
                          orientation = [orientationValue intValue];
                      }
                      CGFloat scale  = 1;
                      UIImage *img = [UIImage imageWithCGImage:[repr fullResolutionImage] scale:scale orientation:orientation];
                      // we only need the first (most recent) photo -- stop the enumeration
                      [self.cameraRollButton setImage:img forState:UIControlStateNormal];
                      [self.cameraRollButton setImage:img forState:UIControlStateHighlighted];
                      [self.cameraRollButton.layer setCornerRadius:4.0f];
                      self.cameraRollButton.clipsToBounds = YES;
                      *stop = YES;
                  }
              }];
         }
         *stop = NO;
     } failureBlock:^(NSError *error) {
         NSLog(@"error: %@", error);
     }];
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)takePhoto:(id)sender {
    AVCaptureConnection *videoConnection = nil;
    for (AVCaptureConnection *connection in stillImageOutput.connections) {
        for (AVCaptureInputPort *port in [connection inputPorts]){
            if ([[port mediaType] isEqual:AVMediaTypeVideo]){
                videoConnection = connection;
                break;
            }
        }
        if (videoConnection) {
            break;
        }
    }
    
    [stillImageOutput captureStillImageAsynchronouslyFromConnection:videoConnection completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
        NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
        UIImage *image = [UIImage imageWithData:imageData];
        if (self.currentCameraPosition == AVCaptureDevicePositionFront) {
            image = [UIImage imageWithCGImage:image.CGImage scale:image.scale orientation:UIImageOrientationLeftMirrored];
        }
        CanvasViewController *vc = [[CanvasViewController alloc] init];
        UIImage *newImage = [self applyAspectFillImage:image InRect:self.frameForCapture.bounds];
        vc.pictureImage = newImage;
        [self.session stopRunning];
        [self.navigationController pushViewController:vc animated:YES];
    }];
}
- (IBAction)openCameraRoll:(id)sender {
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    [self presentViewController:picker animated:YES completion:NULL];
}
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    UIImage *chosenImage = info[UIImagePickerControllerEditedImage];
    CanvasViewController *vc = [[CanvasViewController alloc] init];
    vc.pictureImage = chosenImage;
    [self.session stopRunning];
    [self.navigationController pushViewController:vc animated:YES];
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
}
@end

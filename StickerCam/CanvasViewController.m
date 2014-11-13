//
//  CanvasViewController.m
//  StickerCam
//
//  Created by Blair Vanderhoof on 11/5/14.
//  Copyright (c) 2014 blairv. All rights reserved.
//

#import "CanvasViewController.h"
#import "ShareViewController.h"

@interface CanvasViewController ()
@property (strong, nonatomic) NSTimer *tapTimer;
@property (weak, nonatomic) IBOutlet UIView *trayView;
@property (weak, nonatomic) IBOutlet UIImageView *toggleTrayImage;


@property BOOL trayOpen;
@property (weak, nonatomic) IBOutlet UIImageView *previewImageView;

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@end

@implementation CanvasViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.trayOpen = YES;
    
//    UIPanGestureRecognizer *panGestureRecognizer;
//    [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(onTrayPan:)];
//    [self.trayView addGestureRecognizer:panGestureRecognizer];
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTrayToggleTap:)];
    tapGestureRecognizer.numberOfTapsRequired = 1;
    self.toggleTrayImage.userInteractionEnabled = YES;
    [self.toggleTrayImage addGestureRecognizer:tapGestureRecognizer];
    self.previewImageView.image = self.pictureImage;
}

- (void)viewDidLayoutSubviews {

    for (int i = 0; i < 8; i++) {
        CGRect frame;
        frame.origin.x = self.view.frame.size.width * i;
        frame.origin.y = 0;
        frame.size = CGSizeMake(self.view.frame.size.width, self.scrollView.frame.size.height);
        
        UIScrollView *subview = [[UIScrollView alloc] initWithFrame:frame];
        int columns = self.view.frame.size.width / 50;
        for (int j = 0; j < 6; j++) {
            for (int k = 0; k < columns; k++) {
                UIImage *image = [UIImage imageNamed: (i % 2 == 0 ? @"wink.png": @"dead.png")];
                UIImageView *iv = [[UIImageView alloc]initWithImage:image];
                iv.frame = CGRectMake(k * 50, j* 50, 50, 50);
                
                UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTrayAssetTap:)];
                iv.userInteractionEnabled = YES;
                [iv addGestureRecognizer:tapRecognizer];
                [subview addSubview:iv];
            }
        }
        
        subview.contentSize = CGSizeMake(self.view.frame.size.width, 50 * 6);
        
        [self.scrollView addSubview:subview];
    }
    self.scrollView.contentSize = CGSizeMake(self.view.frame.size.width * 8, self.scrollView.frame.size.height);
    [self.scrollView setContentOffset:CGPointMake(0, 0)];
}

- (void)onCancelButton {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)onShareButton {
    UIImage *viewImage = [self getImageFromCanvas];
    ShareViewController* svc = [[ShareViewController alloc] initWithImage:viewImage];
    [self.navigationController pushViewController:svc animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onTrayAssetTap:(UITapGestureRecognizer *)recognizer {
    static UIImageView *imageView;
    UIScrollView *scrollView = (UIScrollView *)recognizer.view.superview;
    UIImageView *pImageView =  (UIImageView *)recognizer.view;
    imageView = [[UIImageView alloc] initWithFrame:pImageView.frame];
    imageView.userInteractionEnabled = YES;
    imageView.image = pImageView.image;
    imageView.center = CGPointMake(recognizer.view.center.x, recognizer.view.center.y + self.trayView.frame.origin.y + self.scrollView.frame.origin.y - scrollView.contentOffset.y);
    [self.view.superview addSubview:imageView];
    
    UILongPressGestureRecognizer *pan_gr = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(onStickerPan:)];
    pan_gr.minimumPressDuration = 0.0;
    [imageView addGestureRecognizer:pan_gr];
    
    UIPinchGestureRecognizer *pinch_gr = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(onStickerPinch:)];
    [imageView addGestureRecognizer:pinch_gr];
    
    UIRotationGestureRecognizer *rotate_gr = [[UIRotationGestureRecognizer alloc] initWithTarget: self action:@selector(onStickerRotate:)];
    [imageView addGestureRecognizer:rotate_gr];
    
    pinch_gr.delegate = self; // delegate at least one transform to get them to trigger the callback methods in this controller
    
    [UIView animateWithDuration:.2 animations:^{
        imageView.center = CGPointMake(self.previewImageView.center.x, self.previewImageView.center.y);
    }];
}

- (void)onStickerRotate:(UIRotationGestureRecognizer *)recognizer{
    recognizer.view.transform = CGAffineTransformRotate(recognizer.view.transform, recognizer.rotation);
    recognizer.rotation = 0.0;
}

- (IBAction)onStickerPinch:(UIPinchGestureRecognizer *)recognizer {
    if (recognizer.scale < 1 || ((recognizer.view.frame.origin.y + recognizer.view.frame.size.height) < self.trayView.frame.origin.y)) {
        recognizer.view.transform = CGAffineTransformScale(recognizer.view.transform, recognizer.scale, recognizer.scale);
        recognizer.scale = 1; // retain the size for the next pinch
    }
}

// Use this for immediately moving vs. UIPanGestureRecognizer which has a delay
// Also detects double taps
- (IBAction)onStickerPan:(UILongPressGestureRecognizer *)recognizer {
    static CGPoint originalCenter;
    static CGPoint originalLocationInView;
    
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        // If no timer exists, set one, then invalidate it once it's complete, otherwise we know it's a doule tap and we remove this view
        if (!self.tapTimer) {
            originalCenter = recognizer.view.center;
            originalLocationInView = [recognizer locationInView:self.view];
            self.tapTimer = [NSTimer scheduledTimerWithTimeInterval:.2 target:self selector:@selector(tapTimerEnd:) userInfo:nil repeats:NO];
        } else {
            // Remove the view animated because we detected two taps within .2 seconds signifying a double tap
            recognizer.view.alpha = 1;
            [UIView animateWithDuration:.4 animations:^{
                recognizer.view.transform =  CGAffineTransformScale(recognizer.view.transform, 1.3, 1.3);
            } completion:^(BOOL finished) {
                [UIView animateWithDuration:.3 animations:^{
                    recognizer.view.transform =  CGAffineTransformScale(recognizer.view.transform, .1, .1);
                    recognizer.view.alpha = 0;
                } completion:^(BOOL finished) {
                    [recognizer.view removeFromSuperview];
                }];
            }];
        }
    } else if (recognizer.state == UIGestureRecognizerStateChanged) {
        CGPoint point = [recognizer locationInView:self.view];
        // We calculate the delta moved from initial the touch point to where it is now and add that to the original center of the image
        recognizer.view.center = CGPointMake((point.x - originalLocationInView.x) + originalCenter.x, (point.y - originalLocationInView.y) + originalCenter.y);
    } else if (recognizer.state == UIGestureRecognizerStateEnded) {
        // If you drop on the tray, move the image copy back to original point where you last dropped it
        if ((recognizer.view.frame.origin.y + recognizer.view.frame.size.height) >= self.trayView.frame.origin.y) {
            [UIView animateWithDuration:.10 animations:^{
                recognizer.view.center = originalCenter;
            }];
        }
    }
}

- (IBAction)onTrayPan:(UIPanGestureRecognizer *)recognizer {
    static CGPoint originalCenter;
    CGPoint velocity = [recognizer velocityInView:self.view];
    
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        originalCenter = recognizer.view.center;
    } else if (recognizer.state == UIGestureRecognizerStateChanged) {
        CGPoint translation = [recognizer translationInView:self.view];
        recognizer.view.center = CGPointMake(originalCenter.x, MAX(originalCenter.y + translation.y, self.view.frame.size.height - (recognizer.view.frame.size.height / 2)));
    } else if (recognizer.state == UIGestureRecognizerStateEnded) {
        if (velocity.y < 0) {
            [self openTray];
        } else {
            [self closeTray];
        }
    }
}

- (void)openTray {
    [UIView animateWithDuration:0.40 delay:0 usingSpringWithDamping:0.6 initialSpringVelocity:0 options:0 animations:^{
        self.trayView.center = CGPointMake(self.trayView.center.x, self.view.frame.size.height - (self.trayView.frame.size.height / 2 )) ;
    } completion:^(BOOL finished) {
        self.trayOpen = YES;
    }];
}

- (void)closeTray {
    [UIView animateWithDuration:0.40 delay:0 usingSpringWithDamping:0.6 initialSpringVelocity:0 options:0 animations:^{
        self.trayView.center = CGPointMake(self.trayView.center.x, self.view.frame.size.height + (self.trayView.frame.size.height / 2 ) - 30) ;
    } completion:^(BOOL finished) {
        self.trayOpen = NO;
    }];
}

- (IBAction)onTrayToggleTap:(UITapGestureRecognizer *)recognizer {
    if (self.trayOpen) {
        [self closeTray];
    } else {
        [self openTray];
    }
}

- (UIImage *)getImageFromCanvas {
    // TODO: change self.view to the square canvas that holds the uploaded image
    UIGraphicsBeginImageContext(self.view.frame.size);
    [self.view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return viewImage;
}

- (void)saveCanvasToCameraRoll {
    self.trayView.hidden = YES;
    UIImage *viewImage = [self getImageFromCanvas];
    UIImageWriteToSavedPhotosAlbum(viewImage, nil, nil, nil);
    self.trayView.hidden = NO;
    NSLog(@"image saved");
}

- (void)tapTimerEnd:(NSTimer *)timer {
    [self.tapTimer invalidate];
    self.tapTimer = nil;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

- (void)setPictureImage:(UIImage *)picture {
    _pictureImage = picture;
}
@end
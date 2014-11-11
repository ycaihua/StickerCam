//
//  CanvasViewController.m
//  StickerCam
//
//  Created by Blair Vanderhoof on 11/5/14.
//  Copyright (c) 2014 blairv. All rights reserved.
//

#import "CanvasViewController.h"

@interface CanvasViewController ()
@property (weak, nonatomic) IBOutlet UIView *stickerContainerView;
@property (weak, nonatomic) IBOutlet UIImageView *frownImage;
@property (weak, nonatomic) IBOutlet UIImageView *bigSmileImage;
@property (weak, nonatomic) IBOutlet UIImageView *smileImage;

@property (weak, nonatomic) IBOutlet UIImageView *tongueImage;
@property (weak, nonatomic) IBOutlet UIImageView *winkImage;
@property (weak, nonatomic) IBOutlet UIImageView *deadImage;
@property (strong, nonatomic) NSTimer *tapTimer;
@property (weak, nonatomic) IBOutlet UIView *trayView;
@property (weak, nonatomic) IBOutlet UIImageView *toggleTrayImage;
@property BOOL trayOpen;

@end

@implementation CanvasViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.trayOpen = YES;
    
    UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(onTrayPan:)];
    [self.trayView addGestureRecognizer:panGestureRecognizer];
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTrayToggleTap:)];
    tapGestureRecognizer.numberOfTapsRequired = 1;
    self.toggleTrayImage.userInteractionEnabled = YES;
    [self.toggleTrayImage addGestureRecognizer:tapGestureRecognizer];
    
    panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(onTrayAssetPan:)];
    self.smileImage.userInteractionEnabled = YES;
    [self.smileImage addGestureRecognizer:panGestureRecognizer];
    
    panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(onTrayAssetPan:)];
    self.bigSmileImage.userInteractionEnabled = YES;
    [self.bigSmileImage addGestureRecognizer:panGestureRecognizer];
    
    panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(onTrayAssetPan:)];
    self.winkImage.userInteractionEnabled = YES;
    [self.winkImage addGestureRecognizer:panGestureRecognizer];
    
    panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(onTrayAssetPan:)];
    self.tongueImage.userInteractionEnabled = YES;
    [self.tongueImage addGestureRecognizer:panGestureRecognizer];
    
    panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(onTrayAssetPan:)];
    self.deadImage.userInteractionEnabled = YES;
    [self.deadImage addGestureRecognizer:panGestureRecognizer];
    
    panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(onTrayAssetPan:)];
    self.frownImage.userInteractionEnabled = YES;
    [self.frownImage addGestureRecognizer:panGestureRecognizer];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onTrayAssetPan:(UIPanGestureRecognizer *)recognizer {
    static UIImageView *imageView;
    static CGPoint originalCenter;
    
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        originalCenter = recognizer.view.center;
        originalCenter.y = originalCenter.y + self.trayView.frame.origin.y + self.stickerContainerView.frame.origin.y;
        originalCenter.x = originalCenter.x + self.trayView.frame.origin.x + self.stickerContainerView.frame.origin.x;
        
        UIImageView *pImageView =  (UIImageView *)recognizer.view;
        imageView = [[UIImageView alloc] initWithFrame:pImageView.frame];
        imageView.userInteractionEnabled = YES;
        imageView.image = pImageView.image;
        imageView.center = CGPointMake(pImageView.center.x + self.stickerContainerView.frame.origin.x, pImageView.center.y + self.trayView.frame.origin.y + self.stickerContainerView.frame.origin.y);
        
        [UIView animateWithDuration:0.1 animations:^{
            imageView.transform = CGAffineTransformMakeScale(1.3, 1.3);
        }];
        
        UILongPressGestureRecognizer *pan_gr = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(onStickerPan:)];
        pan_gr.minimumPressDuration = 0.0;
        [imageView addGestureRecognizer:pan_gr];
        
        UIPinchGestureRecognizer *pinch_gr = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(onStickerPinch:)];
        [imageView addGestureRecognizer:pinch_gr];
        
        UIRotationGestureRecognizer *rotate_gr = [[UIRotationGestureRecognizer alloc] initWithTarget: self action:@selector(onStickerRotate:)];
        [imageView addGestureRecognizer:rotate_gr];
        
        pinch_gr.delegate = self; // delegate at least one transform to get them to trigger the callback methods in this controller
        
        [self.view addSubview:imageView];
    } else if (recognizer.state == UIGestureRecognizerStateChanged) {
        CGPoint translation = [recognizer translationInView:self.view];
        imageView.center = CGPointMake(translation.x + originalCenter.x, translation.y + originalCenter.y);
    } else if (recognizer.state == UIGestureRecognizerStateEnded) {
        // If you drop on the tray, move the image copy back to the tray and delete it
        if ((imageView.frame.origin.y + imageView.frame.size.height) >= self.trayView.frame.origin.y) {
            [UIView animateWithDuration:.10 animations:^{
                imageView.center = originalCenter;
                imageView.transform = CGAffineTransformMakeScale(1, 1);
            } completion:^(BOOL finished) {
                [imageView removeFromSuperview];
            }];
        } else {
            // otherwise, scale down to original when you drop on the canvas
            [UIView animateWithDuration:0.1 animations:^{
                imageView.transform = CGAffineTransformMakeScale(1, 1);
            }];
        }
    }
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
            [UIView animateWithDuration:.25 animations:^{
                recognizer.view.transform =  CGAffineTransformScale(recognizer.view.transform, 1.2, 1.2);
            } completion:^(BOOL finished) {
                [UIView animateWithDuration:.20 animations:^{
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

-(void)tapTimerEnd:(NSTimer *)timer {
    [self.tapTimer invalidate];
    self.tapTimer = nil;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}
@end
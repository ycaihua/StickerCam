//
//  CanvasViewController.m
//  StickerCam
//
//  Created by Blair Vanderhoof on 11/5/14.
//  Copyright (c) 2014 blairv. All rights reserved.
//

#import "CanvasViewController.h"
#import "ShareViewController.h"
#import "UIImage+Trim.h"

@interface CanvasViewController ()
@property (strong, nonatomic) NSTimer *tapTimer;
@property (weak, nonatomic) IBOutlet UIView *trayView;
@property (weak, nonatomic) IBOutlet UIImageView *toggleTrayImage;


@property BOOL trayOpen;
@property BOOL layoutComplete;
@property (weak, nonatomic) IBOutlet UIImageView *previewImageView;
@property (weak, nonatomic) IBOutlet UIView *previewImageContainerView;

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) NSArray *pages;

@end

@implementation CanvasViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.trayOpen = YES;
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTrayToggleTap:)];
    tapGestureRecognizer.numberOfTapsRequired = 1;
    self.toggleTrayImage.userInteractionEnabled = YES;
    [self.toggleTrayImage addGestureRecognizer:tapGestureRecognizer];
    self.previewImageView.image = self.pictureImage;
    
    self.pages = @[@{@"page": @"Hats", @"images": @[@"Thumb_red puma hat.PNG",
                                              @"Thumb_kids griffin hat.png",
                                              @"Runner-Hat.png",
                                              @"Round-Hat2-300x300.png",
                                              @"Hats_SessTrucker_Red.gif",
                                              @"Hats_SessTrucker_Black.gif",
                                              @"hat-yachtsman-white-adjustable-back-763285706646.png",
                                              @"hat-viking-helmet-child-teen-one-size-763285730078.png",
                                              @"hat-cowboy-black-cattleman-adult-med-9999914598.png",
                                              @"hat-confederate-general-dlx-adult-sm-9999912643.png",
                                              @"hat-conductor-adult-large-9999917479.png",
                                              @"more_mario_64_animation_by_expodude32-d79f1o1.png"]
                                             },
                   @{@"page": @"Glasses", @"images": @[@"3D_Glasses_Final_Clipart_Free.png",
                                                       @"glasses-300x300.png",
                                                       @"iolanta-black-gold-lorgnette-opera-glasses.png",
                                                       @"voodoo-tactical-military-glasses-1.gif",
                                                       @"voodoo-tactical-military-glasses-2.gif",
                                                       @"voodoo-tactical-military-glasses-3.gif",
                                                       @"voodoo-tactical-military-glasses-4.gif"]
                     }];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(onCancelButton)];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Share" style:UIBarButtonItemStylePlain target:self action:@selector(onShareButton)];
    
}

- (void)onCancelButton {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)onShareButton {
    UIImage *viewImage = [self getImageFromCanvas];
    ShareViewController* svc = [[ShareViewController alloc] initWithImage:viewImage];
    [self.navigationController pushViewController:svc animated:YES];
}


- (void)viewDidLayoutSubviews {
    
    if (!self.layoutComplete) {
        [self.scrollView setContentSize:CGSizeMake(self.view.frame.size.width * [self.pages count], self.scrollView.frame.size.height)];
        for (int i = 0; i < [self.pages count]; i++) {
            CGRect frame;
            frame.origin.x = self.trayView.frame.size.width * i;
            frame.origin.y = 0;
            frame.size = CGSizeMake(self.trayView.frame.size.width, self.trayView.frame.size.height - self.scrollView.frame.origin.y);
            
            UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
            [layout setSectionInset:UIEdgeInsetsMake(0, 10, 10, 10)];
            UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:frame collectionViewLayout:layout];
            collectionView.tag = i;
            collectionView.backgroundColor = self.trayView.backgroundColor;
            [collectionView setDataSource:self];
            [collectionView setDelegate:self];
            [collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"cellIdentifier"];
            self.scrollView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
            [self.scrollView addSubview:collectionView];
        }
        

        [self.scrollView setContentOffset:CGPointMake(0, 0)];
        self.layoutComplete = YES;
    }
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    NSDictionary *page = [self.pages objectAtIndex:collectionView.tag];
    
    return [page[@"images"] count];
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell=[collectionView dequeueReusableCellWithReuseIdentifier:@"cellIdentifier" forIndexPath:indexPath];
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTrayAssetTap:)];
    NSDictionary *page = [self.pages objectAtIndex:collectionView.tag];
    UIImage *image = [UIImage imageNamed:[page[@"images"] objectAtIndex:indexPath.item]];
    UIImageView *iv = [[UIImageView alloc]initWithImage:image];
    [cell addGestureRecognizer:tapRecognizer];
    cell.backgroundView = iv;
    cell.userInteractionEnabled = YES;
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(75, 75);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onTrayAssetTap:(UITapGestureRecognizer *)recognizer {
    UICollectionView *collectionView = (UICollectionView *)recognizer.view.superview;
    UICollectionViewCell *collectionViewCell = (UICollectionViewCell *)recognizer.view;
    UIImageView *pImageView =  (UIImageView *)collectionViewCell.backgroundView;
    UIImage *croppedImage = [pImageView.image imageByTrimmingTransparentPixels];
    UIImageView *imageView;
    imageView = [[UIImageView alloc] initWithFrame:CGRectMake(pImageView.frame.origin.x, pImageView.frame.origin.x, 75, (croppedImage.size.height/croppedImage.size.width) * 75)];
    imageView.userInteractionEnabled = YES;
    [imageView setImage:croppedImage];
    imageView.center = CGPointMake(recognizer.view.center.x, recognizer.view.center.y + self.trayView.frame.origin.y + self.scrollView.frame.origin.y - collectionView.contentOffset.y);
    [self.previewImageContainerView addSubview:imageView];
    [self.previewImageContainerView bringSubviewToFront:imageView];
    
    UIPanGestureRecognizer *pan_gr = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(onStickerPan:)];
    [imageView addGestureRecognizer:pan_gr];
    
    UITapGestureRecognizer *tap_gr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onStickerDoubleTap:)];
    tap_gr.numberOfTapsRequired = 2;
    [imageView addGestureRecognizer:tap_gr];
    
    UILongPressGestureRecognizer *lp_gr = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(onStickerLongPress:)];
    lp_gr.minimumPressDuration = 0.5;
    [imageView addGestureRecognizer:lp_gr];
    
    UIPinchGestureRecognizer *pinch_gr = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(onStickerPinch:)];
    [imageView addGestureRecognizer:pinch_gr];
    
    UIRotationGestureRecognizer *rotate_gr = [[UIRotationGestureRecognizer alloc] initWithTarget: self action:@selector(onStickerRotate:)];
    [imageView addGestureRecognizer:rotate_gr];
    
    rotate_gr.delegate = self; // delegate at least one transform to get them to trigger the callback methods in this controller
    
    [UIView animateWithDuration:.25 animations:^{
        imageView.center = CGPointMake(self.previewImageView.center.x, self.previewImageView.center.y);
        imageView.transform = CGAffineTransformScale(imageView.transform, 2, 2);

    }];
}

- (void)onStickerRotate:(UIRotationGestureRecognizer *)recognizer{
    recognizer.view.transform = CGAffineTransformRotate(recognizer.view.transform, recognizer.view.transform.a < 0 ? - 1 *recognizer.rotation : recognizer.rotation);
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
- (IBAction)onStickerPan:(UIPanGestureRecognizer *)recognizer {
    static CGPoint originalCenter;
    static CGPoint originalLocationInView;
    
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        originalCenter = recognizer.view.center;
        originalLocationInView = [recognizer locationInView:self.view];
    } else if (recognizer.state == UIGestureRecognizerStateChanged) {
        CGPoint point = [recognizer locationInView:self.view];
        // We calculate the delta moved from initial the touch point to where it is now and add that to the original center of the image
        recognizer.view.center = CGPointMake((point.x - originalLocationInView.x) + originalCenter.x, (point.y - originalLocationInView.y) + originalCenter.y);
    } else if (recognizer.state == UIGestureRecognizerStateEnded) {
        // If you drop on the tray, move the image copy back to original point where you last dropped it
//        if ((recognizer.view.frame.origin.y + recognizer.view.frame.size.height) >= self.trayView.frame.origin.y) {
//            [UIView animateWithDuration:.10 animations:^{
//                recognizer.view.center = originalCenter;
//            }];
//        }
    }
}

- (IBAction)onStickerDoubleTap:(UITapGestureRecognizer *)recognizer {
    if (recognizer.state == UIGestureRecognizerStateRecognized) {
        recognizer.view.alpha = 1;
        [UIView animateWithDuration:.2 animations:^{
            recognizer.view.transform =  CGAffineTransformScale(recognizer.view.transform, 1.3, 1.3);
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:.2 animations:^{
                recognizer.view.transform =  CGAffineTransformScale(recognizer.view.transform, .1, .1);
                recognizer.view.alpha = 0;
            } completion:^(BOOL finished) {
                [recognizer.view removeFromSuperview];
            }];
        }];
    }
}

- (IBAction)onStickerLongPress:(UILongPressGestureRecognizer *)recognizer {
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        [UIView animateWithDuration:.25 animations:^{
            recognizer.view.transform = CGAffineTransformScale(recognizer.view.transform, -1, 1);
        }];
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
    UIGraphicsBeginImageContext(self.previewImageView.frame.size);
    [self.previewImageContainerView.layer renderInContext:UIGraphicsGetCurrentContext()];
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

- (void)flipHorizontal:(NSTimer *)timer {
    UIImageView *view = (UIImageView *)timer.userInfo;
    [UIView animateWithDuration:.25 animations:^{
        view.transform = CGAffineTransformScale(view.transform, -1, 1);
    }];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

- (void)setPictureImage:(UIImage *)picture {
    _pictureImage = picture;
}
@end

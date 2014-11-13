//
//  CanvasViewController.h
//  StickerCam
//
//  Created by Blair Vanderhoof on 11/11/14.
//  Copyright (c) 2014 blairv. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CanvasViewController : UIViewController<UIGestureRecognizerDelegate,UIScrollViewDelegate>
@property (strong, nonatomic) UIImage *pictureImage;
- (void)setPictureImage:(UIImage *)picture;
@end

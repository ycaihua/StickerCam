//
//  CameraViewController.h
//  CustomCamera
//
//  Created by Kent Tam on 11/10/14.
//  Copyright (c) 2014 Kent Tam. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CameraViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIView *frameForCapture;
@property (weak, nonatomic) IBOutlet UIImageView *photoImageView;
- (IBAction)takePhoto:(id)sender;

@end

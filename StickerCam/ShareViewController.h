//
//  ShareViewController.h
//  StickerCam
//
//  Created by Ravi Sathyam on 11/12/14.
//  Copyright (c) 2014 blairv. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ShareViewController : UIViewController<UITextViewDelegate>
- (id)initWithImage:(UIImage *)image;
@property (strong, nonatomic) UIImage* image;
@property (weak, nonatomic) IBOutlet UIImageView *shareImageView;
@property (weak, nonatomic) IBOutlet UIButton *facebookShareButton;
@property (weak, nonatomic) IBOutlet UIButton *instagramShareButton;
- (IBAction)onFacebookShareButtonClicked:(id)sender;
- (IBAction)onInstagramShareButtonClicked:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *stickerCamButton;
- (IBAction)onStickerCamClick:(id)sender;

typedef enum {
    Facebook,
    Instagram
} SocialNetwork;
@end

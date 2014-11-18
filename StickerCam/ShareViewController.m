//
//  ShareViewController.m
//  StickerCam
//
//  Created by Ravi Sathyam on 11/12/14.
//  Copyright (c) 2014 blairv. All rights reserved.
//

#import "ShareViewController.h"
#import <FacebookSDK/FacebookSDK.h>
#import <MGInstagram/MGInstagram.h>

@interface ShareViewController()

@end

@implementation ShareViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.captionView.delegate = self;
    //TODO - remove this override
    self.image = [UIImage imageNamed:@"test_image_stickercam.jpg"];

    CGSize targetSize = self.shareImageView.bounds.size;
    UIGraphicsBeginImageContextWithOptions(targetSize, NO, 0.0);
    [self.image drawInRect:CGRectMake(0, 0, targetSize.width, targetSize.height)];
    UIImage* resized = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    [self.shareImageView setImage:resized];
    
    self.facebookShareButton.layer.cornerRadius = 4;
    self.instagramShareButton.layer.cornerRadius = 4;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (id)initWithImage:(UIImage *)image {
    self = [super init];
    if (self) {
        self.image = image;
    }
    return self;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
    if([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    
    return YES;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)onFacebookShareButtonClicked:(id)sender {
    // Check if the Facebook app is installed and we can present the share dialog
    FBLinkShareParams *params = [[FBLinkShareParams alloc] init];
    params.link = [NSURL URLWithString:@"https://developers.facebook.com/docs/ios/share/"];
    if ([self.captionView.text length] > 0) {
        params.caption = self.captionView.text;
    }
    
    NSArray* photos = @[self.shareImageView.image];
    
    // If the Facebook app is installed and we can present the share dialog
    if ([FBDialogs canPresentShareDialogWithParams:params]) {
        // Present the share dialog
        [FBDialogs presentShareDialogWithPhotos:photos handler:^(FBAppCall *call, NSDictionary *results, NSError *error) {
            if(error) {
                // An error occurred, we need to handle the error
                //Throw a UIAlertView here
                // See: https://developers.facebook.com/docs/ios/errors
                NSLog(@"Error publishing story: %@", error.description);
            }
        }];
    }
}

- (IBAction)onInstagramShareButtonClicked:(id)sender {
    [MGInstagram postImage:self.shareImageView.image inView:self.view];
}
@end

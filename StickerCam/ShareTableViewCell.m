//
//  ShareTableViewCell.m
//  StickerCam
//
//  Created by Ravi Sathyam on 11/12/14.
//  Copyright (c) 2014 blairv. All rights reserved.
//

#import "ShareTableViewCell.h"
#import <FacebookSDK/FacebookSDK.h>
#import <MGInstagram/MGInstagram.h>

@implementation ShareTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)onShareButtonClicked:(id)sender {
    if (self.socialNetwork == Facebook) {
        // Check if the Facebook app is installed and we can present the share dialog
        FBLinkShareParams *params = [[FBLinkShareParams alloc] init];
        params.link = [NSURL URLWithString:@"https://developers.facebook.com/docs/ios/share/"];
        
        NSArray* photos = @[self.shareImage];
        
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
    } else if (self.socialNetwork == Instagram) {
        [MGInstagram postImage:self.shareImage inView:self.socialNetworkImageView];
    }
}
@end

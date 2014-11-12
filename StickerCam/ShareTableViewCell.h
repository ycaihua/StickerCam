//
//  ShareTableViewCell.h
//  StickerCam
//
//  Created by Ravi Sathyam on 11/12/14.
//  Copyright (c) 2014 blairv. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ShareViewController.h"

@interface ShareTableViewCell : UITableViewCell


@property (weak, nonatomic) IBOutlet UIImageView *socialNetworkImageView;

@property (weak, nonatomic) IBOutlet UIButton *shareButton;
@property SocialNetwork socialNetwork;

- (IBAction)onShareButtonClicked:(id)sender;

@end
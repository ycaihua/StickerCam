//
//  ShareViewController.m
//  StickerCam
//
//  Created by Ravi Sathyam on 11/12/14.
//  Copyright (c) 2014 blairv. All rights reserved.
//

#import "ShareViewController.h"
#import "ShareTableViewCell.h"

@interface ShareViewController ()

@end

@implementation ShareViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    //TODO - remove this override
    self.image = [UIImage imageNamed:@"test_image_stickercam.jpg"];
    
    self.shareTableView.delegate = self;
    self.shareTableView.dataSource = self;
    CGSize targetSize = self.shareImageView.bounds.size;
    UIGraphicsBeginImageContextWithOptions(targetSize, NO, 0.0);
    [self.image drawInRect:CGRectMake(0, 0, targetSize.width, targetSize.height)];
    UIImage* resized = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    [self.shareImageView setImage:resized];
    
    [self.shareTableView registerNib:[UINib nibWithNibName:@"ShareTableViewCell" bundle:nil] forCellReuseIdentifier:@"ShareTableViewCell"];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"Share Photo";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ShareTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ShareTableViewCell" forIndexPath:indexPath];
    CGSize targetSize = cell.socialNetworkImageView.bounds.size;
    UIImage* resized = nil;
    UIImage* image = nil;
    UIGraphicsBeginImageContextWithOptions(targetSize, NO, 0.0);
    switch (indexPath.row) {
        case 0:
            cell.socialNetwork = Facebook;
            image = [UIImage imageNamed:@"FBLogo.png"];
            break;
        case 1:
            cell.socialNetwork = Twitter;
            image = [UIImage imageNamed:@"TwitterLogo.png"];
            break;
        default:
            break;
    }
    [image drawInRect:CGRectMake(0,0, targetSize.width, targetSize.height)];
    resized = UIGraphicsGetImageFromCurrentImageContext();
    [cell.socialNetworkImageView setImage:resized];
    
    return cell;
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



/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

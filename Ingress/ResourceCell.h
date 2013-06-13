//
//  ItemCell.h
//  Ingress
//
//  Created by Alex Studnička on 14.04.13.
//  Copyright (c) 2013 A&A Code. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ResourceCell : UITableViewCell <UIActionSheetDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *itemImageView;
@property (weak, nonatomic) IBOutlet UILabel *itemTitleLabel;
@property (nonatomic) ItemType itemType;

- (IBAction)action:(UIButton *)sender;

@end

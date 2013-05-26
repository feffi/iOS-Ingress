//
//  ItemCell.h
//  Ingress
//
//  Created by Alex Studnička on 14.04.13.
//  Copyright (c) 2013 A&A Code. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
	ItemTypeResonator,
	ItemTypeXMP,
	ItemTypePortalShield,
	ItemTypePowerCube,
	ItemTypeFlipCard,
	ItemTypeLinkAmp
} ItemType;

@interface ResourceCell : UITableViewCell <UIActionSheetDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *itemImageView;
@property (nonatomic) ItemType itemType;

- (IBAction)action:(UIButton *)sender;

@end

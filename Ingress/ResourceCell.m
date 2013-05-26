//
//  ItemCell.m
//  Ingress
//
//  Created by Alex Studnička on 14.04.13.
//  Copyright (c) 2013 A&A Code. All rights reserved.
//

#import "ResourceCell.h"

@implementation ResourceCell {
	int actionLevel;
}

- (void)layoutSubviews {
	[super layoutSubviews];

	CGFloat fontSize = 16;

	if (self.itemType == ItemTypePortalShield || self.itemType == ItemTypeLinkAmp) {
		fontSize = 8;
	}

	for (UIView *view in self.contentView.subviews) {
		if ([view isKindOfClass:[UIButton class]]) {
			UIButton *button = (UIButton *)view;
			button.titleLabel.font = [UIFont fontWithName:[[[UILabel appearance] font] fontName] size:fontSize];
		}
	}

}

#pragma mark - Set values

- (void)setItemType:(ItemType)itemType {
	_itemType = itemType;

	Class objectClass = [NSManagedObject class];
	switch (itemType) {
		case ItemTypeResonator:
			objectClass = [Resonator class];
			break;
		case ItemTypeXMP:
			objectClass = [XMP class];
			break;
		case ItemTypePortalShield:
			objectClass = [Shield class];
			break;
		case ItemTypePowerCube:
			objectClass = [PowerCube class];
			break;
		case ItemTypeFlipCard:
			objectClass = [FlipCard class];
			break;
		case ItemTypeLinkAmp:
			objectClass = [Item class];
			break;
	}

	if (itemType == ItemTypePortalShield) {
		for (int i = 1; i <= 3; i++) {
			UILabel *label = (UILabel *)[self.contentView viewWithTag:i];
			label.text = [NSString stringWithFormat:@"%d", [objectClass MR_countOfEntitiesWithPredicate:[NSPredicate predicateWithFormat:@"dropped = NO && rarity = %d", i-1]]];
		}
	} else if (itemType == ItemTypeFlipCard) {
		for (int i = 1; i <= 2; i++) {
			UILabel *label = (UILabel *)[self.contentView viewWithTag:i];
			label.text = @"-";
			//label.text = [NSString stringWithFormat:@"%d", [objectClass MR_countOfEntitiesWithPredicate:[NSPredicate predicateWithFormat:@"dropped = NO && faction = %@", (i == 1) ? @"ALIENS" : @"RESISTANCE"]]];
		}
	} else if (itemType == ItemTypeLinkAmp) {
		for (int i = 1; i <= 3; i++) {
			UILabel *label = (UILabel *)[self.contentView viewWithTag:i];
			label.text = @"-";
		}
	} else {
		for (int i = 1; i <= 8; i++) {
			UILabel *label = (UILabel *)[self.contentView viewWithTag:i];
			label.text = [NSString stringWithFormat:@"%d", [objectClass MR_countOfEntitiesWithPredicate:[NSPredicate predicateWithFormat:@"dropped = NO && level = %d", i]]];
		}
	}

}

#pragma mark - Action

- (IBAction)action:(UIButton *)sender {

	actionLevel = sender.tag-10;

	if (self.itemType == ItemTypePowerCube || self.itemType == ItemTypeFlipCard) {
		UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Drop" otherButtonTitles:@"Use", @"Recycle", nil];
		[actionSheet showInView:self];
	} else {
		UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Drop" otherButtonTitles:@"Recycle", nil];
		[actionSheet showInView:self];
	}
	
}

#pragma mark - Actions

- (void)dropItem {

	Class objectClass = [NSManagedObject class];
	switch (self.itemType) {
		case ItemTypeResonator:
			objectClass = [Resonator class];
			break;
		case ItemTypeXMP:
			objectClass = [XMP class];
			break;
		case ItemTypePortalShield:
			objectClass = [Shield class];
			break;
		case ItemTypePowerCube:
			objectClass = [PowerCube class];
			break;
		case ItemTypeFlipCard:
			objectClass = [FlipCard class];
			break;
		case ItemTypeLinkAmp:
			objectClass = [Item class];
			break;
	}

	NSString *guid;

	if (self.itemType == ItemTypePortalShield) {
		PortalShieldRarity rarity = [API shieldRarityFromInt:actionLevel];
		guid = [[objectClass MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"dropped = NO && rarity = %d", rarity]] guid];
	} else if (self.itemType == ItemTypeFlipCard) {
		guid = [[objectClass MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"dropped = NO && faction = %@", (actionLevel == 1) ? @"ALIENS" : @"RESISTANCE"]] guid];
	} else if (self.itemType == ItemTypeLinkAmp) {
		guid = nil;
	} else {
		guid = [[objectClass MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"dropped = NO && level = %d", actionLevel]] guid];
	}

	actionLevel = 0;

	if (guid) {

		__block MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:[AppDelegate instance].window];
		HUD.userInteractionEnabled = YES;
		HUD.mode = MBProgressHUDModeIndeterminate;
		HUD.dimBackground = YES;
		HUD.labelFont = [UIFont fontWithName:[[[UILabel appearance] font] fontName] size:16];
		HUD.labelText = @"Dropping Item...";
		[[AppDelegate instance].window addSubview:HUD];
		[HUD show:YES];

		[[SoundManager sharedManager] playSound:@"Sound/sfx_drop_resource.aif"];

		[[API sharedInstance] dropItemWithGuid:guid completionHandler:^(void) {
			[HUD hide:YES];
		}];

	} else {

		MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:[AppDelegate instance].window];
		HUD.userInteractionEnabled = YES;
		HUD.dimBackground = YES;
		HUD.mode = MBProgressHUDModeCustomView;
		HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"warning.png"]];
		HUD.detailsLabelFont = [UIFont fontWithName:[[[UILabel appearance] font] fontName] size:16];
		HUD.detailsLabelText = @"No Item";
		[[AppDelegate instance].window addSubview:HUD];
		[HUD show:YES];
		[HUD hide:YES afterDelay:HUD_DELAY_TIME];
		
	}

}

- (void)recycleItem {

	Class objectClass = [NSManagedObject class];
	switch (self.itemType) {
		case ItemTypeResonator:
			objectClass = [Resonator class];
			break;
		case ItemTypeXMP:
			objectClass = [XMP class];
			break;
		case ItemTypePortalShield:
			objectClass = [Shield class];
			break;
		case ItemTypePowerCube:
			objectClass = [PowerCube class];
			break;
		case ItemTypeFlipCard:
			objectClass = [FlipCard class];
			break;
		case ItemTypeLinkAmp:
			objectClass = [Item class];
			break;
	}

	Item *item;

	if (self.itemType == ItemTypePortalShield) {
		PortalShieldRarity rarity = [API shieldRarityFromInt:actionLevel];
		item = [objectClass MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"dropped = NO && rarity = %d", rarity]];
	} else if (self.itemType == ItemTypeFlipCard) {
		item = [objectClass MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"dropped = NO && faction = %@", (actionLevel == 1) ? @"ALIENS" : @"RESISTANCE"]];
	} else if (self.itemType == ItemTypeLinkAmp) {
		item = nil;
	} else {
		item = [objectClass MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"dropped = NO && level = %d", actionLevel]];
	}

	actionLevel = 0;

	if (item) {

		__block MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:[AppDelegate instance].window];
		HUD.userInteractionEnabled = YES;
		HUD.mode = MBProgressHUDModeIndeterminate;
		HUD.dimBackground = YES;
		HUD.labelFont = [UIFont fontWithName:[[[UILabel appearance] font] fontName] size:16];
		HUD.labelText = @"Recycling Item...";
		[[AppDelegate instance].window addSubview:HUD];
		[HUD show:YES];

		[[SoundManager sharedManager] playSound:[NSString stringWithFormat:@"Sound/sfx_recycle_%@.aif", arc4random_uniform(2) ? @"a" : @"b"]];

		[[API sharedInstance] recycleItem:item completionHandler:^{
			[HUD hide:YES];
		}];

	} else {

		MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:[AppDelegate instance].window];
		HUD.userInteractionEnabled = YES;
		HUD.dimBackground = YES;
		HUD.mode = MBProgressHUDModeCustomView;
		HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"warning.png"]];
		HUD.detailsLabelFont = [UIFont fontWithName:[[[UILabel appearance] font] fontName] size:16];
		HUD.detailsLabelText = @"No Item";
		[[AppDelegate instance].window addSubview:HUD];
		[HUD show:YES];
		[HUD hide:YES afterDelay:HUD_DELAY_TIME];
		
	}

}

- (void)usePowerCube {

	PowerCube *powerCube = [PowerCube MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"dropped = NO && level = %d", actionLevel]];

	if (powerCube) {

		actionLevel = 0;

		__block MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:[AppDelegate instance].window];
		HUD.userInteractionEnabled = YES;
		HUD.mode = MBProgressHUDModeIndeterminate;
		HUD.dimBackground = YES;
		HUD.labelFont = [UIFont fontWithName:[[[UILabel appearance] font] fontName] size:16];
		HUD.labelText = @"Using Power Cube...";
		[[AppDelegate instance].window addSubview:HUD];
		[HUD show:YES];

		[[SoundManager sharedManager] playSound:@"Sound/sfx_powercube_activate.aif"];

		[[API sharedInstance] usePowerCube:powerCube completionHandler:^{
			[HUD hide:YES];
		}];
		
	} else {

		MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:[AppDelegate instance].window];
		HUD.userInteractionEnabled = YES;
		HUD.dimBackground = YES;
		HUD.mode = MBProgressHUDModeCustomView;
		HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"warning.png"]];
		HUD.detailsLabelFont = [UIFont fontWithName:[[[UILabel appearance] font] fontName] size:16];
		HUD.detailsLabelText = @"No Item";
		[[AppDelegate instance].window addSubview:HUD];
		[HUD show:YES];
		[HUD hide:YES afterDelay:HUD_DELAY_TIME];
		
	}

}

- (void)useFlipCard {

	FlipCard *flipCard = [FlipCard MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"dropped = NO && faction = %@", (actionLevel == 1) ? @"ALIENS" : @"RESISTANCE"]];

	if (flipCard) {

		actionLevel = 0;

#warning Virus not yet implemented

		//self.window.rootViewController.tabBarController

	} else {

		MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:[AppDelegate instance].window];
		HUD.userInteractionEnabled = YES;
		HUD.dimBackground = YES;
		HUD.mode = MBProgressHUDModeCustomView;
		HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"warning.png"]];
		HUD.detailsLabelFont = [UIFont fontWithName:[[[UILabel appearance] font] fontName] size:16];
		HUD.detailsLabelText = @"No Item";
		[[AppDelegate instance].window addSubview:HUD];
		[HUD show:YES];
		[HUD hide:YES afterDelay:HUD_DELAY_TIME];
		
	}
	
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	
	[[SoundManager sharedManager] playSound:@"Sound/sfx_ui_success.aif"];
	
	if (self.itemType == ItemTypePowerCube || self.itemType == ItemTypeFlipCard) {
		if (buttonIndex == 0) {
			[self dropItem];
		} else if (buttonIndex == 1) {
			if (self.itemType == ItemTypePowerCube) {
				[self usePowerCube];
			} else {
				[self useFlipCard];
			}
		} else if (buttonIndex == 2) {
			[self recycleItem];
		}
	} else {
		if (buttonIndex == 0) {
			[self dropItem];
		} else if (buttonIndex == 1) {
			[self recycleItem];
		}
	}
	
}

@end

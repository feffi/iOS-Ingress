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

	if (self.itemType == ItemTypePortalShield) {
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
	}

	if (itemType == ItemTypePortalShield) {
		for (int i = 1; i <= 3; i++) {
			UILabel *label = (UILabel *)[self.contentView viewWithTag:i];
			label.text = [NSString stringWithFormat:@"%d", [objectClass MR_countOfEntitiesWithPredicate:[NSPredicate predicateWithFormat:@"dropped = NO && rarity = %d", i-1]]];
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

	if (self.itemType == ItemTypePowerCube) {
		UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Drop" otherButtonTitles:@"Use", nil];
		//	[actionSheet showFromTabBar:self.tabBarController.tabBar];
		[actionSheet showInView:self];
	} else {
		UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Drop" otherButtonTitles:nil];
		//	[actionSheet showFromTabBar:self.tabBarController.tabBar];
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
	}

	NSString *guid;

	if (self.itemType == ItemTypePortalShield) {
		PortalShieldRarity rarity = [API shieldRarityFromInt:actionLevel];
		guid = [[objectClass MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"dropped = NO && rarity = %d", rarity] andRetrieveAttributes:@[@"guid"]] guid];
	} else {
		guid = [[objectClass MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"dropped = NO && level = %d", actionLevel] andRetrieveAttributes:@[@"guid"]] guid];
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

		[[API sharedInstance] playSound:@"SFX_DROP_RESOURCE"];

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
		[HUD hide:YES afterDelay:3];
		
	}

}

- (void)usePowerCube {

	PowerCube *powerCube = [PowerCube MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"dropped = NO && level = %d", actionLevel] andRetrieveAttributes:@[@"guid"]];

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
		[HUD hide:YES afterDelay:3];
		
	}

}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	
	[[SoundManager sharedManager] playSound:@"Sound/sfx_ui_success.aif"];
	
	if (self.itemType == ItemTypePowerCube) {
		if (buttonIndex == 0) {
			[self dropItem];
		} else if (buttonIndex == 1) {
			[self usePowerCube];
		}
	} else {
		if (buttonIndex == 0) {
			[self dropItem];
		}
	}
	
}

@end

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
	
	switch (itemType) {
		case ItemTypeResonator: {
			
			UILabel *label = (UILabel *)[self.contentView viewWithTag:1];
			label.text = [NSString stringWithFormat:@"%d", [[DB sharedInstance] numberOfResonatorsOfLevel:1]];
			
			label = (UILabel *)[self.contentView viewWithTag:2];
			label.text = [NSString stringWithFormat:@"%d", [[DB sharedInstance] numberOfResonatorsOfLevel:2]];
			
			label = (UILabel *)[self.contentView viewWithTag:3];
			label.text = [NSString stringWithFormat:@"%d", [[DB sharedInstance] numberOfResonatorsOfLevel:3]];
			
			label = (UILabel *)[self.contentView viewWithTag:4];
			label.text = [NSString stringWithFormat:@"%d", [[DB sharedInstance] numberOfResonatorsOfLevel:4]];
			
			label = (UILabel *)[self.contentView viewWithTag:5];
			label.text = [NSString stringWithFormat:@"%d", [[DB sharedInstance] numberOfResonatorsOfLevel:5]];
			
			label = (UILabel *)[self.contentView viewWithTag:6];
			label.text = [NSString stringWithFormat:@"%d", [[DB sharedInstance] numberOfResonatorsOfLevel:6]];
			
			label = (UILabel *)[self.contentView viewWithTag:7];
			label.text = [NSString stringWithFormat:@"%d", [[DB sharedInstance] numberOfResonatorsOfLevel:7]];
			
			label = (UILabel *)[self.contentView viewWithTag:8];
			label.text = [NSString stringWithFormat:@"%d", [[DB sharedInstance] numberOfResonatorsOfLevel:8]];
			
			break;
		}
		case ItemTypeXMP: {
			
			UILabel *label = (UILabel *)[self.contentView viewWithTag:1];
			label.text = [NSString stringWithFormat:@"%d", [[DB sharedInstance] numberOfXMPsOfLevel:1]];
			
			label = (UILabel *)[self.contentView viewWithTag:2];
			label.text = [NSString stringWithFormat:@"%d", [[DB sharedInstance] numberOfXMPsOfLevel:2]];
			
			label = (UILabel *)[self.contentView viewWithTag:3];
			label.text = [NSString stringWithFormat:@"%d", [[DB sharedInstance] numberOfXMPsOfLevel:3]];
			
			label = (UILabel *)[self.contentView viewWithTag:4];
			label.text = [NSString stringWithFormat:@"%d", [[DB sharedInstance] numberOfXMPsOfLevel:4]];
			
			label = (UILabel *)[self.contentView viewWithTag:5];
			label.text = [NSString stringWithFormat:@"%d", [[DB sharedInstance] numberOfXMPsOfLevel:5]];
			
			label = (UILabel *)[self.contentView viewWithTag:6];
			label.text = [NSString stringWithFormat:@"%d", [[DB sharedInstance] numberOfXMPsOfLevel:6]];
			
			label = (UILabel *)[self.contentView viewWithTag:7];
			label.text = [NSString stringWithFormat:@"%d", [[DB sharedInstance] numberOfXMPsOfLevel:7]];
			
			label = (UILabel *)[self.contentView viewWithTag:8];
			label.text = [NSString stringWithFormat:@"%d", [[DB sharedInstance] numberOfXMPsOfLevel:8]];
			
			break;
		}
		case ItemTypePortalShield: {

			UILabel *label = (UILabel *)[self.contentView viewWithTag:1];
			label.text = [NSString stringWithFormat:@"%d", [[DB sharedInstance] numberOfPortalShieldsOfRarity:PortalShieldRarityCommon]];
			
			label = (UILabel *)[self.contentView viewWithTag:2];
			label.text = [NSString stringWithFormat:@"%d", [[DB sharedInstance] numberOfPortalShieldsOfRarity:PortalShieldRarityRare]];
			
			label = (UILabel *)[self.contentView viewWithTag:3];
			label.text = [NSString stringWithFormat:@"%d", [[DB sharedInstance] numberOfPortalShieldsOfRarity:PortalShieldRarityVeryRare]];

			break;
		}
		case ItemTypePowerCube: {
			
			UILabel *label = (UILabel *)[self.contentView viewWithTag:1];
			label.text = [NSString stringWithFormat:@"%d", [[DB sharedInstance] numberOfPowerCubesOfLevel:1]];

			label = (UILabel *)[self.contentView viewWithTag:2];
			label.text = [NSString stringWithFormat:@"%d", [[DB sharedInstance] numberOfPowerCubesOfLevel:2]];

			label = (UILabel *)[self.contentView viewWithTag:3];
			label.text = [NSString stringWithFormat:@"%d", [[DB sharedInstance] numberOfPowerCubesOfLevel:3]];

			label = (UILabel *)[self.contentView viewWithTag:4];
			label.text = [NSString stringWithFormat:@"%d", [[DB sharedInstance] numberOfPowerCubesOfLevel:4]];

			label = (UILabel *)[self.contentView viewWithTag:5];
			label.text = [NSString stringWithFormat:@"%d", [[DB sharedInstance] numberOfPowerCubesOfLevel:5]];

			label = (UILabel *)[self.contentView viewWithTag:6];
			label.text = [NSString stringWithFormat:@"%d", [[DB sharedInstance] numberOfPowerCubesOfLevel:6]];

			label = (UILabel *)[self.contentView viewWithTag:7];
			label.text = [NSString stringWithFormat:@"%d", [[DB sharedInstance] numberOfPowerCubesOfLevel:7]];

			label = (UILabel *)[self.contentView viewWithTag:8];
			label.text = [NSString stringWithFormat:@"%d", [[DB sharedInstance] numberOfPowerCubesOfLevel:8]];

			break;
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

	NSString *guid;

	switch (self.itemType) {
		case ItemTypeResonator: {
			guid = [[DB sharedInstance] getRandomResonatorOfLevel:actionLevel].guid;
			break;
		}
		case ItemTypeXMP: {
			guid = [[DB sharedInstance] getRandomXMPOfLevel:actionLevel].guid;
			break;
		}
		case ItemTypePortalShield: {
			PortalShieldRarity rarity = [API shieldRarityFromInt:actionLevel];
			guid = [[DB sharedInstance] getRandomShieldOfRarity:rarity].guid;
			break;
		}
		case ItemTypePowerCube: {
			guid = [[DB sharedInstance] getRandomPowerCubeOfLevel:actionLevel].guid;
			break;
		}
	}

	actionLevel = 0;

	if (guid) {

		__block MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:[AppDelegate instance].window];
		HUD.userInteractionEnabled = YES;
		HUD.mode = MBProgressHUDModeIndeterminate;
		HUD.dimBackground = YES;
		HUD.labelFont = [UIFont fontWithName:@"Coda-Regular" size:16];
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
		HUD.detailsLabelFont = [UIFont fontWithName:@"Coda-Regular" size:16];
		HUD.detailsLabelText = @"No Item";
		[[AppDelegate instance].window addSubview:HUD];
		[HUD show:YES];
		[HUD hide:YES afterDelay:3];
		
	}

}

- (void)usePowerCube {

	PowerCube *powerCube = [[DB sharedInstance] getRandomPowerCubeOfLevel:actionLevel];

	if (powerCube) {

		actionLevel = 0;

		__block MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:[AppDelegate instance].window];
		HUD.userInteractionEnabled = YES;
		HUD.mode = MBProgressHUDModeIndeterminate;
		HUD.dimBackground = YES;
		HUD.labelFont = [UIFont fontWithName:@"Coda-Regular" size:16];
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
		HUD.detailsLabelFont = [UIFont fontWithName:@"Coda-Regular" size:16];
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

//
//  ItemCell.m
//  Ingress
//
//  Created by Alex Studnička on 14.04.13.
//  Copyright (c) 2013 A&A Code. All rights reserved.
//

#import "ResourceCell.h"

@implementation ResourceCell

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
	
//	if ((sender.tag - 40) >= 0 && (sender.tag - 40) < 10) {
//		actionResource = 1;
//		actionLevel = sender.tag-40+1;
//	} else if ((sender.tag - 50) >= 0 && (sender.tag - 50) < 10) {
//		actionResource = 2;
//		actionLevel = sender.tag-50+1;
//	} else if ((sender.tag - 60) >= 0 && (sender.tag - 60) < 10) {
//		actionResource = 3;
//		actionLevel = sender.tag-60+1;
//	}

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

	NSLog(@"Drop item");

//	NSString *guid;
//
//	switch (actionResource) {
//		case 1: {
//			guid = [[DB sharedInstance] getRandomResonatorOfLevel:actionLevel].guid;
//			break;
//		}
//		case 2: {
//			guid = [[DB sharedInstance] getRandomXMPOfLevel:actionLevel].guid;
//			break;
//		}
//		case 3: {
//			PortalShieldRarity rarity = [API shieldRarityFromInt:actionLevel];
//			guid = [[DB sharedInstance] getRandomShieldOfRarity:rarity].guid;
//			break;
//		}
//	}
//
//	actionResource = 0;
//	actionLevel = 0;
//
//	if (!guid) { break; }
//
//	__block MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:[AppDelegate instance].window];
//	HUD.userInteractionEnabled = YES;
//	HUD.mode = MBProgressHUDModeIndeterminate;
//	HUD.dimBackground = YES;
//	HUD.labelFont = [UIFont fontWithName:@"Coda-Regular" size:16];
//	HUD.labelText = @"Dropping Item...";
//	[[AppDelegate instance].window addSubview:HUD];
//	[HUD show:YES];
//
//	[[SoundManager sharedManager] playSound:@"Sound/sfx_drop_resource.aif"];
//
//	[[API sharedInstance] dropItemWithGuid:guid completionHandler:^(void) {
//
//		[HUD hide:YES];
//		
//	}];

}

- (void)usePowerCube {

	NSLog(@"Use power cube");

	//https://m-dot-betaspike.appspot.com/rpc/gameplay/dischargePowerCube

	//{"params":{"clientBasket":{"clientBlob":"7ilfDOYVSFJ3aq/FgNNh+ymD9siLb9vKzZ3BjIwWG3zFLCycIsdU/thb33WQbajK17h9Vbcl4eDs65LZomt58ObXTQkxhix2euAJfUbCBXp688iOE7wRyz6gj10pc5fR51ifZXUTvb7DMZxolNCdXu7wYBTFp7RhVDLWzv83nwe67u8zAsIFxGsAyJEvoEd5RrFT3ZV2yLkMrv17bMcyGdQQQFwsdJyBlTvMQyJyxWphx7XmRsUXb9coQRMnM470rg7GzdAeg/GlyPcMsImTEjvXBJWmumK+M52GFCUFnbX2AyVBKLzLAKaloOb48JX3FLOnAI6JQhumtYDA4y7MYw"},"energyGlobGuids":[],"itemGuid":"dc932f61ced445aaad9c1c98acb7510d.5","knobSyncTimestamp":1366652448744,"playerLocation":"0304bb16,00d2f918"}}

	//{"result":{"xmGained":2000},"gameBasket":{"gameEntities":[],"playerEntity":["25e5ce861b2f418398c03aa3cb1a85d5.c",1366652497434,{"playerPersonal":{"ap":"187627","energy":5336,"allowNicknameEdit":false,"allowFactionChoice":false,"clientLevel":22,"mediaHighWaterMarks":{"RESISTANCE":2,"ALIENS":6,"General":65},"energyState":"XM_OK","notificationSettings":{"shouldSendEmail":true,"maySendPromoEmail":true}},"controllingTeam":{"team":"ALIENS"}}],"apGains":[],"inventory":[],"deletedEntityGuids":["dc932f61ced445aaad9c1c98acb7510d.5"]}}

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

//
//  ItemCell.m
//  Ingress
//
//  Created by Alex Studnička on 14.04.13.
//  Copyright (c) 2013 A&A Code. All rights reserved.
//

#import "ResourceCell.h"
#import "ScannerViewController.h"

@implementation ResourceCell {
	int actionLevel;
	ChooserViewController *_countChooser;
}

- (void)layoutSubviews {
	[super layoutSubviews];

	CGFloat fontSize = 16;
	
	if (self.itemType == ItemTypePortalShield || self.itemType == ItemTypeForceAmp || self.itemType == ItemTypeHeatsink || self.itemType == ItemTypeLinkAmp || self.itemType == ItemTypeMultihack || self.itemType == ItemTypeTurret) {
		fontSize = 8;
	}

	for (UIView *view in self.contentView.subviews) {
		if ([view isKindOfClass:[UIButton class]]) {
			UIButton *button = (UIButton *)view;
			button.titleLabel.font = [UIFont fontWithName:[[[UILabel appearance] font] fontName] size:fontSize];
			button.titleLabel.numberOfLines = 0;
			button.titleLabel.textAlignment = NSTextAlignmentCenter;
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
		case ItemTypeForceAmp:
			objectClass = [ForceAmp class];
			break;
		case ItemTypeHeatsink:
			objectClass = [Heatsink class];
			break;
		case ItemTypeLinkAmp:
			objectClass = [LinkAmp class];
			break;
		case ItemTypeMultihack:
			objectClass = [Multihack class];
			break;
		case ItemTypeTurret:
			objectClass = [Turret class];
			break;
		case ItemTypeUnknown:
			objectClass = [Item class];
			break;
	}

	if (itemType == ItemTypePortalShield || itemType == ItemTypeForceAmp || itemType == ItemTypeHeatsink || itemType == ItemTypeLinkAmp || itemType == ItemTypeMultihack || itemType == ItemTypeTurret) {
		for (int i = 1; i <= 6; i++) {
			UILabel *label = (UILabel *)[self.contentView viewWithTag:i];
			ItemRarity rarity = [Utilities rarityFromInt:i];
			label.text = [NSString stringWithFormat:@"%d", [objectClass MR_countOfEntitiesWithPredicate:[NSPredicate predicateWithFormat:@"dropped = NO && rarity = %d", rarity]]];
		}
	} else if (itemType == ItemTypeFlipCard) {
		for (int i = 1; i <= 2; i++) {
			UILabel *label = (UILabel *)[self.contentView viewWithTag:i];
			label.text = [NSString stringWithFormat:@"%d", [objectClass MR_countOfEntitiesWithPredicate:[NSPredicate predicateWithFormat:@"dropped = NO && type = %@", (i == 1) ? @"JARVIS" : @"ADA"]]];
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
		UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Drop" otherButtonTitles:@"Recycle", @"Use", nil];
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
		case ItemTypeForceAmp:
			objectClass = [ForceAmp class];
			break;
		case ItemTypeHeatsink:
			objectClass = [Heatsink class];
			break;
		case ItemTypeLinkAmp:
			objectClass = [LinkAmp class];
			break;
		case ItemTypeMultihack:
			objectClass = [Multihack class];
			break;
		case ItemTypeTurret:
			objectClass = [Turret class];
			break;
		case ItemTypeUnknown:
			objectClass = [Item class];
			break;
	}

	int maxCount = 0;

	if (self.itemType == ItemTypePortalShield || self.itemType == ItemTypeForceAmp || self.itemType == ItemTypeHeatsink || self.itemType == ItemTypeLinkAmp || self.itemType == ItemTypeMultihack || self.itemType == ItemTypeTurret) {
		ItemRarity rarity = [Utilities rarityFromInt:actionLevel];
		maxCount = [objectClass MR_countOfEntitiesWithPredicate:[NSPredicate predicateWithFormat:@"dropped = NO && rarity = %d", rarity]];
	} else if (self.itemType == ItemTypeFlipCard) {
		maxCount = [objectClass MR_countOfEntitiesWithPredicate:[NSPredicate predicateWithFormat:@"dropped = NO && type = %@", (actionLevel == 1) ? @"JARVIS" : @"ADA"]];
	} else {
		maxCount = [objectClass MR_countOfEntitiesWithPredicate:[NSPredicate predicateWithFormat:@"dropped = NO && level = %d", actionLevel]];
	}

	if (maxCount > 0) {

		MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:[AppDelegate instance].window];
		HUD.removeFromSuperViewOnHide = YES;
		HUD.userInteractionEnabled = YES;
		HUD.mode = MBProgressHUDModeCustomView;
		HUD.dimBackground = YES;
		HUD.showCloseButton = YES;

		_countChooser = [ChooserViewController countChooserWithButtonTitle:@"DROP" maxCount:maxCount completionHandler:^(int count) {
			if (count > 0) {
				[HUD hide:YES];
				_countChooser = nil;

				MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:[AppDelegate instance].window];
				HUD.removeFromSuperViewOnHide = YES;
				HUD.userInteractionEnabled = YES;
				HUD.mode = MBProgressHUDModeIndeterminate;
				HUD.dimBackground = YES;
				HUD.labelFont = [UIFont fontWithName:[[[UILabel appearance] font] fontName] size:16];
				HUD.labelText = @"Dropping...";
				[[AppDelegate instance].window addSubview:HUD];
				[HUD show:YES];

				if ([[NSUserDefaults standardUserDefaults] boolForKey:DeviceSoundToggleEffects]) {
					[[SoundManager sharedManager] playSound:@"Sound/sfx_drop_resource.aif"];
				}

				NSArray *items;

				if (self.itemType == ItemTypePortalShield || self.itemType == ItemTypeForceAmp || self.itemType == ItemTypeHeatsink || self.itemType == ItemTypeLinkAmp || self.itemType == ItemTypeMultihack || self.itemType == ItemTypeTurret) {
					ItemRarity rarity = [Utilities rarityFromInt:actionLevel];
					items = [objectClass MR_findAllWithPredicate:[NSPredicate predicateWithFormat:@"dropped = NO && rarity = %d", rarity]];
				} else if (self.itemType == ItemTypeFlipCard) {
					items = [objectClass MR_findAllWithPredicate:[NSPredicate predicateWithFormat:@"dropped = NO && type = %@", (actionLevel == 1) ? @"JARVIS" : @"ADA"]];
				} else {
					items = [objectClass MR_findAllWithPredicate:[NSPredicate predicateWithFormat:@"dropped = NO && level = %d", actionLevel]];
				}

				if (items.count > count) {
					items = [items subarrayWithRange:NSMakeRange(0, count)];
				}

				__block int completed = 0;
				for (Item *item in items) {

					[[API sharedInstance] dropItemWithGuid:item.guid completionHandler:^(void) {
						completed++;
						if (completed == items.count) {
							[HUD hide:YES];
							self.itemType = self.itemType;
						}
					}];

				}

			}
		}];
		HUD.customView = _countChooser.view;
		
		[[AppDelegate instance].window addSubview:HUD];
		[HUD show:YES];

	} else {
		[Utilities showWarningWithTitle:@"No Item"];
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
		case ItemTypeForceAmp:
			objectClass = [ForceAmp class];
			break;
		case ItemTypeHeatsink:
			objectClass = [Heatsink class];
			break;
		case ItemTypeLinkAmp:
			objectClass = [LinkAmp class];
			break;
		case ItemTypeMultihack:
			objectClass = [Multihack class];
			break;
		case ItemTypeTurret:
			objectClass = [Turret class];
			break;
		case ItemTypeUnknown:
			objectClass = [Item class];
			break;
	}

	int maxCount = 0;

	if (self.itemType == ItemTypePortalShield || self.itemType == ItemTypeForceAmp || self.itemType == ItemTypeHeatsink || self.itemType == ItemTypeLinkAmp || self.itemType == ItemTypeMultihack || self.itemType == ItemTypeTurret) {
		ItemRarity rarity = [Utilities rarityFromInt:actionLevel];
		maxCount = [objectClass MR_countOfEntitiesWithPredicate:[NSPredicate predicateWithFormat:@"dropped = NO && rarity = %d", rarity]];
	} else if (self.itemType == ItemTypeFlipCard) {
		maxCount = [objectClass MR_countOfEntitiesWithPredicate:[NSPredicate predicateWithFormat:@"dropped = NO && type = %@", (actionLevel == 1) ? @"JARVIS" : @"ADA"]];
	} else {
		maxCount = [objectClass MR_countOfEntitiesWithPredicate:[NSPredicate predicateWithFormat:@"dropped = NO && level = %d", actionLevel]];
	}

	if (maxCount > 0) {

		MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:[AppDelegate instance].window];
		HUD.removeFromSuperViewOnHide = YES;
		HUD.userInteractionEnabled = YES;
		HUD.mode = MBProgressHUDModeCustomView;
		HUD.dimBackground = YES;
		HUD.showCloseButton = YES;

		_countChooser = [ChooserViewController countChooserWithButtonTitle:@"RECYCLE" maxCount:maxCount completionHandler:^(int count) {
			if (count > 0) {
				[HUD hide:YES];
				_countChooser = nil;

				MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:[AppDelegate instance].window];
				HUD.removeFromSuperViewOnHide = YES;
				HUD.userInteractionEnabled = YES;
				HUD.mode = MBProgressHUDModeIndeterminate;
				HUD.dimBackground = YES;
				HUD.labelFont = [UIFont fontWithName:[[[UILabel appearance] font] fontName] size:16];
				HUD.labelText = @"Recycling...";
				[[AppDelegate instance].window addSubview:HUD];
				[HUD show:YES];

				if ([[NSUserDefaults standardUserDefaults] boolForKey:DeviceSoundToggleEffects]) {
					[[SoundManager sharedManager] playSound:[NSString stringWithFormat:@"Sound/sfx_recycle_%@.aif", arc4random_uniform(2) ? @"a" : @"b"]];
				}

				NSArray *items;

				if (self.itemType == ItemTypePortalShield || self.itemType == ItemTypeForceAmp || self.itemType == ItemTypeHeatsink || self.itemType == ItemTypeLinkAmp || self.itemType == ItemTypeMultihack || self.itemType == ItemTypeTurret) {
					ItemRarity rarity = [Utilities rarityFromInt:actionLevel];
					items = [objectClass MR_findAllWithPredicate:[NSPredicate predicateWithFormat:@"dropped = NO && rarity = %d", rarity]];
				} else if (self.itemType == ItemTypeFlipCard) {
					items = [objectClass MR_findAllWithPredicate:[NSPredicate predicateWithFormat:@"dropped = NO && type = %@", (actionLevel == 1) ? @"JARVIS" : @"ADA"]];
				} else {
					items = [objectClass MR_findAllWithPredicate:[NSPredicate predicateWithFormat:@"dropped = NO && level = %d", actionLevel]];
				}

				if (items.count > count) {
					items = [items subarrayWithRange:NSMakeRange(0, count)];
				}

				__block int completed = 0;
				for (Item *item in items) {

					[[API sharedInstance] recycleItem:item completionHandler:^(void) {
						completed++;
						if (completed == items.count) {
							[HUD hide:YES];
							self.itemType = self.itemType;
						}
					}];

				}

			}
		}];
		HUD.customView = _countChooser.view;

		[[AppDelegate instance].window addSubview:HUD];
		[HUD show:YES];

	} else {
		[Utilities showWarningWithTitle:@"No Item"];
	}

}

- (void)usePowerCube {

	PowerCube *powerCube = [PowerCube MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"dropped = NO && level = %d", actionLevel]];

	if (powerCube) {

		actionLevel = 0;

		MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:[AppDelegate instance].window];
		HUD.removeFromSuperViewOnHide = YES;
		HUD.userInteractionEnabled = YES;
		HUD.mode = MBProgressHUDModeIndeterminate;
		HUD.dimBackground = YES;
		HUD.labelFont = [UIFont fontWithName:[[[UILabel appearance] font] fontName] size:16];
		HUD.labelText = @"Using Power Cube...";
		[[AppDelegate instance].window addSubview:HUD];
		[HUD show:YES];
        
        if ([[NSUserDefaults standardUserDefaults] boolForKey:DeviceSoundToggleEffects]) {
            [[SoundManager sharedManager] playSound:@"Sound/sfx_powercube_activate.aif"];
        }
        
		[[API sharedInstance] usePowerCube:powerCube completionHandler:^{
			[HUD hide:YES];
			self.itemType = self.itemType;
		}];
		
	} else {
		[Utilities showWarningWithTitle:@"No Item"];
	}

}

- (void)useFlipCard {

	FlipCard *flipCard = [FlipCard MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"dropped = NO && type = %@", (actionLevel == 1) ? @"JARVIS" : @"ADA"]];

	if (flipCard) {

		actionLevel = 0;

		ScannerViewController *scannerVC = [AppDelegate instance].scannerViewController;
		scannerVC.virusToUse = flipCard;
		[scannerVC.opsViewController dismissViewControllerAnimated:YES completion:NULL];

	} else {
		[Utilities showWarningWithTitle:@"No Item"];
	}
	
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	if ([[NSUserDefaults standardUserDefaults] boolForKey:DeviceSoundToggleEffects]) {
        [[SoundManager sharedManager] playSound:@"Sound/sfx_ui_success.aif"];
    }
    
	if (self.itemType == ItemTypePowerCube || self.itemType == ItemTypeFlipCard) {
		if (buttonIndex == 0) {
			[self dropItem];
		} else if (buttonIndex == 1) {
			[self recycleItem];
		} else if (buttonIndex == 2) {
			if (self.itemType == ItemTypePowerCube) {
				[self usePowerCube];
			} else {
				[self useFlipCard];
			}
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

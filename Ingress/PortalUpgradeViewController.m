//
//  PortalUpgradeViewController.m
//  Ingress
//
//  Created by Alex Studnička on 14.05.13.
//  Copyright (c) 2013 A&A Code. All rights reserved.
//

#import "PortalUpgradeViewController.h"

@implementation PortalUpgradeViewController {
	int currentSlotForDeploy;
}

- (void)viewDidLoad {
	[super viewDidLoad];

	CGFloat viewWidth = [UIScreen mainScreen].bounds.size.width;
	CGFloat viewHeight = [UIScreen mainScreen].bounds.size.height-113;

	_carousel = [[iCarousel alloc] initWithFrame:self.view.bounds];
	_carousel.frame = CGRectMake(0, 100, viewWidth, viewHeight-110);
	_carousel.backgroundColor = self.view.backgroundColor;
//	_carousel.backgroundColor = [UIColor colorWithRed:0 green:.5 blue:1 alpha:.5];
	_carousel.type = iCarouselTypeCylinder;
    _carousel.delegate = self;
    _carousel.dataSource = self;
	[self.view addSubview:_carousel];
	[_carousel scrollToItemAtIndex:2 animated:NO];

}

- (void)dealloc {
    _carousel.delegate = nil;
    _carousel.dataSource = nil;
}

- (void)viewWillLayoutSubviews {
	[self refresh];
}

#pragma mark - Refresh

- (void)refresh {

	Player *player = [[API sharedInstance] playerForContext:[NSManagedObjectContext MR_contextForCurrentThread]];

	for (int i = 0; i < 4; i++) {

		UIButton *button = (UIButton *)[self.view viewWithTag:100+i];

		button.titleLabel.numberOfLines = 0;
		button.titleLabel.font = [UIFont fontWithName:[[[UILabel appearance] font] fontName] size:10];

		DeployedMod *mod = [DeployedMod MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"portal = %@ && slot = %d", self.portal, i]];

		if ([mod isKindOfClass:[DeployedShield class]]) {
//			[button setTitle:[[(DeployedShield *)mod rarityStr] stringByAppendingString:@"\nShield"] forState:UIControlStateNormal];
			switch ([(DeployedShield *)mod rarity]) {
				case ItemRarityVeryCommon:
					[button setImage:[UIImage imageNamed:@"shield_verycommon.png"] forState:UIControlStateNormal];
					break;
				case ItemRarityCommon:
					[button setImage:[UIImage imageNamed:@"shield_common.png"] forState:UIControlStateNormal];
					break;
				case ItemRarityLessCommon:
					[button setImage:[UIImage imageNamed:@"shield_lesscommon.png"] forState:UIControlStateNormal];
					break;
				case ItemRarityRare:
					[button setImage:[UIImage imageNamed:@"shield_rare.png"] forState:UIControlStateNormal];
					break;
				case ItemRarityVeryRare:
					[button setImage:[UIImage imageNamed:@"shield_veryrare.png"] forState:UIControlStateNormal];
					break;
				case ItemRarityExtraRare:
					[button setImage:[UIImage imageNamed:@"shield_extrarare.png"] forState:UIControlStateNormal];
					break;
				default:
					[button setImage:[UIImage imageNamed:@"shield_verycommon.png"] forState:UIControlStateNormal];
					break;
			}
		} else if ([mod isKindOfClass:[DeployedLinkAmp class]]) {
			[button setImage:[UIImage imageNamed:@"linkAmpBtn.png"] forState:UIControlStateNormal];
		} else if ([mod isKindOfClass:[DeployedForceAmp class]]) {
			[button setImage:[UIImage imageNamed:@"forceAmpBtn.png"] forState:UIControlStateNormal];
		} else if ([mod isKindOfClass:[DeployedHeatsink class]]) {
			[button setImage:[UIImage imageNamed:@"heatsinkBtn.png"] forState:UIControlStateNormal];
		} else if ([mod isKindOfClass:[DeployedMultihack class]]) {
			[button setImage:[UIImage imageNamed:@"multihackBtn.png"] forState:UIControlStateNormal];
		} else if ([mod isKindOfClass:[DeployedTurret class]]) {
			[button setImage:[UIImage imageNamed:@"turretBtn.png"] forState:UIControlStateNormal];
		} else {
			[button setImage:nil forState:UIControlStateNormal];
		}

	}

	NSMutableArray *tmpResonators = [NSMutableArray arrayWithCapacity:8];
	for (int i = 0; i < 8; i++) {
		tmpResonators[i] = [NSNull null];
	}
	for (DeployedResonator *resonator in self.portal.resonators) {
		if (![resonator isKindOfClass:[NSNull class]]) {

			int slot = resonator.slot;

			if (self.portal.controllingTeam && ([self.portal.controllingTeam isEqualToString:player.team] || [self.portal.controllingTeam isEqualToString:@"NEUTRAL"])) {
				UIButton *button = (UIButton *)[self.view viewWithTag:50+slot];
				[button setTitle:@"UPGRADE" forState:UIControlStateNormal];
				tmpResonators[slot] = resonator;
			}

		}
	}
	_resonators = tmpResonators;

	[_carousel reloadData];
	
}

#pragma mark - iCarouselDataSource & iCarouselDelegate

- (NSUInteger)numberOfItemsInCarousel:(iCarousel *)carousel {
    return 8;
}

- (UIView *)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSUInteger)index reusingView:(UIView *)view {
    
	DeployedResonator *resonator = _resonators[index];
	
    UILabel *label = nil;
	GUIButton *deployButton = nil;
	GUIButton *rechargeButton = nil;
    
    if (!view) {
        
		view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 220, 220)];
//        view.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:.95];
		view.backgroundColor = [UIColor colorWithRed:16.0/255.0 green:32.0/255.0 blue:34.0/255.0 alpha:0.95];

        label = [[GlowingLabel alloc] initWithFrame:CGRectMake(20, 0, 180, 112)];
        label.backgroundColor = [UIColor clearColor];
        label.textColor = [UIColor whiteColor];
//        label.textAlignment = NSTextAlignmentCenter;
		label.font = [UIFont fontWithName:[[[UILabel appearance] font] fontName] size:18];
		label.minimumScaleFactor = .75;
		label.adjustsFontSizeToFitWidth = YES;
		label.numberOfLines = 0;
        label.tag = 1;
        [view addSubview:label];
        
		deployButton = [[GUIButton alloc] initWithFrame:CGRectMake(20, 112, 180, 44)];
		deployButton.titleLabel.font = [UIFont fontWithName:[[[UILabel appearance] font] fontName] size:20];
		[deployButton addTarget:self action:@selector(resonatorButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        deployButton.tag = 2;
        [view addSubview:deployButton];

		rechargeButton = [[GUIButton alloc] initWithFrame:CGRectMake(20, 166, 180, 44)];
		rechargeButton.titleLabel.font = [UIFont fontWithName:[[[UILabel appearance] font] fontName] size:20];
		[rechargeButton setTitle:@"RECHARGE" forState:UIControlStateNormal];
		[rechargeButton addTarget:self action:@selector(rechargeButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        rechargeButton.tag = 3;
		rechargeButton.hidden = YES;
        [view addSubview:rechargeButton];
        
    } else {
        label = (UILabel *)[view viewWithTag:1];
        deployButton = (GUIButton *)[view viewWithTag:2];
        rechargeButton = (GUIButton *)[view viewWithTag:3];
    }
    
	view.tag = index;
	NSString *resonatorOctant = @[@"E", @"NE", @"N", @"NW", @"W", @"SW", @"S", @"SE"][index];
    
	if (![resonator isKindOfClass:[NSNull class]]) {

		NSMutableString *resonatorString = [NSMutableString string];
		[resonatorString appendFormat:@"Level: L%d\n", resonator.level];
		[resonatorString appendFormat:@"XM: %.1fk/%.1fk\n", resonator.energy/1000., [Utilities maxEnergyForResonatorLevel:resonator.level]/1000.];
		[resonatorString appendFormat:@"Octant: %@\n", resonatorOctant];

		NSString *nickname = resonator.owner.nickname;
		if (nickname) { [resonatorString appendFormat:@"Owner: %@", nickname]; }

		NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:resonatorString];

		[attrString setAttributes:[Utilities attributesWithShadow:YES size:16 color:[UIColor whiteColor]] range:NSMakeRange(0, resonatorString.length)];

		[attrString setAttributes:[Utilities attributesWithShadow:YES size:16 color:[Utilities colorForLevel:resonator.level]] range:NSMakeRange(7, 2)];

		if (nickname) {
			[attrString setAttributes:[Utilities attributesWithShadow:YES size:16
																color:[Utilities colorForFaction:self.portal.controllingTeam]] range:NSMakeRange(resonatorString.length-nickname.length, nickname.length)];
		}

		[label setAttributedText:attrString];

		[deployButton setTitle:@"UPGRADE" forState:UIControlStateNormal];

		rechargeButton.hidden = NO;
	} else {
		label.text = [NSString stringWithFormat:@"Octant: %@", resonatorOctant];
        
		[deployButton setTitle:@"DEPLOY" forState:UIControlStateNormal];

		rechargeButton.hidden = YES;
	}
    
    return view;
	
}

- (CGFloat)carousel:(iCarousel *)_carousel valueForOption:(iCarouselOption)option withDefault:(CGFloat)value {

    switch (option) {
        case iCarouselOptionWrap: {
            return YES;
        }
        case iCarouselOptionSpacing: {
            return value * 1.05;
        }
        default: {
            return value;
        }
    }
	
}

//- (void)carouselCurrentItemIndexDidChange:(iCarousel *)carousel {
//	
//}

#pragma mark - Resonators

- (IBAction)resonatorButtonPressed:(GUIButton *)sender {

	if (sender.disabled) { return; }

	MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:[AppDelegate instance].window];
	HUD.userInteractionEnabled = YES;
	HUD.mode = MBProgressHUDModeCustomView;
	HUD.dimBackground = YES;
	HUD.removeFromSuperViewOnHide = YES;
	HUD.showCloseButton = YES;

	_levelChooser = [ChooserViewController levelChooserWithTitle:@"Choose resonator level" completionHandler:^(int level) {
		[HUD hide:YES];
		[self deployResonatorOfLevel:level toSlot:sender.superview.tag];
		_levelChooser = nil;
	}];
	HUD.customView = _levelChooser.view;

	[[AppDelegate instance].window addSubview:HUD];
	[HUD show:YES];

}

- (void)deployResonatorOfLevel:(int)level toSlot:(int)slot {

	if ([_resonators[slot] isKindOfClass:[NSNull class]]) {

		Resonator *resonatorItem = [Resonator MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"dropped = NO && level = %d", level]];

		if (!resonatorItem) {
			[Utilities showWarningWithTitle:@"No resonator of that level remaining!"];
		} else {

			[[[GAI sharedInstance] defaultTracker] sendEventWithCategory:@"Game Action" withAction:@"Deploy Resonator" withLabel:self.portal.name withValue:@(resonatorItem.level)];

			MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:[AppDelegate instance].window];
			HUD.userInteractionEnabled = YES;
			HUD.dimBackground = YES;
			HUD.removeFromSuperViewOnHide = YES;
			HUD.labelFont = [UIFont fontWithName:[[[UILabel appearance] font] fontName] size:16];
			HUD.labelText = [NSString stringWithFormat:@"Deploying resonator of level: %d", level];
			[[AppDelegate instance].window addSubview:HUD];
			[HUD show:YES];

			@try {
				[[API sharedInstance] deployResonator:resonatorItem toPortal:self.portal toSlot:slot completionHandler:^(NSString *errorStr) {
					
					[HUD hide:YES];
					
					if (errorStr) {
						[Utilities showWarningWithTitle:errorStr];
					} else {
						
						dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^(void){
							[self refresh];
						});
						if ([[NSUserDefaults standardUserDefaults] boolForKey:DeviceSoundToggleEffects]) {
							[[SoundManager sharedManager] playSound:@"Sound/sfx_resonator_power_up.aif"];
						}
						if ([[NSUserDefaults standardUserDefaults] boolForKey:DeviceSoundToggleSpeech]) {
							[[API sharedInstance] playSounds:@[@"SPEECH_RESONATOR", @"SPEECH_DEPLOYED"]];
							if ([self.portal.resonators count] == 1) {
								[[API sharedInstance] playSounds:@[@"SPEECH_PORTAL", @"SPEECH_ONLINE", @"SPEECH_GOOD_WORK"]];
							}
						}
					}
					
				}];
			} @catch (NSException *exception) {
				[HUD hide:YES];
				
				[Utilities showWarningWithTitle:@"Application error"];
				[[[GAI sharedInstance] defaultTracker] sendException:NO withDescription:@"%@: %@", @"deployResonatorOfLevel", [exception reason]];
#if DEBUG
				NSLog(@"%@", [NSString stringWithFormat:@"Error %@: %@\n%@", @"deployResonatorOfLevel", [exception reason], [exception callStackSymbols]]);
#endif
			}
		}

	} else {

		Resonator *resonatorItem = [Resonator MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"dropped = NO && level = %d", level]];

		if (!resonatorItem) {

			[Utilities showWarningWithTitle:@"No resonator of that level remaining!"];

		} else {

			[[[GAI sharedInstance] defaultTracker] sendEventWithCategory:@"Game Action" withAction:@"Upgrade Resonator" withLabel:self.portal.name withValue:@(resonatorItem.level)];

			MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:[AppDelegate instance].window];
			HUD.userInteractionEnabled = YES;
			HUD.dimBackground = YES;
			HUD.removeFromSuperViewOnHide = YES;
			HUD.labelFont = [UIFont fontWithName:[[[UILabel appearance] font] fontName] size:16];
			HUD.labelText = [NSString stringWithFormat:@"Upgrading resonator to level: %d", level];
			[[AppDelegate instance].window addSubview:HUD];
			[HUD show:YES];

			[[API sharedInstance] upgradeResonator:resonatorItem toPortal:self.portal toSlot:slot completionHandler:^(NSString *errorStr) {
				[HUD hide:YES];

				if (errorStr) {
					[Utilities showWarningWithTitle:errorStr];
				} else {

					dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^(void){
						[self refresh];
					});
                    if ([[NSUserDefaults standardUserDefaults] boolForKey:DeviceSoundToggleEffects]) {
                        [[SoundManager sharedManager] playSound:@"Sound/sfx_resonator_power_up.aif"];
                    }
                    if ([[NSUserDefaults standardUserDefaults] boolForKey:DeviceSoundToggleSpeech]) {
                        [[API sharedInstance] playSounds:@[@"SPEECH_RESONATOR", @"SPEECH_UPGRADED"]];
                    }
				}

			}];

		}

	}

}

- (IBAction)rechargeButtonPressed:(GUIButton *)sender {

	MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:[AppDelegate instance].window];
	HUD.userInteractionEnabled = YES;
	HUD.mode = MBProgressHUDModeIndeterminate;
	HUD.dimBackground = YES;
	HUD.removeFromSuperViewOnHide = YES;
	HUD.labelFont = [UIFont fontWithName:[[[UILabel appearance] font] fontName] size:16];
	HUD.labelText = @"Recharging...";
	[[AppDelegate instance].window addSubview:HUD];
	[HUD show:YES];

	[[[GAI sharedInstance] defaultTracker] sendEventWithCategory:@"Game Action" withAction:@"Resonator Recharge" withLabel:self.portal.name withValue:@(sender.superview.tag)];

	[[API sharedInstance] rechargePortal:self.portal slots:@[@(sender.superview.tag)] completionHandler:^(NSString *errorStr) {

		[HUD hide:YES];

		if (errorStr) {
			[Utilities showWarningWithTitle:errorStr];
		} else {

			dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^(void){
				[self refresh];
			});
			if ([[NSUserDefaults standardUserDefaults] boolForKey:DeviceSoundToggleEffects]) {
                [[SoundManager sharedManager] playSound:@"Sound/sfx_resonator_recharge.aif"];
            }
            if ([[NSUserDefaults standardUserDefaults] boolForKey:DeviceSoundToggleSpeech]) {
                [[API sharedInstance] playSounds:@[@"SPEECH_RESONATOR", @"SPEECH_RECHARGED"]];
            }
		}

	}];
	
}

#pragma mark - Mods

- (IBAction)modButtonPressed:(GUIButton *)sender {

	if (sender.disabled) { return; }

	int slot = sender.tag-100;

	DeployedMod *mod = [DeployedMod MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"portal = %@ && slot = %d", self.portal, slot]];

	if (mod) {
		
		Player *player = [[API sharedInstance] playerForContext:[NSManagedObjectContext MR_contextForCurrentThread]];

		MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:[AppDelegate instance].window];
		HUD.userInteractionEnabled = YES;
		HUD.removeFromSuperViewOnHide = YES;
		HUD.mode = MBProgressHUDModeCustomView;
		HUD.dimBackground = YES;
		HUD.showCloseButton = YES;

		UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 180, 156)];

        GlowingLabel *label = [[GlowingLabel alloc] initWithFrame:CGRectMake(0, 0, 180, 112)];
        label.backgroundColor = [UIColor clearColor];
        label.textColor = [UIColor whiteColor];
		label.textAlignment = NSTextAlignmentCenter;
		label.font = [UIFont fontWithName:[[[UILabel appearance] font] fontName] size:18];
		label.minimumScaleFactor = .75;
		label.adjustsFontSizeToFitWidth = YES;
		label.numberOfLines = 0;
        [view addSubview:label];

		GUIButton *removeButton = [[GUIButton alloc] initWithFrame:CGRectMake(0, 112, 180, 44)];
		removeButton.titleLabel.font = [UIFont fontWithName:[[[UILabel appearance] font] fontName] size:20];
		[removeButton setTitle:@"Remove Mod" forState:UIControlStateNormal];
		if ([mod.owner.guid isEqualToString:player.guid]) {
            [removeButton handleControlEvent:UIControlEventTouchUpInside withBlock:^{
                [HUD hide:YES];
                [self removeModButtonPressed:removeButton];
            }];
		} else {
			[removeButton setEnabled:NO];
			[removeButton setErrorString:@"Not Owner"];
		}
        removeButton.tag = 100+slot;
        [view addSubview:removeButton];

		if ([mod isKindOfClass:[DeployedShield class]]) {
			DeployedShield *shield = (DeployedShield *)mod;
			label.text = [NSString stringWithFormat:@"%@ Shield\nMitigation +%d", shield.rarityStr, shield.mitigation];
		} else if ([mod isKindOfClass:[DeployedLinkAmp class]]) {
//			DeployedLinkAmp *linkAmp = (DeployedLinkAmp *)mod;
			label.text = [NSString stringWithFormat:@"%@ Link Amp", mod.rarityStr];
		} else if ([mod isKindOfClass:[DeployedForceAmp class]]) {
//			DeployedForceAmp *forceAmp = (DeployedForceAmp *)mod;
			label.text = [NSString stringWithFormat:@"%@ Force Amp", mod.rarityStr];
		} else if ([mod isKindOfClass:[DeployedHeatsink class]]) {
//			DeployedHeatsink *heatsink = (DeployedHeatsink *)mod;
			label.text = [NSString stringWithFormat:@"%@ Heat sink", mod.rarityStr];
		} else if ([mod isKindOfClass:[DeployedMultihack class]]) {
//			DeployedMultihack *multihack = (DeployedMultihack *)mod;
			label.text = [NSString stringWithFormat:@"%@ Multi-hack", mod.rarityStr];
		} else if ([mod isKindOfClass:[DeployedTurret class]]) {
//			DeployedTurret *turret = (DeployedTurret *)mod;
			label.text = [NSString stringWithFormat:@"%@ Turret", mod.rarityStr];
		} else {
			label.text = [NSString stringWithFormat:@"%@ Unknown Mod", mod.rarityStr];
		}

		HUD.customView = view;
		[[AppDelegate instance].window addSubview:HUD];
		[HUD show:YES];

		return;
	}

	MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:[AppDelegate instance].window];
	HUD.userInteractionEnabled = YES;
	HUD.removeFromSuperViewOnHide = YES;
	HUD.mode = MBProgressHUDModeCustomView;
	HUD.dimBackground = YES;
	HUD.showCloseButton = YES;
	
	_modChooser = [ChooserViewController modChooserWithTitle:@"Choose Mod" completionHandler:^(ItemType modType) {
		[HUD hide:YES];
		_modChooser = nil;

		__block MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:[AppDelegate instance].window];
		HUD.userInteractionEnabled = YES;
		HUD.removeFromSuperViewOnHide = NO;
		HUD.mode = MBProgressHUDModeCustomView;
		HUD.dimBackground = YES;
		HUD.showCloseButton = YES;
		_levelChooser = [ChooserViewController rarityChooserWithTitle:@"Choose Rarity" completionHandler:^(ItemRarity rarity) {
			[HUD hide:YES];
			[HUD removeFromSuperview];
			HUD = nil;
			_levelChooser = nil;
			[self deployMod:modType ofRarity:rarity toSlot:slot];
		}];
		HUD.customView = _levelChooser.view;
		[[AppDelegate instance].window addSubview:HUD];
		[HUD show:YES];
		
	}];
	HUD.customView = _modChooser.view;
	[[AppDelegate instance].window addSubview:HUD];
	[HUD show:YES];

}

- (void)deployMod:(ItemType)modType ofRarity:(ItemRarity)rarity toSlot:(int)slot {

	Class objectClass = [NSManagedObject class];
	switch (modType) {
		case ItemTypePortalShield:
			objectClass = [Shield class];
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
		default:
			objectClass = [Mod class];
			break;
	}

	Mod *modItem = [objectClass MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"dropped = NO && rarity = %d", rarity]];

	if (!modItem) {
		[Utilities showWarningWithTitle:@"No mod of that rarity remaining!"];
	} else {

		[[[GAI sharedInstance] defaultTracker] sendEventWithCategory:@"Game Action" withAction:@"Deploy Mod" withLabel:self.portal.name withValue:@(modItem.rarity)];

		if ([[NSUserDefaults standardUserDefaults] boolForKey:DeviceSoundToggleEffects]) {
			[[SoundManager sharedManager] playSound:@"Sound/sfx_mod_power_up.aif"];
		}

		MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:[AppDelegate instance].window];
		HUD.userInteractionEnabled = YES;
		HUD.dimBackground = YES;
		HUD.removeFromSuperViewOnHide = YES;
		HUD.detailsLabelFont = [UIFont fontWithName:[[[UILabel appearance] font] fontName] size:16];
		HUD.detailsLabelText = @"Deploying Mod...";
		[[AppDelegate instance].window addSubview:HUD];
		[HUD show:YES];

		[[API sharedInstance] addMod:modItem toItem:self.portal toSlot:slot completionHandler:^(NSString *errorStr) {

			[HUD hide:YES];

			if (errorStr) {
				[Utilities showWarningWithTitle:errorStr];
			} else {

				[self refresh];
                if ([[NSUserDefaults standardUserDefaults] boolForKey:DeviceSoundToggleSpeech]) {

					NSMutableArray *sounds = [NSMutableArray arrayWithCapacity:2];
					switch (modType) {
						case ItemTypePortalShield:
							[sounds addObject:@"SPEECH_SHIELD"];
							break;
						case ItemTypeForceAmp:
							[sounds addObject:@"SPEECH_FORCE_AMP"];
							break;
						case ItemTypeHeatsink:
							[sounds addObject:@"SPEECH_HEAT_SINK"];
							break;
						case ItemTypeLinkAmp:
							[sounds addObject:@"SPEECH_LINKAMP"];
							break;
						case ItemTypeMultihack:
							[sounds addObject:@"SPEECH_MULTI_HACK"];
							break;
						case ItemTypeTurret:
							[sounds addObject:@"SPEECH_TURRET"];
							break;
						default:
							[sounds addObject:@"SPEECH_UNKNOWN_TECH"];
							break;
					}
					[sounds addObject:@"SPEECH_DEPLOYED"];
					[[API sharedInstance] playSounds:sounds];

                }
			}
			
		}];
		
	}
	
}

- (IBAction)removeModButtonPressed:(GUIButton *)sender {

	MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:[AppDelegate instance].window];
	HUD.userInteractionEnabled = YES;
	HUD.dimBackground = YES;
	HUD.removeFromSuperViewOnHide = YES;
	HUD.detailsLabelFont = [UIFont fontWithName:[[[UILabel appearance] font] fontName] size:16];
	HUD.detailsLabelText = @"Removing Mod...";
	[[AppDelegate instance].window addSubview:HUD];
	[HUD show:YES];

	[[API sharedInstance] removeModFromItem:self.portal atSlot:sender.tag-100 completionHandler:^(NSString *errorStr) {

		[HUD hide:YES];

		if (errorStr) {
			[Utilities showWarningWithTitle:errorStr];
		}
        
        [self refresh];

	}];

}

@end

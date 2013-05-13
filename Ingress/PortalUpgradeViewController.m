//
//  PortalUpgradeViewController.m
//  Ingress
//
//  Created by Alex Studnicka on 20.01.13.
//  Copyright (c) 2013 A&A Code. All rights reserved.
//

#import "PortalUpgradeViewController.h"

@implementation PortalUpgradeViewController

@synthesize portal = _portal;

- (void)viewDidLoad {
	[super viewDidLoad];

}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];

	[self refresh];

}

#pragma mark - Refresh

- (void)refresh {

	NSMutableArray *tmpResonators = [NSMutableArray arrayWithCapacity:8];
	
	for (int i = 0; i < 8; i++) {
		
		UILabel *levelLabel = (UILabel *)[self.view viewWithTag:10+i];
		levelLabel.font = [UIFont fontWithName:[[[UILabel appearance] font] fontName] size:14];
		levelLabel.text = @"";
		
		UIImageView *resonatorImage = (UIImageView *)[self.view viewWithTag:30+i];
		[resonatorImage setHidden:YES];
		
		UIImageView *progressView = (UIImageView *)[self.view viewWithTag:40+i];
		if ([self.portal.controllingTeam isEqualToString:@"ALIENS"]) {
			progressView.image = [UIImage imageNamed:@"enl_res_energy_fill.png"];
		} else {
			progressView.image = [UIImage imageNamed:@"hum_res_energy_fill.png"];
		}
		CGRect rect = progressView.frame;
		rect.size.height = 0;
		if (i == 0 || i == 1 || i == 6 || i == 7) {
			rect.origin.y = 0;
		} else {
			rect.origin.y = 188;
		}
		progressView.frame = rect;
		[progressView setHidden:YES];
		
		UIButton *button = (UIButton *)[self.view viewWithTag:50+i];
		if (self.portal.controllingTeam && ([self.portal.controllingTeam isEqualToString:[API sharedInstance].playerInfo[@"team"]] || [self.portal.controllingTeam isEqualToString:@"NEUTRAL"])) {
			button.titleLabel.font = [UIFont fontWithName:[[[UIButton appearance] font] fontName] size:10];
			[button setTitle:@"DEPLOY" forState:UIControlStateNormal];
			tmpResonators[i] = @0;
		} else {
			[button setHidden:YES];
		}
		
	}
	
	for (int i = 0; i < 4; i++) {
		
		UIButton *button = (UIButton *)[self.view viewWithTag:100+i];
		
		button.titleLabel.numberOfLines = 0;
		button.titleLabel.font = [UIFont fontWithName:[[[UIButton appearance] font] fontName] size:10];

		DeployedMod *mod = [DeployedMod MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"portal = %@ && slot = %d", self.portal, i]];
		
		if ([mod isKindOfClass:[DeployedShield class]]) {
			[button setTitle:[[(DeployedShield *)mod rarityStr] stringByAppendingString:@"\nShield"] forState:UIControlStateNormal];
		} else {
			[button setTitle:@"-" forState:UIControlStateNormal];
		}

		if (self.portal.controllingTeam && ([self.portal.controllingTeam isEqualToString:[API sharedInstance].playerInfo[@"team"]] || [self.portal.controllingTeam isEqualToString:@"NEUTRAL"])) {
			[button setEnabled:YES];
		} else {
			[button setEnabled:NO];
		}
		
	}
	
	for (DeployedResonator *resonator in self.portal.resonators) {
		
		if (![resonator isKindOfClass:[NSNull class]]) {
			
			int slot = resonator.slot;
			int level = resonator.level;
			float energy = resonator.energy;
			float maxEnergy = (float)[API maxEnergyForResonatorLevel:level];
			
			UILabel *levelLabel = (UILabel *)[self.view viewWithTag:10+slot];
			levelLabel.text = [NSString stringWithFormat:@"L%d", level];
			levelLabel.textColor = [API colorForLevel:level];

			UIImageView *resonatorImage = (UIImageView *)[self.view viewWithTag:30+slot];
			[resonatorImage setHidden:NO];
			
			UIImageView *progressView = (UIImageView *)[self.view viewWithTag:40+slot];
			[progressView setHidden:NO];
			CGRect rect = progressView.frame;
			rect.size.height = (energy/maxEnergy) * 44;
			if (slot >= 1 && slot <= 4) {
				rect.origin.y = 0 + (44 - rect.size.height);
			} else {
				rect.origin.y = 188 + (44 - rect.size.height);
			}
			progressView.frame = rect;
			
			if ([self.portal.controllingTeam isEqualToString:[API sharedInstance].playerInfo[@"team"]]) {
				UIButton *button = (UIButton *)[self.view viewWithTag:50+slot];
				[button setTitle:@"UPGRADE" forState:UIControlStateNormal];
				tmpResonators[slot] = @1;
			}
			
		}
		
	}
	
	_resonators = tmpResonators;
	
}

#pragma mark - Resonators

- (IBAction)resonatorButtonPressed:(GUIButton *)sender {
	
	if (sender.disabled) { return; }

	MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:[AppDelegate instance].window];
	HUD.userInteractionEnabled = YES;
	HUD.mode = MBProgressHUDModeCustomView;
	HUD.dimBackground = YES;
	HUD.showCloseButton = YES;
	
	_levelChooser = [LevelChooserViewController levelChooserWithTitle:@"Choose resonator level" completionHandler:^(int level) {
		[HUD hide:YES];
		[self deployResonatorOfLevel:level toSlot:sender.tag-50];
		_levelChooser = nil;
	}];
	HUD.customView = _levelChooser.view;
	
	[[AppDelegate instance].window addSubview:HUD];
	[HUD show:YES];
	
}

- (void)deployResonatorOfLevel:(int)level toSlot:(int)slot {

	[[SoundManager sharedManager] playSound:@"Sound/sfx_resonator_power_up.aif"];
	
	if ([_resonators[slot] intValue] == 0) {

		Resonator *resonatorItem = [Resonator MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"dropped = NO && level = %d", level]];
		
		if (!resonatorItem) {

			MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:[AppDelegate instance].window];
			HUD.userInteractionEnabled = YES;
			HUD.dimBackground = YES;
			HUD.mode = MBProgressHUDModeCustomView;
			HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"warning.png"]];
			HUD.detailsLabelFont = [UIFont fontWithName:[[[UILabel appearance] font] fontName] size:16];
			HUD.detailsLabelText = @"No resonator of that level remaining!";
			[[AppDelegate instance].window addSubview:HUD];
			[HUD show:YES];
			[HUD hide:YES afterDelay:3];

		} else {

			MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:[AppDelegate instance].window];
			HUD.userInteractionEnabled = YES;
			HUD.dimBackground = YES;
			HUD.labelFont = [UIFont fontWithName:[[[UILabel appearance] font] fontName] size:16];
			HUD.labelText = [NSString stringWithFormat:@"Deploying resonator of level: %d", level];
			[[AppDelegate instance].window addSubview:HUD];
			[HUD show:YES];

			[[API sharedInstance] deployResonator:resonatorItem toPortal:self.portal toSlot:slot completionHandler:^(NSString *errorStr) {

				[HUD hide:YES];

				if (errorStr) {
					MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:[AppDelegate instance].window];
					HUD.userInteractionEnabled = YES;
					HUD.dimBackground = YES;
					HUD.mode = MBProgressHUDModeCustomView;
					HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"warning.png"]];
					HUD.detailsLabelFont = [UIFont fontWithName:[[[UILabel appearance] font] fontName] size:16];
					HUD.detailsLabelText = errorStr;
					[[AppDelegate instance].window addSubview:HUD];
					[HUD show:YES];
					[HUD hide:YES afterDelay:3];
				} else {

					[self refresh];

					[[API sharedInstance] playSounds:@[@"SPEECH_RESONATOR", @"SPEECH_DEPLOYED"]];

					if ([self.portal.resonators count] == 1) {
						[[API sharedInstance] playSounds:@[@"SPEECH_PORTAL", @"SPEECH_ONLINE", @"SPEECH_GOOD_WORK"]];
					}
					
				}
				
			}];

		}
		
	} else if ([_resonators[slot] intValue] == 1) {
		
		Resonator *resonatorItem = [Resonator MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"dropped = NO && level = %d", level]];
		
		if (!resonatorItem) {

			MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:[AppDelegate instance].window];
			HUD.userInteractionEnabled = YES;
			HUD.dimBackground = YES;
			HUD.mode = MBProgressHUDModeCustomView;
			HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"warning.png"]];
			HUD.detailsLabelFont = [UIFont fontWithName:[[[UILabel appearance] font] fontName] size:16];
			HUD.detailsLabelText = @"No resonator of that level remaining!";
			[[AppDelegate instance].window addSubview:HUD];
			[HUD show:YES];
			[HUD hide:YES afterDelay:3];

		} else {

			MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:[AppDelegate instance].window];
			HUD.userInteractionEnabled = YES;
			HUD.dimBackground = YES;
			HUD.labelFont = [UIFont fontWithName:[[[UILabel appearance] font] fontName] size:16];
			HUD.labelText = [NSString stringWithFormat:@"Upgrading resonator to level: %d", level];
			[[AppDelegate instance].window addSubview:HUD];
			[HUD show:YES];

			[[API sharedInstance] upgradeResonator:resonatorItem toPortal:self.portal toSlot:slot completionHandler:^(NSString *errorStr) {
				[HUD hide:YES];

				if (errorStr) {
					MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:[AppDelegate instance].window];
					HUD.userInteractionEnabled = YES;
					HUD.dimBackground = YES;
					HUD.mode = MBProgressHUDModeCustomView;
					HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"warning.png"]];
					HUD.detailsLabelFont = [UIFont fontWithName:[[[UILabel appearance] font] fontName] size:16];
					HUD.detailsLabelText = errorStr;
					[[AppDelegate instance].window addSubview:HUD];
					[HUD show:YES];
					[HUD hide:YES afterDelay:3];
				} else {

					[self refresh];

					[[API sharedInstance] playSounds:@[@"SPEECH_RESONATOR", @"SPEECH_UPGRADED"]];
					
				}
				
			}];

		}

	}
	
}

#pragma mark - Shields

- (IBAction)shieldButtonPressed:(GUIButton *)sender {
	
	if (sender.disabled) { return; }
	
	MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:[AppDelegate instance].window];
	HUD.userInteractionEnabled = YES;
	HUD.mode = MBProgressHUDModeCustomView;
	HUD.dimBackground = YES;
	HUD.showCloseButton = YES;

	_levelChooser = [LevelChooserViewController rarityChooserWithTitle:@"Choose shield rarity" completionHandler:^(PortalShieldRarity rarity) {
		[HUD hide:YES];
		[self deployShieldOfRarity:rarity toSlot:sender.tag-100];
		_levelChooser = nil;
	}];
	HUD.customView = _levelChooser.view;
	
	[[AppDelegate instance].window addSubview:HUD];
	[HUD show:YES];
	
}

- (void)deployShieldOfRarity:(PortalShieldRarity)rarity toSlot:(int)slot {
	
	[[SoundManager sharedManager] playSound:@"Sound/sfx_mod_power_up.aif"];

	Shield *shieldItem = [Shield MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"dropped = NO && rarity = %d", rarity]];
	
	if (!shieldItem) {
		
		MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:[AppDelegate instance].window];
		HUD.userInteractionEnabled = YES;
		HUD.dimBackground = YES;
		HUD.mode = MBProgressHUDModeCustomView;
		HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"warning.png"]];
		HUD.detailsLabelFont = [UIFont fontWithName:[[[UILabel appearance] font] fontName] size:16];
		HUD.detailsLabelText = @"No shield of that rarity remaining!";
		[[AppDelegate instance].window addSubview:HUD];
		[HUD show:YES];
		[HUD hide:YES afterDelay:3];
		
	} else {
		
		MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:[AppDelegate instance].window];
		HUD.userInteractionEnabled = YES;
		HUD.dimBackground = YES;
		HUD.detailsLabelFont = [UIFont fontWithName:[[[UILabel appearance] font] fontName] size:16];
		HUD.detailsLabelText = @"Deploying shield...";
		[[AppDelegate instance].window addSubview:HUD];
		[HUD show:YES];

		[[API sharedInstance] addMod:shieldItem toItem:self.portal toSlot:slot completionHandler:^(NSString *errorStr) {

			[HUD hide:YES];

			if (errorStr) {
				MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:[AppDelegate instance].window];
				HUD.userInteractionEnabled = YES;
				HUD.dimBackground = YES;
				HUD.mode = MBProgressHUDModeCustomView;
				HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"warning.png"]];
				HUD.detailsLabelFont = [UIFont fontWithName:[[[UILabel appearance] font] fontName] size:16];
				HUD.detailsLabelText = errorStr;
				[[AppDelegate instance].window addSubview:HUD];
				[HUD show:YES];
				[HUD hide:YES afterDelay:3];
			} else {

				[self refresh];

				[[API sharedInstance] playSounds:@[@"SPEECH_SHIELD", @"SPEECH_DEPLOYED"]];
				
			}
			
		}];
		
	}
		
}

@end

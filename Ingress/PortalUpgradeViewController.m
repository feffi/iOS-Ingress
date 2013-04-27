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
	
//	[[NSNotificationCenter defaultCenter] addObserverForName:@"PortalChanged" object:nil queue:[API sharedInstance].notificationQueue usingBlock:^(NSNotification *note) {
//		Portal *newPortal = note.userInfo[@"portal"];
//		if (newPortal && self.portal && [newPortal isKindOfClass:[Portal class]] && [newPortal.guid isEqualToString:self.portal.guid]) {
//			self.portal= note.userInfo[@"portal"];
//		}
//	}];

}

- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
	
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setPortal:(Portal *)portal {
	_portal = portal;
	
	dispatch_async(dispatch_get_main_queue(), ^{
		[self refresh];
	});
}

#pragma mark - Refresh

- (void)refresh {

	NSMutableArray *tmpResonators = [NSMutableArray arrayWithCapacity:8];
	
	for (int i = 0; i < 8; i++) {
		
		UILabel *levelLabel = (UILabel *)[self.view viewWithTag:10+i];
		levelLabel.font = [UIFont fontWithName:@"Coda-Regular" size:14];
		levelLabel.text = @"";
		
		//		UIProgressView *progressIndicator = (UIProgressView *)[self.view viewWithTag:20+i];
		//		if ([self.portalItem.controllingTeam isEqualToString:@"ALIENS"]) {
		//			progressIndicator.progressTintColor = [UIColor colorWithRed:40./255. green:244./255. blue:40./255. alpha:1];
		//		} else {
		//			progressIndicator.progressTintColor = [UIColor colorWithRed:0 green:194./255. blue:1 alpha:1];
		//		}
		//		[progressIndicator setHidden:YES];
		
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
			button.titleLabel.font = [UIFont fontWithName:@"Coda-Regular" size:10];
			[button setTitle:@"DEPLOY" forState:UIControlStateNormal];
			tmpResonators[i] = @0;
		} else {
			[button setHidden:YES];
		}
		
	}
	
	for (int i = 0; i < 4; i++) {
		
		UIButton *button = (UIButton *)[self.view viewWithTag:100+i];
		
		button.titleLabel.numberOfLines = 0;
		button.titleLabel.font = [UIFont fontWithName:@"Coda-Regular" size:10];

		DeployedShield *shield = (DeployedShield *)[[DB sharedInstance] deployedModPortal:self.portal ofClass:@"DeployedShield" atSlot:i shouldCreate:NO];
		
		if (shield) {
			[button setTitle:[shield.rarityStr stringByAppendingString:@"\nShield"] forState:UIControlStateNormal];
		} else {
			[button setTitle:@"-" forState:UIControlStateNormal];
		}
		
		if (!self.portal.controllingTeam || ![self.portal.controllingTeam isEqualToString:[API sharedInstance].playerInfo[@"team"]]) {
			[button setEnabled:NO];
		} else {
			[button setEnabled:YES];
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
			
			//			UIProgressView *progressIndicator = (UIProgressView *)[self.view viewWithTag:20+slot];
			//			[progressIndicator setHidden:NO];
			//			[progressIndicator setProgress:energy/maxEnergy];
			
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
			
			if ([self.portal.controllingTeam isEqualToString:[API sharedInstance].playerInfo[@"team"]]) {			UIButton *button = (UIButton *)[self.view viewWithTag:50+slot];
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
		
		MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:[AppDelegate instance].window];
		HUD.userInteractionEnabled = YES;
		HUD.dimBackground = YES;
		HUD.labelFont = [UIFont fontWithName:@"Coda-Regular" size:16];
		HUD.labelText = [NSString stringWithFormat:@"Deploying resonator of level: %d", level];
		[[AppDelegate instance].window addSubview:HUD];
		[HUD show:YES];
		
		Resonator *resonatorItem = [[DB sharedInstance] getRandomResonatorOfLevel:level];
		
		if (!resonatorItem) {
			NSLog(@"No resonator of that level remaining!");
			return;
		}
		
		[[API sharedInstance] deployResonator:resonatorItem toPortal:self.portal toSlot:slot completionHandler:^(NSString *errorStr) {
			
			[HUD hide:YES];

			if (errorStr) {
				MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:[AppDelegate instance].window];
				HUD.userInteractionEnabled = YES;
				HUD.dimBackground = YES;
				HUD.mode = MBProgressHUDModeCustomView;
				HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"warning.png"]];
				HUD.detailsLabelFont = [UIFont fontWithName:@"Coda-Regular" size:16];
				HUD.detailsLabelText = errorStr;
				[[AppDelegate instance].window addSubview:HUD];
				[HUD show:YES];
				[HUD hide:YES afterDelay:3];
			} else {
				
				[[SoundManager sharedManager] playSound:@"Sound/speech_resonator.aif"];
				
				dispatch_after(dispatch_time(DISPATCH_TIME_NOW, .75 * NSEC_PER_SEC), dispatch_get_main_queue(), ^(void){
					[[SoundManager sharedManager] playSound:@"Sound/speech_deployed.aif"];
				});
				
			}
			
		}];
		
	} else if ([_resonators[slot] intValue] == 1) {
		
		MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:[AppDelegate instance].window];
		HUD.userInteractionEnabled = YES;
		HUD.dimBackground = YES;
		HUD.labelFont = [UIFont fontWithName:@"Coda-Regular" size:16];
		HUD.labelText = [NSString stringWithFormat:@"Upgrading resonator to level: %d", level];
		[[AppDelegate instance].window addSubview:HUD];
		[HUD show:YES];
		
		Resonator *resonatorItem = [[DB sharedInstance] getRandomResonatorOfLevel:level];
		
		if (!resonatorItem) {
			NSLog(@"No resonator of that level remaining!");
			return;
		}
		
		[[API sharedInstance] upgradeResonator:resonatorItem toPortal:self.portal toSlot:slot completionHandler:^(NSString *errorStr) {
			[HUD hide:YES];
			
			if (errorStr) {
				MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:[AppDelegate instance].window];
				HUD.userInteractionEnabled = YES;
				HUD.dimBackground = YES;
				HUD.mode = MBProgressHUDModeCustomView;
				HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"warning.png"]];
				HUD.detailsLabelFont = [UIFont fontWithName:@"Coda-Regular" size:16];
				HUD.detailsLabelText = errorStr;
				[[AppDelegate instance].window addSubview:HUD];
				[HUD show:YES];
				[HUD hide:YES afterDelay:3];
			} else {

				[[SoundManager sharedManager] playSound:@"Sound/speech_resonator.aif"];
				
				dispatch_after(dispatch_time(DISPATCH_TIME_NOW, .75 * NSEC_PER_SEC), dispatch_get_main_queue(), ^(void){
					[[SoundManager sharedManager] playSound:@"Sound/speech_upgraded.aif"];
				});
				
			}
			
		}];
		
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
	
	MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:[AppDelegate instance].window];
	HUD.userInteractionEnabled = YES;
	HUD.dimBackground = YES;
	HUD.detailsLabelFont = [UIFont fontWithName:@"Coda-Regular" size:16];
	HUD.detailsLabelText = @"Deploying shield...";
	[[AppDelegate instance].window addSubview:HUD];
	[HUD show:YES];
	
	Shield *shieldItem = [[DB sharedInstance] getRandomShieldOfRarity:rarity];
	
	if (!shieldItem) {
		NSLog(@"No shield of that rarity remaining!");
		return;
	}
	
	[[API sharedInstance] addMod:shieldItem toItem:self.portal toSlot:slot completionHandler:^(NSString *errorStr) {
		
		[HUD hide:YES];
		
		if (errorStr) {
			MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:[AppDelegate instance].window];
			HUD.userInteractionEnabled = YES;
			HUD.dimBackground = YES;
			HUD.mode = MBProgressHUDModeCustomView;
			HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"warning.png"]];
			HUD.detailsLabelFont = [UIFont fontWithName:@"Coda-Regular" size:16];
			HUD.detailsLabelText = errorStr;
			[[AppDelegate instance].window addSubview:HUD];
			[HUD show:YES];
			[HUD hide:YES afterDelay:3];
		} else {
			
			[[API sharedInstance] playSounds:@[@"SPEECH_SHIELD", @"SPEECH_DEPLOYED"]];
			
		}
		
	}];
		
}

@end

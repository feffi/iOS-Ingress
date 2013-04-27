//
//  PortalInfoViewController.m
//  Ingress
//
//  Created by Alex Studnicka on 20.01.13.
//  Copyright (c) 2013 A&A Code. All rights reserved.
//

#import "PortalInfoViewController.h"

@implementation PortalInfoViewController

@synthesize portal = _portal;

- (void)viewDidLoad {
	[super viewDidLoad];
	
	portalTitleLabel.font = [UIFont fontWithName:@"Coda-Regular" size:18];
	
	infoLabel1.font = [UIFont fontWithName:@"Coda-Regular" size:14];
	infoLabel2.font = [UIFont fontWithName:@"Coda-Regular" size:14];
	
	hackButton.titleLabel.font = [UIFont fontWithName:@"Coda-Regular" size:16];
	rechargeButton.titleLabel.font = [UIFont fontWithName:@"Coda-Regular" size:16];
	linkButton.titleLabel.font = [UIFont fontWithName:@"Coda-Regular" size:16];

}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
//	[[NSNotificationCenter defaultCenter] addObserverForName:@"PortalChanged" object:nil queue:[API sharedInstance].notificationQueue usingBlock:^(NSNotification *note) {
//		Portal *newPortal = note.userInfo[@"portal"];
//		if (newPortal && [newPortal isKindOfClass:[PortalItem class]] && [newPortal.guid isEqualToString:self.portal.guid]) {
//			self.portal = note.userInfo[@"portal"];
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
	
	[imageActivityIndicator stopAnimating];

	if (self.portal.imageData) {
		
	} else {
		self.imageView.image = [UIImage imageNamed:@"missing_image"];
	}
	
//	[imageActivityIndicator startAnimating];
//	NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:self.portal.imageURL]];
//	[NSURLConnection sendAsynchronousRequest:request queue:[API sharedInstance].networkQueue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
//		dispatch_async(dispatch_get_main_queue(), ^{
//			[imageActivityIndicator stopAnimating];
//			imageView.image = [UIImage imageWithData:data];
//		});
//	}];
	
	portalTitleLabel.text = self.portal.subtitle;

	NSMutableString *str = [NSMutableString string];
	
	[str appendFormat:@"Level: L%d\n", self.portal.level];
	
	//int part1len = str.length;
	
	User *user = nil;
//	User *user = [[DB sharedInstance] userWhoCapturedPortal:self.portal];
	NSString *nickname = user.nickname;
	if (!nickname) { nickname = [API factionStrForFaction:self.portal.controllingTeam]; }
	[str appendFormat:@"%@", nickname];

	NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:str];

	[attrStr setAttributes:@{NSFontAttributeName: [UIFont fontWithName:@"Coda-Regular" size:15], NSForegroundColorAttributeName : [UIColor colorWithRed:.56 green:1 blue:1 alpha:1]} range:NSMakeRange(0, str.length)];
	[attrStr setAttributes:@{NSFontAttributeName: [UIFont fontWithName:@"Coda-Regular" size:16], NSForegroundColorAttributeName : [API colorForLevel:self.portal.level]} range:NSMakeRange(7, 2)];
	[attrStr setAttributes:@{NSFontAttributeName: [UIFont fontWithName:@"Coda-Regular" size:16], NSForegroundColorAttributeName : [API colorForFaction:self.portal.controllingTeam]} range:NSMakeRange(str.length-(nickname.length), nickname.length)];

	infoLabel1.attributedText = attrStr;

	////////////////////////////

	infoLabel2.text = [NSString stringWithFormat:@"Energy: %.1fk\nRange: %.1fkm", self.portal.energy/1000., self.portal.range/1000.];
	
//	attrStr = [[NSMutableAttributedString alloc] initWithString:str];
//	[attrStr setAttributes:@{NSFontAttributeName: [UIFont fontWithName:@"Coda-Regular" size:15], NSForegroundColorAttributeName : [UIColor colorWithRed:.56 green:1 blue:1 alpha:1]} range:NSMakeRange(0, str.length)];
//	//[attrStr setAttributes:@{NSFontAttributeName: [UIFont fontWithName:@"Coda-Regular" size:16], NSForegroundColorAttributeName : [API colorForFaction:self.portal.controllingTeam]} range:NSMakeRange(part1len+7, attrStr.length-(7+part1len))];
//	infoLabel2.attributedText = attrStr;
	
	////////////////////////////
	
	if (self.portal.controllingTeam && [self.portal.controllingTeam isEqualToString:[API sharedInstance].playerInfo[@"team"]]) {
		rechargeButton.enabled = YES;
		linkButton.enabled = YES;
	} else {
		rechargeButton.enabled = NO;
		linkButton.enabled = NO;
	}
	
}

#pragma mark - Actions

- (IBAction)hack:(GUIButton *)sender {
	
	if (sender.disabled) { return; }
	
	__block MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:[AppDelegate instance].window];
	HUD.userInteractionEnabled = YES;
	HUD.mode = MBProgressHUDModeIndeterminate;
	HUD.dimBackground = YES;
	HUD.labelFont = [UIFont fontWithName:@"Coda-Regular" size:16];
	HUD.labelText = @"Hacking...";
	[[AppDelegate instance].window addSubview:HUD];
	[HUD show:YES];
	
	if ([self.portal.controllingTeam isEqualToString:@"ALIENS"]) {
		[[SoundManager sharedManager] playSound:@"Sound/sfx_portal_hacking_alien.aif"];
	} else if ([self.portal.controllingTeam isEqualToString:@"RESISTANCE"]) {
		[[SoundManager sharedManager] playSound:@"Sound/sfx_portal_hacking_human.aif"];
	} else {
		[[SoundManager sharedManager] playSound:@"Sound/sfx_portal_hacking_neutral.aif"];
	}
	
	[[API sharedInstance] hackPortal:self.portal completionHandler:^(NSString *errorStr, NSArray *acquiredItems, int secondsRemaining) {
		
		[HUD hide:YES];
		
		HUD = [[MBProgressHUD alloc] initWithView:[AppDelegate instance].window];
		HUD.userInteractionEnabled = YES;
		HUD.dimBackground = YES;
		HUD.labelFont = [UIFont fontWithName:@"Coda-Regular" size:16];
		HUD.detailsLabelFont = [UIFont fontWithName:@"Coda-Regular" size:12];
		//HUD.showCloseButton = YES;
		
		if (errorStr) {
			HUD.mode = MBProgressHUDModeCustomView;
			HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"warning.png"]];
			HUD.detailsLabelFont = [UIFont fontWithName:@"Coda-Regular" size:16];
			HUD.detailsLabelText = errorStr;

			NSMutableArray *sounds = [NSMutableArray arrayWithObjects:@"SPEECH_HACKING", @"SPEECH_UNSUCCESSFUL", nil];

			if (secondsRemaining > 0) {
				[sounds addObject:@"SPEECH_COOLDOWN_ACTIVE"];
			}

			if (secondsRemaining == 300) {
				[sounds addObject:@"SPEECH_NUMBER_005"];
				[sounds addObject:@"SPEECH_MINUTES"];
				[sounds addObject:@"SPEECH_REMAINING"];
			}

			[[API sharedInstance] playSounds:sounds];
		} else {
			HUD.mode = MBProgressHUDModeText;
			if (acquiredItems.count > 0) {

				[[SoundManager sharedManager] playSound:@"Sound/sfx_resource_pick_up.aif"];
				
				NSMutableString *acquiredItemsStr = [NSMutableString string];
				
				for (NSString *GUID in acquiredItems) {
					[acquiredItemsStr appendFormat:@"%@\n", [[DB sharedInstance] getItemWithGuid:GUID]];
				}
				
				HUD.labelText = @"Items acquired";
				HUD.detailsLabelText = acquiredItemsStr;
				
			} else {
				HUD.labelText = @"Hack acquired no items";
				
				[[API sharedInstance] playSounds:@[@"SPEECH_HACKING", @"SPEECH_UNSUCCESSFUL"]];
			}
		}
		
		[[AppDelegate instance].window addSubview:HUD];
		[HUD show:YES];
		[HUD hide:YES afterDelay:3];
		
	}];
	
}

- (IBAction)recharge:(GUIButton *)sender {
	
	if (sender.disabled) { return; }
	
	__block MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:[AppDelegate instance].window];
	HUD.userInteractionEnabled = YES;
	HUD.mode = MBProgressHUDModeIndeterminate;
	HUD.dimBackground = YES;
	HUD.labelFont = [UIFont fontWithName:@"Coda-Regular" size:16];
	HUD.labelText = @"Recharging...";
	[[AppDelegate instance].window addSubview:HUD];
	[HUD show:YES];
	
	[[SoundManager sharedManager] playSound:@"Sound/sfx_resonator_recharge.aif"];
	
	[[API sharedInstance] rechargePortal:self.portal completionHandler:^() {
		
		[HUD hide:YES];
		
		[[SoundManager sharedManager] playSound:@"Sound/speech_resonator.aif"];
		
		dispatch_after(dispatch_time(DISPATCH_TIME_NOW, .75 * NSEC_PER_SEC), dispatch_get_main_queue(), ^(void){
			[[SoundManager sharedManager] playSound:@"Sound/speech_recharged.aif"];
		});
		
	}];
	
}

- (IBAction)link:(GUIButton *)sender {
	
	if (sender.disabled) { return; }
	
	[self performSegueWithIdentifier:@"PortalLinkPushKeysSegue" sender:self];
	
}

@end

//
//  PortalInfoViewController.m
//  Ingress
//
//  Created by Alex Studnicka on 20.01.13.
//  Copyright (c) 2013 A&A Code. All rights reserved.
//

#import "PortalActionsViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "PortalKeysViewController.h"
#import "NSShadow+Initilalizer.h"

@implementation PortalActionsViewController

@synthesize portal = _portal;

- (void)viewDidLoad {
	[super viewDidLoad];
	
	portalTitleLabel.font = [UIFont fontWithName:[[[UILabel appearance] font] fontName] size:18];
	
	infoLabel1.font = [UIFont fontWithName:[[[UILabel appearance] font] fontName] size:15];
	infoLabel2.font = [UIFont fontWithName:[[[UILabel appearance] font] fontName] size:15];
	
	hackButton.titleLabel.font = [UIFont fontWithName:[[[UIButton appearance] font] fontName] size:16];
	rechargeButton.titleLabel.font = [UIFont fontWithName:[[[UIButton appearance] font] fontName] size:16];
	linkButton.titleLabel.font = [UIFont fontWithName:[[[UIButton appearance] font] fontName] size:16];

	self.imageView.image = [UIImage imageNamed:@"missing_image"];

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

	[self.imageView setImageWithURL:[NSURL URLWithString:self.portal.imageURL] placeholderImage:[UIImage imageNamed:@"missing_image"]];
	
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
	
	User *user = self.portal.capturedBy;
	NSString *nickname = user.nickname;
	if (!nickname) { nickname = [API factionStrForFaction:self.portal.controllingTeam]; }
	[str appendFormat:@"Owner: %@", nickname];

	NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:str];

	NSShadow *shadow = [NSShadow shadowWithOffset:CGSizeZero blurRadius:15/5 color:[UIColor colorWithRed:.56 green:1 blue:1 alpha:1]];
	[attrStr setAttributes:@{NSFontAttributeName: [UIFont fontWithName:[[[UILabel appearance] font] fontName] size:15], NSForegroundColorAttributeName : [UIColor colorWithRed:.56 green:1 blue:1 alpha:1], NSShadowAttributeName: shadow} range:NSMakeRange(0, str.length)];

	shadow = [NSShadow shadowWithOffset:CGSizeZero blurRadius:15/5 color:[API colorForLevel:self.portal.level]];
	[attrStr setAttributes:@{NSFontAttributeName: [UIFont fontWithName:[[[UILabel appearance] font] fontName] size:15], NSForegroundColorAttributeName : [API colorForLevel:self.portal.level], NSShadowAttributeName: shadow} range:NSMakeRange(7, 2)];

	shadow = [NSShadow shadowWithOffset:CGSizeZero blurRadius:15/5 color:[API colorForFaction:self.portal.controllingTeam]];
	[attrStr setAttributes:@{NSFontAttributeName: [UIFont fontWithName:[[[UILabel appearance] font] fontName] size:15], NSForegroundColorAttributeName : [API colorForFaction:self.portal.controllingTeam], NSShadowAttributeName: shadow} range:NSMakeRange(str.length-(nickname.length), nickname.length)];

	infoLabel1.attributedText = attrStr;

	////////////////////////////

	infoLabel2.text = [NSString stringWithFormat:@"Energy: %.1fk\nRange: %.1fkm", self.portal.energy/1000., self.portal.range/1000.];
	
//	attrStr = [[NSMutableAttributedString alloc] initWithString:str];
//	[attrStr setAttributes:@{NSFontAttributeName: [UIFont fontWithName:[[[UILabel appearance] font] fontName] size:15], NSForegroundColorAttributeName : [UIColor colorWithRed:.56 green:1 blue:1 alpha:1]} range:NSMakeRange(0, str.length)];
//	//[attrStr setAttributes:@{NSFontAttributeName: [UIFont fontWithName:[[[UILabel appearance] font] fontName] size:16], NSForegroundColorAttributeName : [API colorForFaction:self.portal.controllingTeam]} range:NSMakeRange(part1len+7, attrStr.length-(7+part1len))];
//	infoLabel2.attributedText = attrStr;
	
	////////////////////////////
	
	if (self.portal.controllingTeam && [self.portal.controllingTeam isEqualToString:[API sharedInstance].player.team]) {
		rechargeButton.enabled = YES;
		linkButton.enabled = YES;
		rechargeButton.errorString = nil;
		linkButton.errorString = nil;
	} else {
		rechargeButton.enabled = NO;
		linkButton.enabled = NO;

		if ([self.portal.controllingTeam isEqualToString:@"NEUTRAL"]) {
			rechargeButton.errorString = @"Neutral Portal";
			linkButton.errorString = @"Neutral Portal";
		} else {
			rechargeButton.errorString = @"Enemy Portal";
			linkButton.errorString = @"Enemy Portal";
		}
	}
	
}

#pragma mark - Actions

- (IBAction)hack:(GUIButton *)sender {
	
	if (sender.disabled) { return; }
	
	__block MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:[AppDelegate instance].window];
	HUD.userInteractionEnabled = YES;
	HUD.mode = MBProgressHUDModeIndeterminate;
	HUD.dimBackground = YES;
	HUD.labelFont = [UIFont fontWithName:[[[UILabel appearance] font] fontName] size:16];
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
		HUD.labelFont = [UIFont fontWithName:[[[UILabel appearance] font] fontName] size:16];
		HUD.detailsLabelFont = [UIFont fontWithName:[[[UILabel appearance] font] fontName] size:12];
		//HUD.showCloseButton = YES;
		
		if (errorStr) {
			HUD.mode = MBProgressHUDModeCustomView;
			HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"warning.png"]];
			HUD.detailsLabelFont = [UIFont fontWithName:[[[UILabel appearance] font] fontName] size:16];
			HUD.detailsLabelText = errorStr;

			NSMutableArray *sounds = [NSMutableArray arrayWithObjects:@"SPEECH_HACKING", @"SPEECH_UNSUCCESSFUL", nil];

			if (secondsRemaining > 0) {
				
				[sounds addObject:@"SPEECH_COOLDOWN_ACTIVE"];

				int minutes = (int)floorf(secondsRemaining/60);
				if (minutes > 0) {
					[sounds addObjectsFromArray:[API soundsForNumber:minutes]];
					[sounds addObject:@"SPEECH_MINUTES"];
				} else {
					[sounds addObjectsFromArray:[API soundsForNumber:secondsRemaining]];
					[sounds addObject:@"SPEECH_SECONDS"];
				}
				
				[sounds addObject:@"SPEECH_REMAINING"];

			}

			[[API sharedInstance] playSounds:sounds];
		} else {
			HUD.mode = MBProgressHUDModeText;
			if (acquiredItems.count > 0) {

				NSMutableArray *sounds = [NSMutableArray arrayWithCapacity:acquiredItems];
				NSMutableString *acquiredItemsStr = [NSMutableString string];
				
				for (NSString *guid in acquiredItems) {
					Item *item = [Item MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"guid = %@", guid]];
					if (item) {
						[acquiredItemsStr appendFormat:@"%@\n", item];
					} else {
						[acquiredItemsStr appendString:@"Unknown Item\n"];
					}

					if ([item isKindOfClass:[Resonator class]]) {
						if (![sounds containsObject:@"SPEECH_RESONATOR"]) {
							[sounds addObject:@"SPEECH_RESONATOR"];
						}
					} else if ([item isKindOfClass:[XMP class]]) {
						if (![sounds containsObject:@"SPEECH_XMP"]) {
							[sounds addObject:@"SPEECH_XMP"];
						}
					} else if ([item isKindOfClass:[Shield class]]) {
						if (![sounds containsObject:@"SPEECH_SHIELD"]) {
							[sounds addObject:@"SPEECH_SHIELD"];
						}
					} else if ([item isKindOfClass:[PowerCube class]]) {
						if (![sounds containsObject:@"SPEECH_POWER_CUBE"]) {
							[sounds addObject:@"SPEECH_POWER_CUBE"];
						}
					} else if ([item isKindOfClass:[FlipCard class]]) {
						if ([[API sharedInstance].player.team isEqualToString:@"ALIENS"]) {
							if (![sounds containsObject:@"SPEECH_JARVIS_VIRUS"]) {
								[sounds addObject:@"SPEECH_JARVIS_VIRUS"];
							}
						} else {
							if (![sounds containsObject:@"SPEECH_ADA_REFACTOR"]) {
								[sounds addObject:@"SPEECH_ADA_REFACTOR"];
							}
						}
					} else if ([item isKindOfClass:[PortalKey class]]) {
						if (![sounds containsObject:@"SPEECH_PORTAL_KEY"]) {
							[sounds addObject:@"SPEECH_PORTAL_KEY"];
						}
					} else if ([item isKindOfClass:[Media class]]) {
						if (![sounds containsObject:@"SPEECH_MEDIA"]) {
							[sounds addObject:@"SPEECH_MEDIA"];
						}
					} else {
						if (![sounds containsObject:@"SPEECH_UNKNOWN_TECH"]) {
							[sounds addObject:@"SPEECH_UNKNOWN_TECH"];
						}
					}

				}

				if (sounds.count > 0) {
					[sounds addObject:@"SPEECH_ACQUIRED"];
				}

				[[SoundManager sharedManager] playSound:@"Sound/sfx_resource_pick_up.aif"];
				[[API sharedInstance] playSounds:sounds];
				
				HUD.labelText = @"Items acquired";
				HUD.detailsLabelText = acquiredItemsStr;
				
			} else {
				HUD.labelText = @"Hack acquired no items";
				
				[[API sharedInstance] playSounds:@[@"SPEECH_HACKING", @"SPEECH_UNSUCCESSFUL"]];
			}
		}
		
		[[AppDelegate instance].window addSubview:HUD];
		[HUD show:YES];
		[HUD hide:YES afterDelay:HUD_DELAY_TIME];
		
	}];
	
}

- (IBAction)recharge:(GUIButton *)sender {
	
	if (sender.disabled) { return; }
	
	__block MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:[AppDelegate instance].window];
	HUD.userInteractionEnabled = YES;
	HUD.mode = MBProgressHUDModeIndeterminate;
	HUD.dimBackground = YES;
	HUD.labelFont = [UIFont fontWithName:[[[UILabel appearance] font] fontName] size:16];
	HUD.labelText = @"Recharging...";
	[[AppDelegate instance].window addSubview:HUD];
	[HUD show:YES];
	
	[[API sharedInstance] rechargePortal:self.portal slots:@[@0, @1, @2, @3, @4, @5, @6, @7] completionHandler:^(NSString *errorStr) {
		
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
			[HUD hide:YES afterDelay:HUD_DELAY_TIME];

		} else {
			[[SoundManager sharedManager] playSound:@"Sound/sfx_resonator_recharge.aif"];
			[[API sharedInstance] playSounds:@[@"SPEECH_RESONATOR", @"SPEECH_RECHARGED"]];
		}

	}];
	
}

- (IBAction)link:(GUIButton *)sender {
	
	if (sender.disabled) { return; }

	UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil];
	PortalKeysViewController *portalKeysVC = [storyboard instantiateViewControllerWithIdentifier:@"PortalKeysViewController"];
	portalKeysVC.linkingPortal = self.portal;
	[self.navigationController pushViewController:portalKeysVC animated:YES]; //.parentViewController

}

@end

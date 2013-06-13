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
	
	hackButton.titleLabel.font = [UIFont fontWithName:[[[UILabel appearance] font] fontName] size:16];
	rechargeButton.titleLabel.font = [UIFont fontWithName:[[[UILabel appearance] font] fontName] size:16];
	linkButton.titleLabel.font = [UIFont fontWithName:[[[UILabel appearance] font] fontName] size:16];

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
	if (!nickname) { nickname = [Utilities factionStrForFaction:self.portal.controllingTeam]; }
	[str appendFormat:@"Owner: %@", nickname];

	NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:str];

	NSShadow *shadow = [NSShadow shadowWithOffset:CGSizeZero blurRadius:15/5 color:[UIColor colorWithRed:.56 green:1 blue:1 alpha:1]];
	[attrStr setAttributes:@{NSFontAttributeName: [UIFont fontWithName:[[[UILabel appearance] font] fontName] size:15], NSForegroundColorAttributeName : [UIColor colorWithRed:.56 green:1 blue:1 alpha:1], NSShadowAttributeName: shadow} range:NSMakeRange(0, str.length)];

	shadow = [NSShadow shadowWithOffset:CGSizeZero blurRadius:15/5 color:[Utilities colorForLevel:self.portal.level]];
	[attrStr setAttributes:@{NSFontAttributeName: [UIFont fontWithName:[[[UILabel appearance] font] fontName] size:15], NSForegroundColorAttributeName : [Utilities colorForLevel:self.portal.level], NSShadowAttributeName: shadow} range:NSMakeRange(7, 2)];

	shadow = [NSShadow shadowWithOffset:CGSizeZero blurRadius:15/5 color:[Utilities colorForFaction:self.portal.controllingTeam]];
	[attrStr setAttributes:@{NSFontAttributeName: [UIFont fontWithName:[[[UILabel appearance] font] fontName] size:15], NSForegroundColorAttributeName : [Utilities colorForFaction:self.portal.controllingTeam], NSShadowAttributeName: shadow} range:NSMakeRange(str.length-(nickname.length), nickname.length)];

	infoLabel1.attributedText = attrStr;

	////////////////////////////

    if (![[NSUserDefaults standardUserDefaults] boolForKey:MilesOrKM]) {
        infoLabel2.text = [NSString stringWithFormat:@"Energy: %.1fk\nRange: %.1fmi", self.portal.energy/1000., (self.portal.range/1000.) * 0.62137];
    }
    else
    {
    	infoLabel2.text = [NSString stringWithFormat:@"Energy: %.1fk\nRange: %.1fkm", self.portal.energy/1000., self.portal.range/1000.];
    }
	
//	attrStr = [[NSMutableAttributedString alloc] initWithString:str];
//	[attrStr setAttributes:@{NSFontAttributeName: [UIFont fontWithName:[[[UILabel appearance] font] fontName] size:15], NSForegroundColorAttributeName : [UIColor colorWithRed:.56 green:1 blue:1 alpha:1]} range:NSMakeRange(0, str.length)];
//	//[attrStr setAttributes:@{NSFontAttributeName: [UIFont fontWithName:[[[UILabel appearance] font] fontName] size:16], NSForegroundColorAttributeName : [API colorForFaction:self.portal.controllingTeam]} range:NSMakeRange(part1len+7, attrStr.length-(7+part1len))];
//	infoLabel2.attributedText = attrStr;
	
	////////////////////////////

	Player *player = [[API sharedInstance] playerForContext:[NSManagedObjectContext MR_contextForCurrentThread]];
	
	if (self.portal.controllingTeam && [self.portal.controllingTeam isEqualToString:player.team]) {
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

	[[[GAI sharedInstance] defaultTracker] sendEventWithCategory:@"Game Action" withAction:@"Portal Hack" withLabel:self.portal.name withValue:@(0)];

	__block MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:[AppDelegate instance].window];
	HUD.userInteractionEnabled = YES;
	HUD.mode = MBProgressHUDModeIndeterminate;
	HUD.dimBackground = YES;
	HUD.labelFont = [UIFont fontWithName:[[[UILabel appearance] font] fontName] size:16];
	HUD.labelText = @"Hacking...";
	[[AppDelegate instance].window addSubview:HUD];
	[HUD show:YES];
	
	if ([self.portal.controllingTeam isEqualToString:@"ALIENS"]) {
        if ([[NSUserDefaults standardUserDefaults] boolForKey:DeviceSoundToggleEffects]) {
            [[SoundManager sharedManager] playSound:@"Sound/sfx_portal_hacking_alien.aif"];
        }
	} else if ([self.portal.controllingTeam isEqualToString:@"RESISTANCE"]) {
        if ([[NSUserDefaults standardUserDefaults] boolForKey:DeviceSoundToggleEffects]) {
            [[SoundManager sharedManager] playSound:@"Sound/sfx_portal_hacking_human.aif"];
        }
	} else {
        if ([[NSUserDefaults standardUserDefaults] boolForKey:DeviceSoundToggleEffects]) {
            [[SoundManager sharedManager] playSound:@"Sound/sfx_portal_hacking_neutral.aif"];
        }
	}
	
	[[API sharedInstance] hackPortal:self.portal completionHandler:^(NSString *errorStr, NSArray *acquiredItems, int secondsRemaining) {
		
		[HUD hide:YES];
		
		if (errorStr) {
            
            NSMutableArray *sounds = [NSMutableArray array];
			if ([[NSUserDefaults standardUserDefaults] boolForKey:DeviceSoundToggleSpeech]) {
                [sounds addObjectsFromArray:@[@"SPEECH_HACKING", @"SPEECH_UNSUCCESSFUL"]];
                if (secondsRemaining > 0) {
                    
                    [sounds addObject:@"SPEECH_COOLDOWN_ACTIVE"];
                    
                    int minutes = (int)floorf(secondsRemaining/60);
                    if (minutes > 1) {
                        [sounds addObjectsFromArray:[API soundsForNumber:minutes]];
                        [sounds addObject:@"SPEECH_MINUTES"];
                    } else {
                        [sounds addObjectsFromArray:[API soundsForNumber:secondsRemaining]];
                        [sounds addObject:@"SPEECH_SECONDS"];
                    }
                    
                    [sounds addObject:@"SPEECH_REMAINING"];
                    
                }
            }
            
			[[API sharedInstance] playSounds:sounds];

			[Utilities showWarningWithTitle:errorStr];
			
		} else {

			if (acquiredItems.count > 0) {

				NSMutableArray *sounds = [NSMutableArray arrayWithCapacity:acquiredItems];
				NSCountedSet *acquiredItemStrings = [[NSCountedSet alloc] initWithCapacity:acquiredItems.count];
				NSMutableAttributedString *acquiredItemsStr = [NSMutableAttributedString new];
				
				for (NSString *guid in acquiredItems) {
					Item *item = [Item MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"guid = %@", guid]];
					if (item) {
						if ([item isKindOfClass:[PortalKey class]]) {
							[acquiredItemStrings addObject:@"Portal Key"];
						} else {
							[acquiredItemStrings addObject:item.description];
						}
					} else {
						[acquiredItemStrings addObject:@"Unknown Item"];
					}

                    if ([[NSUserDefaults standardUserDefaults] boolForKey:DeviceSoundToggleSpeech]) {
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
                        } else if ([item isKindOfClass:[LinkAmp class]]) {
                            if (![sounds containsObject:@"SPEECH_FORCE_AMP"]) {
                                [sounds addObject:@"SPEECH_FORCE_AMP"];
                            }
                        } else if ([item isKindOfClass:[ForceAmp class]]) {
                            if (![sounds containsObject:@"SPEECH_FORCE_AMP"]) {
                                [sounds addObject:@"SPEECH_FORCE_AMP"];
                            }
                        } else if ([item isKindOfClass:[Heatsink class]]) {
                            if (![sounds containsObject:@"SPEECH_HEAT_SINK"]) {
                                [sounds addObject:@"SPEECH_HEAT_SINK"];
                            }
                        } else if ([item isKindOfClass:[Multihack class]]) {
                            if (![sounds containsObject:@"SPEECH_MULTI_HACK"]) {
                                [sounds addObject:@"SPEECH_MULTI_HACK"];
                            }
                        } else if ([item isKindOfClass:[Turret class]]) {
                            if (![sounds containsObject:@"SPEECH_TURRET"]) {
                                [sounds addObject:@"SPEECH_TURRET"];
                            }
                        } else if ([item isKindOfClass:[PowerCube class]]) {
                            if (![sounds containsObject:@"SPEECH_POWER_CUBE"]) {
                                [sounds addObject:@"SPEECH_POWER_CUBE"];
                            }
                        } else if ([item isKindOfClass:[FlipCard class]]) {
                            if ([[(FlipCard *)item type] isEqualToString:@"JARVIS"]) {
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
				}
                if ([[NSUserDefaults standardUserDefaults] boolForKey:DeviceSoundToggleSpeech]) {
                    if (sounds.count > 0) {
                        [sounds addObject:@"SPEECH_ACQUIRED"];
                    }
                    
                    [[SoundManager sharedManager] playSound:@"Sound/sfx_resource_pick_up.aif"];
                    [[API sharedInstance] playSounds:sounds];
                }

				for (NSString *acquiredItem in acquiredItemStrings) {

					NSMutableAttributedString *acquiredItemStr = [[NSMutableAttributedString alloc] initWithString:acquiredItem attributes:[Utilities attributesWithShadow:YES size:15 color:[UIColor whiteColor]]];

					if ([acquiredItem hasPrefix:@"L"]) {
						int level = [[acquiredItem substringWithRange:NSMakeRange(1, 1)] intValue];
						[acquiredItemStr setAttributes:[Utilities attributesWithShadow:YES size:15 color:[Utilities colorForLevel:level]] range:NSMakeRange(0, 2)];
					} else if ([acquiredItem hasPrefix:@"Common"]) {
						//[acquiredItemStr setAttributes:[Utilities attributesWithShadow:YES size:15 color:[API colorForLevel:level]] range:NSMakeRange(0, 2)];
					}

					[acquiredItemsStr appendAttributedString:acquiredItemStr];

					NSUInteger count = [acquiredItemStrings countForObject:acquiredItem];
					if (count > 1) {
						[acquiredItemsStr appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@" (%d)", count] attributes:[Utilities attributesWithShadow:YES size:15 color:[UIColor whiteColor]]]];
					}

					[acquiredItemsStr appendAttributedString:[[NSAttributedString alloc] initWithString:@"\n" attributes:nil]];

				}

				HUD = [[MBProgressHUD alloc] initWithView:[AppDelegate instance].window];
				HUD.userInteractionEnabled = YES;
				HUD.dimBackground = YES;
				HUD.mode = MBProgressHUDModeText;
				HUD.labelFont = [UIFont fontWithName:[[[UILabel appearance] font] fontName] size:18];
				HUD.labelText = @"Items acquired";
				HUD.detailsLabelAttributedText = acquiredItemsStr;
				HUD.showCloseButton = YES;
				[[AppDelegate instance].window addSubview:HUD];
				[HUD show:YES];
				
			} else {

				HUD = [[MBProgressHUD alloc] initWithView:[AppDelegate instance].window];
				HUD.userInteractionEnabled = YES;
				HUD.dimBackground = YES;
				HUD.mode = MBProgressHUDModeText;
				HUD.labelFont = [UIFont fontWithName:[[[UILabel appearance] font] fontName] size:16];

				HUD.labelText = @"Hack acquired no items";
				if ([[NSUserDefaults standardUserDefaults] boolForKey:DeviceSoundToggleSpeech]) {
                    [[API sharedInstance] playSounds:@[@"SPEECH_HACKING", @"SPEECH_UNSUCCESSFUL"]];
                }
                
				[[AppDelegate instance].window addSubview:HUD];
				[HUD show:YES];
				[HUD hide:YES afterDelay:HUD_DELAY_TIME];
				
			}
		}

	}];
	
}

- (IBAction)recharge:(GUIButton *)sender {
	
	if (sender.disabled) { return; }

	[[[GAI sharedInstance] defaultTracker] sendEventWithCategory:@"Game Action" withAction:@"Portal Recharge" withLabel:self.portal.name withValue:@(0)];
	
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
			[Utilities showWarningWithTitle:errorStr];
		} else {
            if ([[NSUserDefaults standardUserDefaults] boolForKey:DeviceSoundToggleEffects]) {
                [[SoundManager sharedManager] playSound:@"Sound/sfx_resonator_recharge.aif"];
            }
            if ([[NSUserDefaults standardUserDefaults] boolForKey:DeviceSoundToggleSpeech]) {
                [[API sharedInstance] playSounds:@[@"SPEECH_RESONATOR", @"SPEECH_RECHARGED"]];
            }
		}

	}];
	
}

- (IBAction)link:(GUIButton *)sender {
	
	if (sender.disabled) { return; }

	[[[GAI sharedInstance] defaultTracker] sendEventWithCategory:@"Game Action" withAction:@"Portal Link" withLabel:self.portal.name withValue:@(0)];

	UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil];
	PortalKeysViewController *portalKeysVC = [storyboard instantiateViewControllerWithIdentifier:@"PortalKeysViewController"];
	portalKeysVC.linkingPortal = self.portal;
	[self.navigationController pushViewController:portalKeysVC animated:YES]; //.parentViewController

}

@end

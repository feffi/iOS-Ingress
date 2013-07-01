//
//  PortalKeysViewController.m
//  Ingress
//
//  Created by Alex Studnicka on 18.01.13.
//  Copyright (c) 2013 A&A Code. All rights reserved.
//

#import "PortalKeysViewController.h"
#import "PortalDetailViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "GUIButton.h"

@interface PortalKeysViewController ()
@property (nonatomic, weak) GUIButton* closeButton;
@end

@implementation PortalKeysViewController {
	NSMutableDictionary *keysDict;
	NSMutableArray *portals;

	PortalKey *currentPortalKey;
}

@synthesize linkingPortal = _linkingPortal;

- (void)viewDidLoad {
	[super viewDidLoad];
    
    if (self.linkingPortal) {
        self.tableView.contentInset = UIEdgeInsetsMake(22, 0, 60, 0);
        GUIButton *closeButton = [[GUIButton alloc] initWithFrame:CGRectMake(self.view.bounds.size.width-110, self.view.bounds.size.height-75, 100, 45)];
        closeButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
        [closeButton setTitle:@"CANCEL" forState:UIControlStateNormal];
        [closeButton addTarget:self action:@selector(closePortalKeyChooser:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:closeButton];
        _closeButton = closeButton;
    }

#if __IPHONE_OS_VERSION_MAX_ALLOWED < 70000
	if (!self.linkingPortal || ![Utilities isOS7]) {
		self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 32, 0);
		self.tableView.scrollIndicatorInsets = self.tableView.contentInset;
	}
#endif
    
}

//- (void)viewWillLayoutSubviews {
//	if (self.linkingPortal && [Utilities isOS7]) {
//		CGRect frame = self.view.frame;
//		frame.origin.y = 20;
//		frame.size.height = [UIScreen mainScreen].bounds.size.height-20;
//		self.view.frame = frame;
//	}
//}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];

	[self refresh];
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];

}

- (void)refresh {

	NSArray *fetchedKeys = [PortalKey MR_findAllWithPredicate:[NSPredicate predicateWithFormat:@"dropped = NO"]];
	keysDict = [NSMutableDictionary dictionary];
	for (PortalKey *portalKey in fetchedKeys) {
		if ([keysDict.allKeys containsObject:portalKey.portal.guid]) {
			NSMutableArray *array = keysDict[portalKey.portal.guid];
			[array addObject:portalKey];
		} else {
			keysDict[portalKey.portal.guid] = [NSMutableArray arrayWithObject:portalKey];
		}
	}

	portals = [NSMutableArray arrayWithCapacity:keysDict.allKeys.count];
	for (NSString *portalGuid in keysDict.allKeys) {
		[portals addObject:[Portal MR_findFirstByAttribute:@"guid" withValue:portalGuid]];
	}

	[portals sortUsingComparator:^NSComparisonResult(Portal *obj1, Portal *obj2) {
		CLLocationDistance dist1 = [obj1 distanceFromCoordinate:[AppDelegate instance].mapView.centerCoordinate];
		CLLocationDistance dist2 = [obj2 distanceFromCoordinate:[AppDelegate instance].mapView.centerCoordinate];

		if (dist1 < dist2) {
			return NSOrderedAscending;
		} else if (dist1 > dist2) {
			return NSOrderedDescending;
		} else {
			return NSOrderedSame;
		}
	}];

	[self.tableView reloadData];

}

#pragma mark - UITableViewDataSource & UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return portals.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PortalKeyCell" forIndexPath:indexPath];
	
	Portal *portal = portals[indexPath.row];
	
	int numberOfKeys = [keysDict[portal.guid] count];
	cell.textLabel.text = [NSString stringWithFormat:@"%dx %@", numberOfKeys, portal.subtitle];
	
	if (self.linkingPortal) {
		cell.detailTextLabel.text = @"Querying Linkability...";
		
		PortalKey *portalKey = [keysDict[portal.guid] lastObject];
		[[API sharedInstance] queryLinkabilityForPortal:self.linkingPortal portalKey:portalKey completionHandler:^(NSString *errorStr) {
			[self configureCellAtIndexPath:indexPath inTableView:tableView withErrorStr:errorStr];
		}];
	} else {
		cell.detailTextLabel.text = portal.address;
		
		[[API sharedInstance] getModifiedEntity:portal completionHandler:^{
			[self configureCellAtIndexPath:indexPath inTableView:tableView withErrorStr:nil];
		}];
	}
	
	[cell.imageView setImageWithURL:[NSURL URLWithString:portal.imageURL] placeholderImage:[UIImage imageNamed:@"missing_image"]];

	if (self.linkingPortal) {
		cell.textLabel.textColor = [UIColor lightGrayColor];
	} else {
		if (portal.completeInfo) {
			if ([@[@"ALIENS", @"RESISTANCE"] containsObject:portal.controllingTeam]) {
				cell.textLabel.textColor = [Utilities colorForFaction:portal.controllingTeam];
			} else {
				cell.textLabel.textColor = [UIColor lightGrayColor];
			}
		} else {
			cell.textLabel.textColor = [UIColor whiteColor];
		}
	}

    return cell;
}

- (void)configureCellAtIndexPath:(NSIndexPath *)indexPath inTableView:(UITableView *)tableView withErrorStr:(NSString *)errorStr {
	UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
	if (cell) {
		Portal *portal = portals[indexPath.row];

		if (self.linkingPortal) {
			if (errorStr) {
				cell.textLabel.textColor = [UIColor lightGrayColor];
				cell.detailTextLabel.text = errorStr;
			} else {
				cell.textLabel.textColor = [Utilities colorForFaction:portal.controllingTeam];
				cell.detailTextLabel.text = portal.address;
			}
		} else {
			if (portal.completeInfo) {
				if ([@[@"ALIENS", @"RESISTANCE"] containsObject:portal.controllingTeam]) {
					cell.textLabel.textColor = [Utilities colorForFaction:portal.controllingTeam];
				} else {
					cell.textLabel.textColor = [UIColor lightGrayColor];
				}
			} else {
				cell.textLabel.textColor = [UIColor whiteColor];
			}
		}
		
	}
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	
	Portal *portal = portals[indexPath.row];
    
	if (self.linkingPortal) {

		UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
		if (![cell.detailTextLabel.text isEqualToString:portal.address]) {
			if ([[NSUserDefaults standardUserDefaults] boolForKey:DeviceSoundToggleEffects]) {
				[[SoundManager sharedManager] playSound:@"Sound/sfx_ui_fail.aif"];
			}
			return;
		}
		
		if ([[NSUserDefaults standardUserDefaults] boolForKey:DeviceSoundToggleEffects]) {
			[[SoundManager sharedManager] playSound:@"Sound/sfx_ui_success.aif"];
		}
		
        if ([[NSUserDefaults standardUserDefaults] boolForKey:DeviceSoundToggleSpeech]) {
            [[API sharedInstance] playSound:@"SPEECH_ESTABLISHING_PORTAL_LINK"];
        }
		
		PortalKey *portalKey = [keysDict[portal.guid] lastObject];

		MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:[AppDelegate instance].window];
		HUD.removeFromSuperViewOnHide = YES;
		HUD.userInteractionEnabled = YES;
		HUD.dimBackground = YES;
		HUD.labelFont = [UIFont fontWithName:[[[UILabel appearance] font] fontName] size:16];
		HUD.labelText = @"Linking Portal...";
		[[AppDelegate instance].window addSubview:HUD];
		[HUD show:YES];

		[[API sharedInstance] linkPortal:self.linkingPortal withPortalKey:portalKey completionHandler:^(NSString *errorStr) {

			[HUD hide:YES];

			if ([[NSUserDefaults standardUserDefaults] boolForKey:DeviceSoundToggleEffects]) {
				[[SoundManager sharedManager] playSound:@"Sound/sfx_link_power_up.aif"];
			}
			if ([[NSUserDefaults standardUserDefaults] boolForKey:DeviceSoundToggleSpeech]) {
				[[API sharedInstance] playSound:@"SPEECH_PORTAL_LINK_ESTABLISHED"];
			}

			[self refresh];
			
		}];
		
	} else {
		
		if ([[NSUserDefaults standardUserDefaults] boolForKey:DeviceSoundToggleEffects]) {
			[[SoundManager sharedManager] playSound:@"Sound/sfx_ui_success.aif"];
		}

		PortalKey *portalKey = [keysDict[portal.guid] lastObject];
		currentPortalKey = portalKey;

		UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Drop" otherButtonTitles:@"Recycle", @"View Portal Info", nil];
		actionSheet.tag = 1;
		[actionSheet showInView:self.view.window];

	}

}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if ([[NSUserDefaults standardUserDefaults] boolForKey:DeviceSoundToggleEffects]) {
        [[SoundManager sharedManager] playSound:@"Sound/sfx_ui_success.aif"];
    }
	if (actionSheet.tag == 1 && buttonIndex == 0) {

		__block MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:[AppDelegate instance].window];
		HUD.userInteractionEnabled = YES;
		HUD.mode = MBProgressHUDModeIndeterminate;
		HUD.dimBackground = YES;
		HUD.labelFont = [UIFont fontWithName:[[[UILabel appearance] font] fontName] size:16];
		HUD.labelText = @"Dropping Portal Key...";
		[[AppDelegate instance].window addSubview:HUD];
		[HUD show:YES];
        if ([[NSUserDefaults standardUserDefaults] boolForKey:DeviceSoundToggleEffects]) {
            [[API sharedInstance] playSound:@"SFX_DROP_RESOURCE"];
        }
        
		[[API sharedInstance] dropItemWithGuid:currentPortalKey.guid completionHandler:^(void) {
			[HUD hide:YES];

			[self refresh];
		}];

	} else if (actionSheet.tag == 1 && buttonIndex == 1) {

		PortalKey *portalKey = currentPortalKey;

		__block MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:[AppDelegate instance].window];
		HUD.userInteractionEnabled = YES;
		HUD.mode = MBProgressHUDModeIndeterminate;
		HUD.dimBackground = YES;
		HUD.labelFont = [UIFont fontWithName:[[[UILabel appearance] font] fontName] size:16];
		HUD.labelText = @"Recycling Item...";
		[[AppDelegate instance].window addSubview:HUD];
		[HUD show:YES];

        if ([[NSUserDefaults standardUserDefaults] boolForKey:DeviceSoundToggleEffects]) {
            [[SoundManager sharedManager] playSound:[NSString stringWithFormat:@"Sound/sfx_recycle_%@.aif", arc4random_uniform(2) ? @"a" : @"b"]];
        }

		[[API sharedInstance] recycleItem:portalKey completionHandler:^{
			[HUD hide:YES];

			[self refresh];
		}];
		
	} else if (actionSheet.tag == 1 && buttonIndex == 2) {

		PortalKey *portalKey = currentPortalKey;
		
		UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil];
		PortalDetailViewController *portalDetailVC = [storyboard instantiateViewControllerWithIdentifier:@"PortalDetailViewController"];
		portalDetailVC.portal = portalKey.portal;
		portalDetailVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
		[self presentViewController:portalDetailVC animated:YES completion:NULL];
		
		currentPortalKey = nil;
		
//		__block MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:[AppDelegate instance].window];
//		HUD.userInteractionEnabled = YES;
//		HUD.mode = MBProgressHUDModeIndeterminate;
//		HUD.dimBackground = YES;
//		HUD.labelFont = [UIFont fontWithName:[[[UILabel appearance] font] fontName] size:16];
//		HUD.labelText = @"Recharging Portal...";
//		[[AppDelegate instance].window addSubview:HUD];
//		[HUD show:YES];
//        
//        if ([[NSUserDefaults standardUserDefaults] boolForKey:DeviceSoundToggleEffects]) {
//            [[API sharedInstance] playSound:@"SFX_RESONATOR_RECHARGE"];
//        }
//        
//		[[API sharedInstance] remoteRechargePortal:portalKey.portal portalKey:portalKey completionHandler:^(NSString *errorStr) {
//
//			[HUD hide:YES];
//
//			if (errorStr) {
//
//				MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:[AppDelegate instance].window];
//				HUD.userInteractionEnabled = YES;
//				HUD.dimBackground = YES;
//				HUD.mode = MBProgressHUDModeCustomView;
//				HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"warning.png"]];
//				HUD.detailsLabelFont = [UIFont fontWithName:[[[UILabel appearance] font] fontName] size:16];
//				HUD.detailsLabelText = errorStr;
//				[[AppDelegate instance].window addSubview:HUD];
//				[HUD show:YES];
//				[HUD hide:YES afterDelay:HUD_DELAY_TIME];
//
//			} else {
//                if ([[NSUserDefaults standardUserDefaults] boolForKey:DeviceSoundToggleSpeech]) {
//                    [[API sharedInstance] playSounds:@[@"SPEECH_RESONATOR", @"SPEECH_RECHARGED"]];
//                }
//			}
//
//			currentPortalKey = nil;
//
//		}];

	}
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
	_closeButton.transform = CGAffineTransformMakeTranslation(0, (scrollView.contentInset.top + scrollView.contentOffset.y));
}

#pragma mark - Actions

- (void)closePortalKeyChooser:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end

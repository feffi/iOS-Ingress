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
	
	ChooserViewController *_countChooser;
}

@synthesize linkingPortal = _linkingPortal;

- (void)viewDidLoad {
	[super viewDidLoad];
    
    if (self.linkingPortal) {
        self.tableView.contentInset = UIEdgeInsetsMake(20, 0, 60, 0);
        GUIButton *closeButton = [[GUIButton alloc] initWithFrame:CGRectMake(self.view.bounds.size.width-110, self.view.bounds.size.height-75, 100, 45)];
        closeButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
        [closeButton setTitle:@"CANCEL" forState:UIControlStateNormal];
        [closeButton addTarget:self action:@selector(closePortalKeyChooser:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:closeButton];
        _closeButton = closeButton;
    } else {
		self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 32, 0);
		self.tableView.scrollIndicatorInsets = self.tableView.contentInset;
	}
    
}

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
	
	UIColor *portalColor = [UIColor whiteColor];
	if (self.linkingPortal) {
		portalColor = [UIColor lightGrayColor];
	}
	
	if (portal.completeInfo) {
		NSMutableAttributedString *attrStr = [NSMutableAttributedString new];
		[attrStr appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%dx ", [keysDict[portal.guid] count]] attributes:[Utilities attributesWithShadow:NO size:14 color:[UIColor whiteColor]]]];
		[attrStr appendAttributedString:[[NSAttributedString alloc] initWithString:portal.name attributes:[Utilities attributesWithShadow:NO size:14 color:portalColor]]];
		cell.textLabel.attributedText = attrStr;
	}
	
	if (portal.level > 8) {
		NSLog(@"WTF? L%d - %d resonators", portal.level, portal.resonators.count);
	}
	
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
	
	[cell layoutIfNeeded];

    return cell;
}

- (void)configureCellAtIndexPath:(NSIndexPath *)indexPath inTableView:(UITableView *)tableView withErrorStr:(NSString *)errorStr {
	UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
	if (cell) {
		
		Portal *portal = portals[indexPath.row];
		
		UIColor *portalColor = [UIColor whiteColor];
		if (self.linkingPortal) {
			if (errorStr) {
				portalColor = [UIColor lightGrayColor];
			} else {
				portalColor = [Utilities colorForFaction:portal.controllingTeam];
			}
		} else if (portal.completeInfo) {
			if ([@[@"ALIENS", @"RESISTANCE"] containsObject:portal.controllingTeam]) {
				portalColor = [Utilities colorForFaction:portal.controllingTeam];
			} else {
				portalColor = [UIColor lightGrayColor];
			}
		}
		
		if (portal.completeInfo) {
			NSMutableAttributedString *attrStr = [NSMutableAttributedString new];
			[attrStr appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%dx ", [keysDict[portal.guid] count]] attributes:[Utilities attributesWithShadow:NO size:14 color:[UIColor whiteColor]]]];
			[attrStr appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"L%d ", portal.level] attributes:[Utilities attributesWithShadow:NO size:14 color:[Utilities colorForLevel:portal.level]]]];
			[attrStr appendAttributedString:[[NSAttributedString alloc] initWithString:portal.name attributes:[Utilities attributesWithShadow:NO size:14 color:portalColor]]];
			cell.textLabel.attributedText = attrStr;
		}

		if (self.linkingPortal) {
			if (errorStr) {
				cell.detailTextLabel.text = errorStr;
			} else {
				cell.detailTextLabel.text = portal.address;
			}
		}
		
		[cell layoutIfNeeded];
		
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
		
		Portal *portal = currentPortalKey.portal;
		NSArray *portalKeys = keysDict[portal.guid];

		if (portalKeys.count > 0) {
			
			MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:[AppDelegate instance].window];
			HUD.removeFromSuperViewOnHide = YES;
			HUD.userInteractionEnabled = YES;
			HUD.mode = MBProgressHUDModeCustomView;
			HUD.dimBackground = YES;
			HUD.showCloseButton = YES;
			
			_countChooser = [ChooserViewController countChooserWithButtonTitle:@"DROP" maxCount:portalKeys.count completionHandler:^(int count) {
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

					if (portalKeys.count >= count) {
						items = [portalKeys subarrayWithRange:NSMakeRange(0, count)];
					}

					__block int completed = 0;
					for (PortalKey *portalKey in items) {
						[[API sharedInstance] dropItemWithGuid:portalKey.guid completionHandler:^(void) {
							completed++;
							if (completed == items.count) {
								[HUD hide:YES];
								[self refresh];
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

	} else if (actionSheet.tag == 1 && buttonIndex == 1) {
		
		Portal *portal = currentPortalKey.portal;
		NSArray *portalKeys = keysDict[portal.guid];
		
		if (portalKeys.count > 0) {
			
			MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:[AppDelegate instance].window];
			HUD.removeFromSuperViewOnHide = YES;
			HUD.userInteractionEnabled = YES;
			HUD.mode = MBProgressHUDModeCustomView;
			HUD.dimBackground = YES;
			HUD.showCloseButton = YES;
			
			_countChooser = [ChooserViewController countChooserWithButtonTitle:@"RECYCLE" maxCount:portalKeys.count completionHandler:^(int count) {
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
					
					if (portalKeys.count > count) {
						items = [portalKeys subarrayWithRange:NSMakeRange(0, count)];
					}
					
					__block int completed = 0;
					for (PortalKey *portalKey in portalKeys) {
						
						[[API sharedInstance] recycleItem:portalKey completionHandler:^(void) {
							completed++;
							if (completed == items.count) {
								[HUD hide:YES];
								[self refresh];
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
		
	} else if (actionSheet.tag == 1 && buttonIndex == 2) {

		PortalKey *portalKey = currentPortalKey;
		
		UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil];
		PortalDetailViewController *portalDetailVC = [storyboard instantiateViewControllerWithIdentifier:@"PortalDetailViewController"];
		portalDetailVC.portal = portalKey.portal;
		portalDetailVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
		[self presentViewController:portalDetailVC animated:YES completion:NULL];
		
		currentPortalKey = nil;

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

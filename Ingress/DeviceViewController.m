//
//  DeviceViewController.m
//  Ingress
//
//  Created by Alex Studnička on 02.05.13.
//  Copyright (c) 2013 A&A Code. All rights reserved.
//

#import "DeviceViewController.h"

@implementation DeviceViewController {
	UIImage *imageData;
	NSString *imageLocation;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];

	[[[GAI sharedInstance] defaultTracker] sendView:@"Device Screen"];

	[self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDataSource & UITableViewDelegate

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
	cell.textLabel.font = [UIFont fontWithName:[[[UILabel appearance] font] fontName] size:18];
    
	switch (indexPath.section) {
		case 0:

			switch (indexPath.row) {
				case 0: {
					cell.textLabel.text = [NSString stringWithFormat:@"iOS Ingress %@", [[NSBundle mainBundle] infoDictionary][@"CFBundleVersion"]];
					break;
				}
				case 4: {
					int numItems = [Item MR_countOfEntitiesWithPredicate:[NSPredicate predicateWithFormat:@"dropped = NO"]];
					cell.textLabel.text = [NSString stringWithFormat:@"%d items in Inventory", numItems];
					break;
				}
			}

			break;
		case 1:

			switch (indexPath.row) {
				case 2: {
					if ([[NSUserDefaults standardUserDefaults] boolForKey:DeviceSoundToggleBackground]) {
						cell.textLabel.text = @"Mute Background";
					} else {
						cell.textLabel.text = @"Unmute Background";
					}
					break;
				}
				case 3: {
					if ([[NSUserDefaults standardUserDefaults] boolForKey:DeviceSoundToggleEffects]) {
						cell.textLabel.text = @"Mute Effects";
					} else {
						cell.textLabel.text = @"Unmute Effects";
					}
					break;
				}
				case 4: {
					if ([[NSUserDefaults standardUserDefaults] boolForKey:DeviceSoundToggleSpeech]) {
						cell.textLabel.text = @"Mute Speech";
					} else {
						cell.textLabel.text = @"Unmute Speech";
					}
					break;
				}
				case 5: {
					Player *player = [[API sharedInstance] playerForContext:[NSManagedObjectContext MR_contextForCurrentThread]];
					if (player.shouldSendEmail) {
						cell.textLabel.text = @"Disable Email Notifications";
					} else {
						cell.textLabel.text = @"Enable Email Notifications";
					}
					break;
				}
				case 6: {
					if ([[NSUserDefaults standardUserDefaults] boolForKey:IGMapDayMode]) {
						cell.textLabel.text = @"Switch map to night mode";
					} else {
						cell.textLabel.text = @"Switch map to day mode";
					}
					break;
				}
				case 7: {
					if (![[NSUserDefaults standardUserDefaults] boolForKey:MilesOrKM]) {
						cell.textLabel.text = @"Switch units to kilometers";
					} else {
						cell.textLabel.text = @"Switch units to miles";
					}
					break;
				}
			}

			break;
	}

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
	if (cell.selectionStyle == UITableViewCellSelectionStyleNone) {
		return;
	}

	[tableView deselectRowAtIndexPath:indexPath animated:YES];

    if ((indexPath.row == 5 && ![[NSUserDefaults standardUserDefaults] boolForKey:DeviceSoundToggleEffects]) || (indexPath.row != 5 && [[NSUserDefaults standardUserDefaults] boolForKey:DeviceSoundToggleEffects])) {
        [[SoundManager sharedManager] playSound:@"Sound/sfx_ui_success.aif"];
    }

	switch (indexPath.section) {
		case 0:

			switch (indexPath.row) {
				case 2:
					[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.ios-ingress.com"]];
					break;
				case 3:
					[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://www.paypal.com/cgi-bin/webscr?cmd=_donations&business=6HKVU78GCECL2&lc=US&item_name=iOS%20Ingress&currency_code=USD&bn=PP%2dDonationsBF%3abtn_donateCC_LG%2egif%3aNonHosted"]];
					break;
			}

			break;
		case 1:

			switch (indexPath.row) {
				case 0: {

					NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
					for (NSHTTPCookie *cookie in [storage cookies]) {
						[storage deleteCookie:cookie];
					}
					[[NSUserDefaults standardUserDefaults] synchronize];

					[MagicalRecord cleanUp];
					[[NSFileManager defaultManager] removeItemAtURL:[NSPersistentStore MR_urlForStoreName:@"Ingress.sqlite"] error:nil];
					[MagicalRecord setupCoreDataStackWithAutoMigratingSqliteStoreNamed:@"Ingress.sqlite"];

					[self dismissViewControllerAnimated:YES completion:nil];

					break;
				}
                    
                case 1: {
                    
                    Player *player = [[API sharedInstance] playerForContext:[NSManagedObjectContext MR_contextForCurrentThread]];
                    NSString *nickname = [player.nickname copy];
                    
					[MagicalRecord cleanUp];
					[[NSFileManager defaultManager] removeItemAtURL:[NSPersistentStore MR_urlForStoreName:@"Ingress.sqlite"] error:nil];
					[MagicalRecord setupCoreDataStackWithAutoMigratingSqliteStoreNamed:@"Ingress.sqlite"];
                    
                    player = [[API sharedInstance] playerForContext:[NSManagedObjectContext MR_contextForCurrentThread]];
                    player.nickname = nickname;
                    
                    nickname = nil;
                    
					MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:self.view.window];
					HUD.removeFromSuperViewOnHide = YES;
					HUD.userInteractionEnabled = YES;
					HUD.dimBackground = YES;
					HUD.mode = MBProgressHUDModeIndeterminate;
					HUD.labelFont = [UIFont fontWithName:[[[UILabel appearance] font] fontName] size:16];
					HUD.labelText = @"Force Sync In Progress...";
					[self.view.window addSubview:HUD];
					[HUD show:YES];

					[[API sharedInstance] getInventoryWithCompletionHandler:^{
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"DBUpdatedNotification" object:nil];
						[HUD hide:YES];
					}];

					break;
                    
                }

				case 2: {

					BOOL background = [[NSUserDefaults standardUserDefaults] boolForKey:DeviceSoundToggleBackground];
					UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
					if (background) {
						[[SoundManager sharedManager] stopMusic:NO];
						cell.textLabel.text = @"Unmute Background";
						[[NSUserDefaults standardUserDefaults] setBool:NO forKey:DeviceSoundToggleBackground];
					} else {
						cell.textLabel.text = @"Mute Background";
						[[NSUserDefaults standardUserDefaults] setBool:YES forKey:DeviceSoundToggleBackground];
						[[SoundManager sharedManager] playMusic:@"Sound/sfx_ambient_scanner_base.aif" looping:YES fadeIn:NO];
					}
					[[NSUserDefaults standardUserDefaults] synchronize];

					break;
				}

				case 3: {

					BOOL effects = [[NSUserDefaults standardUserDefaults] boolForKey:DeviceSoundToggleEffects];
					UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
					if (effects) {
						cell.textLabel.text = @"Unmute Effects";
						[[NSUserDefaults standardUserDefaults] setBool:NO forKey:DeviceSoundToggleEffects];
					} else {
						cell.textLabel.text = @"Mute Effects";
						[[NSUserDefaults standardUserDefaults] setBool:YES forKey:DeviceSoundToggleEffects];
					}
					[[NSUserDefaults standardUserDefaults] synchronize];

					break;
				}

				case 4: {

					BOOL speech = [[NSUserDefaults standardUserDefaults] boolForKey:DeviceSoundToggleSpeech];
					UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
					if (speech) {
						cell.textLabel.text = @"Unmute Speech";
						[[NSUserDefaults standardUserDefaults] setBool:NO forKey:DeviceSoundToggleSpeech];
					} else {
						cell.textLabel.text = @"Mute Speech";
						[[NSUserDefaults standardUserDefaults] setBool:YES forKey:DeviceSoundToggleSpeech];
						[[API sharedInstance] playSound:@"SPEECH_ACTIVATED"];
					}
					[[NSUserDefaults standardUserDefaults] synchronize];

					break;
				}

				case 5: {

					UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
					Player *player = [[API sharedInstance] playerForContext:[NSManagedObjectContext MR_contextForCurrentThread]];
					if (player.shouldSendEmail) {
						cell.textLabel.text = @"Enable Email Notifications";
					} else {
						cell.textLabel.text = @"Disable Email Notifications";
					}

					[MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
						Player *player = [[API sharedInstance] playerForContext:localContext];
						player.shouldSendEmail = !player.shouldSendEmail;
					} completion:^(BOOL success, NSError *error) {
						[[API sharedInstance] setNotificationSettingsWithCompletionHandler:nil];
					}];

					break;
				}

				case 6: {
					BOOL newDayModeValue = ! [[NSUserDefaults standardUserDefaults] boolForKey:IGMapDayMode];

					[[NSUserDefaults standardUserDefaults] setBool:newDayModeValue forKey:IGMapDayMode];
					[[NSUserDefaults standardUserDefaults] synchronize];

					UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
					if (newDayModeValue) {
						cell.textLabel.text = @"Switch map to night mode";
					} else {
						cell.textLabel.text = @"Switch map to day mode";
					}

					break;
				}
				case 7:
				{

					BOOL newMilesorKMValue = ! [[NSUserDefaults standardUserDefaults] boolForKey:MilesOrKM];
					[[NSUserDefaults standardUserDefaults] setBool:newMilesorKMValue forKey:MilesOrKM];
					[[NSUserDefaults standardUserDefaults] synchronize];

					UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
					if (!newMilesorKMValue) {
						cell.textLabel.text = @"Switch units to kilometers";
					} else {
						cell.textLabel.text = @"Switch units to miles";
					}
					break;
				}

			}

			break;
	}

}

@end

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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDataSource & UITableViewDelegate

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
	cell.textLabel.font = [UIFont fontWithName:[[[UILabel appearance] font] fontName] size:18];
    
    switch (indexPath.row) {
        case 4: {
            if ([[NSUserDefaults standardUserDefaults] floatForKey:kDeviceSoundLevel] < 0.1) {
                cell.textLabel.text = @"Unmute Sound";
            } else {
                cell.textLabel.text = @"Mute Sound";
			}
            break;
        }
		case 5: {
            if ([API sharedInstance].player.shouldSendEmail) {
                cell.textLabel.text = @"Disable Email Notifications";
            } else {
                cell.textLabel.text = @"Enable Email Notifications";
			}
            break;
        }
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:YES];

	[[SoundManager sharedManager] playSound:@"Sound/sfx_ui_success.aif"];

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

			[self performSegueWithIdentifier:@"ImagePickerSegue" sender:self];

			break;
		}
		case 2: {

			__block MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:self.view.window];
			HUD.userInteractionEnabled = YES;
			HUD.dimBackground = YES;
			HUD.mode = MBProgressHUDModeIndeterminate;
			HUD.labelFont = [UIFont fontWithName:[[[UILabel appearance] font] fontName] size:16];
			HUD.labelText = @"Loading inventory...";
			[self.view.window addSubview:HUD];
			[HUD show:YES];

			[[API sharedInstance] getInventoryWithCompletionHandler:^{
				[HUD hide:YES];
			}];

			break;
		}

		case 3: {

			[MagicalRecord cleanUp];
			[[NSFileManager defaultManager] removeItemAtURL:[NSPersistentStore MR_urlForStoreName:@"Ingress.sqlite"] error:nil];
			[MagicalRecord setupCoreDataStackWithAutoMigratingSqliteStoreNamed:@"Ingress.sqlite"];
			
            break;
		}

        case 4: {

			float currentSoundVolume = [SoundManager sharedManager].soundVolume;
			UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
			if (currentSoundVolume < 0.1) {
				cell.textLabel.text = @"Mute Sound";
                currentSoundVolume = 1.0;
			} else {
				cell.textLabel.text = @"Unmute Sound";
                currentSoundVolume = 0.0;
			}

            [SoundManager sharedManager].soundVolume = currentSoundVolume;
            [SoundManager sharedManager].musicVolume = currentSoundVolume;

            [[NSUserDefaults standardUserDefaults] setFloat:currentSoundVolume forKey:kDeviceSoundLevel];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            break;
        }

		case 5: {

            UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
			if ([API sharedInstance].player.shouldSendEmail) {
				cell.textLabel.text = @"Enable Email Notifications";
			} else {
				cell.textLabel.text = @"Disable Email Notifications";
			}

            [API sharedInstance].player.shouldSendEmail = ![API sharedInstance].player.shouldSendEmail;

			[[API sharedInstance] setNotificationSettingsWithCompletionHandler:nil];
			
		}
	}
	
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {

	imageData = nil;
	imageLocation = nil;

	NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
	if ([mediaType isEqualToString:(NSString*)kUTTypeImage]) {
		NSURL *url = [info objectForKey:UIImagePickerControllerReferenceURL];
		if (url) {
			[[ALAssetsLibrary new] assetForURL:url resultBlock:^(ALAsset *asset) {
				CLLocation *location = [asset valueForProperty:ALAssetPropertyLocation];
				if (location) {
					imageLocation = [NSString stringWithFormat:@"lat=%g\nlng=%g\n", location.coordinate.latitude, location.coordinate.longitude];
					imageData = info[UIImagePickerControllerOriginalImage];
					NSLog(@"imageData: %@", imageData);
				}
			} failureBlock:nil];
		}
	}

	[picker dismissViewControllerAnimated:YES completion:^{
		if (imageData) {
			NSLog(@"imageData: %@", imageData);
			UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Enter title for portal" message:nil delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
			alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
			[alertView textFieldAtIndex:0].placeholder = @"Enter portal title";
			[alertView show];
		} else {
			UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error getting photo" message:nil delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
			[alertView show];
		}
	}];

}

#pragma mark - UIAlertViewDelegate

- (BOOL)alertViewShouldEnableFirstOtherButton:(UIAlertView *)alertView {
	return ([alertView textFieldAtIndex:0].text.length > 0);
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (buttonIndex == 1) {
		if ([MFMailComposeViewController canSendMail]) {

			[[UINavigationBar appearance] setTitleTextAttributes:@{UITextAttributeFont: [UIFont boldSystemFontOfSize:18]}];
			[[UIBarButtonItem appearance] setTitleTextAttributes:@{UITextAttributeFont: [UIFont boldSystemFontOfSize:12]} forState:UIControlStateNormal];

			MFMailComposeViewController *mailVC = [MFMailComposeViewController new];
			[mailVC setMailComposeDelegate:self];
			[mailVC setToRecipients:@[@"super-ops@google.com"]];
			[mailVC setSubject:[alertView textFieldAtIndex:0].text];
			[mailVC setMessageBody:imageLocation isHTML:NO];
			[mailVC addAttachmentData:UIImageJPEGRepresentation(imageData, .75) mimeType:@"image/jpg" fileName:@"portal_image.jpg"];
			[self presentViewController:mailVC animated:YES completion:^{
				
				[[UINavigationBar appearance] setTitleTextAttributes:@{UITextAttributeFont: [UIFont fontWithName:@"Coda-Regular" size:16]}];
				[[UIBarButtonItem appearance] setTitleTextAttributes:@{UITextAttributeFont: [UIFont fontWithName:@"Coda-Regular" size:10]} forState:UIControlStateNormal];
				imageData = nil;
				imageLocation = nil;
				
			}];
		} else {
			UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error while sending mail" message:nil delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
			[alertView show];
		}
	}
}

#pragma mark - MFMailComposeViewControllerDelegate

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
	[controller dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Storyboard

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	if ([segue.identifier isEqualToString:@"ImagePickerSegue"]) {
		UIImagePickerController *vc = (UIImagePickerController *)segue.destinationViewController;
		vc.delegate = self;
	}
}

@end

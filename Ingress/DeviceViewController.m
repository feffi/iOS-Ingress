//
//  DeviceViewController.m
//  Ingress
//
//  Created by Alex Studnička on 02.05.13.
//  Copyright (c) 2013 A&A Code. All rights reserved.
//

#import "DeviceViewController.h"

@implementation DeviceViewController {
	NSData *imageData;
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
        case 3: {
            NSString *muteLabel = @"Mute Sound";
            float soundVolumeValue = [[NSUserDefaults standardUserDefaults] floatForKey:kDeviceSoundLevel];

            if(soundVolumeValue < 0.1){
                muteLabel = @"Unmute Sound";
            }
            
            cell.textLabel.text = muteLabel;
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

			[Item MR_truncateAll];
			[User MR_truncateAll];
			[DeployedMod MR_truncateAll];
			[DeployedResonator MR_truncateAll];
			[PortalLink MR_truncateAll];
			[ControlField MR_truncateAll];

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
            NSString *muteLabel = @"Unmute Sound";
            float currentSoundVolume = [SoundManager sharedManager].soundVolume;
            if (currentSoundVolume < 0.1){
                currentSoundVolume = 1.0;
                muteLabel = @"Mute Sound";
            } else {
                currentSoundVolume = 0.0;
            }
            
            UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
            cell.textLabel.text = muteLabel;
            
            [SoundManager sharedManager].soundVolume = currentSoundVolume;
            [SoundManager sharedManager].musicVolume = currentSoundVolume;
            
            [[NSUserDefaults standardUserDefaults] setFloat:currentSoundVolume forKey:kDeviceSoundLevel];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            break;
        }
	}
	
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {

	NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
	if ([mediaType isEqualToString:(NSString*)kUTTypeImage]) {
		NSURL *url = [info objectForKey:UIImagePickerControllerReferenceURL];
		if (url) {
			[[ALAssetsLibrary new] assetForURL:url resultBlock:^(ALAsset *asset) {
				CLLocation *location = [asset valueForProperty:ALAssetPropertyLocation];
				UIImage *image = info[@"UIImagePickerControllerOriginalImage"];
				imageData = [self geotagImage:image withLocation:location];
				NSLog(@"loc: %@", location);
			} failureBlock:^(NSError *error) {
				NSLog(@"cant get image - %@", [error localizedDescription]);
				imageData = nil;
			}];
		}
	}

	[picker dismissViewControllerAnimated:YES completion:^{
		if (imageData) {
			UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Enter title for portal" message:nil delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
			alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
			[alertView textFieldAtIndex:0].placeholder = @"Enter portal title";
			[alertView show];
		} else {
			UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error getting photo GPS coordinates" message:nil delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
			alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
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
			MFMailComposeViewController *mailVC = [MFMailComposeViewController new];
			[mailVC setMailComposeDelegate:self];
			[mailVC setToRecipients:@[@"super-ops@google.com"]];
			[mailVC setSubject:[alertView textFieldAtIndex:0].text];
			[mailVC addAttachmentData:imageData mimeType:@"image/jpg" fileName:@"portal_image.jpg"];
			[self presentViewController:mailVC animated:YES completion:nil];
			imageData = nil;
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

#pragma mark - UIImage with GPS

- (NSMutableArray *)createLocArray:(double)val{
    val = fabs(val);
    NSMutableArray* array = [[NSMutableArray alloc] init];
    double deg = (int)val;
    [array addObject:[NSNumber numberWithDouble:deg]];
    val = val - deg;
    val = val*60;
    double minutes = (int) val;
    [array addObject:[NSNumber numberWithDouble:minutes]];
    val = val - minutes;
    val = val*60;
    double seconds = val;
    [array addObject:[NSNumber numberWithDouble:seconds]];
    return array;
}

- (void)populateGPS:(EXFGPSLoc *)gpsLoc locArray:(NSArray *)locArray{
    long numDenumArray[2];
    long* arrPtr = numDenumArray;
    [EXFUtils convertRationalToFraction:&arrPtr :[locArray objectAtIndex:0]];
    EXFraction* fract = [[EXFraction alloc] initWith:numDenumArray[0]:numDenumArray[1]];
    gpsLoc.degrees = fract;
    [EXFUtils convertRationalToFraction:&arrPtr :[locArray objectAtIndex:1]];
    fract = [[EXFraction alloc] initWith:numDenumArray[0] :numDenumArray[1]];
    gpsLoc.minutes = fract;
    [EXFUtils convertRationalToFraction:&arrPtr :[locArray objectAtIndex:2]];
    fract = [[EXFraction alloc] initWith:numDenumArray[0] :numDenumArray[1]];
    gpsLoc.seconds = fract;
}

- (NSData *)geotagImage:(UIImage *)image withLocation:(CLLocation *)imageLocation {
    NSData *jpegData =  UIImageJPEGRepresentation(image, 0.8);
    EXFJpeg *jpegScanner = [EXFJpeg new];
    [jpegScanner scanImageData: jpegData];
    EXFMetaData* exifMetaData = jpegScanner.exifMetaData;
    // end of helper methods
    // adding GPS data to the Exif object
    NSMutableArray* locArray = [self createLocArray:imageLocation.coordinate.latitude];
    EXFGPSLoc* gpsLoc = [[EXFGPSLoc alloc] init];
    [self populateGPS:gpsLoc locArray:locArray];
    [exifMetaData addTagValue:gpsLoc forKey:[NSNumber numberWithInt:EXIF_GPSLatitude] ];
    locArray = [self createLocArray:imageLocation.coordinate.longitude];
    gpsLoc = [[EXFGPSLoc alloc] init];
    [self populateGPS:gpsLoc locArray:locArray];
    [exifMetaData addTagValue:gpsLoc forKey:[NSNumber numberWithInt:EXIF_GPSLongitude] ];
    NSString* ref;
    if (imageLocation.coordinate.latitude <0.0)
        ref = @"S";
    else
        ref =@"N";
    [exifMetaData addTagValue: ref forKey:[NSNumber numberWithInt:EXIF_GPSLatitudeRef] ];
    if (imageLocation.coordinate.longitude <0.0)
        ref = @"W";
    else
        ref =@"E";
    [exifMetaData addTagValue: ref forKey:[NSNumber numberWithInt:EXIF_GPSLongitudeRef] ];
    NSMutableData* taggedJpegData = [NSMutableData data];
    [jpegScanner populateImageData:taggedJpegData];
    return taggedJpegData;
}

@end

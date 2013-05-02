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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"DeviceCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];

    // Configure the cell...

    return cell;
}

/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
 {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
 }
 else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }
 }
 */

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
 {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}


#pragma mark - Action Sheet

- (IBAction)actionSheet {

	[[SoundManager sharedManager] playSound:@"Sound/sfx_ui_success.aif"];

	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Sign Out" otherButtonTitles:@"Submit Portal", nil];
	[actionSheet showFromTabBar:self.tabBarController.tabBar];
	
}

#pragma mark - Refresh Inventory

- (IBAction)refreshInventory {

	[[SoundManager sharedManager] playSound:@"Sound/sfx_ui_success.aif"];

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

}

#pragma mark - UIActionSheetDelegate

- (void)willPresentActionSheet:(UIActionSheet *)actionSheet {
    for (UIView *_currentView in actionSheet.subviews) {
        if ([_currentView isKindOfClass:[UILabel class]]) {
            ((UILabel *)_currentView).font = [UIFont fontWithName:[[[UILabel appearance] font] fontName] size:16];
        }
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {

	[[SoundManager sharedManager] playSound:@"Sound/sfx_ui_success.aif"];

	switch (buttonIndex) {
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
			alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
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

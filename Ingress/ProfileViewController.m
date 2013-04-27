//
//  StatsViewController.m
//  Ingress
//
//  Created by Alex Studnicka on 11.01.13.
//  Copyright (c) 2013 A&A Code. All rights reserved.
//

#import "ProfileViewController.h"
#import "DAKeyboardControl.h"

@implementation ProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	
	//[self.navigationController.navigationBar setTitleTextAttributes:@{UITextAttributeFont: [UIFont fontWithName:@"Coda-Regular" size:16]}];
	
	for (UINavigationController *navC in self.tabBarController.viewControllers) {
//		[navC.tabBarItem setTitleTextAttributes:@{UITextAttributeFont: [UIFont fontWithName:@"Coda-Regular" size:10]} forState:UIControlStateNormal];
		navC.topViewController.view.hidden = NO;
	}
	
	[self.tabBarController setSelectedIndex:2];
	
	[[SoundManager sharedManager] playMusic:@"Sound/sfx_ambient_scanner_base.aif" looping:YES];

	apLabel.font = [UIFont fontWithName:[[[UILabel appearance] font] fontName] size:13];
	xmLabel.font = [UIFont fontWithName:[[[UILabel appearance] font] fontName] size:13];
	
	passcodeTextField.font = [UIFont fontWithName:[[[UILabel appearance] font] fontName] size:15];
	submitPasscodeButton.titleLabel.font = [UIFont fontWithName:[[[UILabel appearance] font] fontName] size:15];
	
	levelLabel.font = [UIFont fontWithName:[[[UILabel appearance] font] fontName] size:32];
	nicknameLabel.font = [UIFont fontWithName:[[[UILabel appearance] font] fontName] size:20];
	
//	xmIndicator.backgroundColor = self.view.backgroundColor;
//	xmIndicator.frameColor = [UIColor colorWithRed:235./255. green:188./255. blue:74./255. alpha:1];
//	xmIndicator.foregroundColor = [UIColor colorWithRed:40./255. green:244./255. blue:40./255. alpha:1];
	
	__weak typeof(self) weakSelf = self;
	__weak typeof(passcodeContainerView) weakPasscodeContainerView = passcodeContainerView;
	
	[self.view setKeyboardTriggerOffset:32];
	[self.view addKeyboardPanningWithActionHandler:^(CGRect keyboardFrameInView) {
		CGRect passcodeContainerViewFrame = weakPasscodeContainerView.frame;
		if (keyboardFrameInView.origin.y > weakSelf.view.frame.size.height) {
			passcodeContainerViewFrame.origin.y = weakSelf.view.frame.size.height - passcodeContainerViewFrame.size.height;
		} else {
			passcodeContainerViewFrame.origin.y = keyboardFrameInView.origin.y - passcodeContainerViewFrame.size.height;
		}
		weakPasscodeContainerView.frame = passcodeContainerViewFrame;
	}];
	
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	[energyCollectLabel setText:[NSString stringWithFormat:@"%d / %d", [API sharedInstance].numberOfEnergyToCollect, [DB sharedInstance].numberOfEnergyGlobs]];
	[energyCollectStepper setValue:[API sharedInstance].numberOfEnergyToCollect];
	[energyCollectStepper setMaximumValue:[DB sharedInstance].numberOfEnergyGlobs];
	
//	[[NSNotificationCenter defaultCenter] addObserverForName:@"ProfileUpdatedNotification" object:nil queue:[[API sharedInstance] notificationQueue] usingBlock:^(NSNotification *note) {
//		//NSLog(@"ProfileUpdatedNotification");
//		dispatch_async(dispatch_get_main_queue(), ^{
//			[self refresh];
//		});
//	}];

	[self refresh];
	
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	
	//return;
	
	API *api = [API sharedInstance];
	int ap = [api.playerInfo[@"ap"] intValue];
	int level = [API levelForAp:ap];
	float energy = [api.playerInfo[@"energy"] floatValue];
	float maxEnergy = (float)[API maxXmForLevel:level];
	[xmIndicator setProgress:(energy/maxEnergy) animated:YES];

}

- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
	
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)refresh {
	
	API *api = [API sharedInstance];
	
	int ap = [api.playerInfo[@"ap"] intValue];
	int level = [API levelForAp:ap];
	int lvlImg = [API levelImageForAp:ap];
	int maxAp = [API maxApForLevel:level];
	int energy = [api.playerInfo[@"energy"] intValue];
	int maxEnergy = [API maxXmForLevel:level];
	
	NSMutableParagraphStyle *pStyle = [NSMutableParagraphStyle new];
    pStyle.alignment = NSTextAlignmentRight;
	
	UIColor *teamColor = [API colorForFaction:api.playerInfo[@"team"]];
	
	if ([api.playerInfo[@"team"] isEqualToString:@"ALIENS"]) {
		levelImage.image = [UIImage imageNamed:[NSString stringWithFormat:@"ap_icon_enl_%d.png", lvlImg]];
	} else {
		levelImage.image = [UIImage imageNamed:[NSString stringWithFormat:@"ap_icon_hum_%d.png", lvlImg]];
	}

	levelLabel.text = [NSString stringWithFormat:@"%d", level];
	
	nicknameLabel.textColor = teamColor;
	nicknameLabel.text = api.playerInfo[@"nickname"];

	NSArray *apLabelStrComps = @[[NSString stringWithFormat:@"%d AP\n", ap], @"[ ", [NSString stringWithFormat:@"%d AP", maxAp], [NSString stringWithFormat:@" required for level %d ]", level+1]];
	NSString *apLabelStr = [apLabelStrComps componentsJoinedByString:@""];
	
	NSMutableAttributedString *apLabelAtrStr = [[NSMutableAttributedString alloc] initWithString:apLabelStr attributes:@{NSFontAttributeName: [UIFont fontWithName:@"Coda-Regular" size:13], NSForegroundColorAttributeName: [UIColor colorWithRed:235./255. green:188./255. blue:74./255. alpha:1], NSParagraphStyleAttributeName: pStyle}];
	
	NSRange range = [apLabelAtrStr.string rangeOfString:apLabelStrComps[0] options:0 range:NSMakeRange(0, apLabelStr.length)];
	[apLabelAtrStr setAttributes:@{NSFontAttributeName: [UIFont fontWithName:@"Coda-Regular" size:13], NSForegroundColorAttributeName: teamColor, NSParagraphStyleAttributeName: pStyle} range:range];
	
	range = [apLabelAtrStr.string rangeOfString:apLabelStrComps[2] options:0 range:NSMakeRange(0, apLabelStr.length)];
	[apLabelAtrStr setAttributes:@{NSFontAttributeName: [UIFont fontWithName:@"Coda-Regular" size:13], NSForegroundColorAttributeName: teamColor, NSParagraphStyleAttributeName: pStyle} range:range];
	
	apLabel.attributedText = apLabelAtrStr;
	
	NSString *xmLabelStr = [NSString stringWithFormat:@"%d / %d XM", energy, maxEnergy];
	NSMutableAttributedString *xmLabelAtrStr = [[NSMutableAttributedString alloc] initWithString:xmLabelStr attributes:@{NSForegroundColorAttributeName: [UIColor colorWithRed:235./255. green:188./255. blue:74./255. alpha:1], NSFontAttributeName: [UIFont fontWithName:@"Coda-Regular" size:13], NSParagraphStyleAttributeName: pStyle}];
	[xmLabelAtrStr setAttributes:@{NSForegroundColorAttributeName: teamColor, NSFontAttributeName: [UIFont fontWithName:@"Coda-Regular" size:13], NSParagraphStyleAttributeName: pStyle} range:NSMakeRange(0, [[NSString stringWithFormat:@"%d", energy] length])];
	xmLabel.attributedText = xmLabelAtrStr;
	
	//CGRect rect = xmIndicatorInner.frame;
	//rect.size.width = (energy/maxEnergy) * (xmIndicatorOuter.frame.size.width-2);
	//xmIndicatorInner.frame = rect;
	
	xmIndicator.progressTintColor = teamColor;
	[xmIndicator setProgress:(energy/maxEnergy) animated:NO];
	
}

- (IBAction)submitPasscode {
	
	NSString *passcode = passcodeTextField.text;
	passcodeTextField.text = @"";
	[passcodeTextField resignFirstResponder];
	
	if (!passcode || passcode.length < 1) {
		[[SoundManager sharedManager] playSound:@"Sound/sfx_ui_fail.aif"];
		return;
	}
	
	[[SoundManager sharedManager] playSound:@"Sound/sfx_ui_success.aif"];
	
	MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:self.view.window];
	HUD.userInteractionEnabled = NO;
	HUD.labelText = @"Redeeming...";
	HUD.labelFont = [UIFont fontWithName:@"Coda-Regular" size:16];
	[self.view.window addSubview:HUD];
	[HUD show:YES];
	
	[[API sharedInstance] redeemReward:passcode completionHandler:^(BOOL accepted, NSString *response) {
		
		[HUD hide:YES];
		
		MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:self.view.window];
		HUD.userInteractionEnabled = NO;
		HUD.mode = MBProgressHUDModeCustomView;
		if (accepted) {
			HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"check.png"]];
		} else {
			HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"warning.png"]];
		}
		HUD.labelText = response;
		HUD.labelFont = [UIFont fontWithName:@"Coda-Regular" size:16];
		[self.view.window addSubview:HUD];
		[HUD show:YES];
		[HUD hide:YES afterDelay:2];
		
	}];

}

- (IBAction)energyCollectValueChanged:(UIStepper *)sender {
	[[SoundManager sharedManager] playSound:@"Sound/sfx_ui_success.aif"];
	//[energyCollectLabel setText:[NSString stringWithFormat:@"%d", (int)(sender.value)]];
	[API sharedInstance].numberOfEnergyToCollect = sender.value;
	[energyCollectLabel setText:[NSString stringWithFormat:@"%d / %d", [API sharedInstance].numberOfEnergyToCollect, [DB sharedInstance].numberOfEnergyGlobs]];
}

- (IBAction)actionSheet {
	
	[[SoundManager sharedManager] playSound:@"Sound/sfx_ui_success.aif"];

	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Sign Out" otherButtonTitles:@"Submit Portal", nil];
	[actionSheet showFromTabBar:self.tabBarController.tabBar];
	
}

#pragma mark -

- (IBAction)refreshInventory {

	[[SoundManager sharedManager] playSound:@"Sound/sfx_ui_success.aif"];

	__block MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:self.view];
	HUD.userInteractionEnabled = YES;
	HUD.dimBackground = YES;
	HUD.mode = MBProgressHUDModeIndeterminate;
	HUD.labelFont = [UIFont fontWithName:@"Coda-Regular" size:16];
	HUD.labelText = @"Loading inventory...";
	[self.view addSubview:HUD];
	[HUD show:YES];

	[[API sharedInstance] getInventoryWithCompletionHandler:^{
		[HUD hide:YES];
	}];

}

#pragma mark - UITextFieldDelegate

- (void)textFieldDidBeginEditing:(UITextField *)textField {
	
	[[SoundManager sharedManager] playSound:@"Sound/sfx_ui_success.aif"];
	
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	[self submitPasscode];
	return NO;
}

#pragma mark - UIActionSheetDelegate

- (void)willPresentActionSheet:(UIActionSheet *)actionSheet {
    for (UIView *_currentView in actionSheet.subviews) {
        if ([_currentView isKindOfClass:[UILabel class]]) {
            ((UILabel *)_currentView).font = [UIFont fontWithName:@"Coda-Regular" size:16];
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

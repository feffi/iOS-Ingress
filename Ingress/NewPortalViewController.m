//
//  NewPortalViewController.m
//  Ingress
//
//  Created by Alex Studnička on 30.06.13.
//  Copyright (c) 2013 A&A Code. All rights reserved.
//

#import "NewPortalViewController.h"
#import "NewPortalLocationViewController.h"

@implementation NewPortalViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	
	titleLabel.font = [UIFont fontWithName:[[[UILabel appearance] font] fontName] size:20];
	subtitleLabel.font = [UIFont fontWithName:[[[UILabel appearance] font] fontName] size:12];
	mapViewLabel.font = [UIFont fontWithName:[[[UILabel appearance] font] fontName] size:10];
	
	portalNameTextField.layer.borderWidth = 1;
	portalNameTextField.layer.borderColor = [UIColor colorWithRed:0 green:245./255. blue:253./255. alpha:1].CGColor;
	portalDescriptionTextField.layer.borderWidth = 1;
	portalDescriptionTextField.layer.borderColor = [UIColor colorWithRed:0 green:245./255. blue:253./255. alpha:1].CGColor;
	
	for (UIView *view in portalLocationMapView.subviews) {
		if ([view isKindOfClass:NSClassFromString(@"MKAttributionLabel")]) {
			[view removeFromSuperview];
		}
	}

}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(inputKeyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(inputKeyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
	
	[self.view addKeyboardPanningWithActionHandler:NULL];
	
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.1), dispatch_get_main_queue(), ^(void){
		
		portalImageView.image = self.portalImage;
		[portalLocationMapView setCenterCoordinate:self.portalLocation.coordinate zoomLevel:16 animated:NO];
		
		Player *player = [[API sharedInstance] playerForContext:[NSManagedObjectContext MR_contextForCurrentThread]];
		
		NSDateFormatter *dateFormatter = [NSDateFormatter new];
		[dateFormatter setDateFormat:@"MM.dd.yyyy HH:mm"];
		
		[subtitleLabel setText:[NSString stringWithFormat:@"by %@ at %@", player.nickname, [dateFormatter stringFromDate:[NSDate date]]]];
		
	});
}

- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
	
	[self.view removeKeyboardControl];
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLayoutSubviews {
	
	CGSize viewSize = self.view.frame.size;
	CGFloat width = ((viewSize.width-20)/2)-20;
	sendButton.frame = CGRectMake(20, viewSize.height-60, width, 40);
	cancelButton.frame = CGRectMake(width+40, viewSize.height-60, width, 40);
	UIScrollView *scrollView = (UIScrollView *)(self.view);
	scrollView.contentSize = viewSize;
	
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Keyboard

- (void)inputKeyboardWillShow:(NSNotification *)notification {
	UIScrollView *scrollView = (UIScrollView *)(self.view);
	scrollView.contentInset = UIEdgeInsetsMake(0, 0, 216, 0);
	scrollView.scrollIndicatorInsets = scrollView.contentInset;
}

- (void)inputKeyboardWillHide:(NSNotification *)notification {
	UIScrollView *scrollView = (UIScrollView *)(self.view);
	scrollView.contentInset = UIEdgeInsetsZero;
	scrollView.scrollIndicatorInsets = UIEdgeInsetsZero;
}

#pragma mark - IBActions

- (IBAction)selectLocation {
	if ([[NSUserDefaults standardUserDefaults] boolForKey:DeviceSoundToggleEffects]) {
		[[SoundManager sharedManager] playSound:@"Sound/sfx_ui_success.aif"];
	}
	
	UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil];
	NewPortalLocationViewController *newPortalLocationVC = [storyboard instantiateViewControllerWithIdentifier:@"NewPortalLocationViewController"];
	newPortalLocationVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
	newPortalLocationVC.portalLocation = self.portalLocation;
	newPortalLocationVC.delegate = self;
	[self presentViewController:newPortalLocationVC animated:YES completion:NULL];
}

- (IBAction)send {
	
	if (sendButton.disabled) { return; }

	unsigned long long min = 1000000000000000000U;
	unsigned long long max = 9999999999999999999U;
	unsigned long long rand = ABS((((float)arc4random()/0x100000000)*(max-min)+min));
	
	NSDateFormatter *dateFormatter = [NSDateFormatter new];
	[dateFormatter setDateFormat:@"yyyy_MM_dd_HH:mm:ss.SSSZ"]; //2013_06_30_20:12:05.156+0200
	NSString *photoRequestId = [NSString stringWithFormat:@"%lld_%@", rand, [dateFormatter stringFromDate:[NSDate date]]];
	
	CLLocationCoordinate2D coord = self.portalLocation.coordinate;
	NSString *location = [NSString stringWithFormat:@"%08x,%08x", (int)(coord.latitude*1E6), (int)(coord.longitude*1E6)];;
	
	NSDictionary *dict = @{
		@"title": portalNameTextField.text,
		@"curationReason": [NSNull null],
		@"curationType": @"NEW_SUBMISSION",
		@"description": portalDescriptionTextField.text,
		@"location": location,
		@"photoRequestId": photoRequestId,
		@"portalGuid": [NSNull null],
		@"addDirectlyToGame": @(NO),
	};
	
	MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:self.view.window];
	HUD.removeFromSuperViewOnHide = YES;
	HUD.userInteractionEnabled = YES;
	HUD.dimBackground = YES;
	HUD.mode = MBProgressHUDModeIndeterminate;
	HUD.labelFont = [UIFont fontWithName:[[[UILabel appearance] font] fontName] size:16];
	HUD.labelText = @"Submitting portal...";
	[self.view.window addSubview:HUD];
	[HUD show:YES];
	
	[[API sharedInstance] setPortalDetailsForCurationWithParams:dict completionHandler:^(NSString *errorStr) {
		
		[[API sharedInstance] getUploadUrl:^(NSString *url) {
			
			[[API sharedInstance] uploadPortalImage:self.portalImage toURL:url completionHandler:^{
				
				[[API sharedInstance] uploadPortalPhotoByUrlWithRequestId:photoRequestId imageUrl:url completionHandler:^(NSString *errorStr) {
					
					[HUD hide:YES];
					
					[self cancel];
					
					self.portalImage = nil;
					self.portalLocation = nil;
					
				}];
				
			}];

			
		}];
		
	}];

}

- (IBAction)cancel {
	[self dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
	if ([textField isEqual:portalNameTextField]) {
		int textLength = portalNameTextField.text.length - range.length + string.length;
		sendButton.enabled = textLength > 0;
	}
	return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	if ([textField isEqual:portalNameTextField]) {
		[portalDescriptionTextField becomeFirstResponder];
	} else if ([textField isEqual:portalDescriptionTextField]) {
		[portalDescriptionTextField resignFirstResponder];
	}
	return NO;
}

@end

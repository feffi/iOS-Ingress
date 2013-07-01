//
//  ItemsViewController.m
//  Ingress
//
//  Created by Alex Studnicka on 17.01.13.
//  Copyright (c) 2013 A&A Code. All rights reserved.
//

#import "ItemsViewController.h"
#import "DAKeyboardControl.h"
#import "TTUIScrollViewSlidingPages.h"
#import "ResourcesViewController.h"
#import "PortalKeysViewController.h"
#import "MediaItemsViewController.h"

@implementation ItemsViewController

- (void)viewDidLoad {
    [super viewDidLoad];

	TTScrollSlidingPagesController *slider = [TTScrollSlidingPagesController new];
	slider.titleScrollerHeight = 30;
    slider.labelsOffset = 0;
	slider.disableTitleScrollerShadow = YES;
	slider.disableUIPageControl = YES;
	slider.zoomOutAnimationDisabled = YES;
	slider.dataSource = self;
	CGRect frame = self.view.frame;
	frame.size.height -= passcodeContainerView.frame.size.height;
	slider.view.frame = frame;
	[self.view addSubview:slider.view];
	[self addChildViewController:slider];
	[self.view bringSubviewToFront:passcodeContainerView];

	passcodeTextField.font = [UIFont fontWithName:[[[UILabel appearance] font] fontName] size:15];
	submitPasscodeButton.titleLabel.font = [UIFont fontWithName:[[[UILabel appearance] font] fontName] size:15];

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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - TTSlidingPagesDataSource

- (int)numberOfPagesForSlidingPagesViewController:(TTScrollSlidingPagesController *)source {
    return 3;
}

- (TTSlidingPage *)pageForSlidingPagesViewController:(TTScrollSlidingPagesController*)source atIndex:(int)index{
    UIViewController *viewController;
	UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil];

	switch (index) {
		case 0:
			viewController = [storyboard instantiateViewControllerWithIdentifier:@"ResourcesViewController"];
			break;
		case 1:
			viewController = [storyboard instantiateViewControllerWithIdentifier:@"PortalKeysViewController"];
			break;
		case 2:
			viewController = [storyboard instantiateViewControllerWithIdentifier:@"MediaItemsViewController"];
			break;
	}

    return [[TTSlidingPage alloc] initWithContentViewController:viewController];
}

- (TTSlidingPageTitle *)titleForSlidingPagesViewController:(TTScrollSlidingPagesController *)source atIndex:(int)index{
    TTSlidingPageTitle *title;
	switch (index) {
		case 0:
			title = [[TTSlidingPageTitle alloc] initWithHeaderText:@"Resources"];
			break;
		case 1:
			title = [[TTSlidingPageTitle alloc] initWithHeaderText:@"Portal Keys"];
			break;
		case 2:
			title = [[TTSlidingPageTitle alloc] initWithHeaderText:@"Media"];
			break;
	}
    return title;
}

#pragma mark - UITextFieldDelegate

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    if ([[NSUserDefaults standardUserDefaults] boolForKey:DeviceSoundToggleEffects]) {
        [[SoundManager sharedManager] playSound:@"Sound/sfx_ui_success.aif"];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	[self submitPasscode];
	return NO;
}

#pragma mark - Passcode

- (IBAction)submitPasscode {

	NSString *passcode = passcodeTextField.text;
	passcodeTextField.text = @"";
	[passcodeTextField resignFirstResponder];

	if (!passcode || passcode.length < 1) {
        if ([[NSUserDefaults standardUserDefaults] boolForKey:DeviceSoundToggleEffects]) {
            [[SoundManager sharedManager] playSound:@"Sound/sfx_ui_fail.aif"];
        }
		return;
	}
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:DeviceSoundToggleEffects]) {
        [[SoundManager sharedManager] playSound:@"Sound/sfx_ui_success.aif"];
    }
    
	MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:self.view.window];
	HUD.removeFromSuperViewOnHide = YES;
	HUD.userInteractionEnabled = NO;
	HUD.labelText = @"Redeeming...";
	HUD.labelFont = [UIFont fontWithName:[[[UILabel appearance] font] fontName] size:16];
	[self.view.window addSubview:HUD];
	[HUD show:YES];

	[[API sharedInstance] redeemReward:passcode completionHandler:^(BOOL accepted, NSString *response) {

		[HUD hide:YES];

		MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:self.view.window];
		HUD.removeFromSuperViewOnHide = YES;
		HUD.userInteractionEnabled = NO;
		HUD.mode = MBProgressHUDModeCustomView;
		if (accepted) {
			HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"check.png"]];
		} else {
			HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"warning.png"]];
		}
		HUD.labelText = response;
		HUD.labelFont = [UIFont fontWithName:[[[UILabel appearance] font] fontName] size:16];
		[self.view.window addSubview:HUD];
		[HUD show:YES];
		[HUD hide:YES afterDelay:HUD_DELAY_TIME];

	}];

}

@end

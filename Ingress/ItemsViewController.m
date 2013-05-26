//
//  ItemsViewController.m
//  Ingress
//
//  Created by Alex Studnicka on 17.01.13.
//  Copyright (c) 2013 A&A Code. All rights reserved.
//

#import "ItemsViewController.h"
#import "ResourcesViewController.h"
#import "PortalKeysViewController.h"
#import "MediaItemsViewController.h"
#import "DAKeyboardControl.h"

@implementation ItemsViewController

- (void)viewDidLoad {
    [super viewDidLoad];

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

- (UIViewController *)childViewControllerWithClass:(Class)class {
	for (UIViewController *vc in self.childViewControllers) {
		if ([vc isKindOfClass:class]) {
			return vc;
		}
	}
	return nil;
}

- (IBAction)viewSegmentedControlChanged {
	
	[[SoundManager sharedManager] playSound:@"Sound/sfx_ui_success.aif"];
	
	switch (viewSegmentedControl.selectedSegmentIndex) {
		case 0:
			
			[[self childViewControllerWithClass:[ResourcesViewController class]] viewWillAppear:NO];
			[resourcesContainerView setHidden:NO];
			[[self childViewControllerWithClass:[ResourcesViewController class]] viewDidAppear:NO];
			[[(UITableViewController *)[self childViewControllerWithClass:[ResourcesViewController class]] tableView] setScrollsToTop:YES];

			[[(UITableViewController *)[self childViewControllerWithClass:[PortalKeysViewController class]] tableView] setScrollsToTop:NO];
			[[self childViewControllerWithClass:[PortalKeysViewController class]] viewWillDisappear:NO];
			[portalKeysContainerView setHidden:YES];
			[[self childViewControllerWithClass:[PortalKeysViewController class]] viewDidDisappear:NO];

			[[(UITableViewController *)[self childViewControllerWithClass:[MediaItemsViewController class]] tableView] setScrollsToTop:NO];
			[[self childViewControllerWithClass:[MediaItemsViewController class]] viewWillDisappear:NO];
			[mediaContainerView setHidden:YES];
			[[self childViewControllerWithClass:[MediaItemsViewController class]] viewDidDisappear:NO];
			
			break;
		case 1:
			
			[[self childViewControllerWithClass:[ResourcesViewController class]] viewWillDisappear:NO];
			[resourcesContainerView setHidden:YES];
			[[self childViewControllerWithClass:[ResourcesViewController class]] viewDidDisappear:NO];
			[[(UITableViewController *)[self childViewControllerWithClass:[ResourcesViewController class]] tableView] setScrollsToTop:NO];

			[[(UITableViewController *)[self childViewControllerWithClass:[PortalKeysViewController class]] tableView] setScrollsToTop:YES];
			[[self childViewControllerWithClass:[PortalKeysViewController class]] viewWillAppear:NO];
			[portalKeysContainerView setHidden:NO];
			[[self childViewControllerWithClass:[PortalKeysViewController class]] viewDidAppear:NO];
			
			[[self childViewControllerWithClass:[MediaItemsViewController class]] viewWillDisappear:NO];
			[mediaContainerView setHidden:YES];
			[[self childViewControllerWithClass:[MediaItemsViewController class]] viewDidDisappear:NO];
			[[(UITableViewController *)[self childViewControllerWithClass:[MediaItemsViewController class]] tableView] setScrollsToTop:NO];
			
			break;
		case 2:

			[[(UITableViewController *)[self childViewControllerWithClass:[ResourcesViewController class]] tableView] setScrollsToTop:NO];
			[[self childViewControllerWithClass:[ResourcesViewController class]] viewWillDisappear:NO];
			[resourcesContainerView setHidden:YES];
			[[self childViewControllerWithClass:[ResourcesViewController class]] viewDidDisappear:NO];

			[[(UITableViewController *)[self childViewControllerWithClass:[PortalKeysViewController class]] tableView] setScrollsToTop:NO];
			[[self childViewControllerWithClass:[PortalKeysViewController class]] viewWillDisappear:NO];
			[portalKeysContainerView setHidden:YES];
			[[self childViewControllerWithClass:[PortalKeysViewController class]] viewDidDisappear:NO];
			
			[[self childViewControllerWithClass:[MediaItemsViewController class]] viewWillAppear:NO];
			[mediaContainerView setHidden:NO];
			[[self childViewControllerWithClass:[MediaItemsViewController class]] viewDidAppear:NO];
			[[(UITableViewController *)[self childViewControllerWithClass:[MediaItemsViewController class]] tableView] setScrollsToTop:YES];
			
			break;
	}
	
}

#pragma mark - UITextFieldDelegate

- (void)textFieldDidBeginEditing:(UITextField *)textField {

	[[SoundManager sharedManager] playSound:@"Sound/sfx_ui_success.aif"];

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
		[[SoundManager sharedManager] playSound:@"Sound/sfx_ui_fail.aif"];
		return;
	}

	[[SoundManager sharedManager] playSound:@"Sound/sfx_ui_success.aif"];

	MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:self.view.window];
	HUD.userInteractionEnabled = NO;
	HUD.labelText = @"Redeeming...";
	HUD.labelFont = [UIFont fontWithName:[[[UILabel appearance] font] fontName] size:16];
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
		HUD.labelFont = [UIFont fontWithName:[[[UILabel appearance] font] fontName] size:16];
		[self.view.window addSubview:HUD];
		[HUD show:YES];
		[HUD hide:YES afterDelay:HUD_DELAY_TIME];

	}];

}

@end

//
//  CommViewController.m
//  Ingress
//
//  Created by Alex Studnicka on 10.01.13.
//  Copyright (c) 2013 A&A Code. All rights reserved.
//

#import "CommViewController.h"
#import "TTUIScrollViewSlidingPages.h"
#import "DAKeyboardControl.h"

@implementation CommViewController {
	
	BOOL hidden;
	
	TTScrollSlidingPagesController *slider;

	CommTableViewController *allTableView;
	CommTableViewController *factionTableView;

}

- (void)viewDidLoad {
    [super viewDidLoad];

	hidden = YES;

	UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil];

	allTableView = [storyboard instantiateViewControllerWithIdentifier:@"CommTableViewController"];
	allTableView.factionOnly = NO;
	
	factionTableView = [storyboard instantiateViewControllerWithIdentifier:@"CommTableViewController"];
	factionTableView.factionOnly = YES;

	slider = [TTScrollSlidingPagesController new];
	slider.titleScrollerHeight = 32;
	slider.labelsOffset = 0;
	slider.titleScrollerBackgroundColour = [UIColor clearColor];
	slider.titleScrollerTextColour = [UIColor colorWithRed:45./255. green:239./255. blue:249./255. alpha:1.0];
	slider.contentScrollerBackgroundColour = [UIColor colorWithRed:19./255. green:48./255. blue:63./255. alpha:1.0];
	slider.disableTitleScrollerShadow = YES;
	slider.disableTriangle = YES;
	slider.disableUIPageControl = YES;
	slider.zoomOutAnimationDisabled = YES;
	slider.dataSource = self;
	
	CGRect frame = self.view.bounds;
	frame.origin.y = 28;
	frame.size.height -= 60; //28+32
	slider.view.frame = frame;

	[self.view addSubview:slider.view];
	[self addChildViewController:slider];
	[self.view bringSubviewToFront:transmitContainerView];
	
	bgImageView.image = [[UIImage imageNamed:@"commBg.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(30, 200, 20, 100)];

	transmitTextField.font = [UIFont fontWithName:[[[UITextField appearance] font] fontName] size:15];
	transmitButton.titleLabel.font = [UIFont fontWithName:[[[UILabel appearance] font] fontName] size:15];
	showHideButton.titleLabel.font = [UIFont fontWithName:[[[UILabel appearance] font] fontName] size:16];
	
	__weak typeof(self) weakSelf = self;
	__weak typeof(transmitContainerView) weakTransmitContainerView = transmitContainerView;
	
	[self.view setKeyboardTriggerOffset:32];
	[self.view addKeyboardPanningWithActionHandler:^(CGRect keyboardFrameInView) {
		CGRect transmitContainerViewFrame = weakTransmitContainerView.frame;
		if (keyboardFrameInView.origin.y > weakSelf.view.frame.size.height) {
			transmitContainerViewFrame.origin.y = weakSelf.view.frame.size.height - transmitContainerViewFrame.size.height;
		} else {
			transmitContainerViewFrame.origin.y = keyboardFrameInView.origin.y - transmitContainerViewFrame.size.height;
		}
		weakTransmitContainerView.frame = transmitContainerViewFrame;
	}];
	
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];

	[[[GAI sharedInstance] defaultTracker] sendView:@"Comm Screen"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - TTSlidingPagesDataSource

- (int)numberOfPagesForSlidingPagesViewController:(TTScrollSlidingPagesController *)source {
    return 2;
}

- (TTSlidingPage *)pageForSlidingPagesViewController:(TTScrollSlidingPagesController*)source atIndex:(int)index{
    UIViewController *viewController;
	switch (index) {
		case 0:
			viewController = allTableView;
			break;
		case 1:
			viewController = factionTableView;
			break;
	}
    return [[TTSlidingPage alloc] initWithContentViewController:viewController];
}

- (TTSlidingPageTitle *)titleForSlidingPagesViewController:(TTScrollSlidingPagesController *)source atIndex:(int)index{
    TTSlidingPageTitle *title;
	switch (index) {
		case 0:
			title = [[TTSlidingPageTitle alloc] initWithHeaderText:@"All"];
			break;
		case 1:
			title = [[TTSlidingPageTitle alloc] initWithHeaderText:@"Faction"];
			break;
	}
    return title;
}

#pragma mark - IBActions

- (IBAction)showHide {

	if ([[NSUserDefaults standardUserDefaults] boolForKey:DeviceSoundToggleEffects]) {
        [[SoundManager sharedManager] playSound:@"Sound/sfx_ui_success.aif"];
    }

	[UIView animateWithDuration:.3 animations:^{
		CGFloat superViewHeight = self.view.superview.frame.size.height-20;
		CGRect frame = self.view.frame;
		if (hidden) {
			frame.origin.y = superViewHeight-373;
			[allTableView refresh];
			[factionTableView refresh];
		} else {
			frame.origin.y = superViewHeight-12;
			[transmitTextField resignFirstResponder];
		}
		self.view.frame = frame;
	} completion:^(BOOL finished) {
		hidden = !hidden;
	}];

}

- (void)mentionUser:(User *)user {
	NSString *mentionToken = [NSString stringWithFormat:@"@%@", user.nickname];
	NSString *input = [transmitTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];

	if ([input rangeOfString:mentionToken].location == NSNotFound) {
		input = [NSString stringWithFormat:@"%@%@%@ ", input, (input.length > 0) ? @" " : @"", mentionToken];
		transmitTextField.text = input;
	}

	[transmitTextField becomeFirstResponder];
}

- (IBAction)transmit {
	
	NSString *message = transmitTextField.text;
	transmitTextField.text = @"";
	[transmitTextField resignFirstResponder];
	
	if (!message || message.length < 1) {
        if ([[NSUserDefaults standardUserDefaults] boolForKey:DeviceSoundToggleEffects]) {
            [[SoundManager sharedManager] playSound:@"Sound/sfx_ui_fail.aif"];
        }
		return;
	}

	BOOL factionOnly = slider.getCurrentDisplayedPage;

	[[[GAI sharedInstance] defaultTracker] sendEventWithCategory:@"Game Action" withAction:@"Send Message" withLabel:nil withValue:@(factionOnly)];
	if ([[NSUserDefaults standardUserDefaults] boolForKey:DeviceSoundToggleEffects]) {
        [[SoundManager sharedManager] playSound:@"Sound/sfx_ui_success.aif"];
    }
    
	[[API sharedInstance] sendMessage:message factionOnly:factionOnly completionHandler:^{
		[allTableView refresh];
		[factionTableView refresh];
	}];

}

#pragma mark - UITextFieldDelegate

- (void)textFieldDidBeginEditing:(UITextField *)textField {
	if ([[NSUserDefaults standardUserDefaults] boolForKey:DeviceSoundToggleEffects]) {
        [[SoundManager sharedManager] playSound:@"Sound/sfx_ui_success.aif"];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	[self transmit];
	return NO;
}

@end

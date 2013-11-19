//
//  RecruitViewController.m
//  Ingress
//
//  Created by Alex Studnicka on 12.01.13.
//  Copyright (c) 2013 A&A Code. All rights reserved.
//

#import "RecruitViewController.h"
#import "DAKeyboardControl.h"


@implementation RecruitViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	
	inviteTextField.font = [UIFont fontWithName:[[[UITextField appearance] font] fontName] size:15];
	inviteButton.titleLabel.font = [UIFont fontWithName:[[[UILabel appearance] font] fontName] size:15];
	inviteLabel.font = [UIFont fontWithName:[[[UILabel appearance] font] fontName] size:12];
	
	__weak typeof(self) weakSelf = self;
	__weak typeof(inviteContainerView) weakInviteContainerView = inviteContainerView;
	
	[self.view setKeyboardTriggerOffset:32];
	[self.view addKeyboardPanningWithActionHandler:^(CGRect keyboardFrameInView) {
		CGRect inviteContainerViewFrame = weakInviteContainerView.frame;
		if (keyboardFrameInView.origin.y > weakSelf.view.frame.size.height) {
			inviteContainerViewFrame.origin.y = weakSelf.view.frame.size.height - inviteContainerViewFrame.size.height;
		} else {
			inviteContainerViewFrame.origin.y = keyboardFrameInView.origin.y - inviteContainerViewFrame.size.height;
		}
		weakInviteContainerView.frame = inviteContainerViewFrame;
	}];
	
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	[self loadNumberOfInvites];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadNumberOfInvites {
	
	MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:self.view];
	HUD.removeFromSuperViewOnHide = YES;
	HUD.userInteractionEnabled = NO;
	//HUD.labelText = @"Loading...";
	//HUD.labelFont = [UIFont fontWithName:[[[UILabel appearance] font] fontName] size:16];
	[self.view addSubview:HUD];
	[HUD show:YES];
	
	[[API sharedInstance] loadNumberOfInvitesWithCompletionHandler:^(int numberOfInvites) {
		
		[HUD hide:YES];
		
		[inviteLabel setText:[NSString stringWithFormat:@"%d invites remaining", numberOfInvites]];
		
	}];
	
}

- (IBAction)invite {
	
	NSString *email = inviteTextField.text;
	inviteTextField.text = @"";
	[inviteTextField resignFirstResponder];

	if (!email || email.length < 1) {
        if ([[NSUserDefaults standardUserDefaults] boolForKey:DeviceSoundToggleEffects]) {
            [[SoundManager sharedManager] playSound:@"Sound/sfx_ui_fail.aif"];
        }
		return;
	}
	
    if ([[NSUserDefaults standardUserDefaults] boolForKey:DeviceSoundToggleEffects]) {
        [[SoundManager sharedManager] playSound:@"Sound/sfx_ui_success.aif"];
    }
    
	[[[GAI sharedInstance] defaultTracker] sendEventWithCategory:@"Game Action" withAction:@"Recruit" withLabel:nil withValue:@(0)];
	
	MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:self.view];
	HUD.removeFromSuperViewOnHide = YES;
	HUD.userInteractionEnabled = NO;
	//HUD.labelText = @"Loading...";
	//HUD.labelFont = [UIFont fontWithName:[[[UILabel appearance] font] fontName] size:16];
	[self.view addSubview:HUD];
	[HUD show:YES];
	
	[[API sharedInstance] inviteUserWithEmail:email completionHandler:^(NSString *errorStr, int numberOfInvites) {
		
		[HUD hide:YES];
		
		[inviteLabel setText:[NSString stringWithFormat:@"%d invites remaining", numberOfInvites]];

		if (errorStr && errorStr.length > 0) {
			[Utilities showWarningWithTitle:errorStr];
		}
		
	}];
	
}

#pragma mark - UITextFieldDelegate

- (void)textFieldDidBeginEditing:(UITextField *)textField {
	if ([[NSUserDefaults standardUserDefaults] boolForKey:DeviceSoundToggleEffects]) {
        [[SoundManager sharedManager] playSound:@"Sound/sfx_ui_success.aif"];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	[self invite];
	return NO;
}

@end

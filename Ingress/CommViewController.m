//
//  CommViewController.m
//  Ingress
//
//  Created by Alex Studnicka on 10.01.13.
//  Copyright (c) 2013 A&A Code. All rights reserved.
//

#import "CommViewController.h"
#import "DAKeyboardControl.h"

@implementation CommViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view.
	commTableVC =  self.childViewControllers[0];
	
	[groupSegments setTitleTextAttributes:@{UITextAttributeFont: [UIFont fontWithName:[[[UILabel appearance] font] fontName] size:12]} forState:UIControlStateNormal];
	
	transmitTextField.font = [UIFont fontWithName:[[[UITextField appearance] font] fontName] size:15];
	transmitButton.titleLabel.font = [UIFont fontWithName:[[[UILabel appearance] font] fontName] size:15];
	
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

- (IBAction)groupChanged:(UISegmentedControl *)sender {
	[commTableVC setFactionOnly:sender.selectedSegmentIndex];
	if ([[NSUserDefaults standardUserDefaults] boolForKey:DeviceSoundToggleEffects]) {
        [[SoundManager sharedManager] playSound:@"Sound/sfx_ui_success.aif"];
    }
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

	[[[GAI sharedInstance] defaultTracker] sendEventWithCategory:@"Game Action" withAction:@"Send Message" withLabel:nil withValue:@(commTableVC.factionOnly)];
	if ([[NSUserDefaults standardUserDefaults] boolForKey:DeviceSoundToggleEffects]) {
        [[SoundManager sharedManager] playSound:@"Sound/sfx_ui_success.aif"];
    }
    
	[[API sharedInstance] sendMessage:message factionOnly:commTableVC.factionOnly completionHandler:^{
		[commTableVC refresh];
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

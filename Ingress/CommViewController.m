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
	
	[groupSegments setTitleTextAttributes:@{UITextAttributeFont: [UIFont fontWithName:@"Coda-Regular" size:12]} forState:UIControlStateNormal];
	
	transmitTextField.font = [UIFont fontWithName:@"Coda-Regular" size:15];
	transmitButton.titleLabel.font = [UIFont fontWithName:@"Coda-Regular" size:15];
	
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)groupChanged:(UISegmentedControl *)sender {
	[commTableVC setFactionOnly:sender.selectedSegmentIndex];
	[commTableVC refresh];
	
	[[SoundManager sharedManager] playSound:@"Sound/sfx_ui_success.aif"];
}

- (IBAction)transmit {
	
	NSString *message = transmitTextField.text;
	transmitTextField.text = @"";
	[transmitTextField resignFirstResponder];
	
	if (!message || message.length < 1) {
		[[SoundManager sharedManager] playSound:@"Sound/sfx_ui_fail.aif"];
		return;
	}
	
	[[SoundManager sharedManager] playSound:@"Sound/sfx_ui_success.aif"];
	
	[[API sharedInstance] sendMessage:message factionOnly:commTableVC.factionOnly completionHandler:^{
		[commTableVC refresh];
	}];

}

#pragma mark - UITextFieldDelegate

- (void)textFieldDidBeginEditing:(UITextField *)textField {
	
	[[SoundManager sharedManager] playSound:@"Sound/sfx_ui_success.aif"];
	
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	[self transmit];
	return NO;
}

@end

//
//  ItemsViewController.h
//  Ingress
//
//  Created by Alex Studnicka on 17.01.13.
//  Copyright (c) 2013 A&A Code. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ItemsViewController : UIViewController <UITextFieldDelegate> {
	
	__weak IBOutlet UISegmentedControl *viewSegmentedControl;
	
	__weak IBOutlet UIView *resourcesContainerView;
	__weak IBOutlet UIView *portalKeysContainerView;
	__weak IBOutlet UIView *mediaContainerView;

	__weak IBOutlet UIView *passcodeContainerView;
	__weak IBOutlet UITextField *passcodeTextField;
	__weak IBOutlet UIButton *submitPasscodeButton;
	
}

- (IBAction)viewSegmentedControlChanged;

- (IBAction)submitPasscode;

@end

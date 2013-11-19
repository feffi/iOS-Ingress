//
//  ItemsViewController.h
//  Ingress
//
//  Created by Alex Studnicka on 17.01.13.
//  Copyright (c) 2013 A&A Code. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TTSlidingPagesDataSource.h"

@interface ItemsViewController : UIViewController <UITextFieldDelegate, TTSlidingPagesDataSource> {

	__weak IBOutlet UIView *passcodeContainerView;
	__weak IBOutlet UITextField *passcodeTextField;
	__weak IBOutlet UIButton *submitPasscodeButton;
	
}

- (IBAction)submitPasscode;

@end

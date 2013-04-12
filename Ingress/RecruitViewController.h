//
//  RecruitViewController.h
//  Ingress
//
//  Created by Alex Studnicka on 12.01.13.
//  Copyright (c) 2013 A&A Code. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RecruitViewController : UIViewController <UITextFieldDelegate> {
	
	__weak IBOutlet UIView *inviteContainerView;
	__weak IBOutlet UITextField *inviteTextField;
	__weak IBOutlet UIButton *inviteButton;
	__weak IBOutlet UILabel *inviteLabel;
	
}

- (IBAction)invite;

@end

//
//  CommViewController.h
//  Ingress
//
//  Created by Alex Studnicka on 10.01.13.
//  Copyright (c) 2013 A&A Code. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CommTableViewController.h"
#import "TTSlidingPagesDataSource.h"

@interface CommViewController : UIViewController <UITextFieldDelegate, TTSlidingPagesDataSource> {
	
//	CommTableViewController *commTableVC;
//	__weak IBOutlet UISegmentedControl *groupSegments;

	__weak IBOutlet UIView *transmitContainerView;
	__weak IBOutlet UITextField *transmitTextField;
	__weak IBOutlet UIButton *transmitButton;

	__weak IBOutlet UIImageView *bgImageView;
	__weak IBOutlet UIButton *showHideButton;

}

- (IBAction)showHide;
//- (IBAction)groupChanged:(UISegmentedControl *)sender;
- (void)mentionUser:(User *)user;
- (IBAction)transmit;

@end

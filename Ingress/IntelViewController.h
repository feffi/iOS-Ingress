//
//  IntelViewController.h
//  Ingress
//
//  Created by Alex Studnicka on 12.01.13.
//  Copyright (c) 2013 A&A Code. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IntelViewController : UIViewController {
	
	__weak IBOutlet UISegmentedControl *viewSegmentedControl;
	
	__weak IBOutlet UIView *scoreContainerView;
	__weak IBOutlet UIView *missionsContainerView;
	__weak IBOutlet UIView *recruitContainerView;
	
}

- (IBAction)viewSegmentedControlChanged;

@end

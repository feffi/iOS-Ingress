//
//  ItemsViewController.h
//  Ingress
//
//  Created by Alex Studnicka on 17.01.13.
//  Copyright (c) 2013 A&A Code. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ItemsViewController : UIViewController {
	
	__weak IBOutlet UISegmentedControl *viewSegmentedControl;
	
	__weak IBOutlet UIView *resourcesContainerView;
	__weak IBOutlet UIView *portalKeysContainerView;
	__weak IBOutlet UIView *mediaContainerView;
	
}

- (IBAction)viewSegmentedControlChanged;

@end

//
//  PortalDetailViewController.h
//  Ingress
//
//  Created by Alex Studnicka on 14.01.13.
//  Copyright (c) 2013 A&A Code. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PortalActionsViewController.h"
#import "PortalInfoViewController.h"
#import "PortalUpgradeViewController.h"

@interface PortalDetailViewController : UIViewController <UIScrollViewDelegate> {

	UIScrollView *_scrollView;
	UISegmentedControl *viewSegmentedControl;

	PortalActionsViewController *portalActionsVC;
	PortalInfoViewController *portalInfoVC;
	PortalUpgradeViewController *portalUpgradeVC;

}

@property (nonatomic, assign) Portal *portal;

@end

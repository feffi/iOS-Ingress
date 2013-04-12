//
//  PortalDetailViewController.m
//  Ingress
//
//  Created by Alex Studnicka on 14.01.13.
//  Copyright (c) 2013 A&A Code. All rights reserved.
//

#import "PortalDetailViewController.h"
#import "PortalInfoViewController.h"
#import "PortalUpgradeViewController.h"

@implementation PortalDetailViewController

@synthesize portal = _portal;

- (void)viewDidLoad {
	[super viewDidLoad];
	
	[viewSegmentedControl setTitleTextAttributes:@{UITextAttributeFont: [UIFont fontWithName:@"Coda-Regular" size:10]} forState:UIControlStateNormal];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];

//	[[NSNotificationCenter defaultCenter] addObserverForName:@"PortalChanged" object:nil queue:[API sharedInstance].notificationQueue usingBlock:^(NSNotification *note) {
//		Portal *newPortal = note.userInfo[@"portal"];
//		if (newPortal && [newPortal isKindOfClass:[PortalItem class]] && [newPortal.guid isEqualToString:self.portal.guid]) {
//			self.portal = note.userInfo[@"portal"];
//		}
//	}];
	
	PortalInfoViewController *vc1 = (PortalInfoViewController *)[self childViewControllerWithClass:[PortalInfoViewController class]];
	vc1.portal = self.portal;
	vc1.mapCenterCoordinate = self.mapCenterCoordinate;
	
	PortalUpgradeViewController *vc2 = (PortalUpgradeViewController *)[self childViewControllerWithClass:[PortalUpgradeViewController class]];
	vc2.portal = self.portal;
	vc2.mapCenterCoordinate = self.mapCenterCoordinate;
	
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	
	if (self.isMovingFromParentViewController) {
		[[SoundManager sharedManager] playSound:@"Sound/sfx_ui_success.aif"];
	}
}

- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
	
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -

- (UIViewController *)childViewControllerWithClass:(Class)class {
	for (UIViewController *vc in self.childViewControllers) {
		if ([vc isKindOfClass:class]) {
			return vc;
		}
	}
	return nil;
}

- (IBAction)viewSegmentedControlChanged {
	
	[[SoundManager sharedManager] playSound:@"Sound/sfx_ui_success.aif"];
	
	switch (viewSegmentedControl.selectedSegmentIndex) {
		case 0:
			
			[[self childViewControllerWithClass:[PortalInfoViewController class]] viewWillAppear:NO];
			[infoContainerView setHidden:NO];
			[[self childViewControllerWithClass:[PortalInfoViewController class]] viewDidAppear:NO];
			
			[[self childViewControllerWithClass:[PortalUpgradeViewController class]] viewWillDisappear:NO];
			[upgradeContainerView setHidden:YES];
			[[self childViewControllerWithClass:[PortalUpgradeViewController class]] viewDidDisappear:NO];
			
			break;
		case 1:
			
			[[self childViewControllerWithClass:[PortalInfoViewController class]] viewWillDisappear:NO];
			[infoContainerView setHidden:YES];
			[[self childViewControllerWithClass:[PortalInfoViewController class]] viewDidDisappear:NO];
			
			[[self childViewControllerWithClass:[PortalUpgradeViewController class]] viewWillAppear:NO];
			[upgradeContainerView setHidden:NO];
			[[self childViewControllerWithClass:[PortalUpgradeViewController class]] viewDidAppear:NO];
			
			break;
	}
	
}

@end

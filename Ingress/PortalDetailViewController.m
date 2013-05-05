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

@synthesize portalInfoVC = _portalInfoVC;

@synthesize portal = _portal;
@synthesize mapCenterCoordinate = _mapCenterCoordinate;

- (void)viewDidLoad {
	[super viewDidLoad];

	CGSize screenSize = [UIScreen mainScreen].bounds.size;

	CGRect backgroundRect = CGRectMake(0, 0, screenSize.width, screenSize.height-113);
	UIImageView *backgroundImageView = [[UIImageView alloc] initWithFrame:backgroundRect];
	backgroundImageView.image = [UIImage imageNamed:@"missing_image"];
	backgroundImageView.contentMode = UIViewContentModeScaleAspectFill;

	infoContainerView = [[MDCParallaxView alloc] initWithBackgroundView:backgroundImageView foregroundView:self.portalInfoVC.view];
	infoContainerView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
	infoContainerView.backgroundColor = [UIColor colorWithRed:16.0/255.0 green:32.0/255.0 blue:34.0/255.0 alpha:1];
	infoContainerView.scrollView.scrollsToTop = YES;
	infoContainerView.scrollView.alwaysBounceVertical = YES;
	infoContainerView.backgroundInteractionEnabled = NO;

	infoContainerView.frame = CGRectMake(0, 0, screenSize.width, screenSize.height-113);
	infoContainerView.backgroundHeight = screenSize.height-113-280;

	self.portalInfoVC.portal = self.portal;
	self.portalInfoVC.mapCenterCoordinate = self.mapCenterCoordinate;
	self.portalInfoVC.view.frame = CGRectMake(0, 0, screenSize.width, 280);

	self.portalInfoVC.imageView = backgroundImageView;

	[self addChildViewController:self.portalInfoVC];
	[self.view addSubview:infoContainerView];

}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];

//	[[NSNotificationCenter defaultCenter] addObserverForName:@"PortalChanged" object:nil queue:[API sharedInstance].notificationQueue usingBlock:^(NSNotification *note) {
//		Portal *newPortal = note.userInfo[@"portal"];
//		if (newPortal && [newPortal isKindOfClass:[PortalItem class]] && [newPortal.guid isEqualToString:self.portal.guid]) {
//			self.portal = note.userInfo[@"portal"];
//		}
//	}];
	
//	PortalInfoViewController *vc1 = (PortalInfoViewController *)[self childViewControllerWithClass:[PortalInfoViewController class]];
//	vc1.portal = self.portal;
//	vc1.mapCenterCoordinate = self.mapCenterCoordinate;



//	CGPoint bottomOffset = CGPointMake(0, infoContainerView.scrollView.contentSize.height - infoContainerView.scrollView.bounds.size.height);
//	[infoContainerView.scrollView setContentOffset:bottomOffset animated:NO];

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

#pragma mark - Portal Info View Controller

- (PortalInfoViewController *)portalInfoVC {
	if (!_portalInfoVC) {
		UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil];
		_portalInfoVC = [storyboard instantiateViewControllerWithIdentifier:@"PortalInfoViewController"];
	}
	return _portalInfoVC;
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

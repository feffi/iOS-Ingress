//
//  PortalDetailViewController.m
//  Ingress
//
//  Created by Alex Studnicka on 14.01.13.
//  Copyright (c) 2013 A&A Code. All rights reserved.
//

#import "PortalDetailViewController.h"
#import "MDCParallaxView.h"

@implementation PortalDetailViewController {
	BOOL pageControlUsed;
}

@synthesize portal = _portal;

- (void)viewDidLoad {
	[super viewDidLoad];

	Player *player = [[API sharedInstance] playerForContext:[NSManagedObjectContext MR_contextForCurrentThread]];

	BOOL canUpgrade = (self.portal.controllingTeam && ([self.portal.controllingTeam isEqualToString:player.team] || [self.portal.controllingTeam isEqualToString:@"NEUTRAL"]));

	viewSegmentedControl = [[UISegmentedControl alloc] initWithItems:@[@"Actions", @"Info"]];
	viewSegmentedControl.segmentedControlStyle = UISegmentedControlStyleBar;
	viewSegmentedControl.tintColor = [UIColor darkGrayColor];
	if (canUpgrade) {
		[viewSegmentedControl insertSegmentWithTitle:@"Upgrade" atIndex:2 animated:NO];
	}
	[viewSegmentedControl setApportionsSegmentWidthsByContent:NO];
	[viewSegmentedControl setSelectedSegmentIndex:0];
	[viewSegmentedControl addTarget:self action:@selector(viewSegmentedControlChanged) forControlEvents:UIControlEventValueChanged];
	self.navigationItem.titleView = viewSegmentedControl;

	CGFloat viewWidth = [UIScreen mainScreen].bounds.size.width;
	CGFloat viewHeight = [UIScreen mainScreen].bounds.size.height-49; //-113+44+20
	CGFloat topPadding = 0;

	if ([Utilities isOS7]) {
		viewHeight -= 64;
	} else {
		viewHeight -= 49;
		topPadding = 64;
	}

	_scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, viewWidth, viewHeight)];
	_scrollView.delegate = self;
	_scrollView.pagingEnabled = YES;
	_scrollView.showsHorizontalScrollIndicator = NO;
	_scrollView.backgroundColor = self.view.backgroundColor;
	_scrollView.contentSize = CGSizeMake(viewWidth*(2+canUpgrade), viewHeight);
	[self.view addSubview:_scrollView];

	CGRect backgroundRect = CGRectMake(0, 0, viewWidth, viewHeight);
	UIImageView *backgroundImageView = [[UIImageView alloc] initWithFrame:backgroundRect];
	backgroundImageView.image = [UIImage imageNamed:@"missing_image"];
	backgroundImageView.contentMode = UIViewContentModeScaleAspectFill;

	UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil];
	
	portalActionsVC = [storyboard instantiateViewControllerWithIdentifier:@"PortalActionsViewController"];
	MDCParallaxView *infoContainerView = [[MDCParallaxView alloc] initWithBackgroundView:backgroundImageView foregroundView:portalActionsVC.view];
	infoContainerView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
	infoContainerView.backgroundColor = [UIColor colorWithRed:16.0/255.0 green:32.0/255.0 blue:34.0/255.0 alpha:1];
	infoContainerView.scrollView.scrollsToTop = YES;
	infoContainerView.scrollView.alwaysBounceVertical = YES;
	infoContainerView.backgroundInteractionEnabled = NO;
	infoContainerView.frame = CGRectMake(0, 0, viewWidth, viewHeight);
	infoContainerView.backgroundHeight = viewHeight-280;
	portalActionsVC.portal = self.portal;
	portalActionsVC.view.frame = CGRectMake(0, 0, viewWidth, 280);
	portalActionsVC.imageView = backgroundImageView;
	[self addChildViewController:portalActionsVC];
	[_scrollView addSubview:infoContainerView];

	portalInfoVC = [storyboard instantiateViewControllerWithIdentifier:@"PortalInfoViewController"];
	portalInfoVC.portal = self.portal;
	portalInfoVC.view.frame = CGRectMake(viewWidth, topPadding, viewWidth, viewHeight-64);
	[self addChildViewController:portalInfoVC];
	[_scrollView addSubview:portalInfoVC.view];

	if (canUpgrade) {
		portalUpgradeVC = [storyboard instantiateViewControllerWithIdentifier:@"PortalUpgradeViewController"];
		portalUpgradeVC.portal = self.portal;
		portalUpgradeVC.view.frame = CGRectMake(viewWidth*2, topPadding, viewWidth, viewHeight-64);
		[self addChildViewController:portalUpgradeVC];
		[_scrollView addSubview:portalUpgradeVC.view];
	}

	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(managedObjectContextObjectsDidChange:) name:NSManagedObjectContextObjectsDidChangeNotification object:nil];

}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];

	[[[GAI sharedInstance] defaultTracker] sendView:@"Portal Detail Screen"];

	if (self.isMovingFromParentViewController) {
        if ([[NSUserDefaults standardUserDefaults] boolForKey:DeviceSoundToggleEffects]) {
            [[SoundManager sharedManager] playSound:@"Sound/sfx_ui_success.aif"];
        }
	}
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - NSManagedObjectContext Did Change

- (void)managedObjectContextObjectsDidChange:(NSNotification *)notification {
	if ([notification.userInfo[NSUpdatedObjectsKey] containsObject:self.portal]) {
		[portalActionsVC refresh];
		[portalInfoVC refresh];
		[portalUpgradeVC refresh];
	}
}

#pragma mark - Segmented Control Changed

- (void)viewSegmentedControlChanged {
    if ([[NSUserDefaults standardUserDefaults] boolForKey:DeviceSoundToggleEffects]) {
        [[SoundManager sharedManager] playSound:@"Sound/sfx_ui_success.aif"];
    }
    
	pageControlUsed = YES;
    CGFloat pageWidth = _scrollView.contentSize.width /viewSegmentedControl.numberOfSegments;
    CGFloat x = viewSegmentedControl.selectedSegmentIndex * pageWidth;
    [_scrollView scrollRectToVisible:CGRectMake(x, 0, pageWidth, _scrollView.contentSize.height) animated:YES];
}

#pragma mark - UIScrollViewDelegate

//- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
//    pageControlUsed = NO;
//}
//
//- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
//    if (!pageControlUsed) {
//        viewSegmentedControl.selectedSegmentIndex = lround(_scrollView.contentOffset.x / (_scrollView.contentSize.width / 2));
//	}
//}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (pageControlUsed) return;
    CGFloat pageWidth = _scrollView.frame.size.width;
    viewSegmentedControl.selectedSegmentIndex = floor((_scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    pageControlUsed = NO;
}


@end

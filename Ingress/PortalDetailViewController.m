//
//  PortalDetailViewController.m
//  Ingress
//
//  Created by Alex Studnicka on 14.01.13.
//  Copyright (c) 2013 A&A Code. All rights reserved.
//

#import "PortalDetailViewController.h"
#import "TTUIScrollViewSlidingPages.h"

@implementation PortalDetailViewController {
	BOOL pageControlUsed;
}

@synthesize portal = _portal;

- (void)viewDidLoad {
	[super viewDidLoad];

	CGFloat viewWidth = [UIScreen mainScreen].bounds.size.width;
	CGFloat viewHeight = [UIScreen mainScreen].bounds.size.height-20;

	CGRect backgroundRect = CGRectMake(0, 0, viewWidth, viewHeight);
	UIImageView *backgroundImageView = [[UIImageView alloc] initWithFrame:backgroundRect];
	backgroundImageView.image = [UIImage imageNamed:@"missing_image"];
	backgroundImageView.contentMode = UIViewContentModeScaleAspectFill;

	UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil];
	
	portalActionsVC = [storyboard instantiateViewControllerWithIdentifier:@"PortalActionsViewController"];
	infoContainerView = [[MDCParallaxView alloc] initWithBackgroundView:backgroundImageView foregroundView:portalActionsVC.view];
	infoContainerView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
	infoContainerView.backgroundColor = [UIColor colorWithRed:16.0/255.0 green:32.0/255.0 blue:34.0/255.0 alpha:1];
	infoContainerView.scrollView.scrollsToTop = YES;
	infoContainerView.scrollView.alwaysBounceVertical = YES;
	infoContainerView.backgroundInteractionEnabled = NO;
	infoContainerView.backgroundHeight = viewHeight-64-280;
	infoContainerView.frame = CGRectMake(0, 0, viewWidth, viewHeight);
	portalActionsVC.portal = self.portal;
	portalActionsVC.view.frame = CGRectMake(0, 0, viewWidth, 280);
	portalActionsVC.imageView = backgroundImageView;
	[self addChildViewController:portalActionsVC];

	portalInfoVC = [storyboard instantiateViewControllerWithIdentifier:@"PortalInfoViewController"];
	portalInfoVC.portal = self.portal;
	[self addChildViewController:portalInfoVC];

	if (self.canUpgrade) {
		portalUpgradeVC = [storyboard instantiateViewControllerWithIdentifier:@"PortalUpgradeViewController"];
		portalUpgradeVC.portal = self.portal;
		[self addChildViewController:portalUpgradeVC];
	}

	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(managedObjectContextObjectsDidChange:) name:NSManagedObjectContextObjectsDidChangeNotification object:nil];

	TTScrollSlidingPagesController *slider = [TTScrollSlidingPagesController new];
	slider.titleScrollerHeight = 64;
	slider.disableTitleScrollerShadow = YES;
	slider.disableUIPageControl = YES;
	slider.zoomOutAnimationDisabled = YES;
	slider.dataSource = self;
	slider.view.frame = CGRectMake(0, 20, viewWidth, viewHeight);
	slider.view.backgroundColor = [UIColor colorWithRed:16./255. green:32./255. blue:34./255. alpha:1.0];
	[self.view addSubview:slider.view];
	[self.view sendSubviewToBack:slider.view];
	[self addChildViewController:slider];

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

#pragma mark - 

- (BOOL)canUpgrade {
	Player *player = [[API sharedInstance] playerForContext:[NSManagedObjectContext MR_contextForCurrentThread]];
	return (self.portal.isInPlayerRange && ((self.portal.controllingTeam && ([self.portal.controllingTeam isEqualToString:player.team] || [self.portal.controllingTeam isEqualToString:@"NEUTRAL"]))));
}

#pragma mark - NSManagedObjectContext Did Change

- (void)managedObjectContextObjectsDidChange:(NSNotification *)notification {
	if ([notification.userInfo[NSUpdatedObjectsKey] containsObject:self.portal]) {
		[portalActionsVC refresh];
		[portalInfoVC refresh];
		[portalUpgradeVC refresh];

	}
}

#pragma mark - Back

- (IBAction)back:(UIBarButtonItem *)sender {
    if ([[NSUserDefaults standardUserDefaults] boolForKey:DeviceSoundToggleEffects]) {
        [[SoundManager sharedManager] playSound:@"Sound/sfx_ui_back.aif"];
    }

	[self dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark - TTSlidingPagesDataSource

- (int)numberOfPagesForSlidingPagesViewController:(TTScrollSlidingPagesController *)source {
	return 2+self.canUpgrade;
}

- (TTSlidingPage *)pageForSlidingPagesViewController:(TTScrollSlidingPagesController*)source atIndex:(int)index{
	switch (index) {
		case 0:
			return [[TTSlidingPage alloc] initWithContentView:infoContainerView];
		case 1:
			return [[TTSlidingPage alloc] initWithContentViewController:portalInfoVC];
		case 2:
			return [[TTSlidingPage alloc] initWithContentViewController:portalUpgradeVC];
	}
	return nil;
}

- (TTSlidingPageTitle *)titleForSlidingPagesViewController:(TTScrollSlidingPagesController *)source atIndex:(int)index{
    TTSlidingPageTitle *title;
	switch (index) {
		case 0:
			title = [[TTSlidingPageTitle alloc] initWithHeaderText:@"Actions"];
			break;
		case 1:
			title = [[TTSlidingPageTitle alloc] initWithHeaderText:@"Info"];
			break;
		case 2:
			title = [[TTSlidingPageTitle alloc] initWithHeaderText:@"Upgrade"];
			break;
	}
    return title;
}

@end

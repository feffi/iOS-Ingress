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
	
	opsLabel.rightInset = 10;
	labelBackgroundImage.image = [[UIImage imageNamed:@"ops_background.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(2, 2, 2, 236)];
	
	CGFloat statusBarHeight = [Utilities statusBarHeight];
	CGFloat viewWidth = [UIScreen mainScreen].bounds.size.width;
	CGFloat viewHeight = [UIScreen mainScreen].bounds.size.height-statusBarHeight;

	CGRect backgroundRect = CGRectMake(0, statusBarHeight, viewWidth, viewHeight);
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
	slider.labelsOffset = 30;
	slider.disableTitleScrollerShadow = YES;
	slider.disableUIPageControl = YES;
	slider.zoomOutAnimationDisabled = YES;
	slider.dataSource = self;
	slider.view.frame = CGRectMake(0, statusBarHeight, viewWidth, viewHeight);
	slider.view.backgroundColor = [UIColor colorWithRed:16./255. green:32./255. blue:34./255. alpha:1.0];
	[self.view addSubview:slider.view];
	[self.view sendSubviewToBack:slider.view];
	[self addChildViewController:slider];

}

- (void)viewDidLayoutSubviews {
	CGFloat viewWidth = [UIScreen mainScreen].bounds.size.width;
	CGFloat statusBarHeight = [Utilities statusBarHeight];
	
	opsLabel.frame = CGRectMake(0, statusBarHeight, viewWidth, 32);
	labelBackgroundImage.frame = opsLabel.frame;
	opsCloseButton.frame = CGRectMake(0, statusBarHeight, 62, 34);
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	[[[GAI sharedInstance] defaultTracker] sendView:@"Portal Detail Screen"];
	
	[[LocationManager sharedInstance] addDelegate:self];
}

- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
	
	[[LocationManager sharedInstance] removeDelegate:self];
	[[NSNotificationCenter defaultCenter] removeObserver:self];
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

#pragma mark - CLLocationManagerDelegate protocol

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
	
	float yardModifier;
	NSString *unitLabel;
	if ([[NSUserDefaults standardUserDefaults] boolForKey:MilesOrKM]) {
		yardModifier = 1;
		unitLabel = @"m";
	} else {
		yardModifier = 1.0936133;
		unitLabel = @"yd";
	}

	if (_portal.isInPlayerRange) {
		CLLocationDistance distance = [_portal distanceFromCoordinate:[LocationManager sharedInstance].playerLocation.coordinate];
		opsLabel.text = [NSString stringWithFormat:@"Distance: %.0f%@", distance * yardModifier, unitLabel];
	} else {
		opsLabel.text = @"Out of Range";
	}
	
}

@end

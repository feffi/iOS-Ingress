//
//  IntelViewController.m
//  Ingress
//
//  Created by Alex Studnicka on 12.01.13.
//  Copyright (c) 2013 A&A Code. All rights reserved.
//

#import "IntelViewController.h"
#import "TTUIScrollViewSlidingPages.h"
#import "ScoreViewController.h"
#import "MissionsViewController.h"
#import "RecruitViewController.h"

@implementation IntelViewController

- (void)viewDidLoad {
    [super viewDidLoad];

	TTScrollSlidingPagesController *slider = [TTScrollSlidingPagesController new];
	slider.titleScrollerHeight = 64;
	slider.disableTitleScrollerShadow = YES;
	slider.disableUIPageControl = YES;
	slider.zoomOutAnimationDisabled = YES;
	slider.dataSource = self;
	slider.view.frame = self.view.frame;
	[self.view addSubview:slider.view];
	[self addChildViewController:slider];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - TTSlidingPagesDataSource

- (int)numberOfPagesForSlidingPagesViewController:(TTScrollSlidingPagesController *)source {
    return 3;
}

- (TTSlidingPage *)pageForSlidingPagesViewController:(TTScrollSlidingPagesController*)source atIndex:(int)index{
    UIViewController *viewController;
	UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil];

	switch (index) {
		case 0:
			viewController = [storyboard instantiateViewControllerWithIdentifier:@"ScoreViewController"];
			break;
		case 1:
			viewController = [storyboard instantiateViewControllerWithIdentifier:@"MissionsViewController"];
			break;
		case 2:
			viewController = [storyboard instantiateViewControllerWithIdentifier:@"RecruitViewController"];
			break;
	}

    return [[TTSlidingPage alloc] initWithContentViewController:viewController];
}

- (TTSlidingPageTitle *)titleForSlidingPagesViewController:(TTScrollSlidingPagesController *)source atIndex:(int)index{
    TTSlidingPageTitle *title;
	switch (index) {
		case 0:
			title = [[TTSlidingPageTitle alloc] initWithHeaderText:@"Global Control"];
			break;
		case 1:
			title = [[TTSlidingPageTitle alloc] initWithHeaderText:@"Missions"];
			break;
		case 2:
			title = [[TTSlidingPageTitle alloc] initWithHeaderText:@"Recruit"];
			break;
	}
    return title;
}

@end

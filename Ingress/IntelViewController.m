//
//  IntelViewController.m
//  Ingress
//
//  Created by Alex Studnicka on 12.01.13.
//  Copyright (c) 2013 A&A Code. All rights reserved.
//

#import "IntelViewController.h"
#import "ScoreViewController.h"
#import "MissionsViewController.h"
#import "RecruitViewController.h"

@implementation IntelViewController

- (void)viewDidLoad {
    [super viewDidLoad];

}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

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
			
			[[self childViewControllerWithClass:[ScoreViewController class]] viewWillAppear:NO];
			[scoreContainerView setHidden:NO];
			[[self childViewControllerWithClass:[ScoreViewController class]] viewDidAppear:NO];
			
			[[self childViewControllerWithClass:[MissionsViewController class]] viewWillDisappear:NO];
			[missionsContainerView setHidden:YES];
			[[self childViewControllerWithClass:[MissionsViewController class]] viewDidDisappear:NO];
			
			[[self childViewControllerWithClass:[RecruitViewController class]] viewWillDisappear:NO];
			[recruitContainerView setHidden:YES];
			[[self childViewControllerWithClass:[RecruitViewController class]] viewDidDisappear:NO];
			
			break;
		case 1:
			
			[[self childViewControllerWithClass:[ScoreViewController class]] viewWillDisappear:NO];
			[scoreContainerView setHidden:YES];
			[[self childViewControllerWithClass:[ScoreViewController class]] viewDidDisappear:NO];
			
			[[self childViewControllerWithClass:[MissionsViewController class]] viewWillAppear:NO];
			[missionsContainerView setHidden:NO];
			[[self childViewControllerWithClass:[MissionsViewController class]] viewDidAppear:NO];
			
			[[self childViewControllerWithClass:[RecruitViewController class]] viewWillDisappear:NO];
			[recruitContainerView setHidden:YES];
			[[self childViewControllerWithClass:[RecruitViewController class]] viewDidDisappear:NO];
			
			break;
		case 2:
			
			[[self childViewControllerWithClass:[ScoreViewController class]] viewWillDisappear:NO];
			[scoreContainerView setHidden:YES];
			[[self childViewControllerWithClass:[ScoreViewController class]] viewDidDisappear:NO];
			
			[[self childViewControllerWithClass:[MissionsViewController class]] viewWillDisappear:NO];
			[missionsContainerView setHidden:YES];
			[[self childViewControllerWithClass:[MissionsViewController class]] viewDidDisappear:NO];
			
			[[self childViewControllerWithClass:[RecruitViewController class]] viewWillAppear:NO];
			[recruitContainerView setHidden:NO];
			[[self childViewControllerWithClass:[RecruitViewController class]] viewDidAppear:NO];
			
			break;
	}
	
}

@end

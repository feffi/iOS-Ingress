//
//  ItemsViewController.m
//  Ingress
//
//  Created by Alex Studnicka on 17.01.13.
//  Copyright (c) 2013 A&A Code. All rights reserved.
//

#import "ItemsViewController.h"
//#import "ResourcesViewController.h"
#import "ResourcesViewController.h"
#import "PortalKeysViewController.h"
#import "MediaItemsViewController.h"

@implementation ItemsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
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
			
			[[self childViewControllerWithClass:[ResourcesViewController class]] viewWillAppear:NO];
			[resourcesContainerView setHidden:NO];
			[[self childViewControllerWithClass:[ResourcesViewController class]] viewDidAppear:NO];
			[[(UITableViewController *)[self childViewControllerWithClass:[ResourcesViewController class]] tableView] setScrollsToTop:YES];

			[[(UITableViewController *)[self childViewControllerWithClass:[PortalKeysViewController class]] tableView] setScrollsToTop:NO];
			[[self childViewControllerWithClass:[PortalKeysViewController class]] viewWillDisappear:NO];
			[portalKeysContainerView setHidden:YES];
			[[self childViewControllerWithClass:[PortalKeysViewController class]] viewDidDisappear:NO];

			[[(UITableViewController *)[self childViewControllerWithClass:[MediaItemsViewController class]] tableView] setScrollsToTop:NO];
			[[self childViewControllerWithClass:[MediaItemsViewController class]] viewWillDisappear:NO];
			[mediaContainerView setHidden:YES];
			[[self childViewControllerWithClass:[MediaItemsViewController class]] viewDidDisappear:NO];
			
			break;
		case 1:
			
			[[self childViewControllerWithClass:[ResourcesViewController class]] viewWillDisappear:NO];
			[resourcesContainerView setHidden:YES];
			[[self childViewControllerWithClass:[ResourcesViewController class]] viewDidDisappear:NO];
			[[(UITableViewController *)[self childViewControllerWithClass:[ResourcesViewController class]] tableView] setScrollsToTop:NO];

			[[(UITableViewController *)[self childViewControllerWithClass:[PortalKeysViewController class]] tableView] setScrollsToTop:YES];
			[[self childViewControllerWithClass:[PortalKeysViewController class]] viewWillAppear:NO];
			[portalKeysContainerView setHidden:NO];
			[[self childViewControllerWithClass:[PortalKeysViewController class]] viewDidAppear:NO];
			
			[[self childViewControllerWithClass:[MediaItemsViewController class]] viewWillDisappear:NO];
			[mediaContainerView setHidden:YES];
			[[self childViewControllerWithClass:[MediaItemsViewController class]] viewDidDisappear:NO];
			[[(UITableViewController *)[self childViewControllerWithClass:[MediaItemsViewController class]] tableView] setScrollsToTop:NO];
			
			break;
		case 2:

			[[(UITableViewController *)[self childViewControllerWithClass:[ResourcesViewController class]] tableView] setScrollsToTop:NO];
			[[self childViewControllerWithClass:[ResourcesViewController class]] viewWillDisappear:NO];
			[resourcesContainerView setHidden:YES];
			[[self childViewControllerWithClass:[ResourcesViewController class]] viewDidDisappear:NO];

			[[(UITableViewController *)[self childViewControllerWithClass:[PortalKeysViewController class]] tableView] setScrollsToTop:NO];
			[[self childViewControllerWithClass:[PortalKeysViewController class]] viewWillDisappear:NO];
			[portalKeysContainerView setHidden:YES];
			[[self childViewControllerWithClass:[PortalKeysViewController class]] viewDidDisappear:NO];
			
			[[self childViewControllerWithClass:[MediaItemsViewController class]] viewWillAppear:NO];
			[mediaContainerView setHidden:NO];
			[[self childViewControllerWithClass:[MediaItemsViewController class]] viewDidAppear:NO];
			[[(UITableViewController *)[self childViewControllerWithClass:[MediaItemsViewController class]] tableView] setScrollsToTop:YES];
			
			break;
	}
	
}


@end

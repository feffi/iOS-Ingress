//
//  ResourcesViewController.m
//  Ingress
//
//  Created by Alex Studnicka on 17.01.13.
//  Copyright (c) 2013 A&A Code. All rights reserved.
//

#import "ResourcesViewController.h"
#import "GLViewController.h"

@implementation ResourcesViewController

- (void)viewDidLoad {
    [super viewDidLoad];

	for (UIButton *view in self.view.subviews) {
		if ([view isKindOfClass:[UIButton class]]) {
			UIButton *button = (UIButton *)view;
			button.titleLabel.font = [UIFont fontWithName:@"Coda-Regular" size:button.titleLabel.font.pointSize];
		} else if ([view isKindOfClass:[UILabel class]]) {
			UILabel *label = (UILabel *)view;
			label.font = [UIFont fontWithName:@"Coda-Regular" size:label.font.pointSize];
		}
	}

}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
//	[[NSNotificationCenter defaultCenter] addObserverForName:@"InventoryUpdatedNotification" object:nil queue:[[API sharedInstance] notificationQueue] usingBlock:^(NSNotification *note) {
//		//NSLog(@"InventoryUpdatedNotification");
//		dispatch_async(dispatch_get_main_queue(), ^{
//			[self reload];
//		});
	//	}];
	
//	for (UIViewController *vc in self.childViewControllers) {
//		if ([vc isKindOfClass:[GLViewController class]]) {
//			if ([vc.view isEqual:resonatorContainerView]) {
//				[(GLViewController *)vc setModelID:2];
//			} else if ([vc.view isEqual:xmpContainerView]) {
//				[(GLViewController *)vc setModelID:3];
//			} else if ([vc.view isEqual:shieldContainerView]) {
//				[(GLViewController *)vc setModelID:4];
//			}
//		}
//	}

	[self reload];
	
}

- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
	
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)reload {

	for (int i = 0; i < 8; i++) {
		UILabel *label = (UILabel *)[self.view viewWithTag:10+i];
		label.text = [NSString stringWithFormat:@"%d", [[DB sharedInstance] numberOfResonatorsOfLevel:i+1]];
	}
	
	for (int i = 0; i < 8; i++) {
		UILabel *label = (UILabel *)[self.view viewWithTag:20+i];
		label.text = [NSString stringWithFormat:@"%d", [[DB sharedInstance] numberOfXMPsOfLevel:i+1]];
	}
	
	for (int i = 0; i < 3; i++) {
		
		PortalShieldRarity rarity;
		switch (i) {
			case 0:
				rarity = PortalShieldRarityCommon;
				break;
			case 1:
				rarity = PortalShieldRarityRare;
				break;
			case 2:
				rarity = PortalShieldRarityVeryRare;
				break;
			default:
				rarity = PortalShieldRarityUnknown;
				break;
		}
		
		UILabel *label = (UILabel *)[self.view viewWithTag:30+i];
		label.text = [NSString stringWithFormat:@"%d", [[DB sharedInstance] numberOfPortalShieldsOfRarity:rarity]];
	}

}

#pragma mark - Action

- (IBAction)action:(UIButton *)sender {
	
	if ((sender.tag - 40) >= 0 && (sender.tag - 40) < 10) {
		actionResource = 1;
		actionLevel = sender.tag-40+1;
	} else if ((sender.tag - 50) >= 0 && (sender.tag - 50) < 10) {
		actionResource = 2;
		actionLevel = sender.tag-50+1;
	} else if ((sender.tag - 60) >= 0 && (sender.tag - 60) < 10) {
		actionResource = 3;
		actionLevel = sender.tag-60+1;
	}
	
	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Drop" otherButtonTitles:nil];
	[actionSheet showFromTabBar:self.tabBarController.tabBar];
	
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	
	[[SoundManager sharedManager] playSound:@"Sound/sfx_ui_success.aif"];
	
	switch (buttonIndex) {
		case 0: {
			
			NSString *guid;
			
			switch (actionResource) {
				case 1: {
					guid = [[DB sharedInstance] getRandomResonatorOfLevel:actionLevel].guid;
					break;
				}
				case 2: {
					guid = [[DB sharedInstance] getRandomXMPOfLevel:actionLevel].guid;
					break;
				}
				case 3: {
					PortalShieldRarity rarity = [API shieldRarityFromInt:actionLevel];
					guid = [[DB sharedInstance] getRandomShieldOfRarity:rarity].guid;
					break;
				}
			}
			
			actionResource = 0;
			actionLevel = 0;
			
			if (!guid) { break; }
			
			__block MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:[AppDelegate instance].window];
			HUD.userInteractionEnabled = YES;
			HUD.mode = MBProgressHUDModeIndeterminate;
			HUD.dimBackground = YES;
			HUD.labelFont = [UIFont fontWithName:@"Coda-Regular" size:16];
			HUD.labelText = @"Dropping Item...";
			[[AppDelegate instance].window addSubview:HUD];
			[HUD show:YES];

			[[SoundManager sharedManager] playSound:@"Sound/sfx_drop_resource.aif"];
			
			[[API sharedInstance] dropItemWithGuid:guid completionHandler:^(void) {
				
				[HUD hide:YES];
				
			}];
			
			break;
		}
	}
}

@end

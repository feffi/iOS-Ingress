//
//  PortalDetailViewController.h
//  Ingress
//
//  Created by Alex Studnicka on 14.01.13.
//  Copyright (c) 2013 A&A Code. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TTSlidingPagesDataSource.h"
#import "PortalActionsViewController.h"
#import "PortalInfoViewController.h"
#import "PortalUpgradeViewController.h"
#import "MDCParallaxView.h"

@interface PortalDetailViewController : UIViewController <TTSlidingPagesDataSource, CLLocationManagerDelegate> {

	__weak IBOutlet UIButton *opsCloseButton;
	__weak IBOutlet UIImageView *labelBackgroundImage;
	__weak IBOutlet GlowingLabel *opsLabel;

	PortalActionsViewController *portalActionsVC;
	MDCParallaxView *infoContainerView;
	PortalInfoViewController *portalInfoVC;
	PortalUpgradeViewController *portalUpgradeVC;

}

@property (nonatomic, assign) Portal *portal;

- (IBAction)back:(id)sender;

@end

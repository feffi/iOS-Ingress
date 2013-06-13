//
//  PortalUpgradeViewController.h
//  Ingress
//
//  Created by Alex Studnička on 14.05.13.
//  Copyright (c) 2013 A&A Code. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChooserViewController.h"
#import "GUIButton.h"
#import "GlowingLabel.h"
#import "iCarousel.h"

@interface PortalUpgradeViewController : UIViewController <iCarouselDataSource, iCarouselDelegate> {
	iCarousel *_carousel;
	ChooserViewController *_levelChooser;
	ChooserViewController *_modChooser;
	NSMutableArray *_resonators;
}

@property (nonatomic, assign) Portal *portal;

- (void)refresh;
- (IBAction)modButtonPressed:(GUIButton *)sender;

@end

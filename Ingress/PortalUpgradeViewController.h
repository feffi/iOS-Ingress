//
//  PortalUpgradeViewController.h
//  Ingress
//
//  Created by Alex Studnička on 14.05.13.
//  Copyright (c) 2013 A&A Code. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LevelChooserViewController.h"
#import "GUIButton.h"
#import "GlowingLabel.h"
#import "iCarousel.h"

@interface PortalUpgradeViewController : UIViewController <iCarouselDataSource, iCarouselDelegate> {
	iCarousel *_carousel;
	LevelChooserViewController *_levelChooser;
	NSMutableArray *_resonators;
}

@property (nonatomic, assign) Portal *portal;

- (IBAction)resonatorButtonPressed:(GUIButton *)sender;
- (IBAction)shieldButtonPressed:(GUIButton *)sender;

@end

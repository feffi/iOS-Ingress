//
//  PortalUpgradeViewController.h
//  Ingress
//
//  Created by Alex Studnicka on 20.01.13.
//  Copyright (c) 2013 A&A Code. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LevelChooserViewController.h"
#import "GUIButton.h"

@interface PortalUpgradeViewController : UIViewController {
	LevelChooserViewController *_levelChooser;
	NSMutableArray *_resonators;
}

@property (nonatomic, assign) Portal *portal;
@property (nonatomic, assign) CLLocationCoordinate2D mapCenterCoordinate;

- (IBAction)resonatorButtonPressed:(GUIButton *)sender;
- (IBAction)shieldButtonPressed:(GUIButton *)sender;

@end

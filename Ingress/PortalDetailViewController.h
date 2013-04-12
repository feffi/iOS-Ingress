//
//  PortalDetailViewController.h
//  Ingress
//
//  Created by Alex Studnicka on 14.01.13.
//  Copyright (c) 2013 A&A Code. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PortalDetailViewController : UIViewController {
	
	__weak IBOutlet UISegmentedControl *viewSegmentedControl;
	
	__weak IBOutlet UIView *infoContainerView;
	__weak IBOutlet UIView *upgradeContainerView;

}

@property (nonatomic, assign) Portal *portal;
@property (nonatomic, assign) CLLocationCoordinate2D mapCenterCoordinate;

- (IBAction)viewSegmentedControlChanged;

@end

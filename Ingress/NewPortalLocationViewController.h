//
//  NewPortalLocationViewController.h
//  Ingress
//
//  Created by Alex Studnička on 30.06.13.
//  Copyright (c) 2013 A&A Code. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MKMapView+ZoomLevel.h"
#import "NewPortalViewController.h"

@interface NewPortalLocationViewController : UIViewController {
	
	__weak IBOutlet MKMapView *mapView;
	__weak IBOutlet UILabel *titleLabel;
	
}

@property (nonatomic, strong) CLLocation *portalLocation;
@property (nonatomic, weak) NewPortalViewController *delegate;

- (IBAction)mapTypeChanged:(UISegmentedControl *)sender;
- (IBAction)confirm;
- (IBAction)cancel;

@end

//
//  NewPortalViewController.h
//  Ingress
//
//  Created by Alex Studnička on 30.06.13.
//  Copyright (c) 2013 A&A Code. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MKMapView+ZoomLevel.h"
#import "DAKeyboardControl.h"

@interface NewPortalViewController : UIViewController {
	
	__weak IBOutlet UILabel *titleLabel;
	__weak IBOutlet UILabel *subtitleLabel;
	__weak IBOutlet UILabel *mapViewLabel;
	
	__weak IBOutlet UIImageView *portalImageView;
	__weak IBOutlet MKMapView *portalLocationMapView;
	
	__weak IBOutlet UITextField *portalNameTextField;
	__weak IBOutlet UITextField *portalDescriptionTextField;
	
}

@property (nonatomic, strong) UIImage *portalImage;
@property (nonatomic, strong) CLLocation *portalLocation;

- (IBAction)selectLocation;
- (IBAction)send;
- (IBAction)cancel;

@end

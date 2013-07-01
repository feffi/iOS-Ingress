//
//  NewPortalLocationViewController.m
//  Ingress
//
//  Created by Alex Studnička on 30.06.13.
//  Copyright (c) 2013 A&A Code. All rights reserved.
//

#import "NewPortalLocationViewController.h"

@implementation NewPortalLocationViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	
	titleLabel.font = [UIFont fontWithName:[[[UILabel appearance] font] fontName] size:20];
	
	for (UIView *view in mapView.subviews) {
		if ([view isKindOfClass:NSClassFromString(@"MKAttributionLabel")]) {
			[view removeFromSuperview];
		}
	}
	
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.1), dispatch_get_main_queue(), ^(void){
		[mapView setCenterCoordinate:self.portalLocation.coordinate zoomLevel:16 animated:NO];
	});

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - IBActions

- (IBAction)mapTypeChanged:(UISegmentedControl *)sender {
	switch (sender.selectedSegmentIndex) {
		case 0:
			[mapView setMapType:MKMapTypeStandard];
			break;
		case 1:
			[mapView setMapType:MKMapTypeSatellite];
			break;
		case 2:
			[mapView setMapType:MKMapTypeHybrid];
			break;
	}
}

- (IBAction)confirm {
	self.delegate.portalLocation = [[CLLocation alloc] initWithLatitude:mapView.centerCoordinate.latitude longitude:mapView.centerCoordinate.longitude];
	[self cancel];
}

- (IBAction)cancel {
	[self dismissViewControllerAnimated:YES completion:NULL];
}

@end

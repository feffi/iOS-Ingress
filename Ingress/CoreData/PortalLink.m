//
//  PortalLink.m
//  Ingress
//
//  Created by Alex Studnicka on 24.01.13.
//  Copyright (c) 2013 A&A Code. All rights reserved.
//

#import "PortalLink.h"
#import "Portal.h"
#import "User.h"
#import "MKPolyline+PortalLink.h"

@implementation PortalLink

@synthesize polyline = _polyline;

@dynamic guid;
@dynamic controllingTeam;
@dynamic originPortal;
@dynamic destinationPortal;
@dynamic creator;

- (MKPolyline *)polyline {

	if (!_polyline) {
		CLLocationCoordinate2D coordinates[2];
		coordinates[0] = self.originPortal.coordinate;
		coordinates[1] = self.destinationPortal.coordinate;
		_polyline = [MKPolyline polylineWithCoordinates:coordinates count:2];
		_polyline.portalLink = self;
	}

	return _polyline;
	
}

@end

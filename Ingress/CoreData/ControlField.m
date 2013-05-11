//
//  ControlField.m
//  Ingress
//
//  Created by Alex Studnicka on 24.01.13.
//  Copyright (c) 2013 A&A Code. All rights reserved.
//

#import "ControlField.h"
#import "Portal.h"
#import "User.h"
#import "MKPolygon+ControlField.h"

@implementation ControlField

@synthesize polygon = _polygon;

@dynamic guid;
@dynamic controllingTeam;
@dynamic entityScore;
@dynamic portals;
@dynamic creator;

- (MKPolygon *)polygon {
	
	if (!_polygon) {
		//	NSArray *portals = [Portal MR_findAllWithPredicate:[NSPredicate predicateWithFormat:@"ANY vertexForControlFields = %@", self]];

		CLLocationCoordinate2D coordinates[3];
		if (self.portals.count > 0) {
			NSArray *portalsArray = [self.portals allObjects];
			coordinates[0] = [portalsArray[0] coordinate];
			coordinates[1] = [portalsArray[1] coordinate];
			coordinates[2] = [portalsArray[2] coordinate];
		} else {
			coordinates[0] = CLLocationCoordinate2DMake(0, 0);
			coordinates[1] = CLLocationCoordinate2DMake(0, 0);
			coordinates[2] = CLLocationCoordinate2DMake(0, 0);
		}

		_polygon = [MKPolygon polygonWithCoordinates:coordinates count:3];
		_polygon.controlField = self;
	}
	
	return _polygon;
	
}

@end

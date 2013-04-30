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

@dynamic guid;
@dynamic controllingTeam;
@dynamic entityScore;
@dynamic portals;
@dynamic creator;

- (MKPolygon *)polygon {
	
	NSArray *portals = [Portal MR_findAllWithPredicate:[NSPredicate predicateWithFormat:@"ANY vertexForControlFields = %@", self]];

    CLLocationCoordinate2D coordinates[3];
	coordinates[0] = [portals[0] coordinate];
	coordinates[1] = [portals[1] coordinate];
	coordinates[2] = [portals[2] coordinate];
	
    MKPolygon *polygon = [MKPolygon polygonWithCoordinates:coordinates count:3];
	polygon.controlField = self;
	return polygon;
	
}

@end

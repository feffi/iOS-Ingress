//
//  EnergyGlob.m
//  Ingress
//
//  Created by Alex Studnička on 09.05.13.
//  Copyright (c) 2013 A&A Code. All rights reserved.
//

#import "EnergyGlob.h"
#import "MKCircle+Ingress.h"

@implementation EnergyGlob

@synthesize circle = _circle;

@dynamic amount;

- (NSString *)description {
	return @"XM";
}

- (MKCircle *)circle {
	
	if (!_circle) {
		_circle = [MKCircle circleWithCenterCoordinate:self.coordinate radius:1];
		_circle.energyGlob = self;
	}
	
	return _circle;
	
}

@end

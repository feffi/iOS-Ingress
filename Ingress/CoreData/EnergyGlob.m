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

@dynamic amount;

- (NSString *)description {
	return @"XM";
}

- (MKCircle *)circle {
	MKCircle *circle = [MKCircle circleWithCenterCoordinate:self.coordinate radius:1];
	circle.energyGlob = self;
	return circle;
}

@end

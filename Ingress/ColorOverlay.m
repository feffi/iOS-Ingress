//
//  ColorOverlay.m
//  Ingress
//
//  Created by Alex Studnicka on 26.01.13.
//  Copyright (c) 2013 A&A Code. All rights reserved.
//

#import "ColorOverlay.h"

@implementation ColorOverlay

- (CLLocationCoordinate2D)coordinate {
	return CLLocationCoordinate2DMake(0, 0);
}

- (MKMapRect)boundingMapRect {
	return MKMapRectWorld;
}

//- (BOOL)intersectsMapRect:(MKMapRect)mapRect {
//	return YES;
//}

@end

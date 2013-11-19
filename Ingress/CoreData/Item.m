//
//  Item.m
//  Ingress
//
//  Created by Alex Studnicka on 25.01.13.
//  Copyright (c) 2013 A&A Code. All rights reserved.
//

#import "Item.h"


@implementation Item

@dynamic guid;
@synthesize dropped;
@dynamic latitude;
@dynamic longitude;
@dynamic timestamp;

- (CLLocationCoordinate2D)coordinate {
	return CLLocationCoordinate2DMake(self.latitude, self.longitude);
}

- (CLLocationDistance)distanceFromCoordinate:(CLLocationCoordinate2D)coordinate {
	CLLocation *loc1 = [[CLLocation alloc] initWithLatitude:self.latitude longitude:self.longitude];
	CLLocation *loc2 = [[CLLocation alloc] initWithLatitude:coordinate.latitude longitude:coordinate.longitude];
	return [loc1 distanceFromLocation:loc2];
}

- (NSString *)title {
	return self.description;
}

- (NSString *)description {
	return [NSString stringWithFormat:@"Unknown Item"];
}

@end

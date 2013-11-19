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
@dynamic guid;
@dynamic latitude;
@dynamic longitude;

- (CLLocationCoordinate2D)coordinate {
	return CLLocationCoordinate2DMake(self.latitude, self.longitude);
}

- (CLLocationDistance)distanceFromCoordinate:(CLLocationCoordinate2D)coordinate {
	CLLocation *loc1 = [[CLLocation alloc] initWithLatitude:self.coordinate.latitude longitude:self.coordinate.longitude];
	CLLocation *loc2 = [[CLLocation alloc] initWithLatitude:coordinate.latitude longitude:coordinate.longitude];
	return [loc1 distanceFromLocation:loc2];
}

- (NSString *)title {
	return self.description;
}

- (NSString *)description {
	return [NSString stringWithFormat:@"XM (% 3d): %f, %f", self.amount, self.latitude, self.longitude];
}

- (void)updateWithData:(NSString *)guid {
    NSScanner *scanner = [NSScanner scannerWithString:[guid substringToIndex:16]]; //19
    unsigned long long numCellId;
    [scanner scanHexLongLong:&numCellId];
    CLLocationCoordinate2D coord = [S2Geometry coordinateForCellId:numCellId];
    
    if (self.latitude != coord.latitude)
        self.latitude = coord.latitude;
    if (self.longitude != coord.longitude)
        self.longitude = coord.longitude;
    
    scanner = [NSScanner scannerWithString:[guid substringFromIndex:guid.length-4]];
    unsigned int amount;
    [scanner scanHexInt:&amount];
    if (self.amount != amount)
        self.amount = amount;
}

+ (instancetype)energyGlobWithData:(NSString *)guid inManagedObjectContext:(NSManagedObjectContext *)context {
    EnergyGlob *energyGlob = [EnergyGlob MR_createInContext:context];
    energyGlob.guid = guid;
    [energyGlob updateWithData:guid];
    return energyGlob;
}

@end

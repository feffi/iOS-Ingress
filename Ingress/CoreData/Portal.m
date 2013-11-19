//
//  Portal.m
//  Ingress
//
//  Created by Alex Studnička on 06.06.13.
//  Copyright (c) 2013 A&A Code. All rights reserved.
//

#import "Portal.h"
#import "ControlField.h"
#import "DeployedMod.h"
#import "DeployedResonator.h"
#import "PortalKey.h"
#import "PortalLink.h"
#import "User.h"


@implementation Portal

@dynamic address;
@dynamic completeInfo;
@dynamic controllingTeam;
@dynamic imageURL;
@dynamic name;
@dynamic guid;
@dynamic latitude;
@dynamic longitude;
@dynamic timestamp;
@dynamic capturedBy;
@dynamic destinationForLinks;
@dynamic mods;
@dynamic originForLinks;
@dynamic portalKeys;
@dynamic resonators;
@dynamic vertexForControlFields;

- (CLLocationCoordinate2D)coordinate {
	return CLLocationCoordinate2DMake(self.latitude, self.longitude);
}

- (CLLocationDistance)distanceFromCoordinate:(CLLocationCoordinate2D)coordinate {
	CLLocation *loc1 = [[CLLocation alloc] initWithLatitude:self.latitude longitude:self.longitude];
	CLLocation *loc2 = [[CLLocation alloc] initWithLatitude:coordinate.latitude longitude:coordinate.longitude];
	return [loc1 distanceFromLocation:loc2];
}

- (BOOL)isInPlayerRange {
	return [self distanceFromCoordinate:[LocationManager sharedInstance].playerLocation.coordinate] <= SCANNER_RANGE;
}

- (NSString *)title {
	return self.description;
}

- (NSString *)description {
	return [NSString stringWithFormat:@"L%d Portal", self.level];
}

- (NSString *)subtitle {
	return self.name;
}

- (float)averageResonatorLevel {
	float totalLevel = 0;
	for (DeployedResonator *resonator in self.resonators) {
		totalLevel += resonator.level;
	}
	return totalLevel/8.;
}

- (NSInteger)level {
	float averageResonatorLevel = [self averageResonatorLevel];
	if (averageResonatorLevel > 1) {
		return floorf(averageResonatorLevel);
	} else if (averageResonatorLevel > 0) {
		return 1;
	} else {
		return 0;
	}
}

- (NSInteger)range {
	return 160 * (powf([self averageResonatorLevel], 4));
}

- (float)energy {
	float totalEnergy = 0;
	for (DeployedResonator *resonator in self.resonators) {
		totalEnergy += resonator.energy;
	}
	return totalEnergy;
}

- (MKMapRect)boundingMapRect {
    MKMapPoint upperLeft = MKMapPointForCoordinate(self.coordinate);
	double pointsPerMeter = MKMapPointsPerMeterAtLatitude(self.coordinate.latitude);
    MKMapRect bounds = MKMapRectMake(upperLeft.x - (200*pointsPerMeter/2), upperLeft.y - (200*pointsPerMeter/2), 200*pointsPerMeter, 200*pointsPerMeter);
    return bounds;
}

@end

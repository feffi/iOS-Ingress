//
//  Portal.m
//  Ingress
//
//  Created by Alex Studnicka on 24.01.13.
//  Copyright (c) 2013 A&A Code. All rights reserved.
//

#import "Portal.h"
#import "DeployedMod.h"
#import "DeployedResonator.h"
#import "PortalKey.h"
#import "User.h"


@implementation Portal

@dynamic controllingTeam;
@dynamic name;
@dynamic address;
@dynamic imageURL;
@dynamic capturedBy;
@dynamic portalKeys;
@dynamic mods;
@dynamic resonators;
@dynamic destinationForLinks;
@dynamic originForLinks;
@dynamic vertexForControlFields;
@dynamic completeInfo;

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
	return floorf([self averageResonatorLevel]);
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

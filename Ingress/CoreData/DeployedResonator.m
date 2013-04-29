//
//  DeployedResonator.m
//  Ingress
//
//  Created by Alex Studnicka on 24.01.13.
//  Copyright (c) 2013 A&A Code. All rights reserved.
//

#import "DeployedResonator.h"
#import "Portal.h"
#import "User.h"
#import "MKCircle+Ingress.h"

const CLLocationDegrees kLatLonEarthRadius = 6371.0;

double radians(double degrees) {
    return degrees * M_PI / 180.0;
}

double degrees(double radians) {
    return radians * 180.0 / M_PI;
}

CLLocationCoordinate2D LatLonDestPoint(CLLocationCoordinate2D origin, double bearing, CLLocationDistance distance) {
    double brng = radians(bearing);
    double lat1 = radians(origin.latitude);
    double lon1 = radians(origin.longitude);

    CLLocationDegrees lat2 = asin(sin(lat1) * cos(distance / kLatLonEarthRadius) +
                                  cos(lat1) * sin(distance / kLatLonEarthRadius) * cos(brng));
    CLLocationDegrees lon2 = lon1 + atan2(sin(brng) * sinf(distance / kLatLonEarthRadius) * cos(lat1),
										  cosf(distance / kLatLonEarthRadius) - sin(lat1) * sin(lat2));
    lon2 = fmod(lon2 + M_PI, 2.0 * M_PI) - M_PI;
	
    CLLocationCoordinate2D coordinate;
    if (! (isnan(lat2) || isnan(lon2))) {
        coordinate.latitude = degrees(lat2);
        coordinate.longitude = degrees(lon2);
    }

    return coordinate;
}

@implementation DeployedResonator

@dynamic distanceToPortal;
@dynamic energy;
@dynamic level;
@dynamic maxEnergy;
@dynamic slot;
@dynamic owner;
@dynamic portal;

- (CLLocationCoordinate2D)coordinate {
	
	//MKMapPoint portalCenter = MKMapPointForCoordinate(self.portal.coordinate);
	//double pointsPerMeter = MKMapPointsPerMeterAtLatitude(self.portal.coordinate.latitude);

	double distance = self.distanceToPortal, bearing = 0;
	
	switch (self.slot) {
		case 0: //E
			//portalCenter.x += self.distanceToPortal * pointsPerMeter;
			bearing = 90;
			break;
		case 1: //SE
			//portalCenter.x += (self.distanceToPortal * pointsPerMeter)/sqrtf(2);
			//portalCenter.y -= (self.distanceToPortal * pointsPerMeter)/sqrtf(2);
			bearing = 45;
			break;
		case 2: //S
			//portalCenter.y -= self.distanceToPortal * pointsPerMeter;
			bearing = 0;
			break;
		case 3: //SW
			//portalCenter.x -= (self.distanceToPortal * pointsPerMeter)/sqrtf(2);
			//portalCenter.y -= (self.distanceToPortal * pointsPerMeter)/sqrtf(2);
			bearing = 315;
			break;
		case 4: //W
			//portalCenter.x -= self.distanceToPortal * pointsPerMeter;
			bearing = 270;
			break;
		case 5: //NW
			//portalCenter.x -= (self.distanceToPortal * pointsPerMeter)/sqrtf(2);
			//portalCenter.y += (self.distanceToPortal * pointsPerMeter)/sqrtf(2);
			bearing = 225;
			break;
		case 6: //N
			//portalCenter.y += self.distanceToPortal * pointsPerMeter;
			bearing = 180;
			break;
		case 7: //NE
			//portalCenter.x += (self.distanceToPortal * pointsPerMeter)/sqrtf(2);
			//portalCenter.y += (self.distanceToPortal * pointsPerMeter)/sqrtf(2);
			bearing = 135;
			break;
	}
	
	return LatLonDestPoint(self.portal.coordinate, bearing, distance*6/kLatLonEarthRadius);
	
}

- (MKCircle *)circle {
	MKCircle *circle = [MKCircle circleWithCenterCoordinate:self.coordinate radius:2];
	circle.deployedResonator = self;
	return circle;
}

- (NSString *)description {
	return [NSString stringWithFormat:@"DepoloyedResonator forPortal:%@ slot:%d", self.portal.name, self.slot];
}

@end

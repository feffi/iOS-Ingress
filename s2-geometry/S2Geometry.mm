//
//  S2Geometry.m
//  Ingress
//
//  Created by Alex Studnička on 28.04.13.
//  Copyright (c) 2013 A&A Code. All rights reserved.
//

#import "S2Geometry.h"

#include "s2.h"
#include "s2cellid.h"
#include "s2latlng.h"
#include "s2latlngrect.h"
#include "s2regioncoverer.h"

@implementation S2Geometry

+ (S2Geometry *)sharedInstance {
    static dispatch_once_t onceToken;
    static S2Geometry * __sharedInstance = nil;
    dispatch_once(&onceToken, ^{
        __sharedInstance = [self new];
    });
    return __sharedInstance;
}

- (NSArray *)cellsForMapView:(MKMapView *)mapView {

	CGPoint nePoint = CGPointMake(mapView.bounds.origin.x + mapView.bounds.size.width, mapView.bounds.origin.y);
	CGPoint swPoint = CGPointMake((mapView.bounds.origin.x), (mapView.bounds.origin.y + mapView.bounds.size.height));
	CLLocationCoordinate2D neCoord = [mapView convertPoint:nePoint toCoordinateFromView:mapView];
	CLLocationCoordinate2D swCoord = [mapView convertPoint:swPoint toCoordinateFromView:mapView];

	S2LatLngRect rect = S2LatLngRect(S2LatLng::FromDegrees(MIN(neCoord.latitude, swCoord.latitude), MIN(neCoord.longitude, swCoord.longitude)), S2LatLng::FromDegrees(MAX(neCoord.latitude, swCoord.latitude), MAX(neCoord.longitude, swCoord.longitude)));

    S2RegionCoverer coverer;
	coverer.set_min_level(16);
	coverer.set_max_level(16);

	vector<S2CellId> covering;
	coverer.GetCovering(rect, &covering);

	NSMutableArray *cellsArray = [NSMutableArray arrayWithCapacity:covering.size()];

	for(std::vector<S2CellId>::iterator it = covering.begin(); it != covering.end(); ++it) {
		S2CellId cellId = *it;
		[cellsArray addObject:[NSString stringWithFormat:@"%llx", cellId.id()]];
	}

	return cellsArray;

}

@end

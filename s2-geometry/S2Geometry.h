//
//  S2Geometry.h
//  Ingress
//
//  Created by Alex Studnička on 28.04.13.
//  Copyright (c) 2013 A&A Code. All rights reserved.
//

#import <MapKit/MapKit.h>

@interface S2Geometry : NSObject

+ (S2Geometry *)sharedInstance;

- (NSArray *)cellsForMapView:(MKMapView *)mapView;

@end

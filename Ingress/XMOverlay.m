//
//  XMOverlay.m
//  Ingress
//
//  Created by Alex Studnička on 11.05.13.
//  Copyright (c) 2013 A&A Code. All rights reserved.
//

#import "XMOverlay.h"

@implementation XMOverlay

- (MKMapRect)boundingMapRect {
    return MKMapRectWorld;
}

- (CLLocationCoordinate2D)coordinate {
    return CLLocationCoordinate2DMake(0, 0);
}

@end

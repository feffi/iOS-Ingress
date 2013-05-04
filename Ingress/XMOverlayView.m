//
//  XMOverlayView.m
//  Ingress
//
//  Created by Alex Studnička on 29.04.13.
//  Copyright (c) 2013 A&A Code. All rights reserved.
//

#import "XMOverlayView.h"

@implementation XMOverlayView

- (void)drawMapRect:(MKMapRect)mapRect zoomScale:(MKZoomScale)zoomScale inContext:(CGContextRef)context {

	MKMapPoint xmCenter = MKMapPointForCoordinate(self.overlay.coordinate);
	CGPoint xmCenterPoint = [self pointForMapPoint:xmCenter];
	CGFloat xmSize = 20;

    CGColorSpaceRef space = CGColorSpaceCreateDeviceRGB();
    CGFloat comps[] = {1.0,1.0,1.0,1.0,  1.0,1.0,1.0,0.75,  0.7,1.0,1.0,0.0};
    CGFloat locs[] = {0,0.3,1};
    CGGradientRef g = CGGradientCreateWithColorComponents(space, comps, locs, 3);
    CGContextDrawRadialGradient(context, g, xmCenterPoint, 0, xmCenterPoint, xmSize, 0);
	CGGradientRelease(g);
	CGColorSpaceRelease(space);

}

@end

//
//  XMOverlayView.m
//  Ingress
//
//  Created by Alex Studnička on 29.04.13.
//  Copyright (c) 2013 A&A Code. All rights reserved.
//

#import "XMOverlayView.h"
#import "XMOverlay.h"

@implementation XMOverlayView

- (void)drawMapRect:(MKMapRect)mapRect zoomScale:(MKZoomScale)zoomScale inContext:(CGContextRef)context {

	CGFloat comps[] = {1.0,1.0,1.0,0.5, 1.0,1.0,1.0,0.375, 0.7,1.0,1.0,0.0};

    if (![[NSUserDefaults standardUserDefaults] boolForKey:IGMapDayMode]) {
        // Dimming map takes about 300ms per refresh on iPhone 4 :(
        CGContextSetRGBFillColor(context, 0, 0, 0, .75);
        CGContextFillRect(context, [self rectForMapRect:mapRect]);
    } else {
		comps[0] = 0.0;
		comps[1] = 0.5;
		comps[2] = 1.0;

		comps[4] = 0.0;
		comps[5] = 0.5;
		comps[6] = 1.0;
	}

    CGFloat xmRadius = 30;
    CGFloat xmDelta = 15;
    CGColorSpaceRef space = CGColorSpaceCreateDeviceRGB();
    CGFloat locs[] = {0.0, 0.3, 1.0};
    CGGradientRef g = CGGradientCreateWithColorComponents(space, comps, locs, 3);

	for (NSDictionary *energy in [(XMOverlay *)(self.overlay) globs]) {
		CLLocation *location = energy[@"location"];
		CLLocationCoordinate2D coordinate = location.coordinate;
		MKMapPoint xmCenter = MKMapPointForCoordinate(coordinate);
		xmCenter.x += [Utilities randomWithMin:-20 max:20];
		xmCenter.y += [Utilities randomWithMin:-20 max:20];
		if (MKMapRectContainsRect(mapRect, MKMapRectMake(xmCenter.x - xmRadius, xmCenter.y - xmRadius, 2*xmRadius, 2*xmRadius))) {
			CGPoint xmCenterPoint = [self pointForMapPoint:xmCenter];
			CGFloat xmScaledRadius = xmDelta/100 * [energy[@"amount"] intValue] + xmRadius-xmDelta;
			CGContextDrawRadialGradient(context, g, xmCenterPoint, 0, xmCenterPoint, xmScaledRadius, 0);
		}
	}

    CGGradientRelease(g);
	CGColorSpaceRelease(space);

}

@end

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

    CGContextSetRGBFillColor(context, 0, 0, 0, .75);
    CGContextFillRect(context, [self rectForMapRect:mapRect]);

    CGFloat xmRadius = 30;
    CGFloat xmDelta = 15;
    CGColorSpaceRef space = CGColorSpaceCreateDeviceRGB();
    CGFloat comps[] =	{1.0,1.0,1.0,0.5,	1.0,1.0,1.0,0.375,	0.7,1.0,1.0,0.0};
    CGFloat locs[] =	{0.0,				0.3,				1.0};
    CGGradientRef g = CGGradientCreateWithColorComponents(space, comps, locs, 3);

    for (EnergyGlob *energyGlob in [(XMOverlay *)(self.overlay) globs]) {
        if (energyGlob) {
            MKMapPoint xmCenter = MKMapPointForCoordinate(energyGlob.coordinate);
            if (MKMapRectContainsRect(mapRect, MKMapRectMake(xmCenter.x - xmRadius, xmCenter.y - xmRadius, 2*xmRadius, 2*xmRadius))) {
                CGPoint xmCenterPoint = [self pointForMapPoint:xmCenter];
                CGFloat xmScaledRadius = xmDelta/100 * energyGlob.amount + xmRadius-xmDelta;
                CGContextDrawRadialGradient(context, g, xmCenterPoint, 0, xmCenterPoint, xmScaledRadius, 0);
            }
        }
    }
    
    CGGradientRelease(g);
	CGColorSpaceRelease(space);

}

@end

//
//  ColorOverlayView.m
//  Ingress
//
//  Created by Alex Studnicka on 26.01.13.
//  Copyright (c) 2013 A&A Code. All rights reserved.
//

#import "ColorOverlayView.h"

@implementation ColorOverlayView

- (void)drawMapRect:(MKMapRect)mapRect zoomScale:(MKZoomScale)zoomScale inContext:(CGContextRef)context {
	CGContextSetBlendMode(context, kCGBlendModeSaturation);
    CGContextSetRGBFillColor(context, 0, 0, 0, .75);
    CGContextFillRect(context, [self rectForMapRect:mapRect]);
}

@end

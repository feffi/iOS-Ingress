//
//  XMOverlayView.m
//  Ingress
//
//  Created by Alex Studnička on 29.04.13.
//  Copyright (c) 2013 A&A Code. All rights reserved.
//

#import "XMOverlayView.h"
#import "XMOverlay.h"

@interface XMOverlayView (Private)

@property (nonatomic, readonly) XMOverlay *xmOverlay;

@end

@implementation XMOverlayView

- (XMOverlay *)xmOverlay {
    return (XMOverlay *)self.overlay;
}

- (void)drawMapRect:(MKMapRect)mapRect zoomScale:(MKZoomScale)zoomScale inContext:(CGContextRef)context {
    
    CGFloat xmRadius = 30;
    CGFloat xmDelta = 15;
    CGColorSpaceRef space = CGColorSpaceCreateDeviceRGB();
    CGFloat comps[] = {1.0,1.0,1.0,1.0,  1.0,1.0,1.0,0.75,  0.7,1.0,1.0,0.0};
    CGFloat locs[] = {0,0.3,1};
    CGGradientRef g = CGGradientCreateWithColorComponents(space, comps, locs, 3);
    
    //    refreshObject:mergeChanges:
    
    NSManagedObjectContext *moc = [NSManagedObjectContext MR_contextForCurrentThread];
    NSError *error;
    for (EnergyGlob *otherEnergyGlob in self.xmOverlay.globs) {
        // EnergyGlob *energyGlob = (EnergyGlob *)[moc objectWithID:otherEnergyGlob.objectID];
        // had some problems with the above, but the error should not happen now
        EnergyGlob *energyGlob = (EnergyGlob *)[moc existingObjectWithID:otherEnergyGlob.objectID error:&error];
        if (energyGlob) {
            MKMapPoint xmCenter = MKMapPointForCoordinate(energyGlob.coordinate);
            if (MKMapRectContainsRect(mapRect, MKMapRectMake(xmCenter.x - xmRadius, xmCenter.y - xmRadius, 2*xmRadius, 2*xmRadius))) {
                CGPoint xmCenterPoint = [self pointForMapPoint:xmCenter];
                CGFloat xmScaledRadius = xmDelta/100 * energyGlob.amount + xmRadius-xmDelta;
                CGContextDrawRadialGradient(context, g, xmCenterPoint, 0, xmCenterPoint, xmScaledRadius, 0);
            }
        } else {
            NSLog(@"Error finding object: %@", error);
            exit(1);
        }
    }
    
    CGGradientRelease(g);
	CGColorSpaceRelease(space);
}

@end

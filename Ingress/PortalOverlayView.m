//
//  PortalOverlayView.m
//  Ingress
//
//  Created by Alex Studnicka on 20.01.13.
//  Copyright (c) 2013 A&A Code. All rights reserved.
//

#import "PortalOverlayView.h"

@implementation PortalOverlayView

- (void)drawMapRect:(MKMapRect)mapRect zoomScale:(MKZoomScale)zoomScale inContext:(CGContextRef)context {

//	double maxx = MKMapRectGetMaxX(mapRect);
//    double minx = MKMapRectGetMinX(mapRect);
//    double maxy = MKMapRectGetMaxY(mapRect);
//    double miny = MKMapRectGetMinY(mapRect);
//	
//    CGPoint tr = [self pointForMapPoint:(MKMapPoint) {maxx, maxy}];
//    CGPoint br = [self pointForMapPoint:(MKMapPoint) {maxx, miny}];
//    CGPoint bl = [self pointForMapPoint:(MKMapPoint) {minx, miny}];
//    CGPoint tl = [self pointForMapPoint:(MKMapPoint) {minx, maxy}];
//	
//    CGMutablePathRef cgPath = CGPathCreateMutable();
//    CGPathMoveToPoint(cgPath, NULL, tr.x, tr.y);
//    CGPathAddLineToPoint(cgPath, NULL, br.x, br.y);
//    CGPathAddLineToPoint(cgPath, NULL, bl.x, bl.y);
//    CGPathAddLineToPoint(cgPath, NULL, tl.x, tl.y);
//    CGPathAddLineToPoint(cgPath, NULL, tr.x, tr.y);
//	
//    CGContextSaveGState(context);
//    CGContextAddPath(context, cgPath);
//    CGContextSetStrokeColorWithColor(context, [UIColor redColor].CGColor);
//    CGContextSetLineJoin(context, kCGLineJoinRound);
//    CGContextSetLineCap(context, kCGLineCapRound);
//    CGContextSetLineWidth(context, 2);
//    CGContextStrokePath(context);
//    CGPathRelease(cgPath);
//    CGContextRestoreGState(context);
	
	/////////////

	Portal *portal = (Portal *)self.overlay;

    CGImageRef portalImage;
	//CGImageRef resonatorImage = [UIImage imageNamed:@"resonatorFromTop.png"].CGImage;

	//[DeployedResonator MR_countOfEntitiesWithPredicate:[NSPredicate predicateWithFormat:@"portal = %@", portal]] 
	if (portal.resonators.count > 0) {
		if ([portal.controllingTeam isEqualToString:@"ALIENS"]) {
			portalImage = [UIImage imageNamed:@"portal_aliens.png"].CGImage;
		} else {
			portalImage = [UIImage imageNamed:@"portal_resistance.png"].CGImage;
		}
	} else {
		portalImage = [UIImage imageNamed:@"portal_neutral.png"].CGImage;
	}
	
	MKMapPoint portalCenter = MKMapPointForCoordinate(self.overlay.coordinate);
	CGPoint portalCenterPoint = [self pointForMapPoint:portalCenter];
	
	CGFloat portalSize = 400;

    CGContextDrawImage(context, CGRectMake(portalCenterPoint.x-portalSize/2, portalCenterPoint.y-portalSize/2, portalSize, portalSize), portalImage);

}

@end

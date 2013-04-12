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

	if ([[DB sharedInstance] numberOfResonatorsOfPortal:portal] > 0) {
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
	CGFloat resonatorSize = 50;
	
    CGContextDrawImage(context, CGRectMake(portalCenterPoint.x-portalSize/2, portalCenterPoint.y-portalSize/2, portalSize, portalSize), portalImage);
	
	return;
	
	NSArray *resonators = [[[DB sharedInstance] deployedResonatorsForPortal:portal] copy];
	
	for (DeployedResonator *resonator in resonators) {
		
		NSLog(@"slot: %d, level: %d, distance: %d", resonator.slot, resonator.level, resonator.distanceToPortal);
		
		int slot = resonator.slot;
		int level = resonator.level;
		int distance = resonator.distanceToPortal;
		
		MKMapPoint portalCenter = MKMapPointForCoordinate(self.overlay.coordinate);
		double pointsPerMeter = MKMapPointsPerMeterAtLatitude(self.overlay.coordinate.latitude);
		
		switch (slot) {
			case 0: //E
				portalCenter.x += distance * pointsPerMeter;
				break;
			case 1: //SE
				portalCenter.x += (distance * pointsPerMeter)/sqrtf(2);
				portalCenter.y -= (distance * pointsPerMeter)/sqrtf(2);
				break;
			case 2: //S
				portalCenter.y -= distance * pointsPerMeter;
				break;
			case 3: //SW
				portalCenter.x -= (distance * pointsPerMeter)/sqrtf(2);
				portalCenter.y -= (distance * pointsPerMeter)/sqrtf(2);
				break;
			case 4: //W
				portalCenter.x -= distance * pointsPerMeter;
				break;
			case 5: //NW
				portalCenter.x -= (distance * pointsPerMeter)/sqrtf(2);
				portalCenter.y += (distance * pointsPerMeter)/sqrtf(2);
				break;
			case 6: //N
				portalCenter.y += distance * pointsPerMeter;
				break;
			case 7: //NE
				portalCenter.x += (distance * pointsPerMeter)/sqrtf(2);
				portalCenter.y += (distance * pointsPerMeter)/sqrtf(2);
				break;
		}
		
		CGPoint resonatorCenterPoint = [self pointForMapPoint:portalCenter];
		
		//		CGContextSetStrokeColorWithColor(context, [API colorForFaction:portal.controllingTeam].CGColor);
		//		CGContextSetLineWidth(context, 6);
		//		CGContextMoveToPoint(context, portalCenterPoint.x, portalCenterPoint.y);
		//		CGContextAddLineToPoint(context, resonatorCenterPoint.x, resonatorCenterPoint.y);
		//		CGContextStrokePath(context);
		
		CGContextSetFillColorWithColor(context, [API colorForLevel:level].CGColor);
		CGContextFillEllipseInRect(context, CGRectMake(resonatorCenterPoint.x-resonatorSize/2, resonatorCenterPoint.y-resonatorSize/2, resonatorSize, resonatorSize));
		
		//		CGContextDrawImage(context, CGRectMake(resonatorCenterPoint.x-resonatorSize/2, resonatorCenterPoint.y-resonatorSize/2, resonatorSize, resonatorSize), resonatorImage);
		
	}
	
}

@end

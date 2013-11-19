//
//  PortalOverlayView.m
//  Ingress
//
//  Created by Alex Studnicka on 20.01.13.
//  Copyright (c) 2013 A&A Code. All rights reserved.
//

#import "PortalOverlayView.h"

#import "ScannerViewController.h"

@implementation PortalOverlayView

- (void)drawMapRect:(MKMapRect)mapRect zoomScale:(MKZoomScale)zoomScale inContext:(CGContextRef)context {

	ScannerViewController *scannerVC = [AppDelegate instance].scannerViewController;
	Portal *portal = (Portal *)self.overlay;

	if (portal.completeInfo) {
		CGImageRef portalImage;

		if (portal.completeInfo && [portal.controllingTeam isEqualToString:@"ALIENS"]) {
			portalImage = scannerVC.alienPortalImage.CGImage;
		} else if (portal.completeInfo && [portal.controllingTeam isEqualToString:@"RESISTANCE"]) {
			portalImage = scannerVC.resistancePortalImage.CGImage;
		} else {
			portalImage = scannerVC.neutralPortalImage.CGImage;
		}

		MKMapPoint portalCenter = MKMapPointForCoordinate(self.overlay.coordinate);
		CGPoint portalCenterPoint = [self pointForMapPoint:portalCenter];

		CGFloat portalSize = 400;

		CGContextDrawImage(context, CGRectMake(portalCenterPoint.x-portalSize/2, portalCenterPoint.y-portalSize/2, portalSize, portalSize), portalImage);
	}

}

@end

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

	Portal *portal = (Portal *)self.overlay;

	if (portal.completeInfo) {
		CGImageRef portalImage;

		int count = [DeployedResonator MR_countOfEntitiesWithPredicate:[NSPredicate predicateWithFormat:@"portal = %@", portal]];
		if (count > 0) {
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

}

@end

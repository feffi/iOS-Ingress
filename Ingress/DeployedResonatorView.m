//
//  DeployedResonatorView.m
//  Ingress
//
//  Created by Alex Studnicka on 20.02.13.
//  Copyright (c) 2013 A&A Code. All rights reserved.
//

#import "DeployedResonatorView.h"
#import "MKCircle+Ingress.h"

@implementation DeployedResonatorView

- (id)initWithCircle:(MKCircle *)circle {
    self = [super initWithCircle:circle];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(damage:) name:@"ResonatorDamage" object:self.circle.deployedResonator];
    }
    return self;
}

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)drawMapRect:(MKMapRect)mapRect zoomScale:(MKZoomScale)zoomScale inContext:(CGContextRef)context {
	[super drawMapRect:mapRect zoomScale:zoomScale inContext:context];
	
	if (damageDict) {
		
		int damagePercent = ([damageDict[@"damageAmount"] floatValue]/(float)[API maxEnergyForResonatorLevel:self.circle.deployedResonator.level])*100;

		if (damagePercent > 0) {
			@synchronized([DeployedResonatorView class]) {

				UIGraphicsPushContext(context);
				CGContextSaveGState(context);
				CGRect overallCGRect = [self rectForMapRect:self.overlay.boundingMapRect];
				overallCGRect.origin.x -= 20;
				overallCGRect.size.width += 40;
				overallCGRect.origin.y -= 24;
				[[UIColor redColor] set];
				[[NSString stringWithFormat:@"-%d%%", damagePercent] drawInRect:overallCGRect withFont:[UIFont systemFontOfSize:18] lineBreakMode:NSLineBreakByClipping alignment:NSTextAlignmentCenter];
				CGContextRestoreGState(context);
				UIGraphicsPopContext();
				
			}
		}
		
		dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC));
		dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
			
			if ([damageDict[@"destoryed"] boolValue]) {
				[[[AppDelegate instance] mapView] removeOverlay:self.circle];
			}
			
			damageDict = nil;
			[self setNeedsDisplay];
			
		});
		
	}
	
}

- (void)damage:(NSNotification *)notification {
	damageDict = notification.userInfo;
	[self setNeedsDisplay];
}

@end

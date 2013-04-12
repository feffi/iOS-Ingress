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
	
//	CGContextSetBlendMode(context, kCGBlendModeSaturation);
//    CGContextSetRGBFillColor(context, 0, 0, 0, 1);
//    CGContextFillRect(context, [self rectForMapRect:mapRect]);
	
//	CGContextSetBlendMode(context, kCGBlendModeOverlay);
//    CGContextSetRGBFillColor(context, 0, 0, 0, .5);
//    CGContextFillRect(context, [self rectForMapRect:mapRect]);

	///////////////////////////////
	
	double maxx = MKMapRectGetMaxX(mapRect);
    double minx = MKMapRectGetMinX(mapRect);
    double maxy = MKMapRectGetMaxY(mapRect);
    double miny = MKMapRectGetMinY(mapRect);

    CGPoint tr = [self pointForMapPoint:(MKMapPoint) {maxx, maxy}];
    CGPoint br = [self pointForMapPoint:(MKMapPoint) {maxx, miny}];
    CGPoint bl = [self pointForMapPoint:(MKMapPoint) {minx, miny}];
    CGPoint tl = [self pointForMapPoint:(MKMapPoint) {minx, maxy}];

    CGMutablePathRef cgPath = CGPathCreateMutable();
    CGPathMoveToPoint(cgPath, NULL, tr.x, tr.y);
    CGPathAddLineToPoint(cgPath, NULL, br.x, br.y);
    CGPathAddLineToPoint(cgPath, NULL, bl.x, bl.y);
    CGPathAddLineToPoint(cgPath, NULL, tl.x, tl.y);
    CGPathAddLineToPoint(cgPath, NULL, tr.x, tr.y);

    CGContextSaveGState(context);
    CGContextAddPath(context, cgPath);
    CGContextSetStrokeColorWithColor(context, [UIColor redColor].CGColor);
    CGContextSetLineJoin(context, kCGLineJoinRound);
    CGContextSetLineCap(context, kCGLineCapRound);
    CGContextSetLineWidth(context, 2);
    CGContextStrokePath(context);
    CGPathRelease(cgPath);
    CGContextRestoreGState(context);
	
	///////////////////////////////
	
//	MKMapView *mapView = [AppDelegate instance].mapView;
//	UIGraphicsBeginImageContextWithOptions(mapView.bounds.size, NO, 0);
//	[mapView.layer renderInContext:UIGraphicsGetCurrentContext()];
//	UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
//	UIGraphicsEndImageContext();
//
//	CIImage *beginImage = [CIImage imageWithCGImage:img.CGImage];
//	CIContext *ciContext = [CIContext contextWithOptions:nil];
//	
//	CIFilter *filter = [CIFilter filterWithName:@"CIColorInvert" keysAndValues:
//						kCIInputImageKey, beginImage,
//						nil];
//	CIImage *outputImage = [filter outputImage];
//	
//	filter = [CIFilter filterWithName:@"CIColorControls" keysAndValues:
//			  kCIInputImageKey, outputImage,
//			  @"inputSaturation", @0,
//			  //@"inputBrightness", @.25,
//			  nil];
//	outputImage = [filter outputImage];
//	
//	CGImageRef cgimg = [ciContext createCGImage:outputImage fromRect:[outputImage extent]];
//
//	CGContextDrawImage(context, CGRectMake(tr.x, tr.y, bl.x - tr.x, bl.y - tr.y), cgimg);
	
}

@end

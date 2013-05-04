//
//  APView.m
//  DrawingTest
//
//  Created by Alex Studnička on 04.05.13.
//  Copyright (c) 2013 A&A Code. All rights reserved.
//

#import "APView.h"

@implementation APView

@synthesize faction = _faction;
@synthesize progress = _progress;

- (id)initWithCoder:(NSCoder *)aDecoder {
	self = [super initWithCoder:aDecoder];
	if (self) {
		_faction = @"ALIENS";
		_progress = 0;
	}
	return self;
}

- (UIImage *)maskImageForSize:(CGSize)size percent:(float)percent  {
    UIGraphicsBeginImageContextWithOptions(size, NO, [UIScreen mainScreen].scale);
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
	CGContextFillRect(context, (CGRect){CGPointZero, size});
	CGFloat start = -2;
	CGFloat maskSize = size.width/2;
    UIBezierPath *circle = [UIBezierPath bezierPathWithArcCenter:CGPointMake(maskSize, maskSize) radius:maskSize startAngle:start endAngle:start+(M_PI*2*percent) clockwise:YES];
	circle.lineWidth = 20;
	[[UIColor blackColor] setStroke];
    [circle stroke];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
	return image;
}

- (UIImage*) maskImage:(UIImage *)image withMask:(UIImage *)maskImage {
    CGImageRef maskRef = maskImage.CGImage;
    CGImageRef mask = CGImageMaskCreate(CGImageGetWidth(maskRef),
										CGImageGetHeight(maskRef),
										CGImageGetBitsPerComponent(maskRef),
										CGImageGetBitsPerPixel(maskRef),
										CGImageGetBytesPerRow(maskRef),
										CGImageGetDataProvider(maskRef), NULL, false);
    CGImageRef maskedImageRef = CGImageCreateWithMask([image CGImage], mask);
    UIImage *maskedImage = [UIImage imageWithCGImage:maskedImageRef];
    CGImageRelease(mask);
    CGImageRelease(maskedImageRef);
    return maskedImage;
}

- (void)setFaction:(NSString *)faction {
	_faction = faction;
	[self setNeedsDisplay];
}

- (void)setProgress:(float)progress {
	_progress = progress;
	[self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
	[[self maskImage:[UIImage imageNamed:[NSString stringWithFormat:@"ap_fill_%@", [self.faction lowercaseString]]] withMask:[self maskImageForSize:rect.size percent:self.progress]] drawInRect:rect];
	[[UIImage imageNamed:[NSString stringWithFormat:@"ap_stroke_%@", [self.faction lowercaseString]]] drawInRect:rect];
}

@end

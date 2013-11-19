//
//  GlowingLabel.m
//  Ingress
//
//  Created by Alex Studnička on 28.04.13.
//  Copyright (c) 2013 A&A Code. All rights reserved.
//

#import "GlowingLabel.h"

@implementation GlowingLabel

- (void)drawTextInRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    CGContextSetShadowWithColor(context, CGSizeZero, self.font.pointSize/5, self.textColor.CGColor);

	UIEdgeInsets insets = {self.topInset, self.leftInset, self.bottomInset, self.rightInset};
    [super drawTextInRect:UIEdgeInsetsInsetRect(rect, insets)];

    CGContextRestoreGState(context);
}

@end

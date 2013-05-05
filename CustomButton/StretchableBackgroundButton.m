//
//  StretchableBackgroundButton.m
//  Ingress
//
//  Created by Alex Studnička on 20.04.13.
//  Copyright (c) 2013 A&A Code. All rights reserved.
//

#import "StretchableBackgroundButton.h"

@implementation StretchableBackgroundButton

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {

		[self setBackgroundImage:[[self backgroundImageForState:UIControlStateNormal] stretchableImageWithLeftCapWidth:22 topCapHeight:12] forState:UIControlStateNormal];
		[self setBackgroundImage:[[self backgroundImageForState:UIControlStateHighlighted] stretchableImageWithLeftCapWidth:22 topCapHeight:12] forState:UIControlStateHighlighted];
		[self setBackgroundImage:[[self backgroundImageForState:UIControlStateDisabled] stretchableImageWithLeftCapWidth:22 topCapHeight:12] forState:UIControlStateDisabled];

		self.titleLabel.layer.shadowColor = [self titleColorForState:UIControlStateNormal].CGColor;
		self.titleLabel.layer.shadowOffset = CGSizeZero;
		self.titleLabel.layer.shadowRadius = self.titleLabel.font.pointSize/5;
		self.titleLabel.layer.shadowOpacity = 1;
		self.titleLabel.layer.shouldRasterize = YES;
		self.titleLabel.layer.masksToBounds = NO;

    }
    return self;
}

@end

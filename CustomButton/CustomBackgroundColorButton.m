//
//  CustomBackgroundColorButton.m
//  Ingress
//
//  Created by Alex Studnička on 20.04.13.
//  Copyright (c) 2013 A&A Code. All rights reserved.
//

#import "CustomBackgroundColorButton.h"

@implementation CustomBackgroundColorButton

@synthesize normalColor;
@synthesize highlightedColor;
@synthesize disabledColor;

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {

		normalColor = [UIColor colorWithRed:114.0/255.0 green:247.0/255.0 blue:229.0/255.0 alpha:1.0];
		highlightedColor = [UIColor colorWithRed:219.0/255.0 green:251.0/255.0 blue:247.0/255.0 alpha:1.0];
		disabledColor = [UIColor colorWithRed:30.0/255.0 green:69.0/255.0 blue:76.0/255.0 alpha:1.0];

		[self addTarget:self action:@selector(touchDown) forControlEvents:UIControlEventTouchDown];
		[self addTarget:self action:@selector(touchUp) forControlEvents:UIControlEventTouchUpInside];
		[self addTarget:self action:@selector(touchUp) forControlEvents:UIControlEventTouchUpOutside];

		if (self.enabled) {
			self.backgroundColor = normalColor;
		} else {
			self.backgroundColor = disabledColor;
		}

    }
    return self;
}

- (void)setEnabled:(BOOL)enabled {
	[super setEnabled:enabled];

	if (enabled) {
		self.backgroundColor = normalColor;
	} else {
		self.backgroundColor = disabledColor;
	}
	
}

- (void)touchDown {
	if (!self.enabled) { return; }
	self.backgroundColor = highlightedColor;
}

- (void)touchUp {
	self.backgroundColor = normalColor;
}

@end

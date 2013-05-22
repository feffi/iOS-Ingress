//
//  ScrollTextView.m
//  Ingress
//
//  Created by Alex Studnička on 05.05.13.
//  Copyright (c) 2013 A&A Code. All rights reserved.
//

#import "ScrollTextView.h"

@implementation ScrollTextView {
	NSTimer *scrollTimer;
}

@synthesize scrollInterval = _scrollInterval;
@synthesize glowing = _glowing;

- (id)init {
    self = [super init];
    if (self) {
		self.scrollInterval = 0.04;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
		self.scrollInterval = 0.04;
    }
    return self;
}

- (void)setGlowing:(BOOL)glowing {
	_glowing = glowing;

	if (_glowing) {
		self.layer.shadowColor = self.textColor.CGColor;
		self.layer.shadowOffset = CGSizeZero;
		self.layer.shadowRadius = self.font.pointSize/5;
		self.layer.shadowOpacity = 1;
		self.layer.masksToBounds = YES;
	} else {
		self.layer.shadowRadius = 0;
		self.layer.shadowOpacity = 0;
	}
}

- (void)startScrolling {
	scrollTimer = [NSTimer scheduledTimerWithTimeInterval:(self.scrollInterval) target:self selector:@selector(autoscrollTimerFired) userInfo:nil repeats:YES];
}

- (void)stopScrolling {
	[scrollTimer invalidate];
	scrollTimer = nil;
}

- (void)autoscrollTimerFired {
    [self setContentOffset:CGPointMake(self.contentOffset.x, self.contentOffset.y + 1) animated:NO];
}

- (BOOL)canBecomeFirstResponder {
    return NO;
}

@end

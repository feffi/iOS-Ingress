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

- (id)init {
    self = [super init];
    if (self) {
		self.scrollInterval = 0.04;
		
		self.layer.shadowColor = self.textColor.CGColor;
		self.layer.shadowOffset = CGSizeZero;
		self.layer.shadowRadius = self.font.pointSize/5;
		self.layer.shadowOpacity = 1;
		self.layer.masksToBounds = YES;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
		self.scrollInterval = 0.04;
		
		self.layer.shadowColor = self.textColor.CGColor;
		self.layer.shadowOffset = CGSizeZero;
		self.layer.shadowRadius = self.font.pointSize/5;
		self.layer.shadowOpacity = 1;
		self.layer.masksToBounds = YES;
    }
    return self;
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

@end

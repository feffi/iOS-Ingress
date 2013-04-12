//
//  WheelActivityIndicatorView.m
//  Ingress
//
//  Created by Alex Studnicka on 25.02.13.
//  Copyright (c) 2013 A&A Code. All rights reserved.
//

#import "WheelActivityIndicatorView.h"

@implementation WheelActivityIndicatorView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
		
		frame.size = CGSizeMake(100, 102);
		self.frame = frame;
		
		innerWheel = [[UIImageView alloc] initWithFrame:self.bounds];
		innerWheel.image = [UIImage imageNamed:@"innerwheel.png"];
		[self addSubview:innerWheel];
		
		outerWheel = [[UIImageView alloc] initWithFrame:self.bounds];
		outerWheel.image = [UIImage imageNamed:@"outerwheel.png"];
		[self addSubview:outerWheel];
		
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
		
		CGRect frame = self.frame;
		frame.size = CGSizeMake(100, 102);
		self.frame = frame;
		
		innerWheel = [[UIImageView alloc] initWithFrame:self.bounds];
		innerWheel.image = [UIImage imageNamed:@"innerwheel.png"];
		[self addSubview:innerWheel];
		
		outerWheel = [[UIImageView alloc] initWithFrame:self.bounds];
		outerWheel.image = [UIImage imageNamed:@"outerwheel.png"];
		[self addSubview:outerWheel];
		
    }
    return self;
}

- (void)setFrame:(CGRect)frame {
	frame.size = CGSizeMake(100, 102);
	[super setFrame:frame];
}

- (void)startAnimating {
	
	if (_animating) { return; }
	
	CABasicAnimation *rotationAnimation;
	
    rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimation.toValue = [NSNumber numberWithFloat:M_PI * 2.0];
    rotationAnimation.duration = 6;
    rotationAnimation.repeatCount = INFINITY;
    [innerWheel.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
	
    rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimation.toValue = [NSNumber numberWithFloat:- M_PI * 2.0];
    rotationAnimation.duration = 6;
    rotationAnimation.repeatCount = INFINITY;
    [outerWheel.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
	
	_animating = YES;
	
}

- (void)stopAnimating {
	
	if (!_animating) { return; }
	
	[innerWheel.layer removeAllAnimations];
	[outerWheel.layer removeAllAnimations];
	
	_animating = NO;
	
}

- (BOOL)isAnimating {
	return _animating;
}

@end

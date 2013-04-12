//
//  WheelActivityIndicatorView.h
//  Ingress
//
//  Created by Alex Studnicka on 25.02.13.
//  Copyright (c) 2013 A&A Code. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WheelActivityIndicatorView : UIView {
	
	BOOL _animating;
	
	UIImageView *innerWheel;
	UIImageView *outerWheel;
	
}

- (void)startAnimating;
- (void)stopAnimating;
- (BOOL)isAnimating;

@end

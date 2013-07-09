//
//  CustomButton.m
//  Ingress
//
//  Created by Alex Studnicka on 25.01.13.
//  Copyright (c) 2013 A&A Code. All rights reserved.
//

#import "DarkPressedBackgroundButton.h"

@implementation DarkPressedBackgroundButton

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
		
		[self setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
		[self setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
		[self setTitleColor:[UIColor darkGrayColor] forState:UIControlStateDisabled];
		
		[self addTarget:self action:@selector(touchDown) forControlEvents:UIControlEventTouchDown];
		[self addTarget:self action:@selector(touchUp) forControlEvents:UIControlEventTouchUpInside];
		[self addTarget:self action:@selector(touchUp) forControlEvents:UIControlEventTouchUpOutside];
		
		[self addTarget:self action:@selector(playSound) forControlEvents:UIControlEventTouchUpInside];
		
    }
    return self;
}

- (void)touchDown {
	
	if (!self.enabled) { return; }
	
	CGFloat r = 0;
	CGFloat g = 0;
	CGFloat b = 0;
	
	[self.backgroundColor getRed:&r green:&g blue:&b alpha:nil];
	
	r -= .2;
	g -= .2;
	b -= .2;
	
	self.backgroundColor = [UIColor colorWithRed:r green:g blue:b alpha:1];
	
}

- (void)touchUp {
	
	CGFloat r = 0;
	CGFloat g = 0;
	CGFloat b = 0;
	
	[self.backgroundColor getRed:&r green:&g blue:&b alpha:nil];
	
	r += .2;
	g += .2;
	b += .2;
	
	self.backgroundColor = [UIColor colorWithRed:r green:g blue:b alpha:1];
	
}

- (void)playSound {
	
	if (self.enabled) {
        if ([[NSUserDefaults standardUserDefaults] boolForKey:DeviceSoundToggleEffects]) {
            [[SoundManager sharedManager] playSound:@"Sound/sfx_ui_success.aif"];
        }
	} else {
        if ([[NSUserDefaults standardUserDefaults] boolForKey:DeviceSoundToggleEffects]) {
            [[SoundManager sharedManager] playSound:@"Sound/sfx_ui_fail.aif"];
        }
	}
	
}

@end

//
//  GUIButton.m
//  Ingress
//
//  Created by Alex Studnicka on 01.02.13.
//  Copyright (c) 2013 A&A Code. All rights reserved.
//

#import "GUIButton.h"

@implementation GUIButton

@synthesize disabled = _disabled;

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
		
		_disabled = NO;
		
		UIImage *bgImage;
		
		bgImage = [[UIImage imageNamed:@"default_btn"] stretchableImageWithLeftCapWidth:2 topCapHeight:12];
		[self setBackgroundImage:bgImage forState:UIControlStateNormal];
		
		bgImage = [[UIImage imageNamed:@"default_btn_down"] stretchableImageWithLeftCapWidth:2 topCapHeight:12];
		[self setBackgroundImage:bgImage forState:UIControlStateHighlighted];
		
		bgImage = [[UIImage imageNamed:@"default_btn_disabled"] stretchableImageWithLeftCapWidth:2 topCapHeight:12];
		[self setBackgroundImage:bgImage forState:UIControlStateApplication];
		
		[self setTitleColor:[UIColor colorWithRed:144./255. green:1 blue:1 alpha:1] forState:UIControlStateNormal];
		[self setTitleColor:[UIColor colorWithRed:144./255. green:1 blue:1 alpha:1] forState:UIControlStateHighlighted];
		[self setTitleColor:[UIColor lightGrayColor] forState:UIControlStateApplication];
		
		[self addTarget:self action:@selector(playSound) forControlEvents:UIControlEventTouchUpInside];

    }
    return self;
}

- (UIControlState)state {
	UIControlState customState = super.state;
	if (self.disabled) {
		customState |= UIControlStateApplication;
	}
	//customState &= ~UIControlStateDisabled;
	return customState;
}

- (void)setEnabled:(BOOL)enabled {
	[super setEnabled:YES];
	self.disabled = !enabled;
}

//- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
//	if (_enabled) {
//		[super touchesEnded:touches withEvent:event];
//	} else {
//		self.highlighted = NO;
//	}
//}

- (void)playSound {
	if (!self.disabled) {
		[[SoundManager sharedManager] playSound:@"Sound/sfx_ui_success.aif"];
	} else {
		[[SoundManager sharedManager] playSound:@"Sound/sfx_ui_fail.aif"];
	}
}

@end

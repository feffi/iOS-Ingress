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
@synthesize errorString = _errorString;

- (id)init {
    self = [super init];
    if (self) {
		[self setup];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
		[self setup];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
		[self setup];
    }
    return self;
}

- (void)setupBackground {
	UIImage *bgImage;
	
	bgImage = [[UIImage imageNamed:@"default_btn"] stretchableImageWithLeftCapWidth:2 topCapHeight:12];
	[self setBackgroundImage:bgImage forState:UIControlStateNormal];
	
	bgImage = [[UIImage imageNamed:@"default_btn_down"] stretchableImageWithLeftCapWidth:2 topCapHeight:12];
	[self setBackgroundImage:bgImage forState:UIControlStateHighlighted];
	
	bgImage = [[UIImage imageNamed:@"default_btn_disabled"] stretchableImageWithLeftCapWidth:2 topCapHeight:12];
	[self setBackgroundImage:bgImage forState:UIControlStateApplication];
}

- (void)setup {
	
	_disabled = NO;
	_errorString = nil;

	[self setupBackground];

	[self setTitleColor:[UIColor colorWithRed:144./255. green:1 blue:1 alpha:1] forState:UIControlStateNormal];
	[self setTitleColor:[UIColor colorWithRed:144./255. green:1 blue:1 alpha:1] forState:UIControlStateHighlighted];
	[self setTitleColor:[UIColor lightGrayColor] forState:UIControlStateApplication];
	
    self.titleLabel.font = [UIFont fontWithName:[[[UILabel appearance] font] fontName] size:18];

	self.titleLabel.layer.shadowColor = [self titleColorForState:UIControlStateNormal].CGColor;
	self.titleLabel.layer.shadowOffset = CGSizeZero;
	self.titleLabel.layer.shadowRadius = 18/5;
	self.titleLabel.layer.shadowOpacity = 1;
	self.titleLabel.layer.shouldRasterize = YES;
	self.titleLabel.layer.masksToBounds = NO;

	[self removeTarget:self action:NULL forControlEvents:UIControlEventAllEvents];
	[self addTarget:self action:@selector(touchUp) forControlEvents:UIControlEventTouchUpInside];
	
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
	[self setupBackground];
}

//- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
//	if (_enabled) {
//		[super touchesEnded:touches withEvent:event];
//	} else {
//		self.highlighted = NO;
//	}
//}

- (void)touchUp {
	if (!self.disabled) {
        if ([[NSUserDefaults standardUserDefaults] boolForKey:DeviceSoundToggleEffects]) {
            [[SoundManager sharedManager] playSound:@"Sound/sfx_ui_success.aif"];
        }
	} else {
        if ([[NSUserDefaults standardUserDefaults] boolForKey:DeviceSoundToggleEffects]) {
            [[SoundManager sharedManager] playSound:@"Sound/sfx_ui_fail.aif"];
        }

		if (self.errorString && ![[self titleColorForState:UIControlStateApplication] isEqual:[UIColor redColor]]) {
			__block UIColor *oldColor = [self titleColorForState:UIControlStateApplication];
			__block NSString *oldTitle = [self titleForState:UIControlStateApplication];

			[self setTitleColor: [UIColor redColor] forState:UIControlStateApplication];
			[self setTitle:self.errorString forState:UIControlStateApplication];
			self.titleLabel.layer.shadowColor = [UIColor redColor].CGColor;

			dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC));
			dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
				[self setTitleColor:oldColor forState:UIControlStateApplication];
				[self setTitle:oldTitle forState:UIControlStateApplication];
				self.titleLabel.layer.shadowColor = [self titleColorForState:UIControlStateNormal].CGColor;
			});
		}

	}
}

@end

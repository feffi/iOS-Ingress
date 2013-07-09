//
//  CommTableViewCell.m
//  Ingress
//
//  Created by Alex Studnicka on 11.01.13.
//  Copyright (c) 2013 A&A Code. All rights reserved.
//

#import "CommTableViewCell.h"

@implementation CommTableViewCell {
	UIImageView *nudgeImageView;
}

@synthesize mentionsYou = _mentionsYou;

- (void)setMentionsYou:(BOOL)mentionsYou {
	_mentionsYou = mentionsYou;

	if (mentionsYou) {
		if (!nudgeImageView) {
			nudgeImageView = [UIImageView new];
			nudgeImageView.opaque = NO;
			nudgeImageView.image = [[UIImage imageNamed:@"nudge_callout.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(8, 2, 10, 8)];
		}
		nudgeImageView.frame = CGRectMake(0, 2, self.timeLabel.frame.size.width+2, self.timeLabel.frame.size.height-4);
		[self.contentView insertSubview:nudgeImageView belowSubview:self.timeLabel];

		self.timeLabel.textColor = [UIColor colorWithRed:0.965 green:0.800 blue:0.302 alpha:1.000];
		self.timeLabel.backgroundColor = [UIColor clearColor];
	} else {
		if (nudgeImageView) {
			[nudgeImageView removeFromSuperview];
			nudgeImageView = nil;
		}

		self.timeLabel.textColor = [UIColor colorWithRed:0.561 green:0.576 blue:0.584 alpha:1.000];
	}

}

@end

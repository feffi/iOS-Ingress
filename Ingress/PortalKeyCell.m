//
//  PortalKeyCell.m
//  Ingress
//
//  Created by Alex Studnicka on 23.01.13.
//  Copyright (c) 2013 A&A Code. All rights reserved.
//

#import "PortalKeyCell.h"

@implementation PortalKeyCell

- (void)layoutSubviews {
    [super layoutSubviews];

	self.imageView.frame = CGRectMake(0,0,44,44);
	self.textLabel.frame = CGRectMake(52,self.textLabel.frame.origin.y,self.frame.size.width-60,self.textLabel.frame.size.height);
	self.detailTextLabel.frame = CGRectMake(52,self.detailTextLabel.frame.origin.y,self.frame.size.width-60,self.detailTextLabel.frame.size.height);
	self.imageView.contentMode = UIViewContentModeScaleAspectFill;
	self.imageView.clipsToBounds = YES;

	CGRect frame;

	self.textLabel.font = [UIFont fontWithName:[[[UILabel appearance] font] fontName] size:14];
	frame = self.textLabel.frame;
	frame.origin.y = 2;
	self.textLabel.frame = frame;

	self.detailTextLabel.font = [UIFont fontWithName:[[[UILabel appearance] font] fontName] size:12];
	frame = self.detailTextLabel.frame;
	frame.origin.y = 20;
	self.detailTextLabel.frame = frame;

}

@end

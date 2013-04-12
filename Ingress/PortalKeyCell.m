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

}

@end

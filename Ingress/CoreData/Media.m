//
//  Media.m
//  Ingress
//
//  Created by Alex Studnicka on 24.01.13.
//  Copyright (c) 2013 A&A Code. All rights reserved.
//

#import "Media.h"


@implementation Media

@dynamic name;
@dynamic level;
@dynamic imageURL;
@dynamic url;
@dynamic imageData;

- (NSString *)description {
	return [NSString stringWithFormat:@"L%d Media Item", self.level];
}

@end

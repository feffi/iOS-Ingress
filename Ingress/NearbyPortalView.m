//
//  NearbyPortalView.m
//  Ingress
//
//  Created by Alex Studnička on 03.07.13.
//  Copyright (c) 2013 A&A Code. All rights reserved.
//

#import "NearbyPortalView.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "GlowingLabel.h"

@implementation NearbyPortalView

- (id)initWithFrame:(CGRect)frame portal:(NSDictionary *)portal {
    self = [super initWithFrame:frame];
    if (self) {
		
		self.userInteractionEnabled = NO;
		
		CLLocationDistance distance = [[[LocationManager sharedInstance] playerLocation] distanceFromLocation:portal[@"location"]];
		CLLocationDirection direction = [Utilities angleFromCoordinate:[[[LocationManager sharedInstance] playerLocation] coordinate] toCoordinate:[portal[@"location"] coordinate]];

		self.backgroundColor = [[Utilities colorForFaction:portal[@"controllingTeam"]] colorWithAlphaComponent:0.25];
		
		self.layer.borderWidth = 2;
		self.layer.borderColor = [[Utilities colorForFaction:portal[@"controllingTeam"]] colorWithAlphaComponent:0.5].CGColor;
		
		UIImageView *arrowImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 15, 50, 50)];
		arrowImageView.image = [UIImage imageNamed:@"playerArrow_aliens.png"];
		arrowImageView.contentMode = UIViewContentModeScaleAspectFit;
		arrowImageView.transform = CGAffineTransformMakeRotation(GLKMathDegreesToRadians(direction));
		[self addSubview:arrowImageView];
		
		float yardModifier = 1;
		if (![[NSUserDefaults standardUserDefaults] boolForKey:MilesOrKM]) {
			yardModifier = 1.0936133;
		}
		
		UILabel *label = [[GlowingLabel alloc] initWithFrame:CGRectMake(55, 0, 145, 80)];
		label.numberOfLines = 0;
		label.text = [NSString stringWithFormat:@"%@ (%.0f %@)", portal[@"name"], floorf(distance*yardModifier), ([[NSUserDefaults standardUserDefaults] boolForKey:MilesOrKM] ? @"m" : @"yd")];
		label.font = [UIFont fontWithName:[[[UILabel appearance] font] fontName] size:16];
		label.textColor = [UIColor whiteColor];
		[self addSubview:label];
		
		UIImageView *portalImageView = [[UIImageView alloc] initWithFrame:CGRectMake(self.frame.size.width-70, 10, 60, 60)];
		[portalImageView setImageWithURL:[NSURL URLWithString:portal[@"imageURL"]] placeholderImage:[UIImage imageNamed:@"missing_image"]];
		portalImageView.contentMode = UIViewContentModeScaleAspectFit;
		[self addSubview:portalImageView];

    }
    return self;
}

@end

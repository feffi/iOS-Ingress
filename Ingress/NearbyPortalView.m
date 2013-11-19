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

@interface NearbyPortalView ()

@property UILabel *glowingLabel;
@property UIImageView *arrowImageView;

@end

@implementation NearbyPortalView {
	NSString *portalName;
	CLLocation *portalLocation;
}

- (id)initWithFrame:(CGRect)frame portal:(NSDictionary *)portal {
    self = [super initWithFrame:frame];
    if (self) {
		
		self.userInteractionEnabled = NO;
		
		self.portalGUID = portal[@"guid"];
		portalLocation = portal[@"location"];
		portalName = portal[@"name"];
		

		self.backgroundColor = [[Utilities colorForFaction:portal[@"controllingTeam"]] colorWithAlphaComponent:0.25];
		
		self.layer.borderWidth = 2;
		self.layer.borderColor = [[Utilities colorForFaction:portal[@"controllingTeam"]] colorWithAlphaComponent:0.5].CGColor;
		
		self.arrowImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 15, 50, 50)];
		self.arrowImageView.image = [UIImage imageNamed:@"playerArrow_aliens.png"];
		self.arrowImageView.contentMode = UIViewContentModeScaleAspectFit;
		[self addSubview:self.arrowImageView];
		
		
		self.glowingLabel = [[GlowingLabel alloc] initWithFrame:CGRectMake(55, 0, 145, 80)];
		self.glowingLabel.numberOfLines = 0;
		self.glowingLabel.font = [UIFont fontWithName:[[[UILabel appearance] font] fontName] size:16];
		self.glowingLabel.textColor = [UIColor whiteColor];
		self.glowingLabel.backgroundColor = [UIColor clearColor];
		[self addSubview:self.glowingLabel];
		
		UIImageView *portalImageView = [[UIImageView alloc] initWithFrame:CGRectMake(self.frame.size.width-70, 10, 60, 60)];
		[portalImageView setImageWithURL:[NSURL URLWithString:portal[@"imageURL"]] placeholderImage:[UIImage imageNamed:@"missing_image"]];
		portalImageView.contentMode = UIViewContentModeScaleAspectFit;
		[self addSubview:portalImageView];
		
		[self updateInformation];
    }
	
    return self;
}

- (void)updateInformation {
	float yardModifier;
	NSString *unitLabel;
	if ([[NSUserDefaults standardUserDefaults] boolForKey:MilesOrKM]) {
		yardModifier = 1;
		unitLabel = @"m";
	} else {
		yardModifier = 1.0936133;
		unitLabel = @"yd";
	}

	CLLocationDistance distance = [[[LocationManager sharedInstance] playerLocation] distanceFromLocation:portalLocation];
	CLLocationDirection direction = [Utilities angleFromCoordinate:[[[LocationManager sharedInstance] playerLocation] coordinate] toCoordinate:[portalLocation coordinate]];

	self.arrowImageView.transform = CGAffineTransformMakeRotation(GLKMathDegreesToRadians(direction));
	self.glowingLabel.text = [NSString stringWithFormat:@"%@ (%.0f %@)", portalName, floorf(distance*yardModifier), unitLabel];

}

@end

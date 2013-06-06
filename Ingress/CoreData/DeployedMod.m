//
//  DeployedMod.m
//  Ingress
//
//  Created by Alex Studnicka on 24.01.13.
//  Copyright (c) 2013 A&A Code. All rights reserved.
//

#import "DeployedMod.h"
#import "Portal.h"
#import "User.h"


@implementation DeployedMod

@dynamic slot;
@dynamic rarity;
@dynamic owner;
@dynamic portal;

- (NSString *)rarityStr {
	return [Utilities rarityStringFromRarity:self.rarity];
}

@end

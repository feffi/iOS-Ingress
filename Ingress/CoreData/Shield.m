//
//  Shield.m
//  Ingress
//
//  Created by Alex Studnicka on 24.01.13.
//  Copyright (c) 2013 A&A Code. All rights reserved.
//

#import "Shield.h"


@implementation Shield

@dynamic rarity;

- (NSString *)rarityStr {
	return [API shieldRarityStrFromRarity:self.rarity];
}

- (NSString *)description {
	return [NSString stringWithFormat:@"%@ Portal Shield", self.rarityStr];
}

@end

//
//  Mod.m
//  Ingress
//
//  Created by Alex Studnička on 06.06.13.
//  Copyright (c) 2013 A&A Code. All rights reserved.
//

#import "Mod.h"


@implementation Mod

@dynamic rarity;

- (NSString *)rarityStr {
	return [Utilities rarityStringFromRarity:self.rarity];
}

- (NSString *)description {
	return [NSString stringWithFormat:@"%@ Unknown Mod", self.rarityStr];
}

@end

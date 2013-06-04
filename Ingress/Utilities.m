//
//  Utilities.m
//  Ingress
//
//  Created by Alex Studnička on 04.06.13.
//  Copyright (c) 2013 A&A Code. All rights reserved.
//

#import "Utilities.h"

@implementation Utilities

#pragma mark - NSAttributedString attributes

+ (NSDictionary *)attributesWithShadow:(BOOL)shadow size:(CGFloat)size color:(UIColor *)color {

	NSMutableDictionary *attributes = [NSMutableDictionary dictionary];

	attributes[NSFontAttributeName] = [UIFont fontWithName:[[[UILabel appearance] font] fontName] size:size];
	attributes[NSForegroundColorAttributeName] = color;

	if (shadow) {
		NSShadow *shadowObj = [NSShadow new];
		shadowObj.shadowOffset = CGSizeZero;
		shadowObj.shadowBlurRadius = size/5;
		shadowObj.shadowColor = color;
		attributes[NSShadowAttributeName] = shadowObj;
	}

	return attributes;

}

#pragma mark - Rarity

+ (UIColor *)colorForRarity:(ItemRarity)rarity {

	switch (rarity) {
		case ItemRarityVeryCommon:
			return [UIColor whiteColor];
		case ItemRarityCommon:
			return [UIColor colorWithRed:0.220 green:1.000 blue:0.749 alpha:1.000];
		case ItemRarityLessCommon:
			return [UIColor colorWithRed:0.216 green:0.478 blue:1.000 alpha:1.000];
		case ItemRarityRare:
			return [UIColor colorWithRed:0.537 green:0.306 blue:0.996 alpha:1.000];
		case ItemRarityVeryRare:
			return [UIColor colorWithRed:1.000 green:0.239 blue:1.000 alpha:1.000];
		case ItemRarityExtraRare:
			return [UIColor colorWithRed:1.000 green:0.196 blue:0.196 alpha:1.000];
		default:
			return [UIColor whiteColor];
	}

}

+ (NSString *)rarityStringFromRarity:(ItemRarity)rarity {

	switch (rarity) {
		case ItemRarityVeryCommon:
			return @"Very Common";
		case ItemRarityCommon:
			return @"Common";
		case ItemRarityLessCommon:
			return @"Less Common";
		case ItemRarityRare:
			return @"Rare";
		case ItemRarityVeryRare:
			return @"Very Rare";
		case ItemRarityExtraRare:
			return @"Extra Rare";
		default:
			return @"Unknown";
	}

}

+ (ItemRarity)rarityFromString:(NSString *)rarityStr {
	if ([rarityStr isEqualToString:@"VERY_COMMON"]) {
		return ItemRarityVeryCommon;
	} else if ([rarityStr isEqualToString:@"COMMON"]) {
		return ItemRarityCommon;
	} else if ([rarityStr isEqualToString:@"LESS_COMMON"]) {
		return ItemRarityLessCommon;
	} else if ([rarityStr isEqualToString:@"RARE"]) {
		return ItemRarityRare;
	} else if ([rarityStr isEqualToString:@"VERY_RARE"]) {
		return ItemRarityVeryRare;
	} else if ([rarityStr isEqualToString:@"EXTRA_RARE"]) {
		return ItemRarityExtraRare;
	}
	return ItemRarityUnknown;
}

+ (ItemRarity)rarityFromInt:(int)rarityInt {
	switch (rarityInt) {
		case 1:
			return ItemRarityVeryCommon;
		case 2:
			return ItemRarityCommon;
		case 3:
			return ItemRarityLessCommon;
		case 4:
			return ItemRarityRare;
		case 5:
			return ItemRarityVeryRare;
		case 6:
			return ItemRarityExtraRare;
		default:
			return ItemRarityUnknown;
	}
}

@end

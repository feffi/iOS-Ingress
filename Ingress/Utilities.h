//
//  Utilities.h
//  Ingress
//
//  Created by Alex Studnička on 04.06.13.
//  Copyright (c) 2013 A&A Code. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
	ItemRarityVeryCommon,
	ItemRarityCommon,
	ItemRarityLessCommon,
	ItemRarityRare,
	ItemRarityVeryRare,
	ItemRarityExtraRare,
	ItemRarityUnknown
} ItemRarity;

@interface Utilities : NSObject

+ (NSDictionary *)attributesWithShadow:(BOOL)shadow size:(CGFloat)size color:(UIColor *)color;

+ (UIColor *)colorForRarity:(ItemRarity)rarity;
+ (NSString *)rarityStringFromRarity:(ItemRarity)rarity;
+ (ItemRarity)rarityFromString:(NSString *)rarityStr;
+ (ItemRarity)rarityFromInt:(int)rarityInt;

@end

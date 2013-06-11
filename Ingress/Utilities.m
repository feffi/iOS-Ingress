//
//  Utilities.m
//  Ingress
//
//  Created by Alex Studnička on 04.06.13.
//  Copyright (c) 2013 A&A Code. All rights reserved.
//

#import "Utilities.h"

@implementation Utilities

#pragma mark - Singleton

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    static Utilities * __sharedInstance = nil;
    dispatch_once(&onceToken, ^{
        __sharedInstance = [self new];
    });
    return __sharedInstance;
}

#pragma mark - iOS 7

+ (BOOL)isOS7 {
	return ([[[UIDevice currentDevice] systemVersion] compare:@"7.0" options:NSNumericSearch] != NSOrderedAscending);
}

#pragma mark - Warning

+ (void)showWarningWithTitle:(NSString *)title {
	MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:[AppDelegate instance].window];
	HUD.userInteractionEnabled = YES;
	HUD.dimBackground = YES;
	HUD.removeFromSuperViewOnHide = YES;
	HUD.mode = MBProgressHUDModeCustomView;
	HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"warning.png"]];
	HUD.detailsLabelFont = [UIFont fontWithName:[[[UILabel appearance] font] fontName] size:16];
	HUD.detailsLabelText = title;
	[[AppDelegate instance].window addSubview:HUD];
	[HUD show:YES];
	[HUD hide:YES afterDelay:HUD_DELAY_TIME];
}

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

#pragma mark - Levels

+ (int)levelForAp:(int)ap {

	if (ap > 1200000) {
		return 8;
	} else if (ap > 600000) {
		return 7;
	} else if (ap > 300000) {
		return 6;
	} else if (ap > 150000) {
		return 5;
	} else if (ap > 70000) {
		return 4;
	} else if (ap > 30000) {
		return 3;
	} else if (ap > 10000) {
		return 2;
	} else if (ap >= 0) {
		return 1;
	}

	return 0;

}

+ (int)maxApForLevel:(int)level {
	return (level > 0 && level < 8) ? [@[@0, @10000, @30000, @70000, @150000, @300000, @600000, @1200000, @(INFINITY)][level] intValue] : 0;
}

+ (int)maxXmForLevel:(int)level {

	switch (level) {
		case 1:
			return 3000;
		case 2:
			return 4000;
		case 3:
			return 5000;
		case 4:
			return 6000;
		case 5:
			return 7000;
		case 6:
			return 8000;
		case 7:
			return 9000;
		case 8:
			return 10000;
		default:
			return 0;
	}

}

+ (int)maxEnergyForResonatorLevel:(int)level {

	switch (level) {
		case 1:
			return 1000;
		case 2:
			return 1500;
		case 3:
			return 2000;
		case 4:
			return 2500;
		case 5:
			return 3000;
		case 6:
			return 4000;
		case 7:
			return 5000;
		case 8:
			return 6000;
		default:
			return 0;
	}

}

#pragma mark - Factions

+ (NSString *)factionStrForFaction:(NSString *)faction {
	if ([faction isEqualToString:@"ALIENS"]) {
		return @"Enlightened";
	} else if ([faction isEqualToString:@"RESISTANCE"]) {
		return @"Resistance";
	} else {
		return @"Neutral";
	}
}

#pragma mark - Colors

+ (UIColor *)colorForLevel:(int)level {

	switch (level) {
		case 1:
			return UIColorFromRGB(0xfece5a);
		case 2:
			return UIColorFromRGB(0xffa630);
		case 3:
			return UIColorFromRGB(0xff7315);
		case 4:
			return UIColorFromRGB(0xe40000);
		case 5:
			return UIColorFromRGB(0xfd2992);
		case 6:
			return UIColorFromRGB(0xeb26cd);
		case 7:
			return UIColorFromRGB(0xc124e0);
		case 8:
			return UIColorFromRGB(0x9627f4);
		default:
			return [UIColor whiteColor];
	}

}

+ (UIColor *)colorForFaction:(NSString *)faction {
	if ([faction isEqualToString:@"ALIENS"]) {
		return [UIColor colorWithRed:0.000 green:0.945 blue:0.439 alpha:1.000];
	} else if ([faction isEqualToString:@"RESISTANCE"]) {
		return [UIColor colorWithRed:0 green:194./255. blue:1 alpha:1];
	} else {
		return [UIColor grayColor];
	}
}

#pragma mark - Portals

+ (UIImage *)iconForPortal:(Portal *)portal {

	UIGraphicsBeginImageContextWithOptions(CGSizeMake(30, 30), NO, [UIScreen mainScreen].scale);
	UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	return newImage;

	//	if (portal.resonators.count > 0) {
	//
	//		NSString *factionStr;
	//		if ([portal.controllingTeam isEqualToString:@"ALIENS"]) { factionStr = @"enl"; } else { factionStr = @"hum"; }
	//
	//		UIImage *bg = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%dres.png", factionStr, portal.resonators.count]];
	//
	//		int portalLevel = portal.level;
	//
	//		if (portalLevel > 1) {
	//
	//			UIImage *fg = [UIImage imageNamed:[NSString stringWithFormat:@"%@_lev%d.png", factionStr, portalLevel]];
	//			UIGraphicsBeginImageContextWithOptions(bg.size, NO, [UIScreen mainScreen].scale);
	//			[bg drawInRect:(CGRect){{0, 0}, bg.size}];
	//			[fg drawInRect:(CGRect){{0, 0}, bg.size}];
	//			UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
	//			UIGraphicsEndImageContext();
	//			return newImage;
	//
	//		} else {
	//			return bg;
	//		}
	//
	//	}
	//
	//	return [UIImage imageNamed:@"neutral_icon.png"];
	
}

@end

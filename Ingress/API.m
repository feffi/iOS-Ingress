//
//  API.m
//  Ingress
//
//  Created by Alex Studnicka on 10.01.13.
//  Copyright (c) 2013 A&A Code. All rights reserved.
//

#import "API.h"

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@implementation API

@synthesize networkQueue = _networkQueue;
@synthesize notificationQueue = _notificationQueue;
@synthesize xsrfToken = _xsrfToken;
@synthesize SACSID = _SACSID;
@synthesize intelcsrftoken = _intelcsrftoken;
@synthesize intelACSID = _intelACSID;
@synthesize playerInfo = _playerInfo;
@synthesize numberOfEnergyToCollect = _numberOfEnergyToCollect;

@synthesize ui_success_sound = _ui_success_sound;
@synthesize ui_fail_sound = _ui_fail_sound;

+ (API *)sharedInstance {
    static dispatch_once_t onceToken;
    static API * __sharedInstance = nil;
    dispatch_once(&onceToken, ^{
        __sharedInstance = [self new];
    });
    return __sharedInstance;
}

- (id)init {
    self = [super init];
	if (self) {
		self.networkQueue = [NSOperationQueue new];
        self.notificationQueue = [NSOperationQueue new];
		self.numberOfEnergyToCollect = 0;
	}
    return self;
}

- (void)dealloc {
	AudioServicesDisposeSystemSoundID(self.ui_success_sound);
	AudioServicesDisposeSystemSoundID(self.ui_fail_sound);
}

#pragma mark - Static Methods

+ (PortalShieldRarity)shieldRarityFromString:(NSString *)shieldRarityStr {
	if ([shieldRarityStr isEqualToString:@"COMMON"]) {
		return PortalShieldRarityCommon;
	} else if ([shieldRarityStr isEqualToString:@"RARE"]) {
		return PortalShieldRarityRare;
	} else if ([shieldRarityStr isEqualToString:@"VERY_RARE"]) {
		return PortalShieldRarityVeryRare;
	}
	return PortalShieldRarityUnknown;
}

+ (PortalShieldRarity)shieldRarityFromInt:(int)shieldRarityInt {
	switch (shieldRarityInt) {
		case 1:
			return PortalShieldRarityCommon;
		case 2:
			return PortalShieldRarityRare;
		case 3:
			return PortalShieldRarityVeryRare;
		default:
			return PortalShieldRarityUnknown;
	}
}

+ (NSString *)shieldRarityStrFromRarity:(PortalShieldRarity)shieldRarity {
	switch (shieldRarity) {
		case PortalShieldRarityCommon:
			return @"Common";
		case PortalShieldRarityRare:
			return @"Rare";
		case PortalShieldRarityVeryRare:
			return @"Very Rare";
		default:
			return @"Unknown";
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

+ (int)levelImageForAp:(int)ap {
	int level = [API levelForAp:ap];
	float max = (float)[API maxApForLevel:level];
	NSArray *maxAPs = @[@0, @10000, @30000, @70000, @150000, @300000, @600000, @1200000];
	int lvlImg = max == 0 ? 0 : floorf(8 * ((ap - [maxAPs[level - 1] floatValue]) / ([maxAPs[level] floatValue] - [maxAPs[level - 1] floatValue])));
	return lvlImg;
}

+ (int)maxApForLevel:(int)level {
	return (level > 0 && level < 8) ? [@[@0, @10000, @30000, @70000, @150000, @300000, @600000, @1200000][level] intValue] : 0;
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
		return [UIColor colorWithRed:40./255. green:244./255. blue:40./255. alpha:1];
	} else if ([faction isEqualToString:@"RESISTANCE"]) {
		return [UIColor colorWithRed:0 green:194./255. blue:1 alpha:1];
	} else {
		return [UIColor grayColor];
	}
}

#pragma mark - Sound

- (float)durationOfSound:(NSString *)soundName {
	AVAsset *audioAsset = [AVAsset assetWithURL:[[NSBundle mainBundle] URLForResource:soundName withExtension:@"aif" subdirectory:@"Sound"]];
	CMTime audioDuration = audioAsset.duration;
	return CMTimeGetSeconds(audioDuration);
}

- (void)playSounds:(NSArray *)soundNames {
	
	int i = 0;
	for (NSString *soundName in soundNames) {
		dispatch_after(dispatch_time(DISPATCH_TIME_NOW, i * ([self durationOfSound:soundName]+.1) * NSEC_PER_SEC), dispatch_get_main_queue(), ^(void){
			[[SoundManager sharedManager] playSound:[NSString stringWithFormat:@"Sound/%@.aif", soundName]];
		});
		i++;
	}
	
}

#pragma mark - Location

- (NSString *)currentE6Location {
	CLLocationCoordinate2D loc = [AppDelegate instance].mapView.centerCoordinate;
	return [NSString stringWithFormat:@"%08x,%08x", (int)(loc.latitude*1E6), (int)(loc.longitude*1E6)];
}

#pragma mark - Portals

- (UIImage *)iconForPortal:(Portal *)portal {
	
	if (portal.resonators.count > 0) {

		NSString *factionStr;
		if ([portal.controllingTeam isEqualToString:@"ALIENS"]) { factionStr = @"enl"; } else { factionStr = @"hum"; }
		
		UIImage *bg = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%dres.png", factionStr, portal.resonators.count]];
		
		int portalLevel = portal.level;

		if (portalLevel > 1) {
			
			UIImage *fg = [UIImage imageNamed:[NSString stringWithFormat:@"%@_lev%d.png", factionStr, portalLevel]];
			UIGraphicsBeginImageContextWithOptions(bg.size, NO, [UIScreen mainScreen].scale);
			[bg drawInRect:(CGRect){{0, 0}, bg.size}];
			[fg drawInRect:(CGRect){{0, 0}, bg.size}];
			UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
			UIGraphicsEndImageContext();
			return newImage;
			
		} else {
			return bg;
		}

	}
	
	return [UIImage imageNamed:@"neutral_icon.png"];
	
}

#pragma mark - Handshake

- (void)processHandshakeData:(NSString *)jsonString completionHandler:(void (^)(NSString *errorStr))handler {
	
//	NSLog(@"jsonString: %@", [jsonString substringFromIndex:9]);
	
	NSData *jsonData = [[jsonString substringFromIndex:9] dataUsingEncoding:NSUTF8StringEncoding];
	
	NSError *jsonParseError;
	id jsonObject = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&jsonParseError];
	if (jsonParseError) { NSLog(@"Handshake jsonParseError: %@", jsonParseError); }
	
	if (jsonObject) {
		
//		NSLog(@"processHandshakeData: %@", jsonObject);
		
		if ([jsonObject[@"result"][@"pregameStatus"][@"action"] isEqualToString:@"USER_REQUIRES_ACTIVATION"]) {
			dispatch_async(dispatch_get_main_queue(), ^{
				handler(@"USER_REQUIRES_ACTIVATION");
			});
			return;
		}
		
		if ([jsonObject[@"result"][@"pregameStatus"][@"action"] isEqualToString:@"USER_MUST_ACCEPT_TOS"]) {
			dispatch_async(dispatch_get_main_queue(), ^{
				handler(@"USER_MUST_ACCEPT_TOS");
			});
			return;
		}
		
		if (![jsonObject[@"result"][@"canPlay"] boolValue]) {
			dispatch_async(dispatch_get_main_queue(), ^{
				handler(@"You are not able to play");
			});
			return;
		}
		
		self.xsrfToken = jsonObject[@"result"][@"xsrfToken"];
		//NSLog(@"xsrfToken: %@", self.xsrfToken);
		
		if ([jsonObject[@"result"][@"playerEntity"][2][@"playerPersonal"][@"allowNicknameEdit"] boolValue]) {
			dispatch_async(dispatch_get_main_queue(), ^{
				handler(@"allowNicknameEdit");
			});
			return;
		}
		
		if ([jsonObject[@"result"][@"playerEntity"][2][@"playerPersonal"][@"allowFactionChoice"] boolValue]) {
			NSLog(@"allowFactionChoice");
			
//			UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Faction choose" message:nil delegate:self cancelButtonTitle:@"Later" otherButtonTitles:@"Enlightened", @"Resistance", nil];
//			[alertView show];
			
//			[[API sharedInstance] chooseFaction:@"ALIENS/RESISTANCE" completionHandler:^{ }];
		}
		
		self.playerInfo = @{
		@"nickname": jsonObject[@"result"][@"nickname"],
		@"team": jsonObject[@"result"][@"playerEntity"][2][@"controllingTeam"][@"team"],
		@"ap": jsonObject[@"result"][@"playerEntity"][2][@"playerPersonal"][@"ap"],
		@"energy": jsonObject[@"result"][@"playerEntity"][2][@"playerPersonal"][@"energy"]
		};
		
		//[[NSNotificationCenter defaultCenter] postNotificationName:@"ProfileUpdatedNotification" object:nil];

		dispatch_async(dispatch_get_main_queue(), ^{
			handler(nil);
			
			/////
			
			[[API sharedInstance] playSounds:@[@"speech_zoom_acquiring", @"speech_zoom_lockon", @"speech_zoom_downloading"]];
			
//			[[SoundManager sharedManager] playSound:@"Sound/speech_zoom_acquiring.aif"];
//			
//			dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1.5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^(void){
//				[[SoundManager sharedManager] playSound:@"Sound/speech_zoom_lockon.aif"];
//			});
//			
//			dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 3 * NSEC_PER_SEC), dispatch_get_main_queue(), ^(void){
//				[[SoundManager sharedManager] playSound:@"Sound/speech_zoom_downloading.aif"];
//			});
			
			///////
        });
		
	} else {
		dispatch_async(dispatch_get_main_queue(), ^{
			handler(@"Server Error");
        });
	}

}

#pragma mark - Cells

- (NSArray *)cellsAsHex {
	
	NSSet *cellsSet = [NSSet setWithObjects:
	
					   // Jablonec
					   
//					   @"470ecad230000000",
//					   @"470ecad030000000",
//					   @"470ecad130000000",
//					   @"470ecad210000000",
//					   @"470ecad010000000",
//					   @"470ecad110000000",
//					   @"470ecad0f0000000",
//					   @"470ecad1f0000000",
//					   @"470ecad3d0000000",
//					   @"470ecad0d0000000",
//					   @"470ecad1d0000000",
//					   @"470ecacfd0000000",
//					   @"470ecad1b0000000",
//					   @"470ecacff0000000",
//					   @"470ecad090000000",
//					   @"470ecacdf0000000",
//					   @"470ecad190000000",
//					   @"470ecadab0000000",
//					   @"470ecace10000000",
//					   @"470ecad070000000",
//					   @"470ecad170000000",
//					   @"470ecada90000000",
//					   @"470ecace30000000",
//					   @"470ecad050000000",
//					   @"470ecad150000000",
					   
					   // Teplice
					   
					   @"47098e8c30000000",
					   @"47098e8d30000000",
					   @"47098e8cf0000000",
					   @"47098e8df0000000",
					   @"47098e8ef0000000",
					   @"47098e8bf0000000",
					   @"47098e8cb0000000",
					   @"47098e8db0000000",
					   @"47098e8eb0000000",
					   @"47098e8c70000000",
					   @"47098e8d70000000",
					   @"47098e8e70000000",
					   @"47098e8b70000000",
					   @"47098e8c10000000",
					   @"47098e8d10000000",
					   @"47098e8e10000000",
					   @"47098e8cd0000000",
					   @"47098e8dd0000000",
					   @"47098e8ed0000000",
					   @"47098e8b90000000",
					   @"47098e8c90000000",
					   @"47098e8d90000000",
					   @"47098e8e90000000",
					   @"47098e8950000000",
					   @"47098e8c50000000",
					   @"47098e8d50000000",
					   @"47098e8e50000000",

//					   @"47098e8d30000000",
//					   @"47098e8e30000000",
//					   @"47098e9250000000",
//					   @"47098e8d10000000",
//					   @"47098e8e10000000",
//					   @"47098e9270000000",
//					   @"47098e9190000000",
//					   @"47098e8df0000000",
//					   @"47098e9290000000",
//					   @"47098e8dd0000000",
//					   @"47098e93b0000000",
//					   @"47098e92b0000000",
//					   @"47098e91d0000000",
//					   @"47098e8db0000000",
//					   @"47098e93d0000000",
//					   @"47098e92d0000000",
//					   @"47098e91f0000000",
//					   @"47098e8d90000000",
//					   @"47098e92f0000000",
//					   @"47098e8d70000000",
//					   @"47098e9310000000",
//					   @"47098e8e70000000",
//					   @"47098e9210000000",
//					   @"47098e8d50000000",
//					   @"47098e9230000000",
//					   
//					   @"47098ef750000000",
//					   @"47098ef150000000",
//					   @"47098ef050000000",
//					   @"47098ef690000000",
//					   @"47098ef390000000",
//					   @"47098ef190000000",
//					   @"47098ef090000000",
//					   @"47098ef6d0000000",
//					   @"47098ef3d0000000",
//					   @"47098ef0d0000000",
//					   @"47098ef710000000",
//					   @"47098ef410000000",
//					   @"47098ef110000000",
//					   @"47098ef170000000",
//					   @"47098ef470000000",
//					   @"47098ef3b0000000",
//					   @"47098ef1b0000000",
//					   @"47098ef0b0000000",
//					   @"47098ef6b0000000",
//					   @"47098ef3f0000000",
//					   @"47098ef0f0000000",
//					   @"47098ef6f0000000",
//					   @"47098ef230000000",
//					   @"47098ef130000000",
//					   @"47098ef730000000",
//					   @"47098ef430000000",
					   
					   // Ústí
					   
//					   @"470984a8b0000000",
//					   @"470984a9b0000000",
//					   @"470984aeb0000000",
//					   @"470984a970000000",
//					   @"470984ae70000000",
//					   @"470984aa30000000",
//					   @"470984a930000000",
//					   @"470984af30000000",
//					   @"470984ac30000000",
//					   @"470984abf0000000",
//					   @"470984a8f0000000",
//					   @"470984aef0000000",
//					   @"470984ae90000000",
//					   @"470984a890000000",
//					   @"470984a990000000",
//					   @"470984ae50000000",
//					   @"470984af50000000",
//					   @"470984a850000000",
//					   @"470984a950000000",
//					   @"470984af10000000",
//					   @"470984ac10000000",
//					   @"470984a910000000",
//					   @"470984aed0000000",
//					   @"470984add0000000",
//					   @"470984abd0000000",
//					   @"470984a8d0000000",
//					   
//					   @"470984ca90000000",
//					   @"470984b5f0000000",
//					   @"470984b4f0000000",
//					   @"470984ca50000000",
//					   @"470984b530000000",
//					   @"470984b430000000",
//					   @"470984ca10000000",
//					   @"470984b670000000",
//					   @"470984b570000000",
//					   @"470984b470000000",
//					   @"470984cad0000000",
//					   @"470984b5b0000000",
//					   @"470984b5d0000000",
//					   @"470984b4d0000000",
//					   @"470984cab0000000",
//					   @"470984b610000000",
//					   @"470984b510000000",
//					   @"470984b410000000",
//					   @"470984ca70000000",
//					   @"470984b550000000",
//					   @"470984b450000000",
//					   @"470984ca30000000",
//					   @"470984b690000000",
//					   @"470984b590000000",
//					   @"470984b490000000",
//					   @"470984c9f0000000",
//					   @"470984caf0000000",
					   
					   // Povrly
					   
//					   @"47099d6850000000",
//					   @"47099d42b0000000",
//					   @"47099d6790000000",
//					   @"47099d6890000000",
//					   @"47099d5d30000000",
//					   @"47099d4270000000",
//					   @"47099d69d0000000",
//					   @"47099d5d70000000",
//					   @"47099d6710000000",
//					   @"47099d6810000000",
//					   @"47099d5db0000000",
//					   @"47099d42f0000000",
//					   @"47099d67d0000000",
//					   @"47099d4290000000",
//					   @"47099d67b0000000",
//					   @"47099d6870000000",
//					   @"47099d5cd0000000",
//					   @"47099d6770000000",
//					   @"47099d69b0000000",
//					   @"47099d5d10000000",
//					   @"47099d6630000000",
//					   @"47099d5d50000000",
//					   @"47099d42d0000000",
//					   @"47099d67f0000000",
//					   @"47099d6830000000",
//					   @"47099d5d90000000",
					   
					   // Děčín
					   
//					   @"47099fcf90000000",
//					   @"47099fce90000000",
//					   @"47099fd1f0000000",
//					   @"47099fcfb0000000",
//					   @"47099fd1d0000000",
//					   @"47099fd230000000",
//					   @"47099fce50000000",
//					   @"47099fd030000000",
//					   @"47099fd210000000",
//					   @"47099fcf70000000",
//					   @"47099fce70000000",
//					   @"47099fd010000000",
//					   @"47099fcf10000000",
//					   @"47099fce10000000",
//					   @"47099fcf30000000",
//					   @"47099fce30000000",
//					   @"47099fd050000000",
//					   @"47099fcfd0000000",
//					   @"47099fced0000000",
//					   @"47099fcdd0000000",
//					   @"47099fd1b0000000",
//					   @"47099fcff0000000",
//					   @"47099fcef0000000",
//					   @"47099fcdf0000000",
//					   @"47099fd190000000",
//					   
//					   @"47099fdf10000000",
//					   @"47099fdc10000000",
//					   @"47099fd930000000",
//					   @"47097561f0000000",
//					   @"47099fdf30000000",
//					   @"47099fd910000000",
//					   @"47097561d0000000",
//					   @"47099fded0000000",
//					   @"47099fdbf0000000",
//					   @"47099fd8f0000000",
//					   @"47099fdef0000000",
//					   @"4709756210000000",
//					   @"47099fd8d0000000",
//					   @"47099fde90000000",
//					   @"4709756270000000",
//					   @"47099fd8b0000000",
//					   @"47099fd9b0000000",
//					   @"47099fdeb0000000",
//					   @"47099fd890000000",
//					   @"47099fdf50000000",
//					   @"47099fd870000000",
//					   @"47099fd970000000",
//					   @"47099fdf70000000",
//					   @"47099fd850000000",
//					   @"47099fd950000000",
					   
					   // Jílové
					   
//					   @"47099ec930000000",
//					   @"47099ecc10000000",
//					   @"47099ec830000000",
//					   @"47099eca30000000",
//					   @"47099ec910000000",
//					   @"47099ecb10000000",
//					   @"47099eca10000000",
//					   @"47099ec9f0000000",
//					   @"47099ec8f0000000",
//					   @"47099ecbf0000000",
//					   @"47099eced0000000",
//					   @"47099ec9d0000000",
//					   @"47099ec8d0000000",
//					   @"47099ecbd0000000",
//					   @"47099ec9b0000000",
//					   @"47099ecbb0000000",
//					   @"47099ec990000000",
//					   @"47099ecb90000000",
//					   @"47099eceb0000000",
//					   @"47099ec970000000",
//					   @"47099ecb70000000",
//					   @"47099ec950000000",
//					   @"47099ecc70000000",
//					   @"47099ec850000000",
//						@"47099eca50000000",
					   
					   // Praha
					   
//						@"470b948d90000000",
//						@"470b9492d0000000",
//						@"470b948d50000000",
//						@"470b948c50000000",
//						@"470b949210000000",
//						@"470b949310000000",
//						@"470b94ed30000000",
//						@"470b948e10000000",
//						@"470b948d10000000",
//						@"470b949250000000",
//						@"470b948dd0000000",
//						@"470b949290000000",
//						@"470b94f2b0000000",
//						@"470b9492f0000000",
//						@"470b94f2d0000000",
//						@"470b9491f0000000",
//						@"470b948db0000000",
//						@"470b949230000000",
//						@"470b94ed50000000",
//						@"470b948e70000000",
//						@"470b948d70000000",
//						@"470b949270000000",
//						@"470b948d30000000",
//						@"470b948c30000000",
//						@"470b9492b0000000",
//						@"470b948df0000000",
//						@"470b948cf0000000",
					   
					   // New York
					   
//					   @"89c25a1750000000",
//					   @"89c25a1050000000",
//					   @"89c25a1910000000",
//					   @"89c25a1a10000000",
//					   @"89c25a1710000000",
//					   @"89c25a1850000000",
//					   @"89c25a1110000000",
//					   @"89c25a1a50000000",
//					   @"89c25a16d0000000",
//					   @"89c25a10d0000000",
//					   @"89c25a1990000000",
//					   @"89c25a1a90000000",
//					   @"89c25a1790000000",
//					   @"89c25a1090000000",
//					   @"89c25a19d0000000",
//					   @"89c25a1bd0000000",
//					   @"89c25a1830000000",
//					   @"89c25a1070000000",
//					   @"89c25a1a30000000",
//					   @"89c25a1770000000",
//					   @"89c25a1970000000",
//					   @"89c25a1130000000",
//					   @"89c25a1a70000000",
//					   @"89c25a1730000000",
//					   @"89c25a10f0000000",
//					   @"89c25a19b0000000",
//					   @"89c25a10b0000000",
//					   @"89c25a19f0000000",
//					   @"89c25a17b0000000",

					   // Almelo, Netherlands

//					   @"47b8063a70000000",
//					   @"47b8063b70000000",
//					   @"47b8062ff0000000",
//					   @"47b8062530000000",
//					   @"47b8063ab0000000",
//					   @"47b8063bb0000000",
//					   @"47b8063070000000",
//					   @"47b8063cb0000000",
//					   @"47b80624f0000000",
//					   @"47b8063af0000000",
//					   @"47b80624b0000000",
//					   @"47b8063b30000000",
//					   @"47b8062570000000",
//					   @"47b8062510000000",
//					   @"47b8063a50000000",
//					   @"47b8063b50000000",
//					   @"47b8063090000000",
//					   @"47b8063c90000000",
//					   @"47b80624d0000000",
//					   @"47b8063a90000000",
//					   @"47b8063b90000000",
//					   @"47b8062490000000",
//					   @"47b8063ad0000000",
//					   @"47b8063010000000",
//					   @"47b8062550000000",
//					   @"47b8062350000000",
//					   @"47b8063b10000000",
//					   @"47b80630b0000000",
//					   @"47b8063970000000",
//					   @"47b8063c70000000",
//					   @"47b8063bf0000000",
//					   @"47b80639f0000000",
//					   @"47b8063a30000000",
//					   @"47b80630f0000000",
//					   @"47b8063750000000",
//					   @"47b8063990000000",
//					   @"47b8063bd0000000",
//					   @"47b8063a10000000",
//					   @"47b8062330000000",
//					   @"47b8063d70000000",
//					   @"47b80622f0000000",
//					   @"47b8063db0000000",
//					   @"47b80622b0000000",
//					   @"47b8063cf0000000",
//					   @"47b8062370000000",
//					   @"47b80617d0000000",
//					   @"47b8061810000000",
//					   @"47b8063d30000000",
//					   @"47b8063c50000000",
//					   @"47b8063d50000000",
//					   @"47b8062310000000",
//					   @"47b8063d90000000",
//					   @"47b80622d0000000",
//					   @"47b8063cd0000000",
//					   @"47b8062290000000",
//					   @"47b8063d10000000",
//					   @"47b80617f0000000",
//					   @"47b8087e10000000",
//					   @"47b80886b0000000",
//					   @"47b80887b0000000",
//					   @"47b80880b0000000",
//					   @"47b8088770000000",
//					   @"47b8087dd0000000",
//					   @"47b8088170000000",
//					   @"47b8088730000000",
//					   @"47b8087d90000000",
//					   @"47b8088130000000",
//					   @"47b8087e50000000",
//					   @"47b80886f0000000",
//					   @"47b80880f0000000",
//					   @"47b8088090000000",
//					   @"47b8087e30000000",
//					   @"47b8088690000000",
//					   @"47b8088790000000",
//					   @"47b8088150000000",
//					   @"47b8088750000000",
//					   @"47b8087df0000000",
//					   @"47b8088110000000",
//					   @"47b8088710000000",
//					   @"47b8087db0000000",
//					   @"47b80880d0000000",
//					   @"47b8087e70000000",
//					   @"47b80886d0000000",
//					   @"47b807d1d0000000",
//					   @"47b807ce90000000",
//					   @"47b807cd90000000",
//					   @"47b807d210000000",
//					   @"47b807ce50000000",
//					   @"47b807cc50000000",
//					   @"47b807ce10000000",
//					   @"47b807cf10000000",
//					   @"47b807cc10000000",
//					   @"47b807cd10000000",
//					   @"47b807ced0000000",
//					   @"47b807cfd0000000",
//					   @"47b807cdd0000000",
//					   @"47b807ceb0000000",
//					   @"47b807cfb0000000",
//					   @"47b807cdb0000000",
//					   @"47b807d1f0000000",
//					   @"47b807ce70000000",
//					   @"47b807cc70000000",
//					   @"47b807cd70000000",
//					   @"47b807ce30000000",
//					   @"47b807cf30000000",
//					   @"47b807cc30000000",
//					   @"47b807cef0000000",
//					   @"47b807ccf0000000",
//					   @"47b807cdf0000000",
//					   @"47b807f7f0000000",
//					   @"47b807f830000000",
//					   @"47c7f80790000000",
//					   @"47b807f9f0000000",
//					   @"47b807f8f0000000",
//					   @"47b807f770000000",
//					   @"47b807f9b0000000",
//					   @"47c7f80710000000",
//					   @"47c7f80810000000",
//					   @"47b807f7b0000000",
//					   @"47b807f970000000",
//					   @"47b807f870000000",
//					   @"47c7f807d0000000",
//					   @"47b807f910000000",
//					   @"47b807f810000000",
//					   @"47c7f807b0000000",
//					   @"47c7f80870000000",
//					   @"47b807f7d0000000",
//					   @"47b807f9d0000000",
//					   @"47c7f80770000000",
//					   @"47b807f990000000",
//					   @"47b807f890000000",
//					   @"47b807f750000000",
//					   @"47b807f850000000",
//					   @"47c7f807f0000000",
//					   @"47c7f80830000000",
//					   @"47b807f790000000",
//					   @"47b807e570000000",
//					   @"47b807fb30000000",
//					   @"47b807fa30000000",
//					   @"47b807e4b0000000",
//					   @"47b807fbf0000000",
//					   @"47b807faf0000000",
//					   @"47b807e4f0000000",
//					   @"47b807f070000000",
//					   @"47b807fbb0000000",
//					   @"47b807fab0000000",
//					   @"47b807e530000000",
//					   @"47b807fb70000000",
//					   @"47b807fa70000000",
//					   @"47b807fb10000000",
//					   @"47b807fa10000000",
//					   @"47b807e550000000",
//					   @"47b807f010000000",
//					   @"47b807fbd0000000",
//					   @"47b807fad0000000",
//					   @"47b807e490000000",
//					   @"47b807fb90000000",
//					   @"47b807fa90000000",
//					   @"47b807e4d0000000",
//					   @"47b807fb50000000",
//					   @"47b807fa50000000",
//					   @"47b807e510000000",
//					   @"47c7f80390000000",
//					   @"47c7f80590000000",
//					   @"47c7f80490000000",
//					   @"47c7f80690000000",
//					   @"47c7f80150000000",
//					   @"47c7f80450000000",
//					   @"47c7f80650000000",
//					   @"47c7f80510000000",
//					   @"47c7f80410000000",
//					   @"47c7f80610000000",
//					   @"47c7f805d0000000",
//					   @"47c7f804d0000000",
//					   @"47c7f806d0000000",
//					   @"47c7f805b0000000",
//					   @"47c7f806b0000000",
//					   @"47c7f80570000000",
//					   @"47c7f80470000000",
//					   @"47c7f80670000000",
//					   @"47c7f80530000000",
//					   @"47c7f80430000000",
//					   @"47c7f80630000000",
//					   @"47c7f805f0000000",
//					   @"47c7f804f0000000",
//					   @"47c7f806f0000000",
//					   @"47c7f803f0000000",
//					   @"47c7f87af0000000",
//					   @"47c7f879f0000000",
//					   @"47c7f87730000000",
//					   @"47c7f87a30000000",
//					   @"47c7f870f0000000",
//					   @"47c7f87a70000000",
//					   @"47c7f870b0000000",
//					   @"47c7f87970000000",
//					   @"47c7f87ab0000000",
//					   @"47c7f87bb0000000",
//					   @"47c7f87070000000",
//					   @"47c7f879b0000000",
//					   @"47c7f87770000000",
//					   @"47c7f87ad0000000",
//					   @"47c7f87bd0000000",
//					   @"47c7f87010000000",
//					   @"47c7f879d0000000",
//					   @"47c7f87a10000000",
//					   @"47c7f87b10000000",
//					   @"47c7f870d0000000",
//					   @"47c7f87910000000",
//					   @"47c7f87a50000000",
//					   @"47c7f87090000000",
//					   @"47c7f87750000000",
//					   @"47c7f87a90000000",
//					   @"47c7f87050000000",
//					   @"47c7f87990000000",
//					   @"47b8078c90000000",
//					   @"47b8078a90000000",
//					   @"47b8078b90000000",
//					   @"47b807f530000000",
//					   @"47b8078c50000000",
//					   @"47b8078a50000000",
//					   @"47b8078b50000000",
//					   @"47b807f330000000",
//					   @"47b8078c10000000",
//					   @"47b8078b10000000",
//					   @"47b807f4b0000000",
//					   @"47b8078cd0000000",
//					   @"47b8078ad0000000",
//					   @"47b8078bd0000000",
//					   @"47b8078ab0000000",
//					   @"47b8078bb0000000",
//					   @"47b807f4d0000000",
//					   @"47b8078cb0000000",
//					   @"47b8078a70000000",
//					   @"47b8078b70000000",
//					   @"47b8078c70000000",
//					   @"47b8078a30000000",
//					   @"47b8078b30000000",
//					   @"47b807f350000000",
//					   @"47b8078af0000000",
//					   @"47b8078bf0000000",
//					   @"47b8078cf0000000",

					   nil
					   
	];
	
	return [cellsSet allObjects];
	
}

#pragma mark - API

- (void)getInventoryWithCompletionHandler:(void (^)(void))handler {

	//[[Inventory sharedInstance] clearInventory];
	[self sendRequest:@"playerUndecorated/getInventory" params:@{@"lastQueryTimestamp": @0} completionHandler:^(id responseObj) {
		//NSLog(@"getInventory responseObj: %@", responseObj);
		dispatch_async(dispatch_get_main_queue(), ^{
			handler();
        });
	}];
	
}

- (void)getObjectsWithCompletionHandler:(void (^)(void))handler {

	[[DB sharedInstance] removeAllEnergyGlobs];

	NSArray *cellsAsHex = [self cellsAsHex];

	NSMutableArray *dates = [NSMutableArray arrayWithCapacity:cellsAsHex.count];
	for (int i = 0; i < cellsAsHex.count; i++) {
		[dates addObject:@0];
	}

	NSDictionary *dict = @{
	  @"playerLocation": [self currentE6Location],
	  @"knobSyncTimestamp": @(0),
	  //@"energyGlobGuids": @[],
	  @"cellsAsHex": cellsAsHex,
	  @"dates": dates
	};

	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"https://m-dot-betaspike.appspot.com/rpc/gameplay/getObjectsInCells"]];

	NSDictionary *headers = @{
		 @"Content-Type" : @"application/json;charset=UTF-8",
		 @"Accept-Encoding" : @"gzip",
		 @"User-Agent" : @"Nemesis (gzip)",
		 @"X-XsrfToken" : ((self.xsrfToken) ? (self.xsrfToken) : @""),
		 @"Host" : @"m-dot-betaspike.appspot.com",
		 @"Connection" : @"Keep-Alive",
		 @"Cookie" : [NSString stringWithFormat:@"SACSID=%@", ((self.SACSID) ? (self.SACSID) : @"")],
	};

	[request setAllHTTPHeaderFields:headers];
	[request setHTTPMethod:@"POST"];
	[request setHTTPBody:[NSJSONSerialization dataWithJSONObject:@{@"params": dict} options:0 error:nil]];

	[NSURLConnection sendAsynchronousRequest:request queue:self.networkQueue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {

		if (error) { NSLog(@"NSURLConnection error: %@", error); }

		NSError *jsonParseError;
		id responseObj;
		if (data) {
			responseObj = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonParseError];
		}
		if (jsonParseError) {
			NSLog(@"jsonParseError: %@", jsonParseError);
			NSLog(@"text response: %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
		}

		if (responseObj[@"gameBasket"][@"energyGlobGuids"]) {
			dispatch_async(dispatch_get_main_queue(), ^{
				[self processEnergyGlobGuids:responseObj[@"gameBasket"][@"energyGlobGuids"]];
			});
		}

		handler();
		
	}];

	return;

//	NSString *qk = @"0120212211103";
//	
//	CGPoint nePoint = CGPointMake(mapView.bounds.origin.x + mapView.bounds.size.width, mapView.bounds.origin.y);
//	CGPoint swPoint = CGPointMake((mapView.bounds.origin.x), (mapView.bounds.origin.y + mapView.bounds.size.height));
//	
//	CLLocationCoordinate2D neCoord = [mapView convertPoint:nePoint toCoordinateFromView:mapView];
//	CLLocationCoordinate2D swCoord = [mapView convertPoint:swPoint toCoordinateFromView:mapView];
//	
//	//NSLog(@"NE Lat: %lld Long: %lld", neLat, neLong);
//	//NSLog(@"SW Lat: %lld Long: %lld", swLat, swLong);
//	
//	NSDictionary *dict = @{
//	@"minLevelOfDetail": @(-1),
//	@"boundsParamsList": @[
//	@{
//	@"id": qk,
//	@"qk": qk,
//	@"minLatE6": @(neCoord.latitude*1E6),
//	@"minLngE6": @(neCoord.longitude*1E6),
//	@"maxLatE6": @(swCoord.latitude*1E6),
//	@"maxLngE6": @(swCoord.longitude*1E6)
//	}
//	]
//	};
//	
//	[NSURLConnection sendAsynchronousRequest:[self requestWithMethod:@"dashboard.getThinnedEntitiesV2" customDictionary:dict] queue:_queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
//		
//		NSMutableArray *toRemove = [mapView.annotations mutableCopy];
//		[toRemove removeObjectIdenticalTo:mapView.userLocation];
//		[mapView removeAnnotations:toRemove];
//		
//		id responseObj = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
//		//NSLog(@"objects response: %@", responseObj);
//		
//		NSArray *gameEntities = responseObj[@"result"][@"map"][qk][@"gameEntities"];
//		for (NSArray *gameEntity in gameEntities) {
//			NSDictionary *loc = gameEntity[2][@"locationE6"];
//			if (loc) {
//				
//				CLLocationDegrees lat = [loc[@"latE6"] longLongValue]/1E6;
//				CLLocationDegrees lng = [loc[@"lngE6"] longLongValue]/1E6;
//				
//				MKPointAnnotation *portal = [MKPointAnnotation alloc];
//				[portal setCoordinate:CLLocationCoordinate2DMake(lat, lng)];
//				[portal setTitle:[NSString stringWithFormat:@"%@", gameEntity[1]]];
//				[mapView addAnnotation:portal];
//				
//			}
//		}
//
//	}];
	
//	[[DB sharedInstance] removeAllPortals];
//	[[DB sharedInstance] removeAllEnergyGlobs];
//	
//	NSArray *cellsAsHex = [self cellsAsHex];
//
//	NSMutableArray *dates = [NSMutableArray arrayWithCapacity:cellsAsHex.count];
//	for (int i = 0; i < cellsAsHex.count; i++) {
//		[dates addObject:@0];
//	}
//	
//	NSDictionary *dict = @{
//		@"playerLocation": [self currentE6Location],
//		@"knobSyncTimestamp": @(0),
//		//@"energyGlobGuids": @[],
//		@"cellsAsHex": cellsAsHex,
//		@"dates": dates
//	};
//	
//	//NSLog(@"dict energyGlobGuids count: %d", [dict[@"energyGlobGuids"] count]);
//	
////	NSDictionary *dict = @{
////	@"playerLocation": @"0304b588,00d2f0b1",
////	@"knobSyncTimestamp": @(0), //(int)([[NSDate date] timeIntervalSince1970])
////	@"energyGlobGuids": @[],
////	@"cellsAsHex": @[
////	@"AEEE89D32301",
////	],
////	@"dates": @[@0]
////	};
//
//	[self sendRequest:@"gameplay/getObjectsInCells" params:dict completionHandler:^(id responseObj) {
//
//		//NSLog(@"getObjectsInCells responseObj: %@", responseObj);
//
//		dispatch_async(dispatch_get_main_queue(), ^{
//			handler();
//		});
//		
//	}];

}

- (void)loadCommunicationForFactionOnly:(BOOL)factionOnly completionHandler:(void (^)(NSArray *messages))handler {
	
	//NSLog(@"loadCommunicationWithCompletionHandler");

	//NSArray *cellsAsHex = [self cellsAsHex];
	
	NSDictionary *dict = @{
	//@"cellsAsHex": cellsAsHex,
	@"cellsAsHex": @[

		 // Teplice
//		@"4709900000000000",
//		@"4709ec0000000000",
//		@"4709f40000000000",
//		@"470a1f0000000000",
//		@"470a210000000000",
//		@"470a270000000000",
//		@"470a290000000000",
//		@"470a2a4000000000",

		 // Almelo, Netherlands
		@"47b7f8c000000000",
		@"47b7ff0000000000",
		@"47b8100000000000",
		@"47c7f00000000000",
		@"47c8040000000000",
  
	],
	@"minTimestampMs": @(-1),
	@"maxTimestampMs":@(-1),
	@"desiredNumItems": @50,
	@"factionOnly": @(factionOnly),
	@"ascendingTimestampOrder": @NO
	};
	
	[self sendRequest:@"playerUndecorated/getPaginatedPlexts" params:dict completionHandler:^(id responseObj) {
		
		//NSLog(@"comm responseObj: %@", responseObj);
		
		NSMutableArray *messages = [NSMutableArray array];
		NSArray *tmpMessages = responseObj[@"result"];
		
		for (NSArray *message in tmpMessages) {
			
			NSTimeInterval timestamp = [message[1] doubleValue]/1000.;
			NSDate *date = [NSDate dateWithTimeIntervalSince1970:timestamp];
			
			NSString *str = message[2][@"plext"][@"text"];
			NSMutableAttributedString *atrstr = [[NSMutableAttributedString alloc] initWithString:str];
			//NSLog(@"msg: %@", str);
			
			NSArray *markups = message[2][@"plext"][@"markup"];
			BOOL isMessage = NO;
			for (NSArray *markup in markups) {
				//NSLog(@"%@: %@", markup[0], markup[1][@"plain"]);
				
				NSRange range = [str rangeOfString:markup[1][@"plain"] options:0 range:NSMakeRange(0, str.length)];
				
				if ([markup[0] isEqualToString:@"PLAYER"] || [markup[0] isEqualToString:@"SENDER"]) {
					
					if ([markup[0] isEqualToString:@"SENDER"]) {
						isMessage = YES;
					}
					
					if ([markup[1][@"team"] isEqualToString:@"ALIENS"]) {
						[atrstr setAttributes:@{NSFontAttributeName: [UIFont fontWithName:@"Coda-Regular" size:16], NSForegroundColorAttributeName : [UIColor colorWithRed:40./255. green:244./255. blue:40./255. alpha:1]} range:range];
					} else {
						[atrstr setAttributes:@{NSFontAttributeName: [UIFont fontWithName:@"Coda-Regular" size:16], NSForegroundColorAttributeName : [UIColor colorWithRed:0 green:194./255. blue:1 alpha:1]} range:range];
					}
					
				} else if ([markup[0] isEqualToString:@"PORTAL"]) {
					[atrstr setAttributes:@{NSFontAttributeName: [UIFont fontWithName:@"Coda-Regular" size:16], NSForegroundColorAttributeName : [UIColor colorWithRed:0 green:135./255. blue:128./255. alpha:1]} range:range];
					
				} else if ([markup[0] isEqualToString:@"SECURE"]) {
					[atrstr setAttributes:@{NSFontAttributeName: [UIFont fontWithName:@"Coda-Regular" size:16], NSForegroundColorAttributeName : [UIColor colorWithRed:245./255. green:95./255. blue:85./255. alpha:1]} range:range];
				} else {
					
					if (isMessage) {
						[atrstr setAttributes:@{NSFontAttributeName: [UIFont fontWithName:@"Coda-Regular" size:16], NSForegroundColorAttributeName : [UIColor colorWithRed:207./255. green:229./255. blue:229./255. alpha:1]} range:range];
					} else {
						[atrstr setAttributes:@{NSFontAttributeName: [UIFont fontWithName:@"Coda-Regular" size:16], NSForegroundColorAttributeName : [UIColor colorWithRed:0 green:186./255. blue:181./255. alpha:1]} range:range];
					}
					
				}
			}

			[messages addObject:@{@"date": date, @"message": atrstr}];
			
		}
		
		dispatch_async(dispatch_get_main_queue(), ^{
			handler(messages);
        });
		
	}];
	
}

- (void)sendMessage:(NSString *)message factionOnly:(BOOL)factionOnly completionHandler:(void (^)(void))handler {
	
	//NSLog(@"loc: {%f, %f}", loc.latitude, loc.longitude);
	//CLLocationCoordinate2D loc = CLLocationCoordinate2DMake(50.639722, 13.829444);
	
	NSDictionary *dict = @{
	@"factionOnly": @(factionOnly),
	@"message": message,
	@"playerLocation": [self currentE6Location],
	};
	
	[self sendRequest:@"player/say" params:dict completionHandler:^(id responseObj) {
		
		//NSLog(@"sendMessage responseObj: %@", responseObj);
		
	}];
	
}

- (void)loadScoreWithCompletionHandler:(void (^)(int alienScore, int resistanceScore))handler {
	
	[self sendRequest:@"playerUndecorated/getGameScore" params:nil completionHandler:^(id responseObj) {
		
		//NSLog(@"getGameScore responseObj: %@", responseObj);
		
		int alienScore = [responseObj[@"result"][@"alienScore"] intValue];
		int resistanceScore = [responseObj[@"result"][@"resistanceScore"] intValue];
		
		dispatch_async(dispatch_get_main_queue(), ^{
			handler(alienScore, resistanceScore);
		});
		
	}];
	
}

- (void)redeemReward:(NSString *)passcode completionHandler:(void (^)(BOOL accepted, NSString *response))handler {
	
	[self sendRequest:@"playerUndecorated/redeemReward" params:@[passcode] completionHandler:^(id responseObj) {
		
		//NSLog(@"redeemReward responseObj: %@", responseObj);

		if (responseObj[@"error"]) {
			if ([responseObj[@"error"] isEqualToString:@"INVALID_PASSCODE"]) {
				dispatch_async(dispatch_get_main_queue(), ^{ handler(NO, @"Invalid passcode"); });
			} else if ([responseObj[@"error"] isEqualToString:@"ALREADY_REDEEMED"]) {
				dispatch_async(dispatch_get_main_queue(), ^{ handler(NO, @"Already redeemed"); });
			} else if ([responseObj[@"error"] isEqualToString:@"ALREADY_REDEEMED_BY_PLAYER"]) {
				dispatch_async(dispatch_get_main_queue(), ^{ handler(NO, @"Already redeemed by you"); });
			} else {
				dispatch_async(dispatch_get_main_queue(), ^{ handler(NO, @"Unknown error"); });
			}
		} else if (responseObj[@"result"]) {
			dispatch_async(dispatch_get_main_queue(), ^{ handler(YES, @"Passcode accepted"); });
		} else {
			dispatch_async(dispatch_get_main_queue(), ^{ handler(NO, @"Unknown error"); });
		}
		
	}];
	
}

- (void)loadNumberOfInvitesWithCompletionHandler:(void (^)(int numberOfInvites))handler {

	[self sendRequest:@"playerUndecorated/getInviteInfo" params:nil completionHandler:^(id responseObj) {
		
		//NSLog(@"getInviteInfo responseObj: %@", responseObj);

		dispatch_async(dispatch_get_main_queue(), ^{
			handler([responseObj[@"result"][@"numAvailableInvites"] intValue]);
		});

	}];
	
}

- (void)inviteUserWithEmail:(NSString *)email completionHandler:(void (^)(NSString *errorStr, int numberOfInvites))handler {
	
	NSDictionary *dict = @{
		@"customMessage": @"",
		@"inviteeEmailAddress": email
	};
	
	[self sendRequest:@"playerUndecorated/inviteViaEmail" params:dict completionHandler:^(id responseObj) {
		
		//NSLog(@"inviteViaEmail responseObj: %@", responseObj);
		
		dispatch_async(dispatch_get_main_queue(), ^{
			handler(responseObj[@"error"], [responseObj[@"result"][@"numAvailableInvites"] intValue]);
		});
		
	}];

}

- (void)fireXMP:(XMP *)xmpItem completionHandler:(void (^)(NSString *errorStr, NSDictionary *damages))handler {
	
	//NSLog(@"loc: {%f, %f}", loc.latitude, loc.longitude);
	//loc = CLLocationCoordinate2DMake(50.639722, 13.829444);
	
	NSDictionary *dict = @{
	@"knobSyncTimestamp": @(0),
	@"itemGuid": xmpItem.guid,
	@"playerLocation": [self currentE6Location],
	};
	
	[self sendRequest:@"gameplay/fireUntargetedRadialWeapon" params:dict completionHandler:^(id responseObj) {
		
		//NSLog(@"fireUntargetedRadialWeapon: %@", responseObj);
		
		if (responseObj[@"error"]) {
			if ([responseObj[@"error"] isEqualToString:@"PLAYER_DEPLETED"]) {
				dispatch_async(dispatch_get_main_queue(), ^{ handler(@"You don't have enough XM", nil); });
			} else if ([responseObj[@"error"] isEqualToString:@"WEAPON_DOES_NOT_EXIST"]) {
				dispatch_async(dispatch_get_main_queue(), ^{ handler(@"Weapon does not exist", nil); });
			} else {
				dispatch_async(dispatch_get_main_queue(), ^{ handler(@"Unknown error", nil); });
			}
		} else {
			
			NSMutableDictionary *tmpDamages = [NSMutableDictionary dictionary];
			
			for (NSDictionary *damage in responseObj[@"result"][@"damages"]) {
				NSMutableArray *tmpDamageArray = tmpDamages[damage[@"targetGuid"]];
				if (!tmpDamageArray) {
					tmpDamages[damage[@"targetGuid"]] = [NSMutableArray array];
				}
				[tmpDamageArray addObject:damage];
			}
			
			//NSLog(@"damages: %@", tmpDamages);
			
			dispatch_async(dispatch_get_main_queue(), ^{
				handler(nil, tmpDamages);
			});
			
		}

	}];
	
}

- (void)validateNickname:(NSString *)nickname completionHandler:(void (^)(NSString *errorStr))handler {
	
	[self sendRequest:@"playerUndecorated/validateNickname" params:@[nickname] completionHandler:^(id responseObj) {
		
		//NSLog(@"validateNickname: %@", responseObj);
		
		dispatch_async(dispatch_get_main_queue(), ^{
			handler(responseObj[@"error"]); //INVALID_CHARACTERS, TOO_SHORT, BAD_WORDS, NOT_UNIQUE
		});
		
	}];
	
}

- (void)persistNickname:(NSString *)nickname completionHandler:(void (^)(NSString *errorStr))handler {
	
	[self sendRequest:@"playerUndecorated/persistNickname" params:@[nickname] completionHandler:^(id responseObj) {
		
		//NSLog(@"persistNickname: %@", responseObj);
		
		dispatch_async(dispatch_get_main_queue(), ^{
			handler(responseObj[@"error"]);
		});
		
	}];
	
}

- (void)chooseFaction:(NSString *)faction completionHandler:(void (^)(void))handler {

	[self sendRequest:@"playerUndecorated/chooseFaction" params:@[faction] completionHandler:^(id responseObj) {
		
		NSLog(@"chooseFaction: %@", responseObj);
		
		dispatch_async(dispatch_get_main_queue(), ^{
			handler();
		});
		
	}];
	
}

- (void)getNicknameFromUserGUID:(NSString *)GUID completionHandler:(void (^)(NSString *nickname))handler {
	
	[self sendRequest:@"playerUndecorated/getNickNamesFromPlayerIds" params:@[@[GUID]] completionHandler:^(id responseObj) {
		
		dispatch_async(dispatch_get_main_queue(), ^{
			if (responseObj[@"result"][0]) {
				handler(responseObj[@"result"][0]);
			} else {
				handler(@"Unknown Player");
			}
		});
		
	}];
	
}

- (void)hackPortal:(Portal *)portal completionHandler:(void (^)(NSString *errorStr, NSArray *acquiredItems, int secondsRemaining))handler {
	
	NSDictionary *dict = @{
	@"itemGuid": portal.guid,
	@"playerLocation": [self currentE6Location],
	@"knobSyncTimestamp": @(0),
	//@"energyGlobGuids": @[]
	};
	
	[self sendRequest:@"gameplay/collectItemsFromPortal" params:dict completionHandler:^(id responseObj) {
		
		//NSLog(@"hackPortal responseObj: %@", responseObj);
		
		if ([responseObj[@"error"] isEqualToString:@"TOO_SOON_BIG"]) {
			
			dispatch_async(dispatch_get_main_queue(), ^{
				handler(@"Portal running hot! Unsafe to acquire items. Estimated time to cooldown: 300 seconds", nil, 300);
			});
			
		} else if ([responseObj[@"error"] hasPrefix:@"TOO_SOON_"]) {
			
			NSCharacterSet *charSet = [NSCharacterSet decimalDigitCharacterSet];
			NSScanner *scanner = [NSScanner scannerWithString:responseObj[@"error"]];
			[scanner scanUpToCharactersFromSet:charSet intoString:nil];
			int seconds;
			[scanner scanInt:&seconds];
			
			//[responseObj[@"error"] substringWithRange:NSMakeRange(9, 3)]

			dispatch_async(dispatch_get_main_queue(), ^{
				handler([NSString stringWithFormat:@"Portal running hot! Unsafe to acquire items. Estimated time to cooldown: %d seconds", seconds], nil, seconds);
			});
			
		} else if ([responseObj[@"error"] isEqualToString:@"TOO_OFTEN"]) {
			
			dispatch_async(dispatch_get_main_queue(), ^{
				handler(@"Portal burned out! It may take significant time for the Portal to reset", nil, 0);
			});
			
		} else if ([responseObj[@"error"] isEqualToString:@"OUT_OF_RANGE"]) {
			
			dispatch_async(dispatch_get_main_queue(), ^{
				handler(@"Portal is out of range", nil, 0);
			});
			
		} else if ([responseObj[@"error"] isEqualToString:@"NEED_MORE_ENERGY"]) {
			
			dispatch_async(dispatch_get_main_queue(), ^{
				handler(@"You don't have enough XM", nil, 0);
			});
			
		} else {
			
			dispatch_async(dispatch_get_main_queue(), ^{
				handler(nil, responseObj[@"result"][@"addedGuids"], 0);
			});
			
		}
		
	}];
	
}

- (void)deployResonator:(Resonator *)resonatorItem toPortal:(Portal *)portal toSlot:(int)slot completionHandler:(void (^)(NSString *errorStr))handler {

	NSDictionary *dict = @{
	@"knobSyncTimestamp": @(0),
	@"itemGuids": @[resonatorItem.guid],
	@"location": [self currentE6Location],
	@"portalGuid": portal.guid,
	@"preferredSlot": @(slot)
	};
	
	[self sendRequest:@"gameplay/deployResonatorV2" params:dict completionHandler:^(id responseObj) {
		
		//NSLog(@"deployResonator responseObj: %@", responseObj);

		if ([responseObj[@"error"] isEqualToString:@"PORTAL_OUT_OF_RANGE"]) {
			
			dispatch_async(dispatch_get_main_queue(), ^{
				handler(@"Portal out of range");
			});
			
		} else if ([responseObj[@"error"] isEqualToString:@"TOO_MANY_RESONATORS_FOR_LEVEL_BY_USER"]) {
			
			dispatch_async(dispatch_get_main_queue(), ^{
				handler(@"Too many resonators with same level by you");
			});
			
		} else if ([responseObj[@"error"] isEqualToString:@"PORTAL_AT_MAX_RESONATORS"]) {
			
			dispatch_async(dispatch_get_main_queue(), ^{
				handler(@"Portal has all resonators");
			});
			
		} else {
			
			dispatch_async(dispatch_get_main_queue(), ^{
				handler(nil);
			});
			
		}

	}];
	
}

- (void)upgradeResonator:(Resonator *)resonatorItem toPortal:(Portal *)portal toSlot:(int)slot completionHandler:(void (^)(NSString *errorStr))handler {
	
	//{"params":{"energyGlobGuids":[],"itemGuids":["365e07c2f4bd4ca3ba11f13355b3cfc9.5"],"knobSyncTimestamp":1358000897501,"location":"0304bb25,00d2f8f0","portalGuid":"3e7788cf535745a29461dffcad2c8711.12","preferredSlot":255}}
	
	NSDictionary *dict = @{
	@"knobSyncTimestamp": @(0),
	//@"energyGlobGuids": @[],
	@"emitterGuid": resonatorItem.guid,
	@"location": [self currentE6Location],
	@"portalGuid": portal.guid,
	@"resonatorSlotToUpgrade": @(slot)
	};
	
	[self sendRequest:@"gameplay/upgradeResonatorV2" params:dict completionHandler:^(id responseObj) {
		
		if ([responseObj[@"error"] isEqualToString:@"PORTAL_OUT_OF_RANGE"]) {
			
			dispatch_async(dispatch_get_main_queue(), ^{
				handler(@"Portal out of range");
			});
			
		} else if ([responseObj[@"error"] isEqualToString:@"CAN_ONLY_UPGRADE_TO_HIGHER_LEVEL"]) {
			
			dispatch_async(dispatch_get_main_queue(), ^{
				handler(@"You can upgrade only to higher level");
			});
			
		} else if ([responseObj[@"error"] isEqualToString:@"TOO_MANY_RESONATORS_FOR_LEVEL_BY_USER"]) {
			
			dispatch_async(dispatch_get_main_queue(), ^{
				handler(@"Too many resonators with same level by you");
			});

		} else {
			
			//NSLog(@"upgradeResonator responseObj: %@", responseObj);
			
			dispatch_async(dispatch_get_main_queue(), ^{
				handler(nil);
			});
			
		}
		
	}];
	
}

- (void)addMod:(Item *)modItem toItem:(Item *)modableItem toSlot:(int)slot completionHandler:(void (^)(NSString *errorStr))handler {
	
	//{"params":{"energyGlobGuids":[],"playerLocation":"0304b436,00d305c9","knobSyncTimestamp":1358097541497,"modResourceGuid":"ef2b59f137654d73b43ecc73c373836c.5","modableGuid":"ca2b7f744e244b70bf0c8d7b65d446cc.11","index":0}}
	
	NSDictionary *dict = @{
	  @"knobSyncTimestamp": @(0),
	  //@"energyGlobGuids": @[],
	  @"playerLocation": [self currentE6Location],
	  @"modResourceGuid": modItem.guid,
	  @"modableGuid": modableItem.guid,
	  @"index": @(slot)
	};
	
	[self sendRequest:@"gameplay/addMod" params:dict completionHandler:^(id responseObj) {
		
		if ([responseObj[@"error"] isEqualToString:@"PORTAL_OUT_OF_RANGE"]) {
			
			dispatch_async(dispatch_get_main_queue(), ^{
				handler(@"Portal out of range");
			});
			
		} else {
			
			//NSLog(@"addMod responseObj: %@", responseObj);
			
			dispatch_async(dispatch_get_main_queue(), ^{
				handler(nil);
			});
			
		}
		
	}];
	
}

- (void)dropItemWithGuid:(NSString *)guid completionHandler:(void (^)(void))handler {
	NSLog(@"dropItemWithGuid: %@", guid);
	
	NSDictionary *dict = @{
	@"knobSyncTimestamp": @(0),
	@"playerLocation": [self currentE6Location],
	@"itemGuid": guid
	};
	
	[self sendRequest:@"gameplay/dropItem" params:dict completionHandler:^(id responseObj) {
		
		//NSLog(@"dropItemWithGuid responseObj: %@", responseObj);
		
		dispatch_async(dispatch_get_main_queue(), ^{
			handler();
		});
		
	}];
	
}

- (void)pickUpItemWithGuid:(NSString *)guid completionHandler:(void (^)(NSString *errorStr))handler {
	
	NSDictionary *dict = @{
	@"knobSyncTimestamp": @(0),
	@"playerLocation": [self currentE6Location],
	@"itemGuid": guid
	};
	
	[self sendRequest:@"gameplay/pickUp" params:dict completionHandler:^(id responseObj) {

		if ([responseObj[@"error"] isEqualToString:@"RESOURCE_NOT_AVAILABLE"]) {
			
			dispatch_async(dispatch_get_main_queue(), ^{
				handler(@"Item is no longer availabile");
			});
			
		} else {
			
			//NSLog(@"pickUpItemWithGuid responseObj: %@", responseObj);
			
			dispatch_async(dispatch_get_main_queue(), ^{
				handler(nil);
			});
			
		}
		
	}];
	
}

- (void)rechargePortal:(Portal *)portal completionHandler:(void (^)(void))handler {
	
	//{"params":{"energyGlobGuids":[],"knobSyncTimestamp":1358000897501,"location":"0304bb25,00d2f8f0","portalGuid":"3e7788cf535745a29461dffcad2c8711.12","portalKeyGuid":null,"resonatorSlots":[0,5,6,7]}}
	
	NSDictionary *dict = @{
	@"knobSyncTimestamp": @(0),
	@"location": [self currentE6Location],
	@"portalGuid": portal.guid,
	@"portalKeyGuid": [NSNull null],
	@"resonatorSlots": @[@0, @1, @2, @3, @4, @5, @6, @7]
	};
	
	[self sendRequest:@"gameplay/rechargeResonatorsV2" params:dict completionHandler:^(id responseObj) {
		
		//NSLog(@"rechargeResonatorWithGuid responseObj: %@", responseObj);
		
		dispatch_async(dispatch_get_main_queue(), ^{
			handler();
		});
		
	}];
	
}

- (void)cheatSetPlayerLevel {

	[self sendRequest:@"devCheat/cheatSetPlayerLevel" params:@[@5] completionHandler:^(id responseObj) {
		
		NSLog(@"cheatSetPlayerLevel responseObj: %@", responseObj);
		
	}];
	
}

#pragma mark - Send Request

- (void)sendRequest:(NSString *)requestName params:(id)params completionHandler:(void (^)(id responseObj))handler {
//	NSLog(@"sendRequest: %@", requestName);
	
	if ([params isKindOfClass:[NSDictionary class]]) {
		
		NSMutableDictionary *mutableParams = [params mutableCopy];
	
		NSMutableArray *collectedEnergyGuids = [NSMutableArray array];
		for (EnergyGlob *energyGlob in [[DB sharedInstance] getEnergyGlobs:[API sharedInstance].numberOfEnergyToCollect]) {
			[collectedEnergyGuids addObject:energyGlob.guid];
		}
		mutableParams[@"energyGlobGuids"] = collectedEnergyGuids;
		
		[API sharedInstance].numberOfEnergyToCollect = 0;
		
		//NSLog(@"collecting %d energy", collectedEnergyGuids.count);
		
		params = mutableParams;
		
	}

	/////////////////////////
	
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://m-dot-betaspike.appspot.com/rpc/%@", requestName]]];
	
	[request setHTTPMethod:@"POST"];
	
	NSDictionary *headers = @{
	@"Content-Type" : @"application/json;charset=UTF-8",
	@"Accept-Encoding" : @"gzip",
	@"User-Agent" : @"Nemesis (gzip)",
	@"X-XsrfToken" : ((self.xsrfToken) ? (self.xsrfToken) : @""),
	@"Host" : @"m-dot-betaspike.appspot.com",
	@"Connection" : @"Keep-Alive",
	@"Cookie" : [NSString stringWithFormat:@"SACSID=%@", ((self.SACSID) ? (self.SACSID) : @"")],
	};
	
	[request setAllHTTPHeaderFields:headers];
	
	NSError *error;
	id tmpParams;
	if (params) {
		tmpParams = params;
	} else {
		tmpParams = @[];
	}
	
	[request setHTTPBody:[NSJSONSerialization dataWithJSONObject:@{@"params": tmpParams} options:0 error:&error]];
	if (error) { NSLog(@"error: %@", error); }
	
	[NSURLConnection sendAsynchronousRequest:request queue:self.networkQueue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
		
		if (error) { NSLog(@"NSURLConnection error: %@", error); }
		
//		if ([requestName isEqualToString:@"rpc/playerUndecorated/getNickNamesFromPlayerIds"]) {
//			//NSLog(@"response: %@", response);
//			NSLog(@"text response: %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
//			return;
//		}

		NSError *jsonParseError;
		id responseObj;
		if (data) {
			responseObj = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonParseError];
		}
		if (jsonParseError) {
			NSLog(@"jsonParseError: %@", jsonParseError);
			NSLog(@"text response: %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
		}
		
		NSDictionary *gameBasket = responseObj[@"gameBasket"];
		if (gameBasket) {
			dispatch_async(dispatch_get_main_queue(), ^{
				[self processGameBasket:gameBasket];
			});
		}

		handler(responseObj);
		
	}];
	
}

#pragma mark - Process Game Basket

- (void)processGameBasket:(NSDictionary *)gameBasket {
	//NSLog(@"processGameBasket: %@", gameBasket);
	
	NSArray *inventory = gameBasket[@"inventory"];
	if (inventory) { [self processInventory:inventory]; }

	NSArray *gameEntities = gameBasket[@"gameEntities"];
	if (gameEntities) { [self processGameEntities:gameEntities]; }
	
	NSArray *playerEntity = gameBasket[@"playerEntity"];
	if (playerEntity) { [self processPlayerEntity:playerEntity]; }
	
	NSArray *energyGlobGuids = gameBasket[@"energyGlobGuids"];
	if (energyGlobGuids) { [self processEnergyGlobGuids:energyGlobGuids]; }
	
	NSArray *apGains = gameBasket[@"apGains"];
	if (apGains) { [self processAPGains:apGains]; }
	
	NSArray *playerDamages = gameBasket[@"playerDamages"];
	if (playerDamages) { [self processPlayerDamages:playerDamages]; }
	
	NSArray *deletedEntityGuids = gameBasket[@"deletedEntityGuids"];
	if (deletedEntityGuids) { [self processDeletedEntityGuids:deletedEntityGuids]; }

}

- (void)processInventory:(NSArray *)inventory {
	//NSLog(@"processInventory");
	
	for (NSArray *item in inventory) {
		
		NSString *resourceType;
		
		if (item[2][@"resourceWithLevels"][@"resourceType"]) {
			resourceType = item[2][@"resourceWithLevels"][@"resourceType"];
		}
		
		if (item[2][@"resource"][@"resourceType"]) {
			resourceType = item[2][@"resource"][@"resourceType"];
		}
		
		if (item[2][@"modResource"][@"resourceType"]) {
			resourceType = item[2][@"modResource"][@"resourceType"];
		}
		
		//NSLog(@"resourceType: %@", resourceType);
		
		if ([resourceType isEqualToString:@"EMITTER_A"]) {
			Resonator *resonator = (Resonator *)[[DB sharedInstance] getOrCreateItemWithGuid:item[0] classStr:@"Resonator"];
			resonator.level = [item[2][@"resourceWithLevels"][@"level"] integerValue];
		} else if ([resourceType isEqualToString:@"EMP_BURSTER"]) {
			XMP *xmp = (XMP *)[[DB sharedInstance] getOrCreateItemWithGuid:item[0] classStr:@"XMP"];
			xmp.level = [item[2][@"resourceWithLevels"][@"level"] integerValue];
		} else if ([resourceType isEqualToString:@"RES_SHIELD"]) {
			Shield *shield = (Shield *)[[DB sharedInstance] getOrCreateItemWithGuid:item[0] classStr:@"Shield"];
			shield.rarity = [API shieldRarityFromString:item[2][@"modResource"][@"rarity"]];
		} else if ([resourceType isEqualToString:@"PORTAL_LINK_KEY"]) {
			Portal *portal = (Portal *)[[DB sharedInstance] getOrCreateItemWithGuid:item[2][@"portalCoupler"][@"portalGuid"] classStr:@"Portal"];
			portal.imageURL = item[2][@"portalCoupler"][@"portalImageUrl"];
			portal.name = item[2][@"portalCoupler"][@"portalTitle"];
			portal.address = item[2][@"portalCoupler"][@"portalAddress"];
			
			PortalKey *portalKey = (PortalKey *)[[DB sharedInstance] getOrCreateItemWithGuid:item[0] classStr:@"PortalKey"];
			portalKey.portal = portal;
		} else if ([resourceType isEqualToString:@"MEDIA"]) {
			Media *media = (Media *)[[DB sharedInstance] getOrCreateItemWithGuid:item[0] classStr:@"Media"];
			media.name = item[2][@"storyItem"][@"shortDescription"];
			media.url = item[2][@"storyItem"][@"primaryUrl"];
			media.level = [item[2][@"resourceWithLevels"][@"level"] integerValue];
			media.imageURL = item[2][@"imageByUrl"][@"imageUrl"];
		} else if ([resourceType isEqualToString:@"POWER_CUBE"]) {
			PowerCube *powerCube = (PowerCube *)[[DB sharedInstance] getOrCreateItemWithGuid:item[0] classStr:@"PowerCube"];
			powerCube.level = [item[2][@"resourceWithLevels"][@"level"] integerValue];
		} else {
			NSLog(@"Unknown Item");
			//Item *itemObj =
			[[DB sharedInstance] getOrCreateItemWithGuid:item[0] classStr:@"Item"];
		}

	}
	
	[[DB sharedInstance] saveContext];

	//[[NSNotificationCenter defaultCenter] postNotificationName:@"InventoryUpdatedNotification" object:nil];
	
}

- (void)processGameEntities:(NSArray *)gameEntities {
	//NSLog(@"processGameEntities: %@", gameEntities);
	
	for (NSArray *gameEntity in gameEntities) {
		NSDictionary *loc = gameEntity[2][@"locationE6"];
		if (loc && gameEntity[2][@"portalV2"]) {

			//Portal *portal = [[DB sharedInstance] portalWithGuid:gameEntity[0]];
			Portal *portal = (Portal *)[[DB sharedInstance] getOrCreateItemWithGuid:gameEntity[0] classStr:@"Portal"];
			portal.latitude = [loc[@"latE6"] intValue]/1E6;
			portal.longitude = [loc[@"lngE6"] intValue]/1E6;
			portal.controllingTeam = gameEntity[2][@"controllingTeam"][@"team"];
			portal.capturedBy = [[DB sharedInstance] userWithGuid:gameEntity[2][@"captured"][@"capturingPlayerId"] shouldCreate:YES];
			portal.imageURL = gameEntity[2][@"imageByUrl"][@"imageUrl"];
			portal.name = gameEntity[2][@"portalV2"][@"descriptiveText"][@"TITLE"];
			portal.address = gameEntity[2][@"portalV2"][@"descriptiveText"][@"ADDRESS"];
			portal.completeInfo = YES;
			
			for (int i = 0; i < 8; i++) {
				
				NSDictionary *resonatorDict = gameEntity[2][@"resonatorArray"][@"resonators"][i];

				if ([resonatorDict isKindOfClass:[NSNull class]]) {
					DeployedResonator *resonator = [[DB sharedInstance] deployedResonatorForPortal:portal atSlot:i shouldCreate:NO];
					if (resonator) {
						[[[DB sharedInstance] managedObjectContext] deleteObject:resonator];
					}
				} else {
					
					if ([resonatorDict[@"slot"] intValue] != i) {
						NSLog(@"%d != %d", [resonatorDict[@"slot"] intValue], i);
					}
					DeployedResonator *resonator = [[DB sharedInstance] deployedResonatorForPortal:portal atSlot:i shouldCreate:YES];
					resonator.energy = [resonatorDict[@"energyTotal"] intValue];
					resonator.owner = [[DB sharedInstance] userWithGuid:resonatorDict[@"ownerGuid"] shouldCreate:YES];
					resonator.distanceToPortal = [resonatorDict[@"distanceToPortal"] intValue];
					resonator.level = [resonatorDict[@"level"] intValue];
					[portal addResonatorsObject:resonator];
				}
				
			}
			
			//NSLog(@"Mods: %@", gameEntity[2][@"portalV2"][@"linkedModArray"]);
			
			for (int i = 0; i < 4; i++) {
				
				NSDictionary *modDict = gameEntity[2][@"portalV2"][@"linkedModArray"][i];
				
				if ([modDict isKindOfClass:[NSNull class]]) {
					DeployedMod *mod = [[DB sharedInstance] deployedModPortal:portal ofClass:nil atSlot:i shouldCreate:NO];
					if (mod) {
						[[[DB sharedInstance] managedObjectContext] deleteObject:mod];
					}
				} else {
					
					if ([modDict[@"type"] isEqualToString:@"RES_SHIELD"]) {
						
						DeployedShield *shield = (DeployedShield *)[[DB sharedInstance] deployedModPortal:portal ofClass:@"DeployedShield" atSlot:i shouldCreate:YES];
						shield.mitigation = [modDict[@"stats"][@"MITIGATION"] intValue];
						shield.rarity = [API shieldRarityFromString:modDict[@"rarity"]];
						shield.owner = [[DB sharedInstance] userWithGuid:modDict[@"installingUser"] shouldCreate:YES];
						[portal addModsObject:shield];
						
					} else {
						NSLog(@"Unknown Mod");
					}
					
				}
				
			}

			//portal.mods = gameEntity[2][@"portalV2"][@"linkedModArray"];
			
//			if (![portal.controllingTeam isEqualToString:@"NEUTRAL"] && portal.capturedByGUID) {
//				[self getNicknameFromUserGUID:portal.capturedByGUID completionHandler:^(NSString *nickname) {
//					portal.capturedByNickname = nickname;
//					//[[NSNotificationCenter defaultCenter] postNotificationName:@"PortalChanged" object:self userInfo:@{@"portal": portal}];
//				}];
//			}
			
//			NSMutableArray *resonators = [gameEntity[2][@"resonatorArray"][@"resonators"] mutableCopy];
//			portal.resonators = resonators;
//			
//			NSMutableArray *mods = [gameEntity[2][@"portalV2"][@"linkedModArray"] mutableCopy];
//			portal.mods = mods;
			
			//[[Portals sharedInstance] addPortal:portal];
			
			[[DB sharedInstance] saveContext];
			
		} else if (loc && gameEntity[2][@"resource"]) {
			
			NSString *resourceType;
			
			if (gameEntity[2][@"resourceWithLevels"][@"resourceType"]) {
				resourceType = gameEntity[2][@"resourceWithLevels"][@"resourceType"];
			}
			
			if (gameEntity[2][@"resource"][@"resourceType"]) {
				resourceType = gameEntity[2][@"resource"][@"resourceType"];
			}
			
			if (gameEntity[2][@"modResource"][@"resourceType"]) {
				resourceType = gameEntity[2][@"modResource"][@"resourceType"];
			}
			
			//NSLog(@"Dropped resourceType: %@", resourceType);
			
			if ([resourceType isEqualToString:@"EMITTER_A"]) {
				Resonator *resonator = (Resonator *)[[DB sharedInstance] getOrCreateItemWithGuid:gameEntity[0] classStr:@"Resonator"];
				resonator.dropped = YES;
				resonator.latitude = [loc[@"latE6"] intValue]/1E6;
				resonator.longitude = [loc[@"lngE6"] intValue]/1E6;
				resonator.level = [gameEntity[2][@"resourceWithLevels"][@"level"] integerValue];
				[[DB sharedInstance] saveContext];
			} else if ([resourceType isEqualToString:@"EMP_BURSTER"]) {
				XMP *xmp = (XMP *)[[DB sharedInstance] getOrCreateItemWithGuid:gameEntity[0] classStr:@"XMP"];
				xmp.dropped = YES;
				xmp.latitude = [loc[@"latE6"] intValue]/1E6;
				xmp.longitude = [loc[@"lngE6"] intValue]/1E6;
				xmp.level = [gameEntity[2][@"resourceWithLevels"][@"level"] integerValue];
				[[DB sharedInstance] saveContext];
			} else if ([resourceType isEqualToString:@"RES_SHIELD"]) {
				Shield *shield = (Shield *)[[DB sharedInstance] getOrCreateItemWithGuid:gameEntity[0] classStr:@"Shield"];
				shield.dropped = YES;
				shield.latitude = [loc[@"latE6"] intValue]/1E6;
				shield.longitude = [loc[@"lngE6"] intValue]/1E6;
				shield.rarity = [API shieldRarityFromString:gameEntity[2][@"modResource"][@"rarity"]];
				[[DB sharedInstance] saveContext];
			} else if ([resourceType isEqualToString:@"PORTAL_LINK_KEY"]) {
				Portal *portal = (Portal *)[[DB sharedInstance] getOrCreateItemWithGuid:gameEntity[2][@"portalCoupler"][@"portalGuid"] classStr:@"Portal"];
				portal.imageURL = gameEntity[2][@"portalCoupler"][@"portalImageUrl"];
				portal.name = gameEntity[2][@"portalCoupler"][@"portalTitle"];
				portal.address = gameEntity[2][@"portalCoupler"][@"portalAddress"];
				
				PortalKey *portalKey = (PortalKey *)[[DB sharedInstance] getOrCreateItemWithGuid:gameEntity[0] classStr:@"PortalKey"];
				portalKey.dropped = YES;
				portalKey.latitude = [loc[@"latE6"] intValue]/1E6;
				portalKey.longitude = [loc[@"lngE6"] intValue]/1E6;
				portalKey.portal = portal;
				[[DB sharedInstance] saveContext];
			} else if ([resourceType isEqualToString:@"MEDIA"]) {
				Media *media = (Media *)[[DB sharedInstance] getOrCreateItemWithGuid:gameEntity[0] classStr:@"Media"];
				media.dropped = YES;
				media.latitude = [loc[@"latE6"] intValue]/1E6;
				media.longitude = [loc[@"lngE6"] intValue]/1E6;
				media.name = gameEntity[2][@"storyItem"][@"shortDescription"];
				media.url = gameEntity[2][@"storyItem"][@"primaryUrl"];
				media.level = [gameEntity[2][@"resourceWithLevels"][@"level"] integerValue];
				media.imageURL = gameEntity[2][@"imageByUrl"][@"imageUrl"];
				[[DB sharedInstance] saveContext];
			} else {
				NSLog(@"Unknown Dropped Item");
				Item *itemObj = [[DB sharedInstance] getOrCreateItemWithGuid:gameEntity[0] classStr:@"Item"];
				itemObj.dropped = YES;
				itemObj.latitude = [loc[@"latE6"] intValue]/1E6;
				itemObj.longitude = [loc[@"lngE6"] intValue]/1E6;
				[[DB sharedInstance] saveContext];
			}
			
			//DroppedItem *droppedItem = [[DB sharedInstance] getOrCreateItemWithGuid:gameEntity[0] classStr:@"DroppedItem"];
			
		} else if (gameEntity[2][@"edge"]) {
			
			//NSLog(@"link: %@", gameEntity[0]);

			PortalLink *portalLink = (PortalLink *)[[DB sharedInstance] getOrCreateItemWithGuid:gameEntity[0] classStr:@"PortalLink"];
			portalLink.controllingTeam = gameEntity[2][@"controllingTeam"][@"team"];
			
			User *creator = [[DB sharedInstance] userWithGuid:gameEntity[2][@"creator"][@"creatorGuid"] shouldCreate:YES];
			portalLink.creator = creator;
			
			Portal *destinationPortal = (Portal *)[[DB sharedInstance] getOrCreateItemWithGuid:gameEntity[2][@"edge"][@"destinationPortalGuid"] classStr:@"Portal"];
			destinationPortal.controllingTeam = gameEntity[2][@"controllingTeam"][@"team"];
			destinationPortal.latitude = [gameEntity[2][@"edge"][@"destinationPortalLocation"][@"latE6"] intValue]/1E6;
			destinationPortal.longitude = [gameEntity[2][@"edge"][@"destinationPortalLocation"][@"lngE6"] intValue]/1E6;
			portalLink.destinationPortal = destinationPortal;
			
			Portal *originPortal = (Portal *)[[DB sharedInstance] getOrCreateItemWithGuid:gameEntity[2][@"edge"][@"originPortalGuid"] classStr:@"Portal"];
			originPortal.controllingTeam = gameEntity[2][@"controllingTeam"][@"team"];
			originPortal.latitude = [gameEntity[2][@"edge"][@"originPortalLocation"][@"latE6"] intValue]/1E6;
			originPortal.longitude = [gameEntity[2][@"edge"][@"originPortalLocation"][@"lngE6"] intValue]/1E6;
			portalLink.originPortal = originPortal;
			
		} else if (gameEntity[2][@"capturedRegion"]) {
			
			//NSLog(@"capturedRegion: %@", gameEntity[0]);
			
			ControlField *controlField = (ControlField *)[[DB sharedInstance] getOrCreateItemWithGuid:gameEntity[0] classStr:@"ControlField"];
			controlField.controllingTeam = gameEntity[2][@"controllingTeam"][@"team"];
			controlField.entityScore = [gameEntity[2][@"entityScore"][@"entityScore"] intValue];
			
			User *creator = [[DB sharedInstance] userWithGuid:gameEntity[2][@"creator"][@"creatorGuid"] shouldCreate:YES];
			controlField.creator = creator;
			
			Portal *portalA = (Portal *)[[DB sharedInstance] getOrCreateItemWithGuid:gameEntity[2][@"capturedRegion"][@"vertexA"][@"guid"] classStr:@"Portal"];
			portalA.controllingTeam = gameEntity[2][@"controllingTeam"][@"team"];
			portalA.latitude = [gameEntity[2][@"capturedRegion"][@"vertexA"][@"location"][@"latE6"] intValue]/1E6;
			portalA.longitude = [gameEntity[2][@"capturedRegion"][@"vertexA"][@"location"][@"lngE6"] intValue]/1E6;
			[controlField addPortalsObject:portalA];
			
			Portal *portalB = (Portal *)[[DB sharedInstance] getOrCreateItemWithGuid:gameEntity[2][@"capturedRegion"][@"vertexB"][@"guid"] classStr:@"Portal"];
			portalB.controllingTeam = gameEntity[2][@"controllingTeam"][@"team"];
			portalB.latitude = [gameEntity[2][@"capturedRegion"][@"vertexB"][@"location"][@"latE6"] intValue]/1E6;
			portalB.longitude = [gameEntity[2][@"capturedRegion"][@"vertexB"][@"location"][@"lngE6"] intValue]/1E6;
			[controlField addPortalsObject:portalB];
			
			Portal *portalC = (Portal *)[[DB sharedInstance] getOrCreateItemWithGuid:gameEntity[2][@"capturedRegion"][@"vertexC"][@"guid"] classStr:@"Portal"];
			portalC.controllingTeam = gameEntity[2][@"controllingTeam"][@"team"];
			portalC.latitude = [gameEntity[2][@"capturedRegion"][@"vertexC"][@"location"][@"latE6"] intValue]/1E6;
			portalC.longitude = [gameEntity[2][@"capturedRegion"][@"vertexC"][@"location"][@"lngE6"] intValue]/1E6;
			[controlField addPortalsObject:portalC];
			
		}
	}
	
}

- (void)processPlayerEntity:(NSArray *)playerEntity {
	//NSLog(@"processPlayerEntity");
	
	int oldLevel = [API levelForAp:[self.playerInfo[@"ap"] intValue]];
	int newLevel = [API levelForAp:[playerEntity[2][@"playerPersonal"][@"ap"] intValue]];
	
	if ([self.playerInfo[@"ap"] intValue] != 0 && newLevel > oldLevel) {
		[[SoundManager sharedManager] playSound:@"Sound/sfx_player_level_up.aif"];
	}
	
	self.playerInfo = @{
	@"nickname": self.playerInfo[@"nickname"],
	@"team": playerEntity[2][@"controllingTeam"][@"team"],
	@"ap": playerEntity[2][@"playerPersonal"][@"ap"],
	@"energy": playerEntity[2][@"playerPersonal"][@"energy"]
	};
	
	//[[NSNotificationCenter defaultCenter] postNotificationName:@"ProfileUpdatedNotification" object:nil];
	
}

- (void)processEnergyGlobGuids:(NSArray *)energyGlobGuids {
	//NSLog(@"processEnergyGlobGuids: %d", energyGlobGuids.count);
	for (NSString *energyGlobGuid in energyGlobGuids) {
		//[[DB sharedInstance] addEnergyGlobWithGuid:energyGlobGuid];
		[[DB sharedInstance] getOrCreateItemWithGuid:energyGlobGuid classStr:@"EnergyGlob"];
		[[DB sharedInstance] saveContext];
	}
}

- (void)processAPGains:(NSArray *)apGains {
	//NSLog(@"processAPGains");

	for (NSDictionary *apGain in apGains) {
		dispatch_async(dispatch_get_main_queue(), ^{
			[[MTStatusBarOverlay sharedInstance] postFinishMessage:[NSString stringWithFormat:@"+ %d AP", [apGain[@"apGainAmount"] intValue]] duration:3 animated:YES];
		});
	}
}

- (void)processPlayerDamages:(NSArray *)playerDamages {
	//NSLog(@"processPlayerDamages: %d", playerDamages.count);

	for (NSDictionary *playerDamage in playerDamages) {
		dispatch_async(dispatch_get_main_queue(), ^{

			[[SoundManager sharedManager] playSound:@"Sound/sfx_player_hit.aif"];
			
			//postMessage
			[[MTStatusBarOverlay sharedInstance] postErrorMessage:[NSString stringWithFormat:@"- %d XM", [playerDamage[@"damageAmount"] intValue]] duration:3 animated:YES];
		});
	}
}

- (void)processDeletedEntityGuids:(NSArray *)deletedEntityGuids {
	//NSLog(@"processDeletedEntityGuids: %d", deletedEntityGuids.count);
	
	for (NSString *deletedGuid in deletedEntityGuids) {
		[[DB sharedInstance] removeItemWithGuid:deletedGuid];
	}
}

@end

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

@implementation API {
	BOOL isSoundPlaying;
	NSMutableArray *soundsQueue;
}

@synthesize networkQueue = _networkQueue;
@synthesize notificationQueue = _notificationQueue;
@synthesize xsrfToken = _xsrfToken;
@synthesize SACSID = _SACSID;
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
		soundsQueue = [NSMutableArray array];
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

+ (NSDictionary *)sounds {
	return @{
		@"SFX_RINGTONE": @{@"file": @"sfx_ringtone.aif", @"duration": @(2561)},
		@"SFX_SONAR": @{@"file": @"sfx_sonar.aif", @"duration": @(2056)},
		@"SFX_TYPING": @{@"file": @"sfx_typing.aif", @"duration": @(1857)},
		@"SFX_UI_BACK": @{@"file": @"sfx_ui_back.aif", @"duration": @(92)},
		@"SFX_UI_FAIL": @{@"file": @"sfx_ui_fail.aif", @"duration": @(278)},
		@"SFX_UI_SUCCESS": @{@"file": @"sfx_ui_success.aif", @"duration": @(404)},
		@"SFX_XM_PICKUP": @{@"file": @"sfx_xm_pickup.aif", @"duration": @(696)},
		@"SFX_THROB": @{@"file": @"sfx_throbbing_wheels.aif", @"duration": @(3890)},
		@"SFX_ZOOM_1": @{@"file": @"sfx_zoom_1.aif", @"duration": @(4388)},
		@"SFX_ZOOM_2": @{@"file": @"sfx_zoom_2.aif", @"duration": @(3947)},
		@"SFX_ZOOM_3": @{@"file": @"sfx_zoom_3.aif", @"duration": @(4086)},
		@"SFX_ZOOM_ACQUIRE_TARGET": @{@"file": @"sfx_zoom_acquire_target.aif", @"duration": @(1394)},
		@"SFX_AMBIENT_ALIEN_BASE": @{@"file": @"sfx_ambient_alien_base.aif", @"duration": @(26795)},
		@"SFX_AMBIENT_HUMAN_BASE": @{@"file": @"sfx_ambient_human_base.aif", @"duration": @(30023)},
		@"SFX_AMBIENT_NEUTRAL_BASE": @{@"file": @"sfx_ambient_neutral_base.aif", @"duration": @(30023)},
		@"SFX_AMBIENT_SCANNER_BASE": @{@"file": @"sfx_ambient_scanner_base.aif", @"duration": @(7977)},
		@"SFX_AMBIENT_SPACE_BASE": @{@"file": @"sfx_ambient_space_base.aif", @"duration": @(8986)},
		@"SFX_AMBIENT_SPACE_BASE2": @{@"file": @"sfx_ambient_space_base2.aif", @"duration": @(8800)},
		@"SFX_AMBIENT_SCANNER_BEEPS": @{@"file": @"sfx_ambient_scanner_beeps.aif", @"duration": @(1963)},
		@"SFX_AMBIENT_SCANNER_RING": @{@"file": @"sfx_ambient_scanner_ring.aif", @"duration": @(3960)},
		@"SFX_AMBIENT_SCANNER_SWELL": @{@"file": @"sfx_ambient_scanner_swell.aif", @"duration": @(2901)},
		@"SFX_AMBIENT_SCANNER_WIND": @{@"file": @"sfx_ambient_scanner_wind.aif", @"duration": @(3960)},
		@"SFX_AMBIENT_ALIEN_HEARTBEAT": @{@"file": @"sfx_ambient_alien_heartbeat.aif", @"duration": @(3078)},
		@"SFX_AMBIENT_ALIEN_STATIC": @{@"file": @"sfx_ambient_alien_static.aif", @"duration": @(5075)},
		@"SFX_AMBIENT_ALIEN_WRAITH_ALT": @{@"file": @"sfx_ambient_alien_wraith_alt.aif", @"duration": @(4076)},
		@"SFX_AMBIENT_ALIEN_WRAITH": @{@"file": @"sfx_ambient_alien_wraith.aif", @"duration": @(5075)},
		@"SFX_AMBIENT_HUMAN_CRYSTAL": @{@"file": @"sfx_ambient_human_crystal.aif", @"duration": @(4958)},
		@"SFX_AMBIENT_HUMAN_ENERGY_PULSE": @{@"file": @"sfx_ambient_human_energy_pulse.aif", @"duration": @(5051)},
		@"SFX_AMBIENT_HUMAN_PULSING_STEREO": @{@"file": @"sfx_ambient_human_pulsing_stereo.aif", @"duration": @(8070)},
		@"SFX_AMBIENT_HUMAN_PULSING_WARM": @{@"file": @"sfx_ambient_human_pulsing_warm.aif", @"duration": @(5075)},
		@"SFX_AMBIENT_NEUTRAL_CRYSTAL": @{@"file": @"sfx_ambient_neutral_crystal.aif", @"duration": @(7095)},
		@"SFX_AMBIENT_NEUTRAL_IMPACTS": @{@"file": @"sfx_ambient_neutral_impacts.aif", @"duration": @(5051)},
		@"SFX_AMBIENT_NEUTRAL_WHALE_ALT": @{@"file": @"sfx_ambient_neutral_whale_alt.aif", @"duration": @(4076)},
		@"SFX_AMBIENT_NEUTRAL_WHALE": @{@"file": @"sfx_ambient_neutral_whale.aif", @"duration": @(4076)},
		@"SFX_AMBIENT_SPACE_ALIEN": @{@"file": @"sfx_ambient_space_alien.aif", @"duration": @(3111)},
		@"SFX_AMBIENT_SPACE_FEMALE": @{@"file": @"sfx_ambient_space_female.aif", @"duration": @(3552)},
		@"SFX_AMBIENT_SPACE_TRANSMISSION3": @{@"file": @"sfx_ambient_space_transmission3.aif", @"duration": @(998)},
		@"SFX_AMBIENT_SPACE_TRANSMISSION4": @{@"file": @"sfx_ambient_space_transmission4.aif", @"duration": @(1393)},
		@"SFX_AMBIENT_SPACE_GRID142": @{@"file": @"sfx_ambient_space_grid142.aif", @"duration": @(1017)},
		@"SFX_AMBIENT_SPACE_MAGNIFICATION": @{@"file": @"sfx_ambient_space_magnification.aif", @"duration": @(1516)},
		@"SFX_AMBIENT_SPACE_LATTITUDE": @{@"file": @"sfx_ambient_space_lattitude.aif", @"duration": @(1301)},
		@"SFX_DROP_RESOURCE": @{@"file": @"sfx_drop_resource.aif", @"duration": @(1114)},
		@"SPEECH_ABANDONED": @{@"file": @"speech_abandoned.aif", @"duration": @(744)},
		@"SPEECH_ACCESS_LEVEL_ACHIEVED": @{@"file": @"speech_access_level_achieved.aif", @"duration": @(1327)},
		@"SPEECH_ACTIVATED": @{@"file": @"speech_activated.aif", @"duration": @(782)},
		@"SPEECH_ADDED": @{@"file": @"speech_added.aif", @"duration": @(523)},
		@"SPEECH_ACQUIRED": @{@"file": @"speech_acquired.aif", @"duration": @(580)},
		@"SPEECH_ARCHIVED": @{@"file": @"speech_archived.aif", @"duration": @(767)},
		@"SPEECH_ATTACK": @{@"file": @"speech_attack.aif", @"duration": @(700)},
		@"SPEECH_ATTACK_IN_PROGRESS": @{@"file": @"speech_attack_in_progress.aif", @"duration": @(1365)},
		@"SPEECH_AVAILABLE": @{@"file": @"speech_available.aif", @"duration": @(735)},
		@"SPEECH_CODENAME_ALREADY_ASSIGNED": @{@"file": @"speech_codename_already_assigned.aif", @"duration": @(3043)},
		@"SPEECH_CODENAME_CHOOSE": @{@"file": @"speech_codename_choose.aif", @"duration": @(9193)},
		@"SPEECH_CODENAME_CONFIRM": @{@"file": @"speech_codename_confirm.aif", @"duration": @(2689)},
		@"SPEECH_CODENAME_CONFIRMATION": @{@"file": @"speech_codename_confirmation.aif", @"duration": @(33237)},
		@"SPEECH_COLLAPSED": @{@"file": @"speech_collapsed.aif", @"duration": @(724)},
		@"SPEECH_COMMUNICATION_RECEIVED": @{@"file": @"speech_communication_received.aif", @"duration": @(1290)},
		@"SPEECH_COMPLETE": @{@"file": @"speech_complete.aif", @"duration": @(698)},
		@"SPEECH_COOLDOWN_ACTIVE": @{@"file": @"speech_cooldown_active.aif", @"duration": @(1118)},
		@"SPEECH_CRITICAL": @{@"file": @"speech_critical.aif", @"duration": @(593)},
		@"SPEECH_DEPLETED": @{@"file": @"speech_depleted.aif", @"duration": @(666)},
		@"SPEECH_DEPLOYED": @{@"file": @"speech_deployed.aif", @"duration": @(557)},
		@"SPEECH_DETECTED": @{@"file": @"speech_detected.aif", @"duration": @(645)},
		@"SPEECH_DIRECTION_EAST": @{@"file": @"speech_direction_east.aif", @"duration": @(441)},
		@"SPEECH_DIRECTION_NORTH": @{@"file": @"speech_direction_north.aif", @"duration": @(605)},
		@"SPEECH_DIRECTION_NORTH_EAST": @{@"file": @"speech_direction_north_east.aif", @"duration": @(696)},
		@"SPEECH_DIRECTION_NORTH_WEST": @{@"file": @"speech_direction_north_west.aif", @"duration": @(789)},
		@"SPEECH_DIRECTION_SOUTH": @{@"file": @"speech_direction_south.aif", @"duration": @(580)},
		@"SPEECH_DIRECTION_SOUTH_EAST": @{@"file": @"speech_direction_south_east.aif", @"duration": @(743)},
		@"SPEECH_DIRECTION_SOUTH_WEST": @{@"file": @"speech_direction_south_west.aif", @"duration": @(743)},
		@"SPEECH_DIRECTION_WEST": @{@"file": @"speech_direction_west.aif", @"duration": @(464)},
		@"SPEECH_DRAINED": @{@"file": @"speech_drained.aif", @"duration": @(602)},
		@"SPEECH_ENLIGHTENED": @{@"file": @"speech_enlightened.aif", @"duration": @(692)},
		@"SPEECH_ESTABLISHING_PORTAL_LINK": @{@"file": @"speech_establishing_portal_link.aif", @"duration": @(1439)},
		@"SPEECH_EXCELLENT_WORK": @{@"file": @"speech_excellent_work.aif", @"duration": @(921)},
		@"SPEECH_FACTION_CHOICE_ENLIGHTENED": @{@"file": @"speech_faction_choice_enlightened.aif", @"duration": @(19311)},
		@"SPEECH_FACTION_CHOICE_ENLIGHTENED_ALT": @{@"file": @"speech_faction_choice_enlightened_alt.aif", @"duration": @(7672)},
		@"SPEECH_FACTION_CHOICE_ENLIGHTENED_START": @{@"file": @"speech_faction_choice_enlightened_start.aif", @"duration": @(12868)},
		@"SPEECH_FACTION_CHOICE_HUMANIST": @{@"file": @"speech_faction_choice_humanist.aif", @"duration": @(9872)},
		@"SPEECH_FACTION_CHOICE_HUMANIST_ALT": @{@"file": @"speech_faction_choice_humanist_alt.aif", @"duration": @(13132)},
		@"SPEECH_FACTION_CHOICE_HUMANIST_START": @{@"file": @"speech_faction_choice_humanist_start.aif", @"duration": @(8880)},
		@"SPEECH_FAILED": @{@"file": @"speech_failed.aif", @"duration": @(605)},
		@"SPEECH_FIELD": @{@"file": @"speech_field.aif", @"duration": @(605)},
		@"SPEECH_FIELD_ESTABLISHED": @{@"file": @"speech_field_established.aif", @"duration": @(1226)},
		@"SPEECH_FROM_PRESENT_LOCATION": @{@"file": @"speech_from_present_location.aif", @"duration": @(1345)},
		@"SPEECH_GOOD_WORK": @{@"file": @"speech_good_work.aif", @"duration": @(603)},
		@"SPEECH_HACKER": @{@"file": @"speech_hacker.aif", @"duration": @(581)},
		@"SPEECH_HACKING": @{@"file": @"speech_hacking.aif", @"duration": @(642)},
		@"SPEECH_HUMANIST": @{@"file": @"speech_humanist.aif", @"duration": @(788)},
		@"SPEECH_IN_RANGE": @{@"file": @"speech_in_range.aif", @"duration": @(673)},
		@"SPEECH_INCOMING_MESSAGE": @{@"file": @"speech_incoming_message.aif", @"duration": @(1133)},
		@"SPEECH_KILOMETERS": @{@"file": @"speech_kilometers.aif", @"duration": @(719)},
		@"SPEECH_LINK": @{@"file": @"speech_link.aif", @"duration": @(590)},
		@"SPEECH_LOST": @{@"file": @"speech_lost.aif", @"duration": @(671)},
		@"SPEECH_MEDIA": @{@"file": @"speech_media.aif", @"duration": @(645)},
		@"SPEECH_METERS": @{@"file": @"speech_meters.aif", @"duration": @(557)},
		@"SPEECH_MINE": @{@"file": @"speech_mine.aif", @"duration": @(535)},
		@"SPEECH_MINUTES": @{@"file": @"speech_minutes.aif", @"duration": @(487)},
		@"SPEECH_MISSION": @{@"file": @"speech_mission.aif", @"duration": @(550)},
		@"SPEECH_MISSION_0_INTRO": @{@"file": @"speech_mission_0_intro.aif", @"duration": @(18237)},
		@"SPEECH_MISSION_1B_COMPLETE": @{@"file": @"speech_mission_1b_complete.aif", @"duration": @(3139)},
		@"SPEECH_MISSION_1B_INTRO": @{@"file": @"speech_mission_1b_intro.aif", @"duration": @(14554)},
		@"SPEECH_MISSION_1B_OBJECTIVE": @{@"file": @"speech_mission_1b_objective.aif", @"duration": @(4143)},
		@"SPEECH_MISSION_1_COMPLETE": @{@"file": @"speech_mission_1_complete.aif", @"duration": @(5670)},
		@"SPEECH_MISSION_1_INTRO": @{@"file": @"speech_mission_1_intro.aif", @"duration": @(16760)},
		@"SPEECH_MISSION_2_COMPLETE": @{@"file": @"speech_mission_2_complete.aif", @"duration": @(16017)},
		@"SPEECH_MISSION_2_INTRO": @{@"file": @"speech_mission_2_intro.aif", @"duration": @(14154)},
		@"SPEECH_MISSION_2_PRE_INTRO": @{@"file": @"speech_mission_2_pre_intro.aif", @"duration": @(8973)},
		@"SPEECH_MISSION_3_CLOSING": @{@"file": @"speech_mission_3_closing.aif", @"duration": @(2854)},
		@"SPEECH_MISSION_3_INTRO": @{@"file": @"speech_mission_3_intro.aif", @"duration": @(12865)},
		@"SPEECH_MISSION_4_COMPLETE": @{@"file": @"speech_mission_4_complete.aif", @"duration": @(4384)},
		@"SPEECH_MISSION_4_INTRO": @{@"file": @"speech_mission_4_intro.aif", @"duration": @(8499)},
		@"SPEECH_MISSION_5_COMPLETE": @{@"file": @"speech_mission_5_complete.aif", @"duration": @(2723)},
		@"SPEECH_MISSION_5_HACKING_COMPLETE": @{@"file": @"speech_mission_5_hacking_complete.aif", @"duration": @(3757)},
		@"SPEECH_MISSION_5_INTRO": @{@"file": @"speech_mission_5_intro.aif", @"duration": @(15811)},
		@"SPEECH_MISSION_5_RECHARGE_RESONATORS": @{@"file": @"speech_mission_5_recharge_resonators.aif", @"duration": @(7722)},
		@"SPEECH_MISSION_6_COMPLETE": @{@"file": @"speech_mission_6_complete.aif", @"duration": @(20147)},
		@"SPEECH_MISSION_6_FIRST_PORTAL_KEY": @{@"file": @"speech_mission_6_first_portal_key.aif", @"duration": @(6137)},
		@"SPEECH_MISSION_6_INTRO": @{@"file": @"speech_mission_6_intro.aif", @"duration": @(27612)},
		@"SPEECH_MISSION_6_SECOND_PORTAL": @{@"file": @"speech_mission_6_second_portal.aif", @"duration": @(6215)},
		@"SPEECH_MISSION_6_SECOND_PORTAL_RESONATED": @{@"file": @"speech_mission_6_second_portal_resonated.aif", @"duration": @(5211)},
		@"SPEECH_MISSION_7_COMPLETE": @{@"file": @"speech_mission_7_complete.aif", @"duration": @(31023)},
		@"SPEECH_MISSION_7_FIRST_LINK": @{@"file": @"speech_mission_7_first_link.aif", @"duration": @(2454)},
		@"SPEECH_MISSION_7_INTRO": @{@"file": @"speech_mission_7_intro.aif", @"duration": @(21140)},
		@"SPEECH_MISSION_7_SECOND_LINK": @{@"file": @"speech_mission_7_second_link.aif", @"duration": @(4088)},
		@"SPEECH_MISSION_7_THIRD_PORTAL": @{@"file": @"speech_mission_7_third_portal.aif", @"duration": @(2622)},
		@"SPEECH_MISSION_ACHIEVED_HUMAN": @{@"file": @"speech_mission_achieved_human.aif", @"duration": @(2947)},
		@"SPEECH_MORE_PORTALS": @{@"file": @"speech_more_portals.aif", @"duration": @(1017)},
		@"SPEECH_MULTIPLE_PORTAL_ATTACKS": @{@"file": @"speech_multiple_portal_attacks.aif", @"duration": @(1557)},
		@"SPEECH_NEUTRAL": @{@"file": @"speech_neutral.aif", @"duration": @(625)},
		@"SPEECH_NEXT": @{@"file": @"speech_next.aif", @"duration": @(599)},
		@"SPEECH_NUMBER_001": @{@"file": @"speech_number_001.aif", @"duration": @(361)},
		@"SPEECH_NUMBER_002": @{@"file": @"speech_number_002.aif", @"duration": @(355)},
		@"SPEECH_NUMBER_003": @{@"file": @"speech_number_003.aif", @"duration": @(372)},
		@"SPEECH_NUMBER_004": @{@"file": @"speech_number_004.aif", @"duration": @(454)},
		@"SPEECH_NUMBER_005": @{@"file": @"speech_number_005.aif", @"duration": @(534)},
		@"SPEECH_NUMBER_006": @{@"file": @"speech_number_006.aif", @"duration": @(534)},
		@"SPEECH_NUMBER_007": @{@"file": @"speech_number_007.aif", @"duration": @(483)},
		@"SPEECH_NUMBER_008": @{@"file": @"speech_number_008.aif", @"duration": @(348)},
		@"SPEECH_NUMBER_009": @{@"file": @"speech_number_009.aif", @"duration": @(457)},
		@"SPEECH_NUMBER_010": @{@"file": @"speech_number_010.aif", @"duration": @(404)},
		@"SPEECH_NUMBER_011": @{@"file": @"speech_number_011.aif", @"duration": @(483)},
		@"SPEECH_NUMBER_012": @{@"file": @"speech_number_012.aif", @"duration": @(510)},
		@"SPEECH_NUMBER_013": @{@"file": @"speech_number_013.aif", @"duration": @(599)},
		@"SPEECH_NUMBER_014": @{@"file": @"speech_number_014.aif", @"duration": @(642)},
		@"SPEECH_NUMBER_015": @{@"file": @"speech_number_015.aif", @"duration": @(622)},
		@"SPEECH_NUMBER_016": @{@"file": @"speech_number_016.aif", @"duration": @(712)},
		@"SPEECH_NUMBER_017": @{@"file": @"speech_number_017.aif", @"duration": @(738)},
		@"SPEECH_NUMBER_018": @{@"file": @"speech_number_018.aif", @"duration": @(581)},
		@"SPEECH_NUMBER_019": @{@"file": @"speech_number_019.aif", @"duration": @(674)},
		@"SPEECH_NUMBER_020": @{@"file": @"speech_number_020.aif", @"duration": @(419)},
		@"SPEECH_NUMBER_025": @{@"file": @"speech_number_025.aif", @"duration": @(766)},
		@"SPEECH_NUMBER_030": @{@"file": @"speech_number_030.aif", @"duration": @(491)},
		@"SPEECH_NUMBER_040": @{@"file": @"speech_number_040.aif", @"duration": @(503)},
		@"SPEECH_NUMBER_050": @{@"file": @"speech_number_050.aif", @"duration": @(471)},
		@"SPEECH_NUMBER_060": @{@"file": @"speech_number_060.aif", @"duration": @(570)},
		@"SPEECH_NUMBER_070": @{@"file": @"speech_number_070.aif", @"duration": @(657)},
		@"SPEECH_NUMBER_075": @{@"file": @"speech_number_075.aif", @"duration": @(1081)},
		@"SPEECH_NUMBER_080": @{@"file": @"speech_number_080.aif", @"duration": @(535)},
		@"SPEECH_NUMBER_090": @{@"file": @"speech_number_090.aif", @"duration": @(622)},
		@"SPEECH_NUMBER_100": @{@"file": @"speech_number_100.aif", @"duration": @(580)},
		@"SPEECH_NUMBER_200": @{@"file": @"speech_number_200.aif", @"duration": @(626)},
		@"SPEECH_NUMBER_300": @{@"file": @"speech_number_300.aif", @"duration": @(719)},
		@"SPEECH_NUMBER_400": @{@"file": @"speech_number_400.aif", @"duration": @(719)},
		@"SPEECH_NUMBER_500": @{@"file": @"speech_number_500.aif", @"duration": @(764)},
		@"SPEECH_NUMBER_600": @{@"file": @"speech_number_600.aif", @"duration": @(743)},
		@"SPEECH_NUMBER_700": @{@"file": @"speech_number_700.aif", @"duration": @(766)},
		@"SPEECH_NUMBER_800": @{@"file": @"speech_number_800.aif", @"duration": @(673)},
		@"SPEECH_NUMBER_900": @{@"file": @"speech_number_900.aif", @"duration": @(719)},
		@"SPEECH_OFFLINE": @{@"file": @"speech_offline.aif", @"duration": @(721)},
		@"SPEECH_ONLINE": @{@"file": @"speech_online.aif", @"duration": @(692)},
		@"SPEECH_PERCENT": @{@"file": @"speech_percent.aif", @"duration": @(510)},
		@"SPEECH_POINT": @{@"file": @"speech_point.aif", @"duration": @(576)},
		@"SPEECH_PORTAL": @{@"file": @"speech_portal.aif", @"duration": @(506)},
		@"SPEECH_PORTAL_ATTACK": @{@"file": @"speech_portal_attack.aif", @"duration": @(997)},
		@"SPEECH_PORTAL_FIELD": @{@"file": @"speech_portal_field.aif", @"duration": @(930)},
		@"SPEECH_PORTAL_IN_RANGE": @{@"file": @"speech_portal_in_range.aif", @"duration": @(1255)},
		@"SPEECH_PORTAL_KEY": @{@"file": @"speech_portalkey.aif", @"duration": @(767)},
		@"SPEECH_PORTAL_LINK": @{@"file": @"speech_portal_link.aif", @"duration": @(878)},
		@"SPEECH_PORTAL_LINK_ESTABLISHED": @{@"file": @"speech_portal_link_established.aif", @"duration": @(1393)},
		@"SPEECH_PORTAL_XM": @{@"file": @"speech_portal_xm.aif", @"duration": @(1043)},
		@"SPEECH_POSSIBLE": @{@"file": @"speech_possible.aif", @"duration": @(634)},
		@"SPEECH_POWER_CUBE": @{@"file": @"speech_power_cube.aif", @"duration": @(821)},
		@"SPEECH_RECHARGED": @{@"file": @"speech_recharged.aif", @"duration": @(872)},
		@"SPEECH_REDUCED": @{@"file": @"speech_reduced.aif", @"duration": @(712)},
		@"SPEECH_REFUGE": @{@"file": @"speech_refuge.aif", @"duration": @(785)},
		@"SPEECH_RELEASED": @{@"file": @"speech_released.aif", @"duration": @(626)},
		@"SPEECH_REMAINING": @{@"file": @"speech_remaining.aif", @"duration": @(692)},
		@"SPEECH_REQUIRED": @{@"file": @"speech_required.aif", @"duration": @(724)},
		@"SPEECH_RESONATOR": @{@"file": @"speech_resonator.aif", @"duration": @(590)},
		@"SPEECH_RESONATOR_DESTROYED": @{@"file": @"speech_resonator_destroyed.aif", @"duration": @(1253)},
		@"SPEECH_SATURATED": @{@"file": @"speech_saturated.aif", @"duration": @(866)},
		@"SPEECH_SCANNER": @{@"file": @"speech_scanner.aif", @"duration": @(674)},
		@"SPEECH_SECONDS": @{@"file": @"speech_seconds.aif", @"duration": @(680)},
		@"SPEECH_SEVERED": @{@"file": @"speech_severed.aif", @"duration": @(567)},
		@"SPEECH_SHIELD": @{@"file": @"speech_shield.aif", @"duration": @(637)},
		@"SPEECH_TARGET": @{@"file": @"speech_target.aif", @"duration": @(464)},
		@"SPEECH_TESLA": @{@"file": @"speech_tesla.aif", @"duration": @(628)},
		@"SPEECH_UNSUCCESSFUL": @{@"file": @"speech_unsuccessful.aif", @"duration": @(918)},
		@"SPEECH_UPGRADED": @{@"file": @"speech_upgraded.aif", @"duration": @(712)},
		@"SPEECH_WEAPONS": @{@"file": @"speech_weapons.aif", @"duration": @(709)},
		@"SPEECH_WELCOME_ABOUTTIME": @{@"file": @"speech_welcome_abouttime.aif", @"duration": @(2831)},
		@"SPEECH_WELCOME_BACK": @{@"file": @"speech_welcome_back.aif", @"duration": @(892)},
		@"SPEECH_WELCOME_ITSBEEN": @{@"file": @"speech_welcome_itsbeen.aif", @"duration": @(785)},
		@"SPEECH_WELCOME_LAST_LOGIN": @{@"file": @"speech_welcome_last_login.aif", @"duration": @(1824)},
		@"SPEECH_WELCOME_LONGTIME": @{@"file": @"speech_welcome_longtime.aif", @"duration": @(4120)},
		@"SPEECH_WELCOME_WORRIEDABOUTYOU": @{@"file": @"speech_welcome_worriedaboutyou.aif", @"duration": @(1441)},
		@"SPEECH_XM": @{@"file": @"speech_xm.aif", @"duration": @(680)},
		@"SPEECH_XM_LEVELS": @{@"file": @"speech_xm_levels.aif", @"duration": @(1124)},
		@"SPEECH_XM_REQUIRED_FOR_THIS_PORTAL": @{@"file": @"speech_xm_required_for_this_portal.aif", @"duration": @(1920)},
		@"SPEECH_XM_RESERVE": @{@"file": @"speech_xm_reserve.aif", @"duration": @(1118)},
		@"SPEECH_XM_RESERVES": @{@"file": @"speech_xm_reserves.aif", @"duration": @(1272)},
		@"SPEECH_XMP": @{@"file": @"speech_xmp.aif", @"duration": @(866)},
		@"SPEECH_YOUVE_BEEN_HIT": @{@"file": @"speech_youve_been_hit.aif", @"duration": @(696)},
		@"SPEECH_YOU_ARE_UNDER_ATTACK": @{@"file": @"speech_you_are_under_attack.aif", @"duration": @(1095)},
		@"SPEECH_YOU_HAVE_SUFFICIENT_ENERGY_TO_HACK_YOUR_TARGET": @{@"file": @"speech_you_have_sufficient_energy_to_hack_your_target.aif", @"duration": @(2343)},
		@"SPEECH_ZOOM_ACQUIRING": @{@"file": @"speech_zoom_acquiring.aif", @"duration": @(1208)},
		@"SPEECH_ZOOM_DOWNLOADING": @{@"file": @"speech_zoom_downloading.aif", @"duration": @(2007)},
		@"SPEECH_ZOOM_LOCKON": @{@"file": @"speech_zoom_lockon.aif", @"duration": @(1470)},
		@"SPEECH_ZOOMDOWN_INTRO": @{@"file": @"speech_zoomdown_intro.aif", @"duration": @(28152)},
		@"SPEECH_ZOOMDOWN_TRIANGULATING": @{@"file": @"speech_zoomdown_triangulating.aif", @"duration": @(1861)},
	};
}

+ (float)durationOfSound:(NSString *)soundName {
	return [[API sounds][soundName][@"duration"] floatValue]/1000.;
}

+ (NSArray *)soundsForNumber:(int)number {

	if (number > 0 && number < 10) {
		return @[[NSString stringWithFormat:@"SPEECH_NUMBER_00%d", number]];
	} else if (number >= 10 && number <= 20) {
		return @[[NSString stringWithFormat:@"SPEECH_NUMBER_0%d", number]];
	} else if (number == 25 || number == 30 || number == 40 || number == 50 || number == 60 || number == 70 || number == 75 || number == 80 || number == 90) {
		return @[[NSString stringWithFormat:@"SPEECH_NUMBER_0%d", number]];
	} else if (number == 100 || number == 200 || number == 300 || number == 400 || number == 500 || number == 600 || number == 700 || number == 800 || number == 900) {
		return @[[NSString stringWithFormat:@"SPEECH_NUMBER_%d", number]];
	} else if (number > 20 && number < 100) {
		int tens = (int)(number/10)*10;
		int units = number-tens;
		return @[[NSString stringWithFormat:@"SPEECH_NUMBER_0%d", tens], [NSString stringWithFormat:@"SPEECH_NUMBER_00%d", units]];
	}

	return @[];

}

- (void)playSound:(NSString *)soundName {
	[soundsQueue addObject:soundName];
	[self checkSoundQueue];
}

- (void)playSounds:(NSArray *)soundNames {
	[soundsQueue addObjectsFromArray:soundNames];
	[self checkSoundQueue];
}

- (void)checkSoundQueue {
	if (!isSoundPlaying && soundsQueue.count > 0) {

		NSString *soundName = soundsQueue[0];
		[[SoundManager sharedManager] playSound:[NSString stringWithFormat:@"Sound/%@", [API sounds][soundName][@"file"]]];
		isSoundPlaying = YES;

		dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)([API durationOfSound:soundName] * NSEC_PER_SEC));
		dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
			[soundsQueue removeObject:soundName];
			isSoundPlaying = NO;
			[self checkSoundQueue];
		});
		
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
			
			[[API sharedInstance] playSounds:@[@"SPEECH_ZOOM_ACQUIRING", @"SPEECH_ZOOM_LOCKON", @"SPEECH_ZOOM_DOWNLOADING"]];
			
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

	[[DB sharedInstance] removeAllMapData];
	[[DB sharedInstance] removeAllEnergyGlobs];
	
	NSArray *cellsAsHex = [[S2Geometry sharedInstance] cellsForMapView:[AppDelegate instance].mapView];

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

	[self sendRequest:@"gameplay/getObjectsInCells" params:dict completionHandler:^(id responseObj) {

		//NSLog(@"getObjectsInCells responseObj: %@", responseObj);

		dispatch_async(dispatch_get_main_queue(), ^{
			handler();
		});
		
	}];

}

- (void)loadCommunicationForFactionOnly:(BOOL)factionOnly completionHandler:(void (^)(NSArray *messages))handler {
	
	//NSLog(@"loadCommunicationWithCompletionHandler");

	//NSArray *cellsAsHex = [self cellsAsHex];
	
	NSDictionary *dict = @{
	//@"cellsAsHex": cellsAsHex,
	@"cellsAsHex": @[

		 // Teplice
		@"4709900000000000",
		@"4709ec0000000000",
		@"4709f40000000000",
		@"470a1f0000000000",
		@"470a210000000000",
		@"470a270000000000",
		@"470a290000000000",
		@"470a2a4000000000",

		 // Almelo, Netherlands
//		@"47b7f8c000000000",
//		@"47b7ff0000000000",
//		@"47b8100000000000",
//		@"47c7f00000000000",
//		@"47c8040000000000",

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
			int start = 0;
			for (NSArray *markup in markups) {
				//NSLog(@"%@: %@", markup[0], markup[1][@"plain"]);
				
				NSRange range = [str rangeOfString:markup[1][@"plain"] options:0 range:NSMakeRange(start, str.length-start)];
				
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

				start += range.length;
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
			handler(responseObj[@"error"]); //INVALID_CHARACTERS, TOO_SHORT, BAD_WORDS, NOT_UNIQUE, CANNOT_EDIT
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
//	NSLog(@"dropItemWithGuid: %@", guid);

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

- (void)usePowerCube:(PowerCube *)powerCube completionHandler:(void (^)(void))handler {

	NSDictionary *dict = @{
	  @"knobSyncTimestamp": @(0),
	  @"playerLocation": [self currentE6Location],
	  @"itemGuid": powerCube.guid
	};

	[self sendRequest:@"gameplay/dischargePowerCube" params:dict completionHandler:^(id responseObj) {

		//NSLog(@"dischargePowerCube responseObj: %@", responseObj);

		dispatch_async(dispatch_get_main_queue(), ^{
			handler();
		});
		
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

	if ([self.playerInfo[@"energy"] intValue] != [playerEntity[2][@"playerPersonal"][@"energy"] intValue]) {
		int xm = (int)round(([playerEntity[2][@"playerPersonal"][@"energy"] floatValue]/[API maxXmForLevel:newLevel])*100);

		NSMutableArray *sounds = [NSMutableArray arrayWithCapacity:4];
		[sounds addObject:@"SPEECH_XM_LEVELS"];
		[sounds addObjectsFromArray:[API soundsForNumber:xm]];
		[sounds addObject:@"SPEECH_PERCENT"];

		dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC));
		dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
			[self playSounds:sounds];
		});

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

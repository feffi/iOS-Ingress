//
//  API.m
//  Ingress
//
//  Created by Alex Studnicka on 10.01.13.
//  Copyright (c) 2013 A&A Code. All rights reserved.
//

#import "API.h"

NSString *const DeviceSoundLevel = @"DeviceSoundLevel";
NSString *const DeviceSoundToggleBackground = @"FHDeviceSoundToggleBackground";
NSString *const DeviceSoundToggleEffects = @"FHDeviceSoundToggleEffects";
NSString *const DeviceSoundToggleSpeech = @"FHDeviceSoundToggleSpeech";
NSString *const IGMapDayMode = @"IGMapDayMode";
NSString *const MilesOrKM = @"MilesOrKM";

@implementation API {
	BOOL isSoundPlaying;
	NSMutableArray *soundsQueue;
	NSMutableDictionary *cellsDates;
	NSString *playerGuid;
	
	int _networkActivityCount;
	
	NSTimer *inventoryRefreshTimer;
	
	BOOL inventoryRefreshInProgress;
}

@synthesize networkQueue = _networkQueue;
@synthesize xsrfToken = _xsrfToken;
@synthesize SACSID = _SACSID;
@synthesize energyToCollect = _energyToCollect;
@synthesize currentTimestamp = _currentTimestamp;

+ (instancetype)sharedInstance {
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
		cellsDates = [NSMutableDictionary dictionary];
		self.energyToCollect = [NSMutableArray array];
		self.networkQueue = [NSOperationQueue new];
		self.networkQueue.name = @"Network Queue";
		
		inventoryRefreshTimer = [NSTimer scheduledTimerWithTimeInterval:30 target:self selector:@selector(autorefreshInventory) userInfo:nil repeats:YES];
	}
    return self;
}

#pragma mark - Network Activity Indicator

- (void)incrementNetworkActivityCount {
    if (_networkActivityCount == 0) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    }
    _networkActivityCount++;
}

- (void)decrementNetworkActivityCount {
    _networkActivityCount--;
    if (_networkActivityCount <= 0) {
        _networkActivityCount = 0;
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    }
}

#pragma mark - Knob Sync

- (long long)currentTimestamp {
	NSString *timestampString = [NSString stringWithFormat:@"%.3f", [[NSDate date] timeIntervalSince1970]];
	timestampString = [timestampString stringByReplacingOccurrencesOfString:@"." withString:@""];
	return [timestampString longLongValue];
}

#pragma mark - Auto refresh

- (void)autorefreshInventory {
	if (!inventoryRefreshInProgress) {
		[[API sharedInstance] getInventoryWithCompletionHandler:NULL];
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
		@"SFX_RESOURCE_PICK_UP": @{@"file": @"sfx_resource_pick_up.aif", @"duration": @(2090)},
		@"SFX_RESONATOR_RECHARGE": @{@"file": @"sfx_resonator_recharge.aif", @"duration": @(3090)},
		@"SFX_PLAYER_LEVEL_UP": @{@"file": @"sfx_player_level_up.aif", @"duration": @(8680)},
		@"SPEECH_ABANDONED": @{@"file": @"speech_abandoned.aif", @"duration": @(744)},
		@"SPEECH_ACCESS_LEVEL_ACHIEVED": @{@"file": @"speech_access_level_achieved.aif", @"duration": @(1327)},
		@"SPEECH_ACTIVATED": @{@"file": @"speech_activated.aif", @"duration": @(782)},
		@"SPEECH_ADA_REFACTOR": @{@"file": @"speech_flipcard_ada.aif", @"duration": @(1050)},
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
		@"SPEECH_JARVIS_VIRUS": @{@"file": @"speech_flipcard_jarvis.aif", @"duration": @(1190)},
		@"SPEECH_KILOMETERS": @{@"file": @"speech_kilometers.aif", @"duration": @(719)},
		@"SPEECH_LINK": @{@"file": @"speech_link.aif", @"duration": @(590)},
		@"SPEECH_LINKAMP": @{@"file": @"speech_linkamp.aif", @"duration": @(900)},
		@"SPEECH_FORCE_AMP": @{@"file": @"speech_force_amp.aif", @"duration": @(910)},
		@"SPEECH_HEAT_SINK": @{@"file": @"speech_heat_sink.aif", @"duration": @(780)},
		@"SPEECH_MULTI_HACK": @{@"file": @"speech_multi_hack.aif", @"duration": @(1020)},
		@"SPEECH_TURRET": @{@"file": @"speech_turret.aif", @"duration": @(580)},
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
		@"SPEECH_UNKNOWN_TECH": @{@"file": @"speech_unknown_tech.aif", @"duration": @(1390)},
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
//		@"": @{@"file": @"", @"duration": @()},
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
	} else if (number > 100 && number < 1000) {
		int hundrets = (int)(number/100)*100;
		return [@[[NSString stringWithFormat:@"SPEECH_NUMBER_%d", hundrets]] arrayByAddingObjectsFromArray:[API soundsForNumber:(number-hundrets)]];
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
	CLLocationCoordinate2D loc = [LocationManager sharedInstance].playerLocation.coordinate;
	return [NSString stringWithFormat:@"%08x,%08x", (int)(loc.latitude*1E6), (int)(loc.longitude*1E6)];
}

#pragma mark - Player

- (Player *)playerForContext:(NSManagedObjectContext *)context {
	if (playerGuid) {
		Player *player = [Player MR_findFirstByAttribute:@"guid" withValue:playerGuid inContext:context];
		if (!player) {
			player = [Player MR_createInContext:context];
			player.guid = playerGuid;
		}
		return player;
	}
	return nil;
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

		if ([jsonObject[@"result"][@"pregameStatus"][@"action"] isEqualToString:@"CLIENT_MUST_UPGRADE"]) {
			dispatch_async(dispatch_get_main_queue(), ^{
				handler(@"CLIENT_MUST_UPGRADE");
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

		playerGuid = jsonObject[@"result"][@"playerEntity"][0];

		Player *player = [self playerForContext:[NSManagedObjectContext MR_contextForCurrentThread]];

		player.nickname = jsonObject[@"result"][@"nickname"];
		player.team = jsonObject[@"result"][@"playerEntity"][2][@"controllingTeam"][@"team"];
		player.ap = [jsonObject[@"result"][@"playerEntity"][2][@"playerPersonal"][@"ap"] intValue];
		player.energy = [jsonObject[@"result"][@"playerEntity"][2][@"playerPersonal"][@"energy"] intValue];
		player.allowNicknameEdit = [jsonObject[@"result"][@"playerEntity"][2][@"playerPersonal"][@"allowNicknameEdit"] boolValue];
		player.allowFactionChoice = [jsonObject[@"result"][@"playerEntity"][2][@"playerPersonal"][@"allowFactionChoice"] boolValue];
		player.shouldSendEmail = [jsonObject[@"result"][@"playerEntity"][2][@"playerPersonal"][@"notificationSettings"][@"shouldSendEmail"] boolValue];
		player.shouldPushNotifyForAtPlayer = [jsonObject[@"result"][@"playerEntity"][2][@"playerPersonal"][@"notificationSettings"][@"shouldPushNotifyForAtPlayer"] boolValue];
		player.shouldPushNotifyForPortalAttacks = [jsonObject[@"result"][@"playerEntity"][2][@"playerPersonal"][@"notificationSettings"][@"shouldPushNotifyForPortalAttacks"] boolValue];

		[[NSNotificationCenter defaultCenter] postNotificationName:@"ProfileUpdatedNotification" object:nil];

		dispatch_async(dispatch_get_main_queue(), ^{
			handler(nil);
			
			/////
			
//			[[API sharedInstance] playSounds:@[@"SPEECH_ZOOM_ACQUIRING", @"SPEECH_ZOOM_LOCKON", @"SPEECH_ZOOM_DOWNLOADING"]];

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
	
	inventoryRefreshInProgress = YES;

	Player *player = [self playerForContext:[NSManagedObjectContext MR_contextForCurrentThread]];
	long long lastInventoryUpdated = [[NSDate dateWithTimeIntervalSinceReferenceDate:player.lastInventoryUpdated] timeIntervalSince1970]*1000.;
//	NSLog(@"lastInventoryUpdated: %@", [NSDate dateWithTimeIntervalSinceReferenceDate:player.lastInventoryUpdated]);
	
	NSDictionary *params = @{
		@"lastQueryTimestamp": @(lastInventoryUpdated)
	};

	[self sendRequest:@"playerUndecorated/getInventory" params:params completionHandler:^(id responseObj) {
//		NSLog(@"getInventory responseObj: %@", responseObj);
		
		inventoryRefreshInProgress = NO;

		Player *player = [self playerForContext:[NSManagedObjectContext MR_contextForCurrentThread]];
		player.lastInventoryUpdated = [[NSDate dateWithTimeIntervalSince1970:([responseObj[@"result"] doubleValue]/1000.)] timeIntervalSinceReferenceDate];
//		NSLog(@"NEW lastInventoryUpdated: %@", [NSDate dateWithTimeIntervalSince1970:([responseObj[@"result"] doubleValue]/1000.)]);

		if (handler) {
			dispatch_async(dispatch_get_main_queue(), ^{
				handler();
			});
		}
		
	}];
	
}

- (void)getObjectsWithCompletionHandler:(void (^)(void))handler {

	MKMapView *mapView = [AppDelegate instance].mapView;
	CGPoint nePoint = CGPointMake(mapView.bounds.origin.x + mapView.bounds.size.width, mapView.bounds.origin.y);
	CGPoint swPoint = CGPointMake((mapView.bounds.origin.x), (mapView.bounds.origin.y + mapView.bounds.size.height));
	CLLocationCoordinate2D neCoord = [mapView convertPoint:nePoint toCoordinateFromView:mapView];
	CLLocationCoordinate2D swCoord = [mapView convertPoint:swPoint toCoordinateFromView:mapView];
	NSArray *cellsAsHex = [S2Geometry cellsForNeCoord:neCoord swCoord:swCoord minZoomLevel:16 maxZoomLevel:16];

	NSMutableArray *dates = [NSMutableArray arrayWithCapacity:cellsAsHex.count];
	for (NSString *cellID in cellsAsHex) {
//		if (cellsDates[cellID]) {
//			[dates addObject:cellsDates[cellID]];
//		} else {
			[dates addObject:@0];
//		}
//		cellsDates[cellID] = @(self.currentTimestamp);
	}
	
	NSDictionary *dict = @{
		@"cellsAsHex": cellsAsHex,
		@"dates": dates
	};

	[self sendRequest:@"gameplay/getObjectsInCells" params:dict completionHandler:^(id responseObj) {
		//NSLog(@"getObjectsInCells responseObj: %@", responseObj);

		if (handler) {
			dispatch_async(dispatch_get_main_queue(), ^{
				handler();
			});
		}
		
	}];

}

- (void)loadCommunicationForFactionOnly:(BOOL)factionOnly completionHandler:(void (^)(void))handler {
	//NSLog(@"loadCommunicationWithCompletionHandler");

	MKMapView *mapView = [AppDelegate instance].mapView;
	MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(mapView.centerCoordinate, 20000, 20000);
	CLLocationCoordinate2D neCoord, swCoord;
	neCoord.latitude  = region.center.latitude  + (region.span.latitudeDelta  / 2.0);
	neCoord.longitude = region.center.longitude + (region.span.longitudeDelta / 2.0);
	swCoord.latitude  = region.center.latitude  - (region.span.latitudeDelta  / 2.0);
	swCoord.longitude = region.center.longitude - (region.span.longitudeDelta / 2.0);
	NSArray *cellsAsHex = [S2Geometry cellsForNeCoord:neCoord swCoord:swCoord minZoomLevel:8 maxZoomLevel:12];
	
	NSDictionary *dict = @{
		@"cellsAsHex": cellsAsHex,
		@"minTimestampMs": @(-1),
		@"maxTimestampMs":@(-1),
		@"desiredNumItems": @50,
		@"factionOnly": @(factionOnly),
		@"ascendingTimestampOrder": @NO
	};
	
	[self sendRequest:@"playerUndecorated/getPaginatedPlexts" params:dict completionHandler:^(id responseObj) {
		//NSLog(@"getPaginatedPlexts responseObj: %@", responseObj);
		
		[MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {

			for (NSArray *message in responseObj[@"result"]) {

				NSTimeInterval timestamp = [message[1] doubleValue]/1000.;
				NSDate *date = [NSDate dateWithTimeIntervalSince1970:timestamp];

				Player *player = [self playerForContext:localContext];
				User *sender = nil;

				NSString *str = message[2][@"plext"][@"text"];
				NSMutableAttributedString *atrstr = [[NSMutableAttributedString alloc] initWithString:str];
				//NSLog(@"msg: %@", str);

				NSArray *markups = message[2][@"plext"][@"markup"];
				BOOL isMessage = NO;
				BOOL mentionsYou = NO;
				int start = 0;
				for (NSArray *markup in markups) {
					//NSLog(@"%@: %@", markup[0], markup[1][@"plain"]);

					NSRange range = [str rangeOfString:markup[1][@"plain"] options:0 range:NSMakeRange(start, str.length-start)];

					if ([markup[0] isEqualToString:@"PLAYER"] || [markup[0] isEqualToString:@"SENDER"] || [markup[0] isEqualToString:@"AT_PLAYER"]) {

						if ([markup[0] isEqualToString:@"SENDER"]) {
							isMessage = YES;

							NSString *senderGUID = markup[1][@"guid"];
							sender = [User MR_findFirstByAttribute:@"guid" withValue:senderGUID inContext:localContext];
							if (!sender) {
								sender = [User MR_createInContext:localContext];
								sender.guid = senderGUID;
							}
							sender.nickname = [[markup[1][@"plain"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"@:"]];
						}

						if ([markup[0] isEqualToString:@"AT_PLAYER"] && [[markup[1][@"plain"] substringFromIndex:1] isEqualToString:player.nickname]) {
							[atrstr setAttributes:@{NSFontAttributeName: [UIFont fontWithName:[[[UILabel appearance] font] fontName] size:CHAT_FONT_SIZE], NSForegroundColorAttributeName : [UIColor colorWithRed:1.000 green:0.839 blue:0.322 alpha:1.000]} range:range];
							mentionsYou = YES;
						} else {
							if ([markup[1][@"team"] isEqualToString:@"ALIENS"]) {
								[atrstr setAttributes:@{NSFontAttributeName: [UIFont fontWithName:[[[UILabel appearance] font] fontName] size:CHAT_FONT_SIZE], NSForegroundColorAttributeName : [UIColor colorWithRed:40./255. green:244./255. blue:40./255. alpha:1]} range:range];
							} else {
								[atrstr setAttributes:@{NSFontAttributeName: [UIFont fontWithName:[[[UILabel appearance] font] fontName] size:CHAT_FONT_SIZE], NSForegroundColorAttributeName : [UIColor colorWithRed:0 green:194./255. blue:1 alpha:1]} range:range];
							}
						}

					} else if ([markup[0] isEqualToString:@"PORTAL"]) {
						[atrstr setAttributes:@{NSFontAttributeName: [UIFont fontWithName:[[[UILabel appearance] font] fontName] size:CHAT_FONT_SIZE], NSForegroundColorAttributeName : [UIColor colorWithRed:0 green:135./255. blue:128./255. alpha:1]} range:range];

					} else if ([markup[0] isEqualToString:@"SECURE"]) {
						[atrstr setAttributes:@{NSFontAttributeName: [UIFont fontWithName:[[[UILabel appearance] font] fontName] size:CHAT_FONT_SIZE], NSForegroundColorAttributeName : [UIColor colorWithRed:245./255. green:95./255. blue:85./255. alpha:1]} range:range];
					} else {

						if (isMessage) {
							[atrstr setAttributes:@{NSFontAttributeName: [UIFont fontWithName:[[[UILabel appearance] font] fontName] size:CHAT_FONT_SIZE], NSForegroundColorAttributeName : [UIColor colorWithRed:207./255. green:229./255. blue:229./255. alpha:1]} range:range];
						} else {
							[atrstr setAttributes:@{NSFontAttributeName: [UIFont fontWithName:[[[UILabel appearance] font] fontName] size:CHAT_FONT_SIZE], NSForegroundColorAttributeName : [UIColor colorWithRed:0 green:186./255. blue:181./255. alpha:1]} range:range];
						}

					}

					start += range.length;
				}

				Plext *plext = [Plext MR_findFirstByAttribute:@"guid" withValue:message[0] inContext:localContext];
				if (!plext) { plext = [Plext MR_createInContext:localContext]; }
				plext.guid = message[0];
				plext.message = atrstr;
				plext.factionOnly = factionOnly;
				plext.date = [date timeIntervalSinceReferenceDate];
				plext.mentionsYou = mentionsYou;
				plext.sender = sender;
			}

			if (handler) {
				dispatch_async(dispatch_get_main_queue(), ^{
					handler();
				});
			}

		}];
		
	}];
	
}

- (void)sendMessage:(NSString *)message factionOnly:(BOOL)factionOnly completionHandler:(void (^)(void))handler {
	
	//NSLog(@"loc: {%f, %f}", loc.latitude, loc.longitude);
	//CLLocationCoordinate2D loc = CLLocationCoordinate2DMake(50.639722, 13.829444);
	
	NSDictionary *dict = @{
		@"factionOnly": @(factionOnly),
		@"message": message
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
        
        [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {

            NSMutableAttributedString *atrstr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"Enlightened %d - Resistance %d", alienScore, resistanceScore] attributes:[Utilities attributesWithShadow:NO size:CHAT_FONT_SIZE color:[UIColor whiteColor]]];
            
            int len1 = [[NSString stringWithFormat:@"Enlightened %d", alienScore] length];
            [atrstr setAttributes:[Utilities attributesWithShadow:NO size:CHAT_FONT_SIZE color:[Utilities colorForFaction:@"ALIENS"]] range:NSMakeRange(0, len1)];
            
            int len2 = [[NSString stringWithFormat:@"Resistance %d", resistanceScore] length];
            [atrstr setAttributes:[Utilities attributesWithShadow:NO size:CHAT_FONT_SIZE color:[Utilities colorForFaction:@"RESISTANCE"]] range:NSMakeRange(atrstr.length-len2, len2)];

            Plext *plext = [Plext MR_createInContext:localContext];
            plext.guid = nil;
            plext.message = atrstr;
            plext.factionOnly = NO;
            plext.date = [[NSDate date] timeIntervalSinceReferenceDate];
            plext.mentionsYou = nil;
            plext.sender = nil;
            
        }];
		
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
		@"itemGuid": xmpItem.guid
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

- (void)chooseFaction:(NSString *)faction completionHandler:(void (^)(NSString *errorStr))handler {

	[self sendRequest:@"playerUndecorated/chooseFaction" params:@[faction] completionHandler:^(id responseObj) {
		//NSLog(@"chooseFaction: %@", responseObj);
		
		dispatch_async(dispatch_get_main_queue(), ^{
			handler(responseObj[@"error"]);
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
	
	if (!portal || !portal.guid) {
		handler(@"Application error", nil, 0);
		return;
	}
	
	NSDictionary *dict = @{
		@"itemGuid": portal.guid
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
			
		} else if ([responseObj[@"error"] isEqualToString:@"SERVER_ERROR"]) {
			
			dispatch_async(dispatch_get_main_queue(), ^{
				handler(@"Server error", nil, 0);
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
		@"itemGuids": @[resonatorItem.guid],
		@"portalGuid": portal.guid,
		@"preferredSlot": @(slot)
	};
	
	[self sendRequest:@"gameplay/deployResonatorV2" params:dict completionHandler:^(id responseObj) {		

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

		} else if ([responseObj[@"error"] isEqualToString:@"ITEM_DOES_NOT_EXIST"]) {
			// This happens when attempting to deploy to a portal that is out of range. TODO Don't allow player to deploy if portal is not in range.
			dispatch_async(dispatch_get_main_queue(), ^{
				handler(@"Item does not exist");
			});

		} else if ([responseObj[@"error"] isEqualToString:@"SERVER_ERROR"]) {
			
			dispatch_async(dispatch_get_main_queue(), ^{
				handler(@"Server error");
			});

		} else {
			//NSLog(@"deployResonator responseObj: %@", responseObj);
			
			dispatch_async(dispatch_get_main_queue(), ^{
				handler(nil);
			});
			
		}

	}];
	
}

- (void)upgradeResonator:(Resonator *)resonatorItem toPortal:(Portal *)portal toSlot:(int)slot completionHandler:(void (^)(NSString *errorStr))handler {

	NSDictionary *dict = @{
		@"emitterGuid": resonatorItem.guid,
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

- (void)addMod:(Mod *)modItem toItem:(Portal *)modableItem toSlot:(int)slot completionHandler:(void (^)(NSString *errorStr))handler {
	
	NSDictionary *dict = @{
		@"modResourceGuid": modItem.guid,
		@"modableGuid": modableItem.guid,
		@"index": @(slot)
	};
	
	[self sendRequest:@"gameplay/addMod" params:dict completionHandler:^(id responseObj) {
        //NSLog(@"addMod responseObj: %@", responseObj);
		
        if (responseObj[@"error"]) {
            if ([responseObj[@"error"] isEqualToString:@"PORTAL_OUT_OF_RANGE"]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    handler(@"Portal out of range");
                });
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    handler(responseObj[@"error"]);
                });
            }
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                handler(nil);
            });
        }
		
	}];
	
}

- (void)removeModFromItem:(Portal *)modableItem atSlot:(int)slot completionHandler:(void (^)(NSString *errorStr))handler {

	NSDictionary *dict = @{
		@"modableGuid": modableItem.guid,
		@"index": @(slot)
	};

	[self sendRequest:@"gameplay/removeMod" params:dict completionHandler:^(id responseObj) {
        //NSLog(@"removeMod responseObj: %@", responseObj);
        
        if (responseObj[@"error"]) {
            if ([responseObj[@"error"] isEqualToString:@"PORTAL_OUT_OF_RANGE"]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    handler(@"Portal out of range");
                });
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    handler(responseObj[@"error"]);
                });
            }
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                handler(nil);
            });
        }
		
	}];

}

- (void)dropItemWithGuid:(NSString *)guid completionHandler:(void (^)(void))handler {

	NSDictionary *dict = @{
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

- (void)recycleItem:(Item *)item completionHandler:(void (^)(void))handler {

	NSDictionary *dict = @{
		@"itemGuid": item.guid
	};

	[self sendRequest:@"gameplay/recycleItem" params:dict completionHandler:^(id responseObj) {
		//NSLog(@"recycleItem responseObj: %@", responseObj);

		dispatch_async(dispatch_get_main_queue(), ^{
			handler();
		});
		
	}];

}

- (void)usePowerCube:(PowerCube *)powerCube completionHandler:(void (^)(void))handler {

	NSDictionary *dict = @{
		@"itemGuid": powerCube.guid
	};

	[self sendRequest:@"gameplay/dischargePowerCube" params:dict completionHandler:^(id responseObj) {
		//NSLog(@"dischargePowerCube responseObj: %@", responseObj);

		dispatch_async(dispatch_get_main_queue(), ^{
			handler();
		});
		
	}];

}

- (void)rechargePortal:(Portal *)portal slots:(NSArray *)slots completionHandler:(void (^)(NSString *errorStr))handler {
	
	NSDictionary *dict = @{
		@"portalGuid": portal.guid,
		@"resonatorSlots": slots
	};
	
	[self sendRequest:@"gameplay/rechargeResonatorsV2" params:dict completionHandler:^(id responseObj) {
		//NSLog(@"rechargeResonatorWithGuid responseObj: %@", responseObj);
		
		dispatch_async(dispatch_get_main_queue(), ^{
			handler(responseObj[@"error"]);
		});
		
	}];
	
}

- (void)remoteRechargePortal:(Portal *)portal portalKey:(PortalKey *)portalKey completionHandler:(void (^)(NSString *errorStr))handler {

	NSDictionary *dict = @{
		@"portalGuid": portal.guid,
		@"portalKeyGuid": portalKey.guid,
		@"resonatorSlots": @[@0, @1, @2, @3, @4, @5, @6, @7]
	};

	[self sendRequest:@"gameplay/remoteRechargeResonatorsV2" params:dict completionHandler:^(id responseObj) {
		//NSLog(@"rechargeResonatorWithGuid responseObj: %@", responseObj);

		dispatch_async(dispatch_get_main_queue(), ^{
			handler(responseObj[@"error"]);
		});

	}];
	
}

- (void)queryLinkabilityForPortal:(Portal *)portal portalKey:(PortalKey *)portalKey completionHandler:(void (^)(NSString *errorStr))handler {

	NSDictionary *dict = @{
		@"originPortalGuid": portal.guid,
		@"portalLinkKeyGuidSet": @[portalKey.guid]
	};

	[self sendRequest:@"gameplay/getLinkabilityImpediment" params:dict completionHandler:^(id responseObj) {
		//NSLog(@"getLinkabilityImpediment responseObj: %@", responseObj);

		dispatch_async(dispatch_get_main_queue(), ^{
			handler(responseObj[@"result"][portalKey.guid]);
		});

	}];

}

- (void)linkPortal:(Portal *)portal withPortalKey:(PortalKey *)portalKey completionHandler:(void (^)(NSString *errorStr))handler {

	NSDictionary *dict = @{
		@"originPortalGuid": portal.guid,
		@"destinationPortalGuid": portalKey.portalGuid,
		@"linkKeyGuid": portalKey.guid
	};

	[self sendRequest:@"gameplay/createLink" params:dict completionHandler:^(id responseObj) {
		//NSLog(@"createLink responseObj: %@", responseObj);

		if (handler) {
			dispatch_async(dispatch_get_main_queue(), ^{
				handler(nil);
			});
		}
		
	}];
	
}

- (void)setNotificationSettingsWithCompletionHandler:(void (^)(void))handler {

	Player *player = [self playerForContext:[NSManagedObjectContext MR_contextForCurrentThread]];
	
	NSDictionary *dict = @{
		@"notificationSettings": @{
			@"maySendPromoEmail": @(player.maySendPromoEmail),
			@"shouldSendEmail": @(player.shouldSendEmail),
			@"shouldPushNotifyForAtPlayer": @(player.shouldPushNotifyForAtPlayer),
			@"shouldPushNotifyForPortalAttacks": @(player.shouldPushNotifyForPortalAttacks)
		}
	};

	[self sendRequest:@"gameplay/setNotificationSettings" params:dict completionHandler:^(id responseObj) {
		//NSLog(@"setNotificationSettings responseObj: %@", responseObj);

		if (handler) {
			dispatch_async(dispatch_get_main_queue(), ^{
				handler();
			});
		}
		
	}];
	
}

- (void)getModifiedEntity:(Portal *)item completionHandler:(void (^)(void))handler {

//	NSString *timestampString = [NSString stringWithFormat:@"%.3f", [[NSDate dateWithTimeIntervalSinceReferenceDate:item.timestamp] timeIntervalSince1970]];
//	timestampString = [timestampString stringByReplacingOccurrencesOfString:@"." withString:@""];
	long long timestamp = 0; //[timestampString longLongValue];

	NSDictionary *dict = @{
		@"guids": @[item.guid],
		@"timestampsMs": @[@(timestamp)]
	};

	[self sendRequest:@"gameplay/getModifiedEntitiesByGuid" params:dict completionHandler:^(id responseObj) {
		//NSLog(@"getModifiedEntitiesByGuid responseObj: %@", responseObj);

		if (handler) {
			dispatch_async(dispatch_get_main_queue(), ^{
				handler();
			});
		}
		
	}];

}

- (void)flipPortal:(Portal *)portal withFlipCard:(FlipCard *)flipCard completionHandler:(void (^)(NSString *errorStr))handler {

	NSDictionary *dict = @{
		@"portalGuid": portal.guid,
		@"resourceGuid": flipCard.guid
	};
	
	[self sendRequest:@"gameplay/flipPortal" params:dict completionHandler:^(id responseObj) {
		//NSLog(@"flipPortal responseObj: %@", responseObj);

		dispatch_async(dispatch_get_main_queue(), ^{
			handler(responseObj[@"error"]);
		});

	}];
	
}

- (void)setPortalDetailsForCurationWithParams:(NSDictionary *)params completionHandler:(void (^)(NSString *errorStr))handler {
	
	[self sendRequest:@"playerUndecorated/setPortalDetailsForCuration" params:@[params] completionHandler:^(id responseObj) {
		//NSLog(@"setPortalDetailsForCuration responseObj: %@", responseObj);
		
		dispatch_async(dispatch_get_main_queue(), ^{
			handler(responseObj[@"error"]);
		});
		
	}];
	
}

- (void)getUploadUrl:(void (^)(NSString *url))handler {
	
	[self sendRequest:@"playerUndecorated/getUploadUrl" params:nil completionHandler:^(id responseObj) {
		//NSLog(@"getUploadUrl responseObj: %@", responseObj);
		
		dispatch_async(dispatch_get_main_queue(), ^{
			handler(responseObj[@"result"]);
		});
		
	}];
	
}

- (void)uploadPortalPhotoByUrlWithRequestId:(NSString *)requestId imageUrl:(NSString *)imageUrl completionHandler:(void (^)(NSString *errorStr))handler {
	
	NSDictionary *dict = @{
		@"requestId": requestId,
		@"imageUrl": imageUrl,
		@"portalGuid": [NSNull null],
		@"addDirectlyToGame": @(NO)
	};
	
	[self sendRequest:@"playerUndecorated/uploadPortalPhotoByUrl" params:@[dict] completionHandler:^(id responseObj) {
		//NSLog(@"uploadPortalPhotoByUrl responseObj: %@", responseObj);
		
		dispatch_async(dispatch_get_main_queue(), ^{
			handler(responseObj[@"error"]);
		});
		
	}];
	
}

- (void)uploadPortalImage:(UIImage *)image toURL:(NSString *)url completionHandler:(void (^)(void))handler {
	
	NSData *imageData = UIImageJPEGRepresentation(image, .85);
		
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
	
	[request setHTTPMethod:@"PUT"];
	
	NSDictionary *headers = @{
		 @"Content-Type" : @"application/x-www-form-urlencoded",
		 @"x-goog-api-version" : @"2",
		 @"Accept-Encoding" : @"gzip",
		 @"User-Agent" : @"Dalvik/1.6.0 (Linux; U; Android 4.1.1;",
		 @"Host" : @"ingress-incoming.storage.googleapis.com",
		 @"Connection" : @"Keep-Alive",
		 @"Content-Length" : [NSString stringWithFormat:@"%d", imageData.length],
	};
	
	[request setAllHTTPHeaderFields:headers];
	
	[request setHTTPBody:imageData];
	
	[self incrementNetworkActivityCount];
	[NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue new] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
		
		[self decrementNetworkActivityCount];
		
		if (error) { NSLog(@"NSURLConnection error: %@", error); }
		
		//NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
		//NSLog(@"uploadPortalImage => %d -- %@ -- %@", httpResponse.statusCode, httpResponse.allHeaderFields, [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
		
		if (handler) {
			handler();
		}
		
	}];
	
}

- (void)findNearbyPortalsWithCompletionHandler:(void (^)(NSArray *portals))handler {
	
	NSDictionary *dict = @{
		@"continuationToken": [NSNull null],
		@"maxPortals": @(1)
	};
	
	[self sendRequest:@"gameplay/findNearbyPortals" params:dict completionHandler:^(id responseObj) {
		//NSLog(@"findNearbyPortals responseObj: %@", responseObj);
		
		NSArray *portals = responseObj[@"result"];
		NSMutableArray *portalsToReturn = [NSMutableArray arrayWithCapacity:portals.count];
		
		for (NSArray *portal in portals) {

			NSDictionary *portalDict = @{
				@"guid": portal[0],
				@"location": [[CLLocation alloc] initWithLatitude:[portal[2][@"locationE6"][@"latE6"] intValue]/1E6 longitude:[portal[2][@"locationE6"][@"lngE6"] intValue]/1E6],
				@"controllingTeam": portal[2][@"controllingTeam"][@"team"],
				@"imageURL": EMPTYIFNIL(portal[2][@"imageByUrl"][@"imageUrl"]),
				@"name": EMPTYIFNIL(portal[2][@"portalV2"][@"descriptiveText"][@"TITLE"]),
				@"address": EMPTYIFNIL(portal[2][@"portalV2"][@"descriptiveText"][@"ADDRESS"])
			};
			
			[portalsToReturn addObject:portalDict];
			
		}
		
		dispatch_async(dispatch_get_main_queue(), ^{
			handler(portalsToReturn);
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

		mutableParams[@"knobSyncTimestamp"] = @(self.currentTimestamp);
		mutableParams[@"playerLocation"] = self.currentE6Location;
		mutableParams[@"location"] = self.currentE6Location;

		NSMutableArray *collectedEnergyGuids = [NSMutableArray array];
		for (EnergyGlob *energyGlob in self.energyToCollect) {
			if (energyGlob.guid) {
				[collectedEnergyGuids addObject:energyGlob.guid];
			}
		}
		mutableParams[@"energyGlobGuids"] = collectedEnergyGuids;
		[self.energyToCollect removeAllObjects];

		params = mutableParams;
		
		if (collectedEnergyGuids.count > 0) {
            if ([[NSUserDefaults standardUserDefaults] boolForKey:DeviceSoundToggleEffects]) {
                [[API sharedInstance] playSound:@"SFX_XM_PICKUP"];
            }
		}
		
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
	
	[self incrementNetworkActivityCount];
	[NSURLConnection sendAsynchronousRequest:request queue:self.networkQueue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
		
		[self decrementNetworkActivityCount];
		
		if (error) { NSLog(@"NSURLConnection error: %@", error); }

        if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*)response;
            if ([httpResponse statusCode] == 500) {
                NSDictionary *responseObj = @{ @"error": @"SERVER_ERROR" };
                handler(responseObj);
                return;
            }
        }

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
			[self processGameBasket:gameBasket completion:^(BOOL success, NSError *error) {
				if (handler) {
					dispatch_async(dispatch_get_main_queue(), ^{
						handler(responseObj);
					});
				}
			}];
		} else {
			if (handler) {
				dispatch_async(dispatch_get_main_queue(), ^{
					handler(responseObj);
				});
			}
		}

	}];
	
}

#pragma mark - Process Game Basket

- (void)processGameBasket:(NSDictionary *)gameBasket completion:(MRSaveCompletionHandler)completion {
	//NSLog(@"processGameBasket: %@", gameBasket);
	
	[MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {

		NSArray *inventory = gameBasket[@"inventory"];
		if (inventory && inventory.count > 0) { [self processInventory:inventory context:localContext]; }

		NSArray *gameEntities = gameBasket[@"gameEntities"];
		if (gameEntities && gameEntities.count > 0) { [self processGameEntities:gameEntities context:localContext]; }

		NSArray *playerEntity = gameBasket[@"playerEntity"];
		if (playerEntity && playerEntity.count > 0) { [self processPlayerEntity:playerEntity context:localContext]; }

		NSArray *energyGlobGuids = gameBasket[@"energyGlobGuids"];
		if (energyGlobGuids && energyGlobGuids.count > 0) { [self processEnergyGlobGuids:energyGlobGuids context:localContext]; }

		NSArray *deletedEntityGuids = gameBasket[@"deletedEntityGuids"];
		if (deletedEntityGuids && deletedEntityGuids.count > 0) { [self processDeletedEntityGuids:deletedEntityGuids context:localContext]; }

		NSArray *apGains = gameBasket[@"apGains"];
		if (apGains && apGains.count > 0) { [self processAPGains:apGains]; }

		NSArray *playerDamages = gameBasket[@"playerDamages"];
		if (playerDamages && playerDamages.count > 0) { [self processPlayerDamages:playerDamages]; }

	} completion:^(BOOL success, NSError *error) {

		[[NSNotificationCenter defaultCenter] postNotificationName:@"DBUpdatedNotification" object:nil];

		completion(success, error);
		
	}];

}

- (void)processInventory:(NSArray *)inventory context:(NSManagedObjectContext *)context {
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
			Resonator *resonator = [Resonator MR_findFirstByAttribute:@"guid" withValue:item[0] inContext:context];
			if (!resonator) {
				resonator = [Resonator MR_createInContext:context];
				resonator.guid = item[0];
			}
			resonator.level = [item[2][@"resourceWithLevels"][@"level"] integerValue];
			resonator.timestamp = [[NSDate dateWithTimeIntervalSince1970:([item[1] doubleValue]/1000.)] timeIntervalSinceReferenceDate];
		} else if ([resourceType isEqualToString:@"EMP_BURSTER"]) {
			XMP *xmp = [XMP MR_findFirstByAttribute:@"guid" withValue:item[0] inContext:context];
			if (!xmp) {
				xmp = [XMP MR_createInContext:context];
				xmp.guid = item[0];
			}
			xmp.level = [item[2][@"resourceWithLevels"][@"level"] integerValue];
			xmp.timestamp = [[NSDate dateWithTimeIntervalSince1970:([item[1] doubleValue]/1000.)] timeIntervalSinceReferenceDate];
		} else if ([resourceType isEqualToString:@"RES_SHIELD"]) {
			Shield *shield = [Shield MR_findFirstByAttribute:@"guid" withValue:item[0] inContext:context];
			if (!shield) {
				shield = [Shield MR_createInContext:context];
				shield.guid = item[0];
			}
			shield.rarity = [Utilities rarityFromString:item[2][@"modResource"][@"rarity"]];
			shield.timestamp = [[NSDate dateWithTimeIntervalSince1970:([item[1] doubleValue]/1000.)] timeIntervalSinceReferenceDate];
		} else if ([resourceType isEqualToString:@"FORCE_AMP"]) {
			ForceAmp *forceAmp = [Shield MR_findFirstByAttribute:@"guid" withValue:item[0] inContext:context];
			if (!forceAmp) {
				forceAmp = [ForceAmp MR_createInContext:context];
				forceAmp.guid = item[0];
			}
			forceAmp.rarity = [Utilities rarityFromString:item[2][@"modResource"][@"rarity"]];
			forceAmp.timestamp = [[NSDate dateWithTimeIntervalSince1970:([item[1] doubleValue]/1000.)] timeIntervalSinceReferenceDate];
		} else if ([resourceType isEqualToString:@"HEATSINK"]) {
			Heatsink *heatsink = [Shield MR_findFirstByAttribute:@"guid" withValue:item[0] inContext:context];
			if (!heatsink) {
				heatsink = [Heatsink MR_createInContext:context];
				heatsink.guid = item[0];
			}
			heatsink.rarity = [Utilities rarityFromString:item[2][@"modResource"][@"rarity"]];
			heatsink.timestamp = [[NSDate dateWithTimeIntervalSince1970:([item[1] doubleValue]/1000.)] timeIntervalSinceReferenceDate];
		} else if ([resourceType isEqualToString:@"LINK_AMPLIFIER"]) {
			LinkAmp *linkAmp = [Shield MR_findFirstByAttribute:@"guid" withValue:item[0] inContext:context];
			if (!linkAmp) {
				linkAmp = [LinkAmp MR_createInContext:context];
				linkAmp.guid = item[0];
			}
			linkAmp.rarity = [Utilities rarityFromString:item[2][@"modResource"][@"rarity"]];
			linkAmp.timestamp = [[NSDate dateWithTimeIntervalSince1970:([item[1] doubleValue]/1000.)] timeIntervalSinceReferenceDate];
		} else if ([resourceType isEqualToString:@"MULTIHACK"]) {
			Multihack *multihack = [Shield MR_findFirstByAttribute:@"guid" withValue:item[0] inContext:context];
			if (!multihack) {
				multihack = [Multihack MR_createInContext:context];
				multihack.guid = item[0];
			}
			multihack.rarity = [Utilities rarityFromString:item[2][@"modResource"][@"rarity"]];
			multihack.timestamp = [[NSDate dateWithTimeIntervalSince1970:([item[1] doubleValue]/1000.)] timeIntervalSinceReferenceDate];
		} else if ([resourceType isEqualToString:@"TURRET"]) {
			Turret *turret = [Shield MR_findFirstByAttribute:@"guid" withValue:item[0] inContext:context];
			if (!turret) {
				turret = [Turret MR_createInContext:context];
				turret.guid = item[0];
			}
			turret.rarity = [Utilities rarityFromString:item[2][@"modResource"][@"rarity"]];
			turret.timestamp = [[NSDate dateWithTimeIntervalSince1970:([item[1] doubleValue]/1000.)] timeIntervalSinceReferenceDate];
		} else if ([resourceType isEqualToString:@"PORTAL_LINK_KEY"]) {
			Portal *portal = [Portal MR_findFirstByAttribute:@"guid" withValue:item[2][@"portalCoupler"][@"portalGuid"] inContext:context];
			if (!portal) {
				portal = [Portal MR_createInContext:context];
				portal.guid = item[2][@"portalCoupler"][@"portalGuid"];
			}
			portal.imageURL = item[2][@"portalCoupler"][@"portalImageUrl"];
			portal.name = item[2][@"portalCoupler"][@"portalTitle"];
			portal.address = item[2][@"portalCoupler"][@"portalAddress"];
			portal.timestamp = [[NSDate dateWithTimeIntervalSince1970:([item[1] doubleValue]/1000.)] timeIntervalSinceReferenceDate];

			unsigned int latitude;
			unsigned int longitude;
			NSArray *E6location = [item[2][@"portalCoupler"][@"portalLocation"] componentsSeparatedByString:@","];
			NSScanner *scanner = [NSScanner scannerWithString:E6location[0]];
			[scanner scanHexInt:&latitude];
			scanner = [NSScanner scannerWithString:E6location[1]];
			[scanner scanHexInt:&longitude];
			portal.latitude = latitude/1E6;
			portal.longitude = longitude/1E6;
			
			PortalKey *portalKey = [PortalKey MR_findFirstByAttribute:@"guid" withValue:item[0] inContext:context];
			if (!portalKey) {
				portalKey = [PortalKey MR_createInContext:context];
				portalKey.guid = item[0];
			}
			portalKey.portal = portal;
			portalKey.portalGuid = item[2][@"portalCoupler"][@"portalGuid"];
			portalKey.timestamp = [[NSDate dateWithTimeIntervalSince1970:([item[1] doubleValue]/1000.)] timeIntervalSinceReferenceDate];
		} else if ([resourceType isEqualToString:@"MEDIA"]) {
			Media *media = [Media MR_findFirstByAttribute:@"guid" withValue:item[0] inContext:context];
			if (!media) {
				media = [Media MR_createInContext:context];
				media.guid = item[0];
			}
			media.name = item[2][@"storyItem"][@"shortDescription"];
			media.url = item[2][@"storyItem"][@"primaryUrl"];
			media.level = [item[2][@"resourceWithLevels"][@"level"] integerValue];
			media.imageURL = item[2][@"imageByUrl"][@"imageUrl"];
			media.timestamp = [[NSDate dateWithTimeIntervalSince1970:([item[1] doubleValue]/1000.)] timeIntervalSinceReferenceDate];
		} else if ([resourceType isEqualToString:@"POWER_CUBE"]) {
			PowerCube *powerCube = [PowerCube MR_findFirstByAttribute:@"guid" withValue:item[0] inContext:context];
			if (!powerCube) {
				powerCube = [PowerCube MR_createInContext:context];
				powerCube.guid = item[0];
			}
			powerCube.level = [item[2][@"resourceWithLevels"][@"level"] integerValue];
			powerCube.timestamp = [[NSDate dateWithTimeIntervalSince1970:([item[1] doubleValue]/1000.)] timeIntervalSinceReferenceDate];
		} else if ([resourceType isEqualToString:@"FLIP_CARD"]) {
			FlipCard *flipCard = [FlipCard MR_findFirstByAttribute:@"guid" withValue:item[0] inContext:context];
			if (!flipCard) {
				flipCard = [FlipCard MR_createInContext:context];
				flipCard.guid = item[0];
			}
			flipCard.type = item[2][@"flipCard"][@"flipCardType"];
			flipCard.timestamp = [[NSDate dateWithTimeIntervalSince1970:([item[1] doubleValue]/1000.)] timeIntervalSinceReferenceDate];
		} else {
			NSLog(@"Unknown Item");
			Item *itemObj = [Item MR_findFirstByAttribute:@"guid" withValue:item[0] inContext:context];
			if (!itemObj) {
				itemObj = [Item MR_createInContext:context];
				itemObj.guid = item[0];
			}
			itemObj.timestamp = [[NSDate dateWithTimeIntervalSince1970:([item[1] doubleValue]/1000.)] timeIntervalSinceReferenceDate];
		}

	}
	
}

- (void)processGameEntities:(NSArray *)gameEntities context:(NSManagedObjectContext *)context {
	//NSLog(@"processGameEntities: %@", gameEntities);

	for (NSArray *gameEntity in gameEntities) {

		NSDictionary *loc = gameEntity[2][@"locationE6"];
		
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

		if (loc && gameEntity[2][@"portalV2"]) {

			Portal *portal = [Portal MR_findFirstByAttribute:@"guid" withValue:gameEntity[0] inContext:context];
			if (!portal) {
				portal = [Portal MR_createInContext:context];
				portal.guid = gameEntity[0];
			}
			portal.latitude = [loc[@"latE6"] intValue]/1E6;
			portal.longitude = [loc[@"lngE6"] intValue]/1E6;
			portal.controllingTeam = gameEntity[2][@"controllingTeam"][@"team"];
			portal.imageURL = gameEntity[2][@"imageByUrl"][@"imageUrl"];
			portal.name = gameEntity[2][@"portalV2"][@"descriptiveText"][@"TITLE"];
			portal.address = gameEntity[2][@"portalV2"][@"descriptiveText"][@"ADDRESS"];
			portal.completeInfo = YES;
			portal.timestamp = [[NSDate dateWithTimeIntervalSince1970:([gameEntity[1] doubleValue]/1000.)] timeIntervalSinceReferenceDate];

			User *creator = [User MR_findFirstByAttribute:@"guid" withValue:gameEntity[2][@"captured"][@"capturingPlayerId"] inContext:context];
			if (!creator) {
				creator = [User MR_createInContext:context];
				creator.guid = gameEntity[2][@"captured"][@"capturingPlayerId"];
			}
			portal.capturedBy = creator;

			for (int i = 0; i < 8; i++) {

				NSDictionary *resonatorDict = gameEntity[2][@"resonatorArray"][@"resonators"][i];

				DeployedResonator *resonator = [DeployedResonator MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"portal.guid = %@ && slot = %d", portal.guid, i] inContext:context];

				if ([resonatorDict isKindOfClass:[NSNull class]]) {
					if (resonator) {
						[resonator MR_deleteInContext:context];
					}
				} else {
					
					if (!resonator) {
						[DeployedResonator resonatorWithData:resonatorDict forPortal:portal context:context];
					} else {
						[resonator updateWithData:resonatorDict forPortal:portal context:context];
					}

				}

			}

			for (int i = 0; i < 4; i++) {

				NSDictionary *modDict = gameEntity[2][@"portalV2"][@"linkedModArray"][i];

				if ([modDict isKindOfClass:[NSNull class]]) {
					DeployedMod *mod = [DeployedMod MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"portal = %@ && slot = %d", portal, i] inContext:context];
					if (mod) {
						[mod MR_deleteInContext:context];
					}

				} else {

					if ([modDict[@"type"] isEqualToString:@"RES_SHIELD"]) {

						DeployedShield *shield = [DeployedShield MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"portal = %@ && slot = %d", portal, i] inContext:context];

						if (!shield) { shield = [DeployedShield MR_createInContext:context]; }
						shield.portal = portal;
						shield.slot = i;
						shield.mitigation = [modDict[@"stats"][@"MITIGATION"] intValue];
						shield.rarity = [Utilities rarityFromString:modDict[@"rarity"]];

						User *owner = [User MR_findFirstByAttribute:@"guid" withValue:modDict[@"installingUser"] inContext:context];
						if (!owner) {
							owner = [User MR_createInContext:context];
							owner.guid = modDict[@"installingUser"];
						}
						shield.owner = owner;

					} else if ([modDict[@"type"] isEqualToString:@"FORCE_AMP"]) {

						DeployedForceAmp *forceAmp = [DeployedForceAmp MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"portal = %@ && slot = %d", portal, i] inContext:context];

						if (!forceAmp) { forceAmp = [DeployedForceAmp MR_createInContext:context]; }
						forceAmp.portal = portal;
						forceAmp.slot = i;
						forceAmp.rarity = [Utilities rarityFromString:modDict[@"rarity"]];

						User *owner = [User MR_findFirstByAttribute:@"guid" withValue:modDict[@"installingUser"] inContext:context];
						if (!owner) {
							owner = [User MR_createInContext:context];
							owner.guid = modDict[@"installingUser"];
						}
						forceAmp.owner = owner;
						
					} else if ([modDict[@"type"] isEqualToString:@"HEATSINK"]) {

						DeployedHeatsink *heatsink = [DeployedHeatsink MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"portal = %@ && slot = %d", portal, i] inContext:context];

						if (!heatsink) { heatsink = [DeployedHeatsink MR_createInContext:context]; }
						heatsink.portal = portal;
						heatsink.slot = i;
						heatsink.rarity = [Utilities rarityFromString:modDict[@"rarity"]];

						User *owner = [User MR_findFirstByAttribute:@"guid" withValue:modDict[@"installingUser"] inContext:context];
						if (!owner) {
							owner = [User MR_createInContext:context];
							owner.guid = modDict[@"installingUser"];
						}
						heatsink.owner = owner;
						
					} else if ([modDict[@"type"] isEqualToString:@"LINK_AMPLIFIER"]) {

						DeployedLinkAmp *linkAmp = [DeployedLinkAmp MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"portal = %@ && slot = %d", portal, i] inContext:context];

						if (!linkAmp) { linkAmp = [DeployedLinkAmp MR_createInContext:context]; }
						linkAmp.portal = portal;
						linkAmp.slot = i;
						linkAmp.rarity = [Utilities rarityFromString:modDict[@"rarity"]];

						User *owner = [User MR_findFirstByAttribute:@"guid" withValue:modDict[@"installingUser"] inContext:context];
						if (!owner) {
							owner = [User MR_createInContext:context];
							owner.guid = modDict[@"installingUser"];
						}
						linkAmp.owner = owner;
						
					} else if ([modDict[@"type"] isEqualToString:@"MULTIHACK"]) {

						DeployedMultihack *multihack = [DeployedMultihack MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"portal = %@ && slot = %d", portal, i] inContext:context];

						if (!multihack) { multihack = [DeployedMultihack MR_createInContext:context]; }
						multihack.portal = portal;
						multihack.slot = i;
						multihack.rarity = [Utilities rarityFromString:modDict[@"rarity"]];

						User *owner = [User MR_findFirstByAttribute:@"guid" withValue:modDict[@"installingUser"] inContext:context];
						if (!owner) {
							owner = [User MR_createInContext:context];
							owner.guid = modDict[@"installingUser"];
						}
						multihack.owner = owner;
						
					} else if ([modDict[@"type"] isEqualToString:@"TURRET"]) {

						DeployedTurret *turret = [DeployedTurret MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"portal = %@ && slot = %d", portal, i] inContext:context];

						if (!turret) { turret = [DeployedTurret MR_createInContext:context]; }
						turret.portal = portal;
						turret.slot = i;
						turret.rarity = [Utilities rarityFromString:modDict[@"rarity"]];

						User *owner = [User MR_findFirstByAttribute:@"guid" withValue:modDict[@"installingUser"] inContext:context];
						if (!owner) {
							owner = [User MR_createInContext:context];
							owner.guid = modDict[@"installingUser"];
						}
						turret.owner = owner;

					} else {
						NSLog(@"Unknown Mod");
					}

				}

			}

		} else if (loc && resourceType) {

			//NSLog(@"Dropped resourceType: %@", resourceType);

			if ([resourceType isEqualToString:@"EMITTER_A"]) {
				Resonator *resonator = [Resonator MR_findFirstByAttribute:@"guid" withValue:gameEntity[0] inContext:context];
				if (!resonator) {
					resonator = [Resonator MR_createInContext:context];
					resonator.guid = gameEntity[0];
				}
				resonator.dropped = YES;
				resonator.latitude = [loc[@"latE6"] intValue]/1E6;
				resonator.longitude = [loc[@"lngE6"] intValue]/1E6;
				resonator.level = [gameEntity[2][@"resourceWithLevels"][@"level"] integerValue];
				resonator.timestamp = [[NSDate dateWithTimeIntervalSince1970:([gameEntity[1] doubleValue]/1000.)] timeIntervalSinceReferenceDate];
			} else if ([resourceType isEqualToString:@"EMP_BURSTER"]) {
				XMP *xmp = [XMP MR_findFirstByAttribute:@"guid" withValue:gameEntity[0] inContext:context];
				if (!xmp) {
					xmp = [XMP MR_createInContext:context];
					xmp.guid = gameEntity[0];
				}
				xmp.dropped = YES;
				xmp.latitude = [loc[@"latE6"] intValue]/1E6;
				xmp.longitude = [loc[@"lngE6"] intValue]/1E6;
				xmp.level = [gameEntity[2][@"resourceWithLevels"][@"level"] integerValue];
				xmp.timestamp = [[NSDate dateWithTimeIntervalSince1970:([gameEntity[1] doubleValue]/1000.)] timeIntervalSinceReferenceDate];
			} else if ([resourceType isEqualToString:@"RES_SHIELD"]) {
				Shield *shield = [Shield MR_findFirstByAttribute:@"guid" withValue:gameEntity[0] inContext:context];
				if (!shield) {
					shield = [Shield MR_createInContext:context];
					shield.guid = gameEntity[0];
				}
				shield.dropped = YES;
				shield.latitude = [loc[@"latE6"] intValue]/1E6;
				shield.longitude = [loc[@"lngE6"] intValue]/1E6;
				shield.rarity = [Utilities rarityFromString:gameEntity[2][@"modResource"][@"rarity"]];
				shield.timestamp = [[NSDate dateWithTimeIntervalSince1970:([gameEntity[1] doubleValue]/1000.)] timeIntervalSinceReferenceDate];
			} else if ([resourceType isEqualToString:@"FORCE_AMP"]) {
				ForceAmp *forceAmp = [Shield MR_findFirstByAttribute:@"guid" withValue:gameEntity[0] inContext:context];
				if (!forceAmp) {
					forceAmp = [ForceAmp MR_createInContext:context];
					forceAmp.guid = gameEntity[0];
				}
				forceAmp.dropped = YES;
				forceAmp.latitude = [loc[@"latE6"] intValue]/1E6;
				forceAmp.longitude = [loc[@"lngE6"] intValue]/1E6;
				forceAmp.rarity = [Utilities rarityFromString:gameEntity[2][@"modResource"][@"rarity"]];
				forceAmp.timestamp = [[NSDate dateWithTimeIntervalSince1970:([gameEntity[1] doubleValue]/1000.)] timeIntervalSinceReferenceDate];
			} else if ([resourceType isEqualToString:@"HEATSINK"]) {
				Heatsink *heatsink = [Shield MR_findFirstByAttribute:@"guid" withValue:gameEntity[0] inContext:context];
				if (!heatsink) {
					heatsink = [Heatsink MR_createInContext:context];
					heatsink.guid = gameEntity[0];
				}
				heatsink.dropped = YES;
				heatsink.latitude = [loc[@"latE6"] intValue]/1E6;
				heatsink.longitude = [loc[@"lngE6"] intValue]/1E6;
				heatsink.rarity = [Utilities rarityFromString:gameEntity[2][@"modResource"][@"rarity"]];
				heatsink.timestamp = [[NSDate dateWithTimeIntervalSince1970:([gameEntity[1] doubleValue]/1000.)] timeIntervalSinceReferenceDate];
			} else if ([resourceType isEqualToString:@"LINK_AMPLIFIER"]) {
				LinkAmp *linkAmp = [Shield MR_findFirstByAttribute:@"guid" withValue:gameEntity[0] inContext:context];
				if (!linkAmp) {
					linkAmp = [LinkAmp MR_createInContext:context];
					linkAmp.guid = gameEntity[0];
				}
				linkAmp.dropped = YES;
				linkAmp.latitude = [loc[@"latE6"] intValue]/1E6;
				linkAmp.longitude = [loc[@"lngE6"] intValue]/1E6;
				linkAmp.rarity = [Utilities rarityFromString:gameEntity[2][@"modResource"][@"rarity"]];
				linkAmp.timestamp = [[NSDate dateWithTimeIntervalSince1970:([gameEntity[1] doubleValue]/1000.)] timeIntervalSinceReferenceDate];
			} else if ([resourceType isEqualToString:@"MULTIHACK"]) {
				Multihack *multihack = [Shield MR_findFirstByAttribute:@"guid" withValue:gameEntity[0] inContext:context];
				if (!multihack) {
					multihack = [Multihack MR_createInContext:context];
					multihack.guid = gameEntity[0];
				}
				multihack.dropped = YES;
				multihack.latitude = [loc[@"latE6"] intValue]/1E6;
				multihack.longitude = [loc[@"lngE6"] intValue]/1E6;
				multihack.rarity = [Utilities rarityFromString:gameEntity[2][@"modResource"][@"rarity"]];
				multihack.timestamp = [[NSDate dateWithTimeIntervalSince1970:([gameEntity[1] doubleValue]/1000.)] timeIntervalSinceReferenceDate];
			} else if ([resourceType isEqualToString:@"TURRET"]) {
				Turret *turret = [Shield MR_findFirstByAttribute:@"guid" withValue:gameEntity[0] inContext:context];
				if (!turret) {
					turret = [Turret MR_createInContext:context];
					turret.guid = gameEntity[0];
				}
				turret.dropped = YES;
				turret.latitude = [loc[@"latE6"] intValue]/1E6;
				turret.longitude = [loc[@"lngE6"] intValue]/1E6;
				turret.rarity = [Utilities rarityFromString:gameEntity[2][@"modResource"][@"rarity"]];
				turret.timestamp = [[NSDate dateWithTimeIntervalSince1970:([gameEntity[1] doubleValue]/1000.)] timeIntervalSinceReferenceDate];
			} else if ([resourceType isEqualToString:@"PORTAL_LINK_KEY"]) {
				Portal *portal = [Portal MR_findFirstByAttribute:@"guid" withValue:gameEntity[2][@"portalCoupler"][@"portalGuid"] inContext:context];
				if (!portal) {
					portal = [Portal MR_createInContext:context];
					portal.guid = gameEntity[2][@"portalCoupler"][@"portalGuid"];
				}
				portal.imageURL = gameEntity[2][@"portalCoupler"][@"portalImageUrl"];
				portal.name = gameEntity[2][@"portalCoupler"][@"portalTitle"];
				portal.address = gameEntity[2][@"portalCoupler"][@"portalAddress"];
				portal.timestamp = [[NSDate dateWithTimeIntervalSince1970:([gameEntity[1] doubleValue]/1000.)] timeIntervalSinceReferenceDate];

				unsigned int latitude;
				unsigned int longitude;
				NSArray *E6location = [gameEntity[2][@"portalCoupler"][@"portalLocation"] componentsSeparatedByString:@","];
				NSScanner *scanner = [NSScanner scannerWithString:E6location[0]];
				[scanner scanHexInt:&latitude];
				scanner = [NSScanner scannerWithString:E6location[1]];
				[scanner scanHexInt:&longitude];
				portal.latitude = latitude/1E6;
				portal.longitude = longitude/1E6;

				PortalKey *portalKey = [PortalKey MR_findFirstByAttribute:@"guid" withValue:gameEntity[0] inContext:context];
				if (!portalKey) {
					portalKey = [PortalKey MR_createInContext:context];
					portalKey.guid = gameEntity[0];
				}
				portalKey.dropped = YES;
				portalKey.latitude = [loc[@"latE6"] intValue]/1E6;
				portalKey.longitude = [loc[@"lngE6"] intValue]/1E6;
				portalKey.portal = portal;
				portalKey.timestamp = [[NSDate dateWithTimeIntervalSince1970:([gameEntity[1] doubleValue]/1000.)] timeIntervalSinceReferenceDate];
			} else if ([resourceType isEqualToString:@"MEDIA"]) {
				Media *media = [Media MR_findFirstByAttribute:@"guid" withValue:gameEntity[0] inContext:context];
				if (!media) {
					media = [Media MR_createInContext:context];
					media.guid = gameEntity[0];
				}
				media.dropped = YES;
				media.latitude = [loc[@"latE6"] intValue]/1E6;
				media.longitude = [loc[@"lngE6"] intValue]/1E6;
				media.name = gameEntity[2][@"storyItem"][@"shortDescription"];
				media.url = gameEntity[2][@"storyItem"][@"primaryUrl"];
				media.level = [gameEntity[2][@"resourceWithLevels"][@"level"] integerValue];
				media.imageURL = gameEntity[2][@"imageByUrl"][@"imageUrl"];
				media.timestamp = [[NSDate dateWithTimeIntervalSince1970:([gameEntity[1] doubleValue]/1000.)] timeIntervalSinceReferenceDate];
			} else if ([resourceType isEqualToString:@"POWER_CUBE"]) {
				PowerCube *powerCube = [PowerCube MR_findFirstByAttribute:@"guid" withValue:gameEntity[0] inContext:context];
				if (!powerCube) {
					powerCube = [PowerCube MR_createInContext:context];
					powerCube.guid = gameEntity[0];
				}
				powerCube.dropped = YES;
				powerCube.latitude = [loc[@"latE6"] intValue]/1E6;
				powerCube.longitude = [loc[@"lngE6"] intValue]/1E6;
				powerCube.level = [gameEntity[2][@"resourceWithLevels"][@"level"] integerValue];
				powerCube.timestamp = [[NSDate dateWithTimeIntervalSince1970:([gameEntity[1] doubleValue]/1000.)] timeIntervalSinceReferenceDate];
			} else if ([resourceType isEqualToString:@"FLIP_CARD"]) {
				FlipCard *flipCard = [FlipCard MR_findFirstByAttribute:@"guid" withValue:gameEntity[0] inContext:context];
				if (!flipCard) {
					flipCard = [FlipCard MR_createInContext:context];
					flipCard.guid = gameEntity[0];
				}
				flipCard.dropped = YES;
				flipCard.latitude = [loc[@"latE6"] intValue]/1E6;
				flipCard.longitude = [loc[@"lngE6"] intValue]/1E6;
				flipCard.type = gameEntity[2][@"flipCard"][@"flipCardType"];
				flipCard.timestamp = [[NSDate dateWithTimeIntervalSince1970:([gameEntity[1] doubleValue]/1000.)] timeIntervalSinceReferenceDate];
			} else {
				NSLog(@"Unknown Dropped Item");
				Item *itemObj = [Item MR_findFirstByAttribute:@"guid" withValue:gameEntity[0] inContext:context];
				if (!itemObj) {
					itemObj = [Item MR_createInContext:context];
					itemObj.guid = gameEntity[0];
				}
				itemObj.dropped = YES;
				itemObj.latitude = [loc[@"latE6"] intValue]/1E6;
				itemObj.longitude = [loc[@"lngE6"] intValue]/1E6;
				itemObj.timestamp = [[NSDate dateWithTimeIntervalSince1970:([gameEntity[1] doubleValue]/1000.)] timeIntervalSinceReferenceDate];
			}

		} else if (gameEntity[2][@"edge"]) {
			//NSLog(@"link: %@", gameEntity[0]);

			PortalLink *portalLink = [PortalLink MR_findFirstByAttribute:@"guid" withValue:gameEntity[0] inContext:context];
			if (!portalLink) {
				portalLink = [PortalLink MR_createInContext:context];
				portalLink.guid = gameEntity[0];
			}
			portalLink.controllingTeam = gameEntity[2][@"controllingTeam"][@"team"];

			User *creator = [User MR_findFirstByAttribute:@"guid" withValue:gameEntity[2][@"creator"][@"creatorGuid"] inContext:context];
			if (!creator) {
				creator = [User MR_createInContext:context];
				creator.guid = gameEntity[2][@"creator"][@"creatorGuid"];
			}
			portalLink.creator = creator;

			Portal *destinationPortal = [Portal MR_findFirstByAttribute:@"guid" withValue:gameEntity[2][@"edge"][@"destinationPortalGuid"] inContext:context];
			if (!destinationPortal) {
				destinationPortal = [Portal MR_createInContext:context];
				destinationPortal.guid = gameEntity[2][@"edge"][@"destinationPortalGuid"];
			}
			destinationPortal.controllingTeam = gameEntity[2][@"controllingTeam"][@"team"];
			destinationPortal.latitude = [gameEntity[2][@"edge"][@"destinationPortalLocation"][@"latE6"] intValue]/1E6;
			destinationPortal.longitude = [gameEntity[2][@"edge"][@"destinationPortalLocation"][@"lngE6"] intValue]/1E6;
			portalLink.destinationPortal = destinationPortal;

			Portal *originPortal = [Portal MR_findFirstByAttribute:@"guid" withValue:gameEntity[2][@"edge"][@"originPortalGuid"] inContext:context];
			if (!originPortal) {
				originPortal = [Portal MR_createInContext:context];
				originPortal.guid = gameEntity[2][@"edge"][@"originPortalGuid"];
			}
			originPortal.controllingTeam = gameEntity[2][@"controllingTeam"][@"team"];
			originPortal.latitude = [gameEntity[2][@"edge"][@"originPortalLocation"][@"latE6"] intValue]/1E6;
			originPortal.longitude = [gameEntity[2][@"edge"][@"originPortalLocation"][@"lngE6"] intValue]/1E6;
			portalLink.originPortal = originPortal;

		} else if (gameEntity[2][@"capturedRegion"]) {
			//NSLog(@"capturedRegion: %@", gameEntity[0]);

			ControlField *controlField = [ControlField MR_findFirstByAttribute:@"guid" withValue:gameEntity[0] inContext:context];
			if (!controlField) {
				controlField = [ControlField MR_createInContext:context];
				controlField.guid = gameEntity[0];
			}
			controlField.controllingTeam = gameEntity[2][@"controllingTeam"][@"team"];
			controlField.entityScore = [gameEntity[2][@"entityScore"][@"entityScore"] intValue];

			User *creator = [User MR_findFirstByAttribute:@"guid" withValue:gameEntity[2][@"creator"][@"creatorGuid"] inContext:context];
			if (!creator) {
				creator = [User MR_createInContext:context];
				creator.guid = gameEntity[2][@"creator"][@"creatorGuid"];
			}
			controlField.creator = creator;

			Portal *portalA = [Portal MR_findFirstByAttribute:@"guid" withValue:gameEntity[2][@"capturedRegion"][@"vertexA"][@"guid"] inContext:context];
			if (!portalA) {
				portalA = [Portal MR_createInContext:context];
				portalA.guid = gameEntity[2][@"capturedRegion"][@"vertexA"][@"guid"];
			}
			portalA.controllingTeam = gameEntity[2][@"controllingTeam"][@"team"];
			portalA.latitude = [gameEntity[2][@"capturedRegion"][@"vertexA"][@"location"][@"latE6"] intValue]/1E6;
			portalA.longitude = [gameEntity[2][@"capturedRegion"][@"vertexA"][@"location"][@"lngE6"] intValue]/1E6;
			[controlField addPortalsObject:portalA];

			Portal *portalB = [Portal MR_findFirstByAttribute:@"guid" withValue:gameEntity[2][@"capturedRegion"][@"vertexB"][@"guid"] inContext:context];
			if (!portalB) {
				portalB = [Portal MR_createInContext:context];
				portalB.guid = gameEntity[2][@"capturedRegion"][@"vertexB"][@"guid"];
			}
			portalB.controllingTeam = gameEntity[2][@"controllingTeam"][@"team"];
			portalB.latitude = [gameEntity[2][@"capturedRegion"][@"vertexB"][@"location"][@"latE6"] intValue]/1E6;
			portalB.longitude = [gameEntity[2][@"capturedRegion"][@"vertexB"][@"location"][@"lngE6"] intValue]/1E6;
			[controlField addPortalsObject:portalB];

			Portal *portalC = [Portal MR_findFirstByAttribute:@"guid" withValue:gameEntity[2][@"capturedRegion"][@"vertexC"][@"guid"] inContext:context];
			if (!portalC) {
				portalC = [Portal MR_createInContext:context];
				portalC.guid = gameEntity[2][@"capturedRegion"][@"vertexC"][@"guid"];
			}
			portalC.controllingTeam = gameEntity[2][@"controllingTeam"][@"team"];
			portalC.latitude = [gameEntity[2][@"capturedRegion"][@"vertexC"][@"location"][@"latE6"] intValue]/1E6;
			portalC.longitude = [gameEntity[2][@"capturedRegion"][@"vertexC"][@"location"][@"lngE6"] intValue]/1E6;
			[controlField addPortalsObject:portalC];
			
		}
	}
	
}

- (void)processPlayerEntity:(NSArray *)playerEntity context:(NSManagedObjectContext *)context {
	//NSLog(@"processPlayerEntity");

	Player *player = [self playerForContext:context];

	int oldLevel = player.level;
	int newLevel = [Utilities levelForAp:[playerEntity[2][@"playerPersonal"][@"ap"] intValue]];
	
	if (player.ap != 0 && newLevel > oldLevel) {
        if ([[NSUserDefaults standardUserDefaults] boolForKey:DeviceSoundToggleEffects] && [[NSUserDefaults standardUserDefaults] boolForKey:DeviceSoundToggleSpeech]) {
            [self playSound:@"SFX_PLAYER_LEVEL_UP"];
        }
        
        [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
            
            NSAttributedString *atrstr = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"Level up! You are now level %d.", newLevel] attributes:[Utilities attributesWithShadow:NO size:CHAT_FONT_SIZE color:[UIColor colorWithRed:226./255. green:179./255. blue:76./255. alpha:1.0]]];
            
            Plext *plext = [Plext MR_createInContext:localContext];
            plext.guid = nil;
            plext.message = atrstr;
            plext.factionOnly = NO;
            plext.date = [[NSDate date] timeIntervalSinceReferenceDate];
            plext.mentionsYou = nil;
            plext.sender = nil;
            
        }];
	}

	if (player.energy != [playerEntity[2][@"playerPersonal"][@"energy"] intValue]) {
        if ([[NSUserDefaults standardUserDefaults] boolForKey:DeviceSoundToggleSpeech]) {
            int xmPercent = (int)round(([playerEntity[2][@"playerPersonal"][@"energy"] floatValue]/[Utilities maxXmForLevel:newLevel])*100);
            
            NSMutableArray *sounds = [NSMutableArray arrayWithCapacity:4];
            [sounds addObject:@"SPEECH_XM_LEVELS"];
            [sounds addObjectsFromArray:[API soundsForNumber:xmPercent]];
            [sounds addObject:@"SPEECH_PERCENT"];
            
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC));
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                [self playSounds:sounds];
            });
        }
	}

	player.team = playerEntity[2][@"controllingTeam"][@"team"];
	player.ap = [playerEntity[2][@"playerPersonal"][@"ap"] intValue];
	player.energy = [playerEntity[2][@"playerPersonal"][@"energy"] intValue];
	player.allowNicknameEdit = [playerEntity[2][@"playerPersonal"][@"allowNicknameEdit"] boolValue];
	player.allowFactionChoice = [playerEntity[2][@"playerPersonal"][@"allowFactionChoice"] boolValue];
	player.shouldSendEmail = [playerEntity[2][@"playerPersonal"][@"notificationSettings"][@"shouldSendEmail"] boolValue];
	player.maySendPromoEmail = [playerEntity[2][@"playerPersonal"][@"notificationSettings"][@"maySendPromoEmail"] boolValue];
	player.shouldPushNotifyForAtPlayer = [playerEntity[2][@"playerPersonal"][@"notificationSettings"][@"shouldPushNotifyForAtPlayer"] boolValue];
	player.shouldPushNotifyForPortalAttacks = [playerEntity[2][@"playerPersonal"][@"notificationSettings"][@"shouldPushNotifyForPortalAttacks"] boolValue];

}

- (void)processEnergyGlobGuids:(NSArray *)energyGlobGuids context:(NSManagedObjectContext *)context {

    /*
     The following is an implementation of the algorithm described in:
     https://developer.apple.com/library/ios/#documentation/Cocoa/Conceptual/CoreData/Articles/cdImporting.html#//apple_ref/doc/uid/TP40003174-SW1
     The document describes the "find-or-create" pattern for importing data into CoreData. The trick is to fetch all the objects in one fetch request.
     I've extended it to support full synchronization. This version supports managed object update and deletion as well.
     
     The algorithm for ordered list synchronization: http://www.mlsite.net/blog/?p=2250
     */

	NSArray *sortedEnergyGlobGuids = [energyGlobGuids sortedArrayUsingSelector:@selector(compare:)];
	NSArray *localEnergyGlobs = [EnergyGlob MR_findAllSortedBy:@"guid" ascending:YES inContext:context];

	int i = 0;
	int j = 0;
	const NSUInteger remoteCount = sortedEnergyGlobGuids.count;
	const NSUInteger localCount = localEnergyGlobs.count;
	while (i < remoteCount || j < localCount) {
		if (i >= remoteCount) {
			EnergyGlob *energyGlob = [localEnergyGlobs objectAtIndex:j];
			[energyGlob MR_deleteInContext:context];
			j++;
		} else if (j >= localCount) {
			NSString *energyGlobGuid = [sortedEnergyGlobGuids objectAtIndex:i];
			[EnergyGlob energyGlobWithData:energyGlobGuid inManagedObjectContext:context];
			i++;
		} else {
			EnergyGlob *energyGlob = [localEnergyGlobs objectAtIndex:j];
			energyGlob = (EnergyGlob *)[context existingObjectWithID:energyGlob.objectID error:nil];
			NSString *energyGlobGuid = [sortedEnergyGlobGuids objectAtIndex:i];
			NSComparisonResult comparisonResult = [energyGlobGuid compare:energyGlob.guid];
			if (comparisonResult == NSOrderedAscending) {
				[EnergyGlob energyGlobWithData:energyGlobGuid inManagedObjectContext:context];
				i++;
			} else if (comparisonResult == NSOrderedDescending) {
				[energyGlob MR_deleteInContext:context];
				j++;
			} else {
				//Updating does not really make sense, since everything is encoded in the guid
				//[energyGlob updateWithData:energyGlobGuid];
				i++;
				j++;
			}
		}
	}

}

- (void)processDeletedEntityGuids:(NSArray *)deletedEntityGuids context:(NSManagedObjectContext *)context {
	//NSLog(@"processDeletedEntityGuids: %d", deletedEntityGuids.count);

	for (NSString *deletedGuid in deletedEntityGuids) {
		Item *item = [Item MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"guid = %@", deletedGuid] inContext:context];
		if (item) {
			[item MR_deleteInContext:context];
		}
	}

}

- (void)processAPGains:(NSArray *)apGains {
	//NSLog(@"processAPGains");

	for (NSDictionary *apGain in apGains) {
		dispatch_async(dispatch_get_main_queue(), ^{
			[[MTStatusBarOverlay sharedInstance] postFinishMessage:[NSString stringWithFormat:@"+ %d AP", [apGain[@"apGainAmount"] intValue]] duration:3 animated:YES];
		});
        
        NSString *actionStr;
        
        if ([apGain[@"apTrigger"] isEqualToString:@"DEPLOYED_RESONATOR"]) {
            actionStr = @"deploying a Resonator";
        } else if ([apGain[@"apTrigger"] isEqualToString:@"CAPTURED_PORTAL"]) {
            actionStr = @"capturing a Portal";
        } else if ([apGain[@"apTrigger"] isEqualToString:@"CREATED_PORTAL_LINK"]) {
            actionStr = @"creating a Link";
        } else if ([apGain[@"apTrigger"] isEqualToString:@"CREATED_A_PORTAL_REGION"]) {
            actionStr = @"creating a Control Field";
        } else if ([apGain[@"apTrigger"] isEqualToString:@"DESTROYED_A_RESONATOR"]) {
            actionStr = @"destroying a Resonator";
        } else if ([apGain[@"apTrigger"] isEqualToString:@"DESTROYED_A_PORTAL_LINK"]) {
            actionStr = @"destroying a Link";
        } else if ([apGain[@"apTrigger"] isEqualToString:@"DESTROYED_PORTAL_REGION"]) {
            actionStr = @"destroying a Control Field";
        } else if ([apGain[@"apTrigger"] isEqualToString:@"DEPLOYED_RESONATOR_MOD"]) {
            actionStr = @"creating a Resonator Mod";
        } else if ([apGain[@"apTrigger"] isEqualToString:@"PORTAL_FULLY_POPULATED_WITH_RESONATORS"]) {
            actionStr = @"fully powering a Portal";
        } else if ([apGain[@"apTrigger"] isEqualToString:@"HACKING_ENEMY_PORTAL"]) {
            actionStr = @"hacking an enemy Portal";
        } else if ([apGain[@"apTrigger"] isEqualToString:@"REDEEMED_AP"]) {
            actionStr = @"passcode redemption";
        } else if ([apGain[@"apTrigger"] isEqualToString:@"RECHARGE_RESONATOR"]) {
            actionStr = @"recharging a Resonator";
        } else if ([apGain[@"apTrigger"] isEqualToString:@"REMOTE_RECHARGE_RESONATOR"]) {
            actionStr = @"remote recharging a Resonator";
//      } else if ([apGain[@"apTrigger"] isEqualToString:@"INVITED_PLAYER_JOINED"]) {
//			actionStr = @"";
        } else {
            actionStr = [NSString stringWithFormat:@"doing something really awesome! (%@)", apGain[@"apTrigger"]];
        }
        
        [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {

            NSAttributedString *atrstr = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"Gained %d AP for %@.", [apGain[@"apGainAmount"] intValue], actionStr] attributes:[Utilities attributesWithShadow:NO size:CHAT_FONT_SIZE color:[UIColor colorWithRed:226./255. green:179./255. blue:76./255. alpha:1.0]]];
            
            Plext *plext = [Plext MR_createInContext:localContext];
            plext.guid = nil;
            plext.message = atrstr;
            plext.factionOnly = NO;
            plext.date = [[NSDate date] timeIntervalSinceReferenceDate];
            plext.mentionsYou = nil;
            plext.sender = nil;
            
        }];
        
	}
}

- (void)processPlayerDamages:(NSArray *)playerDamages {
	//NSLog(@"processPlayerDamages: %d", playerDamages.count);

	for (NSDictionary *playerDamage in playerDamages) {
		dispatch_async(dispatch_get_main_queue(), ^{
            if ([[NSUserDefaults standardUserDefaults] boolForKey:DeviceSoundToggleEffects]) {
                [[SoundManager sharedManager] playSound:@"Sound/sfx_player_hit.aif"];
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [[MTStatusBarOverlay sharedInstance] postErrorMessage:[NSString stringWithFormat:@"- %d XM", [playerDamage[@"damageAmount"] intValue]] duration:3 animated:YES];
            });

            [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
                
                NSAttributedString *atrstr = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"You've been hit and lost %d XM!", [playerDamage[@"damageAmount"] intValue]] attributes:[Utilities attributesWithShadow:NO size:CHAT_FONT_SIZE color:[UIColor colorWithRed:226./255. green:179./255. blue:76./255. alpha:1.0]]];
                
                Plext *plext = [Plext MR_createInContext:localContext];
                plext.guid = nil;
                plext.message = atrstr;
                plext.factionOnly = NO;
                plext.date = [[NSDate date] timeIntervalSinceReferenceDate];
                plext.mentionsYou = nil;
                plext.sender = nil;
                
            }];
            
		});
	}
}

@end

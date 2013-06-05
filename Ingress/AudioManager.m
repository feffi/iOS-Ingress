//
//  AudioManager.m
//  Ingress
//
//  Created by Alex Studnička on 05.06.13.
//  Copyright (c) 2013 A&A Code. All rights reserved.
//

#import "AudioManager.h"

@implementation AudioManager {
	AVQueuePlayer *speechQueue;
}

@synthesize uiSuccessSound;
@synthesize uiFailSound;
@synthesize uiBackSound;

#pragma mark - Singleton

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    static AudioManager * __sharedInstance = nil;
    dispatch_once(&onceToken, ^{
        __sharedInstance = [self new];
    });
    return __sharedInstance;
}

- (id)init {
    self = [super init];
	if (self) {
		speechQueue = [AVQueuePlayer new];

		self.uiSuccessSound = [Sound soundNamed:[AudioManager pathOfSound:@"SFX_UI_SUCCESS"]];
		self.uiFailSound = [Sound soundNamed:[AudioManager pathOfSound:@"SFX_UI_FAIL"]];
		self.uiBackSound = [Sound soundNamed:[AudioManager pathOfSound:@"SFX_UI_BACK"]];
		[self.uiSuccessSound prepareToPlay];
		[self.uiFailSound prepareToPlay];
		[self.uiBackSound prepareToPlay];
	}
    return self;
}

#pragma mark - Settings

+ (float)volumeForSoundType:(SoundType)type {

	switch (type) {
		case SoundTypeBackground: {
			if ([[NSUserDefaults standardUserDefaults] boolForKey:DeviceSoundToggleBackground]) {
				return 1.0;
			} else {
				return 0.0;
			}
		}
		case SoundTypeEffects: {
			if ([[NSUserDefaults standardUserDefaults] boolForKey:DeviceSoundToggleEffects]) {
				return 1.0;
			} else {
				return 0.0;
			}
		}
		case SoundTypeSpeech: {
			if ([[NSUserDefaults standardUserDefaults] boolForKey:DeviceSoundToggleSpeech]) {
				return 1.0;
			} else {
				return 0.0;
			}
		}
	}

}

#pragma mark - GUI Sounds

+ (void)playUISuccessSound {
	Sound *sound = [[AudioManager sharedInstance] uiSuccessSound];
	sound.volume = [AudioManager volumeForSoundType:SoundTypeEffects];
	[[SoundManager sharedManager] playSound:sound];
}

+ (void)playUIFailSound {
	Sound *sound = [[AudioManager sharedInstance] uiFailSound];
	sound.volume = [AudioManager volumeForSoundType:SoundTypeEffects];
	[[SoundManager sharedManager] playSound:sound];
}

+ (void)playUIBackSound {
	Sound *sound = [[AudioManager sharedInstance] uiBackSound];
	sound.volume = [AudioManager volumeForSoundType:SoundTypeEffects];
	[[SoundManager sharedManager] playSound:sound];
}

#pragma mark - Playing sounds

+ (void)playSoundEffectNamed:(NSString *)soundName {
	if ([[[AudioManager sounds] allKeys] containsObject:soundName]) {
		NSDictionary *soundDict = [AudioManager sounds][soundName];
		Sound *sound = [Sound soundNamed:soundDict[@"file"]];
		sound.volume = [AudioManager volumeForSoundType:[soundDict[@"type"] intValue]];
		[[SoundManager sharedManager] playSound:sound];
	}
}

- (void)playSpeechNamed:(NSString *)soundName {
//	if ([[[AudioManager sounds] allKeys] containsObject:soundName]) {
//		NSDictionary *soundDict = [AudioManager sounds][soundName];
//		Sound *sound = [Sound soundNamed:soundDict[@"file"]];
//		sound.volume = [AudioManager volumeForSoundType:[soundDict[@"type"] intValue]];
//		[[SoundManager sharedManager] playSound:sound];
//	}

	NSURL *url = [[NSBundle mainBundle] URLForResource:[soundName lowercaseString] withExtension:@"aif" subdirectory:@"Sound"];
	[speechQueue insertItem:[AVPlayerItem playerItemWithURL:url] afterItem:[speechQueue.items lastObject]];

    AVMutableAudioMixInputParameters *audioInputParams =[AVMutableAudioMixInputParameters audioMixInputParameters];
    [audioInputParams setVolume:0.0 atTime:kCMTimeZero];
	AVMutableAudioMix *audioZeroMix = [AVMutableAudioMix audioMix];
	[audioZeroMix setInputParameters:@[audioInputParams]];
	[[AVPlayerItem new] setAudioMix:nil];

	if (speechQueue.rate == 0) {
		[speechQueue play];
	}
}

#pragma mark - Utilities

+ (NSString *)pathOfSound:(NSString *)soundName {
	if ([[[AudioManager sounds] allKeys] containsObject:soundName]) {
		return [@"Sound/" stringByAppendingString:[AudioManager sounds][soundName][@"file"]];
	}
	return nil;
}

+ (NSDictionary *)sounds {
	return @{
		@"SFX_UI_SUCCESS": @{@"file": @"sfx_ui_success.aif", @"duration": @(404), @"type": @(SoundTypeEffects)},
		@"SFX_UI_FAIL": @{@"file": @"sfx_ui_fail.aif", @"duration": @(278), @"type": @(SoundTypeEffects)},
		@"SFX_UI_BACK": @{@"file": @"sfx_ui_back.aif", @"duration": @(92), @"type": @(SoundTypeEffects)},
		@"SFX_RINGTONE": @{@"file": @"sfx_ringtone.aif", @"duration": @(2561), @"type": @(SoundTypeEffects)},
		@"SFX_SONAR": @{@"file": @"sfx_sonar.aif", @"duration": @(2056), @"type": @(SoundTypeEffects)},
		@"SFX_TYPING": @{@"file": @"sfx_typing.aif", @"duration": @(1857), @"type": @(SoundTypeEffects)},
		@"SFX_XM_PICKUP": @{@"file": @"sfx_xm_pickup.aif", @"duration": @(696), @"type": @(SoundTypeEffects)},
		@"SFX_THROB": @{@"file": @"sfx_throbbing_wheels.aif", @"duration": @(3890), @"type": @(SoundTypeEffects)},
		@"SFX_ZOOM_1": @{@"file": @"sfx_zoom_1.aif", @"duration": @(4388), @"type": @(SoundTypeEffects)},
		@"SFX_ZOOM_2": @{@"file": @"sfx_zoom_2.aif", @"duration": @(3947), @"type": @(SoundTypeEffects)},
		@"SFX_ZOOM_3": @{@"file": @"sfx_zoom_3.aif", @"duration": @(4086), @"type": @(SoundTypeEffects)},
		@"SFX_ZOOM_ACQUIRE_TARGET": @{@"file": @"sfx_zoom_acquire_target.aif", @"duration": @(1394), @"type": @(SoundTypeEffects)},
		@"SFX_DROP_RESOURCE": @{@"file": @"sfx_drop_resource.aif", @"duration": @(1114), @"type": @(SoundTypeEffects)},
		@"SFX_RESOURCE_PICK_UP": @{@"file": @"sfx_resource_pick_up.aif", @"duration": @(2090), @"type": @(SoundTypeEffects)},
		@"SFX_RESONATOR_RECHARGE": @{@"file": @"sfx_resonator_recharge.aif", @"duration": @(3090), @"type": @(SoundTypeEffects)},
		@"SFX_PLAYER_LEVEL_UP": @{@"file": @"sfx_player_level_up.aif", @"duration": @(8680), @"type": @(SoundTypeEffects)},
  
		@"SFX_AMBIENT_ALIEN_BASE": @{@"file": @"sfx_ambient_alien_base.aif", @"duration": @(26795), @"type": @(SoundTypeBackground)},
		@"SFX_AMBIENT_HUMAN_BASE": @{@"file": @"sfx_ambient_human_base.aif", @"duration": @(30023), @"type": @(SoundTypeBackground)},
		@"SFX_AMBIENT_NEUTRAL_BASE": @{@"file": @"sfx_ambient_neutral_base.aif", @"duration": @(30023), @"type": @(SoundTypeBackground)},
		@"SFX_AMBIENT_SCANNER_BASE": @{@"file": @"sfx_ambient_scanner_base.aif", @"duration": @(7977), @"type": @(SoundTypeBackground)},
		@"SFX_AMBIENT_SPACE_BASE": @{@"file": @"sfx_ambient_space_base.aif", @"duration": @(8986), @"type": @(SoundTypeBackground)},
		@"SFX_AMBIENT_SPACE_BASE2": @{@"file": @"sfx_ambient_space_base2.aif", @"duration": @(8800), @"type": @(SoundTypeBackground)},
		@"SFX_AMBIENT_SCANNER_BEEPS": @{@"file": @"sfx_ambient_scanner_beeps.aif", @"duration": @(1963), @"type": @(SoundTypeBackground)},
		@"SFX_AMBIENT_SCANNER_RING": @{@"file": @"sfx_ambient_scanner_ring.aif", @"duration": @(3960), @"type": @(SoundTypeBackground)},
		@"SFX_AMBIENT_SCANNER_SWELL": @{@"file": @"sfx_ambient_scanner_swell.aif", @"duration": @(2901), @"type": @(SoundTypeBackground)},
		@"SFX_AMBIENT_SCANNER_WIND": @{@"file": @"sfx_ambient_scanner_wind.aif", @"duration": @(3960), @"type": @(SoundTypeBackground)},
		@"SFX_AMBIENT_ALIEN_HEARTBEAT": @{@"file": @"sfx_ambient_alien_heartbeat.aif", @"duration": @(3078), @"type": @(SoundTypeBackground)},
		@"SFX_AMBIENT_ALIEN_STATIC": @{@"file": @"sfx_ambient_alien_static.aif", @"duration": @(5075), @"type": @(SoundTypeBackground)},
		@"SFX_AMBIENT_ALIEN_WRAITH_ALT": @{@"file": @"sfx_ambient_alien_wraith_alt.aif", @"duration": @(4076), @"type": @(SoundTypeBackground)},
		@"SFX_AMBIENT_ALIEN_WRAITH": @{@"file": @"sfx_ambient_alien_wraith.aif", @"duration": @(5075), @"type": @(SoundTypeBackground)},
		@"SFX_AMBIENT_HUMAN_CRYSTAL": @{@"file": @"sfx_ambient_human_crystal.aif", @"duration": @(4958), @"type": @(SoundTypeBackground)},
		@"SFX_AMBIENT_HUMAN_ENERGY_PULSE": @{@"file": @"sfx_ambient_human_energy_pulse.aif", @"duration": @(5051), @"type": @(SoundTypeBackground)},
		@"SFX_AMBIENT_HUMAN_PULSING_STEREO": @{@"file": @"sfx_ambient_human_pulsing_stereo.aif", @"duration": @(8070), @"type": @(SoundTypeBackground)},
		@"SFX_AMBIENT_HUMAN_PULSING_WARM": @{@"file": @"sfx_ambient_human_pulsing_warm.aif", @"duration": @(5075), @"type": @(SoundTypeBackground)},
		@"SFX_AMBIENT_NEUTRAL_CRYSTAL": @{@"file": @"sfx_ambient_neutral_crystal.aif", @"duration": @(7095), @"type": @(SoundTypeBackground)},
		@"SFX_AMBIENT_NEUTRAL_IMPACTS": @{@"file": @"sfx_ambient_neutral_impacts.aif", @"duration": @(5051), @"type": @(SoundTypeBackground)},
		@"SFX_AMBIENT_NEUTRAL_WHALE_ALT": @{@"file": @"sfx_ambient_neutral_whale_alt.aif", @"duration": @(4076), @"type": @(SoundTypeBackground)},
		@"SFX_AMBIENT_NEUTRAL_WHALE": @{@"file": @"sfx_ambient_neutral_whale.aif", @"duration": @(4076), @"type": @(SoundTypeBackground)},
		@"SFX_AMBIENT_SPACE_ALIEN": @{@"file": @"sfx_ambient_space_alien.aif", @"duration": @(3111), @"type": @(SoundTypeBackground)},
		@"SFX_AMBIENT_SPACE_FEMALE": @{@"file": @"sfx_ambient_space_female.aif", @"duration": @(3552), @"type": @(SoundTypeBackground)},
		@"SFX_AMBIENT_SPACE_TRANSMISSION3": @{@"file": @"sfx_ambient_space_transmission3.aif", @"duration": @(998), @"type": @(SoundTypeBackground)},
		@"SFX_AMBIENT_SPACE_TRANSMISSION4": @{@"file": @"sfx_ambient_space_transmission4.aif", @"duration": @(1393), @"type": @(SoundTypeBackground)},
		@"SFX_AMBIENT_SPACE_GRID142": @{@"file": @"sfx_ambient_space_grid142.aif", @"duration": @(1017), @"type": @(SoundTypeBackground)},
		@"SFX_AMBIENT_SPACE_MAGNIFICATION": @{@"file": @"sfx_ambient_space_magnification.aif", @"duration": @(1516), @"type": @(SoundTypeBackground)},
		@"SFX_AMBIENT_SPACE_LATTITUDE": @{@"file": @"sfx_ambient_space_lattitude.aif", @"duration": @(1301), @"type": @(SoundTypeBackground)},

		@"SPEECH_ABANDONED": @{@"file": @"speech_abandoned.aif", @"duration": @(744), @"type": @(SoundTypeSpeech)},
		@"SPEECH_ACCESS_LEVEL_ACHIEVED": @{@"file": @"speech_access_level_achieved.aif", @"duration": @(1327), @"type": @(SoundTypeSpeech)},
		@"SPEECH_ACTIVATED": @{@"file": @"speech_activated.aif", @"duration": @(782), @"type": @(SoundTypeSpeech)},
		@"SPEECH_ADA_REFACTOR": @{@"file": @"speech_flipcard_ada.aif", @"duration": @(1050), @"type": @(SoundTypeSpeech)},
		@"SPEECH_ADDED": @{@"file": @"speech_added.aif", @"duration": @(523), @"type": @(SoundTypeSpeech)},
		@"SPEECH_ACQUIRED": @{@"file": @"speech_acquired.aif", @"duration": @(580), @"type": @(SoundTypeSpeech)},
		@"SPEECH_ARCHIVED": @{@"file": @"speech_archived.aif", @"duration": @(767), @"type": @(SoundTypeSpeech)},
		@"SPEECH_ATTACK": @{@"file": @"speech_attack.aif", @"duration": @(700), @"type": @(SoundTypeSpeech)},
		@"SPEECH_ATTACK_IN_PROGRESS": @{@"file": @"speech_attack_in_progress.aif", @"duration": @(1365), @"type": @(SoundTypeSpeech)},
		@"SPEECH_AVAILABLE": @{@"file": @"speech_available.aif", @"duration": @(735), @"type": @(SoundTypeSpeech)},
		@"SPEECH_CODENAME_ALREADY_ASSIGNED": @{@"file": @"speech_codename_already_assigned.aif", @"duration": @(3043), @"type": @(SoundTypeSpeech)},
		@"SPEECH_CODENAME_CHOOSE": @{@"file": @"speech_codename_choose.aif", @"duration": @(9193), @"type": @(SoundTypeSpeech)},
		@"SPEECH_CODENAME_CONFIRM": @{@"file": @"speech_codename_confirm.aif", @"duration": @(2689), @"type": @(SoundTypeSpeech)},
		@"SPEECH_CODENAME_CONFIRMATION": @{@"file": @"speech_codename_confirmation.aif", @"duration": @(33237), @"type": @(SoundTypeSpeech)},
		@"SPEECH_COLLAPSED": @{@"file": @"speech_collapsed.aif", @"duration": @(724), @"type": @(SoundTypeSpeech)},
		@"SPEECH_COMMUNICATION_RECEIVED": @{@"file": @"speech_communication_received.aif", @"duration": @(1290), @"type": @(SoundTypeSpeech)},
		@"SPEECH_COMPLETE": @{@"file": @"speech_complete.aif", @"duration": @(698), @"type": @(SoundTypeSpeech)},
		@"SPEECH_COOLDOWN_ACTIVE": @{@"file": @"speech_cooldown_active.aif", @"duration": @(1118), @"type": @(SoundTypeSpeech)},
		@"SPEECH_CRITICAL": @{@"file": @"speech_critical.aif", @"duration": @(593), @"type": @(SoundTypeSpeech)},
		@"SPEECH_DEPLETED": @{@"file": @"speech_depleted.aif", @"duration": @(666), @"type": @(SoundTypeSpeech)},
		@"SPEECH_DEPLOYED": @{@"file": @"speech_deployed.aif", @"duration": @(557), @"type": @(SoundTypeSpeech)},
		@"SPEECH_DETECTED": @{@"file": @"speech_detected.aif", @"duration": @(645), @"type": @(SoundTypeSpeech)},
		@"SPEECH_DIRECTION_EAST": @{@"file": @"speech_direction_east.aif", @"duration": @(441), @"type": @(SoundTypeSpeech)},
		@"SPEECH_DIRECTION_NORTH": @{@"file": @"speech_direction_north.aif", @"duration": @(605), @"type": @(SoundTypeSpeech)},
		@"SPEECH_DIRECTION_NORTH_EAST": @{@"file": @"speech_direction_north_east.aif", @"duration": @(696), @"type": @(SoundTypeSpeech)},
		@"SPEECH_DIRECTION_NORTH_WEST": @{@"file": @"speech_direction_north_west.aif", @"duration": @(789), @"type": @(SoundTypeSpeech)},
		@"SPEECH_DIRECTION_SOUTH": @{@"file": @"speech_direction_south.aif", @"duration": @(580), @"type": @(SoundTypeSpeech)},
		@"SPEECH_DIRECTION_SOUTH_EAST": @{@"file": @"speech_direction_south_east.aif", @"duration": @(743), @"type": @(SoundTypeSpeech)},
		@"SPEECH_DIRECTION_SOUTH_WEST": @{@"file": @"speech_direction_south_west.aif", @"duration": @(743), @"type": @(SoundTypeSpeech)},
		@"SPEECH_DIRECTION_WEST": @{@"file": @"speech_direction_west.aif", @"duration": @(464), @"type": @(SoundTypeSpeech)},
		@"SPEECH_DRAINED": @{@"file": @"speech_drained.aif", @"duration": @(602), @"type": @(SoundTypeSpeech)},
		@"SPEECH_ENLIGHTENED": @{@"file": @"speech_enlightened.aif", @"duration": @(692), @"type": @(SoundTypeSpeech)},
		@"SPEECH_ESTABLISHING_PORTAL_LINK": @{@"file": @"speech_establishing_portal_link.aif", @"duration": @(1439), @"type": @(SoundTypeSpeech)},
		@"SPEECH_EXCELLENT_WORK": @{@"file": @"speech_excellent_work.aif", @"duration": @(921), @"type": @(SoundTypeSpeech)},
		@"SPEECH_FACTION_CHOICE_ENLIGHTENED": @{@"file": @"speech_faction_choice_enlightened.aif", @"duration": @(19311), @"type": @(SoundTypeSpeech)},
		@"SPEECH_FACTION_CHOICE_ENLIGHTENED_ALT": @{@"file": @"speech_faction_choice_enlightened_alt.aif", @"duration": @(7672), @"type": @(SoundTypeSpeech)},
		@"SPEECH_FACTION_CHOICE_ENLIGHTENED_START": @{@"file": @"speech_faction_choice_enlightened_start.aif", @"duration": @(12868), @"type": @(SoundTypeSpeech)},
		@"SPEECH_FACTION_CHOICE_HUMANIST": @{@"file": @"speech_faction_choice_humanist.aif", @"duration": @(9872), @"type": @(SoundTypeSpeech)},
		@"SPEECH_FACTION_CHOICE_HUMANIST_ALT": @{@"file": @"speech_faction_choice_humanist_alt.aif", @"duration": @(13132), @"type": @(SoundTypeSpeech)},
		@"SPEECH_FACTION_CHOICE_HUMANIST_START": @{@"file": @"speech_faction_choice_humanist_start.aif", @"duration": @(8880), @"type": @(SoundTypeSpeech)},
		@"SPEECH_FAILED": @{@"file": @"speech_failed.aif", @"duration": @(605), @"type": @(SoundTypeSpeech)},
		@"SPEECH_FIELD": @{@"file": @"speech_field.aif", @"duration": @(605), @"type": @(SoundTypeSpeech)},
		@"SPEECH_FIELD_ESTABLISHED": @{@"file": @"speech_field_established.aif", @"duration": @(1226), @"type": @(SoundTypeSpeech)},
		@"SPEECH_FROM_PRESENT_LOCATION": @{@"file": @"speech_from_present_location.aif", @"duration": @(1345), @"type": @(SoundTypeSpeech)},
		@"SPEECH_GOOD_WORK": @{@"file": @"speech_good_work.aif", @"duration": @(603), @"type": @(SoundTypeSpeech)},
		@"SPEECH_HACKER": @{@"file": @"speech_hacker.aif", @"duration": @(581), @"type": @(SoundTypeSpeech)},
		@"SPEECH_HACKING": @{@"file": @"speech_hacking.aif", @"duration": @(642), @"type": @(SoundTypeSpeech)},
		@"SPEECH_HUMANIST": @{@"file": @"speech_humanist.aif", @"duration": @(788), @"type": @(SoundTypeSpeech)},
		@"SPEECH_IN_RANGE": @{@"file": @"speech_in_range.aif", @"duration": @(673), @"type": @(SoundTypeSpeech)},
		@"SPEECH_INCOMING_MESSAGE": @{@"file": @"speech_incoming_message.aif", @"duration": @(1133), @"type": @(SoundTypeSpeech)},
		@"SPEECH_JARVIS_VIRUS": @{@"file": @"speech_flipcard_jarvis.aif", @"duration": @(1190), @"type": @(SoundTypeSpeech)},
		@"SPEECH_KILOMETERS": @{@"file": @"speech_kilometers.aif", @"duration": @(719), @"type": @(SoundTypeSpeech)},
		@"SPEECH_LINK": @{@"file": @"speech_link.aif", @"duration": @(590), @"type": @(SoundTypeSpeech)},
		@"SPEECH_LINKAMP": @{@"file": @"speech_linkamp.aif", @"duration": @(920), @"type": @(SoundTypeSpeech)},
		@"SPEECH_LOST": @{@"file": @"speech_lost.aif", @"duration": @(671), @"type": @(SoundTypeSpeech)},
		@"SPEECH_MEDIA": @{@"file": @"speech_media.aif", @"duration": @(645), @"type": @(SoundTypeSpeech)},
		@"SPEECH_METERS": @{@"file": @"speech_meters.aif", @"duration": @(557), @"type": @(SoundTypeSpeech)},
		@"SPEECH_MINE": @{@"file": @"speech_mine.aif", @"duration": @(535), @"type": @(SoundTypeSpeech)},
		@"SPEECH_MINUTES": @{@"file": @"speech_minutes.aif", @"duration": @(487), @"type": @(SoundTypeSpeech)},
		@"SPEECH_MISSION": @{@"file": @"speech_mission.aif", @"duration": @(550), @"type": @(SoundTypeSpeech)},
		@"SPEECH_MISSION_0_INTRO": @{@"file": @"speech_mission_0_intro.aif", @"duration": @(18237), @"type": @(SoundTypeSpeech)},
		@"SPEECH_MISSION_1B_COMPLETE": @{@"file": @"speech_mission_1b_complete.aif", @"duration": @(3139), @"type": @(SoundTypeSpeech)},
		@"SPEECH_MISSION_1B_INTRO": @{@"file": @"speech_mission_1b_intro.aif", @"duration": @(14554), @"type": @(SoundTypeSpeech)},
		@"SPEECH_MISSION_1B_OBJECTIVE": @{@"file": @"speech_mission_1b_objective.aif", @"duration": @(4143), @"type": @(SoundTypeSpeech)},
		@"SPEECH_MISSION_1_COMPLETE": @{@"file": @"speech_mission_1_complete.aif", @"duration": @(5670), @"type": @(SoundTypeSpeech)},
		@"SPEECH_MISSION_1_INTRO": @{@"file": @"speech_mission_1_intro.aif", @"duration": @(16760), @"type": @(SoundTypeSpeech)},
		@"SPEECH_MISSION_2_COMPLETE": @{@"file": @"speech_mission_2_complete.aif", @"duration": @(16017), @"type": @(SoundTypeSpeech)},
		@"SPEECH_MISSION_2_INTRO": @{@"file": @"speech_mission_2_intro.aif", @"duration": @(14154), @"type": @(SoundTypeSpeech)},
		@"SPEECH_MISSION_2_PRE_INTRO": @{@"file": @"speech_mission_2_pre_intro.aif", @"duration": @(8973), @"type": @(SoundTypeSpeech)},
		@"SPEECH_MISSION_3_CLOSING": @{@"file": @"speech_mission_3_closing.aif", @"duration": @(2854), @"type": @(SoundTypeSpeech)},
		@"SPEECH_MISSION_3_INTRO": @{@"file": @"speech_mission_3_intro.aif", @"duration": @(12865), @"type": @(SoundTypeSpeech)},
		@"SPEECH_MISSION_4_COMPLETE": @{@"file": @"speech_mission_4_complete.aif", @"duration": @(4384), @"type": @(SoundTypeSpeech)},
		@"SPEECH_MISSION_4_INTRO": @{@"file": @"speech_mission_4_intro.aif", @"duration": @(8499), @"type": @(SoundTypeSpeech)},
		@"SPEECH_MISSION_5_COMPLETE": @{@"file": @"speech_mission_5_complete.aif", @"duration": @(2723), @"type": @(SoundTypeSpeech)},
		@"SPEECH_MISSION_5_HACKING_COMPLETE": @{@"file": @"speech_mission_5_hacking_complete.aif", @"duration": @(3757), @"type": @(SoundTypeSpeech)},
		@"SPEECH_MISSION_5_INTRO": @{@"file": @"speech_mission_5_intro.aif", @"duration": @(15811), @"type": @(SoundTypeSpeech)},
		@"SPEECH_MISSION_5_RECHARGE_RESONATORS": @{@"file": @"speech_mission_5_recharge_resonators.aif", @"duration": @(7722), @"type": @(SoundTypeSpeech)},
		@"SPEECH_MISSION_6_COMPLETE": @{@"file": @"speech_mission_6_complete.aif", @"duration": @(20147), @"type": @(SoundTypeSpeech)},
		@"SPEECH_MISSION_6_FIRST_PORTAL_KEY": @{@"file": @"speech_mission_6_first_portal_key.aif", @"duration": @(6137), @"type": @(SoundTypeSpeech)},
		@"SPEECH_MISSION_6_INTRO": @{@"file": @"speech_mission_6_intro.aif", @"duration": @(27612), @"type": @(SoundTypeSpeech)},
		@"SPEECH_MISSION_6_SECOND_PORTAL": @{@"file": @"speech_mission_6_second_portal.aif", @"duration": @(6215), @"type": @(SoundTypeSpeech)},
		@"SPEECH_MISSION_6_SECOND_PORTAL_RESONATED": @{@"file": @"speech_mission_6_second_portal_resonated.aif", @"duration": @(5211), @"type": @(SoundTypeSpeech)},
		@"SPEECH_MISSION_7_COMPLETE": @{@"file": @"speech_mission_7_complete.aif", @"duration": @(31023), @"type": @(SoundTypeSpeech)},
		@"SPEECH_MISSION_7_FIRST_LINK": @{@"file": @"speech_mission_7_first_link.aif", @"duration": @(2454), @"type": @(SoundTypeSpeech)},
		@"SPEECH_MISSION_7_INTRO": @{@"file": @"speech_mission_7_intro.aif", @"duration": @(21140), @"type": @(SoundTypeSpeech)},
		@"SPEECH_MISSION_7_SECOND_LINK": @{@"file": @"speech_mission_7_second_link.aif", @"duration": @(4088), @"type": @(SoundTypeSpeech)},
		@"SPEECH_MISSION_7_THIRD_PORTAL": @{@"file": @"speech_mission_7_third_portal.aif", @"duration": @(2622), @"type": @(SoundTypeSpeech)},
		@"SPEECH_MISSION_ACHIEVED_HUMAN": @{@"file": @"speech_mission_achieved_human.aif", @"duration": @(2947), @"type": @(SoundTypeSpeech)},
		@"SPEECH_MORE_PORTALS": @{@"file": @"speech_more_portals.aif", @"duration": @(1017), @"type": @(SoundTypeSpeech)},
		@"SPEECH_MULTIPLE_PORTAL_ATTACKS": @{@"file": @"speech_multiple_portal_attacks.aif", @"duration": @(1557), @"type": @(SoundTypeSpeech)},
		@"SPEECH_NEUTRAL": @{@"file": @"speech_neutral.aif", @"duration": @(625), @"type": @(SoundTypeSpeech)},
		@"SPEECH_NEXT": @{@"file": @"speech_next.aif", @"duration": @(599), @"type": @(SoundTypeSpeech)},
		@"SPEECH_NUMBER_001": @{@"file": @"speech_number_001.aif", @"duration": @(361), @"type": @(SoundTypeSpeech)},
		@"SPEECH_NUMBER_002": @{@"file": @"speech_number_002.aif", @"duration": @(355), @"type": @(SoundTypeSpeech)},
		@"SPEECH_NUMBER_003": @{@"file": @"speech_number_003.aif", @"duration": @(372), @"type": @(SoundTypeSpeech)},
		@"SPEECH_NUMBER_004": @{@"file": @"speech_number_004.aif", @"duration": @(454), @"type": @(SoundTypeSpeech)},
		@"SPEECH_NUMBER_005": @{@"file": @"speech_number_005.aif", @"duration": @(534), @"type": @(SoundTypeSpeech)},
		@"SPEECH_NUMBER_006": @{@"file": @"speech_number_006.aif", @"duration": @(534), @"type": @(SoundTypeSpeech)},
		@"SPEECH_NUMBER_007": @{@"file": @"speech_number_007.aif", @"duration": @(483), @"type": @(SoundTypeSpeech)},
		@"SPEECH_NUMBER_008": @{@"file": @"speech_number_008.aif", @"duration": @(348), @"type": @(SoundTypeSpeech)},
		@"SPEECH_NUMBER_009": @{@"file": @"speech_number_009.aif", @"duration": @(457), @"type": @(SoundTypeSpeech)},
		@"SPEECH_NUMBER_010": @{@"file": @"speech_number_010.aif", @"duration": @(404), @"type": @(SoundTypeSpeech)},
		@"SPEECH_NUMBER_011": @{@"file": @"speech_number_011.aif", @"duration": @(483), @"type": @(SoundTypeSpeech)},
		@"SPEECH_NUMBER_012": @{@"file": @"speech_number_012.aif", @"duration": @(510), @"type": @(SoundTypeSpeech)},
		@"SPEECH_NUMBER_013": @{@"file": @"speech_number_013.aif", @"duration": @(599), @"type": @(SoundTypeSpeech)},
		@"SPEECH_NUMBER_014": @{@"file": @"speech_number_014.aif", @"duration": @(642), @"type": @(SoundTypeSpeech)},
		@"SPEECH_NUMBER_015": @{@"file": @"speech_number_015.aif", @"duration": @(622), @"type": @(SoundTypeSpeech)},
		@"SPEECH_NUMBER_016": @{@"file": @"speech_number_016.aif", @"duration": @(712), @"type": @(SoundTypeSpeech)},
		@"SPEECH_NUMBER_017": @{@"file": @"speech_number_017.aif", @"duration": @(738), @"type": @(SoundTypeSpeech)},
		@"SPEECH_NUMBER_018": @{@"file": @"speech_number_018.aif", @"duration": @(581), @"type": @(SoundTypeSpeech)},
		@"SPEECH_NUMBER_019": @{@"file": @"speech_number_019.aif", @"duration": @(674), @"type": @(SoundTypeSpeech)},
		@"SPEECH_NUMBER_020": @{@"file": @"speech_number_020.aif", @"duration": @(419), @"type": @(SoundTypeSpeech)},
		@"SPEECH_NUMBER_025": @{@"file": @"speech_number_025.aif", @"duration": @(766), @"type": @(SoundTypeSpeech)},
		@"SPEECH_NUMBER_030": @{@"file": @"speech_number_030.aif", @"duration": @(491), @"type": @(SoundTypeSpeech)},
		@"SPEECH_NUMBER_040": @{@"file": @"speech_number_040.aif", @"duration": @(503), @"type": @(SoundTypeSpeech)},
		@"SPEECH_NUMBER_050": @{@"file": @"speech_number_050.aif", @"duration": @(471), @"type": @(SoundTypeSpeech)},
		@"SPEECH_NUMBER_060": @{@"file": @"speech_number_060.aif", @"duration": @(570), @"type": @(SoundTypeSpeech)},
		@"SPEECH_NUMBER_070": @{@"file": @"speech_number_070.aif", @"duration": @(657), @"type": @(SoundTypeSpeech)},
		@"SPEECH_NUMBER_075": @{@"file": @"speech_number_075.aif", @"duration": @(1081), @"type": @(SoundTypeSpeech)},
		@"SPEECH_NUMBER_080": @{@"file": @"speech_number_080.aif", @"duration": @(535), @"type": @(SoundTypeSpeech)},
		@"SPEECH_NUMBER_090": @{@"file": @"speech_number_090.aif", @"duration": @(622), @"type": @(SoundTypeSpeech)},
		@"SPEECH_NUMBER_100": @{@"file": @"speech_number_100.aif", @"duration": @(580), @"type": @(SoundTypeSpeech)},
		@"SPEECH_NUMBER_200": @{@"file": @"speech_number_200.aif", @"duration": @(626), @"type": @(SoundTypeSpeech)},
		@"SPEECH_NUMBER_300": @{@"file": @"speech_number_300.aif", @"duration": @(719), @"type": @(SoundTypeSpeech)},
		@"SPEECH_NUMBER_400": @{@"file": @"speech_number_400.aif", @"duration": @(719), @"type": @(SoundTypeSpeech)},
		@"SPEECH_NUMBER_500": @{@"file": @"speech_number_500.aif", @"duration": @(764), @"type": @(SoundTypeSpeech)},
		@"SPEECH_NUMBER_600": @{@"file": @"speech_number_600.aif", @"duration": @(743), @"type": @(SoundTypeSpeech)},
		@"SPEECH_NUMBER_700": @{@"file": @"speech_number_700.aif", @"duration": @(766), @"type": @(SoundTypeSpeech)},
		@"SPEECH_NUMBER_800": @{@"file": @"speech_number_800.aif", @"duration": @(673), @"type": @(SoundTypeSpeech)},
		@"SPEECH_NUMBER_900": @{@"file": @"speech_number_900.aif", @"duration": @(719), @"type": @(SoundTypeSpeech)},
		@"SPEECH_OFFLINE": @{@"file": @"speech_offline.aif", @"duration": @(721), @"type": @(SoundTypeSpeech)},
		@"SPEECH_ONLINE": @{@"file": @"speech_online.aif", @"duration": @(692), @"type": @(SoundTypeSpeech)},
		@"SPEECH_PERCENT": @{@"file": @"speech_percent.aif", @"duration": @(510), @"type": @(SoundTypeSpeech)},
		@"SPEECH_POINT": @{@"file": @"speech_point.aif", @"duration": @(576), @"type": @(SoundTypeSpeech)},
		@"SPEECH_PORTAL": @{@"file": @"speech_portal.aif", @"duration": @(506), @"type": @(SoundTypeSpeech)},
		@"SPEECH_PORTAL_ATTACK": @{@"file": @"speech_portal_attack.aif", @"duration": @(997), @"type": @(SoundTypeSpeech)},
		@"SPEECH_PORTAL_FIELD": @{@"file": @"speech_portal_field.aif", @"duration": @(930), @"type": @(SoundTypeSpeech)},
		@"SPEECH_PORTAL_IN_RANGE": @{@"file": @"speech_portal_in_range.aif", @"duration": @(1255), @"type": @(SoundTypeSpeech)},
		@"SPEECH_PORTAL_KEY": @{@"file": @"speech_portalkey.aif", @"duration": @(767), @"type": @(SoundTypeSpeech)},
		@"SPEECH_PORTAL_LINK": @{@"file": @"speech_portal_link.aif", @"duration": @(878), @"type": @(SoundTypeSpeech)},
		@"SPEECH_PORTAL_LINK_ESTABLISHED": @{@"file": @"speech_portal_link_established.aif", @"duration": @(1393), @"type": @(SoundTypeSpeech)},
		@"SPEECH_PORTAL_XM": @{@"file": @"speech_portal_xm.aif", @"duration": @(1043), @"type": @(SoundTypeSpeech)},
		@"SPEECH_POSSIBLE": @{@"file": @"speech_possible.aif", @"duration": @(634), @"type": @(SoundTypeSpeech)},
		@"SPEECH_POWER_CUBE": @{@"file": @"speech_power_cube.aif", @"duration": @(821), @"type": @(SoundTypeSpeech)},
		@"SPEECH_RECHARGED": @{@"file": @"speech_recharged.aif", @"duration": @(872), @"type": @(SoundTypeSpeech)},
		@"SPEECH_REDUCED": @{@"file": @"speech_reduced.aif", @"duration": @(712), @"type": @(SoundTypeSpeech)},
		@"SPEECH_REFUGE": @{@"file": @"speech_refuge.aif", @"duration": @(785), @"type": @(SoundTypeSpeech)},
		@"SPEECH_RELEASED": @{@"file": @"speech_released.aif", @"duration": @(626), @"type": @(SoundTypeSpeech)},
		@"SPEECH_REMAINING": @{@"file": @"speech_remaining.aif", @"duration": @(692), @"type": @(SoundTypeSpeech)},
		@"SPEECH_REQUIRED": @{@"file": @"speech_required.aif", @"duration": @(724), @"type": @(SoundTypeSpeech)},
		@"SPEECH_RESONATOR": @{@"file": @"speech_resonator.aif", @"duration": @(590), @"type": @(SoundTypeSpeech)},
		@"SPEECH_RESONATOR_DESTROYED": @{@"file": @"speech_resonator_destroyed.aif", @"duration": @(1253), @"type": @(SoundTypeSpeech)},
		@"SPEECH_SATURATED": @{@"file": @"speech_saturated.aif", @"duration": @(866), @"type": @(SoundTypeSpeech)},
		@"SPEECH_SCANNER": @{@"file": @"speech_scanner.aif", @"duration": @(674), @"type": @(SoundTypeSpeech)},
		@"SPEECH_SECONDS": @{@"file": @"speech_seconds.aif", @"duration": @(680), @"type": @(SoundTypeSpeech)},
		@"SPEECH_SEVERED": @{@"file": @"speech_severed.aif", @"duration": @(567), @"type": @(SoundTypeSpeech)},
		@"SPEECH_SHIELD": @{@"file": @"speech_shield.aif", @"duration": @(637), @"type": @(SoundTypeSpeech)},
		@"SPEECH_TARGET": @{@"file": @"speech_target.aif", @"duration": @(464), @"type": @(SoundTypeSpeech)},
		@"SPEECH_TESLA": @{@"file": @"speech_tesla.aif", @"duration": @(628), @"type": @(SoundTypeSpeech)},
		@"SPEECH_UNKNOWN_TECH": @{@"file": @"speech_unknown_tech.aif", @"duration": @(1390), @"type": @(SoundTypeSpeech)},
		@"SPEECH_UNSUCCESSFUL": @{@"file": @"speech_unsuccessful.aif", @"duration": @(918), @"type": @(SoundTypeSpeech)},
		@"SPEECH_UPGRADED": @{@"file": @"speech_upgraded.aif", @"duration": @(712), @"type": @(SoundTypeSpeech)},
		@"SPEECH_WEAPONS": @{@"file": @"speech_weapons.aif", @"duration": @(709), @"type": @(SoundTypeSpeech)},
		@"SPEECH_WELCOME_ABOUTTIME": @{@"file": @"speech_welcome_abouttime.aif", @"duration": @(2831), @"type": @(SoundTypeSpeech)},
		@"SPEECH_WELCOME_BACK": @{@"file": @"speech_welcome_back.aif", @"duration": @(892), @"type": @(SoundTypeSpeech)},
		@"SPEECH_WELCOME_ITSBEEN": @{@"file": @"speech_welcome_itsbeen.aif", @"duration": @(785), @"type": @(SoundTypeSpeech)},
		@"SPEECH_WELCOME_LAST_LOGIN": @{@"file": @"speech_welcome_last_login.aif", @"duration": @(1824), @"type": @(SoundTypeSpeech)},
		@"SPEECH_WELCOME_LONGTIME": @{@"file": @"speech_welcome_longtime.aif", @"duration": @(4120), @"type": @(SoundTypeSpeech)},
		@"SPEECH_WELCOME_WORRIEDABOUTYOU": @{@"file": @"speech_welcome_worriedaboutyou.aif", @"duration": @(1441), @"type": @(SoundTypeSpeech)},
		@"SPEECH_XM": @{@"file": @"speech_xm.aif", @"duration": @(680), @"type": @(SoundTypeSpeech)},
		@"SPEECH_XM_LEVELS": @{@"file": @"speech_xm_levels.aif", @"duration": @(1124), @"type": @(SoundTypeSpeech)},
		@"SPEECH_XM_REQUIRED_FOR_THIS_PORTAL": @{@"file": @"speech_xm_required_for_this_portal.aif", @"duration": @(1920), @"type": @(SoundTypeSpeech)},
		@"SPEECH_XM_RESERVE": @{@"file": @"speech_xm_reserve.aif", @"duration": @(1118), @"type": @(SoundTypeSpeech)},
		@"SPEECH_XM_RESERVES": @{@"file": @"speech_xm_reserves.aif", @"duration": @(1272), @"type": @(SoundTypeSpeech)},
		@"SPEECH_XMP": @{@"file": @"speech_xmp.aif", @"duration": @(866), @"type": @(SoundTypeSpeech)},
		@"SPEECH_YOUVE_BEEN_HIT": @{@"file": @"speech_youve_been_hit.aif", @"duration": @(696), @"type": @(SoundTypeSpeech)},
		@"SPEECH_YOU_ARE_UNDER_ATTACK": @{@"file": @"speech_you_are_under_attack.aif", @"duration": @(1095), @"type": @(SoundTypeSpeech)},
		@"SPEECH_YOU_HAVE_SUFFICIENT_ENERGY_TO_HACK_YOUR_TARGET": @{@"file": @"speech_you_have_sufficient_energy_to_hack_your_target.aif", @"duration": @(2343), @"type": @(SoundTypeSpeech)},
		@"SPEECH_ZOOM_ACQUIRING": @{@"file": @"speech_zoom_acquiring.aif", @"duration": @(1208), @"type": @(SoundTypeSpeech)},
		@"SPEECH_ZOOM_DOWNLOADING": @{@"file": @"speech_zoom_downloading.aif", @"duration": @(2007), @"type": @(SoundTypeSpeech)},
		@"SPEECH_ZOOM_LOCKON": @{@"file": @"speech_zoom_lockon.aif", @"duration": @(1470), @"type": @(SoundTypeSpeech)},
		@"SPEECH_ZOOMDOWN_INTRO": @{@"file": @"speech_zoomdown_intro.aif", @"duration": @(28152), @"type": @(SoundTypeSpeech)},
		@"SPEECH_ZOOMDOWN_TRIANGULATING": @{@"file": @"speech_zoomdown_triangulating.aif", @"duration": @(1861), @"type": @(SoundTypeSpeech)},
//		@"": @{@"file": @"", @"duration": @(), @"type": @()},
	};
}

@end

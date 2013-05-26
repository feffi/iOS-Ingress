//
//  API.h
//  Ingress
//
//  Created by Alex Studnicka on 10.01.13.
//  Copyright (c) 2013 A&A Code. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import <GLKit/GLKit.h>
#import "DB.h"

#define kDeviceSoundLevel @"kDeviceSoundLevel"

typedef void (^SoundCompletionBlock)(void);

@interface API : NSObject <AVAudioPlayerDelegate, MTStatusBarOverlayDelegate> {
	
	AVAudioPlayer *_backgroundAudioPlayer;
	AVAudioPlayer *_audioPlayer;
	SoundCompletionBlock soundCompletionHandlerBlock;
	
}

@property (nonatomic, strong) NSOperationQueue *networkQueue;
@property (nonatomic, strong) NSOperationQueue *notificationQueue;
@property (nonatomic, strong) NSString *xsrfToken;
@property (nonatomic, strong) NSString *SACSID;
@property (nonatomic, strong) Player *player;
@property (nonatomic, strong) NSMutableArray *energyToCollect;
@property (nonatomic, readonly) long long currentTimestamp;

@property (nonatomic) SystemSoundID ui_success_sound;
@property (nonatomic) SystemSoundID ui_fail_sound;

+ (API *)sharedInstance;

+ (PortalShieldRarity)shieldRarityFromString:(NSString *)shieldRarityStr;
+ (PortalShieldRarity)shieldRarityFromInt:(int)shieldRarityInt;
+ (NSString *)shieldRarityStrFromRarity:(PortalShieldRarity)shieldRarity;

+ (int)levelForAp:(int)ap;
+ (int)maxApForLevel:(int)level;
+ (int)maxXmForLevel:(int)level;
+ (int)maxEnergyForResonatorLevel:(int)level;

+ (NSString *)factionStrForFaction:(NSString *)faction;

+ (UIColor *)colorForLevel:(int)level;
+ (UIColor *)colorForFaction:(NSString *)faction;

+ (NSDictionary *)sounds;
+ (float)durationOfSound:(NSString *)soundName;
+ (NSArray *)soundsForNumber:(int)number;
//- (void)playBackgroundMusic;
//- (void)playSoundNamed:(NSString *)name completionHandler:(void (^)(void))handler;
- (void)playSound:(NSString *)soundName;
- (void)playSounds:(NSArray *)soundNames;

- (NSString *)currentE6Location;
- (UIImage *)iconForPortal:(Portal *)portal;

- (void)processHandshakeData:(NSString *)jsonString completionHandler:(void (^)(NSString *errorStr))handler;

- (void)getInventoryWithCompletionHandler:(void (^)(void))handler;
- (void)getObjectsWithCompletionHandler:(void (^)(void))handler;
- (void)loadCommunicationForFactionOnly:(BOOL)factionOnly completionHandler:(void (^)(void))handler;
- (void)sendMessage:(NSString *)message factionOnly:(BOOL)factionOnly completionHandler:(void (^)(void))handler;
- (void)loadScoreWithCompletionHandler:(void (^)(int alienScore, int resistanceScore))handler;
- (void)redeemReward:(NSString *)passcode completionHandler:(void (^)(BOOL accepted, NSString *response))handler;
- (void)loadNumberOfInvitesWithCompletionHandler:(void (^)(int numberOfInvites))handler;
- (void)inviteUserWithEmail:(NSString *)email completionHandler:(void (^)(NSString *errorStr, int numberOfInvites))handler;
- (void)fireXMP:(XMP *)xmpItem completionHandler:(void (^)(NSString *errorStr, NSDictionary *damages))handler;
- (void)validateNickname:(NSString *)nickname completionHandler:(void (^)(NSString *errorStr))handler;
- (void)persistNickname:(NSString *)nickname completionHandler:(void (^)(NSString *errorStr))handler;
- (void)chooseFaction:(NSString *)faction completionHandler:(void (^)(NSString *errorStr))handler;
- (void)hackPortal:(Portal *)portal completionHandler:(void (^)(NSString *errorStr, NSArray *acquiredItems, int secondsRemaining))handler;
- (void)deployResonator:(Resonator *)resonatorItem toPortal:(Portal *)portal toSlot:(int)slot completionHandler:(void (^)(NSString *errorStr))handler;
- (void)upgradeResonator:(Resonator *)resonatorItem toPortal:(Portal *)portal toSlot:(int)slot completionHandler:(void (^)(NSString *errorStr))handler;
- (void)addMod:(Item *)modItem toItem:(Item *)modableItem toSlot:(int)slot completionHandler:(void (^)(NSString *errorStr))handler;
- (void)dropItemWithGuid:(NSString *)guid completionHandler:(void (^)(void))handler;
- (void)pickUpItemWithGuid:(NSString *)guid completionHandler:(void (^)(NSString *errorStr))handler;
- (void)recycleItem:(Item *)item completionHandler:(void (^)(void))handler;
- (void)usePowerCube:(PowerCube *)powerCube completionHandler:(void (^)(void))handler;
- (void)rechargePortal:(Portal *)portal slots:(NSArray *)slots completionHandler:(void (^)(NSString *errorStr))handler;
- (void)remoteRechargePortal:(Portal *)portal portalKey:(PortalKey *)portalKey completionHandler:(void (^)(NSString *errorStr))handler;
- (void)queryLinkabilityForPortal:(Portal *)portal portalKey:(PortalKey *)portalKey completionHandler:(void (^)(NSString *errorStr))handler;
- (void)linkPortal:(Portal *)portal withPortalKey:(PortalKey *)portalKey completionHandler:(void (^)(NSString *errorStr))handler;
- (void)setNotificationSettingsWithCompletionHandler:(void (^)(void))handler;
- (void)getModifiedEntitiesByGuid:(NSString *)guid completionHandler:(void (^)(void))handler;
- (void)flipPortal:(Portal *)portal withFlipCard:(FlipCard *)flipCard completionHandler:(void (^)(void))handler;
- (void)cheatSetPlayerLevel;

- (void)sendRequest:(NSString *)requestName params:(id)params completionHandler:(void (^)(id responseObj))handler;

- (void)processInventory:(NSArray *)inventory;
- (void)processGameEntities:(NSArray *)gameEntities;
- (void)processPlayerEntity:(NSArray *)inventory;
- (void)processEnergyGlobGuids:(NSArray *)energyGlobGuids;
- (void)processAPGains:(NSArray *)apGains;
- (void)processPlayerDamages:(NSArray *)playerDamages;
- (void)processDeletedEntityGuids:(NSArray *)deletedEntityGuids;

@end

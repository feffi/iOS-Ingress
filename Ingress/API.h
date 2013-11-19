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

FOUNDATION_EXPORT NSString *const DeviceSoundLevel;
FOUNDATION_EXPORT NSString *const DeviceSoundToggleBackground;
FOUNDATION_EXPORT NSString *const DeviceSoundToggleEffects;
FOUNDATION_EXPORT NSString *const DeviceSoundToggleSpeech;
FOUNDATION_EXPORT NSString *const IGMapDayMode;
FOUNDATION_EXPORT NSString *const MilesOrKM;

typedef void (^SoundCompletionBlock)(void);

@interface API : NSObject <AVAudioPlayerDelegate, MTStatusBarOverlayDelegate> {
	
	AVAudioPlayer *_backgroundAudioPlayer;
	AVAudioPlayer *_audioPlayer;
	SoundCompletionBlock soundCompletionHandlerBlock;
	
}

@property (nonatomic, strong) NSOperationQueue *networkQueue;
@property (nonatomic, strong) NSString *xsrfToken;
@property (nonatomic, strong) NSString *SACSID;
@property (nonatomic, strong) NSMutableArray *energyToCollect;
@property (nonatomic, readonly) long long currentTimestamp;

+ (instancetype)sharedInstance;

- (void)incrementNetworkActivityCount;
- (void)decrementNetworkActivityCount;

+ (NSDictionary *)sounds;
+ (float)durationOfSound:(NSString *)soundName;
+ (NSArray *)soundsForNumber:(int)number;
//- (void)playBackgroundMusic;
//- (void)playSoundNamed:(NSString *)name completionHandler:(void (^)(void))handler;
- (void)playSound:(NSString *)soundName;
- (void)playSounds:(NSArray *)soundNames;

- (NSString *)currentE6Location;

- (Player *)playerForContext:(NSManagedObjectContext *)context;

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
- (void)addMod:(Mod *)modItem toItem:(Portal *)modableItem toSlot:(int)slot completionHandler:(void (^)(NSString *errorStr))handler;
- (void)removeModFromItem:(Portal *)modableItem atSlot:(int)slot completionHandler:(void (^)(NSString *errorStr))handler;
- (void)dropItemWithGuid:(NSString *)guid completionHandler:(void (^)(void))handler;
- (void)pickUpItemWithGuid:(NSString *)guid completionHandler:(void (^)(NSString *errorStr))handler;
- (void)recycleItem:(Item *)item completionHandler:(void (^)(void))handler;
- (void)usePowerCube:(PowerCube *)powerCube completionHandler:(void (^)(void))handler;
- (void)rechargePortal:(Portal *)portal slots:(NSArray *)slots completionHandler:(void (^)(NSString *errorStr))handler;
- (void)remoteRechargePortal:(Portal *)portal portalKey:(PortalKey *)portalKey completionHandler:(void (^)(NSString *errorStr))handler;
- (void)queryLinkabilityForPortal:(Portal *)portal portalKey:(PortalKey *)portalKey completionHandler:(void (^)(NSString *errorStr))handler;
- (void)linkPortal:(Portal *)portal withPortalKey:(PortalKey *)portalKey completionHandler:(void (^)(NSString *errorStr))handler;
- (void)setNotificationSettingsWithCompletionHandler:(void (^)(void))handler;
- (void)getModifiedEntity:(Portal *)item completionHandler:(void (^)(void))handler;
- (void)flipPortal:(Portal *)portal withFlipCard:(FlipCard *)flipCard completionHandler:(void (^)(NSString *errorStr))handler;
- (void)setPortalDetailsForCurationWithParams:(NSDictionary *)params completionHandler:(void (^)(NSString *errorStr))handler;
- (void)getUploadUrl:(void (^)(NSString *url))handler;
- (void)uploadPortalPhotoByUrlWithRequestId:(NSString *)requestId imageUrl:(NSString *)imageUrl completionHandler:(void (^)(NSString *errorStr))handler;
- (void)uploadPortalImage:(UIImage *)image toURL:(NSString *)url completionHandler:(void (^)(void))handler;
- (void)findNearbyPortalsWithCompletionHandler:(void (^)(NSArray *portals))handler;
- (void)cheatSetPlayerLevel;

- (void)sendRequest:(NSString *)requestName params:(id)params completionHandler:(void (^)(id responseObj))handler;

- (void)processGameBasket:(NSDictionary *)gameBasket completion:(MRSaveCompletionHandler)completion;
- (void)processInventory:(NSArray *)inventory context:(NSManagedObjectContext *)context;
- (void)processGameEntities:(NSArray *)gameEntities context:(NSManagedObjectContext *)context;
- (void)processPlayerEntity:(NSArray *)inventory context:(NSManagedObjectContext *)context;
- (void)processEnergyGlobGuids:(NSArray *)energyGlobGuids context:(NSManagedObjectContext *)context;
- (void)processDeletedEntityGuids:(NSArray *)deletedEntityGuids context:(NSManagedObjectContext *)context;
- (void)processAPGains:(NSArray *)apGains;
- (void)processPlayerDamages:(NSArray *)playerDamages;

@end

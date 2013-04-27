//
//  DB.h
//  Ingress
//
//  Created by Alex Studnicka on 24.01.13.
//  Copyright (c) 2013 A&A Code. All rights reserved.
//

#import <CoreData/CoreData.h>

#import "Resonator.h"
#import "DeployedShield.h"
#import "Player.h"
#import "PortalKey.h"
#import "DeployedMod.h"
#import "DeployedResonator.h"
#import "Item.h"
#import "XMP.h"
#import "Media.h"
#import "Portal.h"
#import "User.h"
#import "Shield.h"
#import "EnergyGlob.h"
#import "PortalLink.h"
#import "ControlField.h"
#import "PowerCube.h"

#import "ColorOverlay.h"

typedef enum {
	PortalShieldRarityCommon,
	PortalShieldRarityRare,
	PortalShieldRarityVeryRare,
	PortalShieldRarityUnknown
} PortalShieldRarity;

@interface DB : NSObject

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

+ (NSURL *)applicationDocumentsDirectory;

+ (DB *)sharedInstance;

- (void)saveContext;

////////////////////////

//- (void)addEnergyGlobWithGuid:(NSString *)guid;
//- (void)addResonatorWithGUID:(NSString *)guid level:(NSInteger)level;
//- (void)addXMPWithGUID:(NSString *)guid level:(NSInteger)level;
//- (void)addPortalShieldWithGUID:(NSString *)guid rarity:(PortalShieldRarity)rarity;
//- (void)addPortalKeyWithGUID:(NSString *)guid forPortal:(Portal *)portal;

////////////////////////

- (NSInteger)numberOfEnergyGlobs;
- (NSInteger)numberOfResonatorsOfLevel:(NSInteger)level;
- (NSInteger)numberOfXMPsOfLevel:(NSInteger)level;
- (NSInteger)numberOfPortalShieldsOfRarity:(PortalShieldRarity)rarity;
- (NSInteger)numberOfMediaItems;
- (NSInteger)numberOfResonatorsOfPortal:(Portal *)portal;
- (NSInteger)numberOfPowerCubesOfLevel:(NSInteger)level;

////////////////////////

- (Item *)getItemWithGuid:(NSString *)guid;
- (Item *)getOrCreateItemWithGuid:(NSString *)guid classStr:(NSString *)classStr;

//- (Portal *)portalWithGuid:(NSString *)guid;
- (DeployedResonator *)deployedResonatorForPortal:(Portal *)portal atSlot:(int)slot shouldCreate:(BOOL)shouldCreate;
- (DeployedMod *)deployedModPortal:(Portal *)portal ofClass:(NSString *)classStr atSlot:(int)slot shouldCreate:(BOOL)shouldCreate;
- (NSArray *)deployedResonatorsForPortal:(Portal *)portal;
- (NSArray *)getEnergyGlobs:(int)count;
- (User *)userWithGuid:(NSString *)guid shouldCreate:(BOOL)shouldCreate;
- (User *)userWhoCapturedPortal:(Portal *)portal;
- (NSArray *)portalsForControlField:(ControlField *)controlField;

////////////////////////

- (Resonator *)getRandomResonatorOfLevel:(NSInteger)level;
- (XMP *)getRandomXMPOfLevel:(NSInteger)level;
- (Shield *)getRandomShieldOfRarity:(PortalShieldRarity)rarity;
- (PowerCube *)getRandomPowerCubeOfLevel:(NSInteger)level;

////////////////////////

- (void)removeItemWithGuid:(NSString *)guid;
- (void)removeAllMapData;
- (void)removeAllEnergyGlobs;

////////////////////////

- (void)addPortalsToMapView;

////////////////////////

- (NSArray *)fetchObjectsForEntityName:(NSString *)newEntityName withPredicate:(id)stringOrPredicate, ...;
- (NSUInteger)numberOfObjectsForEntityName:(NSString *)newEntityName withPredicate:(id)stringOrPredicate, ...;

@end

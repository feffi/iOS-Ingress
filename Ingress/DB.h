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

- (Item *)getItemWithGuid:(NSString *)guid;
- (Item *)getOrCreateItemWithGuid:(NSString *)guid classStr:(NSString *)classStr;

- (NSArray *)getEnergyGlobs:(int)count;

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

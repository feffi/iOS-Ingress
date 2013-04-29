//
//  Portal.h
//  Ingress
//
//  Created by Alex Studnicka on 24.01.13.
//  Copyright (c) 2013 A&A Code. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "Item.h"

@class DeployedMod, DeployedResonator, PortalKey, User;

@interface Portal : Item <MKAnnotation, MKOverlay>

@property (nonatomic, retain) NSString * controllingTeam;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * address;
@property (nonatomic, retain) NSString * imageURL;
@property (nonatomic, retain) User *capturedBy;
@property (nonatomic, retain) NSSet *portalKeys;
@property (nonatomic, retain) NSSet *mods;
@property (nonatomic, retain) NSSet *resonators;
@property (nonatomic, retain) NSSet *destinationForLinks;
@property (nonatomic, retain) NSSet *originForLinks;
@property (nonatomic, retain) NSSet *vertexForControlFields;
@property (nonatomic) BOOL completeInfo;

@property (nonatomic, readonly) NSInteger level;
@property (nonatomic, readonly) NSInteger range;
@property (nonatomic, readonly) float energy;

@property (nonatomic, readonly) MKMapRect boundingMapRect;

@end

@interface Portal (CoreDataGeneratedAccessors)

- (void)addPortalKeysObject:(PortalKey *)value;
- (void)removePortalKeysObject:(PortalKey *)value;
- (void)addPortalKeys:(NSSet *)values;
- (void)removePortalKeys:(NSSet *)values;

- (void)addModsObject:(DeployedMod *)value;
- (void)removeModsObject:(DeployedMod *)value;
- (void)addMods:(NSSet *)values;
- (void)removeMods:(NSSet *)values;

- (void)addResonatorsObject:(DeployedResonator *)value;
- (void)removeResonatorsObject:(DeployedResonator *)value;
- (void)addResonators:(NSSet *)values;
- (void)removeResonators:(NSSet *)values;

@end

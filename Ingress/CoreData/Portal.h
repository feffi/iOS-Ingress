//
//  Portal.h
//  Ingress
//
//  Created by Alex Studnička on 06.06.13.
//  Copyright (c) 2013 A&A Code. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class ControlField, DeployedMod, DeployedResonator, PortalKey, PortalLink, User;

@interface Portal : NSManagedObject <MKAnnotation, MKOverlay>

@property (nonatomic, retain) NSString * address;
@property (nonatomic) BOOL completeInfo;
@property (nonatomic, retain) NSString * controllingTeam;
@property (nonatomic, retain) NSString * imageURL;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * guid;
@property (nonatomic) CLLocationDegrees latitude;
@property (nonatomic) CLLocationDegrees longitude;
@property (nonatomic) NSTimeInterval timestamp;
@property (nonatomic, retain) User *capturedBy;
@property (nonatomic, retain) NSSet *destinationForLinks;
@property (nonatomic, retain) NSSet *mods;
@property (nonatomic, retain) NSSet *originForLinks;
@property (nonatomic, retain) NSSet *portalKeys;
@property (nonatomic, retain) NSSet *resonators;
@property (nonatomic, retain) NSSet *vertexForControlFields;

@property (nonatomic, readonly) NSInteger level;
@property (nonatomic, readonly) NSInteger range;
@property (nonatomic, readonly) float energy;

@property (nonatomic, readonly) MKMapRect boundingMapRect;

@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;

@property (nonatomic, readonly) BOOL isInPlayerRange;

- (CLLocationDistance)distanceFromCoordinate:(CLLocationCoordinate2D)coordinate;

@end

@interface Portal (CoreDataGeneratedAccessors)

- (void)addDestinationForLinksObject:(PortalLink *)value;
- (void)removeDestinationForLinksObject:(PortalLink *)value;
- (void)addDestinationForLinks:(NSSet *)values;
- (void)removeDestinationForLinks:(NSSet *)values;

- (void)addModsObject:(DeployedMod *)value;
- (void)removeModsObject:(DeployedMod *)value;
- (void)addMods:(NSSet *)values;
- (void)removeMods:(NSSet *)values;

- (void)addOriginForLinksObject:(PortalLink *)value;
- (void)removeOriginForLinksObject:(PortalLink *)value;
- (void)addOriginForLinks:(NSSet *)values;
- (void)removeOriginForLinks:(NSSet *)values;

- (void)addPortalKeysObject:(PortalKey *)value;
- (void)removePortalKeysObject:(PortalKey *)value;
- (void)addPortalKeys:(NSSet *)values;
- (void)removePortalKeys:(NSSet *)values;

- (void)addResonatorsObject:(DeployedResonator *)value;
- (void)removeResonatorsObject:(DeployedResonator *)value;
- (void)addResonators:(NSSet *)values;
- (void)removeResonators:(NSSet *)values;

- (void)addVertexForControlFieldsObject:(ControlField *)value;
- (void)removeVertexForControlFieldsObject:(ControlField *)value;
- (void)addVertexForControlFields:(NSSet *)values;
- (void)removeVertexForControlFields:(NSSet *)values;

@end

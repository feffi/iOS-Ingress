//
//  User.h
//  Ingress
//
//  Created by Alex Studnička on 23.05.13.
//  Copyright (c) 2013 A&A Code. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class ControlField, DeployedMod, DeployedResonator, Plext, Portal, PortalLink;

@interface User : NSManagedObject

@property (nonatomic, retain) NSString * guid;
@property (nonatomic, retain) NSString * nickname;
@property (nonatomic, retain) NSString * team;
@property (nonatomic, retain) NSSet *capturedPortals;
@property (nonatomic, retain) NSSet *createdControlFields;
@property (nonatomic, retain) NSSet *createdLinks;
@property (nonatomic, retain) NSSet *deployedMods;
@property (nonatomic, retain) NSSet *deployedResonators;
@property (nonatomic, retain) NSSet *sentPlexts;
@end

@interface User (CoreDataGeneratedAccessors)

- (void)addCapturedPortalsObject:(Portal *)value;
- (void)removeCapturedPortalsObject:(Portal *)value;
- (void)addCapturedPortals:(NSSet *)values;
- (void)removeCapturedPortals:(NSSet *)values;

- (void)addCreatedControlFieldsObject:(ControlField *)value;
- (void)removeCreatedControlFieldsObject:(ControlField *)value;
- (void)addCreatedControlFields:(NSSet *)values;
- (void)removeCreatedControlFields:(NSSet *)values;

- (void)addCreatedLinksObject:(PortalLink *)value;
- (void)removeCreatedLinksObject:(PortalLink *)value;
- (void)addCreatedLinks:(NSSet *)values;
- (void)removeCreatedLinks:(NSSet *)values;

- (void)addDeployedModsObject:(DeployedMod *)value;
- (void)removeDeployedModsObject:(DeployedMod *)value;
- (void)addDeployedMods:(NSSet *)values;
- (void)removeDeployedMods:(NSSet *)values;

- (void)addDeployedResonatorsObject:(DeployedResonator *)value;
- (void)removeDeployedResonatorsObject:(DeployedResonator *)value;
- (void)addDeployedResonators:(NSSet *)values;
- (void)removeDeployedResonators:(NSSet *)values;

- (void)addSentPlextsObject:(Plext *)value;
- (void)removeSentPlextsObject:(Plext *)value;
- (void)addSentPlexts:(NSSet *)values;
- (void)removeSentPlexts:(NSSet *)values;

@end

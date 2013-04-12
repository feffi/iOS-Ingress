//
//  ControlField.h
//  Ingress
//
//  Created by Alex Studnicka on 24.01.13.
//  Copyright (c) 2013 A&A Code. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Portal, User;

@interface ControlField : NSManagedObject

@property (nonatomic, retain) NSString * guid;
@property (nonatomic, retain) NSString * controllingTeam;
@property (nonatomic) int16_t entityScore;
@property (nonatomic, retain) NSSet *portals;
@property (nonatomic, retain) User *creator;

@property (nonatomic, readonly) MKPolygon *polygon;

@end

@interface ControlField (CoreDataGeneratedAccessors)

- (void)addPortalsObject:(Portal *)value;
- (void)removePortalsObject:(Portal *)value;
- (void)addPortals:(NSSet *)values;
- (void)removePortals:(NSSet *)values;

@end

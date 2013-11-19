//
//  DeployedResonator.h
//  Ingress
//
//  Created by Alex Studnicka on 24.01.13.
//  Copyright (c) 2013 A&A Code. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Portal, User;

@interface DeployedResonator : NSManagedObject

@property (nonatomic) int16_t distanceToPortal;
@property (nonatomic) int16_t energy;
@property (nonatomic) int16_t level;
@property (nonatomic) int16_t maxEnergy;
@property (nonatomic) int16_t slot;
@property (nonatomic, retain) User *owner;
@property (nonatomic, retain) Portal *portal;

@property (nonatomic, readonly) MKCircle *circle;

- (void)updateWithData:(NSDictionary *)data forPortal:(Portal *)portal context:(NSManagedObjectContext *)context;
+ (instancetype)resonatorWithData:(NSDictionary *)data forPortal:(Portal *)portal context:(NSManagedObjectContext *)context;

@end

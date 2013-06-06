//
//  EnergyGlob.h
//  Ingress
//
//  Created by Alex Studnička on 09.05.13.
//  Copyright (c) 2013 A&A Code. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "Item.h"


@interface EnergyGlob : NSManagedObject

@property (nonatomic) int32_t amount;
@property (nonatomic, retain) NSString * guid;
@property (nonatomic) CLLocationDegrees latitude;
@property (nonatomic) CLLocationDegrees longitude;

@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;

- (void)updateWithData:(NSString *)guid;
+ (instancetype)energyGlobWithData:(NSString *)guid inManagedObjectContext:(NSManagedObjectContext *)context;

- (CLLocationDistance)distanceFromCoordinate:(CLLocationCoordinate2D)coordinate;

@end

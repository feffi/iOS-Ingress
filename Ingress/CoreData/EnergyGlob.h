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


@interface EnergyGlob : Item

@property (nonatomic) int32_t amount;

- (void)updateWithData:(NSString *)guid;
+ (instancetype)energyGlobWithData:(NSString *)guid inManagedObjectContext:(NSManagedObjectContext *)context;

@end

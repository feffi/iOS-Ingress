//
//  DeployedMod.h
//  Ingress
//
//  Created by Alex Studnicka on 24.01.13.
//  Copyright (c) 2013 A&A Code. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Portal, User;

@interface DeployedMod : NSManagedObject

@property (nonatomic) int16_t slot;
@property (nonatomic) int16_t rarity;
@property (nonatomic, readonly) NSString *rarityStr;
@property (nonatomic, retain) User *owner;
@property (nonatomic, retain) Portal *portal;

@end

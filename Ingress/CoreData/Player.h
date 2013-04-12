//
//  Player.h
//  Ingress
//
//  Created by Alex Studnicka on 24.01.13.
//  Copyright (c) 2013 A&A Code. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "User.h"


@interface Player : User

@property (nonatomic) int16_t ap;
@property (nonatomic) int16_t energy;
@property (nonatomic) int16_t level;
@property (nonatomic) int16_t maxEnergy;
@property (nonatomic) int16_t nextLevelAP;

@end

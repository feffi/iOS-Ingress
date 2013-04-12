//
//  Shield.h
//  Ingress
//
//  Created by Alex Studnicka on 24.01.13.
//  Copyright (c) 2013 A&A Code. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "Item.h"


@interface Shield : Item

@property (nonatomic) int16_t rarity;
@property (nonatomic, readonly) NSString *rarityStr;

@end

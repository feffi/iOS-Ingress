//
//  PortalKey.h
//  Ingress
//
//  Created by Alex Studnicka on 24.01.13.
//  Copyright (c) 2013 A&A Code. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "Item.h"

@class Portal;

@interface PortalKey : Item

@property (nonatomic, retain) Portal *portal;

@end

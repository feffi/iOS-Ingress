//
//  Media.h
//  Ingress
//
//  Created by Alex Studnicka on 24.01.13.
//  Copyright (c) 2013 A&A Code. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "Item.h"


@interface Media : Item

@property (nonatomic, retain) NSString * name;
@property (nonatomic) int16_t level;
@property (nonatomic, retain) NSString * imageURL;
@property (nonatomic, retain) NSString * url;
@property (nonatomic, readonly) NSURL * mediaURL;

@end

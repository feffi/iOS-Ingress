//
//  Plext.h
//  Ingress
//
//  Created by Alex Studnička on 13.05.13.
//  Copyright (c) 2013 A&A Code. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Plext : NSManagedObject

@property (nonatomic) NSTimeInterval date;
@property (nonatomic) BOOL factionOnly;
@property (nonatomic, retain) NSString * guid;
@property (nonatomic) BOOL mentionsYou;
@property (nonatomic, retain) NSAttributedString *message;
@property (nonatomic, retain) User *sender;

@end

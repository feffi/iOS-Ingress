//
//  Message.h
//  Ingress
//
//  Created by Alex Studnička on 12.05.13.
//  Copyright (c) 2013 A&A Code. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Message : NSManagedObject

@property (nonatomic, retain) NSString * guid;
@property (nonatomic, retain) NSAttributedString *message;
@property (nonatomic) BOOL factionOnly;
@property (nonatomic) NSTimeInterval date;
@property (nonatomic) BOOL mentionsYou;

@end

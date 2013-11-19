//
//  CommTableViewController.h
//  Ingress
//
//  Created by Alex Studnicka on 10.01.13.
//  Copyright (c) 2013 A&A Code. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CommTableViewCell.h"

@interface CommTableViewController : UITableViewController <NSFetchedResultsControllerDelegate>

@property (nonatomic) BOOL factionOnly;
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;

- (void)refresh;

@end

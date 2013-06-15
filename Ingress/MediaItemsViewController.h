//
//  MediaItemsViewController.h
//  Ingress
//
//  Created by Alex Studnicka on 23.01.13.
//  Copyright (c) 2013 A&A Code. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MediaItemsViewController : UITableViewController <NSFetchedResultsControllerDelegate, UIActionSheetDelegate>

@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;

@end

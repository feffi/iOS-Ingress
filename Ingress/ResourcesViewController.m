//
//  NewResourcesViewController.m
//  Ingress
//
//  Created by Alex Studnička on 14.04.13.
//  Copyright (c) 2013 A&A Code. All rights reserved.
//

#import "ResourcesViewController.h"
#import "ResourceCell.h"

@implementation ResourcesViewController

- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];

	[self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	switch (indexPath.row) {
		case 0: {
			ResourceCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LevelsItemCell" forIndexPath:indexPath];
			cell.itemImageView.image = [UIImage imageNamed:@"resonator@2x.png"];
			cell.itemType = ItemTypeResonator;
			return cell;
		}
		case 1: {
			ResourceCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LevelsItemCell" forIndexPath:indexPath];
			cell.itemImageView.image = [UIImage imageNamed:@"xmp@2x.png"];
			cell.itemType = ItemTypeXMP;
			return cell;
		}
		case 2: {
			ResourceCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RarityItemCell" forIndexPath:indexPath];
			cell.itemImageView.image = [UIImage imageNamed:@"shield@2x.png"];
			cell.itemType = ItemTypePortalShield;
			return cell;
		}
		case 3: {
			ResourceCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LevelsItemCell" forIndexPath:indexPath];
			cell.itemImageView.image = [UIImage imageNamed:@"powerCube@2x.png"];
			cell.itemType = ItemTypePowerCube;
			return cell;
		}
		default:
			return nil;
	}
}

@end

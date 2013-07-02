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

//#if __IPHONE_OS_VERSION_MAX_ALLOWED < 70000
    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 32, 0);
    self.tableView.scrollIndicatorInsets = self.tableView.contentInset;
//#endif
    
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
    return 10;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	switch (indexPath.row) {
		case 0: {
			ResourceCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LevelsItemCell" forIndexPath:indexPath];
			cell.itemImageView.image = [UIImage imageNamed:@"resonator.png"];
			cell.itemTitleLabel.text = @"Resonator";
			cell.itemType = ItemTypeResonator;
			return cell;
		}
		case 1: {
			ResourceCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LevelsItemCell" forIndexPath:indexPath];
			cell.itemImageView.image = [UIImage imageNamed:@"xmp.png"];
			cell.itemTitleLabel.text = @"XMP Burster";
			cell.itemType = ItemTypeXMP;
			return cell;
		}
		case 2: {
			ResourceCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LevelsItemCell" forIndexPath:indexPath];
			cell.itemImageView.image = [UIImage imageNamed:@"powerCube.png"];
			cell.itemTitleLabel.text = @"Power Cube";
			cell.itemType = ItemTypePowerCube;
			return cell;
		}
		case 3: {
			ResourceCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SingleItemCell" forIndexPath:indexPath];
			Player *player = [[API sharedInstance] playerForContext:[NSManagedObjectContext MR_contextForCurrentThread]];
			if ([player.team isEqualToString:@"ALIENS"]) {
				cell.itemImageView.image = [UIImage imageNamed:@"jarvis_virus.png"];
			} else {
				cell.itemImageView.image = [UIImage imageNamed:@"ada_refactor.png"];
			}
			cell.itemTitleLabel.text = @"Alignment Virus";
			cell.itemType = ItemTypeFlipCard;
			return cell;
		}
		case 4: {
			ResourceCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RarityItemCell" forIndexPath:indexPath];
			cell.itemImageView.image = [UIImage imageNamed:@"shield.png"];
			cell.itemTitleLabel.text = @"Shield";
			cell.itemType = ItemTypePortalShield;
			return cell;
		}
		case 5: {
			ResourceCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RarityItemCell" forIndexPath:indexPath];
			cell.itemImageView.image = [UIImage imageNamed:@"link_amp.png"];
			cell.itemTitleLabel.text = @"Link Amp";
			cell.itemType = ItemTypeLinkAmp;
			return cell;
		}
		case 6: {
			ResourceCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RarityItemCell" forIndexPath:indexPath];
			cell.itemImageView.image = [UIImage imageNamed:@"force_amp.png"];
			cell.itemTitleLabel.text = @"Force Amp";
			cell.itemType = ItemTypeForceAmp;
			return cell;
		}
		case 7: {
			ResourceCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RarityItemCell" forIndexPath:indexPath];
			cell.itemImageView.image = [UIImage imageNamed:@"heatsink.png"];
			cell.itemTitleLabel.text = @"Heatsink";
			cell.itemType = ItemTypeHeatsink;
			return cell;
		}
		case 8: {
			ResourceCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RarityItemCell" forIndexPath:indexPath];
			cell.itemImageView.image = [UIImage imageNamed:@"multihack.png"];
			cell.itemTitleLabel.text = @"Multi-hack";
			cell.itemType = ItemTypeMultihack;
			return cell;
		}
		case 9: {
			ResourceCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RarityItemCell" forIndexPath:indexPath];
			cell.itemImageView.image = [UIImage imageNamed:@"turret.png"];
			cell.itemTitleLabel.text = @"Turret";
			cell.itemType = ItemTypeTurret;
			return cell;
		}
		default:
			return nil;
	}
}

@end

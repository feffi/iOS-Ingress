//
//  MissionsViewController.m
//  Ingress
//
//  Created by Alex Studnicka on 12.01.13.
//  Copyright (c) 2013 A&A Code. All rights reserved.
//

#import "MissionsViewController.h"
#import "MissionViewController.h"

@implementation MissionsViewController {
	int selectedMission;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
	// self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDataSource * UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return [super numberOfSectionsInTableView:tableView];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [super tableView:tableView numberOfRowsInSection:section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    //static NSString *CellIdentifier = @"Cell";
    //UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
	UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
	
	cell.textLabel.font = [UIFont fontWithName:[[[UILabel appearance] font] fontName] size:18];
    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[[SoundManager sharedManager] playSound:@"Sound/sfx_ui_success.aif"];
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	UIActionSheet *actionSheet = nil;
	switch (indexPath.row) {
		case 0: {

			actionSheet = [[UIActionSheet alloc] initWithTitle:@"First contact from ADA." delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"View Briefing", nil];

			break;
		}
		case 1: {

			actionSheet = [[UIActionSheet alloc] initWithTitle:@"Charge your Scanner by collecting XM around you" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"View Briefing", nil];

			break;
		}
		case 2: {

			actionSheet = [[UIActionSheet alloc] initWithTitle:@"Walk to a Portal and hack it for supplies" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"View Briefing", nil];

			break;
		}
		case 3: {

			actionSheet = [[UIActionSheet alloc] initWithTitle:@"Attack an enemy Portal with an XMP" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"View Briefing", nil];

			break;
		}
		case 4: {

			actionSheet = [[UIActionSheet alloc] initWithTitle:@"Bind Portal by deploying Resonator" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"View Briefing", nil];

			break;
		}
		case 5: {

			actionSheet = [[UIActionSheet alloc] initWithTitle:@"Preparing a Portal for linking" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"View Briefing", nil];

			break;
		}
		case 6: {

			actionSheet = [[UIActionSheet alloc] initWithTitle:@"Link two Portals" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"View Briefing", nil];

			break;
		}
		case 7: {

			actionSheet = [[UIActionSheet alloc] initWithTitle:@"Create a Field" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"View Briefing", nil];

			break;
		}
	}
	if (actionSheet) {
		[actionSheet setTag:indexPath.row+1];
		[actionSheet showFromTabBar:self.tabBarController.tabBar];
	}
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	[[SoundManager sharedManager] playSound:@"Sound/sfx_ui_success.aif"];
	if (actionSheet.tag >= 1 && actionSheet.tag <= 8 && buttonIndex == 0) {
		selectedMission = actionSheet.tag;
		[self performSegueWithIdentifier:@"MissionSegue" sender:self];
	}
}

#pragma mark - Storyboard

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	if ([segue.identifier isEqualToString:@"MissionSegue"]) {
		[[SoundManager sharedManager] playSound:@"Sound/sfx_ui_success.aif"];

		MissionViewController *vc = segue.destinationViewController;
		vc.factionChoose = NO;
		vc.mission = selectedMission;
	}
}

@end

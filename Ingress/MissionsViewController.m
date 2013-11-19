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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
	cell.textLabel.font = [UIFont fontWithName:[[[UILabel appearance] font] fontName] size:18];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([[NSUserDefaults standardUserDefaults] boolForKey:DeviceSoundToggleEffects]) {
        [[SoundManager sharedManager] playSound:@"Sound/sfx_ui_success.aif"];
    }
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
		[actionSheet showInView:self.view.window];
	}
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if ([[NSUserDefaults standardUserDefaults] boolForKey:DeviceSoundToggleEffects]) {
        [[SoundManager sharedManager] playSound:@"Sound/sfx_ui_success.aif"];
    }
	if (actionSheet.tag >= 1 && actionSheet.tag <= 8 && buttonIndex == 0) {
		selectedMission = actionSheet.tag;
		[self performSegueWithIdentifier:@"MissionSegue" sender:self];
	}
}

#pragma mark - Storyboard

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	if ([segue.identifier isEqualToString:@"MissionSegue"]) {
        if ([[NSUserDefaults standardUserDefaults] boolForKey:DeviceSoundToggleEffects]) {
            [[SoundManager sharedManager] playSound:@"Sound/sfx_ui_success.aif"];
        }

		MissionViewController *vc = segue.destinationViewController;
		vc.factionChoose = NO;
		vc.mission = selectedMission;
	}
}

@end

//
//  MediaItemsViewController.m
//  Ingress
//
//  Created by Alex Studnicka on 23.01.13.
//  Copyright (c) 2013 A&A Code. All rights reserved.
//

#import "MediaItemsViewController.h"
#import "MediaWebViewViewController.h"
#import "XCDYouTubeVideoPlayerViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>

@implementation MediaItemsViewController {
	Media *currentMedia;
}

- (void)viewDidLoad {
	[super viewDidLoad];

    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 32, 0);
    self.tableView.scrollIndicatorInsets = self.tableView.contentInset;

}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];

	[[NSNotificationCenter defaultCenter] addObserverForName:MPMoviePlayerPlaybackDidFinishNotification object:nil queue:nil usingBlock:^(NSNotification *note) {
        if ([[NSUserDefaults standardUserDefaults] boolForKey:DeviceSoundToggleBackground]) {
            [[SoundManager sharedManager] playMusic:@"Sound/sfx_ambient_scanner_base.aif" looping:YES];
        }
	}];
}

- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];

	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];

	self.fetchedResultsController = nil;
}

- (void)dealloc {
	self.fetchedResultsController = nil;
}

#pragma mark - NSFetchedResultsController & NSFetchedResultsControllerDelegate

- (NSFetchedResultsController *)fetchedResultsController {
	if (_fetchedResultsController != nil) {
		return _fetchedResultsController;
	}
	_fetchedResultsController = [Media MR_fetchAllSortedBy:@"level" ascending:NO withPredicate:nil groupBy:nil delegate:self];
	return _fetchedResultsController;
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView beginUpdates];
}


- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    
	UITableView *tableView = self.tableView;
	
	switch(type) {
		case NSFetchedResultsChangeInsert:
			[tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationLeft];
			break;
			
		case NSFetchedResultsChangeDelete:
			[tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
			break;
			
		case NSFetchedResultsChangeUpdate:
			[tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
			break;
			
		case NSFetchedResultsChangeMove:
			[tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
			[tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
			break;
	}
	
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id )sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
	
    switch(type) {
			
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
			
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}


- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView endUpdates];
}

#pragma mark - UITableViewDataSource & UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return self.fetchedResultsController.sections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController.sections objectAtIndex:section];
	return sectionInfo.numberOfObjects;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MediaItemCell" forIndexPath:indexPath];
	
	Media *media = [self.fetchedResultsController objectAtIndexPath:indexPath];
	
	cell.textLabel.text = [NSString stringWithFormat:@"L%d %@", media.level, media.name];
	cell.detailTextLabel.text = media.url; //[media.url substringFromIndex:49];
	
//	cell.imageView.image = [UIImage imageNamed:@"missing_image"];
	
//	NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:media.imageURL]];
//	[NSURLConnection sendAsynchronousRequest:request queue:[API sharedInstance].networkQueue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
//		dispatch_async(dispatch_get_main_queue(), ^{
//			cell.imageView.image =  [UIImage imageWithData:data];
//		});
//	}];

	[cell.imageView setImageWithURL:[NSURL URLWithString:media.imageURL] placeholderImage:[UIImage imageNamed:@"missing_image"]];

    return cell;
	
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:YES];

    if ([[NSUserDefaults standardUserDefaults] boolForKey:DeviceSoundToggleEffects]) {
        [[SoundManager sharedManager] playSound:@"Sound/sfx_ui_success.aif"];
    }
	
	currentMedia = [self.fetchedResultsController objectAtIndexPath:indexPath];

	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Drop" otherButtonTitles:@"Recycle", @"View", nil];
	actionSheet.tag = 1;
	[actionSheet showInView:self.view.window];

}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if ([[NSUserDefaults standardUserDefaults] boolForKey:DeviceSoundToggleEffects]) {
        [[SoundManager sharedManager] playSound:@"Sound/sfx_ui_success.aif"];
    }
	if (actionSheet.tag == 1 && buttonIndex == 0) {

		MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:[AppDelegate instance].window];
		HUD.removeFromSuperViewOnHide = YES;
		HUD.userInteractionEnabled = YES;
		HUD.mode = MBProgressHUDModeIndeterminate;
		HUD.dimBackground = YES;
		HUD.labelFont = [UIFont fontWithName:[[[UILabel appearance] font] fontName] size:16];
		HUD.labelText = @"Dropping Item...";
		[[AppDelegate instance].window addSubview:HUD];
		[HUD show:YES];
        if ([[NSUserDefaults standardUserDefaults] boolForKey:DeviceSoundToggleEffects]) {
            [[API sharedInstance] playSound:@"SFX_DROP_RESOURCE"];
        }

		[[API sharedInstance] dropItemWithGuid:currentMedia.guid completionHandler:^(void) {
			[HUD hide:YES];

			[self.tableView reloadData];
		}];

	} else if (actionSheet.tag == 1 && buttonIndex == 1) {

		MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:[AppDelegate instance].window];
		HUD.removeFromSuperViewOnHide = YES;
		HUD.userInteractionEnabled = YES;
		HUD.mode = MBProgressHUDModeIndeterminate;
		HUD.dimBackground = YES;
		HUD.labelFont = [UIFont fontWithName:[[[UILabel appearance] font] fontName] size:16];
		HUD.labelText = @"Recycling Item...";
		[[AppDelegate instance].window addSubview:HUD];
		[HUD show:YES];

        if ([[NSUserDefaults standardUserDefaults] boolForKey:DeviceSoundToggleEffects]) {
            [[SoundManager sharedManager] playSound:[NSString stringWithFormat:@"Sound/sfx_recycle_%@.aif", arc4random_uniform(2) ? @"a" : @"b"]];
        }

		[[API sharedInstance] recycleItem:currentMedia completionHandler:^{
			[HUD hide:YES];

			[self.tableView reloadData];
		}];

	} else if (actionSheet.tag == 1 && buttonIndex == 2) {

		if ([currentMedia.mediaURL.host isEqualToString:@"www.youtube.com"]) {
			NSString *videoID = [currentMedia.url componentsSeparatedByString:@"v="][1];
			NSRange search = [videoID rangeOfString:@"&"];
			if (search.location != NSNotFound) {
				videoID = [videoID substringToIndex:search.location];
			}
			XCDYouTubeVideoPlayerViewController *videoPlayerViewController = [[XCDYouTubeVideoPlayerViewController alloc] initWithVideoIdentifier:videoID];
			[self presentMoviePlayerViewControllerAnimated:videoPlayerViewController];
			[[SoundManager sharedManager] stopMusic:YES];
		} else if ([currentMedia.mediaURL.lastPathComponent.pathExtension isEqualToString:@"mp3"]) {
			MPMoviePlayerViewController *audioPlayerViewController = [[MPMoviePlayerViewController alloc] initWithContentURL:currentMedia.mediaURL];
			[self presentMoviePlayerViewControllerAnimated:audioPlayerViewController];
			[[SoundManager sharedManager] stopMusic:YES];
		} else {
			[self performSegueWithIdentifier:@"MediaWebViewSegue" sender:self];
		}

	}
}


#pragma mark - Storyboard

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	if ([segue.identifier isEqualToString:@"MediaWebViewSegue"]) {
        if ([[NSUserDefaults standardUserDefaults] boolForKey:DeviceSoundToggleEffects]) {
            [[SoundManager sharedManager] playSound:@"Sound/sfx_ui_success.aif"];
        }

		UINavigationController *navC = segue.destinationViewController;
		MediaWebViewViewController *vc = (MediaWebViewViewController *)navC.topViewController;
		vc.media = currentMedia;
	}
}

@end

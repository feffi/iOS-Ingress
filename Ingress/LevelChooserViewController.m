//
//  LevelsButtonsViewController.m
//  Ingress
//
//  Created by Alex Studnicka on 19.01.13.
//  Copyright (c) 2013 A&A Code. All rights reserved.
//

#import "LevelChooserViewController.h"

@implementation LevelChooserViewController

@synthesize levelChooserCompletionHandler = _levelChooserCompletionHandler;
@synthesize rarityChooserCompletionHandler = _rarityChooserCompletionHandler;

+ (LevelChooserViewController *)levelChooserWithTitle:(NSString *)title completionHandler:(void (^)(int level))handler {
	UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil];
	LevelChooserViewController *levelChooser = [storyboard instantiateViewControllerWithIdentifier:@"LevelChooserViewController"];
	levelChooser.view.frame = CGRectMake(0, 0, 240, 100);
	levelChooser.titleLabel.text = title;
	levelChooser.levelChooserCompletionHandler = handler;
	return levelChooser;
}

+ (LevelChooserViewController *)rarityChooserWithTitle:(NSString *)title completionHandler:(void (^)(ItemRarity rarity))handler {
	UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil];
	LevelChooserViewController *levelChooser = [storyboard instantiateViewControllerWithIdentifier:@"RarityChooserViewController"];
	levelChooser.view.frame = CGRectMake(0, 0, 240, 100);
	levelChooser.titleLabel.text = title;
	levelChooser.rarityChooserCompletionHandler = handler;
	return levelChooser;
}

- (void)viewDidLoad {
	[super viewDidLoad];
	
	switch (self.view.tag) {
		case 100: {

			Player *player = [[API sharedInstance] playerForContext:[NSManagedObjectContext MR_contextForCurrentThread]];
			int level = player.level;
			
			for (int i = 1; i <= 8; i++) {
				UIButton *button = (UIButton *)[self.view viewWithTag:i];
				if (i <= level) {
					[button setEnabled:YES];
				} else {
					[button setEnabled:NO];
				}
			}
			
			break;
		}
	}

}

- (void)viewDidLayoutSubviews {
	[super viewDidLayoutSubviews];

	for (UIView *view in self.view.subviews) {
		if ([view isKindOfClass:[UIButton class]]) {
			UIButton *button = (UIButton *)view;
			button.titleLabel.font = [UIFont fontWithName:[[[UIButton appearance] font] fontName] size:10];
			button.titleLabel.numberOfLines = 0;
			button.titleLabel.textAlignment = NSTextAlignmentCenter;
		}
	}
}

- (IBAction)action:(UIButton *)sender {
	
	switch (self.view.tag) {
		case 100:
			
			if (self.levelChooserCompletionHandler) {
				self.levelChooserCompletionHandler(sender.tag);
			}
			
			break;
		case 200:
			
			if (self.rarityChooserCompletionHandler) {
				self.rarityChooserCompletionHandler([Utilities rarityFromInt:sender.tag]);
			}
			
			break;
	}
	
}

@end

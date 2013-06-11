//
//  LevelsButtonsViewController.m
//  Ingress
//
//  Created by Alex Studnicka on 19.01.13.
//  Copyright (c) 2013 A&A Code. All rights reserved.
//

#import "ChooserViewController.h"

@implementation ChooserViewController

@synthesize numberChooserCompletionHandler = _numberChooserCompletionHandler;
@synthesize rarityChooserCompletionHandler = _rarityChooserCompletionHandler;

+ (ChooserViewController *)levelChooserWithTitle:(NSString *)title completionHandler:(void (^)(int level))handler {
	UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil];
	ChooserViewController *levelChooser = [storyboard instantiateViewControllerWithIdentifier:@"LevelChooserViewController"];
	levelChooser.view.frame = CGRectMake(0, 0, 240, 100);
	levelChooser.titleLabel.text = title;
	levelChooser.numberChooserCompletionHandler = handler;
	return levelChooser;
}

+ (ChooserViewController *)rarityChooserWithTitle:(NSString *)title completionHandler:(void (^)(ItemRarity rarity))handler {
	UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil];
	ChooserViewController *levelChooser = [storyboard instantiateViewControllerWithIdentifier:@"RarityChooserViewController"];
	levelChooser.view.frame = CGRectMake(0, 0, 240, 100);
	levelChooser.titleLabel.text = title;
	levelChooser.rarityChooserCompletionHandler = handler;
	return levelChooser;
}

+ (ChooserViewController *)countChooserWithButtonTitle:(NSString *)buttonTitle maxCount:(int)maxCount completionHandler:(void (^)(int count))handler {
	UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil];
	ChooserViewController *levelChooser = [storyboard instantiateViewControllerWithIdentifier:@"CountChooserViewController"];
	levelChooser.view.frame = CGRectMake(0, 0, 240, 100);
	levelChooser.numberChooserCompletionHandler = handler;
	[levelChooser.countButton setTitle:buttonTitle forState:UIControlStateNormal];
	levelChooser.countButton.titleLabel.font = [UIFont fontWithName:[[[UILabel appearance] font] fontName] size:16];
	levelChooser.countStepper.maximumValue = maxCount;
	levelChooser.countStepper.value = (maxCount >= 1) ? 1 : 0;
	levelChooser.countLabel.text = [NSString stringWithFormat:@"%.0f / %.0f", levelChooser.countStepper.value, levelChooser.countStepper.maximumValue];
	return levelChooser;
}

- (void)viewDidLoad {
	[super viewDidLoad];
	
	if (self.view.tag == 100) {
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
	}

}

- (void)viewWillLayoutSubviews {
	[super viewDidLayoutSubviews];

	for (UIView *view in self.view.subviews) {
		if ([view isKindOfClass:[UIButton class]]) {
			UIButton *button = (UIButton *)view;
			if (self.view.tag == 200) {
				button.titleLabel.font = [UIFont fontWithName:[[[UILabel appearance] font] fontName] size:10];
			}
			button.titleLabel.numberOfLines = 0;
			button.titleLabel.textAlignment = NSTextAlignmentCenter;
		}
	}
}

- (IBAction)action:(UIButton *)sender {
	
	switch (self.view.tag) {
		case 100:
			
			if (self.numberChooserCompletionHandler) {
				self.numberChooserCompletionHandler(sender.tag);
			}
			
			break;
		case 200:
			
			if (self.rarityChooserCompletionHandler) {
				self.rarityChooserCompletionHandler([Utilities rarityFromInt:sender.tag]);
			}
			
			break;
		case 300:

			if (self.numberChooserCompletionHandler) {
				self.numberChooserCompletionHandler(self.countStepper.value);
			}
			
			break;
	}
	
}

- (IBAction)stepperChanged:(UIStepper *)sender {
	self.countLabel.text = [NSString stringWithFormat:@"%.0f / %.0f", self.countStepper.value, self.countStepper.maximumValue];

	if (self.countStepper.value > 0) {
		self.countButton.enabled = YES;
		self.countButton.errorString = nil;
	} else {
		self.countButton.enabled = NO;
		self.countButton.errorString = @"No items selected";
	}
}

@end

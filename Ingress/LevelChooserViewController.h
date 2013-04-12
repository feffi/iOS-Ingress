//
//  LevelsButtonsViewController.h
//  Ingress
//
//  Created by Alex Studnicka on 19.01.13.
//  Copyright (c) 2013 A&A Code. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LevelChooserViewController : UIViewController

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (copy, nonatomic) void (^levelChooserCompletionHandler)(int level);
@property (copy, nonatomic) void (^rarityChooserCompletionHandler)(PortalShieldRarity rarity);

+ (LevelChooserViewController *)levelChooserWithTitle:(NSString *)title completionHandler:(void (^)(int level))handler;
+ (LevelChooserViewController *)rarityChooserWithTitle:(NSString *)title completionHandler:(void (^)(PortalShieldRarity rarity))handler;

- (IBAction)action:(UIButton *)sender;

@end

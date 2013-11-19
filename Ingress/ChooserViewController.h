//
//  LevelsButtonsViewController.h
//  Ingress
//
//  Created by Alex Studnicka on 19.01.13.
//  Copyright (c) 2013 A&A Code. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GUIButton.h"

@interface ChooserViewController : UIViewController

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIStepper *countStepper;
@property (weak, nonatomic) IBOutlet UILabel *countLabel;
@property (weak, nonatomic) IBOutlet GUIButton *countButton;
@property (copy, nonatomic) void (^numberChooserCompletionHandler)(int number);
@property (copy, nonatomic) void (^rarityChooserCompletionHandler)(ItemRarity rarity);
@property (copy, nonatomic) void (^modChooserCompletionHandler)(ItemType modType);

+ (ChooserViewController *)levelChooserWithTitle:(NSString *)title completionHandler:(void (^)(int level))handler;
+ (ChooserViewController *)rarityChooserWithTitle:(NSString *)title completionHandler:(void (^)(ItemRarity rarity))handler;
+ (ChooserViewController *)countChooserWithButtonTitle:(NSString *)buttonTitle maxCount:(int)maxCount completionHandler:(void (^)(int count))handler;
+ (ChooserViewController *)modChooserWithTitle:(NSString *)title completionHandler:(void (^)(ItemType modType))handler;

- (IBAction)action:(UIButton *)sender;
- (IBAction)stepperChanged:(UIStepper *)sender;

@end

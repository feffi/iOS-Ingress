//
//  PortalUpgradeViewController.m
//  Ingress
//
//  Created by Alex Studnicka on 20.01.13.
//  Copyright (c) 2013 A&A Code. All rights reserved.
//

#import "PortalInfoViewController.h"

@implementation PortalInfoViewController

@synthesize portal = _portal;

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	[self refresh];
}

#pragma mark - Refresh

- (void)refresh {
	
	for (int i = 0; i < 8; i++) {
		
		UILabel *levelLabel = (UILabel *)[self.view viewWithTag:10+i];
		levelLabel.font = [UIFont fontWithName:[[[UILabel appearance] font] fontName] size:14];
		levelLabel.text = @"";
		
		UIImageView *resonatorImage = (UIImageView *)[self.view viewWithTag:30+i];
		[resonatorImage setHidden:YES];
		
		UIImageView *progressView = (UIImageView *)[self.view viewWithTag:40+i];
		if ([self.portal.controllingTeam isEqualToString:@"ALIENS"]) {
			progressView.image = [UIImage imageNamed:@"enl_res_energy_fill.png"];
		} else {
			progressView.image = [UIImage imageNamed:@"hum_res_energy_fill.png"];
		}
		CGRect rect = progressView.frame;
		rect.size.height = 0;
		if (i == 0 || i == 1 || i == 6 || i == 7) {
			rect.origin.y = 0;
		} else {
			rect.origin.y = 188;
		}
		progressView.frame = rect;
		[progressView setHidden:YES];
		
	}

	for (DeployedResonator *resonator in self.portal.resonators) {

		if (![resonator isKindOfClass:[NSNull class]]) {

			int slot = resonator.slot;
			int level = resonator.level;
			float energy = resonator.energy;
			float maxEnergy = (float)[API maxEnergyForResonatorLevel:level];

			UILabel *levelLabel = (UILabel *)[self.view viewWithTag:10+slot];
			levelLabel.text = [NSString stringWithFormat:@"L%d", level];
			levelLabel.textColor = [API colorForLevel:level];

			UIImageView *resonatorImage = (UIImageView *)[self.view viewWithTag:30+slot];
			[resonatorImage setHidden:NO];

			UIImageView *progressView = (UIImageView *)[self.view viewWithTag:40+slot];
			[progressView setHidden:NO];
			CGRect rect = progressView.frame;
			rect.size.height = (energy/maxEnergy) * 44;
			if (slot >= 1 && slot <= 4) {
				rect.origin.y = 0 + (44 - rect.size.height);
			} else {
				rect.origin.y = 188 + (44 - rect.size.height);
			}
			progressView.frame = rect;
			
		}
		
	}
	
}

@end

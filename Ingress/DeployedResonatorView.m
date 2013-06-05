//
//  DeployedResonatorView.m
//  Ingress
//
//  Created by Alex Studnicka on 20.02.13.
//  Copyright (c) 2013 A&A Code. All rights reserved.
//

#import "DeployedResonatorView.h"
#import "MKCircle+Ingress.h"
#import "GlowingLabel.h"

@implementation DeployedResonatorView

- (id)initWithCircle:(MKCircle *)circle {
    self = [super initWithCircle:circle];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(damage:) name:@"ResonatorDamage" object:self.circle.deployedResonator];
    }
    return self;
}

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)damage:(NSNotification *)notification {
	damageDict = notification.userInfo;
    
    int damagePercent = ([damageDict[@"damageAmount"] floatValue]/(float)[Utilities maxEnergyForResonatorLevel:self.circle.deployedResonator.level])*100;
    
    if (damagePercent > 0) {
        GlowingLabel *damageText = [[GlowingLabel alloc] init];
        damageText.text = [NSString stringWithFormat:@"-%d%%", damagePercent];
        damageText.font = [UIFont fontWithName:@"Helvetica" size:80];
        damageText.textColor = [UIColor redColor];
        damageText.backgroundColor = [UIColor clearColor];
        [damageText sizeToFit];
        damageText.center = CGPointMake(damageText.center.x - damageText.frame.size.width/2, damageText.center.y - damageText.frame.size.height);
        damageText.alpha = 0;
        [self addSubview:damageText];
        
        
        [UIView animateWithDuration:0.5 animations:^{
            damageText.alpha = 1;
            damageText.center = CGPointMake(damageText.center.x, damageText.center.y + damageText.frame.size.height/2);
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:2 delay:2 options:UIViewAnimationCurveEaseOut animations:^{
                damageText.alpha = 0;
                damageText.center = CGPointMake(damageText.center.x, damageText.center.y + damageText.frame.size.height);
            } completion:^(BOOL finished) {
                [damageText removeFromSuperview];
                if ([damageDict[@"destroyed"] boolValue]) {
                    [[[AppDelegate instance] mapView] removeOverlay:self.circle];
                }
            }];
        }];
    }
}

@end

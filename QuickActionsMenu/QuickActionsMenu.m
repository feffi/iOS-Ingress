//
//  QuickActionsMenu.m
//  Ingress
//
//  Created by Alex Studnička on 25.06.13.
//  Copyright (c) 2013 A&A Code. All rights reserved.
//

#import "QuickActionsMenu.h"

@implementation QuickActionsMenu {
    
    CGPoint dragStartPoint;
    void (^_selectHandler)(int option);
    
    UIButton *button1;
    UIButton *button2;
    UIButton *button3;
    UIButton *button4;
    
    UIView *line1;
    UIView *line2;
    UIView *line3;
    UIView *line4;
    
}

+ (UIButton *)optionButton {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    
    button.frame = CGRectMake(0, 0, 154, 50);
    button.titleLabel.font = [UIFont fontWithName:[[[UILabel appearance] font] fontName] size:22];
    button.backgroundColor = [UIColor colorWithRed:34./255. green:62./255. blue:73./255. alpha:0.5];
    button.layer.borderColor = [UIColor colorWithRed:54./255. green:190./255. blue:190./255. alpha:0.5].CGColor;
    button.layer.borderWidth = 2;
    
    button.titleLabel.layer.shadowColor = [UIColor whiteColor].CGColor;
	button.titleLabel.layer.shadowOffset = CGSizeZero;
	button.titleLabel.layer.shadowRadius = 22/5;
	button.titleLabel.layer.shadowOpacity = 1;
	button.titleLabel.layer.shouldRasterize = YES;
	button.titleLabel.layer.masksToBounds = NO;
    
    return button;
}

+ (UIView *)optionLine {
    UIView *line = [UIView new];
    line.backgroundColor = [UIColor colorWithRed:42./255. green:77./255. blue:91./255. alpha:0.5];
    return line;
}

- (id)initWithSeletionHandler:(void (^)(int option))selectHandler {
    CGRect screenBound = [[UIScreen mainScreen] bounds];
    self = [super initWithFrame:screenBound];
    if (self) {
        self.hidden = YES;
        self.alpha = 0;
        self.backgroundColor = [UIColor clearColor];
        
        // -------------------------------------------------
        
        button1 = [QuickActionsMenu optionButton];
        button1.tag = 1;
        [button1 setTitle:@"FIRE XMP" forState:UIControlStateNormal];
        [self addSubview:button1];
        
        line1 = [QuickActionsMenu optionLine];
        [self addSubview:line1];
        
        // -------------------------------------------------

        button2 = [QuickActionsMenu optionButton];
        button2.tag = 2;
        [button2 setTitle:@"NEW PORTAL" forState:UIControlStateNormal];
        [self addSubview:button2];
        
        line2 = [QuickActionsMenu optionLine];
        [self addSubview:line2];
        
        // -------------------------------------------------
        
        button3 = [QuickActionsMenu optionButton];
        button3.tag = 3;
        [button3 setTitle:@"TARGET" forState:UIControlStateNormal];
        button3.hidden = YES;
        [self addSubview:button3];
        
        line3 = [QuickActionsMenu optionLine];
        line3.hidden = YES;
        [self addSubview:line3];
        
        // -------------------------------------------------
        
        button4 = [QuickActionsMenu optionButton];
        button4.tag = 4;
        [button4 setTitle:@"COLLECT ALL" forState:UIControlStateNormal];
        [self addSubview:button4];
        
        line4 = [QuickActionsMenu optionLine];
        [self addSubview:line4];
        
        // -------------------------------------------------

        _selectHandler = [selectHandler copy];
    }
    return self;
}

- (void)showMenu:(UIGestureRecognizer *)gestureRecognizer {
    
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        
//        self.hidden = NO;
//        [UIView animateWithDuration:0.3 animations:^{
//            self.alpha = 1;
//        }];
		
		self.hidden = NO;
		self.alpha = 1;

		CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
		[animation setFromValue:[NSNumber numberWithFloat:0]];
		[animation setToValue:[NSNumber numberWithFloat:1]];
		[animation setDuration:0.25];
		[animation setRemovedOnCompletion:YES];
		[animation setFillMode:kCAFillModeRemoved];
		
		[button1.layer addAnimation:animation forKey:@"scale"];
		[button2.layer addAnimation:animation forKey:@"scale"];
		[button3.layer addAnimation:animation forKey:@"scale"];
		[button4.layer addAnimation:animation forKey:@"scale"];
        
        dragStartPoint = CGPointMake([gestureRecognizer locationInView:self].x, [gestureRecognizer locationInView:self].y+20);
        
        button1.center = CGPointMake(dragStartPoint.x, dragStartPoint.y - 110);
        button2.center = CGPointMake(dragStartPoint.x + 110, dragStartPoint.y - 24);
        button3.center = CGPointMake(dragStartPoint.x, dragStartPoint.y + 62);
        button4.center = CGPointMake(dragStartPoint.x - 110, dragStartPoint.y - 24);
        
        line1.frame = CGRectMake(dragStartPoint.x - 2, dragStartPoint.y - 85, 4, 44);
        line2.frame = CGRectMake(dragStartPoint.x + 7, dragStartPoint.y - 26, 26, 4);
        line3.frame = CGRectMake(dragStartPoint.x - 2, dragStartPoint.y - 7, 4, 44);
        line4.frame = CGRectMake(dragStartPoint.x - 32, dragStartPoint.y - 26, 26, 4);
        
    }

    float curX = [gestureRecognizer locationInView:self].x;
    float curY = [gestureRecognizer locationInView:self].y;
    CGPoint curPoint = CGPointMake(curX, curY);
    
    UIButton *activeButton;
    if (!button1.hidden && CGRectContainsPoint(button1.frame, curPoint)) {
        activeButton = button1;
    } else if (!button2.hidden && CGRectContainsPoint(button2.frame, curPoint)) {
        activeButton = button2;
    } else if (!button3.hidden && CGRectContainsPoint(button3.frame, curPoint)) {
        activeButton = button3;
    } else if (!button4.hidden && CGRectContainsPoint(button4.frame, curPoint)) {
        activeButton = button4;
    }
 
    button1.backgroundColor = [button1.backgroundColor colorWithAlphaComponent:0.5];
    button2.backgroundColor = [button2.backgroundColor colorWithAlphaComponent:0.5];
    button3.backgroundColor = [button3.backgroundColor colorWithAlphaComponent:0.5];
    button4.backgroundColor = [button4.backgroundColor colorWithAlphaComponent:0.5];
    activeButton.backgroundColor = [activeButton.backgroundColor colorWithAlphaComponent:1.0];
    
    if (gestureRecognizer.state == UIGestureRecognizerStateEnded) {
        
        if (activeButton) {
            _selectHandler(activeButton.tag);
        }
        
        [UIView animateWithDuration:0.3 animations:^{
            self.alpha = 0;
        } completion:^(BOOL finished) {
            self.hidden = YES;
        }];
    }
    
}

@end

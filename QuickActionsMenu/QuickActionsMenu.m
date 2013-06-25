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
    
}

+ (UIButton *)optionButton {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0, 0, 154, 50);
    button.backgroundColor = [UIColor colorWithRed:34./255. green:62./255. blue:73./255. alpha:1.0];
    button.titleLabel.font = [UIFont fontWithName:[[[UILabel appearance] font] fontName] size:22];
    button.alpha = .8;
    button.layer.borderWidth = 2;
    button.layer.borderColor = [UIColor colorWithRed:54./255. green:190./255. blue:190./255. alpha:1.0].CGColor;
    return button;
}

- (id)initWithSeletionHandler:(void (^)(int option))selectHandler {
    CGRect screenBound = [[UIScreen mainScreen] bounds];
    self = [super initWithFrame:screenBound];
    if (self) {
        [self setHidden:YES];
        self.backgroundColor = [UIColor clearColor];
        
        button1 = [QuickActionsMenu optionButton];
        button1.tag = 1;
        [button1 setTitle:@"FIRE XMP" forState:UIControlStateNormal];
        [self addSubview:button1];
        
        button2 = [QuickActionsMenu optionButton];
        button2.tag = 2;
        [button2 setTitle:@"NEW PORTAL" forState:UIControlStateNormal];
        button2.hidden = YES;
        [self addSubview:button2];
        
        button3 = [QuickActionsMenu optionButton];
        button3.tag = 3;
        [button3 setTitle:@"TARGET" forState:UIControlStateNormal];
        button3.hidden = YES;
        [self addSubview:button3];
        
        button4 = [QuickActionsMenu optionButton];
        button4.tag = 4;
        [button4 setTitle:@"COLLECT ALL" forState:UIControlStateNormal];
        button4.hidden = YES;
        [self addSubview:button4];
        
        _selectHandler = [selectHandler copy];
    }
    return self;
}

- (void)showMenu:(UIGestureRecognizer *)gestureRecognizer {
    
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        [self setHidden:NO];
        dragStartPoint = CGPointMake([gestureRecognizer locationInView:self].x, [gestureRecognizer locationInView:self].y);
        button1.center = CGPointMake(dragStartPoint.x, dragStartPoint.y - 110);
        button2.center = CGPointMake(dragStartPoint.x + 110, dragStartPoint.y - 24);
        button3.center = CGPointMake(dragStartPoint.x, dragStartPoint.y + (110 - 48));
        button4.center = CGPointMake(dragStartPoint.x - 110, dragStartPoint.y - 24);
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
    
    button1.backgroundColor = [UIColor colorWithRed:34./255. green:62./255. blue:73./255. alpha:1.0];
    button2.backgroundColor = [UIColor colorWithRed:34./255. green:62./255. blue:73./255. alpha:1.0];
    button3.backgroundColor = [UIColor colorWithRed:34./255. green:62./255. blue:73./255. alpha:1.0];
    button4.backgroundColor = [UIColor colorWithRed:34./255. green:62./255. blue:73./255. alpha:1.0];
    activeButton.backgroundColor = [UIColor colorWithRed:54./255. green:190./255. blue:190./255. alpha:1.0];
    
    if (gestureRecognizer.state == UIGestureRecognizerStateEnded) {
        
        if (activeButton) {
            _selectHandler(activeButton.tag);
        }
        
        [self setHidden:YES];
    }
    
}

@end

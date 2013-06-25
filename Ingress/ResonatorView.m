//
//  ResonatorView.m
//  Ingress
//
//  Created by John Bekas Jr on 6/24/13.
//  Copyright (c) 2013 A&A Code. All rights reserved.
//

#import "ResonatorView.h"

@implementation ResonatorView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self baseInit];
    }
    return self;
}

-(id)initWithCoder:(NSCoder*)coder {

    self = [super initWithCoder:coder];
    if (self) {
        [self baseInit];
    }

    return self;
}

-(void)baseInit {
    _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    [self addSubview:_imageView];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end

//
//  UIImage+ColorReplace.h
//  Ingress
//
//  Created by Alex Studnicka on 26.01.13.
//  Copyright (c) 2013 A&A Code. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (ColorReplace)

- (UIImage *)imageByRemovingColor:(uint)color;
- (UIImage *)imageByRemovingColorsWithMinColor:(uint)minColor maxColor:(uint)maxColor;
- (UIImage *)imageByReplacingColor:(uint)color withColor:(uint)newColor;
- (UIImage *)imageByReplacingColorsWithMinColor:(uint)minColor maxColor:(uint)maxColor withColor:(uint)newColor;
- (UIImage *)imageByReplacingColorsWithMinColor:(uint)minColor maxColor:(uint)maxColor withColor:(uint)newColor andAlpha:(float)alpha;

@end
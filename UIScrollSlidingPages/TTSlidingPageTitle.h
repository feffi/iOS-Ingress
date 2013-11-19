//
//  TTSlidingPageTitle.h
//  UIScrollSlidingPages
//
//  Created by Thomas Thorpe on 29/03/2013.
//  Copyright (c) 2013 Thomas Thorpe. All rights reserved.
//

/*
 Copyright (c) 2012 Tom Thorpe. All rights reserved.
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of
 this software and associated documentation files (the "Software"), to deal in
 the Software without restriction, including without limitation the rights to
 use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
 of the Software, and to permit persons to whom the Software is furnished to do
 so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all
 copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 SOFTWARE.
 */

#import <Foundation/Foundation.h>

@interface TTSlidingPageTitle : NSObject

-(id)initWithHeaderText:(NSString*)headerText;
-(id)initWithHeaderImage:(UIImage*)headerImage;

//The title text to go in the nav bar
@property(strong, nonatomic) NSString *headerText;

//An image to use in the nav bar (if you set this, the title text will not be used)
@property(strong, nonatomic) UIImage *headerImage;

@end

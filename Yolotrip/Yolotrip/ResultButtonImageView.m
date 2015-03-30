//
//  ResultButtonImageView.m
//  Yolotrip
//
//  Created by Alexander Tsu on 2/27/15.
//  Copyright (c) 2015 Alexander Tsu. All rights reserved.
//
//  Description: Handles the X button on the Results page

#import "ResultButtonImageView.h"

@implementation ResultButtonImageView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void) touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event {
    self.alpha = 0.5;
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    self.alpha = 1.0;
    [self.delegate getButtonPress:self];
}

@end

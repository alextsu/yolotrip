//
//  ConfirmButtonImageView.h
//  Yolotrip
//
//  Created by Alexander Tsu on 2/27/15.
//  Copyright (c) 2015 Alexander Tsu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ConfirmButtonImageView : UIImageView
@property (nonatomic, assign) id  delegate;
@end

@protocol ConfirmButtonDelegate

-(void) getConfirmButtonPress: (ConfirmButtonImageView *) cbiv;
@end

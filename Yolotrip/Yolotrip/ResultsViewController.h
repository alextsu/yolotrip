//
//  ResultsViewController.h
//  Yolotrip
//
//  Created by Alexander Tsu on 2/27/15.
//  Copyright (c) 2015 Alexander Tsu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ResultButtonImageView.h"
#import "ConfirmButtonImageView.h"
#import "MapViewController.h"

@interface ResultsViewController : UIViewController <ResultButtonDelegate>
@property (strong, nonatomic) NSMutableArray* shuffledYelpLocations;
@end

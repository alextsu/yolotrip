//
//  FirstViewController.h
//  Yolotrip
//
//  Created by Alexander Tsu on 2/26/15.
//  Copyright (c) 2015 Alexander Tsu. All rights reserved.
//

@import CoreLocation;
#import <UIKit/UIKit.h>

@interface FirstViewController : UIViewController <UIPickerViewDataSource, UIPickerViewDelegate, CLLocationManagerDelegate>

@property (strong, nonatomic) NSMutableArray* shuffledYelpLocations;
- (IBAction)infoButton:(UIBarButtonItem *)sender;

@end


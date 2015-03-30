//
//  YelpViewController.h
//  Yolotrip
//
//  Created by Alexander Tsu on 2/27/15.
//  Copyright (c) 2015 Alexander Tsu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YelpViewController : UIViewController <UIWebViewDelegate>
@property (weak, nonatomic) IBOutlet UIWebView *yelpWebView;
@property (strong, nonatomic) NSString * link;
@end

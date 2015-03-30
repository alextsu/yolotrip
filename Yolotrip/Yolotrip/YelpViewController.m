//
//  YelpViewController.m
//  Yolotrip
//
//  Created by Alexander Tsu on 2/27/15.
//  Copyright (c) 2015 Alexander Tsu. All rights reserved.
//
//  Description: Simple web view that opens up a selected location in yelp

#import "YelpViewController.h"

@interface YelpViewController ()
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityInd;

@end

@implementation YelpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    if(self.link != nil) {
        NSURL *url = [NSURL URLWithString:self.link];
        NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
        [self.yelpWebView loadRequest:requestObj];
        
        self.yelpWebView.delegate = self;
        [self.activityInd startAnimating];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    self.activityInd.alpha = 0.0;
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Internet Connection Required"
                                                    message:@"Please check your connection settings."
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}


- (void)webViewDidFinishLoad:(UIWebView *)webView {
    self.activityInd.alpha = 0.0;
}

@end

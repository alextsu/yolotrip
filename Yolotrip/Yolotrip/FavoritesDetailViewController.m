//
//  FavoritesDetailViewController.m
//  Yolotrip
//
//  Created by Alexander Tsu on 2/28/15.
//  Copyright (c) 2015 Alexander Tsu. All rights reserved.
//
//  Description: controls results page when selected from the favorites tab. Very similar to ResultsViewController

#import "FavoritesDetailViewController.h"
#import "YelpViewController.h"
#import "MapViewController.h"

#import <sys/socket.h>
#import <netinet/in.h>
#import <SystemConfiguration/SystemConfiguration.h>

@interface FavoritesDetailViewController ()
@property (weak, nonatomic) IBOutlet UILabel *nameOfResult;
@property (weak, nonatomic) IBOutlet UILabel *type;
@property (weak, nonatomic) IBOutlet UIImageView *resultImage;
@property (weak, nonatomic) IBOutlet UIImageView *starRating;
@property (weak, nonatomic) IBOutlet UILabel *userQuote;
@property (strong, nonatomic) NSString * yelpLink;
@end

@implementation FavoritesDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //NSLog(@"Favorites Results here: %@", self.displayedResult);
    
    //Set text fields
    self.yelpLink = [self.displayedResult objectForKey:@"mobile_url"];
    self.nameOfResult.text = [self.displayedResult objectForKey:@"name"];
    self.userQuote.text =[self.displayedResult objectForKey:@"snippet_text"];
    
    NSArray * resultArray = [self.displayedResult objectForKey:@"categories"];
    self.type.text = resultArray[0][0];
    //self.type.text = [self.displayedResult objectForKey:@"display_phone"];
    
}

-(void) viewDidAppear:(BOOL)animated {
    //Display location image
    
    if(!self.hasConnectivity) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Internet Connection Required"
                                                        message:@"Please check your connection settings."
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }
    
    NSString *ImageURL = [self.displayedResult objectForKey:@"image_url"];
    ImageURL = [ImageURL substringToIndex:[ImageURL length] - 6];
    ImageURL = [ImageURL stringByAppendingString:@"ls.jpg"];
    NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:ImageURL]];
    self.resultImage.image = [UIImage imageWithData:imageData];
    self.resultImage.layer.cornerRadius = self.resultImage.frame.size.height /2;
    self.resultImage.layer.masksToBounds = YES;
    self.resultImage.layer.borderWidth = 0;
    
    //Display stars
    ImageURL = [self.displayedResult objectForKey:@"rating_img_url_large"];
    imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:ImageURL]];
    self.starRating.image = [UIImage imageWithData:imageData];
    
    [self.view setNeedsDisplay];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([[segue identifier] isEqualToString:@"openYelp"]) {
        NSLog(@"Yelp Button Pressed: %@", self.yelpLink);
        YelpViewController *temp = [segue destinationViewController];
        [temp setLink:self.yelpLink];
    }
    
    else if ([[segue identifier] isEqualToString:@"showMap"]) {
        NSLog(@"Map Button Pressed");
        
        //Update desination address
        NSDictionary *location = [self.displayedResult objectForKey:@"location"];
        NSDictionary *coordinate = [location objectForKey:@"coordinate"];
        NSString *latitude = [coordinate objectForKey:@"latitude"];
        NSString *longitude = [coordinate objectForKey:@"longitude"];
        NSLog(@"Latitude is %@", latitude);

        NSNumber * destinationLatitude = [NSNumber numberWithFloat: [latitude floatValue]];
        NSNumber * destinationLongitude = [NSNumber numberWithFloat: [longitude floatValue]];
        
        //Show map with route
        MapViewController *temp2 = [segue destinationViewController];
        temp2.link = self.yelpLink;
        temp2.latitude = destinationLatitude;
        temp2.longitude = destinationLongitude;
        
        temp2.locationIconLink = [self.displayedResult objectForKey:@"image_url"];
        temp2.destinationTitle = [self.displayedResult objectForKey:@"name"];
        temp2.fromSearch = NO;
    }
}


/*
 The following method checks for connectivity.
 The following method was copied from Apple's Reachability Example: http://developer.apple.com/library/ios/#samplecode/Reachability
 I discovered this code in the following stack overflow link: http://stackoverflow.com/questions/1083701/how-to-check-for-an-active-internet-connection-on-iphone-sdk
 */
-(BOOL)hasConnectivity {
    struct sockaddr_in zeroAddress;
    bzero(&zeroAddress, sizeof(zeroAddress));
    zeroAddress.sin_len = sizeof(zeroAddress);
    zeroAddress.sin_family = AF_INET;
    
    SCNetworkReachabilityRef reachability = SCNetworkReachabilityCreateWithAddress(kCFAllocatorDefault, (const struct sockaddr*)&zeroAddress);
    if(reachability != NULL) {
        //NetworkStatus retVal = NotReachable;
        SCNetworkReachabilityFlags flags;
        if (SCNetworkReachabilityGetFlags(reachability, &flags)) {
            if ((flags & kSCNetworkReachabilityFlagsReachable) == 0)
            {
                // if target host is not reachable
                return NO;
            }
            
            if ((flags & kSCNetworkReachabilityFlagsConnectionRequired) == 0)
            {
                // if target host is reachable and no connection is required
                //  then we'll assume (for now) that your on Wi-Fi
                return YES;
            }
            
            
            if ((((flags & kSCNetworkReachabilityFlagsConnectionOnDemand ) != 0) ||
                 (flags & kSCNetworkReachabilityFlagsConnectionOnTraffic) != 0))
            {
                // ... and the connection is on-demand (or on-traffic) if the
                //     calling application is using the CFSocketStream or higher APIs
                
                if ((flags & kSCNetworkReachabilityFlagsInterventionRequired) == 0)
                {
                    // ... and no [user] intervention is needed
                    return YES;
                }
            }
            
            if ((flags & kSCNetworkReachabilityFlagsIsWWAN) == kSCNetworkReachabilityFlagsIsWWAN)
            {
                // ... but WWAN connections are OK if the calling application
                //     is using the CFNetwork (CFSocketStream?) APIs.
                return YES;
            }
        }
    }
    
    return NO;
}


@end

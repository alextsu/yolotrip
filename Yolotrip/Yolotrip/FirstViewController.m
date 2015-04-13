//
//  FirstViewController.m
//  Yolotrip
//
//  Created by Alexander Tsu on 2/26/15.
//  Copyright (c) 2015 Alexander Tsu. All rights reserved.
//
//  Description: Controls the first screen user sees when he/she taps on the search tab. Handles the yelp API calls when user taps "Let's Go" and sets the UI Picker

#import "FirstViewController.h"
#import "YPAPISample.h"
#import "ShuffleArray.h"
#import "ResultsViewController.h"

#import <sys/socket.h>
#import <netinet/in.h>
#import <SystemConfiguration/SystemConfiguration.h>

@interface FirstViewController ()
//@property (strong, nonatomic) CLLocation *currentLocation;
@property (strong,nonatomic) CLLocationManager *locationManager;
@property (weak, nonatomic) IBOutlet UIPickerView *activityPicker;
@property (weak, nonatomic) IBOutlet UIButton *letsGo;
- (IBAction)tapLetsGo:(UIButton *)sender;
@property (strong, nonatomic) NSArray * pickerData;
@property (strong, nonatomic) NSString* selectedActivity;
@end

@implementation FirstViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    //Create picker
    self.pickerData = @[@"Park", @"Cinema", @"Restaurant", @"Bar", @"Historical Landmark", @"Museum", @"Shopping"];
    self.activityPicker.dataSource = self;
    self.activityPicker.delegate = self;
    [self.activityPicker selectRow:2 inComponent:0 animated:YES];
    self.selectedActivity = [self.pickerData objectAtIndex:2];
    
    // Create a location manager
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    
    // Ask for permission (only one)
    [self.locationManager requestWhenInUseAuthorization];
    //[self.locationManager requestAlwaysAuthorization];
    
    
    
}

-(void) viewDidAppear:(BOOL)animated {
    if(!self.hasConnectivity) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Internet Connection Required"
                                                        message:@"Please check your connection settings."
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }
}

-  (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return self.pickerData.count;
}

- (NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return self.pickerData[row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    self.selectedActivity = [self.pickerData objectAtIndex:row];
    //NSLog(@"Selected Activity %@", self.selectedActivity);
}

- (NSAttributedString *)pickerView:(UIPickerView *)pickerView attributedTitleForRow:(NSInteger)row forComponent:(NSInteger)component{
    //Set color of picker text to white
    NSAttributedString *attString = [[NSAttributedString alloc] initWithString:self.pickerData[row] attributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    
    return attString;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSLog(@"Segue to Results");
    if ([[segue identifier] isEqualToString:@"getResults"]) {
        
        //Following code is modified from Yelp API Sample Project: https://github.com/Yelp/yelp-api/tree/master/v2/objective-c
        @autoreleasepool {
            
            NSString *defaultTerm = self.selectedActivity;
            NSString *defaultLocation = @"37.764799,-122.419981";
            
            NSLog(@"The current location saved in NSUserDefaults is %@", [[NSUserDefaults standardUserDefaults] valueForKey:@"term"]);
            
            //Get the term and location from the command line if there were any, otherwise assign default values.
            NSString *term = [[NSUserDefaults standardUserDefaults] valueForKey:@"term"] ?: defaultTerm;
            NSString *location = [[NSUserDefaults standardUserDefaults] valueForKey:@"location"] ?: defaultLocation;
            
            YPAPISample *APISample = [[YPAPISample alloc] init];
            dispatch_group_t requestGroup = dispatch_group_create();
            
            dispatch_group_enter(requestGroup);
            [APISample queryTopBusinessInfoForTerm:term location:location completionHandler:^(NSArray *topBusinessJSON, NSError *error) {
                
                if (error) {
                    NSLog(@"An error happened during the request: %@", error);
                } else if (topBusinessJSON) {
                    self.shuffledYelpLocations = [topBusinessJSON shuffledArray];
                    //Following is commented out to prevent delay. Feel free to uncomment to review JSON returned from Yelp API
                    //NSLog(@"Top business info: \n %@", self.shuffledYelpLocations);
                } else {
                    NSLog(@"No business was found");
                }
                
                dispatch_group_leave(requestGroup);
            }];
            
            dispatch_group_wait(requestGroup, DISPATCH_TIME_FOREVER); // This avoids the program exiting before all our asynchronous callbacks have been made.
        }
        
        ResultsViewController *temp = [segue destinationViewController];
        [temp setShuffledYelpLocations:self.shuffledYelpLocations];
    }
}

- (IBAction)tapLetsGo:(UIButton *)sender {
}


/*
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

#pragma mark - Location Manager Delegate Methods
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    //self.currentLocation = [locations lastObject];
    NSLog(@"didUpdateLocations: %@", [locations lastObject]);
    NSString *currentLocationString = [NSString stringWithFormat:@"%f,%f", self.locationManager.location.coordinate.latitude, self.locationManager.location.coordinate.longitude];
    //Update NSUserDefaults
    [[NSUserDefaults standardUserDefaults] setObject:currentLocationString forKey:@"location"];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"Location manager error: %@", error.localizedDescription);
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    if (status == kCLAuthorizationStatusAuthorizedWhenInUse ||
        status == kCLAuthorizationStatusAuthorizedAlways) {
        
        // Configure location manager
        [self.locationManager setDistanceFilter:kCLHeadingFilterNone];//]500]; // meters
        [self.locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
        [self.locationManager setHeadingFilter:kCLDistanceFilterNone];
        self.locationManager.activityType = CLActivityTypeFitness;
        
        // Start the location updating
        [self.locationManager startUpdatingLocation];

        
    } else if (status == kCLAuthorizationStatusDenied) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Location services not authorized"
                                                        message:@"This app needs you to authorize locations services to work."
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    } else {
        NSLog(@"Wrong location status");
    }
}

//Handles the info button click
- (IBAction)infoButton:(UIBarButtonItem *)sender {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Instructions"
                                                    message:@"Select an activty and press 'Let's Go'. For more info, tap the 'View on Yelp' button. Press the gray button to see a new result. Press the orange button to add the result to your Favorites list and view a map to get to the chosen location. On the Maps view, you can also share your Yolotrip activity on Facebook to find friends joining you. Have fun!"
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}
@end

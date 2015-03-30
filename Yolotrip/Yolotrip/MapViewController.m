//
//  MapViewController.m
//  Yolotrip
//
//  Created by Matthias Meier on 01/03/15.
//  Copyright (c) 2015 Alexander Tsu. All rights reserved.
//
//  Description: Controls the map, route drawing, and directions list page after user has favorited a location or if the user clicks the map navigation bar button from the favorite results page. 

#import "MapViewController.h"
#import <Social/Social.h>

@implementation MapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //Set added to favorites text
    self.locationAddedToFavorites.text = [NSString stringWithFormat:@"%@ Added to Favorites", self.destinationTitle];
    self.addedToFavoritesView.alpha = 0.0;
    self.firstLoad = YES;
    
    //Get the image for the location icon at bottom of screen
    NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:self.locationIconLink]];
    self.locationIcon.image = [UIImage imageWithData:imageData];
    
    //Fit it into the rounded circle
    self.locationIcon.layer.cornerRadius = self.locationIcon.frame.size.height /2;
    self.locationIcon.layer.masksToBounds = YES;
    self.locationIcon.layer.borderWidth = 0;
    
    self.destinationTitleLabel.text = [NSString stringWithFormat:@"Directions to %@", self.destinationTitle];
    
    // Create a location manager
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    
    // zoom in to user's current location
    _mapView.showsUserLocation = YES;
    MKCoordinateRegion region =
    MKCoordinateRegionMakeWithDistance(self.locationManager.location.coordinate,
                                       2000, 2000);
    [_mapView setRegion:region animated:NO];
    
    self.mapView.hidden = NO;
    
    //set delegate of mapView to self
    _mapView.delegate = self;
    
    // create request for route
    MKDirectionsRequest *request = [[MKDirectionsRequest alloc] init];
    request.source = [MKMapItem mapItemForCurrentLocation];
    
    float longitudeFloat = [self.longitude floatValue];
    float latitudeFloat = [self.latitude floatValue];
    
    MKPlacemark *destinationAddress= [[MKPlacemark alloc] initWithCoordinate:CLLocationCoordinate2DMake(latitudeFloat,longitudeFloat)
                                                           addressDictionary:nil];
    request.destination = [[MKMapItem alloc] initWithPlacemark:destinationAddress];
    
    MKDirections *directions = [[MKDirections alloc] initWithRequest:request];
    [directions calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse *response, NSError *error) {
        
        if (error) {
            NSLog(@"[Error] %@", error);
            return;
        }
        
        else {
            [self showRoute:response];
        }
        
        self.allSteps = @"";
        MKRoute *route = [response.routes firstObject];
        for (MKRouteStep *step in route.steps) {
            NSLog(@"step:%@",step.instructions);
            NSString *newStep = step.instructions;
            self.allSteps = [self.allSteps stringByAppendingString:newStep];
            self.allSteps = [self.allSteps stringByAppendingString:@"\n"];
        }
        NSLog(@"All steps are %@", self.allSteps);
        self.directionsText.text = self.allSteps;
        
        //self.directionsText.backgroundColor = [UIColor whiteColor];
    }];
    
}

- (void) viewDidAppear:(BOOL)animated {
    
    if(self.firstLoad) {
        self.firstLoad = NO;
        self.addedToFavoritesView.layer.cornerRadius = self.addedToFavoritesView.frame.size.height /2;
        self.addedToFavoritesView.layer.masksToBounds = YES;
        self.addedToFavoritesView.layer.borderWidth = 0;
        self.addedToFavoritesView.alpha = 1.0;
        
        //Animate uiview letting user know this was added to favorites
        if(self.fromSearch) {
            [UIView animateWithDuration:2.5 animations:^{
                self.addedToFavoritesView.alpha = 0.0;
            }
                             completion:^(BOOL completed) {
                             }
             ];
        }
        else self.addedToFavoritesView.alpha = 0.0;
    }
}

///-----------------------------------------------------------------------------
#pragma mark - Location Manager Delegate Methods
///-----------------------------------------------------------------------------
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

// The following code to show the route is based on http://www.techotopia.com/index.php/Using_MKDirections_to_get_iOS_7_Map_Directions_and_Routes
-(void)showRoute:(MKDirectionsResponse *)response
{
    NSLog(@"showRoute method called");
    for (MKRoute *route in response.routes)
    {
        [_mapView
         addOverlay:route.polyline level:MKOverlayLevelAboveRoads];
    }
}

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id < MKOverlay >)overlay
{
    NSLog(@"Overlay method called");
    MKPolylineRenderer *renderer =
    [[MKPolylineRenderer alloc] initWithOverlay:overlay];
    renderer.strokeColor = [UIColor blueColor];
    renderer.lineWidth = 5.0;
    return renderer;
}

- (IBAction)shareWithFacebook:(UIBarButtonItem *)sender {
    NSLog(@"Share with Facebook pressed");
    if([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook]) {
        SLComposeViewController *controller = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
        
        NSString * outputString = [NSString stringWithFormat:@"Come take a YoloTrip with me to %@! %@", self.destinationTitle, self.link];
        [controller setInitialText:outputString];
        [self presentViewController:controller animated:YES completion:Nil];
    }
    else {
        //If you can't use Facebook, throw an UIAlertView
        UIAlertView *alertView = [[UIAlertView alloc]
                                  initWithTitle:@"Sorry"
                                  message:@"You can't post to Facebook right now, make sure your device has an internet connection and you have at least one Facebook account setup"
                                  delegate:self
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil];
        [alertView show];
        
    }
    
}
@end

//
//  ResultsViewController.m
//  Yolotrip
//
//  Created by Alexander Tsu on 2/27/15.
//  Copyright (c) 2015 Alexander Tsu. All rights reserved.
//
//  Description: Controls the Results page after a user has initiated a search. Contains code that refreshes the page when the user click's the X button and has segues to Yelp and the map view.

#import "ResultsViewController.h"
#import "YelpViewController.h"
#import "FavoritesTableViewController.h"

@interface ResultsViewController ()
@property (weak, nonatomic) IBOutlet UILabel *nameOfResult;
@property (weak, nonatomic) IBOutlet UILabel *type;
@property (strong, nonatomic) IBOutlet UIImageView *resultImage;
@property (strong, nonatomic) IBOutlet UIImageView *starRating;
@property (weak, nonatomic) IBOutlet UILabel *userQuote;
@property (strong, nonatomic) IBOutlet UIButton *confirmButton;
@property (strong,nonatomic) NSString * yelpLink;
@property (weak, nonatomic) IBOutlet ResultButtonImageView *reject;
@property (weak, nonatomic) IBOutlet ConfirmButtonImageView *confirm;
@property (strong, nonatomic) NSDictionary *displayedLocation;
@property (strong, nonatomic) NSNumber *destinationLongitude;
@property (strong, nonatomic) NSNumber *destinationLatitude;
@end

@implementation ResultsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    self.reject.delegate =self;
    self.confirm.delegate=self;
    
    [self populatePage];
    self.resultImage.alpha = 0.0;
}


- (void) viewDidAppear:(BOOL)animated {
    //Fit the image in a circle
    self.resultImage.layer.cornerRadius = self.resultImage.frame.size.height /2;
    self.resultImage.layer.masksToBounds = YES;
    self.resultImage.layer.borderWidth = 0;
    self.resultImage.alpha = 1.0;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//Loads data from the first element in the array that we received from the Yelp API
-(void) populatePage {
    self.displayedLocation = [self.shuffledYelpLocations objectAtIndex:0];
    
    //Set text fields
    self.yelpLink = [self.displayedLocation objectForKey:@"mobile_url"];
    
    self.nameOfResult.text = [self.displayedLocation objectForKey:@"name"];
    self.userQuote.text =[self.displayedLocation objectForKey:@"snippet_text"];
    
    NSArray * resultArray = [self.displayedLocation objectForKey:@"categories"];
    //NSLog(@"Result Array: %@", resultArray[0][0]);
    self.type.text = resultArray[0][0];
    
    //Display location image
    NSString *ImageURL = [self.displayedLocation objectForKey:@"image_url"];
    ImageURL = [ImageURL substringToIndex:[ImageURL length] - 6];
    ImageURL = [ImageURL stringByAppendingString:@"ls.jpg"];
    NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:ImageURL]];
    self.resultImage.image = [UIImage imageWithData:imageData];
    
    //Fit the image in a circle
    self.resultImage.layer.cornerRadius = self.resultImage.frame.size.height /2;
    self.resultImage.layer.masksToBounds = YES;
    self.resultImage.layer.borderWidth = 0;
    
    //Display stars
    ImageURL = [self.displayedLocation objectForKey:@"rating_img_url_large"];
    imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:ImageURL]];
    self.starRating.image = [UIImage imageWithData:imageData];
    
}

//Gets called when the X button is pressed. Pops off the first element in the array and calls populatePage to reset the displayed location
-(void) getButtonPress: (ResultButtonImageView *) rbiv {
    NSLog(@"Reject Button Pressed");

    //Remove the first element in array and reload page
    if([self.shuffledYelpLocations count] > 1) {
        [self.shuffledYelpLocations removeObjectAtIndex:0];
        [self populatePage];
        [self.view setNeedsDisplay];
    }
    //Throw UIAlertView when you've run out of suggestions
    else {
        NSLog(@"Ran out of suggestions");
        
        UIAlertView *alertView = [[UIAlertView alloc]
                                  initWithTitle:@"Sorry"
                                  message:@"We've run out of suggestions. Please YoloSearch again!"
                                  delegate:self
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil];
        [alertView show];
        [self.navigationController popToRootViewControllerAnimated:TRUE];
    }
}

//Saves the displayed location to default if user clicks the orange check box
-(void) saveToDefaults {
    //Check if default exists
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSObject * object = [defaults objectForKey:@"favorites"];
    if (object != nil) {
        //If default exists, get the array and copy over every element in it
        NSArray *favoriteArray = [defaults objectForKey:@"favorites"];
        NSMutableArray *duplicateFavoriteArray = [NSMutableArray arrayWithCapacity:[favoriteArray count]+1];
        for (id anObject in favoriteArray) {
            [duplicateFavoriteArray addObject:[anObject mutableCopy]];
        }
        
        //ensure all items in the NSMutableArray are unique
        int i;
        for (i = 0; i < [duplicateFavoriteArray count]; i++) {
            //if ([[duplicateFavoriteArray objectAtIndex:i] isEqual: self.displayedLocation])break;
            if ([[[duplicateFavoriteArray objectAtIndex:i] objectForKey:@"name" ] isEqual: [self.displayedLocation objectForKey:@"name"]]) {
                break;
            }
        }
        
        //Add a new object only if it's unique
        if(i == ([duplicateFavoriteArray count]))[duplicateFavoriteArray addObject:self.displayedLocation];
        
        [defaults setObject:[NSArray arrayWithArray:duplicateFavoriteArray] forKey:@"favorites"];
        NSLog(@"Favorite Array %@", duplicateFavoriteArray);
    }
    else {
        //If this the first time you're adding to the defaults, create new arrays and add them in
        NSMutableArray *favoriteArray = [[NSMutableArray alloc] init];
        [favoriteArray addObject:self.displayedLocation];
        [defaults setObject:[NSArray arrayWithArray:favoriteArray] forKey:@"favorites"];
        NSLog(@"Favorite Array %@", favoriteArray);

    }

}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([[segue identifier] isEqualToString:@"openYelp"]) {
        NSLog(@"Open Yelp Link: %@", self.yelpLink);
        YelpViewController *temp = [segue destinationViewController];
        [temp setLink:self.yelpLink];
    }
    
    else if ([[segue identifier] isEqualToString:@"openMap"]) {
        NSLog(@"Confirm Button Pressed");
        
        //Add it to NSUserDefaults
        [self saveToDefaults];
        
        //Update desination address
        NSDictionary *location = [self.displayedLocation objectForKey:@"location"];
        NSDictionary *coordinate = [location objectForKey:@"coordinate"];
        NSString *latitude = [coordinate objectForKey:@"latitude"];
        NSString *longitude = [coordinate objectForKey:@"longitude"];
        NSLog(@"Latitude is %@", latitude);

        self.destinationLatitude = [NSNumber numberWithFloat: [latitude floatValue]];
        self.destinationLongitude = [NSNumber numberWithFloat: [longitude floatValue]];
        
        //Show map with route
        MapViewController *temp2 = [segue destinationViewController];
        temp2.link = self.yelpLink;
        temp2.latitude = self.destinationLatitude;
        temp2.longitude = self.destinationLongitude;
        
        temp2.locationIconLink = [self.displayedLocation objectForKey:@"image_url"];
        temp2.destinationTitle = [self.displayedLocation objectForKey:@"name"];
        temp2.fromSearch = YES;
    }
}


@end

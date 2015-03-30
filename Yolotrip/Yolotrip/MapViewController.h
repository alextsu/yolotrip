//
//  MapViewController.h
//  Yolotrip
//
//  Created by Matthias Meier on 01/03/15.
//  Copyright (c) 2015 Alexander Tsu. All rights reserved.
//

#import <UIKit/UIKit.h>
@import MapKit;
@interface MapViewController : UIViewController <CLLocationManagerDelegate, MKMapViewDelegate>
@property (strong, nonatomic) NSString * link;
@property (strong, nonatomic) NSNumber *latitude;
@property (strong, nonatomic) NSNumber *longitude;
@property (strong, nonatomic) IBOutlet UITextView *directionsText;
@property (strong, nonatomic) IBOutlet MKMapView *mapView;
@property (strong,nonatomic) CLLocationManager *locationManager;

@property (weak, nonatomic) IBOutlet UIImageView *locationIcon;
@property (strong, nonatomic) NSString *locationIconLink;
@property (weak, nonatomic) IBOutlet UILabel *destinationTitleLabel;
@property (weak, nonatomic) NSString *destinationTitle;
- (IBAction)shareWithFacebook:(UIBarButtonItem *)sender;
@property (weak, nonatomic) IBOutlet UILabel *locationAddedToFavorites;
@property (weak, nonatomic) IBOutlet UIView *addedToFavoritesView;

@property (strong,nonatomic) CLPlacemark *sourcePlacemark;
@property (strong, nonatomic) NSString *allSteps;

@property BOOL fromSearch;
@property BOOL firstLoad;
@end

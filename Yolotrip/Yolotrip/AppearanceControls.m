//
//  AppearanceControls.m
//  Yolotrip
//
//  Created by Alexander Tsu on 2/26/15.
//  Copyright (c) 2015 Alexander Tsu. All rights reserved.
//
//  Description: Called in AppDelegate. Sets all the visual style you see in the app

#import "AppearanceControls.h"

@implementation AppearanceControls

+ (void)applyStyle
{
    //Change style of status bar
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:NO];
    
    //Chance navigation bar to orange with white tints
    UINavigationBar *navigationBarAppearance = [UINavigationBar appearance];
    [[UINavigationBar appearance] setBackgroundImage:[[UIImage alloc] init] forBarMetrics:UIBarMetricsDefault];
    [[UINavigationBar appearance] setBackgroundColor:[UIColor colorWithRed:242.0f/255.0f green:119.0f/255.0f blue:75.0f/255.0f alpha:1.0f]];
    [navigationBarAppearance setTitleTextAttributes:[NSDictionary dictionaryWithObject:[UIColor whiteColor] forKey:NSForegroundColorAttributeName]];
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    
    //Change tab bar tint to orange
    [[UITabBar appearance] setTintColor:[UIColor colorWithRed:242.0f/255.0f green:119.0f/255.0f blue:75.0f/255.0f alpha:1.0f]];
}

@end

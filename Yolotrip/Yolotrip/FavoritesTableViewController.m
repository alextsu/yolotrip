//
//  FavoritesTableViewController.m
//  Yolotrip
//
//  Created by Alexander Tsu on 2/27/15.
//  Copyright (c) 2015 Alexander Tsu. All rights reserved.
//
//  Description: This class controls the favorites tab. It loads these favorites by getting the NSArray of favorited items via NSDefaults and setting each element in the table based on this array.

#import "FavoritesTableViewController.h"
#import "FavoritesTableViewCell.h"
#import "FavoritesDetailViewController.h"

@interface FavoritesTableViewController ()
@property (strong, nonatomic) NSMutableArray *favoritesList;
@end

@implementation FavoritesTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    [self getDefaults];

}

- (void) viewWillAppear:(BOOL)animated {
    NSLog(@"Tab Bar Selected");
    [self getDefaults];
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//Calls NSDefaults to get NSArray to populate page
- (void) getDefaults {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSObject *object = [defaults objectForKey:@"favorites"];
    if (object != nil) {
        //Copy each element into a mutable array (so you can delete them later if you wish)
        NSArray *favoriteArray = [defaults objectForKey:@"favorites"];
        NSMutableArray *duplicateFavoriteArray = [NSMutableArray arrayWithCapacity:[favoriteArray count]+1];
        for (id anObject in favoriteArray) {
            [duplicateFavoriteArray addObject:[anObject mutableCopy]];
        }
        //copy in the array to bookmarkList
        self.favoritesList = duplicateFavoriteArray;
        
    }
}
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [self.favoritesList count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    //Set cell values
    FavoritesTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"favoriteCell" forIndexPath:indexPath];
    cell.favoriteLocationName.text = [[self.favoritesList objectAtIndex:indexPath.row] objectForKey:@"name"];
    
    NSString *ImageURL = [[self.favoritesList objectAtIndex:indexPath.row] objectForKey:@"image_url"];
    NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:ImageURL]];
    cell.favoriteImage.image = [UIImage imageWithData:imageData];
    
    //Fit the images into circles
    cell.favoriteImage.layer.cornerRadius = cell.favoriteImage.frame.size.height /2;
    cell.favoriteImage.layer.masksToBounds = YES;
    cell.favoriteImage.layer.borderWidth = 0;
    
    return cell;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/


// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source

        NSLog(@"Deleting object: %@", [self.favoritesList objectAtIndex:indexPath.row]);
        
        //remove it
        [self.favoritesList removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath, nil] withRowAnimation:UITableViewRowAnimationFade];
        
        //update the defaults to make sure they match what's been deleted in the bookmarview
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:self.favoritesList forKey:@"favorites"];
        
        
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {

    //Pass in the JSON for the selected location into favoritesDetailViewController
    if([[segue identifier] isEqualToString:@"segueToDetails"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        NSDictionary *selectedFavorite = [self.favoritesList objectAtIndex:indexPath.row];
        FavoritesDetailViewController *temp = [segue destinationViewController];
        [temp setDisplayedResult:selectedFavorite];
    }
}


@end

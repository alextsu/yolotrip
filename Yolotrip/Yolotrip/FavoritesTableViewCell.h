//
//  FavoritesTableViewCell.h
//  Yolotrip
//
//  Created by Alexander Tsu on 2/27/15.
//  Copyright (c) 2015 Alexander Tsu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FavoritesTableViewCell : UITableViewCell


@property (weak, nonatomic) IBOutlet UILabel *favoriteLocationName;
@property (weak, nonatomic) IBOutlet UIImageView *favoriteImage;

@end

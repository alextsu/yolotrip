//
//  ShuffleArray.m
//  Yolotrip
//
//  Created by Alexander Tsu on 2/27/15.
//  Copyright (c) 2015 Alexander Tsu. All rights reserved.
//
//  Description: Standard shuffle array method used in our previous homework.

#import "ShuffleArray.h"
#import <Foundation/Foundation.h>

#import "ShuffleArray.h"

//shuffledArray method taken from course notes
@implementation NSArray(Shuffle)
- (NSMutableArray *)shuffledArray
{
    // create temporary mutable array
    NSMutableArray *tmpArray = [NSMutableArray arrayWithCapacity:[self count]];
    
    for (id anObject in self) {
        NSUInteger randomPos = arc4random()%([tmpArray count]+1);
        [tmpArray insertObject:anObject atIndex:randomPos];
    }
    
    return [NSMutableArray arrayWithArray:tmpArray]; 
}
@end
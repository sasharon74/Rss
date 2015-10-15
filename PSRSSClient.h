//
//  PSRSSClient.h
//  ЮУрГУ Онлайн
//
//  Created by Alex on 21.04.14.
//  Copyright (c) 2014 Alex. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "RssManagedItem+PSRssImages.h"

typedef void(^PSRSSClientSuccessBlock)(NSArray *result);
typedef void(^PSRSSClientFailureBlock)(NSError *error);

@interface PSRSSClient : NSObject

@property (nonatomic, strong, readonly) NSManagedObjectContext *managedObjectContext;

+ (PSRSSClient *)sharedInstance;
- (BOOL)hasCachedRssFeed;
- (void)fetchRssFeedCachedBlock:(PSRSSClientSuccessBlock)CachedBlock successBlock:(PSRSSClientSuccessBlock)successBlock failureBlock:(PSRSSClientFailureBlock)failureBlock;
- (NSArray *)fetchCachedRssFeed;

@end

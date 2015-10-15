//
//  PSRSSClient.m
//  ЮУрГУ Онлайн
//
//  Created by Alex on 21.04.14.
//  Copyright (c) 2014 Alex. All rights reserved.
//

#import "PSRSSClient.h"
#import "PSCopyDatabase.h"
#import "FMDatabase+SharedInstance.h"
#import "RSSItem.h"
#import "RSSParser.h"

@interface PSRSSClient ()

{
    const NSString *nameDatabase;
}
@property (strong, nonatomic) FMDatabase *database;
@property (nonatomic, strong, readwrite) NSManagedObjectContext *managedObjectContext;
@end

@implementation PSRSSClient

+ (PSRSSClient *)sharedInstance
{
    //хранение состояния
	static dispatch_once_t p = 0;
	__strong static id _sharedObject = nil;
	
	dispatch_once(&p, ^{
		_sharedObject = [[self alloc] init];
	});
	
	return _sharedObject;
}

- (id)init
{
    self = [super init];
    
    if (!self)
    {
        return nil;
    }
    
    //nameDatabase = @"rss.sqlite";
    nameDatabase = @"RssMnaged.sqlite";
    
    NSError *error = nil;
    
    NSString *databaseFileName = (NSString *)nameDatabase;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *dataBasePath = [documentsDirectory stringByAppendingPathComponent:databaseFileName];
    
    NSManagedObjectModel *managedObjectModel = [NSManagedObjectModel mergedModelFromBundles:nil];
    NSPersistentStoreCoordinator *persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc]initWithManagedObjectModel:managedObjectModel];
    [persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:[NSURL fileURLWithPath:dataBasePath] options:nil error:&error];
    if (error) {
        NSLog(@"%@", [error localizedDescription]);
    }
    

    NSManagedObjectContext *managedObjectContext = [[NSManagedObjectContext alloc] init];
    managedObjectContext.persistentStoreCoordinator = persistentStoreCoordinator;
    self.managedObjectContext = managedObjectContext;

    return self;
}

- (BOOL)hasCachedRssFeed
{
    NSInteger rowCount = 0;
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"RssManagedItem" inManagedObjectContext:self.managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]init];
    fetchRequest.entity = entityDescription;
    
    NSError *error = nil;
    rowCount = [self.managedObjectContext countForFetchRequest:fetchRequest error:&error];
    if (error) {
        NSLog(@"%@", [error localizedDescription]);
    }
    
    return rowCount != 0;
}

- (NSArray *)fetchCachedRssFeed
{
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"RssManagedItem" inManagedObjectContext:self.managedObjectContext];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"pubDate" ascending:NO];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]init];
    fetchRequest.entity = entityDescription;
    fetchRequest.sortDescriptors = @[sortDescriptor];
    
    NSError *error = nil;
    NSArray *results = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (error) {
        NSLog(@"%@", [error localizedDescription]);
    }
    
    return results;
}

- (void)fetchRssFeedCachedBlock:(PSRSSClientSuccessBlock)CachedBlock successBlock:(PSRSSClientSuccessBlock)successBlock failureBlock:(PSRSSClientFailureBlock)failureBlock
{
    if (CachedBlock)
    {
        NSArray *cachedFeed = [self fetchCachedRssFeed];
        CachedBlock(cachedFeed);
    }
    
    NSURL *url = [NSURL URLWithString:@"http://profcom74.ru/feed?n=100"];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [RSSParser parseRSSFeedForRequest:request success:^(NSArray *feedItems) {
    
        for (RSSItem *item in feedItems)
        {
            NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"RssManagedItem" inManagedObjectContext:self.managedObjectContext];
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"guid == %@", item.guid];
            NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]init];
            fetchRequest.entity = entityDescription;
            fetchRequest.predicate = predicate;
            
            NSError *error = nil;
            NSArray *results = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
            if (error) {
                NSLog(@"%@", [error localizedDescription]);
                continue;
            }
            
            RssManagedItem *managedItem = nil;
            if ([results count]) {
                managedItem = [results objectAtIndex:0];
            }
            else
            {
                managedItem = [NSEntityDescription insertNewObjectForEntityForName:@"RssManagedItem" inManagedObjectContext:self.managedObjectContext];
            }
            
           managedItem.title = item.title;
           managedItem.itemDescription = item.itemDescription;
           managedItem.content = item.content;
           managedItem.link = [item.link absoluteString];
           managedItem.commentsLink = [item.commentsLink absoluteString];
           managedItem.commentsFeed = [item.commentsFeed absoluteString];
           managedItem.commentsCount = item.commentsCount;
           managedItem.pubDate = item.pubDate;
           managedItem.author = item.author;
           managedItem.guid = item.guid;
           
            [self.managedObjectContext save:&error];
            if (error) {
                NSLog(@"%@", [error localizedDescription]);
            }

        }
    if (successBlock) {
            NSArray *cachedFeed = [self fetchCachedRssFeed];
            successBlock(cachedFeed);
    }
    }failure:failureBlock
     ];
    
}


//- (BOOL)hasCachedRssFeed
//{
//    NSInteger rowCount = 0;
//    FMResultSet *resultSet = [self.database executeQuery:@"SELECT COUNT(*) FROM rss"];
//    if ([resultSet next]) {
//        rowCount = [resultSet intForColumnIndex:0];
//    }
//
//    return rowCount != 0;
//}
//
//- (NSArray *)fetchCachedRssFeed
//{
//    FMDatabase *database = self.database;
//    NSMutableArray *results = [NSMutableArray array];
//    
//    FMResultSet *resultSet = [database executeQuery:@"SELECT * FROM rss ORDER BY pub_date DESC"];
//    while ([resultSet next]) {
//        RSSItem *item = [[RSSItem alloc]init];
//        item.title = [resultSet stringForColumn:@"title"];
//        item.itemDescription = [resultSet stringForColumn:@"item_description"];
//        item.content = [resultSet stringForColumn:@"content"];
//        item.link = [NSURL URLWithString:[resultSet stringForColumn:@"link"]];
//        item.commentsLink = [NSURL URLWithString:[resultSet stringForColumn:@"comments_link"]];
//        item.commentsFeed = [NSURL URLWithString:[resultSet stringForColumn:@"comments_feed"]];
//        item.commentsCount = [NSNumber numberWithInteger:[resultSet intForColumn:@"comments_count"]];
//        item.pubDate = [resultSet dateForColumn:@"pub_date"];
//        item.author = [resultSet stringForColumn:@"author"];
//        item.guid = [resultSet stringForColumn:@"guid"];
//        
//        [results addObject:item];
//    }
//    return results;
//}
//
//- (void)fetchRssFeedCachedBlock:(PSRSSClientSuccessBlock)CachedBlock successBlock:(PSRSSClientSuccessBlock)successBlock failureBlock:(PSRSSClientFailureBlock)failureBlock
//{
//    if (CachedBlock)
//    {
//        NSArray *cachedFeed = [self fetchCachedRssFeed];
//        CachedBlock(cachedFeed);
//    }
//    
//    NSURL *url = [NSURL URLWithString:@"http://profcom74.ru/feed/"];
//    NSURLRequest *request = [NSURLRequest requestWithURL:url];
//    [RSSParser parseRSSFeedForRequest:request success:^(NSArray *feedItems) {
//        
//        FMDatabase *database = self.database;
//        for (RSSItem *item in feedItems)
//        {
//            NSMutableArray *parameters = [NSMutableArray arrayWithCapacity:10];
//            [parameters addObject:item.title];
//            [parameters addObject:item.itemDescription];
//            [parameters addObject:item.content];
//            [parameters addObject:[item.link absoluteString]];
//            [parameters addObject:[item.commentsLink absoluteString]];
//            [parameters addObject:[item.commentsFeed absoluteString]];
//            [parameters addObject:item.commentsCount];
//            [parameters addObject:item.pubDate];
//            [parameters addObject:item.author];
//            [parameters addObject:item.guid];
//            
//            BOOL updateResult = [database executeQuery:@"INSERT OR REPLACE INTO rss VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)" withArgumentsInArray:parameters];
//            if (!updateResult)
//            {
//                NSLog(@"Failed to insert row: %@", [database lastError]);
//            }
//        }
//        if (successBlock) {
//            NSArray *cachedFeed = [self fetchCachedRssFeed];
//            successBlock(cachedFeed);
//        }
//        //self.data = feedItems;
////        [activityView stopAnimating];
////        [self ReloadData];
//    }failure:failureBlock
//     ];
//
//}


@end

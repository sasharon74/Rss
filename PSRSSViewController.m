//
//  PSRSSViewController.m
//  ЮУрГУ Онлайн
//
//  Created by Alex on 14.04.14.
//  Copyright (c) 2014 Alex. All rights reserved.
//

#import "PSRSSViewController.h"
#import "UIImageView+AFNetworking.h"
#import "PSRSSDetailViewController.h"
#import "PSCopyDatabase.h"
#import "AFNetworkActivityIndicatorManager.h"
#import "SVPullToRefresh.h"
#import "PSRSSClient.h"

#import "UIViewController+ECSlidingViewController.h"
#import "ECSlidingViewController.h"
#import "MEFoldAnimationController.h"

#import <QuartzCore/QuartzCore.h>


@interface PSRSSViewController () <NSFetchedResultsControllerDelegate, ECSlidingViewControllerDelegate,UIViewControllerAnimatedTransitioning>
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@end

@implementation PSRSSViewController

- (void)viewDidLoad
{
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithTitle:@"Лента" style:UIBarButtonItemStyleBordered target:nil action:nil];
        self.navigationItem.backBarButtonItem = backItem;
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    //[self.navigationItem setBackBarButtonItem:backItem];
    
    [self.view addGestureRecognizer:self.slidingViewController.panGesture];

    
    [AFNetworkActivityIndicatorManager sharedManager].enabled = YES;
    
    NSManagedObjectContext *managedObjectContext = [PSRSSClient sharedInstance].managedObjectContext;
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"RssManagedItem" inManagedObjectContext:managedObjectContext];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"pubDate" ascending:NO];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]init];
    fetchRequest.entity = entityDescription;
    fetchRequest.sortDescriptors = @[sortDescriptor];
    
    NSFetchedResultsController *fetchedResultsController = [[NSFetchedResultsController alloc]initWithFetchRequest:fetchRequest managedObjectContext:managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    fetchedResultsController.delegate = self;
    self.fetchedResultsController = fetchedResultsController;
    [self.fetchedResultsController performFetch:nil];
    
    [self.tableView reloadData];
    
    [self.tableView addPullToRefreshWithActionHandler:^{
        [self RefreshData];
    } position:SVPullToRefreshPositionTop];
    [self.tableView triggerPullToRefresh];
    
    
//    BOOL hasCache = [[PSRSSClient sharedInstance]hasCachedRssFeed];
//    
//    if (hasCache)
//    {
//        self.data = [[PSRSSClient sharedInstance]fetchCachedRssFeed];
//        [self.tableView reloadData];
//    }else
//    {
//        UIActivityIndicatorView *activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
//        activityView.frame=CGRectMake(150, 150, 40, 140);
//        [self.view addSubview:activityView];
//        
//        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
//            
//            [activityView startAnimating];
//            
//            dispatch_async(dispatch_get_main_queue(), ^{
//                
//                [[PSRSSClient sharedInstance] fetchRssFeedCachedBlock:nil successBlock:^(NSArray *result) {
//                    [activityView stopAnimating];
//                    self.data = result;
//                    [self.tableView reloadData];
//                } failureBlock:^(NSError *error) {
//                }];
//                
//            });
//        });
//
//    }
    
     [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.fetchedResultsController.fetchedObjects count];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *const CellId = @"Cell";
    PSRSSTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellId];
    
    //[self.tableView setSeparatorInset:UIEdgeInsetsMake(15, 0, 0, 0)];
    
    RssManagedItem *item = [self.fetchedResultsController.fetchedObjects objectAtIndex:indexPath.row];
    NSArray *images = [NSArray array];
    images = [item imagesFromContent];
    
    NSString *urlStr = [images objectAtIndex:0];
    NSURL *url = [NSURL URLWithString:urlStr];
    cell.labelView.text = item.title;
    [cell.imageCell setImageWithURL:url];
    float width = cell.imageCell.bounds.size.width;
    cell.imageCell.layer.masksToBounds = YES;
    cell.imageCell.layer.cornerRadius = width/2;
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"dd.MM.yyyy"];
    [formatter setTimeZone:[NSTimeZone timeZoneWithName:@"..."]];
    cell.labelViewDate.text = [formatter stringFromDate:item.pubDate];
    cell.labelViewDate.textColor = [UIColor colorWithRed:0.62 green:0.77 blue:0.91 alpha:1.0];
    
    UIView* separatorLineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 5)];/// change size as you need.
    separatorLineView.backgroundColor = [UIColor colorWithRed:0.0f/255.0f green:0.0f/255.0f blue:0.0f/255.0f alpha:0.05f];// you can also put image here
    [cell.contentView addSubview:separatorLineView];
    //[tableView setSeparatorInset:UIEdgeInsetsMake(15, 0, 0, 0)];
    //tableView.separatorInset = UIEdgeInsetsMake (0, 15, 0,0);
    
    return  cell;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    if (indexPath)
    {
        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    if (indexPath)
    {
        RssManagedItem *item = [self.fetchedResultsController.fetchedObjects objectAtIndex:indexPath.row];
        [segue.destinationViewController setLinkContent:item];
    }
}

- (void)RefreshData
{
    [[PSRSSClient sharedInstance] fetchRssFeedCachedBlock:^(NSArray *result) {
        [self.tableView reloadData];
    } successBlock:^(NSArray *result) {
        [self.tableView.pullToRefreshView stopAnimating];
        [self.tableView reloadData];
    } failureBlock:^(NSError *error) {
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"Ошибка получения данных" message:nil delegate:nil cancelButtonTitle:@"ОK" otherButtonTitles: nil];
        [alertView show];
        [self.tableView.pullToRefreshView stopAnimating];
    }];
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView beginUpdates];
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView endUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath
{
    switch (type) {
        case NSFetchedResultsChangeInsert:
        {
            [self.tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            //RssManagedItem *item = [controller.fetchedObjects objectAtIndex:newIndexPath.row];
            //NSLog(@"%@", item.title);
            
            //[self setupLocalNotifications:item.title];
            NSString *const oldData = @"oldData";
            NSString *oldDataStr = [[NSUserDefaults standardUserDefaults] stringForKey:oldData];
            int i = oldDataStr.intValue;
            i++;
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%d",i] forKey:oldData];
            [userDefaults synchronize];
        }
            break;
        case NSFetchedResultsChangeUpdate:
            [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
        case NSFetchedResultsChangeDelete:
             [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
        case NSFetchedResultsChangeMove:
            [self.tableView moveRowAtIndexPath:indexPath toIndexPath:newIndexPath];
            break;
        default:
            break;
    }
}

//- (void)setupLocalNotifications:(NSString *)title
//{
//    UILocalNotification *localNotification = [[UILocalNotification alloc] init];
//    
//    localNotification.alertBody = title;
//    localNotification.fireDate = [NSDate dateWithTimeIntervalSinceNow:0];
//    localNotification.timeZone = [NSTimeZone defaultTimeZone];
//    
//    
//    [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
//}
@end

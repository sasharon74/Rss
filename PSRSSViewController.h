//
//  PSRSSViewController.h
//  ЮУрГУ Онлайн
//
//  Created by Alex on 14.04.14.
//  Copyright (c) 2014 Alex. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PSRSSTableViewCell.h"

@interface PSRSSViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>
@property (strong, nonatomic) NSArray *data;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

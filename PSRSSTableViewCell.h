//
//  PSRSSTableViewCell.h
//  ЮУрГУ Онлайн
//
//  Created by Alex on 14.04.14.
//  Copyright (c) 2014 Alex. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PSRSSTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *imageCell;

@property (weak, nonatomic) IBOutlet UILabel *labelView;
@property (weak, nonatomic) IBOutlet UILabel *labelViewDate;

@end

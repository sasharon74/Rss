//
//  PSRSSDetailViewController.h
//  ЮУрГУ Онлайн
//
//  Created by Alex on 14.04.14.
//  Copyright (c) 2014 Alex. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RSSItem.h"
#import "PSRSSClient.h"

@interface PSRSSDetailViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UILabel *labelView;
@property (weak, nonatomic) IBOutlet UIView *contentView;

@property (nonatomic, strong) RssManagedItem *linkContent;

@property (weak, nonatomic) IBOutlet UIWebView *WebView;

@end

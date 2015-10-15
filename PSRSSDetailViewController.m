//
//  PSRSSDetailViewController.m
//  ЮУрГУ Онлайн
//
//  Created by Alex on 14.04.14.
//  Copyright (c) 2014 Alex. All rights reserved.
//

#import "PSRSSDetailViewController.h"
#import "UIImageView+AFNetworking.h"
#import "HTMLParser.h"
#import "HTMLNode.h"

@interface PSRSSDetailViewController () <UIWebViewDelegate>

@end

@implementation PSRSSDetailViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    //[self reloadData];
    [self createWebViewWithHTML];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)LinkContent:(RssManagedItem *)linkContent
{
    self.linkContent = linkContent;
}

- (void)reloadData
{
    if (!self.linkContent)
    {
        return;
    }
    
    self.labelView.text = self.linkContent.title;

//    NSError *error = nil;
//    HTMLParser *parser = [[HTMLParser alloc] initWithString:self.linkContent.content error:&error];
//    
//    if (error) {
//        NSLog(@"Error: %@", error);
//        return;
//    }
//    HTMLNode *bodyNode = [parser body];
//    NSArray *postNodes = [bodyNode findChildTags:@"p"];
//    NSMutableArray *articlesDone = [[NSMutableArray alloc] init];
//    
//    for (HTMLNode *postNode in postNodes) {
//        NSMutableDictionary *article = [[NSMutableDictionary alloc] init];
//        NSArray *bTags = [postNode findChildTags:@"b"];
//        if (bTags.count > 0)
//        {
//            HTMLNode *aOne = [bTags objectAtIndex:0];
//            NSString *nameOfArticle = [aOne contents];
//            NSLog(@"%@", nameOfArticle);
//        }
//        //NSLog(@"%@",postNode.contents);
//    }
//
    
    
    self.textView.text = self.linkContent.content;
    
    NSArray *images = [self.linkContent imagesFromContent];
    NSString *urlStr = [images objectAtIndex:0];
    NSURL *url = [NSURL URLWithString:urlStr];
    [self.imageView setImageWithURL:url];
    
    CGSize textViewSize = [self.textView sizeThatFits:CGSizeMake(self.textView.frame.size.width, FLT_MAX)];
    //NSLog(@"%f",textViewSize.height);
    //Включение скролла
    
    CGRect contentViewFrame = self.contentView.frame;
    contentViewFrame.size.height += textViewSize.height- self.textView.frame.size.height;
    _contentView.frame = contentViewFrame;
    _scrollView.contentSize = _contentView.frame.size;
}

- (void) createWebViewWithHTML{
    UIWebView *webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 42, self.view.frame.size.width, self.view.frame.size.height-42)];
    [webView setBackgroundColor:[UIColor clearColor]];
    
    NSString *strTemplateHTML = [NSString stringWithFormat:@"<html><head><style>img{max-width:100%%;height:auto !important;width:auto !important;};</style></head><body '>%@</body></html>", self.linkContent.content];
    
    [webView loadHTMLString:strTemplateHTML baseURL:nil];
    
//    [webView setBackgroundColor:[UIColor clearColor]];
//    [webView setOpaque:NO];
    
    [self.view addSubview:webView];

}



@end

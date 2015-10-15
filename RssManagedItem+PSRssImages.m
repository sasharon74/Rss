//
//  RssManagedItem+PSRssImages.m
//  ЮУрГУ Онлайн
//
//  Created by Alex on 21.04.14.
//  Copyright (c) 2014 Alex. All rights reserved.
//

#import "RssManagedItem+PSRssImages.h"

@interface RssManagedItem (Private)

-(NSArray *)imagesFromHTMLString:(NSString *)htmlstr;

@end

@implementation RssManagedItem (PSRssImages)

-(NSArray *)imagesFromItemDescription
{
    if (self.itemDescription) {
        return [self imagesFromHTMLString:self.itemDescription];
    }
    
    return nil;
}

-(NSArray *)imagesFromContent
{
    if (self.content) {
        return [self imagesFromHTMLString:self.content];
    }
    
    return nil;
}

#pragma mark - retrieve images from html string using regexp (private methode)

-(NSArray *)imagesFromHTMLString:(NSString *)htmlstr
{
    NSMutableArray *imagesURLStringArray = [[NSMutableArray alloc] init];
    
    NSError *error;
    
    NSRegularExpression *regex = [NSRegularExpression
                                  regularExpressionWithPattern:@"(https?)\\S*(png|jpg|jpeg|gif)"
                                  options:NSRegularExpressionCaseInsensitive
                                  error:&error];
    
    [regex enumerateMatchesInString:htmlstr
                            options:0
                              range:NSMakeRange(0, htmlstr.length)
                         usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
                             [imagesURLStringArray addObject:[htmlstr substringWithRange:result.range]];
                         }];
    
    return [NSArray arrayWithArray:imagesURLStringArray];
}


@end

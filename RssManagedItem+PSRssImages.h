//
//  RssManagedItem+PSRssImages.h
//  ЮУрГУ Онлайн
//
//  Created by Alex on 21.04.14.
//  Copyright (c) 2014 Alex. All rights reserved.
//

#import "RssManagedItem.h"

@interface RssManagedItem (PSRssImages)

-(NSArray *)imagesFromItemDescription;
-(NSArray *)imagesFromContent;

@end

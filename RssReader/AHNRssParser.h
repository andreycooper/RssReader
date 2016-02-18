//
// Created by Andrey Bondarenko on 15.02.16.
// Copyright (c) 2016 Rus Wizards Group. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

extern NSString *const AHNItemXMLKey;
extern NSString *const AHNTitleXMLKey;
extern NSString *const AHNLinkXMLKey;
extern NSString *const AHNDescriptionXMLKey;
extern NSString *const AHNPubDateXMLKey;

@interface AHNRssParser : NSObject

/**
 *  Parses rss news from downloaded data and save its to managed object context, usually private. Also methods delete all previous parsed news
 *
 *  @param rssData Downloaded data
 *  @param context Private managed object context
 */
- (void)parseNewsFromData:(NSData *)rssData toManagedContext:(NSManagedObjectContext *)context;

@end
//
// Created by Andrey Bondarenko on 15.02.16.
// Copyright (c) 2016 Rus Wizards Group. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

extern NSString * const AHNItemXMLKey;
extern NSString * const AHNTitleXMLKey;
extern NSString * const AHNLinkXMLKey;
extern NSString * const AHNDescriptionXMLKey;
extern NSString * const AHNPubDateXMLKey;

@class AHNRssEntity;


@interface AHNRssParser : NSObject

- (NSArray<AHNRssEntity *> *)parseNewsFromData:(NSData *)rssData;

- (void)parseNewsFromData:(NSData *)rssData toManagedContext:(NSManagedObjectContext *)context;

@end
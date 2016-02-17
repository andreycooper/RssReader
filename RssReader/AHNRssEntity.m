//
//  AHNRssEntity.m
//  RssReader
//
//  Created by Andrey Bondarenko on 15.02.16.
//  Copyright © 2016 Rus Wizards Group. All rights reserved.
//

#import "AHNRssEntity.h"
#import "AHNRssParser.h"

@implementation AHNRssEntity

+ (instancetype)rssEntityFrom:(NSDictionary *)rssDictionary {
    return [AHNRssEntity entityWithTitle:rssDictionary[AHNTitleXMLKey]
                                    link:rssDictionary[AHNLinkXMLKey]
                                 content:rssDictionary[AHNDescriptionXMLKey]
                                    date:rssDictionary[AHNPubDateXMLKey]];
}

+ (instancetype)entityWithTitle:(NSString *)title link:(NSString *)link content:(NSString *)content date:(NSDate *)date {
    return [[self alloc] initWithTitle:title link:link content:content date:date];
}

- (instancetype)initWithTitle:(NSString *)title link:(NSString *)link content:(NSString *)content date:(NSDate *)date {
    self = [super init];
    if (self) {
        self.title = title;
        self.link = link;
        self.content = content;
        self.date = date;
    }
    return self;
}

- (NSString *)description {
    NSMutableString *description = [NSMutableString stringWithFormat:@"<%@: ", NSStringFromClass([self class])];
    [description appendFormat:@"self.title=%@", self.title];
    [description appendFormat:@", self.link=%@", self.link];
    [description appendFormat:@", self.content=%@", self.content];
    [description appendFormat:@", self.date=%@", self.date];
    [description appendString:@">"];
    return description;
}


@end

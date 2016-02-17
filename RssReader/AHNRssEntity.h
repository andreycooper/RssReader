//
//  AHNRssEntity.h
//  RssReader
//
//  Created by Andrey Bondarenko on 15.02.16.
//  Copyright © 2016 Rus Wizards Group. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GDataXMLNode.h"

@interface AHNRssEntity : NSObject

@property(strong, nonatomic) NSString *title;
@property(strong, nonatomic) NSString *link;
@property(strong, nonatomic) NSString *content;
@property(strong, nonatomic) NSDate *date;

+ (instancetype)rssEntityFrom:(NSDictionary *)rssDictionary;

+ (instancetype)entityWithTitle:(NSString *)title link:(NSString *)link content:(NSString *)content date:(NSDate *)date;

- (instancetype)initWithTitle:(NSString *)title link:(NSString *)link content:(NSString *)content date:(NSDate *)date;

- (NSString *)description;


@end

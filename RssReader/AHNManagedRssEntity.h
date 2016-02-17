//
//  AHNManagedRssEntity.h
//  RssReader
//
//  Created by Andrey Bondarenko on 15.02.16.
//  Copyright © 2016 Rus Wizards Group. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

NS_ASSUME_NONNULL_BEGIN

@interface AHNManagedRssEntity : NSManagedObject

- (void)fillManagedRssEntityFrom:(NSDictionary *)rssDictionary;

@end

NS_ASSUME_NONNULL_END

#import "AHNManagedRssEntity+CoreDataProperties.h"

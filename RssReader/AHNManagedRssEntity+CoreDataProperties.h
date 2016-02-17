//
//  AHNManagedRssEntity+CoreDataProperties.h
//  RssReader
//
//  Created by Andrey Bondarenko on 15.02.16.
//  Copyright © 2016 Rus Wizards Group. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "AHNManagedRssEntity.h"

NS_ASSUME_NONNULL_BEGIN

@interface AHNManagedRssEntity (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *content;
@property (nullable, nonatomic, retain) NSDate *date;
@property (nullable, nonatomic, retain) NSString *link;
@property (nullable, nonatomic, retain) NSString *title;

@end

NS_ASSUME_NONNULL_END

//
//  AHNCoreDataService.h
//  RssReader
//
//  Created by Andrey Bondarenko on 16.02.16.
//  Copyright © 2016 Rus Wizards Group. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

extern NSString *const AHNDataServiceDidSaveNotification;
extern NSString *const AHNDataServiceDidSaveFailedNotification;

@interface AHNCoreDataService : NSObject

@property(readonly, strong, nonatomic) NSManagedObjectContext *mainManagedObjectContext;
@property(readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property(readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

/**
 *  Initialize CoreData service as singleton
 *
 *  @return Singleton of CoreData service
 */
+ (instancetype)sharedInstance;

/**
 *  Method saves main managed object context
 */
- (void)saveMainContext;

/**
 *  Recurrently save managed object context
 *
 *  @param context NSManagedObject context, ussualy private
 */
- (void)saveContext:(NSManagedObjectContext *)context;

- (NSURL *)applicationDocumentsDirectory;

/**
 *  Returns managed object context with concurrency type: NSPrivateQueueConcurrencyType
 *
 *  @return NSManagedObjectContext
 */
- (NSManagedObjectContext *)managedPrivateObjectContext;

/**
 *  Helper's method for delete all rss entities from CoreData
 */
- (void)deleteAllRSSEntities;

/**
 *  Init request for fetching all rss news from CoreData
 *
 *  @param sortDescriptors Sort Descriptors, usually it's by date
 *
 *  @return Fetch request for all rss news
 */
- (NSFetchRequest *)fetchRequestForAllRSSEntitiesWithSortDescriptors:(NSArray <NSSortDescriptor *> *)sortDescriptors;

@end

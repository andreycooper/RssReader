//
//  AHNCoreDataService.h
//  RssReader
//
//  Created by Andrey Bondarenko on 16.02.16.
//  Copyright © 2016 Rus Wizards Group. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

extern NSString *const DataServiceDidSaveNotification;
extern NSString *const DataServiceDidSaveFailedNotification;

@interface AHNCoreDataService : NSObject

@property(readonly, strong, nonatomic) NSManagedObjectContext *mainManagedObjectContext;
@property(readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property(readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

+ (instancetype)sharedInstance;

- (void)saveMainContext;

- (void)saveContext:(NSManagedObjectContext *)context;

- (void)deleteAllRSSEntities;

- (NSManagedObjectContext *)managedPrivateObjectContext;

- (NSURL *)applicationDocumentsDirectory;

@end

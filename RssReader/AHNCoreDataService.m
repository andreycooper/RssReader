//
//  AHNCoreDataService.m
//  RssReader
//
//  Created by Andrey Bondarenko on 16.02.16.
//  Copyright © 2016 Rus Wizards Group. All rights reserved.
//

#import "AHNCoreDataService.h"
#import "AHNManagedRssEntity.h"

NSString *const DataServiceDidSaveNotification = @"DataServiceDidSaveNotification";
NSString *const DataServiceDidSaveFailedNotification = @"DataServiceDidSaveFailedNotification";

@implementation AHNCoreDataService

+ (instancetype)sharedInstance {
    static id sharedInstance = nil;

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[[self class] alloc] init];
    });

    return sharedInstance;
}

#pragma mark - Core Data stack

@synthesize mainManagedObjectContext = _mainManagedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;


- (NSURL *)applicationDocumentsDirectory {
    // The directory the application uses to store the Core Data store file. This code uses a directory named "com.ruswizards.RssReader" in the application's documents directory.
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSManagedObjectModel *)managedObjectModel {
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }

    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"RssReader" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }

    // Define the Core Data version migration options
    NSDictionary *options = @{NSMigratePersistentStoresAutomaticallyOption : @YES,
            NSInferMappingModelAutomaticallyOption : @YES};

    // Create the coordinator and store

    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"RssReader.sqlite"];
    NSError *error = nil;
    NSString *failureReason = @"There was an error creating or loading the application's saved data.";
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:options error:&error]) {
        // Report any error we got.
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
        dict[NSLocalizedFailureReasonErrorKey] = failureReason;
        dict[NSUnderlyingErrorKey] = error;
        error = [NSError errorWithDomain:@"com.ruswizards.errors" code:9999 userInfo:dict];
        NSLog(@"Fatal error while creating persistent store: %@, %@", error, [error userInfo]);
        abort();
    }

    return _persistentStoreCoordinator;
}


- (NSManagedObjectContext *)mainManagedObjectContext {
    if (_mainManagedObjectContext != nil) {
        return _mainManagedObjectContext;
    }

    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        return nil;
    }
    _mainManagedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    [_mainManagedObjectContext setPersistentStoreCoordinator:coordinator];
    return _mainManagedObjectContext;
}

- (NSManagedObjectContext *)managedPrivateObjectContext {
    NSManagedObjectContext *privateContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    [privateContext setParentContext:[self mainManagedObjectContext]];
    return privateContext;
}

#pragma mark - Core Data Saving support

- (void)saveContext:(NSManagedObjectContext *)context {
    [context performBlockAndWait:^{
        NSError *error;
        if (context.hasChanges && ![context save:&error]) {
            NSLog(@"Unresolved error %@, \n%@", error, [error userInfo]);
            [[NSNotificationCenter defaultCenter] postNotificationName:DataServiceDidSaveFailedNotification object:error];
            abort();
        }
    }];
    if (context.parentContext) {
        [self saveContext:context.parentContext];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:DataServiceDidSaveNotification object:nil];
}

- (void)deleteAllRSSEntities {
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:NSStringFromClass([AHNManagedRssEntity class])];
    NSBatchDeleteRequest *deleteRequest = [[NSBatchDeleteRequest alloc] initWithFetchRequest:request];

    NSError *deleteError = nil;
    NSManagedObjectContext *privateContext = [self managedPrivateObjectContext];
    [self.persistentStoreCoordinator executeRequest:deleteRequest withContext:privateContext error:&deleteError];
    if (deleteError) {
        NSLog(@"Unresolved error while deleting RSS entities: %@, \n%@", deleteError, [deleteError userInfo]);
        abort();
    }
}


- (void)saveMainContext {
    NSManagedObjectContext *managedObjectContext = self.mainManagedObjectContext;
    if (managedObjectContext != nil) {
        NSError *error = nil;
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            NSLog(@"Unresolved error %@, \n%@", error, [error userInfo]);
            [[NSNotificationCenter defaultCenter] postNotificationName:DataServiceDidSaveFailedNotification object:error];
        }
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:DataServiceDidSaveNotification object:nil];
}

@end

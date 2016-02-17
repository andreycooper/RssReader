//
// Created by Andrey Bondarenko on 15.02.16.
// Copyright (c) 2016 Rus Wizards Group. All rights reserved.
//

#import "AHNRssParser.h"
#import "GDataXMLNode.h"
#import "AHNManagedRssEntity.h"
#import "AHNCoreDataService.h"


NSString *const AHNItemXMLKey = @"item";
NSString *const AHNTitleXMLKey = @"title";
NSString *const AHNLinkXMLKey = @"link";
NSString *const AHNDescriptionXMLKey = @"description";
NSString *const AHNPubDateXMLKey = @"pubDate";

@implementation AHNRssParser

#pragma mark - Public methods

- (void)parseNewsFromData:(NSData *)rssData toManagedContext:(NSManagedObjectContext *)context {
    NSArray<NSDictionary *> *rssDictionaryArray = [self parseRssFromData:rssData];
    
    if (rssDictionaryArray.count > 0) {
        // Delete all previous parsed entities from CoreData
        [[AHNCoreDataService sharedInstance] deleteAllRSSEntities];
        
        for (NSDictionary *rssDictionary in rssDictionaryArray) {
            AHNManagedRssEntity *managedRssEntity = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([AHNManagedRssEntity class])
                                                                                  inManagedObjectContext:context];
            if (managedRssEntity) {
                [managedRssEntity fillManagedRssEntityFrom:rssDictionary];
            }
        }
    }
    
    if (context.hasChanges) {
        [[AHNCoreDataService sharedInstance] saveContext:context];
    }
}

#pragma mark - Private methods

/**
 *  Parses data using GdataXML lib
 *
 *  @param rssData Downloaded data
 *
 *  @return Array of dictionary that represents rss item
 */
- (NSArray<NSDictionary *> *)parseRssFromData:(NSData *)rssData {
    // parse data using GdataXML lib into GDataXML document
    NSError *parsingDataError;
    GDataXMLDocument *xmlDocument = [[GDataXMLDocument alloc] initWithData:rssData encoding:NSUTF8StringEncoding error:&parsingDataError];
    if (parsingDataError) {
        NSLog(@"Error while parsing XML: %@", parsingDataError);
        NSString *dataString = [[NSString alloc] initWithData:rssData encoding:NSUTF8StringEncoding];
        NSLog(@"Data: %@", dataString);
        return nil;
    }

    NSMutableArray<NSDictionary *> *rssDictionariesArray = [[NSMutableArray alloc] init];

    // create array of GDataXML elements for nodes "item"
    NSError *parsingItemsError;
    NSArray *rssItems = [xmlDocument nodesForXPath:@"//item" error:&parsingItemsError];
    if (parsingItemsError) {
        NSLog(@"Error while parsing items from XML: %@", parsingItemsError);
        return nil;
    }

    // parse each elemnent into dictionary and add to array
    for (GDataXMLElement *element in rssItems) {
        NSDictionary *rssDictionary = [self parseXMLItem:element];
        [rssDictionariesArray addObject:rssDictionary];
    }

    return [rssDictionariesArray copy];
}

/**
 *  Parses one GDataXML element into dictionary
 *
 *  @param dataXMLElement
 *
 *  @return Dictionary represents rss item
 */
- (NSDictionary *)parseXMLItem:(GDataXMLElement *)dataXMLElement {
    NSMutableDictionary *rssDictionary = [[NSMutableDictionary alloc] init];

    [self addStringFromXMLElement:dataXMLElement toDictionary:rssDictionary forKey:AHNTitleXMLKey];
    [self addStringFromXMLElement:dataXMLElement toDictionary:rssDictionary forKey:AHNLinkXMLKey];
    [self addStringFromXMLElement:dataXMLElement toDictionary:rssDictionary forKey:AHNDescriptionXMLKey];
    [self addDateFromXMLElement:dataXMLElement toDictionary:rssDictionary forKey:AHNPubDateXMLKey];

    return [rssDictionary copy];
}

/**
 *  Add NSString object to dictionary from GDataXML element for specified key
 *
 *  @param dataXMLElement
 *  @param rssDictionary
 *  @param key            could be "title", "description" or "link" for rss dicitionary
 */
- (void)addStringFromXMLElement:(GDataXMLElement *)dataXMLElement toDictionary:(NSMutableDictionary *)rssDictionary forKey:(NSString *)key {
    NSArray *elementArray = [dataXMLElement elementsForName:key];
    if (elementArray.count > 0) {
        GDataXMLElement *element = elementArray[0];
        rssDictionary[key] = [element stringValue];
    }
}

/**
 *  Add NSDate object to dictionary from GDataXML element for specified key
 *
 *  @param dataXMLElement
 *  @param rssDictionary
 *  @param key            must be "pubDate" for rss dictionary
 */
- (void)addDateFromXMLElement:(GDataXMLElement *)dataXMLElement toDictionary:(NSMutableDictionary *)rssDictionary forKey:(NSString *)key {
    NSArray *elementArray = [dataXMLElement elementsForName:key];
    if (elementArray.count > 0) {
        GDataXMLElement *element = elementArray[0];
        rssDictionary[key] = [self parsePacificDateFromString:[element stringValue]];
    }
}

/**
 *  Helper method which parses NSString into NSDate
 *
 *  @param dateString
 *
 *  @return NSDate 
 */
- (NSDate *)parsePacificDateFromString:(NSString *)dateString {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"EEE, dd MMM yyyy HH:mm:ss zzz";
    return [dateFormatter dateFromString:dateString];
}

@end
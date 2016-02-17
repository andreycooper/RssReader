//
//  AHNManagedRssEntity.m
//  RssReader
//
//  Created by Andrey Bondarenko on 15.02.16.
//  Copyright © 2016 Rus Wizards Group. All rights reserved.
//

#import "AHNManagedRssEntity.h"
#import "AHNRssParser.h"

@implementation AHNManagedRssEntity

- (void)fillManagedRssEntityFrom:(NSDictionary *)rssDictionary {
    if (self) {
        self.title = rssDictionary[AHNTitleXMLKey];
        self.link = rssDictionary[AHNLinkXMLKey];
        self.content = rssDictionary[AHNDescriptionXMLKey];
        self.date = rssDictionary[AHNPubDateXMLKey];
    }
}
@end

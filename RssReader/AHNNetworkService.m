//
//  NetworkService.m
//  RssReader
//
//  Created by Andrey Bondarenko on 15.02.16.
//  Copyright © 2016 Rus Wizards Group. All rights reserved.
//

#import "AHNNetworkService.h"
#import "AHNRssParser.h"
#import "AHNRssEntity.h"
#import "AppDelegate.h"
#import "AHNCoreDataService.h"

@implementation AHNNetworkService

- (NSURLSession *)backgroundSession {
    static NSURLSession *session = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:@"com.ruswizards.RssReader.BackgroundSession"];
        [config setAllowsCellularAccess:YES];
        session = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:nil];
    });
    return session;
}

- (void)fetchRssNews {
    NSURL *appleURL = [NSURL URLWithString:@"http://images.apple.com/main/rss/hotnews/hotnews.rss"];

    NSURLSessionDataTask *downloadXMLTask = [[self backgroundSession] dataTaskWithURL:appleURL];

    [downloadXMLTask resume];
}

- (void)fetchRSSNewsWithDelegate:(id <AHNNetworkServiceDelegate>)delegate {
    self.delegate = delegate;
    [self fetchRssNews];
}

#pragma mark - NSURLSessionDataDelegate

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data {
    AHNRssParser *parser = [[AHNRssParser alloc] init];
    NSArray <AHNRssEntity *> *rssEntityArray = [parser parseNewsFromData:data];
    [parser parseNewsFromData:data toManagedContext:[[AHNCoreDataService sharedInstance] managedPrivateObjectContext]];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.delegate networkService:self didFetchingRss:rssEntityArray];
    });
}

@end

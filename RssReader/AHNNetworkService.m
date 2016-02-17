//
//  NetworkService.m
//  RssReader
//
//  Created by Andrey Bondarenko on 15.02.16.
//  Copyright © 2016 Rus Wizards Group. All rights reserved.
//

#import "AHNNetworkService.h"
#import "AHNRssParser.h"
#import "AHNCoreDataService.h"
#import "AppDelegate.h"

@implementation AHNNetworkService

/**
 *  Initialiazes background NSURLSession as singleton
 *
 *  @return Singleton instance of NSURLSession
 */
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

#pragma mark - Public methods

- (void)fetchRssNews {
    NSURL *appleURL = [NSURL URLWithString:@"http://images.apple.com/main/rss/hotnews/hotnews.rss"];

    NSURLSessionDataTask *downloadXMLTask = [[self backgroundSession] dataTaskWithURL:appleURL];

    // Show network indicator and start data task
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    [downloadXMLTask resume];
}

- (void)fetchRSSNewsWithDelegate:(id <AHNNetworkServiceDelegate>)delegate {
    self.delegate = delegate;
    [self fetchRssNews];
}

#pragma mark - NSURLSessionDataDelegate

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data {
    // Parse rss news into Core Data directly
    AHNRssParser *parser = [[AHNRssParser alloc] init];
    [parser parseNewsFromData:data toManagedContext:[[AHNCoreDataService sharedInstance] managedPrivateObjectContext]];

    dispatch_async(dispatch_get_main_queue(), ^{
        // Hide network indicator and send message to delegate
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        if ([self.delegate respondsToSelector:@selector(networkService:didFetchingRss:)]) {
            [self.delegate networkService:self didFetchingRss:YES];
        }
    });
}

@end

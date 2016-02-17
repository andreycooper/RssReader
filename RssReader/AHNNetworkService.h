//
//  NetworkService.h
//  RssReader
//
//  Created by Andrey Bondarenko on 15.02.16.
//  Copyright © 2016 Rus Wizards Group. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AHNNetworkService;

@protocol AHNNetworkServiceDelegate <NSObject>

- (void)networkService:(AHNNetworkService *)service didFetchingRss:(BOOL)isFetchCompleted;

@end

@interface AHNNetworkService : NSObject <NSURLSessionDelegate, NSURLSessionDataDelegate>

@property(weak, nonatomic) id <AHNNetworkServiceDelegate> delegate;

/**
 *  Method creates NSURLSessionDataTask and starts it for fetching rss from Apple site
 */
- (void)fetchRssNews;

/**
 *  Method sets delegate to network service and calls fetchRssNews
 *
 *  @param delegate AHNNetworkServiceDelegate
 */
- (void)fetchRSSNewsWithDelegate:(id <AHNNetworkServiceDelegate>)delegate;

@end

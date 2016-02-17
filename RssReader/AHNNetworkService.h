//
//  NetworkService.h
//  RssReader
//
//  Created by Andrey Bondarenko on 15.02.16.
//  Copyright © 2016 Rus Wizards Group. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AHNNetworkService;
@class AHNRssEntity;

@protocol AHNNetworkServiceDelegate <NSObject>

- (void)networkService:(AHNNetworkService *)service didFetchingRss:(BOOL)isFetchCompleted;

@end

@interface AHNNetworkService : NSObject <NSURLSessionDelegate, NSURLSessionDataDelegate>

@property(weak, nonatomic) id <AHNNetworkServiceDelegate> delegate;

- (void)fetchRssNews;

- (void)fetchRSSNewsWithDelegate:(id <AHNNetworkServiceDelegate>)delegate;

@end

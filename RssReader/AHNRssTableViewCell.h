//
//  AHNRssTableViewCell.h
//  RssReader
//
//  Created by Andrey Bondarenko on 16.02.16.
//  Copyright © 2016 Rus Wizards Group. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AHNRssEntity;
@class AHNManagedRssEntity;

@interface AHNRssTableViewCell : UITableViewCell

@property(weak, nonatomic) IBOutlet UILabel *titleLabel;
@property(weak, nonatomic) IBOutlet UITextView *contentTextView;
@property(weak, nonatomic) IBOutlet UILabel *dateLabel;

- (void)setupWithRssEntity:(AHNRssEntity *)rssEntity;

- (void)setupWithManagedRssEntity:(AHNManagedRssEntity *)managedRssEntity;

@end

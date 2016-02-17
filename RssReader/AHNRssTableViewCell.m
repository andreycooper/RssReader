//
//  AHNRssTableViewCell.m
//  RssReader
//
//  Created by Andrey Bondarenko on 16.02.16.
//  Copyright © 2016 Rus Wizards Group. All rights reserved.
//

#import "AHNRssTableViewCell.h"
#import "AHNManagedRssEntity.h"

@implementation AHNRssTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

#pragma mark - Public methods

- (void)setupWithManagedRssEntity:(AHNManagedRssEntity *)managedRssEntity {
    if (self) {
        self.titleLabel.text = managedRssEntity.title;
        self.contentTextView.text = managedRssEntity.content;
        self.dateLabel.text = [self formatDate:managedRssEntity.date];
        self.contentTextView.userInteractionEnabled = NO;
    }
}

#pragma mark - Private methods

- (NSString *)formatDate:(NSDate *)date {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.timeStyle = NSDateFormatterNoStyle;
    dateFormatter.dateStyle = NSDateFormatterMediumStyle;

    NSLocale *usLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    [dateFormatter setLocale:usLocale];
    return [dateFormatter stringFromDate:date];
}


@end

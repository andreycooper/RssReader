//
//  RssListTableViewController.m
//  RssReader
//
//  Created by Andrey Bondarenko on 15.02.16.
//  Copyright © 2016 Rus Wizards Group. All rights reserved.
//

#import <CoreData/CoreData.h>
#import "AHNRssListTableViewController.h"
#import "AHNWebViewController.h"
#import "AHNRssTableViewCell.h"
#import "AHNCoreDataService.h"
#import "AHNManagedRssEntity.h"


@interface AHNRssListTableViewController () <NSFetchedResultsControllerDelegate>

@property(strong, nonatomic) NSFetchedResultsController *fetchedResultsController;

- (IBAction)refreshRss:(UIRefreshControl *)sender;

@end

@implementation AHNRssListTableViewController

#pragma mark - Lifecycle;

- (void)viewDidLoad {
    [super viewDidLoad];

    [self initializeFetchedResultsController];

    [self setupTableView];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // if fetched managed RSS entitie count equals 0 then show view with hint
    if (self.fetchedResultsController.fetchedObjects.count > 0) {
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    } else {
        [self setupEmptyView];
    }
    
    return self.fetchedResultsController.sections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // get section from fetchedResultsController and return number of managed RSS entities
    id <NSFetchedResultsSectionInfo> sectionInfo = self.fetchedResultsController.sections[section];
    return [sectionInfo numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    AHNRssTableViewCell *rssTableViewCell = (AHNRssTableViewCell *) [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([AHNRssTableViewCell class]) forIndexPath:indexPath];
    [self setupCell:rssTableViewCell atIndexPath:indexPath];
    
    return rssTableViewCell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    AHNWebViewController *webViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"WebView"];
    AHNManagedRssEntity *managedRssEntity = [self.fetchedResultsController objectAtIndexPath:indexPath];
    webViewController.urlString = managedRssEntity.link;
    
    [self.navigationController pushViewController:webViewController animated:YES];
}

#pragma mark - NetworkServiceDelegate

- (void)networkService:(AHNNetworkService *)service didFetchingRss:(BOOL)isFetchCompleted {
    // stops refreshControl
    if (self.refreshControl) {
        [self updateLastUpdateMessageInRefreshControl];
        [self.refreshControl endRefreshing];
    }
}

#pragma mark - NSFetchedResultsControllerDelegate

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
    switch (type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
        case NSFetchedResultsChangeMove:
        case NSFetchedResultsChangeUpdate:
            break;
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    switch (type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
        case NSFetchedResultsChangeUpdate:
            [self setupCell:[self.tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
        case NSFetchedResultsChangeMove:
            [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [self.tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView endUpdates];
}

#pragma mark - Actions

/**
 *  Action for refreshControl
 *
 *  @param sender UIRefreshControl
 */
- (IBAction)refreshRss:(UIRefreshControl *)sender {
    [self refreshRssFromNetwork];
}

#pragma mark - Private methods

/**
 *  Setups tableView for automatic row heigth
 */
- (void)setupTableView {
    self.tableView.estimatedRowHeight = 300;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
}

/**
 *  Initializes fetchResultController and setup request for all managed RSS enetities
 */
- (void)initializeFetchedResultsController {
    // Get fetchRequest from CoreData service with date sorting
    NSSortDescriptor *dateSort = [NSSortDescriptor sortDescriptorWithKey:@"date" ascending:NO];
    NSFetchRequest *request = [[AHNCoreDataService sharedInstance] fetchRequestForAllRSSEntitiesWithSortDescriptors:@[dateSort]];

    NSManagedObjectContext *mainManagedObjectContext = [[AHNCoreDataService sharedInstance] mainManagedObjectContext];

    // initialize fitch controller
    [self setFetchedResultsController:[[NSFetchedResultsController alloc]
            initWithFetchRequest:request
            managedObjectContext:mainManagedObjectContext
              sectionNameKeyPath:nil
                       cacheName:nil]];
    [[self fetchedResultsController] setDelegate:self];

    // fetch managed rss entities
    NSError *error = nil;
    if (![[self fetchedResultsController] performFetch:&error]) {
        NSLog(@"Failed to initialize FetchedResultsController: %@\n%@", [error localizedDescription], [error userInfo]);
        abort();
    }
}

/**
 *  Fetchs RSS news from network using AHNNetworkService
 */
- (void)refreshRssFromNetwork {
    AHNNetworkService *networkService = [[AHNNetworkService alloc] init];
    [networkService fetchRSSNewsWithDelegate:self];
}

/**
 *  Fills TableView cell with content from managed rss entity. This methods also calls in FetchedResultsControllerDelegate
 *
 *  @param cell      custom TableView cell (AHNRssTableViewCell)
 *  @param indexPath needs for taking managed rss entity from fetchedResultsController
 */
- (void)setupCell:(AHNRssTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    AHNManagedRssEntity *managedRssEntity = [self.fetchedResultsController objectAtIndexPath:indexPath];
    [cell setupWithManagedRssEntity:managedRssEntity];
}

/**
 *  Setups an view with a hint when the table is empty
 */
- (void)setupEmptyView {
    UILabel *messageLabel = [self labelWithHintForEmptyView];

    self.tableView.backgroundView = messageLabel;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}

/**
 *  Creates UILabel with hint for empty view
 *
 *  @return UILabel
 */
- (UILabel *)labelWithHintForEmptyView {
    UILabel *messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];

    messageLabel.text = @"No data is currently available. Please pull down to refresh.";
    messageLabel.textColor = [UIColor blackColor];
    messageLabel.numberOfLines = 0;
    messageLabel.textAlignment = NSTextAlignmentCenter;
    [messageLabel sizeToFit];
    
    return messageLabel;
}

- (void)updateLastUpdateMessageInRefreshControl {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MMM d, h:mm a"];

    NSString *title = [NSString stringWithFormat:@"Last update: %@", [formatter stringFromDate:[NSDate date]]];
    NSDictionary *attrsDictionary = @{NSForegroundColorAttributeName : [UIColor blackColor]};
    NSAttributedString *attributedTitle = [[NSAttributedString alloc] initWithString:title attributes:attrsDictionary];
    self.refreshControl.attributedTitle = attributedTitle;
}

@end

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
    if (self.fetchedResultsController.fetchedObjects.count > 0) {
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    } else {
        [self setupEmptyView];
    }
    return self.fetchedResultsController.sections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    id <NSFetchedResultsSectionInfo> sectionInfo = self.fetchedResultsController.sections[section];
    return [sectionInfo numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    AHNRssTableViewCell *rssTableViewCell = (AHNRssTableViewCell *) [tableView dequeueReusableCellWithIdentifier:@"AHNRssTableViewCell" forIndexPath:indexPath];
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
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    if (self.refreshControl) {
        [self updateLastUpdateMessage];
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
            [[self tableView] deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [[self tableView] insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [[self tableView] endUpdates];
}

#pragma mark - Actions

- (IBAction)refreshRss:(UIRefreshControl *)sender {
    [self refreshRssFromNetwork];
}

#pragma mark - private methods

- (void)setupTableView {
    self.tableView.estimatedRowHeight = 300;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
}

- (void)initializeFetchedResultsController {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass([AHNManagedRssEntity class])];
    NSSortDescriptor *dateSort = [NSSortDescriptor sortDescriptorWithKey:@"date" ascending:NO];
    [request setSortDescriptors:@[dateSort]];
    NSManagedObjectContext *mainManagedObjectContext = [[AHNCoreDataService sharedInstance] mainManagedObjectContext];
    [self setFetchedResultsController:[[NSFetchedResultsController alloc]
            initWithFetchRequest:request
            managedObjectContext:mainManagedObjectContext
              sectionNameKeyPath:nil
                       cacheName:nil]];
    [[self fetchedResultsController] setDelegate:self];

    NSError *error = nil;
    if (![[self fetchedResultsController] performFetch:&error]) {
        NSLog(@"Failed to initialize FetchedResultsController: %@\n%@", [error localizedDescription], [error userInfo]);
        abort();
    }
}

- (void)refreshRssFromNetwork {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    AHNNetworkService *networkService = [[AHNNetworkService alloc] init];
    [networkService fetchRSSNewsWithDelegate:self];
}

- (void)setupCell:(AHNRssTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    AHNManagedRssEntity *managedRssEntity = [self.fetchedResultsController objectAtIndexPath:indexPath];
    [cell setupWithManagedRssEntity:managedRssEntity];
}

- (void)setupEmptyView {
    // Display a message when the table is empty
    UILabel *messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];

    messageLabel.text = @"No data is currently available. Please pull down to refresh.";
    messageLabel.textColor = [UIColor blackColor];
    messageLabel.numberOfLines = 0;
    messageLabel.textAlignment = NSTextAlignmentCenter;
    [messageLabel sizeToFit];

    self.tableView.backgroundView = messageLabel;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}

- (void)updateLastUpdateMessage {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MMM d, h:mm a"];
    NSString *title = [NSString stringWithFormat:@"Last update: %@", [formatter stringFromDate:[NSDate date]]];
    NSDictionary *attrsDictionary = @{NSForegroundColorAttributeName : [UIColor blackColor]};
    NSAttributedString *attributedTitle = [[NSAttributedString alloc] initWithString:title attributes:attrsDictionary];
    self.refreshControl.attributedTitle = attributedTitle;
}

@end

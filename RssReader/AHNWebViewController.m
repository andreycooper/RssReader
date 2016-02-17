//
//  AHNWebViewController.m
//  RssReader
//
//  Created by Andrey Bondarenko on 16.02.16.
//  Copyright © 2016 Rus Wizards Group. All rights reserved.
//

#import "AHNWebViewController.h"

@interface AHNWebViewController () <UIWebViewDelegate>

@property(weak, nonatomic) IBOutlet UIWebView *webView;

@end

@implementation AHNWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Setup back button
    self.navigationController.navigationBar.topItem.backBarButtonItem = [[UIBarButtonItem alloc]
            initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:nil action:nil];

    // setup webView
    self.webView.delegate = self;
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:self.urlString]];
    [self.webView loadRequest:request];
}

#pragma mark - UIWebViewDelegate

- (void)webViewDidStartLoad:(UIWebView *)webView {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}


@end

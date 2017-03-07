//
//  TermsConditionView.m
//  Sure
//
//  Created by Hema on 14/04/15.
//  Copyright (c) 2015 Shivendra. All rights reserved.
//

#import "TermsConditionView.h"

@interface TermsConditionView ()

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *indicator;
@property (weak, nonatomic) IBOutlet UIWebView *termAndCondition_webView;
@end

@implementation TermsConditionView

#pragma mark - View life cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    [_indicator startAnimating];
    
    self.title=@"Terms and Condition";
    [[self navigationController] setNavigationBarHidden:NO animated:YES];
    NSURL *url = [NSURL URLWithString:@"https://docs.google.com/document/d/1H2lWHV5k3zDUjWjoVVu66fGiMnTARwlnio6Mm1KdATg/preview"];
    NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
    [_termAndCondition_webView loadRequest:requestObj];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [_indicator stopAnimating];
    
}

#pragma mark - end
@end
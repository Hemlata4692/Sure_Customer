//
//  BackViewController.h
//  Sure
//
//  Created by Hema on 24/03/15.
//  Copyright (c) 2015 Shivendra. All rights reserved.
//

#import "BackViewController.h"
#import "SWRevealViewController.h"
@interface BackViewController ()<SWRevealViewControllerDelegate>
{
    UIBarButtonItem *barButton,*barButton1;
}

@end

@implementation BackViewController

#pragma mark - View life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    myDelegate.currentNavigationController=self.navigationController;
    [self addLeftBarButtonWithImage:[UIImage imageNamed:@"back"] secondImage:[UIImage imageNamed:@"menu.png"]];
    SWRevealViewController *revealController = [self revealViewController];
    [revealController panGestureRecognizer];
    [revealController tapGestureRecognizer];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - end

#pragma mark - Add back button add global side bar button
- (void)addLeftBarButtonWithImage:(UIImage *)buttonImage secondImage:(UIImage *)menuImage {
    CGRect framing = CGRectMake(0, 0, menuImage.size.width, menuImage.size.height);
    UIButton *menu = [[UIButton alloc] initWithFrame:framing];
    [menu setBackgroundImage:menuImage forState:UIControlStateNormal];
    barButton1 =[[UIBarButtonItem alloc] initWithCustomView:menu];
    framing = CGRectMake(0, 0, buttonImage.size.width, buttonImage.size.height);
    UIButton *button = [[UIButton alloc] initWithFrame:framing];
    [button setBackgroundImage:buttonImage forState:UIControlStateNormal];
    barButton =[[UIBarButtonItem alloc] initWithCustomView:button];
     [button addTarget:self action:@selector(backButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItems=[NSArray arrayWithObjects:barButton,barButton1, nil];
    SWRevealViewController *revealViewController = self.revealViewController;
    if (revealViewController)
    {
        [menu addTarget:self.revealViewController action:@selector(revealToggle:) forControlEvents:UIControlEventTouchUpInside];
        
        [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    }
    
}
//back button action
-(void)backButtonAction :(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}
#pragma mark - end

@end

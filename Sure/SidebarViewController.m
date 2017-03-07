//
//  SidebarViewController.m
//  SidebarDemoApp
//
//  Created by Ranosys on 06/02/15.
//  Copyright (c) 2015 Shivendra. All rights reserved.
//

#import "SidebarViewController.h"
#import "SWRevealViewController.h"
#import "LoginViewController.h"
#import "MyProfileViewController.h"



@interface SidebarViewController (){
    NSArray *menuItems;
    
    
}

@property (strong, nonatomic) IBOutlet UITableView *sideBarTable;

@end

@implementation SidebarViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    menuItems = @[@"Search", @"My Calendar", @"My Profile", @"Request Sent", @"Pending My Confirmation",@"Change City", @"Logout"];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    UIView *statusBarView = [[UIView alloc] initWithFrame:CGRectMake(0, -20, self.view.bounds.size.width, 20)];
    statusBarView.backgroundColor = [UIColor colorWithRed:255.0/255.0 green:63.0/255.0 blue:64.0/255.0 alpha:1.0];
    [self.view addSubview:statusBarView];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.revealViewController.frontViewController.view setUserInteractionEnabled:NO];
    [self.tableView reloadData];
    
}
-(void)viewWillDisappear:(BOOL)animated
{
    
    [super viewWillDisappear:animated];
    [self.revealViewController.frontViewController.view setUserInteractionEnabled:YES];
    
}
#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return menuItems.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *CellIdentifier = [menuItems objectAtIndex:indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    UIImageView *imageview = (UIImageView *)[cell.contentView viewWithTag:4];
    UILabel *nameLbl=(UILabel *)[cell.contentView viewWithTag:5];
    imageview.translatesAutoresizingMaskIntoConstraints = YES;
    nameLbl.translatesAutoresizingMaskIntoConstraints = YES;
    
    if ([[NSUserDefaults standardUserDefaults]integerForKey:@"PendingConfirmation"]>0)
    {
        imageview.frame = CGRectMake(15, 6, imageview.frame.size.width, imageview.frame.size.height);
        imageview.image =[UIImage imageNamed:@"pending_confirmation.png"];
        nameLbl.frame = CGRectMake(60, 13, nameLbl.frame.size.width, nameLbl.frame.size.height);
    }
    else
    {
        imageview.frame = CGRectMake(19, 11, imageview.frame.size.width, imageview.frame.size.height);
        imageview.image =[UIImage imageNamed:@"pending.png"];
         nameLbl.frame = CGRectMake(60, 14, nameLbl.frame.size.width, nameLbl.frame.size.height);
        
    }    
    return cell;
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 140.0;
}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView=[[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 140)];
    headerView.backgroundColor=[UIColor colorWithRed:204.0/255.0 green:204.0/255.0 blue:204.0/255.0 alpha:1.0];
    UILabel * label1;
    label1 = [[UILabel alloc] initWithFrame:CGRectMake(25, 45, 280, 22)];
    label1.backgroundColor = [UIColor clearColor];
    label1.textAlignment=NSTextAlignmentLeft;
    label1.textColor=[UIColor colorWithRed:253.0/255.0 green:47.0/255.0 blue:47.0/255.0 alpha:1.0];
    label1.font = [UIFont fontWithName:@"Helvetica" size:16];
    label1.text = @"Welcome" ;
    
    UILabel *label2;
    label2 = [[UILabel alloc] initWithFrame:CGRectMake(25, 60, 250, 70)];
    label2.lineBreakMode = NSLineBreakByWordWrapping;
    label2.numberOfLines = 2;
    label2.backgroundColor = [UIColor clearColor];
    label2.textAlignment=NSTextAlignmentLeft;
    label2.textColor=[UIColor colorWithRed:121.0/255.0 green:115.0/255.0 blue:115.0/255.0 alpha:1.0];
    label2.font = [UIFont fontWithName:@"Helvetica-Bold" size:22];
    
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"Name"] isEqual:@""]) {
        label2.text = @"User";
    }
    else
    {
        label2.text =[[NSUserDefaults standardUserDefaults] objectForKey:@"Name"];
    }
    
    
    
    [headerView addSubview:label1];
    [headerView addSubview:label2];
    
    return headerView;
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    // Check Row and Select Next View controller
    if (indexPath.row == 6)
    {
        if (!([FBSession activeSession].state != FBSessionStateOpen &&
              [FBSession activeSession].state != FBSessionStateOpenTokenExtended))
        {
            [[FBSession activeSession] closeAndClearTokenInformation];
        }
        
         
        UIStoryboard *sb=[UIStoryboard storyboardWithName:@"Main" bundle:nil];
        myDelegate.window.rootViewController = myDelegate.navigationController;
        LoginViewController *firstVC=[sb instantiateViewControllerWithIdentifier:@"LoginViewController"];
        [myDelegate.navigationController setViewControllers: [NSArray arrayWithObject: firstVC]
                                                   animated: YES];
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults removeObjectForKey:@"UserId"];
        [defaults removeObjectForKey:@"Name"];
        [defaults removeObjectForKey:@"PendingConfirmation"];
        [defaults synchronize];
        [myDelegate unregisterDeviceForNotification];
        
        
    }
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    // Set the title of navigation bar by using the menu items
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    UINavigationController *destViewController = (UINavigationController*)segue.destinationViewController;
    destViewController.title = [[menuItems objectAtIndex:indexPath.row] capitalizedString];
    
    // Set the photo if it navigates to the PhotoView
    //    if ([segue.identifier isEqualToString:@"showPhoto"]) {
    //        UINavigationController *navController = segue.destinationViewController;
    //        LeaveManagementViewController *photoController = [navController childViewControllers].firstObject;
    //        NSString *photoFilename = [NSString stringWithFormat:@"%@_photo", [menuItems objectAtIndex:indexPath.row]];
    //        //photoController.photoFilename = photoFilename;
    //    }
}


/*
 - (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
 UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
 
 // Configure the cell...
 
 return cell;
 }
 */

/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
 } else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }
 }
 */

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end

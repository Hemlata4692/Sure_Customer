//
//  SubCategoryViewController.m
//  Sure
//
//  Created by Hema on 27/03/15.
//  Copyright (c) 2015 Shivendra. All rights reserved.
//

#import "SubCategoryViewController.h"
#import "SearchDataModel.h"
#import "SearchViewController.h"
#import "ServiceProviderViewController.h"

@interface SubCategoryViewController ()
@property (weak, nonatomic) IBOutlet UITableView *subCategoryListing;
@property (weak, nonatomic) IBOutlet UILabel *noSubCategoryLbl;
@property(nonatomic,retain)NSMutableArray * getSubCategoryArray;
@end

@implementation SubCategoryViewController
@synthesize subCategoryListing,mainCategoryId,getSubCategoryArray,mainCategoryName,noSubCategoryLbl;

#pragma mark - View life cycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    noSubCategoryLbl.hidden=YES;
    getSubCategoryArray=[[NSMutableArray alloc]init];
    [getSubCategoryArray removeAllObjects];
    [myDelegate ShowIndicator];
    [self performSelector:@selector(getSubcategoryListFromWebservice) withObject:nil afterDelay:.1];
    //Remove swipe gesture for sidebar
    for (UIGestureRecognizer *recognizer in self.view.gestureRecognizers)
    {
        [self.view removeGestureRecognizer:recognizer];
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    self.title=mainCategoryName;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) dealloc
{
    getSubCategoryArray=nil;
    
}
#pragma mark - end

#pragma mark - Webservice Methods list
//Method to get sub category listing from server
-(void) getSubcategoryListFromWebservice
{
    [[WebService sharedManager] getSubCategoryList:mainCategoryId success:^(id subCategoryArray)
     {
         getSubCategoryArray=[subCategoryArray mutableCopy];
         if (getSubCategoryArray.count==0)
         {
             noSubCategoryLbl.hidden=NO;
         }
         [subCategoryListing reloadData];
         
     } failure:^(NSError *error) {
         
     }] ;
}

#pragma mark - end

#pragma mark - Table view delegate methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return getSubCategoryArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *simpleTableIdentifier = @"subCategoryCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
    }
    UILabel *subCategoryLabel= (UILabel *)[cell viewWithTag:1];
    SearchDataModel * data = [getSubCategoryArray objectAtIndex:indexPath.row];
    subCategoryLabel.text=data.categoryName;
    return cell;
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    SearchDataModel * data = [getSubCategoryArray objectAtIndex:indexPath.row];
    UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    ServiceProviderViewController *serviceProviderListing =[storyboard instantiateViewControllerWithIdentifier:@"ServiceProviderViewController"];
    serviceProviderListing.subCatServiceID=data.categoryId;
    serviceProviderListing.searchKey=@"";
    serviceProviderListing.customLocation=@"";
    serviceProviderListing.longitude=myDelegate.longitude;
    serviceProviderListing.latitude=myDelegate.latitude;
    [self.navigationController pushViewController:serviceProviderListing animated:YES];
}

#pragma mark - end

@end

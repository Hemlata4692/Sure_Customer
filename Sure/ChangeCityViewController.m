//
//  ChangeCityViewController.m
//  Sure
//
//  Created by Hema on 24/04/15.
//  Copyright (c) 2015 Shivendra. All rights reserved.
//

#import "ChangeCityViewController.h"
#import "MyButton.h"
#import "CityCell.h"
@interface ChangeCityViewController ()<RadioCellDelegate>
{
    NSArray * cityArray;
    __weak IBOutlet UITableView *cityTableView;
}
@end

@implementation ChangeCityViewController
#pragma mark - View life cycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title=@"Change City";
    [myDelegate ShowIndicator];
    [self performSelector:@selector(getCitiesFromServer) withObject:nil afterDelay:.1];
    
    //Remove swipe gesture for sidebar
    for (UIGestureRecognizer *recognizer in self.view.gestureRecognizers)
    {
        [self.view removeGestureRecognizer:recognizer];
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) dealloc
{
    cityArray=nil;
}
#pragma mark - end

#pragma mark - City Webservice method
-(void)getCitiesFromServer
{
    [[WebService sharedManager]getCitiesFromServer:^(id responseObject) {
        
        cityArray = [responseObject objectForKey:@"CityList"];
        if ([[NSUserDefaults standardUserDefaults]objectForKey:@"City"]==nil||[[NSUserDefaults standardUserDefaults]objectForKey:@"City"]==NULL)
        {
            NSDictionary * tempDict = [cityArray objectAtIndex:1];
            [[NSUserDefaults standardUserDefaults]setObject:tempDict forKey:@"City"];
        }
        [cityTableView reloadData];
        
    } failure:^(NSError *error) {
        
    }] ;
    
}
#pragma mark - end

#pragma mark - Table view methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return cityArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *simpleTableIdentifier = @"CityCell";
    
    CityCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    if (cell == nil)
    {
        cell = [[CityCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
    }
    
    [cell.myradio addTarget:self action:@selector(radioTouched:) forControlEvents:UIControlEventTouchUpInside];
    cell.myradio.tag=indexPath.row;
    NSDictionary * cityDict = [cityArray objectAtIndex:indexPath.row];
    NSDictionary * selectedCityDict = [[NSUserDefaults standardUserDefaults]objectForKey:@"City"];
    if ([[selectedCityDict objectForKey:@"Id"]intValue]==[[cityDict objectForKey:@"Id"]intValue])
    {
        NSDictionary * cityDict = [cityArray objectAtIndex:indexPath.row];
        [cell radioButtonTouched:cityDict];
    }
    cell.cityLabel.text = [cityDict objectForKey:@"Name"];
    cell.delegate = self;
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    CityCell * cell = (CityCell *)[tableView cellForRowAtIndexPath:indexPath];
    NSDictionary * cityDict = [cityArray objectAtIndex:indexPath.row];
    [cell radioButtonTouched:cityDict];
}
#pragma mark - end

#pragma mark - Radiobutton action
- (IBAction)radioTouched:(id)sender
{
    NSIndexPath *index=[NSIndexPath indexPathForRow:[sender tag] inSection:0];
    CityCell * cell = (CityCell *)[cityTableView cellForRowAtIndexPath:index];
    NSDictionary * cityDict = [cityArray objectAtIndex:index.row];
    [cell radioButtonTouched:cityDict];
}
//Method to change city using radio button
-(void) myRadioCellDelegateDidCheckRadioButton:(CityCell*)checkedCell
{
    NSIndexPath *checkPath = [cityTableView indexPathForCell:checkedCell];
    
    for (int section = 0; section < [cityTableView numberOfSections]; section++) {
        if(section == checkPath.section)
        {
            for (int row = 0; row < [cityTableView numberOfRowsInSection:section]; row++) {
                NSIndexPath* cellPath = [NSIndexPath indexPathForRow:row inSection:section];
                CityCell* cell = (CityCell *)[cityTableView cellForRowAtIndexPath:cellPath];
                
                if(checkPath.row != cellPath.row) {
                    [cell unCheckRadio];
                }
            }
        }
    }
}
#pragma mark - end



@end

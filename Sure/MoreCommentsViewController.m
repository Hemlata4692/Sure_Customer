//
//  MoreCommentsViewController.m
//  Sure_sp
//
//  Created by Ranosys on 20/04/15.
//  Copyright (c) 2015 Shivendra. All rights reserved.
//

#import "MoreCommentsViewController.h"
#import "CommentsTableCell.h"
#import "BusinessProfileDataModel.h"


@interface MoreCommentsViewController ()
{
    BusinessProfileDataModel * businessData;
    NSMutableArray *commentsArray;
    UIView * footerView;
    int totalComments;
}
@property (weak, nonatomic) IBOutlet UITableView *commentsTable;
@property(nonatomic, strong) NSString *Offset;
@end

@implementation MoreCommentsViewController
@synthesize serviceProviderId,Offset,commentsTable;

#pragma mark - View life cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title=@"Comments";
    // Do any additional setup after loading the view.
    [self initFooterView];
    Offset=@"0";
    [myDelegate ShowIndicator];
    [self performSelector:@selector(getCommentsListFromServer) withObject:nil afterDelay:.1];
    commentsArray=[[NSMutableArray alloc]init];
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
    commentsArray=nil;
    
}
#pragma mark - end

#pragma mark - Webservice Methods
//Methods to get comments list
-(void)getCommentsListFromServer
{
    [[WebService sharedManager] getCommentData:serviceProviderId offset:[NSString stringWithFormat:@"%@",Offset] success:^(id responseObject)
     {
         [commentsArray addObjectsFromArray:[responseObject objectForKey:@"CommentsResponse"]];
         totalComments=[[responseObject objectForKey:@"CommentsCount"] intValue];
         Offset=[NSString stringWithFormat:@"%lu",(unsigned long)commentsArray.count];
         [commentsTable reloadData];
         
     } failure:^(NSError *error)
     {
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
    return commentsArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *simpleTableIdentifier = @"commentsCell";
    CommentsTableCell *cell1 = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    if (cell1 == nil)
    {
        cell1 = [[CommentsTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
    }
    NSDictionary * tmpDict = [commentsArray objectAtIndex:indexPath.row];
    CGSize size = CGSizeMake(172,1500);
    CGRect textRect=[[tmpDict objectForKey:@"Comment"]
                     boundingRectWithSize:size
                     options:NSStringDrawingUsesLineFragmentOrigin
                     attributes:@{NSFontAttributeName:[UIFont fontWithName:@"Helvetica Neue" size:14]}
                     context:nil];
    cell1.commentTextView.numberOfLines = 0;
    cell1.commentTextView.frame =CGRectMake(16, 9, self.view.frame.size.width-32, textRect.size.height+5);
    [cell1 displayCommentData:tmpDict];
    return cell1;
}
//Method to get dynamic height according to comments
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGSize size = CGSizeMake(172,1500);
    NSDictionary * tmpDict = [commentsArray objectAtIndex:indexPath.row];
    CGRect textRect=[[tmpDict objectForKey:@"Comment"]
                     boundingRectWithSize:size
                     options:NSStringDrawingUsesLineFragmentOrigin
                     attributes:@{NSFontAttributeName:[UIFont fontWithName:@"Helvetica Neue" size:14]}
                     context:nil];
    return textRect.size.height+55.0;
}
#pragma mark - end

#pragma mark - pagignation for table view
-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *) cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (commentsArray.count ==totalComments)
    {
        [(UIActivityIndicatorView *)[footerView viewWithTag:10] stopAnimating];
        [(UILabel *)[footerView viewWithTag:11] setHidden:true];
    }
    else if(indexPath.row==[commentsArray count]-1) //self.array is the array of items you are displaying
    {
        if(commentsArray.count <= totalComments)
        {
            tableView.tableFooterView = footerView;
            [(UIActivityIndicatorView *)[footerView viewWithTag:10] startAnimating];
            [self getCommentsListFromServer];
        }
        else
        {
            commentsTable.tableFooterView = nil; //You can add an activity indicator in tableview's footer in viewDidLoad to show a loading status to user.
        }
    }
}

-(void)initFooterView
{
    footerView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.frame.size.width, 40.0)];
    UIActivityIndicatorView * actInd = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    UILabel *footerLabel=[[UILabel alloc]init];
    footerLabel.tag=11;
    footerLabel.frame=CGRectMake(self.view.frame.size.width/2, 5.0, 80.0, 20.0);
    footerLabel.text=@"Loading...";
    [footerLabel.font fontWithSize:12.0];
    footerLabel.textColor=[UIColor grayColor];
    actInd.tag = 10;
    actInd.frame = CGRectMake(10.0, 5.0, 20.0, 20.0);
    actInd.hidesWhenStopped = YES;
    [footerView addSubview:actInd];
    [footerView addSubview:footerLabel];
    footerLabel=nil;
    actInd = nil;
}
#pragma mark - end

@end

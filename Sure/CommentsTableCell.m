//
//  CommentsTableCell.m
//  Sure
//
//  Created by Ranosys on 17/04/15.
//  Copyright (c) 2015 Shivendra. All rights reserved.
//

#import "CommentsTableCell.h"

@implementation CommentsTableCell
@synthesize commentTextView,dateLabel,separatorLabel,dateStarView,staticStarView;

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}
#pragma mark - Setframes of objects

-(void)layoutView : (CGRect )rect
{
    self.commentTextView.translatesAutoresizingMaskIntoConstraints=YES;
    self.commentLabel.translatesAutoresizingMaskIntoConstraints=YES;
    self.separatorLabel.translatesAutoresizingMaskIntoConstraints=YES;
    self.dateStarView.translatesAutoresizingMaskIntoConstraints=YES;
      self.staticStarView.translatesAutoresizingMaskIntoConstraints=YES;
    self.commentTextView.frame =CGRectMake(16, self.frame.origin.y+10, rect.size.width-32, self.commentTextView.frame.size.height);
    self.commentLabel.frame =CGRectMake(self.commentLabel.frame.origin.x, self.commentLabel.frame.origin.y, rect.size.width-32, self.commentLabel.frame.size.height);
    self.separatorLabel.frame =CGRectMake(0, self.separatorLabel.frame.origin.y, rect.size.width, self.separatorLabel.frame.size.height);
    self.dateStarView.frame =CGRectMake(0, self.dateStarView.frame.origin.y, rect.size.width, self.dateStarView.frame.size.height);
    staticStarView.frame =CGRectMake(rect.size.width-95, self.staticStarView.frame.origin.y, 95, self.staticStarView.frame.size.height);
}
#pragma mark - end

#pragma mark - Display data from webservice

-(void)displayCommentData :(NSDictionary *)commentsDict
{
    self.commentLabel.text=[commentsDict objectForKey:@"Comment"];
    self.commentTextView.text = [commentsDict objectForKey:@"Comment"];
    self.dateLabel.text = [myDelegate formatDateToDisplay:[commentsDict objectForKey:@"CommentedOn"]];
    staticStarView.backgroundColor = [UIColor clearColor];
    staticStarView.canEdit=NO;
    staticStarView.leftMargin=2.5;
    staticStarView.midMargin=.5;
    staticStarView.maxRating = 5;
    staticStarView.rating = [[commentsDict objectForKey:@"Rating"] floatValue];
    staticStarView.minAllowedRating = .5;
    staticStarView.maxAllowedRating = 5;
}
#pragma mark - end
@end

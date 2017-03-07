//
//  CommentsTableCell.h
//  Sure
//
//  Created by Ranosys on 17/04/15.
//  Copyright (c) 2015 Shivendra. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ASStarRatingView.h"

@interface CommentsTableCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *commentLabel;
@property (weak, nonatomic) IBOutlet UILabel *commentTextView;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *separatorLabel;
@property (weak, nonatomic) IBOutlet UIView *dateStarView;
@property (weak, nonatomic) IBOutlet ASStarRatingView *staticStarView;
-(void)layoutView : (CGRect )rect;
-(void)displayCommentData :(NSDictionary *)commentsDict;
@end
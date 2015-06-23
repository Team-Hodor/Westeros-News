//
//  CommentTableViewCell.h
//  Westeros-News-App
//
//  Created by Engin Dzhemil on 6/22/15.
//  Copyright (c) 2015 Team-Hodor. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Comment.h"

@interface CommentTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *authorLabel;
@property (weak, nonatomic) IBOutlet UITextView *contentTextView;
@end

//
//  CommentTableViewCell.m
//  Westeros-News-App
//
//  Created by Engin Dzhemil on 6/22/15.
//  Copyright (c) 2015 Team-Hodor. All rights reserved.
//

#import "CommentTableViewCell.h"

@interface CommentTableViewCell()

@end

@implementation CommentTableViewCell

-(void)prepareForReuse{
    self.dateLabel.text = @"";
    self.authorLabel.text = @"";
    self.contentTextView.text = @"";
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self.contentView layoutIfNeeded];
    self.dateLabel.preferredMaxLayoutWidth = CGRectGetWidth(self.dateLabel.frame);
}

@end

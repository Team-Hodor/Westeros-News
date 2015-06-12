//
//  NewsTableViewCell.m
//  Westeros-News-App
//
//  Created by Engin Dzhemil on 6/12/15.
//  Copyright (c) 2015 Team-Hodor. All rights reserved.
//

#import "NewsTableViewCell.h"

@interface NewsTableViewCell()

@property (weak, nonatomic) IBOutlet UIImageView *articleImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *subtitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;

@end

@implementation NewsTableViewCell

- (void)setArticle:(Article *)article{
    _article = article;
    self.titleLabel.text = article.title;
    self.subtitleLabel.text = article.subtitle;
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"dd-MM-yyyy HH:mm"];
    
    self.dateLabel.text = [formatter stringFromDate:article.createdAt];

}

@end

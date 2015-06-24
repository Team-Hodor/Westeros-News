//
//  NewsTableViewCell.m
//  Westeros-News-App
//
//  Created by Engin Dzhemil on 6/12/15.
//  Copyright (c) 2015 Team-Hodor. All rights reserved.
//

#import "NewsTableViewCell.h"
#import "WebServiceManager.h"

@interface NewsTableViewCell()

@property (weak, nonatomic) IBOutlet UIImageView *articleImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *subtitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;

@end

@implementation NewsTableViewCell

-(void)prepareForReuse {
    [super prepareForReuse];
    
    self.articleImageView.image = nil;
    self.article = nil;
}

- (void)setArticle:(Article *)article{
    _article = article;
    self.titleLabel.text = article.title;
    self.subtitleLabel.text = article.subtitle;
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"dd.MM.yyyy HH:mm"];
    
    self.dateLabel.text = [formatter stringFromDate:article.createdAt];

    [self setArticleImage];
}

- (void)setArticleImage {
    self.articleImageView.layer.cornerRadius = self.articleImageView.frame.size.height / 2.0;
    self.articleImageView.layer.masksToBounds = YES;
    
    UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    [indicator startAnimating];
    [indicator setCenter:self.articleImageView.center];
    [self.contentView addSubview:indicator];
    
    [WebServiceManager downloadImageWithImageURL:self.article.previewImageURL completion:^(UIImage *image, NSHTTPURLResponse *response) {
        
        [indicator removeFromSuperview];
        self.articleImageView.image = image;
    }];
}

@end

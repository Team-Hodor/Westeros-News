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

@property (nonatomic, strong) Article *article;

@end

@implementation NewsTableViewCell

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
    
    NSURL *imageURL = [NSURL URLWithString:self.article.imageURL];
    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfiguration];
    
    NSURLSessionDataTask *imageTask = [session dataTaskWithURL:imageURL
                                             completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                                 dispatch_async(dispatch_get_main_queue(), ^() {
                                                     [indicator removeFromSuperview];
                                                     UIImage *image = [UIImage imageWithData:data];
                                                     self.articleImageView.image = image;
                                                 });
                                             }];
    
    dispatch_queue_t queue = dispatch_queue_create("taskQueue", NULL);
    dispatch_async(queue, ^() {
        [imageTask resume];
    });

}

@end

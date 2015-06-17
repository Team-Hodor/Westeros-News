//
//  NewsDetailViewController.m
//  Westeros-News-App
//
//  Created by Engin Dzhemil on 6/12/15.
//  Copyright (c) 2015 Team-Hodor. All rights reserved.
//

#import "NewsDetailViewController.h"
#import "DataRepository.h"
#import "Article.h"

@interface NewsDetailViewController ()
@property (strong, nonatomic) Article *article;

@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *subtitleLabel;

@property (weak, nonatomic) IBOutlet UIImageView *articleImageView;
@property (weak, nonatomic) IBOutlet UILabel *contentLabel;

@end

@implementation NewsDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self updateValues];
}

- (void) updateValues{
    self.article = [[DataRepository sharedInstance] selectedArticle];
    self.titleLabel.text = self.article.title;
    self.subtitleLabel.text = self.article.subtitle;
    self.contentLabel.text = self.article.content;
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"dd.MM.yyyy HH:mm"];
    
    self.dateLabel.text = [formatter stringFromDate:self.article.createdAt];
    
    [self setArticleImage];
}

- (void)setArticleImage {

    NSURL *imageURL = [NSURL URLWithString:self.article.thumbnailURL];
    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfiguration];
    
    NSURLSessionDataTask *imageTask = [session dataTaskWithURL:imageURL
                                             completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                                 dispatch_async(dispatch_get_main_queue(), ^() {
                                                     UIImage *image = [UIImage imageWithData:data];
                                                     self.articleImageView.image = image;
                                                 });
                                             }];
    
    dispatch_queue_t queue = dispatch_queue_create("taskQueue", NULL);
    dispatch_async(queue, ^() {
        [imageTask resume];
    });
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

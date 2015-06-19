//
//  NewsDetailViewController.m
//  Westeros-News-App
//
//  Created by Engin Dzhemil on 6/12/15.
//  Copyright (c) 2015 Team-Hodor. All rights reserved.
//

#import "NewsDetailViewController.h"
#import "DataRepository.h"
#import "WebServiceManager.h"
#import "DataRepository.h"
#import "Article.h"
#import "UIAlertController+ShowAlert.h"

@interface NewsDetailViewController ()
@property (strong, nonatomic) Article *article;

@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *subtitleLabel;

@property (weak, nonatomic) IBOutlet UIImageView *articleImageView;
@property (weak, nonatomic) IBOutlet UILabel *contentLabel;

@end

@implementation NewsDetailViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.navigationController.toolbarHidden = YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self updateValues];
    
    [self performInitialConfiguration];
    
    
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

    [WebServiceManager downloadImageWithImageURL:self.article.imageURL completion:^(NSData *data, NSHTTPURLResponse *response, NSError *error) {
        
        UIImage *image = [UIImage imageWithData:data];
        self.articleImageView.image = image;
    }];
    
}

- (void)performInitialConfiguration {
    
    
    UIBarButtonItem *favButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"fav.png"] landscapeImagePhone:[UIImage imageNamed:@"fav.png"] style:UIBarButtonItemStylePlain target:self action:@selector(addToFavouritesButtonTapped:)];
    
    [self setFavouriteButtonState:favButton];
    
    self.navigationItem.rightBarButtonItem = favButton;
    
    
}

- (void) addToFavouritesButtonTapped: (UIBarButtonItem*)btn{
    
    
    User *user = [[DataRepository sharedInstance] loggedUser];
    if([user.favouriteNews containsObject:self.article.identifier]){
        
        UIAlertController * alert=   [UIAlertController
                                      alertControllerWithTitle:@"Confirmation"
                                      message:@"Are you sure you want to remove article from favourites?"
                                      preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* ok = [UIAlertAction
                             actionWithTitle:@"OK"
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action)
                             {
                                 [WebServiceManager removeArticleFromFavorites:self.article sessionToken:[DataRepository sharedInstance].loggedUser.sessionToken completion:^(NSDictionary *resultData, NSHTTPURLResponse *response, NSError *error) {
                                     if ( [resultData objectForKey:@"error"] ) {
                                         
                                         [UIAlertController showAlertWithTitle:@"Error"
                                                                    andMessage:@"Couldn't remove article from favourites."
                                                              inViewController:self
                                                                   withHandler:nil];
                                         btn.tintColor = [UIColor redColor];
                                     }else{
                                         [user.favouriteNews removeObject:self.article.identifier];
                                         btn.tintColor = [UIColor whiteColor];
                                     }
                                 }];
                                 
                                 [alert dismissViewControllerAnimated:YES completion:nil];
                                 
                             }];
        UIAlertAction* cancel = [UIAlertAction
                                 actionWithTitle:@"Cancel"
                                 style:UIAlertActionStyleDefault
                                 handler:^(UIAlertAction * action)
                                 {
                                     [alert dismissViewControllerAnimated:YES completion:nil];
                                     
                                 }];
        
        [alert addAction:ok];
        [alert addAction:cancel];
        
        [self presentViewController:alert animated:YES completion:nil];
        
    
    }else{
        
        [WebServiceManager addArticleToFavorites:self.article sessionToken:[DataRepository sharedInstance].loggedUser.sessionToken completion:^(NSDictionary *resultData, NSHTTPURLResponse *response, NSError *error) {
            if ( [resultData objectForKey:@"error"] ) {
                
                [UIAlertController showAlertWithTitle:@"Error"
                                           andMessage:@"Couldn't add article to favourites."
                                     inViewController:self
                                          withHandler:nil];
                btn.tintColor = [UIColor whiteColor];
            }else{
                [user.favouriteNews addObject:self.article.identifier];
                btn.tintColor = [UIColor redColor];
            }
        }
         ];
        
    }

}

- (void) setFavouriteButtonState:(UIBarButtonItem *)btn{
    
    User *user = [[DataRepository sharedInstance] loggedUser];
    if([user.favouriteNews containsObject:self.article.identifier]){
        btn.tintColor = [UIColor redColor];
    }
    else{
        btn.tintColor = [UIColor whiteColor];
    }
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

//
//  ArticleCommentViewController.m
//  Westeros-News-App
//
//  Created by Engin Dzhemil on 6/21/15.
//  Copyright (c) 2015 Team-Hodor. All rights reserved.
//

#import "ArticleCommentViewController.h"
#import "WebServiceManager.h"
#import "DataRepository.h"

@interface ArticleCommentViewController ()
@property (weak, nonatomic) IBOutlet UITextField *commentTextField;
@property (weak, nonatomic) IBOutlet UIScrollView *mainScrollView;

@end

@implementation ArticleCommentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [WebServiceManager getCommentsForArticleWithId:[DataRepository sharedInstance].selectedArticle.identifier sessionToken:[DataRepository sharedInstance].loggedUser.sessionToken completion:^(NSDictionary *dataDictionary, NSHTTPURLResponse *response) {
 
    }];
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

//
//  InitialViewController.m
//  Westeros-News-App
//
//  Created by P. Mihaylov on 6/21/15.
//  Copyright (c) 2015 Team-Hodor. All rights reserved.
//

#import "InitialViewController.h"
#import "DataRepository.h"
#import "WebServiceManager.h"

@interface InitialViewController ()


#define WELCOME_VIEW_CONTROLLER_ID @"welcomeViewController"
#define NEWS_VIEW_CONTROLLER_ID @"newsNavigationController"
@end

@implementation InitialViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    NSString *sessionToken = [[NSUserDefaults standardUserDefaults] valueForKey:@"sessionToken"];
    NSString *username = [[NSUserDefaults standardUserDefaults] valueForKey:@"username"];
    NSString *uniqueID = [[NSUserDefaults standardUserDefaults] valueForKey:@"uniqueID"];
    NSString *name = [[NSUserDefaults standardUserDefaults] valueForKey:@"name"];
    NSMutableArray *favouriteNews = [[NSUserDefaults standardUserDefaults] valueForKey:@"favouriteNews"];
    BOOL isAdmin =[[NSUserDefaults standardUserDefaults] boolForKey:@"isAdmin"];
    
    [WebServiceManager checkUserSessionWithID:sessionToken
                                   completion:^(NSDictionary *resultData, NSHTTPURLResponse *response) {
                                       UIViewController *viewController;
                                       UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main"
                                                                                            bundle:[NSBundle mainBundle]];
                                       
                                       if ([resultData valueForKey:@"error"]) {
                                           viewController = [storyboard instantiateViewControllerWithIdentifier:WELCOME_VIEW_CONTROLLER_ID];
                                       } else {
                                           User *loggedUser = [[User alloc] initWithUsername:username
                                                                                        name:name
                                                                                andSessionId:sessionToken
                                                                                 andUniqueId:uniqueID];
                                           
                                           loggedUser.favouriteNews = favouriteNews;
                                           loggedUser.isAdmin = isAdmin;
                                           
                                           [DataRepository sharedInstance].loggedUser = loggedUser;
                                           
                                           viewController = [storyboard instantiateViewControllerWithIdentifier:NEWS_VIEW_CONTROLLER_ID];
                                       }
                                       
                                       [self presentViewController:viewController animated:YES completion:nil];
    }];
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

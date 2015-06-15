//
//  DataRepository.h
//  Westeros-News-App
//
//  Created by P. Mihaylov on 6/6/15.
//  Copyright (c) 2015 Team-Hodor. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User.h"
#import "Article.h"
#import <UIKit/UIKit.h>

@interface DataRepository : NSObject

@property (nonatomic, strong) User *loggedUser;
@property (nonatomic, strong) Article *selectedArticle;

+ (DataRepository *)sharedInstance;

- (void)logoutLoggedUserInViewController:(UIViewController *)viewController;

#define BASE_URL @"https://api.parse.com/1"

// http://78.90.132.242:2403/news?{"id":{"$in":["be51ab58a31d4831"]}}
@end

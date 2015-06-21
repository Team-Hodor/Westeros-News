//
//  ServiceRequester.h
//  Westeros-News-App
//
//  Created by P. Mihaylov on 6/7/15.
//  Copyright (c) 2015 Team-Hodor. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User.h"
#import "Article.h"
#import <UIKit/UIKit.h>

@interface WebServiceManager : NSObject

+ (void)postNewArticleWithTitle:(NSString *)title
                       subtitle:(NSString *)subtitle
                     categoryID:(NSString *)categoryID
                       authorID:(NSString *)authorID
                   previewImage:(UIImage *)previewImage
                      mainImage:(UIImage *)mainImage
                        content:(NSString *)content
                   sessionToken:(NSString *)sessionToken
                     completion:(void (^)(NSDictionary *dataDictionary, NSHTTPURLResponse *response))handlerBlock;

+ (void)editArticleWithObjectId:(NSString *)objectId
                          title:(NSString *)title
                       subtitle:(NSString *)subtitle
                     categoryID:(NSString *)categoryID
                        content:(NSString *)content
                   previewImage:(UIImage *)previewImage
                      mainImage:(UIImage *)mainImage
                   sessionToken:(NSString *)sessionToken
                     completion:(void (^)(NSDictionary *dataDictionary, NSHTTPURLResponse *response))handlerBlock;

+ (void)deleteArticleWithObjectId:(NSString *)objectId completion:(void (^)(NSDictionary *dataDictionary, NSHTTPURLResponse *response))handlerBlock;

+ (void)loadAvailableCategoriesWithCompletion:(void (^)(NSDictionary *dataDictionary, NSHTTPURLResponse *response))handlerBlock;

+ (void)loadArticleWithObjectId:(NSString *)objectId completion:(void (^)(NSDictionary *dataDictionary, NSHTTPURLResponse *response))handlerBlock;

+ (void)loadFavouriteNewsForUser:(User *)user
                      completion:(void (^)(NSDictionary *dataDictionary, NSHTTPURLResponse *response))handlerBlock;

+ (void)loadNewsWithLimit:(NSInteger)limit
                     skip:(NSInteger)skip
             sessionToken:(NSString *)sessionToken
               completion:(void (^)(NSDictionary *dataDictionary, NSHTTPURLResponse *response))handlerBlock;

+ (void)loginUserWithUsername:(NSString *)username
                  andPassword:(NSString *)password
                   completion:(void (^)(NSDictionary *dataDictionary, NSHTTPURLResponse *response))handlerBlock;

+ (void)registerUserWithUsername:(NSString *)username
                     andPassword:(NSString *)password
                         andName:(NSString *)name
                      completion:(void (^)(NSDictionary *dataDictionary, NSHTTPURLResponse *response))handlerBlock;

+ (void)logoutUserWithSessionId:(NSString *)sessionId
                     completion:(void (^)(NSDictionary *dataDictionary, NSHTTPURLResponse *response))handlerBlock;
+ (void)editUserName:(NSString *)name
                 sessionToken:(NSString *)sessionToken
                   completion:(void (^)(NSDictionary *dataDictionary, NSHTTPURLResponse *response))handlerBlock;
+ (void)changeUserPassword:(NSString *)password
        sessionToken:(NSString *)sessionToken
          completion:(void (^)(NSDictionary *dataDictionary, NSHTTPURLResponse *response))handlerBlock;

+ (void)addArticleToFavorites:(Article *)article
                 sessionToken:(NSString *)sessionToken
                   completion:(void (^)(NSDictionary *dataDictionary, NSHTTPURLResponse *response))handlerBlock;
+ (void)removeArticleFromFavorites:(Article *)article
                 sessionToken:(NSString *)sessionToken
                   completion:(void (^)(NSDictionary *dataDictionary, NSHTTPURLResponse *response))handlerBlock;

+ (void)downloadImageWithImageURL:(NSString *)imageURL completion:(void (^)(NSData *, NSHTTPURLResponse *))handlerBlock;

@end

//
//  ServiceRequester.m
//  Westeros-News-App
//
//  Created by P. Mihaylov on 6/7/15.
//  Copyright (c) 2015 Team-Hodor. All rights reserved.
//

#import "WebServiceManager.h"
#import "DataRepository.h"

@interface WebServiceManager() <NSURLSessionDelegate>


#define PARSE_APPLICATION_ID @"asCqw49GNR2QRP7xw1vETNZpW9DoqDtibGWCbg4e"
#define PARSE_REST_ID @"T8eI5HefBUPlZRQQ6UoSTFqoKgd1raXl1iAhWXw4"

@end

@implementation WebServiceManager

+ (void)postNewArticleWithTitle:(NSString *)title
                       subtitle:(NSString *)subtitle
                     categoryID:(NSString *)categoryID
                       authorID:(NSString *)authorID
                   previewImage:(UIImage *)previewImage
                      mainImage:(UIImage *)mainImage
                        content:(NSString *)content
                   sessionToken:(NSString *)sessionToken
                     completion:(void (^)(NSDictionary *dataDictionary, NSHTTPURLResponse *response))handlerBlock {
    NSString *serviceURL = [BASE_URL stringByAppendingString:
                            [NSString stringWithFormat:@"/classes/News?where={\"title\":\"%@\"}", title]];
    
    
    NSURL *checkURL = [NSURL URLWithString:[serviceURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
    [WebServiceManager performRequestWithUrl:checkURL contentType:@"application/json" andMethod:@"GET" andHttpBody:nil sessionToken:nil andHandler:^(NSDictionary *resultData, NSHTTPURLResponse *response) {
        if ([[resultData valueForKey:@"results"] count] == 0) {
            __block NSString *previewImageName;
            __block NSString *mainImageName;
            
            [WebServiceManager uploadImage:previewImage
                                  withName:@"previewImage"
                                completion:^(NSString *imageName) {
                                    previewImageName = imageName;
                                    if (mainImageName) {
                                        [WebServiceManager performNewArticleRequestWithArticleTitle:title
                                                                                           subtitle:subtitle
                                                                                         categoryID:categoryID
                                                                                           authorID:authorID
                                                                                   previewImageName:previewImageName
                                                                                      mainImageName:mainImageName
                                                                                            content:content
                                                                                       sessionToken:sessionToken
                                                                                         completion:handlerBlock];
                                    }
            }];
            
            [WebServiceManager uploadImage:mainImage
                                  withName:@"mainImage"
                                completion:^(NSString *imageName) {
                                    mainImageName = imageName;
                                    if (previewImageName) {
                                        [WebServiceManager performNewArticleRequestWithArticleTitle:title
                                                                                           subtitle:subtitle
                                                                                         categoryID:categoryID
                                                                                           authorID:authorID
                                                                                   previewImageName:previewImageName
                                                                                      mainImageName:mainImageName
                                                                                            content:content
                                                                                       sessionToken:sessionToken
                                                                                         completion:handlerBlock];
                                    }
                                }];
        } else {
            handlerBlock(@{@"error":@"Article with such title already exists"}, nil);
        }
    }];
}

+ (void)editArticleWithObjectId:(NSString *)objectId
                          title:(NSString *)title
                       subtitle:(NSString *)subtitle
                     categoryID:(NSString *)categoryID
                        content:(NSString *)content
                   previewImage:(UIImage *)previewImage
                      mainImage:(UIImage *)mainImage
                      sessionToken:(NSString *)sessionToken
                     completion:(void (^)(NSDictionary *dataDictionary, NSHTTPURLResponse *response))handlerBlock {
    
    __block NSString *previewImageName;
    __block NSString *mainImageName;
    
    __block NSMutableDictionary *articleData = [[NSMutableDictionary alloc] init];
  
    articleData[@"title"] = title;
    articleData[@"subtitle"] = subtitle;
    articleData[@"category"] = @{@"__type":@"Pointer", @"className":@"Category", @"objectId":categoryID};
    
    articleData[@"content"] = content;
    
    if (previewImage) {
        [WebServiceManager uploadImage:previewImage
                              withName:@"previewImage"
                            completion:^(NSString *imageName) {
                                previewImageName = imageName;
                                articleData[@"previewImage"] = @{@"name":previewImageName, @"__type":@"File"};
                                if (mainImageName || [mainImageName isEqualToString:@"missing"]) {
                                    [WebServiceManager performEditArticleRequestWithObjectID:objectId
                                                                                sessionToken:sessionToken
                                                                                     options:articleData
                                                                                  completion:handlerBlock];
                                }
                            }];
    } else {
        previewImageName = @"missing";
    }
    
    if (mainImage) {
        [WebServiceManager uploadImage:mainImage
                              withName:@"mainImage"
                            completion:^(NSString *imageName) {
                                mainImageName = imageName;
                                articleData[@"mainImage"] = @{@"name":mainImageName, @"__type":@"File"};
                                if (previewImageName || [previewImageName isEqualToString:@"missing"]) {
                                    [WebServiceManager performEditArticleRequestWithObjectID:objectId
                                                                                sessionToken:sessionToken
                                                                                     options:articleData
                                                                                  completion:handlerBlock];
                                }
                            }];
    } else {
        mainImageName = @"missing";
    }
    
    if ([mainImageName isEqualToString:@"missing"] &&
            [previewImageName isEqualToString:@"missing"]) {
        [WebServiceManager performEditArticleRequestWithObjectID:objectId
                                                    sessionToken:sessionToken
                                                         options:articleData
                                                      completion:handlerBlock];
    }
}

+ (void)deleteArticleWithObjectId:(NSString *)objectId completion:(void (^)(NSDictionary *dataDictionary, NSHTTPURLResponse *response))handlerBlock {
    NSString *serviceURL = [BASE_URL stringByAppendingString:[NSString stringWithFormat:@"/classes/News/%@", objectId]];
    NSURL *url = [NSURL URLWithString:[serviceURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
    [WebServiceManager performRequestWithUrl:url
                                 contentType:@"application/json"
                                   andMethod:@"DELETE"
                                 andHttpBody:nil
                                sessionToken:nil
                                  andHandler:handlerBlock];
}

+ (void)loadAvailableCategoriesWithCompletion:(void (^)(NSDictionary *dataDictionary, NSHTTPURLResponse *response))handlerBlock {
    
    NSString *serviceURL = [BASE_URL stringByAppendingString:@"/classes/Category"];
    NSURL *url = [NSURL URLWithString:[serviceURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
    [WebServiceManager performRequestWithUrl:url
                                 contentType:@"application/json"
                                   andMethod:@"GET"
                                 andHttpBody:nil
                                sessionToken:nil
                                  andHandler:handlerBlock];
}

+ (void)loadArticleWithObjectId:(NSString *)objectId completion:(void (^)(NSDictionary *dataDictionary, NSHTTPURLResponse *response))handlerBlock {
    NSString *serviceURL = [BASE_URL stringByAppendingString:[NSString stringWithFormat:@"/classes/News/%@", objectId]];
    
    NSURL *url = [NSURL URLWithString:[serviceURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
    [WebServiceManager performRequestWithUrl:url
                                 contentType:@"application/json"
                                   andMethod:@"GET"
                                 andHttpBody:nil
                                sessionToken:nil
                                  andHandler:handlerBlock];
}

+ (void)loadFavouriteNewsForUser:(User *)user completion:(void (^)(NSDictionary *dataDictionary, NSHTTPURLResponse *response))handlerBlock {
    
    NSString *serviceURL = [BASE_URL stringByAppendingString:
                            [NSString stringWithFormat:@"/classes/News?where={\"objectId\":{\"$in\":[\"%@\"]}}&order=-createdAt",
                             [user.favouriteNews componentsJoinedByString:@"\",\""]]];

    NSURL *url = [NSURL URLWithString:[serviceURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
    [WebServiceManager performRequestWithUrl:url
                                 contentType:@"application/json"
                                   andMethod:@"GET"
                                 andHttpBody:nil
                                sessionToken:user.sessionToken
                                  andHandler:handlerBlock];
}

+ (void)loadNewsWithLimit:(NSInteger)limit skip:(NSInteger)skip sessionToken:(NSString *)sessionToken completion:(void (^)(NSDictionary *dataDictionary, NSHTTPURLResponse *response))handlerBlock {
    
    NSString *serviceURL = [BASE_URL stringByAppendingString:
                            [NSString stringWithFormat:@"/classes/News?limit=%ld&skip=%ld&order=-createdAt", (long)limit, (long)skip]];
    
    NSURL *url = [NSURL URLWithString:[serviceURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
    [WebServiceManager performRequestWithUrl:url
                                 contentType:@"application/json"
                                   andMethod:@"GET"
                                 andHttpBody:nil
                                sessionToken:sessionToken
                                  andHandler:handlerBlock];
}

+ (void)loginUserWithUsername:(NSString *)username andPassword:(NSString *)password completion:(void (^)(NSDictionary *dataDictionary, NSHTTPURLResponse *response))handlerBlock {
    
    NSString *serviceURL = [BASE_URL stringByAppendingString:
                            [NSString stringWithFormat:@"/login?username=%@&password=%@", username, password]];
    
    NSURL *url = [NSURL URLWithString:[serviceURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
    [WebServiceManager performRequestWithUrl:url
                                 contentType:@"application/json"
                                   andMethod:@"GET"
                                 andHttpBody:nil
                                sessionToken:nil
                                  andHandler:handlerBlock];
}

+ (void)registerUserWithUsername:(NSString *)username andPassword:(NSString *)password andName:(NSString *)name completion:(void (^)(NSDictionary *dataDictionary, NSHTTPURLResponse *response))handlerBlock {
    
    NSString *serviceURL = [BASE_URL stringByAppendingString:@"/users"];
    NSURL *url = [NSURL URLWithString:serviceURL];
    
    NSDictionary *userData = @{@"username":username, @"password":password, @"name":name};
    
    [WebServiceManager performRequestWithUrl:url
                                 contentType:@"application/json"
                                   andMethod:@"POST"
                                 andHttpBody:userData
                                sessionToken:nil
                                  andHandler:handlerBlock];
}

+ (void)logoutUserWithSessionId:(NSString *)sessionToken completion:(void (^)(NSDictionary *dataDictionary, NSHTTPURLResponse *response))handlerBlock {
    
    NSString *serviceURL = [BASE_URL stringByAppendingString:@"/logout"];
    NSURL *url = [NSURL URLWithString:serviceURL];
    
    [WebServiceManager performRequestWithUrl:url
                                 contentType:@"application/json"
                                   andMethod:@"POST"
                                 andHttpBody:nil
                                sessionToken:sessionToken
                                  andHandler:handlerBlock];
}

+ (void)getUserWithUserId:(NSString *)userId
               completion:(void (^)(NSDictionary *dataDictionary, NSHTTPURLResponse *response))handlerBlock{
    
    NSString *serviceURL = [BASE_URL stringByAppendingString:
                            [NSString stringWithFormat:@"/users/%@", userId]];
    
    NSURL *url = [NSURL URLWithString:[serviceURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
    [WebServiceManager performRequestWithUrl:url
                                 contentType:@"application/json"
                                   andMethod:@"GET"
                                 andHttpBody:nil
                                sessionToken:nil
                                  andHandler:handlerBlock];
}

+ (void)getCommentsForArticleWithId:(NSString *)articleId sessionToken:(NSString *)sessionToken
                         completion:(void (^)(NSDictionary *dataDictionary, NSHTTPURLResponse *response))handlerBlock{
    
    NSString *serviceURL = [BASE_URL stringByAppendingString:
                            [NSString stringWithFormat:@"/classes/Comments"]];
    
    NSDictionary *data = @{ @"articleID": articleId
                            };
    
    NSURL *url = [NSURL URLWithString:[serviceURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
    [WebServiceManager performRequestWithUrl:url
                                 contentType:@"application/json"
                                   andMethod:@"GET"
                                 andHttpBody:data
                                sessionToken:sessionToken
                                  andHandler:handlerBlock];
    
}


+ (void) editUserName:(NSString *)name sessionToken:(NSString *)sessionToken completion:(void (^)(NSDictionary *, NSHTTPURLResponse *))handlerBlock{
    User *user = [[DataRepository sharedInstance] loggedUser];
    NSString *appString = [NSString stringWithFormat:@"/users/%@",user.uniqueId];
    NSString *serviceURL = [BASE_URL stringByAppendingString:appString];
    NSURL *url = [NSURL URLWithString:serviceURL];
    
    NSDictionary *data = @{ @"name": name
                            };
    
    
    [WebServiceManager performRequestWithUrl:url
                                 contentType:@"application/json"
                                   andMethod:@"PUT"
                                 andHttpBody:data
                                sessionToken:sessionToken
                                  andHandler:handlerBlock];
}

+ (void) changeUserPassword:(NSString *)password sessionToken:(NSString *)sessionToken completion:(void (^)(NSDictionary *, NSHTTPURLResponse *))handlerBlock{
    User *user = [[DataRepository sharedInstance] loggedUser];
    NSString *appString = [NSString stringWithFormat:@"/users/%@",user.uniqueId];
    NSString *serviceURL = [BASE_URL stringByAppendingString:appString];
    NSURL *url = [NSURL URLWithString:serviceURL];
    
    NSDictionary *data = @{ @"password": password
                            };
    
    
    [WebServiceManager performRequestWithUrl:url
                                 contentType:@"application/json"
                                   andMethod:@"PUT"
                                 andHttpBody:data
                                sessionToken:sessionToken
                                  andHandler:handlerBlock];
}

+ (void)addArticleToFavorites:(Article *)article sessionToken:(NSString *)sessionToken completion:(void (^)(NSDictionary *, NSHTTPURLResponse *))handlerBlock{
    User *user = [[DataRepository sharedInstance] loggedUser];
    NSString *appString = [NSString stringWithFormat:@"/users/%@",user.uniqueId];
    NSString *serviceURL = [BASE_URL stringByAppendingString:appString];
    NSURL *url = [NSURL URLWithString:serviceURL];
    
    NSDictionary *data = @{ @"favourites": @{
                                    
                                    @"__op": @"AddUnique",
                                    @"objects":
                                        @[
                                            @{
                                                @"__type": @"Pointer",
                                                @"className": @"News",
                                                @"objectId": article.identifier
                                                }
                                            ]
                                    }
                            };


    [WebServiceManager performRequestWithUrl:url
                                 contentType:@"application/json"
                                   andMethod:@"PUT"
                                 andHttpBody:data
                                sessionToken:sessionToken
                                  andHandler:handlerBlock];
}

+ (void) removeArticleFromFavorites:(Article *)article sessionToken:(NSString *)sessionToken completion:(void (^)(NSDictionary *, NSHTTPURLResponse *))handlerBlock {
    User *user = [[DataRepository sharedInstance] loggedUser];
    NSString *appString = [NSString stringWithFormat:@"/users/%@",user.uniqueId];
    NSString *serviceURL = [BASE_URL stringByAppendingString:appString];
    NSURL *url = [NSURL URLWithString:serviceURL];
    
    NSDictionary *data = @{ @"favourites": @{
                                    
                                    @"__op": @"Remove",
                                    @"objects":
                                        @[
                                            @{
                                                @"__type": @"Pointer",
                                                @"className": @"News",
                                                @"objectId": article.identifier
                                                }
                                            ]
                                    }
                            };
    
    
    [WebServiceManager performRequestWithUrl:url
                                 contentType:@"application/json"
                                   andMethod:@"PUT"
                                 andHttpBody:data
                                sessionToken:sessionToken
                                  andHandler:handlerBlock];
}

+ (void)downloadImageWithImageURL:(NSString *)imageURL completion:(void (^)(NSData *, NSHTTPURLResponse *))handlerBlock {
    
    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfiguration];
    
    NSURLSessionDataTask *imageTask = [session dataTaskWithURL:[NSURL URLWithString:imageURL]
                                                 completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                                     NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
                                                     if (!error) {
                                                         dispatch_async(dispatch_get_main_queue(), ^() {
                                                             handlerBlock(data, httpResponse);
                                                         });
                                                     } else {
                                                         NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
                                                     }
                                                 }];
    
    [imageTask resume];

}

#pragma mark - Private methods

+ (void)uploadImage:(UIImage *)image
           withName:(NSString *)name
         completion:(void (^)(NSString *imageName))handlerBlock {
    
    NSData *binaryImageData = UIImageJPEGRepresentation(image, 1.0);
    NSURL *url = [NSURL URLWithString:[BASE_URL stringByAppendingString:
                                       [NSString stringWithFormat:@"/files/%@.jpg", name]]];
    
    [WebServiceManager performRequestWithUrl:url
                                 contentType:@"image/jpeg"
                                   andMethod:@"POST"
                                 andHttpBody:binaryImageData
                                sessionToken:nil
                                  andHandler:^(NSDictionary *resultData, NSHTTPURLResponse *response) {
                                      NSString *imageName = (NSString *)[resultData valueForKey:@"name"];
                                      handlerBlock(imageName);
                                  }];
}

+ (void)performEditArticleRequestWithObjectID:(NSString *)objectID
                                 sessionToken:(NSString *)sessionToken
                                      options:(NSMutableDictionary *)options
                                   completion:(void (^)(NSDictionary *dataDictionary, NSHTTPURLResponse *response))handlerBlock {
    
    NSURL *url = [NSURL URLWithString:[BASE_URL stringByAppendingString:[NSString stringWithFormat:@"/classes/News/%@", objectID]]];
    
    [self performRequestWithUrl:url
                    contentType:@"application/json"
                      andMethod:@"PUT"
                    andHttpBody:options
                   sessionToken:sessionToken
                     andHandler:handlerBlock];
}

+ (void)performNewArticleRequestWithArticleTitle:(NSString *)title
                                        subtitle:(NSString *)subtitle
                                      categoryID:(NSString *)categoryID
                                        authorID:(NSString *)authorID
                                    previewImageName:(NSString *)previewImageName
                                       mainImageName:(NSString *)mainImageName
                                         content:(NSString *)content
                                    sessionToken:(NSString *)sessionToken
                                      completion:(void (^)(NSDictionary *dataDictionary, NSHTTPURLResponse *response))handlerBlock {
    
    NSDictionary *articleData = @{@"title":title,
                                  @"subtitle":subtitle,
                                  @"previewImage":@{
                                          @"name":previewImageName,
                                          @"__type":@"File"
                                          },
                                  @"mainImage":@{
                                          @"name":mainImageName,
                                          @"__type":@"File"
                                          },
                                  @"category":@{
                                          @"__type":@"Pointer",
                                          @"className":@"Category",
                                          @"objectId":categoryID
                                          },
                                  @"author":@{
                                          @"__type":@"Pointer",
                                          @"className":@"_User",
                                          @"objectId":authorID
                                          },
                                  @"content":content};
    
    NSURL *url = [NSURL URLWithString:[BASE_URL stringByAppendingString:@"/classes/News"]];
    
    [self performRequestWithUrl:url
                    contentType:@"application/json"
                      andMethod:@"POST"
                    andHttpBody:articleData
                   sessionToken:sessionToken
                     andHandler:handlerBlock];
}

+ (void)performRequestWithUrl:(NSURL *)url
                  contentType:(NSString *)contentType
                    andMethod:(NSString *)method
                  andHttpBody:(NSObject *)httpBody
                 sessionToken:(NSString *)sessionToken
                   andHandler:(void (^)(NSDictionary *dataDictionary, NSHTTPURLResponse *response))handlerBlock {
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:nil];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:10.0];
    
    [request setHTTPMethod:method];

    if ([httpBody isKindOfClass:[NSDictionary class]]) {
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:httpBody
                                                           options:0
                                                             error:nil];
        
        [request setHTTPBody:jsonData];
    } else {
        [request setHTTPBody:(httpBody ? (NSData *)httpBody : [[NSData alloc] init])];
    }
    
    // Setting the parse headers
    [request addValue:PARSE_APPLICATION_ID forHTTPHeaderField:@"X-Parse-Application-Id"];
    [request addValue:PARSE_REST_ID forHTTPHeaderField:@"X-Parse-REST-API-Key"];
    [request addValue:contentType forHTTPHeaderField:@"Content-Type"];
    
    if (sessionToken) {
        [request addValue:sessionToken forHTTPHeaderField:@"X-Parse-Session-Token"];
    }
    
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request
                                                    completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                                        
                                                        NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
                                                        
                                                        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
                                                        if (!error) {
                                                            dispatch_async(dispatch_get_main_queue(), ^{
                                                                handlerBlock(dictionary, httpResponse);
                                                            });
                                                        } else {
                                                            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
                                                        }
                                                    }];
    
    [dataTask resume];
}

@end

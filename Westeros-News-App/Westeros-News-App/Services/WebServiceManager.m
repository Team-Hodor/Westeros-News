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

// TODO:
+ (void)loadFavouriteNewsForUser:(User *)user completion:(void (^)(NSDictionary *dataDictionary, NSURLResponse *response, NSError *error))handlerBlock {
    
    NSString *serviceURL = [BASE_URL stringByAppendingString:
                            [NSString stringWithFormat:@"/classes/News?where={\"objectId\":{\"$in\":[\"%@\"]}}",
                             [user.favouriteNews componentsJoinedByString:@"\",\""]]];

    NSURL *url = [NSURL URLWithString:[serviceURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
    [WebServiceManager performRequestWithUrl:url
                                   andMethod:@"GET"
                                 andHttpBody:nil
                                sessionToken:user.sessionToken
                                  andHandler:handlerBlock];
}

+ (void)loadNewsWithLimit:(NSInteger)limit skip:(NSInteger)skip sessionToken:(NSString *)sessionToken completion:(void (^)(NSDictionary *dataDictionary, NSURLResponse *response, NSError *error))handlerBlock {
    
    NSString *serviceURL = [BASE_URL stringByAppendingString:
                            [NSString stringWithFormat:@"/classes/News?limit=%ld&skip=%ld", (long)limit, (long)skip]];
    
    NSURL *url = [NSURL URLWithString:[serviceURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
    [WebServiceManager performRequestWithUrl:url
                                   andMethod:@"GET"
                                 andHttpBody:nil
                                sessionToken:sessionToken
                                  andHandler:handlerBlock];
}

+ (void)loginUserWithUsername:(NSString *)username andPassword:(NSString *)password completion:(void (^)(NSDictionary *dataDictionary, NSURLResponse *response, NSError *error))handlerBlock {
    
    NSString *serviceURL = [BASE_URL stringByAppendingString:
                            [NSString stringWithFormat:@"/login?username=%@&password=%@", username, password]];
    
    NSURL *url = [NSURL URLWithString:[serviceURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
    [WebServiceManager performRequestWithUrl:url
                                   andMethod:@"GET"
                                 andHttpBody:nil
                                sessionToken:nil
                                  andHandler:handlerBlock];
}

+ (void)registerUserWithUsername:(NSString *)username andPassword:(NSString *)password andName:(NSString *)name completion:(void (^)(NSDictionary *dataDictionary, NSURLResponse *response, NSError *error))handlerBlock {
    
    NSString *serviceURL = [BASE_URL stringByAppendingString:@"/users"];
    NSURL *url = [NSURL URLWithString:serviceURL];
    
    NSDictionary *userData = @{@"username":username, @"password":password, @"name":name};
    
    [WebServiceManager performRequestWithUrl:url
                                   andMethod:@"POST"
                                 andHttpBody:userData
                                sessionToken:nil
                                  andHandler:handlerBlock];
}

+ (void)logoutUserWithSessionId:(NSString *)sessionToken completion:(void (^)(NSDictionary *dataDictionary, NSURLResponse *response, NSError *error))handlerBlock {
    
    NSString *serviceURL = [BASE_URL stringByAppendingString:@"/logout"];
    NSURL *url = [NSURL URLWithString:serviceURL];
    
    [WebServiceManager performRequestWithUrl:url
                                   andMethod:@"POST"
                                 andHttpBody:nil
                                sessionToken:sessionToken
                                  andHandler:handlerBlock];
}

+ (void)performRequestWithUrl:(NSURL *)url
                    andMethod:(NSString *)method
                  andHttpBody:(NSDictionary *)httpBody
                 sessionToken:(NSString *)sessionToken
                   andHandler:(void (^)(NSDictionary *dataDictionary, NSURLResponse *response, NSError *error))handlerBlock {
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:nil];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:10.0];
    
    [request setHTTPMethod:method];

    if (httpBody) {
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:httpBody
                                                           options:0
                                                             error:nil];
        
        [request setHTTPBody:jsonData];
    }
    
    // Setting the parse headers
    [request addValue:PARSE_APPLICATION_ID forHTTPHeaderField:@"X-Parse-Application-Id"];
    [request addValue:PARSE_REST_ID forHTTPHeaderField:@"X-Parse-REST-API-Key"];
    
    if (sessionToken) {
        [request addValue:sessionToken forHTTPHeaderField:@"X-Parse-Session-Token"];
    }
    
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request
                                                    completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                                        
                                                        NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
                                                        
                                                        if (!error) {
                                                            dispatch_async(dispatch_get_main_queue(), ^{
                                                                handlerBlock(dictionary, response, error);
                                                            });
                                                        } else {
                                                            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
                                                        }
                                                    }];
    
    [dataTask resume];
}

@end

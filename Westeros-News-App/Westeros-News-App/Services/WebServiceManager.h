//
//  ServiceRequester.h
//  Westeros-News-App
//
//  Created by P. Mihaylov on 6/7/15.
//  Copyright (c) 2015 Team-Hodor. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User.h"

@interface WebServiceManager : NSObject

+ (void)loadFavouriteNewsForUser:(User *)user completion:(void (^)(NSDictionary *dataDictionary, NSURLResponse *response, NSError *error))handlerBlock;

+ (void)loadNewsWithLimit:(NSInteger)limit skip:(NSInteger)skip sessionToken:(NSString *)sessionToken completion:(void (^)(NSDictionary *dataDictionary, NSURLResponse *response, NSError *error))handlerBlock;

+ (void)loginUserWithUsername:(NSString *)username andPassword:(NSString *)password completion:(void (^)(NSDictionary *dataDictionary, NSURLResponse *response, NSError *error))handlerBlock;

+ (void)registerUserWithUsername:(NSString *)username andPassword:(NSString *)password andName:(NSString *)name completion:(void (^)(NSDictionary *dataDictionary, NSURLResponse *response, NSError *error))handlerBlock;

+ (void)logoutUserWithSessionId:(NSString *)sessionId completion:(void (^)(NSDictionary *dataDictionary, NSURLResponse *response, NSError *error))handlerBlock;

+ (void)performRequestWithUrl:(NSURL *)url
                    andMethod:(NSString *)method
                  andHttpBody:(NSDictionary *)httpBody
                 sessionToken:(NSString *)sessionToken
                   andHandler:(void (^)(NSDictionary *dataDictionary, NSURLResponse *response, NSError *error))handlerBlock;

@end

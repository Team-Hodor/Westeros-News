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

@end

@implementation WebServiceManager

static WebServiceManager *sharedInst = nil;

+ (WebServiceManager *)sharedInstance {
    @synchronized( self ) {
        if ( sharedInst == nil ) {
            /* sharedInst set up in init */
            [[self alloc] init];
        }
    }
    
    return sharedInst;
}

- (id)init {
    if ( sharedInst != nil ) {
        [NSException raise:NSInternalInconsistencyException
                    format:@"[%@ %@] cannot be called; use +[%@ %@] instead",
         NSStringFromClass([self class]),
         NSStringFromSelector(_cmd),
         NSStringFromClass([self class]),
         NSStringFromSelector(@selector(sharedInstance))];
    } else if ( self = [super init] ) {
        sharedInst = self;
    }
    
    return sharedInst;
}

// TODO:

- (void)loadNewsWithLimit:(NSInteger)limit skip:(NSInteger)skip completion:(void (^)(NSDictionary *dataDictionary, NSURLResponse *response, NSError *error))handlerBlock {
    
    NSString *serviceURL = [BASE_URL stringByAppendingString:
                            [NSString stringWithFormat:@"/news?{\"$limit\":%ld,\"$skip\":%ld,\"$sort\":{\"createdAt\":-1}}", limit, skip]];
    
    NSURL *url = [NSURL URLWithString:[serviceURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
    [[WebServiceManager sharedInstance] performRequestWithUrl:url
                                                    andMethod:@"GET"
                                                  andHttpBody:@""
                                                   andHandler:handlerBlock];
}

-(void)loginUserWithUsername:(NSString *)username andPassword:(NSString *)password completion:(void (^)(NSDictionary *dataDictionary, NSURLResponse *response, NSError *error))handlerBlock {
    
    NSString *serviceURL = [BASE_URL stringByAppendingString:@"/users/login"];
    NSURL *url = [NSURL URLWithString:serviceURL];
    
    NSString *userData = [NSString stringWithFormat:@"username=%@&password=%@",username, password];
    
    [self performRequestWithUrl:url
                      andMethod:@"POST"
                    andHttpBody:userData
                     andHandler:handlerBlock];
}

-(void)registerUserWithUsername:(NSString *)username andPassword:(NSString *)password andName:(NSString *)name completion:(void (^)(NSDictionary *dataDictionary, NSURLResponse *response, NSError *error))handlerBlock {
    
    NSString *serviceURL = [BASE_URL stringByAppendingString:@"/users"];
    NSURL *url = [NSURL URLWithString:serviceURL];
    
    NSString *userData = [NSString stringWithFormat:@"username=%@&password=%@&name=%@",username, password, name];
    
    [self performRequestWithUrl:url
                      andMethod:@"POST"
                    andHttpBody:userData
                     andHandler:handlerBlock];
}

-(void)performRequestWithUrl:(NSURL *)url andMethod:(NSString *)method andHttpBody:(NSString *)httpBody andHandler:(void (^)(NSDictionary *dataDictionary, NSURLResponse *response, NSError *error))handlerBlock {
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:nil];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:60.0];
    
    [request setHTTPMethod:method];

    [request setHTTPBody:[httpBody dataUsingEncoding:NSUTF8StringEncoding]];
    
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

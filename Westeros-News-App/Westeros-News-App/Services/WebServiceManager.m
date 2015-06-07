//
//  ServiceRequester.m
//  Westeros-News-App
//
//  Created by P. Mihaylov on 6/7/15.
//  Copyright (c) 2015 Team-Hodor. All rights reserved.
//

#import "WebServiceManager.h"

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

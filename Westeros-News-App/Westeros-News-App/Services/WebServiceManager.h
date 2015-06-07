//
//  ServiceRequester.h
//  Westeros-News-App
//
//  Created by P. Mihaylov on 6/7/15.
//  Copyright (c) 2015 Team-Hodor. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WebServiceManager : NSObject

-(void)performRequestWithUrl:(NSURL *)url andMethod:(NSString *)method andHttpBody:(NSString *)httpBody andHandler:(void (^)(NSDictionary *dataDictionary, NSURLResponse *response, NSError *error))handlerBlock;

+ (WebServiceManager *)sharedInstance;

@end

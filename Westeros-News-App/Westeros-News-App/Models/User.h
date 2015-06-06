//
//  User.h
//  Westeros-News-App
//
//  Created by P. Mihaylov on 6/1/15.
//  Copyright (c) 2015 Team-Hodor. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface User : NSObject

@property (nonatomic, strong, readonly) NSString *sessionId;
@property (nonatomic, strong, readonly) NSString *uniqueId;
@property (nonatomic, strong, readonly) NSString *username;

- (instancetype)initWithUsername:(NSString *)username andSessionId:(NSString *)sessionId andUniqueId:(NSString *)uniqueId;

@end

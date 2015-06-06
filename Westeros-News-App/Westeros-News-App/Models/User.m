//
//  User.m
//  Westeros-News-App
//
//  Created by P. Mihaylov on 6/1/15.
//  Copyright (c) 2015 Team-Hodor. All rights reserved.
//

#import "User.h"

@interface User()

@property (nonatomic, strong, readwrite) NSString *sessionId;
@property (nonatomic, strong, readwrite) NSString *uniqueId;
@property (nonatomic, strong, readwrite) NSString *username;

@end

@implementation User

- (instancetype)initWithUsername:(NSString *)username andSessionId:(NSString *)sessionId andUniqueId:(NSString *)uniqueId {
    self = [super init];
    
    if (self) {
        self.username = username;
        self.sessionId = sessionId;
        self.uniqueId = uniqueId;
    }
    
    return self;
}

// TODO: Override Setters

@end

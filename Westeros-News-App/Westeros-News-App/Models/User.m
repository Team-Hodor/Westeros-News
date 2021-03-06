//
//  User.m
//  Westeros-News-App
//
//  Created by P. Mihaylov on 6/1/15.
//  Copyright (c) 2015 Team-Hodor. All rights reserved.
//

#import "User.h"

@interface User()

@property (nonatomic, strong, readwrite) NSString *sessionToken;
@property (nonatomic, strong, readwrite) NSString *uniqueId;
@property (nonatomic, strong, readwrite) NSString *username;

@end

@implementation User

- (instancetype)init {
    self = [super init];
    
    if (self) {
        self.favouriteNews = [[NSMutableArray alloc] init];
    }
    
    return self;
}

- (instancetype)initWithUsername:(NSString *)username
                            name:(NSString *)name
                    andSessionId:(NSString *)sessionId
                     andUniqueId:(NSString *)uniqueId {
    self = [super init];
    
    if (self) {
        self.username = username;
        self.name = name;
        self.sessionToken = sessionId;
        self.uniqueId = uniqueId;
    }
    
    return self;
}

// TODO: Override Setters

@end

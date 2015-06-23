//
//  Comment.m
//  Westeros-News-App
//
//  Created by Engin Dzhemil on 6/22/15.
//  Copyright (c) 2015 Team-Hodor. All rights reserved.
//

#import "Comment.h"

@implementation Comment


- (instancetype)initWithContent:(NSString *)content
                       authorId:(NSString *)authorId
                        createdAt:(NSDate *)createdAt
                     andUniqueId:(NSString *)uniqueId {
    self = [super init];
    
    if (self) {
        self.content = content;
        self.authorId = authorId;
        self.createdAt = createdAt;
        self.uniqueId = uniqueId;
    }
    
    return self;
}

@end

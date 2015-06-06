//
//  DataRepository.m
//  Westeros-News-App
//
//  Created by P. Mihaylov on 6/6/15.
//  Copyright (c) 2015 Team-Hodor. All rights reserved.
//

#import "DataRepository.h"

@implementation DataRepository

static DataRepository *sharedInst = nil;

+ (DataRepository *)sharedInstance {
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

- (void)logoutLoggedUser {
    if (self.loggedUser) {
        // TODO: Logout
    }
}

@end

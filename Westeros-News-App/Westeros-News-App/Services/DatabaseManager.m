//
//  ServerManager.m
//  Westeros-News-App
//
//  Created by P. Mihaylov on 6/1/15.
//  Copyright (c) 2015 Team-Hodor. All rights reserved.
//

#import "DatabaseManager.h"
#import "Article.h"

@implementation DatabaseManager

static DatabaseManager *sharedInst = nil;

+ (DatabaseManager *)sharedInstance {
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
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(receiveManagedObjectSaveNotification:)
                                                     name:NSManagedObjectContextDidSaveNotification
                                                   object:nil];
    }
    
    return sharedInst;
}

+ (void)saveNewsInDatabase:(NSDictionary *)newsData {
    NSManagedObjectContext *workerContext = [[DatabaseManager sharedInstance] workerContext];
    
    [workerContext performBlock:^() {
        int duplicatesCount = 0;
        
        for (id news in [newsData valueForKey:@"results"]) {
            NSString *authorID = [[news valueForKey:@"author"] valueForKey:@"objectId"];
            NSString *categoryID = [[news valueForKey:@"category"] valueForKey:@"objectId"];
            NSString *content = [news valueForKey:@"content"];
            NSString *identifier = [news valueForKey:@"objectId"];
            NSString *imageURL = [[news valueForKey:@"mainImage"] valueForKey:@"url"];
            NSString *thumbnailURL = [[news valueForKey:@"previewImage"] valueForKey:@"url"];
            NSString *title = [news valueForKey:@"title"];
            NSString *subtitle = [news valueForKey:@"subtitle"];
            
            
            NSDateFormatter *dateFormat = [[NSDateFormatter alloc]init];
            
            [dateFormat setDateFormat:@"yyyy'-'MM'-'dd'T'HH':'mm':'ss.SSS'Z'"];
            [dateFormat setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
            
            NSDate *createdAt = [dateFormat dateFromString:((NSString *)[news valueForKey:@"createdAt"])];
            NSDate *updatedAt = [dateFormat dateFromString:((NSString *)[news valueForKey:@"updatedAt"])];
            
            NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Article"];
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"identifier = %@", identifier];
            [request setPredicate:predicate];
            
            NSArray *result = [workerContext executeFetchRequest:request error:nil];
            if (![result count]) {
                Article *article = [NSEntityDescription insertNewObjectForEntityForName:@"Article"
                                                                 inManagedObjectContext:workerContext];
                
                article.authorID = authorID;
                article.categoryID = categoryID;
                article.content = content;
                article.identifier = identifier;
                article.mainImageURL = imageURL;
                article.previewImageURL = thumbnailURL;
                article.title = title;
                article.subtitle = subtitle;
                article.createdAt = createdAt;
                article.updatedAt = updatedAt;
            } else {
                duplicatesCount++;
                
                Article *article = result[0];
                
                article.authorID = authorID;
                article.categoryID = categoryID;
                article.content = content;
                article.identifier = identifier;
                article.mainImageURL = imageURL;
                article.previewImageURL = thumbnailURL;
                article.title = title;
                article.subtitle = subtitle;
                article.createdAt = createdAt;
                article.updatedAt = updatedAt;
            }
        }
        
        if (duplicatesCount) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"DuplicatedArticlesNotification"
                                                                object:nil];
        } else {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"NoDuplicatedArticlesNotification"
                                                                object:nil];
        }
        
        NSError *error;
        [workerContext save:&error];
    }];
}

#pragma mark - Core Data stack

@synthesize masterContext = _masterContext;
@synthesize mainContext = _mainContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (NSManagedObjectModel *)managedObjectModel {
    // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Westeros_News_App" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it.
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    // Create the coordinator and store
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    
    NSURL *directoryURL = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    
    NSURL *storeURL = [directoryURL URLByAppendingPathComponent:@"Westeros_News_App.sqlite"];
    NSError *error = nil;
    NSString *failureReason = @"There was an error creating or loading the application's saved data.";
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        // Report any error we got.
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
        dict[NSLocalizedFailureReasonErrorKey] = failureReason;
        dict[NSUnderlyingErrorKey] = error;
        error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        // Replace this with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}


- (NSManagedObjectContext *)masterContext {
    // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
    if (_masterContext != nil) {
        return _masterContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        return nil;
    }
    _masterContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    [_masterContext setPersistentStoreCoordinator:coordinator];
    return _masterContext;
}

- (NSManagedObjectContext *)mainContext {
    // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
    if (_mainContext != nil) {
        return _mainContext;
    }
    
    _mainContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    [_mainContext setParentContext:self.masterContext];
    
    return _mainContext;
}

#pragma mark - Core Data Saving support

- (void)saveContext {
    NSManagedObjectContext *managedObjectContext = self.masterContext;
    if (managedObjectContext != nil) {
        NSError *error = nil;
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

- (NSManagedObjectContext *)workerContext {
    NSManagedObjectContext *workerContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    
    [workerContext setParentContext:self.mainContext];
    
    return workerContext;
}

- (void)receiveManagedObjectSaveNotification:(id)receivedNotification {
    NSNotification *notification = receivedNotification;
    NSManagedObjectContext *context = notification.object;
    if ([context parentContext]) {
        NSError *error;
        [context.parentContext save:&error];
        if (error) {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        }
    }
}



@end

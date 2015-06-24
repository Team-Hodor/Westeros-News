//
//  AppDelegate.m
//  Westeros-News-App
//
//  Created by P. Mihaylov on 6/1/15.
//  Copyright (c) 2015 Team-Hodor. All rights reserved.
//

#import "AppDelegate.h"
#import "DatabaseManager.h"
#import "WebServiceManager.h"
#import "DataRepository.h"
#import "DatabaseManager.h"

@interface AppDelegate ()


#define TOTAL_ARTICLES_TO_SAVE 10
@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:NO];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    User *loggedUser = [DataRepository sharedInstance].loggedUser;
    
    if (loggedUser) {
        [[NSUserDefaults standardUserDefaults] setObject:loggedUser.username forKey:@"username"];
        [[NSUserDefaults standardUserDefaults] setObject:loggedUser.uniqueId forKey:@"uniqueID"];
        [[NSUserDefaults standardUserDefaults] setObject:loggedUser.name forKey:@"name"];
        [[NSUserDefaults standardUserDefaults] setObject:loggedUser.sessionToken forKey:@"sessionToken"];
        [[NSUserDefaults standardUserDefaults] setObject:loggedUser.favouriteNews forKey:@"favouriteNews"];
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:loggedUser.isAdmin] forKey:@"isAdmin"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    } else {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"username"];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"uniqueID"];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"name"];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"sessionToken"];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"favouriteNews"];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"isAdmin"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    NSManagedObjectContext *context = [DatabaseManager sharedInstance].masterContext;
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Article"
                                              inManagedObjectContext:context];
    
    NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"createdAt" ascending:YES];
    
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sort]];
    [fetchRequest setFetchBatchSize:20];
    [fetchRequest setEntity:entity];
    
    NSError *error;
    NSArray *results = [context executeFetchRequest:fetchRequest error:&error];
    
    if (!error) {
        
        NSUInteger resultsCount = TOTAL_ARTICLES_TO_SAVE > [results count] ? [results count] : TOTAL_ARTICLES_TO_SAVE;
        
        for (int index = 0; index < resultsCount; index++) {
            [context deleteObject:results[index]];
        }
        [context save:&error];
    }
}

- (NSURL *)applicationDocumentsDirectory {
    // The directory the application uses to store the Core Data store file. This code uses a directory named "com.hodor.Westeros_News_App" in the application's documents directory.
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

@end

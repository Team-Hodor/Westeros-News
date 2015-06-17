//
//  NewsTableViewController.m
//  Westeros-News-App
//
//  Created by P. Mihaylov on 6/7/15.
//  Copyright (c) 2015 Team-Hodor. All rights reserved.
//

#import "NewsTableViewController.h"
#import "WebServiceManager.h"
#import "DataRepository.h"
#import "DatabaseManager.h"
#import "Article.h"
#import "NSString+DateValue.h"
#import "NewsTableViewCell.h"

typedef enum {
    FeaturedNewsSection,
    AllNewsSection,
    FavouriteNewsSection
} NewsSection;

@interface NewsTableViewController () <NSFetchedResultsControllerDelegate>

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic) NewsSection selectedSection;
@property (nonatomic) NSInteger currentWebRequestSkipCount;
@property (nonatomic) NSInteger currentNumberOfInsertions;
@property (nonatomic) BOOL hasFinishedPaging;

#define CELL_ID @"ArticleCell"
#define WEB_REQUEST_LIMIT 5

@end

@implementation NewsTableViewController


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self performInitialConfiguration];
    
    NSError *error;
    [[self fetchedResultsController] performFetch:&error];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Fetch Results Controller

- (NSFetchedResultsController *)fetchedResultsController {
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSManagedObjectContext *context = [DatabaseManager sharedInstance].mainContext;
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Article"
                                              inManagedObjectContext:context];
    
    NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"createdAt" ascending:NO];

    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sort]];
    [fetchRequest setFetchBatchSize:20];
    [fetchRequest setEntity:entity];
    [fetchRequest setFetchLimit:5];
    [fetchRequest setFetchOffset:0];
    
    
    
    _fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                    managedObjectContext:context
                                                                      sectionNameKeyPath:nil
                                                                               cacheName:nil];
    _fetchedResultsController.delegate = self;
    return _fetchedResultsController;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    
    return [[self.fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
    
    NSInteger numRows = [sectionInfo numberOfObjects];
    
    if (self.selectedSection == AllNewsSection && !self.hasFinishedPaging) {
        return numRows + 1;
    }
    
    return [[self.fetchedResultsController fetchedObjects] count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    id  sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:indexPath.section];

    UIView *bgColorView = [[UIView alloc] init];
    bgColorView.backgroundColor = [UIColor colorWithRed:59.0f/255.0f green:110.0f/255.0f blue:165.0f/255.0f alpha:1.0f];
    
    if ([sectionInfo numberOfObjects] > indexPath.row) {
        NewsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CELL_ID forIndexPath:indexPath];
        Article *article = [self.fetchedResultsController objectAtIndexPath:indexPath];
        
        [cell setArticle:article];
        
        //set cell background color on selection
        [cell setSelectedBackgroundView:bgColorView];
        
            return cell;
    } else {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"showMoreCell" forIndexPath:indexPath];
        
        //set cell background color on selection
        [cell setSelectedBackgroundView:bgColorView];
            return cell;
    }
    

}

#pragma mark - Controller

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller
   didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath
     forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath {
    
    
    
    UITableView *tableView = self.tableView;
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]
                                  withRowAnimation:UITableViewRowAnimationFade];
            break;
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
            break;
        case NSFetchedResultsChangeUpdate:
            break;
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView endUpdates];
    
    if (self.selectedSection == FeaturedNewsSection) {
        NSFetchRequest *request = [self.fetchedResultsController fetchRequest];
        [request setFetchLimit:5];
        [self.fetchedResultsController performFetch:nil];
        [self.tableView reloadData];
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    id  sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:indexPath.section];
    
    
    if ( !( [sectionInfo numberOfObjects] > indexPath.row ) ) {
        [self loadNewsWithLimit:WEB_REQUEST_LIMIT skip:self.currentWebRequestSkipCount];
        self.currentWebRequestSkipCount += WEB_REQUEST_LIMIT;
        if (self.currentWebRequestSkipCount > [[self.fetchedResultsController fetchedObjects] count]) {
            self.currentWebRequestSkipCount = [[self.fetchedResultsController fetchedObjects] count];
        }
        
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        
    }else{
        Article *article = [self.fetchedResultsController objectAtIndexPath:indexPath];
        [[DataRepository sharedInstance] setSelectedArticle:article];
        UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
        UIViewController *showUserProfileViewController = [mainStoryboard instantiateViewControllerWithIdentifier:@"NewsDetailView"];
        
        [self.navigationController pushViewController:showUserProfileViewController animated:YES];
    }
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

- (void)performInitialConfiguration {
    [DataRepository sharedInstance].selectedArticle = nil;
    
    //set navigationBar colour
    [self.navigationController.navigationBar setBarTintColor:[UIColor colorWithRed:59.0f/255.0f green:110.0f/255.0f blue:165.0f/255.0f alpha:1.0f]];
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    
    //set tabBar colour
    [self.tabBarController.tabBar setBackgroundColor:[UIColor redColor]];
    
    UIBarButtonItem *profileButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"profile-icon@3x.png"] landscapeImagePhone:[UIImage imageNamed:@"profile-icon@3x.png"] style:UIBarButtonItemStylePlain target:self action:@selector(showUserProfileButtonTapped)];
    self.navigationItem.rightBarButtonItem = profileButton;
    
    // New Post button
    if ([DataRepository sharedInstance].loggedUser.isAdmin) {
        UIBarButtonItem *newArticleButton = [[UIBarButtonItem alloc] initWithTitle:@"New Article" style:UIBarButtonItemStylePlain target:self action:@selector(newArticleButtonTapped)];
        
        self.navigationItem.leftBarButtonItem = newArticleButton;
    }
    
    self.currentWebRequestSkipCount = 5;
    [self loadInitialNews];
}

#pragma mark - Web service managers
// Probably useless
- (void)loadFullUserDataForUser:(User *)user {
//    [WebServiceManager loadFullUserDataForUserWithID:user.uniqueId completion:^(NSDictionary *resultData, NSURLResponse *response, NSError *error) {
//        
//            User *loggedUser = [DataRepository sharedInstance].loggedUser;
//            if ([resultData valueForKey:@"isAdmin"]) {
//                loggedUser.isAdmin = YES;
//            } else {
//                loggedUser.isAdmin = NO;
//            }
//            
//            loggedUser.favouriteNews = [resultData valueForKey:@"favourites"];
//    }];
}

- (void)loadNewsWithLimit:(NSInteger)limit skip:(NSInteger)skip {
    [WebServiceManager loadNewsWithLimit:limit
                                    skip:skip
                            sessionToken:[DataRepository sharedInstance].loggedUser.sessionToken
                              completion:^(NSDictionary *resultData, NSURLResponse *response, NSError *error) {
            if (![[resultData valueForKey:@"results"] count]) {
                self.hasFinishedPaging = YES;
                [self.tableView beginUpdates];
                NSInteger lastSection = [self.tableView numberOfSections] - 1;
                NSInteger lastRow = [self.tableView numberOfRowsInSection:lastSection] - 1;
                
                NSIndexPath *lastIndexPath = [NSIndexPath indexPathForRow:lastRow inSection:lastSection];
                [self.tableView deleteRowsAtIndexPaths:@[lastIndexPath] withRowAnimation:UITableViewRowAnimationTop];
                [self.tableView endUpdates];
                return;
            }
            
            [self saveNewsInDatabase:resultData];
    }];
}

- (void)loadInitialNews {
    [WebServiceManager loadNewsWithLimit:WEB_REQUEST_LIMIT
                                    skip:0
                            sessionToken:[DataRepository sharedInstance].loggedUser.sessionToken
                              completion:^(NSDictionary *dataDictionary, NSURLResponse *response, NSError *error) {
                                  if ([dataDictionary count] > 0) {
                                      NSFetchRequest *request = [[NSFetchRequest alloc] init];
                                      [request setEntity:[NSEntityDescription entityForName:@"Article" inManagedObjectContext:[DatabaseManager sharedInstance].masterContext]];
                                      
                                      [request setIncludesPropertyValues:NO]; //only fetch the managedObjectID
                                      
                                      NSError * error = nil;
                                      NSArray * result = [[DatabaseManager sharedInstance].masterContext executeFetchRequest:request error:&error];
                                      
                                      //error handling goes here
                                      for (NSManagedObject * news in result) {
                                          [[DatabaseManager sharedInstance].masterContext deleteObject:news];
                                      }
                                      NSError *saveError = nil;
                                      [[DatabaseManager sharedInstance].masterContext save:&saveError];
                                      
                                      [self saveNewsInDatabase:dataDictionary];
                                  }
                              }];
}

-(void)saveNewsInDatabase:(NSDictionary *)newsData {
    NSManagedObjectContext *workerContext = [[DatabaseManager sharedInstance] workerContext];
    
    [workerContext performBlock:^() {
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
                article.imageURL = imageURL;
                article.thumbnailURL = thumbnailURL;
                article.title = title;
                article.subtitle = subtitle;
                article.createdAt = createdAt;
                article.updatedAt = updatedAt;
            } else {
                Article *article = result[0];
                
                article.authorID = authorID;
                article.categoryID = categoryID;
                article.content = content;
                article.identifier = identifier;
                article.imageURL = imageURL;
                article.thumbnailURL = thumbnailURL;
                article.title = title;
                article.subtitle = subtitle;
                article.createdAt = createdAt;
                article.updatedAt = updatedAt;
            }
        }
        
        NSError *error;
        [workerContext save:&error];
    }];
}

#pragma mark - Event Handlers

- (void)newArticleButtonTapped {
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    UINavigationController *newArticleViewController = [mainStoryboard instantiateViewControllerWithIdentifier:@"newArticleViewController"];
    
    [self presentViewController:newArticleViewController animated:YES completion:nil];
}

-(void)showUserProfileButtonTapped{
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    UIViewController *showUserProfileViewController = [mainStoryboard instantiateViewControllerWithIdentifier:@"userProfileView"];
    
    [self.navigationController pushViewController:showUserProfileViewController animated:YES];
}

- (IBAction)featuredBarButtonItemActionTriggered:(id)sender {
    if (self.selectedSection != FeaturedNewsSection) {
        self.selectedSection = FeaturedNewsSection;
        self.hasFinishedPaging = NO;
        
        NSFetchRequest *request = [self.fetchedResultsController fetchRequest];
        [request setFetchLimit:5];
        [request setPredicate:nil];
        
        
        NSError *error;
        [self.fetchedResultsController performFetch:&error];
        
        if (error) {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        } else {
            [self.tableView reloadData];
        }
    }
}

- (IBAction)allNewsBarButtonItemActionTriggered:(id)sender {
    if (self.selectedSection != AllNewsSection) {
        self.selectedSection = AllNewsSection;
        
        NSFetchRequest *request = [self.fetchedResultsController fetchRequest];
        [request setFetchLimit:2000];
        [request setPredicate:nil];
        
        NSError *error;
        [self.fetchedResultsController performFetch:&error];
        
        if (error) {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        } else {
            [self.tableView reloadData];
        }
        
        [self loadNewsWithLimit:WEB_REQUEST_LIMIT skip:0];
    }
}

- (IBAction)favouritesBarButtonItemActionTriggered:(id)sender {
    if (self.selectedSection != FavouriteNewsSection) {
        self.selectedSection = FavouriteNewsSection;
        self.hasFinishedPaging = NO;
        
        [WebServiceManager loadFavouriteNewsForUser:[DataRepository sharedInstance].loggedUser completion:^(NSDictionary *resultData, NSURLResponse *response, NSError *error) {
                [self saveNewsInDatabase:resultData];
        }];
        
        NSFetchRequest *request = [self.fetchedResultsController fetchRequest];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%@ CONTAINS identifier", [DataRepository sharedInstance].loggedUser.favouriteNews];
        
        [request setPredicate:predicate];
        [request setFetchLimit:2000];
        
        NSError *error;
        [self.fetchedResultsController performFetch:&error];
        
        if (error) {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        } else {
            [self.tableView reloadData];
        }
    }
}


@end

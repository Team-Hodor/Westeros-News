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
#import "UIAlertController+ShowAlert.h"

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
    
    if (self.selectedSection == FavouriteNewsSection) {
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
    
    self.navigationController.toolbarHidden = NO;
    [DataRepository sharedInstance].selectedArticle = nil;
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

#pragma mark - Table Cell Editing

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row < 0 || indexPath.section < 0) {
        return UITableViewCellEditingStyleNone;
    } else {
        return UITableViewCellEditingStyleDelete;
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    
    if ([DataRepository sharedInstance].loggedUser.isAdmin == NO || self.selectedSection == FeaturedNewsSection) {
        return NO;
    } else if (indexPath.row < 0 || indexPath.section < 0) {
        return NO;
    } else if (self.selectedSection == FavouriteNewsSection) {
        return YES;
    } else {
        return YES;
    }
}

- (NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row < 0 || indexPath.section < 0) {
        return nil;
    }
    
    if (self.selectedSection == FavouriteNewsSection) {
        // TODO:
        return nil;
    } else {
        UITableViewRowAction *deleteAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive  title:@"Delete" handler:^(UITableViewRowAction *rowAction,NSIndexPath *indexPath) {
            
            Article *fetchedObject = [self.fetchedResultsController objectAtIndexPath:indexPath];
            [WebServiceManager deleteArticleWithObjectId:fetchedObject.identifier completion:^(NSDictionary *resultData, NSHTTPURLResponse *response, NSError *error) {
                if (![resultData valueForKey:@"error"]) {
                    NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
                    
                    [context deleteObject:fetchedObject];
                    [context save:nil];
                } else {
                    [UIAlertController showAlertWithTitle:@"Error"
                                               andMessage:@"There was an error deleting the article. Please try again later."
                                         inViewController:self
                                              withHandler:nil];
                }
            }];
        }];
        
        UITableViewRowAction *editAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal  title:@" Edit " handler:^(UITableViewRowAction *rowAction,NSIndexPath *indexPath) {
            
            Article *fetchedObject = [self.fetchedResultsController objectAtIndexPath:indexPath];
            [DataRepository sharedInstance].selectedArticle = fetchedObject;
            [self showNewArticleViewController];
        }];
        
        editAction.backgroundColor = [UIColor orangeColor];
        
        return @[deleteAction, editAction];
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
        
        id objectToDelete = [self.fetchedResultsController objectAtIndexPath:indexPath];
        
        [context deleteObject:objectToDelete];
        
        NSError *error;
        [context save:&error];
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
        
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        
    }else{
        Article *article = [self.fetchedResultsController objectAtIndexPath:indexPath];
        [[DataRepository sharedInstance] setSelectedArticle:article];
        UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
        UIViewController *showUserProfileViewController = [mainStoryboard instantiateViewControllerWithIdentifier:@"NewsDetailView"];
        
        [self.navigationController pushViewController:showUserProfileViewController animated:YES];
    }
}

#pragma mark - Private Methods

- (void)performInitialConfiguration {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveNoDuplicatedArticlesSavedNotification:)
                                                 name:@"NoDuplicatedArticlesNotification"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveDuplicatedArticlesSavedNotification:)
                                                 name:@"DuplicatedArticlesNotification"
                                               object:nil];
    
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
        UIBarButtonItem *newArticleButton = [[UIBarButtonItem alloc] initWithTitle:@"New Article" style:UIBarButtonItemStylePlain target:self action:@selector(showNewArticleViewController)];
        
        self.navigationItem.leftBarButtonItem = newArticleButton;
    }
    
    self.currentWebRequestSkipCount = 5;
    [self loadInitialNews];
}

- (void)loadNewsWithLimit:(NSInteger)limit skip:(NSInteger)skip {
    [WebServiceManager loadNewsWithLimit:limit
                                    skip:skip
                            sessionToken:[DataRepository sharedInstance].loggedUser.sessionToken
                              completion:^(NSDictionary *resultData, NSHTTPURLResponse *response, NSError *error) {
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
            
            [DatabaseManager saveNewsInDatabase:resultData];
    }];
}

- (void)loadInitialNews {
    [WebServiceManager loadNewsWithLimit:WEB_REQUEST_LIMIT
                                    skip:0
                            sessionToken:[DataRepository sharedInstance].loggedUser.sessionToken
                              completion:^(NSDictionary *dataDictionary, NSHTTPURLResponse *response, NSError *error) {
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
                                      
                                      [DatabaseManager saveNewsInDatabase:dataDictionary];
                                  }
                              }];
}

#pragma mark - Event Handlers

- (void)showNewArticleViewController {
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
        
        self.currentWebRequestSkipCount = 0;
        [self loadNewsWithLimit:WEB_REQUEST_LIMIT skip:self.currentWebRequestSkipCount];
    }
}

- (IBAction)favouritesBarButtonItemActionTriggered:(id)sender {
    if (self.selectedSection != FavouriteNewsSection) {
        self.selectedSection = FavouriteNewsSection;
        self.hasFinishedPaging = NO;
        
        
        [WebServiceManager loadFavouriteNewsForUser:[DataRepository sharedInstance].loggedUser completion:^(NSDictionary *resultData, NSHTTPURLResponse *response, NSError *error) {
                [DatabaseManager saveNewsInDatabase:resultData];
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


- (void)receiveNoDuplicatedArticlesSavedNotification:(id)receivedNotification {
    if (self.selectedSection == AllNewsSection &&
            self.currentWebRequestSkipCount < [[self.fetchedResultsController fetchedObjects] count]) {
        
        self.currentWebRequestSkipCount += WEB_REQUEST_LIMIT;
        [self loadNewsWithLimit:WEB_REQUEST_LIMIT skip:self.currentWebRequestSkipCount];
    }
}

- (void)receiveDuplicatedArticlesSavedNotification:(id)receivedNotification {
    if (self.selectedSection == AllNewsSection) {
        self.currentWebRequestSkipCount = [[self.fetchedResultsController fetchedObjects] count];
    }
}

@end

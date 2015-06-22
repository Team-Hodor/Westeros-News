//
//  ArticleCommentViewController.m
//  Westeros-News-App
//
//  Created by Engin Dzhemil on 6/21/15.
//  Copyright (c) 2015 Team-Hodor. All rights reserved.
//

#import "ArticleCommentViewController.h"
#import "WebServiceManager.h"
#import "DataRepository.h"
#import "CommentTableViewCell.h"
#import "Comment.h"
#import "UIAlertController+ShowAlert.h"

@interface ArticleCommentViewController ()<UITableViewDataSource,UITableViewDelegate, UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *commentTextField;
@property (weak, nonatomic) IBOutlet UIScrollView *mainScrollView;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topConstrain;

@property (nonatomic, strong) NSMutableArray *comments;

@end

@implementation ArticleCommentViewController
UIGestureRecognizer *tapper;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self performInitialConfiguration];
}

- (void)performInitialConfiguration {
    self.tableView.transform = CGAffineTransformMakeRotation(-M_PI);
    
    self.tableView.allowsSelection = NO;
    
    [self registerForKeyboardNotifications];
    
    self.commentTextField.delegate = self;
    
    tapper = [[UITapGestureRecognizer alloc]
              initWithTarget:self action:@selector(handleSingleTap:)];
    tapper.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tapper];
}


- (void)handleSingleTap:(UITapGestureRecognizer *) sender{
    [self.view endEditing:YES];
}

-(void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    self.comments = [[NSMutableArray alloc]init];
    
    [self loadComments];
}

- (IBAction)sendCommentTapped:(id)sender {
    
    User *user = [DataRepository sharedInstance].loggedUser;
    NSString *commentText = self.commentTextField.text;
    
    if([self areFieldsValidated]){
        
        [WebServiceManager addComment:commentText forArticleWithId:[DataRepository sharedInstance].selectedArticle.identifier sessionToken:user.sessionToken completion:^(NSDictionary *dataDictionary, NSHTTPURLResponse *response) {
            if ( [dataDictionary objectForKey:@"error"] ) {
                
                [UIAlertController showAlertWithTitle:@"Error"
                                           andMessage:@"Couldn't add comment. Please try again."
                                     inViewController:self
                                          withHandler:nil];
            }else{
                self.commentTextField.text = @"";
                
                // Comment *comment = [[Comment alloc] init];
                // comment.authorId = user.uniqueId;
                // comment.content = commentText;
                // comment.createdAt = [[dataDictionary objectForKey:@"results"] objectForKey:@"createdAt"];
                
                //[self.comments addObject:comment];
                //[self.tableView reloadData];
                [self loadComments];
            }
            
        }];
    }
    
    
    
    [self.commentTextField resignFirstResponder];
}

-(void)loadComments{
    
    [self.comments removeAllObjects];
    
        [WebServiceManager getCommentsForArticleWithId:[DataRepository sharedInstance].selectedArticle.identifier sessionToken:[DataRepository sharedInstance].loggedUser.sessionToken completion:^(NSDictionary *dataDictionary, NSHTTPURLResponse *response) {
            
            if(dataDictionary !=nil){
                
                if ( [dataDictionary objectForKey:@"error"] ) {
                    
                    [UIAlertController showAlertWithTitle:@"Error"
                                               andMessage:@"Couldn't load comments."
                                         inViewController:self
                                              withHandler:nil];
                }else{
                    
                    for (NSDictionary *result in [dataDictionary objectForKey:@"results"]) {
                        Comment *comment = [[Comment alloc] init];
                        comment.authorId = [[result objectForKey:@"authorID"] objectForKey:@"objectId"];
                        comment.content = [result objectForKey:@"content"];
                        comment.createdAt = [result objectForKey:@"createdAt"];
                        
                        [self.comments addObject:comment];
                    }
                    
                    [self.tableView reloadData];
                }
                
                
            }
            else{
                [UIAlertController showAlertWithTitle:@"No Comments"
                                           andMessage:@"Be first to comment."
                                     inViewController:self
                                          withHandler:nil];
            }
            
        }];
    
}

-(BOOL) areFieldsValidated {
    NSString *errorMessage;
    
    NSString *name = [self.commentTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    
    if ([name length] == 0) {
        errorMessage = @"The comment text field cannot be empty.";
    }
    
    if (!errorMessage) {
        return YES;
    } else {
        [UIAlertController showAlertWithTitle:@"Error"
                                   andMessage:errorMessage
                             inViewController:self
                                  withHandler:nil];
        return NO;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.comments.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [self basicCellAtIndexPath:indexPath];
}

- (CommentTableViewCell *)basicCellAtIndexPath:(NSIndexPath *)indexPath {
    CommentTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"commentCell" forIndexPath:indexPath];
    cell.transform = CGAffineTransformMakeRotation(M_PI);
    [self configureBasicCell:cell atIndexPath:indexPath];
    return cell;
}

- (void)configureBasicCell:(CommentTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    Comment *comment = [self.comments objectAtIndex:indexPath.row];
    [self setDateAndAuthorForCell:cell item:comment.authorId];
    [self setContentForCell:cell item:comment.content];
}

- (void)setDateAndAuthorForCell:(CommentTableViewCell *)cell item:(NSString *)item {
    [cell.dateAndAuthorLabel setText:item];
}

- (void)setContentForCell:(CommentTableViewCell *)cell item:(NSString *)item {

    [cell.contentTextView setText:item];
    [cell.contentTextView setFrame:CGRectMake(10, cell.contentTextView.frame.origin.y, cell.contentTextView.frame.size.width, cell.contentTextView.frame.size.height)];
    
    cell.contentTextView.layer.cornerRadius = 10.0;
    cell.contentTextView.clipsToBounds = YES;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [self heightForBasicCellAtIndexPath:indexPath];
}

- (CGFloat)heightForBasicCellAtIndexPath:(NSIndexPath *)indexPath {
    static CommentTableViewCell *sizingCell = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sizingCell = [self.tableView dequeueReusableCellWithIdentifier:@"commentCell"];
    });
    
    [self configureBasicCell:sizingCell atIndexPath:indexPath];
    return [self calculateHeightForConfiguredSizingCell:sizingCell];
}

- (CGFloat)calculateHeightForConfiguredSizingCell:(UITableViewCell *)sizingCell {
    [sizingCell setNeedsLayout];
    [sizingCell layoutIfNeeded];
    
    CGSize size = [sizingCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
    return size.height;
}

#pragma mark - Managing the keyboard

- (void)registerForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeShown:)
                                                 name:UIKeyboardWillShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
    
}

// Called when the UIKeyboardDidShowNotification is sent.
- (void)keyboardWillBeShown:(NSNotification*)aNotification
{
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    self.topConstrain.constant = -kbSize.height;
}

// Called when the UIKeyboardWillHideNotification is sent
- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    
    self.topConstrain.constant = 0;
}

# pragma mark - Text Field Delegate

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

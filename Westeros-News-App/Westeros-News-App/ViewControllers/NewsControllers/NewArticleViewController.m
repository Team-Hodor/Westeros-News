//
//  NewArticleViewController.m
//  Westeros-News-App
//
//  Created by P. Mihaylov on 6/15/15.
//  Copyright (c) 2015 Team-Hodor. All rights reserved.
//

#import "NewArticleViewController.h"
#import "DataRepository.h"
#import "WebServiceManager.h"
#import "UIAlertController+ShowAlert.h"
#import "DatabaseManager.h"

@interface NewArticleViewController () <UIImagePickerControllerDelegate, UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate, UITextViewDelegate, UINavigationControllerDelegate>

// IBOutlets
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UITextView *contentTextView;
@property (weak, nonatomic) IBOutlet UITextField *titleTextField;
@property (weak, nonatomic) IBOutlet UITextField *subtitleTextField;
@property (weak, nonatomic) IBOutlet UITextField *categoryTextField;
@property (weak, nonatomic) IBOutlet UIImageView *previewImageView;
@property (weak, nonatomic) IBOutlet UIImageView *mainImageView;
@property (weak, nonatomic) IBOutlet UIButton *submitButton;

// View management properties
@property (strong, nonatomic) UIView *activeField;
@property (nonatomic) NSInteger chooseImageSenderTag;

// Category management properties
@property (strong, nonatomic) NSMutableArray *categoryTitles;
@property (strong, nonatomic) NSMutableDictionary *categoriesByID;

// Edit Article properties
@property (strong, nonatomic) UIImage *initialMainImage;
@property (strong, nonatomic) UIImage *initialPreviewImage;

@end

@implementation NewArticleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self registerForKeyboardNotifications];
    [self performInitialConfiguration];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Event Handlers

- (void)cancelButtonActionTriggered {
    [self.view endEditing:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)chooseImageButtonTouchUpInside:(id)sender {
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    self.chooseImageSenderTag = [sender tag];
    
    [self presentViewController:picker animated:YES completion:NULL];
}

- (IBAction)submitButtonTouchUpInside:(id)sender {
    if (![self areFieldsValidated]) {
        return;
    } else {
        ((UIButton *)sender).enabled = NO;
    }
    
    NSString *title = [self.titleTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *subtitle = [self.subtitleTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    UIImage *previewImage = self.previewImageView.image;
    UIImage *mainImage = self.mainImageView.image;
    
    NSString *content = self.contentTextView.text;
    NSString *categoryID = self.categoriesByID[self.categoryTextField.text];
    
    Article *selectedArticle = [DataRepository sharedInstance].selectedArticle;
    User *currentUser = [DataRepository sharedInstance].loggedUser;
    
    if (selectedArticle) {
        if (self.initialMainImage == mainImage) {
            mainImage = nil;
        }
        
        if (self.initialPreviewImage == previewImage) {
            previewImage = nil;
        }
        
        [self editSelectedArticleWithObjectID:selectedArticle.identifier
                                        title:title
                                     subtitle:subtitle
                                   categoryID:categoryID
                                 previewImage:previewImage
                                    mainImage:mainImage
                                      content:content
                                 sessionToken:currentUser.sessionToken];
    } else {
        [self postArticleWithTitle:title
                          subtitle:subtitle
                        categoryID:categoryID
                      previewImage:previewImage
                         mainImage:mainImage
                           content:content
                      sessionToken:currentUser.sessionToken];
    }
}

#pragma mark - Private methods

- (void)postArticleWithTitle:(NSString *)title
                    subtitle:(NSString *)subtitle
                  categoryID:(NSString *)categoryID
                previewImage:(UIImage *)previewImage
                   mainImage:(UIImage *)mainImage
                     content:(NSString *)content
                sessionToken:(NSString *)sessionToken {
    
    [WebServiceManager postNewArticleWithTitle:title
                                      subtitle:subtitle
                                    categoryID:categoryID
                                      authorID:[DataRepository sharedInstance].loggedUser.uniqueId
                                  previewImage:previewImage
                                     mainImage:mainImage
                                       content:content
                                  sessionToken:[DataRepository sharedInstance].loggedUser.sessionToken
                                    completion:^(NSDictionary *resultData, NSHTTPURLResponse *response) {
                                        if ([resultData valueForKey:@"error"]) {
                                            NSString *errorMessage = (NSString *)[resultData valueForKey:@"error"];
                                            self.submitButton.enabled = YES;
                                            
                                            if ([errorMessage isEqualToString:@"Article with such title already exists"]) {
                                                [UIAlertController showAlertWithTitle:@"Error"
                                                                           andMessage:@"An article with such title already exists."
                                                                     inViewController:self
                                                                          withHandler:nil];
                                            } else {
                                                [UIAlertController showAlertWithTitle:@"Error"
                                                                           andMessage:@"An error occured while trying to post the article. Please try again later."
                                                                     inViewController:self
                                                                          withHandler:nil];
                                            }
                                        } else {
                                            [self saveArticleInDatabaseWithObjectId:[resultData valueForKey:@"objectId"]];
                                            
                                            [UIAlertController showAlertWithTitle:@"Success"
                                                                       andMessage:@"The article has been posted successfully."
                                                                 inViewController:self
                                                                      withHandler:^() {
                                                                          [self dismissViewControllerAnimated:YES completion:nil];
                                                                      }];
                                        }
                                    }];
}

- (void)editSelectedArticleWithObjectID:(NSString *)objectID
                                  title:(NSString *)title
                               subtitle:(NSString *)subtitle
                             categoryID:(NSString *)categoryID
                        previewImage:(UIImage *)previewImage
                           mainImage:(UIImage *)mainImage
                             content:(NSString *)content
                           sessionToken:(NSString *)sessionToken {
    
    [WebServiceManager editArticleWithObjectId:objectID
                                         title:title
                                      subtitle:subtitle
                                    categoryID:categoryID
                                       content:content
                                  previewImage:previewImage
                                     mainImage:mainImage
                                  sessionToken:sessionToken
                                    completion:^(NSDictionary *dataDictionary,
                                                 NSHTTPURLResponse *response) {
                                        
                                        // The OK Status codes
                                        if ([response statusCode] >= 200 && [response statusCode] < 300) {
                                            [self saveArticleInDatabaseWithObjectId:objectID];
                                            
                                            [UIAlertController showAlertWithTitle:@"Success"
                                                                       andMessage:@"The article has been edited successfully."
                                                                 inViewController:self
                                                                      withHandler:^() {
                                                                          [self dismissViewControllerAnimated:YES completion:nil];
                                                                      }];
                                        } else {
                                            [UIAlertController showAlertWithTitle:@"Error"
                                                                       andMessage:@"An error occured while trying to post the article. Please try again later."
                                                                 inViewController:self
                                                                      withHandler:nil];
                                            self.submitButton.enabled = YES;
                                        }
                                        
        
    }];
}

- (void)saveArticleInDatabaseWithObjectId:(NSString *)objectId {
    [WebServiceManager loadArticleWithObjectId:objectId
                                    completion:^(NSDictionary *resultData, NSHTTPURLResponse *response) {
                                        NSDictionary *newsData = @{@"results": @[resultData]};
                                        
                                        [DatabaseManager saveNewsInDatabase:newsData];
                                    }];
}

-(BOOL) areFieldsValidated {
    NSString *errorMessage;
    
    NSString *title = [self.titleTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    NSString *subtitle = [self.subtitleTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    NSString *category = [self.categoryTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    NSString *content = [self.contentTextView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if ([title length] == 0) {
        errorMessage = @"The title cannot be left empty.";
    } else if ([subtitle length] == 0) {
        errorMessage = @"The subtitle cannot be left empty.";
    } else if ([category length] == 0) {
        errorMessage = @"The category cannot be left empty";
    } else if ([content length] == 0) {
        errorMessage = @"The content cannot be left empty";
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

- (void)performInitialConfiguration {
    
    //set navigationBar colour
    [self.navigationController.navigationBar setBarTintColor:[UIColor colorWithRed:59.0f/255.0f green:110.0f/255.0f blue:165.0f/255.0f alpha:1.0f]];
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    
    //set title color
    NSDictionary *navbarTitleTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                               [UIColor whiteColor],
                                               NSForegroundColorAttributeName,
                                               nil];
    [self.navigationController.navigationBar setTitleTextAttributes:navbarTitleTextAttributes];
    
    //add cancel button
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(cancelButtonActionTriggered)];
    
    self.navigationItem.leftBarButtonItem = cancelButton;
    
    if ([DataRepository sharedInstance].selectedArticle) {
        // TODO: Set initial values for selected article
        self.title = @"Edit Article";
    } else {
        self.title = @"New Article";
    }
    
    
    //rounded corners
    self.contentTextView.layer.cornerRadius = 10.0;
    self.contentTextView.clipsToBounds = YES;
    
    Article *selectedArticle = [DataRepository sharedInstance].selectedArticle;
    
    [WebServiceManager loadAvailableCategoriesWithCompletion:^(NSDictionary *resultData, NSHTTPURLResponse *response) {
        if (NO) {
            [UIAlertController showAlertWithTitle:@"Error"
                                       andMessage:@"An error occured while trying to get the available categories."
                                 inViewController:self
                                      withHandler:nil];
        }
        
        self.categoryTitles = [[NSMutableArray alloc] init];
        self.categoriesByID = [[NSMutableDictionary alloc] init];
        
        for (id category in [resultData valueForKey:@"results"]) {
            [self.categoryTitles addObject:[category valueForKey:@"name"]];
            [self.categoriesByID setObject:[category valueForKey:@"objectId"]
                                    forKey:[category valueForKey:@"name"]];
            
            if ([category valueForKey:@"objectId"] == selectedArticle.categoryID) {
                self.categoryTextField.text = [category valueForKey:@"name"];
            }
        }
        
        [self initialiseTypePicker];
    }];
    
    if (selectedArticle) {
        self.titleTextField.text = selectedArticle.title;
        self.subtitleTextField.text = selectedArticle.subtitle;
        self.contentTextView.text = selectedArticle.content;
        
        [WebServiceManager downloadImageWithImageURL:selectedArticle.mainImageURL completion:^(NSData *imageData, NSHTTPURLResponse *response) {
            UIImage *image = [UIImage imageWithData:imageData];
            self.mainImageView.image = image;
            self.initialMainImage = image;
        }];
        
        [WebServiceManager downloadImageWithImageURL:selectedArticle.previewImageURL completion:^(NSData *imageData, NSHTTPURLResponse *response) {
            UIImage *image = [UIImage imageWithData:imageData];
            self.previewImageView.image = image;
            self.initialPreviewImage = image;
        }];
    }
}

- (void)initialiseTypePicker {
    UIPickerView *typePicker = [[UIPickerView alloc] init];
    typePicker.dataSource = self;
    typePicker.delegate = self;
    self.categoryTextField.inputView = typePicker;
}

#pragma mark - Managing the keyboard

- (void)registerForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
    
}

// Called when the UIKeyboardDidShowNotification is sent.
- (void)keyboardWasShown:(NSNotification*)aNotification
{
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height, 0.0);
    self.scrollView.contentInset = contentInsets;
    self.scrollView.scrollIndicatorInsets = contentInsets;
    
    // If active text field is hidden by keyboard, scroll it so it's visible
    // Your app might not need or want this behavior.
    CGRect aRect = self.view.frame;
    aRect.size.height -= kbSize.height;
    if (!CGRectContainsPoint(aRect, self.activeField.frame.origin) ) {
        [self.scrollView scrollRectToVisible:self.activeField.frame animated:YES];
    }
}

// Called when the UIKeyboardWillHideNotification is sent
- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    self.scrollView.contentInset = contentInsets;
    self.scrollView.scrollIndicatorInsets = contentInsets;
}

# pragma mark - Text Field Delegate

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    self.activeField = textField;
}

- (void)textFieldDidEndEditing:(UITextField *)textField{
    self.activeField = nil;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - UIImagePickerController Delegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *chosenImage = info[UIImagePickerControllerEditedImage];
    
    if (self.chooseImageSenderTag == 1) {
        self.previewImageView.image = chosenImage;
    } else {
        self.mainImageView.image = chosenImage;
    }
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
}

#pragma mark - UIPickerViewDataSource
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView*)thePickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)thePickerView numberOfRowsInComponent:(NSInteger)component {
    return [self.categoryTitles count];
}

#pragma mark - UIPickerViewDelegate
- (NSString *)pickerView:(UIPickerView *)thePickerView
             titleForRow:(NSInteger)row
            forComponent:(NSInteger)component {
    
    return self.categoryTitles[row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    self.categoryTextField.text = self.categoryTitles[row];
}

@end

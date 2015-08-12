//
//  PQKeyboardManagerView.m
//  PQKeyboardManager
//
//  Created by Paolo Quadrani on 12/08/15.
//  Copyright (c) 2015 nEraLab. All rights reserved.
//

#import "PQKeyboardManagerView.h"

@interface PQKeyboardManagerView ()

@property (assign) UITextField *activeField;

@end

@implementation PQKeyboardManagerView

- (void)didMoveToSuperview {
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    [self addGestureRecognizer:tap];
    
    [self registerForKeyboardNotifications];
    [self registerForTextFieldNotifications];
}

- (void)dismissKeyboard {
    [self.activeField resignFirstResponder];
}

#pragma mark - UITextField Notifications

- (void)registerForTextFieldNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(textFieldDidBeginEditingNotification:)
                                                 name:UITextFieldTextDidBeginEditingNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(textFieldDidEndEditingNotification:)
                                                 name:UITextFieldTextDidEndEditingNotification object:nil];
    
}

- (void)textFieldDidBeginEditingNotification:(NSNotification *)notification
{
    self.activeField = notification.object;
}

- (void)textFieldDidEndEditingNotification:(NSNotification *)notification
{
    self.activeField = nil;
}

#pragma mark - Keyboard Management

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
    self.contentInset = contentInsets;
    self.scrollIndicatorInsets = contentInsets;
    
    // If active text field is hidden by keyboard, scroll it so it's visible
    // Your app might not need or want this behavior.
    CGRect aRect = self.superview.frame;
    aRect.size.height -= kbSize.height;
    if (!CGRectContainsPoint(aRect, self.activeField.frame.origin) ) {
        [self scrollRectToVisible:self.activeField.frame animated:YES];
    }
}

// Called when the UIKeyboardWillHideNotification is sent
- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    self.contentInset = contentInsets;
    self.scrollIndicatorInsets = contentInsets;
}

@end

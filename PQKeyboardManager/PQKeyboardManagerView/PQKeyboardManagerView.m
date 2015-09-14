/***************************************************************************
 Copyright [2015] [Paolo Quadrani]
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 
 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 ***************************************************************************/

//
//  PQKeyboardManagerView.m
//  PQKeyboardManager
//
//  Created by Paolo Quadrani on 12/08/15.
//

#import "PQKeyboardManagerView.h"

@interface PQKeyboardManagerView ()

@property (assign) UITextField *activeField;
@property (strong) UITapGestureRecognizer *tap;

@end

@implementation PQKeyboardManagerView

- (void)didMoveToSuperview {
    self.dismissKeyboardOnTap = YES;
    
    // Register the scrollview to observe the text field notifications
    [self registerForKeyboardNotifications];

    // Register the scrollview to observe the keyboard notifications
    [self registerForTextFieldNotifications];
}

- (void)setDismissKeyboardOnTap:(BOOL)dismissKeyboardOnTap {
    if (_dismissKeyboardOnTap != dismissKeyboardOnTap) {
        // update the dismiss flag and add/remove the tap gesture accordingly
        _dismissKeyboardOnTap = dismissKeyboardOnTap;

        if (_dismissKeyboardOnTap) {
            self.tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
            [self addGestureRecognizer:self.tap];
        } else {
            [self removeGestureRecognizer:self.tap];
            self.tap = nil;
        }
    }
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
    // get the current active text field
    UITextField *tf = notification.object;
    if ([tf isDescendantOfView:self]) {
        // listen only children UITextFields
        self.activeField = notification.object;
    }
}

- (void)textFieldDidEndEditingNotification:(NSNotification *)notification
{
    UITextField *tf = notification.object;
    if ([tf isDescendantOfView:self]) {
        // reset the active text field
        self.activeField = nil;
    }
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

- (void)keyboardWasShown:(NSNotification*)aNotification
{
    if (self.activeField) {
        // Retrieve the keyboard size
        NSDictionary *info = [aNotification userInfo];
        CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
        
        // Assign to the contentInset the keyboard height
        UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height, 0.0);
        self.contentInset = contentInsets;
        self.scrollIndicatorInsets = contentInsets;
        
        // If active text field is hidden by keyboard, scroll it so it's visible
        CGRect aRect = self.superview.frame;
        aRect.size.height -= kbSize.height;
        if (!CGRectContainsPoint(aRect, self.activeField.frame.origin) ) {
            [self scrollRectToVisible:self.activeField.frame animated:YES];
        }
    }
}

- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    if (self.activeField) {
        // Revert contentInset to the initial value
        UIEdgeInsets contentInsets = UIEdgeInsetsZero;
        self.contentInset = contentInsets;
        self.scrollIndicatorInsets = contentInsets;
    }
}

@end

//
//  ATFeedbackWindowController.m
//  ApptentiveConnect
//
//  Created by Andrew Wooster on 6/1/11.
//  Copyright 2011 Apptentive, Inc. All rights reserved.
//

#import "ATFeedbackWindowController.h"
#import "ATConnect.h"
#import "ATContactStorage.h"
#import <AddressBook/AddressBook.h>

@interface ATFeedbackWindowController (Private)
- (void)setup;
- (void)teardown;
- (void)fillInContactInfo;
@end


@implementation ATFeedbackWindowController
- (id)init {
    NSBundle *bundle = [ATConnect resourceBundle];
    NSString *path = [bundle pathForResource:@"ATFeedbackWindow" ofType:@"nib"];
    if ((self = [super initWithWindowNibPath:path owner:self])) {
        
    }
    return self;
}

- (void)dealloc {
    //!!
    NSLog(@"window dealloc'd properly");
    [self teardown];
    [super dealloc];
}

- (void)windowDidLoad {
    [super windowDidLoad];
    [self setup];
}

#pragma mark Actions
- (IBAction)cancelPressed:(id)sender {
    [self close];
}

- (IBAction)sendFeedbackPressed:(id)sender {
}

#pragma mark NSWindowDelegate
- (void)windowWillClose:(NSNotification *)notification {
    [self teardown];
}
@end


@implementation ATFeedbackWindowController (Private)
- (void)setup {
    self.window.delegate = self;
    [self.window center];
    [self.window setTitle:NSLocalizedString(@"Submit Feedback", @"Feedback window title.")];
    [self fillInContactInfo];
}

- (void)teardown {
    
}

- (void)fillInContactInfo {
    ATContactStorage *contactStorage = [ATContactStorage sharedContactStorage];
    NSMutableArray *names = [NSMutableArray array];
    NSMutableArray *emails = [NSMutableArray array];
    NSMutableArray *phoneNumbers = [NSMutableArray array];
    
    if (contactStorage.name) {
        [names addObject:contactStorage.name];
    }
    if (contactStorage.email) {
        [emails addObject:contactStorage.email];
    }
    if (contactStorage.phone) {
        [phoneNumbers addObject:contactStorage.phone];
    }
    
    ABPerson *me = [[ABAddressBook sharedAddressBook] me];
    if (me) {
        NSString *firstName = [me valueForProperty:kABFirstNameProperty];
        NSString *middleName = [me valueForProperty:kABMiddleNameProperty];
        NSString *lastName = [me valueForProperty:kABLastNameProperty];
        NSMutableArray *nameParts = [NSMutableArray array];
        if (firstName) {
            [nameParts addObject:firstName];
        }
        if (middleName) {
            [nameParts addObject:middleName];
        }
        if (lastName) {
            [nameParts addObject:lastName];
        }
        if ([nameParts count]) {
            NSString *newName = [nameParts componentsJoinedByString:@" "];
            if (contactStorage.name == nil || ![contactStorage.name isEqualToString:newName]) {
                [names addObject:newName];
            }
        }
        
        
        ABMultiValue *abEmails = [me valueForProperty:kABEmailProperty];
        if (abEmails && [abEmails count]) {
            for (int i = 0; i < [abEmails count]; i++) {
                NSString *abEmail = [abEmails valueAtIndex:i];
                if (contactStorage.email == nil || ![contactStorage.email isEqualToString:abEmail]) {
                    [emails addObject:abEmail];
                }
            }
        }
        ABMultiValue *abPhoneNumbers = [me valueForProperty:kABPhoneProperty];
        if (abPhoneNumbers && [abPhoneNumbers count]) {
            for (int i = 0; i < [abPhoneNumbers count]; i++) {
                NSString *abPhoneNumber = [abPhoneNumbers valueAtIndex:i];
                if (contactStorage.phone == nil || ![contactStorage.phone isEqualToString:abPhoneNumber]) {
                    [phoneNumbers addObject:abPhoneNumber];
                }
            }
        }
    }
    if (nameBox && [names count]) {
        [nameBox addItemsWithObjectValues:names];
        [nameBox selectItemAtIndex:0];
    }
    if (emailBox && [emails count]) {
        [emailBox addItemsWithObjectValues:emails];
        [emailBox selectItemAtIndex:0];
    }
    if (phoneNumberBox && [phoneNumbers count]) {
        [phoneNumberBox addItemsWithObjectValues:phoneNumbers];
        [phoneNumberBox selectItemAtIndex:0];
    }
}
@end

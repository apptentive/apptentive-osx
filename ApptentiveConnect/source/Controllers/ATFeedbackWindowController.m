//
//  ATFeedbackWindowController.m
//  ApptentiveConnect
//
//  Created by Andrew Wooster on 6/1/11.
//  Copyright 2011 Apptentive, Inc. All rights reserved.
//

#import "ATFeedbackWindowController.h"
#import "ATBackend.h"
#import "ATConnect.h"
#import "ATContactStorage.h"
#import "ATImageView.h"
#import "ATConnect_FeedbackWindowPrivate.h"
#import "ATUtilities.h"
#import <AddressBook/AddressBook.h>

@interface ATFeedbackWindowController (Private)
- (void)setup;
- (void)teardown;
/*! Fills in the contact information. */
- (void)fillInContactInfo;
/*! Returns the text view for the current feedback type. */
- (NSTextView *)currentTextView;
/*! Takes text from current text view and puts in feedback. */
- (void)updateFeedbackWithText;
/*! Takes text from feedback and puts in current text view. */
- (void)updateTextWithFeedback;
- (void)setScreenshotToFilename:(NSString *)filename;
- (void)imageChanged:(NSNotification *)notification;
@end


@implementation ATFeedbackWindowController
@synthesize feedback;
- (id)initWithFeedback:(ATFeedback *)newFeedback {
    NSBundle *bundle = [ATConnect resourceBundle];
    NSString *path = [bundle pathForResource:@"ATFeedbackWindow" ofType:@"nib"];
    if ((self = [super initWithWindowNibPath:path owner:self])) {
        self.feedback = newFeedback;
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

- (void)setFeedbackType:(ATFeedbackType)feedbackType {
    self.feedback.type = feedbackType;
    if (feedbackType == ATFeedbackTypeFeedback) {
        [topTabView selectTabViewItemWithIdentifier:@"feedback"];
    } else if (feedbackType == ATFeedbackTypeQuestion) {
        [topTabView selectTabViewItemWithIdentifier:@"question"];
    } else if (feedbackType == ATFeedbackTypeBug) {
        [topTabView selectTabViewItemWithIdentifier:@"bug"];
    } else {
        // Default to feedback, for now.
        [topTabView selectTabViewItemWithIdentifier:@"feedback"];
    }
}

#pragma mark Actions
- (IBAction)browseForScreenshotPressed:(id)sender {
    NSOpenPanel *openPanel = [NSOpenPanel openPanel];
    [openPanel setCanChooseFiles:YES];
    [openPanel setCanCreateDirectories:NO];
    [openPanel setAllowsMultipleSelection:NO];
    [openPanel setAllowedFileTypes:[NSArray arrayWithObjects:@"jpg", @"jpeg", @"png", @"gif", @"bmp", nil]];
    if ([openPanel runModal] == NSOKButton) {
		NSArray *URLs = [openPanel URLs];
        for (NSURL *URL in URLs) {
            [self setScreenshotToFilename:[URL path]];
        }
    }
}

- (IBAction)cancelPressed:(id)sender {
    [self close];
}

- (IBAction)sendFeedbackPressed:(id)sender {
    @synchronized(self) {
        if (!feedbackRequest) {
            [progressIndicator setHidden:NO];
            [progressIndicator startAnimation:self];
            [progressIndicator setDoubleValue:0.01];
            feedbackRequest = [[[ATBackend sharedBackend] requestForSendingFeedback:self.feedback] retain];
            feedbackRequest.delegate = self;
            [feedbackRequest start];
            [sendButton setEnabled:NO];
        }
    }
}


- (IBAction)openApptentivePressed:(id)sender {
    [[NSWorkspace sharedWorkspace] openURL:[[ATBackend sharedBackend] apptentiveHomepageURL]];
}

#pragma mark ATAPIRequestDelegate
- (void)at_APIRequestDidFinish:(ATAPIRequest *)request result:(id)result {
    @synchronized(self) {
        feedbackRequest.delegate = nil;
        [feedbackRequest release];
        feedbackRequest = nil;
        [progressIndicator setDoubleValue:1.0];
        [progressIndicator stopAnimation:self];
        [progressIndicator setHidden:YES];
        
        NSAlert *alert = [[[NSAlert alloc] init] autorelease];
        [alert addButtonWithTitle:ATLocalizedString(@"Okay", @"Successful feedback button title.")];
        [alert setMessageText:ATLocalizedString(@"Thanks! Your feedback has been sent successfully.", @"Succesful feedback message.")];
        [alert setAlertStyle:NSInformationalAlertStyle];
        [alert beginSheetModalForWindow:self.window modalDelegate:self didEndSelector:@selector(thanksSheetDidClose:returnCode:contextInfo:) contextInfo:nil];
    }
}

- (void)at_APIRequestDidProgress:(ATAPIRequest *)request {
    @synchronized(self) {
        [progressIndicator setDoubleValue:(double)[request percentageComplete]];
    }
}

- (void)at_APIRequestDidFail:(ATAPIRequest *)request {
    //!!
    [sendButton setEnabled:YES];
    [progressIndicator stopAnimation:self];
    [progressIndicator setHidden:YES];
    
    NSAlert *alert = [[[NSAlert alloc] init] autorelease];
    [alert addButtonWithTitle:@"Try Again"];
    [alert addButtonWithTitle:@"Cancel"];
    [alert setMessageText:request.errorTitle];
    [alert setInformativeText:request.errorMessage];
    [alert setAlertStyle:NSWarningAlertStyle];
    [alert setIcon:[NSImage imageNamed:NSImageNameCaution]];
    [alert beginSheetModalForWindow:self.window modalDelegate:self didEndSelector:@selector(alertDidEnd:returnCode:contextInfo:) contextInfo:nil];
    feedbackRequest.delegate = nil;
    [feedbackRequest release];
    feedbackRequest = nil;
}

- (void)alertDidEnd:(NSWindow *)sheet returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo {
    if (returnCode == NSAlertFirstButtonReturn) {
        [self sendFeedbackPressed:self];
    } else if (returnCode == NSAlertSecondButtonReturn) {
        [self close];
    }
}

- (void)thanksSheetDidClose:(NSWindow *)sheet returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo {
    [[ATBackend sharedBackend] setCurrentFeedback:nil];
    [self performSelectorOnMainThread:@selector(close) withObject:nil waitUntilDone:NO];
}

#pragma mark NSWindowDelegate
- (void)windowWillClose:(NSNotification *)notification {
    [self teardown];
}
         
#pragma mark NSTabViewDelegate
- (void)tabView:(NSTabView *)tabView didSelectTabViewItem:(NSTabViewItem *)tabViewItem {
    [self updateFeedbackWithText];
    if ([[tabViewItem identifier] isEqualToString:@"question"]) {
        self.feedback.type = ATFeedbackTypeQuestion;
    } else if ([[tabViewItem identifier] isEqualToString:@"bug"]) {
        self.feedback.type = ATFeedbackTypeBug;
    } else {
        self.feedback.type = ATFeedbackTypeFeedback;
    }
    [self updateTextWithFeedback];
}

#pragma mark NSComboBoxDelegate
- (void)comboBoxSelectionDidChange:(NSNotification *)notification {
    NSComboBox *sender = (NSComboBox *)[notification object];
    if (sender) {
        NSString *value = (NSString *)[sender itemObjectValueAtIndex:[sender indexOfSelectedItem]];
        if (value) {
            if (sender == emailBox) {
                self.feedback.email = value;
            } else if (sender == phoneNumberBox) {
                self.feedback.phone = value;
            } else if (sender == nameBox) {
                self.feedback.name = value;
            }
        }
    }
}

#pragma mark NSTextViewDelegate
- (void)controlTextDidChange:(NSNotification *)aNotification {
    NSControl *sender = (NSControl *)[aNotification object];
    if (sender && [sender isKindOfClass:[NSComboBox class]]) {
        NSString *value = [sender stringValue];
        if (value) {
            if (sender == emailBox) {
                self.feedback.email = value;
            } else if (sender == phoneNumberBox) {
                self.feedback.phone = value;
            } else if (sender == nameBox) {
                self.feedback.name = value;
            }
        }
    }
}
@end


@implementation ATFeedbackWindowController (Private)
- (void)setup {
    self.window.delegate = self;
    [self.window center];
    [self.window setTitle:NSLocalizedString(@"Submit Feedback", @"Feedback window title.")];
    [self fillInContactInfo];
    [self updateTextWithFeedback];
    [self setFeedbackType:self.feedback.type];
    if (self.feedback.screenshot) {
        screenshotView.image = self.feedback.screenshot;
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(imageChanged:) name:ATImageViewContentsChanged object:nil];
    [logoImageView setImage:[ATBackend imageNamed:@"at_logo_info"]];
    [logoImageView setTarget:self];
    [logoImageView setAction:@selector(openApptentivePressed:)];
}

- (void)teardown {
    [self updateFeedbackWithText];
    [[ATConnect sharedConnection] feedbackWindowDidClose:self];
    self.feedback = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:ATImageViewContentsChanged object:nil];
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
    
    if (self.feedback.name) {
        [names addObject:self.feedback.name];
    }
    if (self.feedback.email) {
        [emails addObject:self.feedback.email];
    }
    if (self.feedback.phone) {
        [phoneNumbers addObject:self.feedback.phone];
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
    [ATUtilities uniquifyArray:names];
    [ATUtilities uniquifyArray:emails];
    [ATUtilities uniquifyArray:phoneNumbers];
    
    
    if (nameBox && [names count]) {
        [nameBox addItemsWithObjectValues:names];
        if (self.feedback.name && [names containsObject:self.feedback.name]) {
            [nameBox selectItemAtIndex:[names indexOfObject:self.feedback.name]];
        } else {
            [nameBox selectItemAtIndex:0];
        }
    }
    if (emailBox && [emails count]) {
        [emailBox addItemsWithObjectValues:emails];
        if (self.feedback.email && [emails containsObject:self.feedback.email]) {
            [emailBox selectItemAtIndex:[emails indexOfObject:self.feedback.email]];
        } else {
            [emailBox selectItemAtIndex:0];
        }
    }
    if (phoneNumberBox && [phoneNumbers count]) {
        [phoneNumberBox addItemsWithObjectValues:phoneNumbers];
        if (self.feedback.phone && [phoneNumbers containsObject:self.feedback.phone]) {
            [phoneNumberBox selectItemAtIndex:[phoneNumbers indexOfObject:self.feedback.phone]];
        } else {
            [phoneNumberBox selectItemAtIndex:0];
        }
    }
}

- (NSTextView *)currentTextView {
    NSTextView *result = nil;
    if (self.feedback.type == ATFeedbackTypeFeedback) {
        result = feedbackTextView;
    } else if (self.feedback.type == ATFeedbackTypeQuestion) {
        result = questionTextView;
    } else if (self.feedback.type == ATFeedbackTypeBug) {
        result = bugTextView;
    } else {
        result = feedbackTextView;
    }
    return result;
}

- (void)updateFeedbackWithText {
    NSString *text = [[[self currentTextView] textStorage] string];
    self.feedback.text = text;
}

- (void)updateTextWithFeedback {
    NSTextView *currentTextView = [self currentTextView];
    NSRange range = NSMakeRange(0, [[currentTextView textStorage] length]);
    NSString *replacement = self.feedback.text ? self.feedback.text : @"";
    [[currentTextView textStorage] replaceCharactersInRange:range withString:replacement];
}

- (void)setScreenshotToFilename:(NSString *)filename {
    NSImage *image = [[NSImage alloc] initWithContentsOfFile:filename];
    if (image) {
        self.feedback.screenshot = image;
        [screenshotView setImage:image];
    }
    [image release];
}

- (void)imageChanged:(NSNotification *)notification {
    NSObject *obj = [notification object];
    if (obj == screenshotView) {
        if ([screenshotView image] != self.feedback.screenshot) {
            self.feedback.screenshot = [screenshotView image];
        }
    }
}
@end

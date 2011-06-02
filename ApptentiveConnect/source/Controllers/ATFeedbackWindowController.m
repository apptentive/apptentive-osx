//
//  ATFeedbackWindowController.m
//  ApptentiveConnect
//
//  Created by Andrew Wooster on 6/1/11.
//  Copyright 2011 Apptentive, Inc. All rights reserved.
//

#import "ATFeedbackWindowController.h"
#import "ATConnect.h"

@implementation ATFeedbackWindowController
- (id)init {
    NSBundle *bundle = [ATConnect resourceBundle];
    NSString *path = [bundle pathForResource:@"ATFeedbackWindow" ofType:@"nib"];
    if ((self = [super initWithWindowNibPath:path owner:self])) {
        
    }
    return self;
}

- (void)windowDidLoad {
    [super windowDidLoad];
    [self.window setTitle:NSLocalizedString(@"Submit Feedback", @"Feedback window title.")];
}
@end

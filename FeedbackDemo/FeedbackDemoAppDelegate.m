//
//  FeedbackDemoAppDelegate.m
//  FeedbackDemo
//
//  Created by Andrew Wooster on 5/30/11.
//  Copyright 2011 Planetary Scale LLC. All rights reserved.
//

#import "FeedbackDemoAppDelegate.h"
#import <ApptentiveConnect/ATConnect.h>
#import "defines.h"

@implementation FeedbackDemoAppDelegate

@synthesize window;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	// Insert code here to initialize your application 
    [[ATConnect sharedConnection] setApiKey:kApptentiveAPIKey];
}

- (IBAction)showFeedbackWindow:(id)sender {
    [[ATConnect sharedConnection] showFeedbackWindow:sender];
}

- (IBAction)showFeedbackWindowForFeedback:(id)sender {
    [[ATConnect sharedConnection] showFeedbackWindowForFeedback:sender];
}

- (IBAction)showFeedbackWindowForQuestion:(id)sender {
    [[ATConnect sharedConnection] showFeedbackWindowForQuestion:sender];
}

- (IBAction)showFeedbackWindowForBugReport:(id)sender {
    [[ATConnect sharedConnection] showFeedbackWindowForBugReport:sender];
}
@end

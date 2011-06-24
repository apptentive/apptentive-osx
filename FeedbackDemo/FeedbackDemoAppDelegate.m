//
//  FeedbackDemoAppDelegate.m
//  FeedbackDemo
//
//  Created by Andrew Wooster on 5/30/11.
//  Copyright 2011 Planetary Scale LLC. All rights reserved.
//

#import "FeedbackDemoAppDelegate.h"
#import <ApptentiveConnect/ATConnect.h>

@implementation FeedbackDemoAppDelegate

@synthesize window;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	// Insert code here to initialize your application 
}

- (IBAction)showFeedbackWindow:(id)sender {
    [[ATConnect sharedConnection] showFeedbackWindow:sender];
}

- (ATConnect *)apptentiveConnection {
    return [ATConnect sharedConnection];
}
@end

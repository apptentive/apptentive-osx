//
//  FeedbackDemoAppDelegate.h
//  FeedbackDemo
//
//  Created by Andrew Wooster on 5/30/11.
//  Copyright 2011 Planetary Scale LLC. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <ApptentiveConnect/ATConnect.h>

@interface FeedbackDemoAppDelegate : NSObject <NSApplicationDelegate> {
    NSWindow *window;
}

@property (assign) IBOutlet NSWindow *window;
- (IBAction)showFeedbackWindow:(id)sender;
- (IBAction)showFeedbackWindowForFeedback:(id)sender;
- (IBAction)showFeedbackWindowForQuestion:(id)sender;
- (IBAction)showFeedbackWindowForBugReport:(id)sender;
@end

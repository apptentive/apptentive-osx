//
//  ATFeedbackWindowController.h
//  ApptentiveConnect
//
//  Created by Andrew Wooster on 6/1/11.
//  Copyright 2011 Apptentive, Inc. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface ATFeedbackWindowController : NSWindowController <NSWindowDelegate> {
    IBOutlet NSTabView *topTabView;
    IBOutlet NSView *sendFeedbackView;
    IBOutlet NSView *askQuestionView;
    IBOutlet NSProgressIndicator *progressIndicator;
    IBOutlet NSComboBox *nameBox;
    IBOutlet NSComboBox *emailBox;
    IBOutlet NSComboBox *phoneNumberBox;
}
- (id)init;
- (IBAction)cancelPressed:(id)sender;
- (IBAction)sendFeedbackPressed:(id)sender;
@end

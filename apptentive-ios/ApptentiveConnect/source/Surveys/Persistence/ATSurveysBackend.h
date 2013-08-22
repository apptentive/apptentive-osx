//
//  ATSurveysBackend.h
//  ApptentiveSurveys
//
//  Created by Andrew Wooster on 11/4/11.
//  Copyright (c) 2011 Apptentive. All rights reserved.
//

#if TARGET_OS_IPHONE
#import <UIKit/UIKit.h>
#elif TARGET_OS_MAC
#import <Cocoa/Cocoa.h>
#endif

@class ATSurvey;

@interface ATSurveysBackend : NSObject {
@private
	NSMutableArray *availableSurveys;
	ATSurvey *currentSurvey;
}
+ (ATSurveysBackend *)sharedBackend;
- (void)checkForAvailableSurveys;
- (ATSurvey *)currentSurvey;
- (void)resetSurvey;
#if TARGET_OS_IPHONE
- (void)presentSurveyControllerWithNoTagsFromViewController:(UIViewController *)viewController;
- (void)presentSurveyControllerWithTags:(NSSet *)tags fromViewController:(UIViewController *)viewController;
#elif TARGET_OS_MAC
#	warning Unimplemented
#endif
- (void)setDidSendSurvey:(ATSurvey *)survey;
- (BOOL)hasSurveyAvailableWithNoTags;
- (BOOL)hasSurveyAvailableWithTags:(NSSet *)tags;
@end


@interface ATSurveysBackend (Private)
- (BOOL)surveyAlreadySubmitted:(ATSurvey *)survey;
- (void)didReceiveNewSurveys:(NSArray *)surveys maxAge:(NSTimeInterval)expiresMaxAge;
@end

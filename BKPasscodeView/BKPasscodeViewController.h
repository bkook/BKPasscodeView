//
//  BKPasscodeViewController.h
//  BKPasscodeViewDemo
//
//  Created by Byungkook Jang on 2014. 4. 20..
//  Copyright (c) 2014년 Byungkook Jang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BKPasscodeInputView.h"

typedef enum : NSUInteger {
    BKPasscodeViewControllerNewPasscodeType,
    BKPasscodeViewControllerChangePasscodeType,
    BKPasscodeViewControllerCheckPasscodeType
} BKPasscodeViewControllerType;

@protocol BKPasscodeViewControllerDelegate;

@interface BKPasscodeViewController : UIViewController <BKPasscodeInputViewDelegate>

@property (nonatomic, assign) id<BKPasscodeViewControllerDelegate> delegate;

@property (nonatomic) BKPasscodeViewControllerType      type;
@property (nonatomic) BKPasscodeInputViewPasscodeStyle  passcodeStyle;

/**
 * Customize passcode input view
 * You may override to customize passcode input view appearance.
 */
- (void)customizePasscodeInputView:(BKPasscodeInputView *)aPasscodeInputView;

@end

@protocol BKPasscodeViewControllerDelegate <NSObject>

/**
 * Tells the delegate that passcode is created or authenticated successfully.
 */
- (void)passcodeViewController:(BKPasscodeViewController *)aViewController didFinishWithPasscode:(NSString *)aPasscode;

/**
 * Ask the delegate to verify that a passcode is correct. Return YES if passcode is correct.
 */
- (BOOL)passcodeViewController:(BKPasscodeViewController *)aViewController shouldAuthenticatePasscode:(NSString *)aPasscode;

/**
 * Tells the delegate that user entered incorrect passcode. 
 * You should manage failed attempts yourself and it should be returned by -[BKPasscodeViewControllerDelegate passcodeViewControllerNumberOfFailedAttempts:] method.
 */
- (void)passcodeViewControllerDidFailAttempt:(BKPasscodeViewController *)aViewController;

/**
 * Ask the delegate that how many times incorrect passcode entered to display failed attempt count.
 */
- (NSUInteger)passcodeViewControllerNumberOfFailedAttempts:(BKPasscodeViewController *)aViewController;

/**
 * Ask the delegate that whether passcode view should lock or unlock.
 * If you return nil, passcode view will unlock otherwise it will lock until the date.
 */
- (NSDate *)passcodeViewControllerLockUntilDate:(BKPasscodeViewController *)aViewController;

@end
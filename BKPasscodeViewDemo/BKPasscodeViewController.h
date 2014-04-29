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

@end

@protocol BKPasscodeViewControllerDelegate <NSObject>

- (void)passcodeViewController:(BKPasscodeViewController *)aViewController didFinishWithPasscode:(NSString *)aPasscode;

- (BOOL)passcodeViewController:(BKPasscodeViewController *)aViewController shouldAuthenticatePasscode:(NSString *)aPasscode;

- (void)passcodeViewControllerDidFailAttempt:(BKPasscodeViewController *)aViewController;

- (NSUInteger)passcodeViewControllerNumberOfFailedAttempts:(BKPasscodeViewController *)aViewController;

- (NSDate *)passcodeViewControllerLockUntilDate:(BKPasscodeViewController *)aViewController;

@end
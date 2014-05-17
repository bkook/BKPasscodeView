//
//  BKPasscodeViewController.m
//  BKPasscodeViewDemo
//
//  Created by Byungkook Jang on 2014. 4. 20..
//  Copyright (c) 2014년 Byungkook Jang. All rights reserved.
//

#import "BKPasscodeViewController.h"
#import "BKShiftingPasscodeInputView.h"
#import "UIView+Shake.h"

typedef enum : NSUInteger {
    BKPasscodeViewControllerStateUnknown,
    BKPasscodeViewControllerStateCheckPassword,
    BKPasscodeViewControllerStateInputPassword,
    BKPasscodeViewControllerStateReinputPassword
} BKPasscodeViewControllerState;

#define kBKPasscodeOneMinuteInSeconds           (60)

@interface BKPasscodeViewController ()

@property (nonatomic, strong) BKShiftingPasscodeInputView   *shiftingPasscodeInputView;
@property (nonatomic) BKPasscodeViewControllerState         currentState;
@property (nonatomic, strong) NSString                      *oldPasscode;
@property (nonatomic, strong) NSString                      *changedPasscode;
@property (nonatomic, strong) NSTimer                       *lockStateUpdateTimer;
@property (nonatomic) CGFloat                               keyboardHeight;

@end

@implementation BKPasscodeViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // create view
        _shiftingPasscodeInputView = [[BKShiftingPasscodeInputView alloc] init];
        _shiftingPasscodeInputView.passcodeInputViewDelegate = self;
        _shiftingPasscodeInputView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        
        // init state
        _currentState = BKPasscodeViewControllerStateUnknown;
        
        // keyboard notifications
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveKeyboardWillShowNotification:) name:UIKeyboardWillShowNotification object:nil];
    }
    return self;
}

- (void)dealloc
{
    [self.lockStateUpdateTimer invalidate];
    self.lockStateUpdateTimer = nil;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.view setBackgroundColor:[UIColor colorWithRed:0.94 green:0.94 blue:0.96 alpha:1]];
    
    self.shiftingPasscodeInputView.frame = self.view.bounds;
    
    if (self.currentState == BKPasscodeViewControllerStateUnknown) {
        if (self.type == BKPasscodeViewControllerNewPasscodeType) {
            self.currentState = BKPasscodeViewControllerStateInputPassword;
        } else {
            self.currentState = BKPasscodeViewControllerStateCheckPassword;
        }
    }
    
    [self updatePasscodeInputViewTitle:self.shiftingPasscodeInputView.passcodeInputView];
    [self.view addSubview:self.shiftingPasscodeInputView];
    [self.shiftingPasscodeInputView becomeFirstResponder];
    
    [self lockIfNeeded];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    CGRect frame = self.view.bounds;
    
    if ([self respondsToSelector:@selector(topLayoutGuide)]) {
        
        CGFloat topBarOffset = [self.topLayoutGuide length];
        frame.origin.y += topBarOffset;
        frame.size.height -= (topBarOffset + self.keyboardHeight);
    }
    
    self.shiftingPasscodeInputView.frame = frame;
}

#pragma mark - Public methods

- (void)setPasscodeStyle:(BKPasscodeInputViewPasscodeStyle)passcodeStyle
{
    self.shiftingPasscodeInputView.passcodeInputView.passcodeStyle = passcodeStyle;
}

- (BKPasscodeInputViewPasscodeStyle)passcodeStyle
{
    return self.shiftingPasscodeInputView.passcodeInputView.passcodeStyle;
}

//- (void)lockWithTimeInterval:(NSTimeInterval)timeInterval
//{
//    NSDate *lockUntil = [NSDate dateWithTimeIntervalSinceNow:timeInterval];
//    
//    [self showLockMessageWithLockUntilDate:lockUntil];
//}

- (void)showLockMessageWithLockUntilDate:(NSDate *)lockUntil
{
    NSTimeInterval timeInterval = [lockUntil timeIntervalSinceNow];
    NSUInteger minutes = ceilf(timeInterval / 60.0f);
    
    BKPasscodeInputView *inputView = self.shiftingPasscodeInputView.passcodeInputView;
    inputView.enabled = NO;
    
    if (minutes == 1) {
        inputView.title = NSLocalizedStringFromTable(@"Try again in 1 minute", @"BKPasscodeView", @"1분 후에 다시 시도");
    } else {
        inputView.title = [NSString stringWithFormat:NSLocalizedStringFromTable(@"Try again in %d minutes", @"BKPasscodeView", @"%d분 후에 다시 시도"), minutes];
    }
    
    NSUInteger numberOfFailedAttempts = [self.delegate passcodeViewControllerNumberOfFailedAttempts:self];
    
    [self showFailedAttemptsCount:numberOfFailedAttempts inputView:inputView];
    
    if (self.lockStateUpdateTimer == nil) {
        
        NSTimeInterval delay = timeInterval + kBKPasscodeOneMinuteInSeconds - (kBKPasscodeOneMinuteInSeconds * (NSTimeInterval)minutes);
        
        self.lockStateUpdateTimer = [[NSTimer alloc] initWithFireDate:[NSDate dateWithTimeIntervalSinceNow:delay]
                                                             interval:60.f
                                                               target:self
                                                             selector:@selector(lockStateUpdateTimerFired:)
                                                             userInfo:nil
                                                              repeats:YES];
        
        [[NSRunLoop currentRunLoop] addTimer:self.lockStateUpdateTimer forMode:NSDefaultRunLoopMode];
    }
}

- (void)lockIfNeeded
{
    if (self.currentState != BKPasscodeViewControllerStateCheckPassword) {
        return;
    }
    
    if (NO == [self.delegate respondsToSelector:@selector(passcodeViewControllerLockUntilDate:)]) {
        return;
    }
    
    NSDate *lockUntil = [self.delegate passcodeViewControllerLockUntilDate:self];
    if (lockUntil == nil || [lockUntil timeIntervalSinceNow] < 0) {
        return;
    }
    
    [self showLockMessageWithLockUntilDate:lockUntil];
}

- (void)updateLockMessageOrUnlockIfNeeded
{
    if (self.currentState != BKPasscodeViewControllerStateCheckPassword) {
        return;
    }
    
    if (NO == [self.delegate respondsToSelector:@selector(passcodeViewControllerLockUntilDate:)]) {
        return;
    }
    
    BKPasscodeInputView *inputView = self.shiftingPasscodeInputView.passcodeInputView;
    
    NSDate *lockUntil = [self.delegate passcodeViewControllerLockUntilDate:self];

    if (lockUntil == nil || [lockUntil timeIntervalSinceNow] < 0) {
        
        // invalidate timer
        [self.lockStateUpdateTimer invalidate];
        self.lockStateUpdateTimer = nil;
        
        [self updatePasscodeInputViewTitle:inputView];
        
        inputView.enabled = YES;
        
    } else {
        [self showLockMessageWithLockUntilDate:lockUntil];
    }
}

- (void)lockStateUpdateTimerFired:(NSTimer *)timer
{
    [self updateLockMessageOrUnlockIfNeeded];
}
                                     
#pragma mark - Private methods

- (void)updatePasscodeInputViewTitle:(BKPasscodeInputView *)passcodeInputView
{
    switch (self.currentState) {
        case BKPasscodeViewControllerStateCheckPassword:
            if (self.type == BKPasscodeViewControllerChangePasscodeType) {
                passcodeInputView.title = NSLocalizedStringFromTable(@"Enter your old passcode", @"BKPasscodeView", @"기존 암호 입력");
            } else {
                passcodeInputView.title = NSLocalizedStringFromTable(@"Enter your passcode", @"BKPasscodeView", @"암호 입력");
            }
            break;
            
        case BKPasscodeViewControllerStateInputPassword:
            if (self.type == BKPasscodeViewControllerChangePasscodeType) {
                passcodeInputView.title = NSLocalizedStringFromTable(@"Enter your new passcode", @"BKPasscodeView", @"새로운 암호 입력");
            } else {
                passcodeInputView.title = NSLocalizedStringFromTable(@"Enter a passcode", @"BKPasscodeView", @"암호 입력");
            }
            break;
            
        case BKPasscodeViewControllerStateReinputPassword:
            passcodeInputView.title = NSLocalizedStringFromTable(@"Re-enter your passcode", @"BKPasscodeView", @"암호 재입력");
            break;
            
        default:
            break;
    }
}

- (void)showFailedAttemptsCount:(NSUInteger)failCount inputView:(BKPasscodeInputView *)aInputView
{
    if (failCount == 0) {
        aInputView.errorMessage = NSLocalizedStringFromTable(@"Invalid Passcode", @"BKPasscodeView", @"잘못된 암호");
    } else if (failCount == 1) {
        aInputView.errorMessage = NSLocalizedStringFromTable(@"1 Failed Passcode Attempt", @"BKPasscodeView", @"1번의 암호 입력 시도 실패");
    } else {
        aInputView.errorMessage = [NSString stringWithFormat:NSLocalizedStringFromTable(@"%d Failed Passcode Attempts", @"BKPasscodeView", @"%d번의 암호 입력 시도 실패"), failCount];
    }
}

#pragma mark - BKPasscodeInputViewDelegate

- (void)passcodeInputViewDidFinish:(BKPasscodeInputView *)aInputView
{
    NSString *passcode = aInputView.passcode;
    
    switch (self.currentState) {
        case BKPasscodeViewControllerStateCheckPassword:
        {
            if ([self.delegate respondsToSelector:@selector(passcodeViewController:shouldAuthenticatePasscode:)] &&
                [self.delegate passcodeViewController:self shouldAuthenticatePasscode:passcode])
            {
                if (self.type == BKPasscodeViewControllerChangePasscodeType) {
                    
                    self.oldPasscode = passcode;
                    self.currentState = BKPasscodeViewControllerStateInputPassword;
                    
                    [self.shiftingPasscodeInputView shiftPasscodeInputViewWithDirection:BKShiftingDirectionForward andConfigurationBlock:^(BKPasscodeInputView *inputView) {
                        [self updatePasscodeInputViewTitle:inputView];
                    }];
                    
                } else {
                    
                    [self.delegate passcodeViewController:self didFinishWithPasscode:passcode];
                    
                }

            } else {
                
                if ([self.delegate respondsToSelector:@selector(passcodeViewControllerDidFailAttempt:)]) {
                    [self.delegate passcodeViewControllerDidFailAttempt:self];
                }
                
                NSUInteger failCount = 0;

                if ([self.delegate respondsToSelector:@selector(passcodeViewControllerNumberOfFailedAttempts:)]) {
                    failCount = [self.delegate passcodeViewControllerNumberOfFailedAttempts:self];
                }

                [self showFailedAttemptsCount:failCount inputView:aInputView];
                
                // reset entered passcode
                aInputView.passcode = nil;
                
                // shake
                [aInputView.passcodeControl shake:5 withDelta:10 andSpeed:0.08f];
                
                // lock if needed
                if ([self.delegate respondsToSelector:@selector(passcodeViewControllerLockUntilDate:)]) {
                    NSDate *lockUntilDate = [self.delegate passcodeViewControllerLockUntilDate:self];
                    if (lockUntilDate != nil) {
                        [self showLockMessageWithLockUntilDate:lockUntilDate];
                    }
                }

            }
            break;
        }
        case BKPasscodeViewControllerStateInputPassword:
        {
            if (self.type == BKPasscodeViewControllerChangePasscodeType && [self.oldPasscode isEqualToString:passcode]) {
                
                aInputView.passcode = nil;
                aInputView.message = NSLocalizedStringFromTable(@"Enter a different passcode. Cannot re-use the same passcode.", @"BKPasscodeView", @"다른 암호를 입력하십시오. 동일한 암호를 다시 사용할 수 없습니다.");
                
            } else {
                
                self.changedPasscode = passcode;
                self.currentState = BKPasscodeViewControllerStateReinputPassword;
                
                [self.shiftingPasscodeInputView shiftPasscodeInputViewWithDirection:BKShiftingDirectionForward andConfigurationBlock:^(BKPasscodeInputView *inputView) {
                    [self updatePasscodeInputViewTitle:inputView];
                }];
                
            }
            
            break;
        }
        case BKPasscodeViewControllerStateReinputPassword:
        {
            if ([passcode isEqualToString:self.changedPasscode]) {
                
                [self.delegate passcodeViewController:self didFinishWithPasscode:passcode];
                
            } else {
                
                self.currentState = BKPasscodeViewControllerStateInputPassword;
                
                [self.shiftingPasscodeInputView shiftPasscodeInputViewWithDirection:BKShiftingDirectionBackward andConfigurationBlock:^(BKPasscodeInputView *inputView) {
                    [self updatePasscodeInputViewTitle:inputView];
                    inputView.message = NSLocalizedStringFromTable(@"Passcodes did not match.\nTry again.", @"BKPasscodeView", @"암호가 일치하지 않습니다.\n다시 시도하십시오.");
                }];
                
            }
            break;
        }
        default:
            break;
    }
}

#pragma mark - Notifications

- (void)didReceiveKeyboardWillShowNotification:(NSNotification *)notification
{
    CGRect keyboardRect = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    keyboardRect = [self.view convertRect:keyboardRect fromView:nil];
    
    self.keyboardHeight = keyboardRect.size.height;
    
    CGRect rect = self.view.bounds;
    rect.size.height -= keyboardRect.size.height;
    self.shiftingPasscodeInputView.frame = rect;
}

@end

//
//  BKShiftingPasscodeInputView.m
//  BKPasscodeViewDemo
//
//  Created by Byungkook Jang on 2014. 4. 21..
//  Copyright (c) 2014년 Byungkook Jang. All rights reserved.
//

#import "BKShiftingPasscodeInputView.h"

@interface BKShiftingPasscodeInputView ()

@property (nonatomic, strong) BKPasscodeInputView     *passcodeInputView;

@end

@implementation BKShiftingPasscodeInputView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self _initialize];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self _initialize];
    }
    return self;
}

- (void)_initialize
{
    self.passcodeInputView = [[BKPasscodeInputView alloc] initWithFrame:self.bounds];
    self.passcodeInputView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self addSubview:self.passcodeInputView];
}

- (void)setPasscodeInputViewDelegate:(id<BKPasscodeInputViewDelegate>)passcodeInputViewDelegate
{
    self.passcodeInputView.delegate = passcodeInputViewDelegate;
}

- (id<BKPasscodeInputViewDelegate>)passcodeInputViewDelegate
{
    return self.passcodeInputView.delegate;
}

- (void)shiftPasscodeInputViewWithDirection:(BKShiftingDirection)direction andConfigurationBlock:(void (^)(BKPasscodeInputView *inputView))configBlock
{
    BKPasscodeInputView *previousInputView = self.passcodeInputView;
    previousInputView.enabled = NO;
    
    CGRect nextFrame = self.bounds;
    
    switch (direction) {
        case BKShiftingDirectionForward:
            nextFrame.origin.x = CGRectGetWidth(self.bounds);
            break;
        case BKShiftingDirectionBackward:
            nextFrame.origin.x = -CGRectGetWidth(self.bounds);
            break;
    }
    
    self.passcodeInputView = [[BKPasscodeInputView alloc] initWithFrame:nextFrame];
    self.passcodeInputView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.passcodeInputView.passcodeStyle = previousInputView.passcodeStyle;
    self.passcodeInputView.delegate = previousInputView.delegate;
    
    if (configBlock) {
        configBlock(self.passcodeInputView);
    }
    
    [self addSubview:self.passcodeInputView];
    
    // start animation
    [UIView animateWithDuration:0.3f delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        
        switch (direction) {
            case BKShiftingDirectionForward:
                previousInputView.frame = CGRectOffset(previousInputView.frame, -CGRectGetWidth(self.bounds), 0);
                self.passcodeInputView.frame = CGRectOffset(self.passcodeInputView.frame, -CGRectGetWidth(self.bounds), 0);
                break;
            case BKShiftingDirectionBackward:
                previousInputView.frame = CGRectOffset(previousInputView.frame, CGRectGetWidth(self.bounds), 0);
                self.passcodeInputView.frame = CGRectOffset(self.passcodeInputView.frame, CGRectGetWidth(self.bounds), 0);
                break;
        }
        
    } completion:^(BOOL finished) {
        
        [self.passcodeInputView becomeFirstResponder];
        
        [previousInputView removeFromSuperview];
        
    }];
}

- (BOOL)canBecomeFirstResponder
{
    return [self.passcodeInputView canBecomeFirstResponder];
}

- (BOOL)becomeFirstResponder
{
    return [self.passcodeInputView becomeFirstResponder];
}

@end

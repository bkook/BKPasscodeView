//
//  BKPasscodeInputView.h
//  BKPasscodeViewDemo
//
//  Created by Byungkook Jang on 2014. 4. 20..
//  Copyright (c) 2014년 Byungkook Jang. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "BKPasscodeField.h"

typedef enum : NSUInteger {
    BKPasscodeInputViewNumericPasscodeStyle,
    BKPasscodeInputViewNormalPasscodeStyle,
} BKPasscodeInputViewPasscodeStyle;


@protocol BKPasscodeInputViewDelegate;


@interface BKPasscodeInputView : UIView <UITextFieldDelegate, BKPasscodeFieldDelegate>

@property (nonatomic, assign) id<BKPasscodeInputViewDelegate> delegate;

@property (nonatomic) BKPasscodeInputViewPasscodeStyle  passcodeStyle;
@property (nonatomic) NSUInteger                        maximumLength;

@property (nonatomic, strong) NSString                  *title;
@property (nonatomic, strong) NSString                  *message;
@property (nonatomic, strong) NSString                  *errorMessage;
@property (nonatomic, getter = isEnabled) BOOL          enabled;
@property (nonatomic, strong) NSString                  *passcode;

@property (nonatomic, strong, readonly) UIControl       *passcodeControl;

+ (void)configureTitleLabel:(UILabel *)aLabel;
+ (void)configureMessageLabel:(UILabel *)aLabel;
+ (void)configureErrorMessageLabel:(UILabel *)aLabel;

@end


@protocol BKPasscodeInputViewDelegate <NSObject>

- (void)passcodeInputViewDidFinish:(BKPasscodeInputView *)aInputView;

@end
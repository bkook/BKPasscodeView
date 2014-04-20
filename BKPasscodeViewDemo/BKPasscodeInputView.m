//
//  BKPasscodeInputView.m
//  BKPasscodeViewDemo
//
//  Created by Byungkook Jang on 2014. 4. 20..
//  Copyright (c) 2014년 Byungkook Jang. All rights reserved.
//

#import "BKPasscodeInputView.h"

#import "BKPasscodeField.h"

#define kLabelPasscodeSpacePortrait         (30.0f)
#define kLabelPasscodeSpaceLandscape        (10.0f)

#define kTextLeftRightSpace                 (20.0f)

#define kErrorMessageLeftRightPadding       (10.0f)
#define kErrorMessageTopBottomPadding       (5.0f)

@interface BKPasscodeInputView ()

@property (nonatomic, strong) UILabel           *titleLabel;
@property (nonatomic, strong) UILabel           *messageLabel;
@property (nonatomic, strong) UILabel           *errorMessageLabel;
@property (nonatomic, strong) UIControl         *passcodeControl;

@end

@implementation BKPasscodeInputView

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self _initialize];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
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
    self.backgroundColor = [UIColor clearColor];
    
    _enabled = YES;
    
    _titleLabel = [[UILabel alloc] init];
    [[self class] configureTitleLabel:_titleLabel];
    [self addSubview:_titleLabel];
    
    [self setPasscodeStyle:BKPasscodeInputViewNumericPasscodeStyle];
    
    _messageLabel = [[UILabel alloc] init];
    [[self class] configureMessageLabel:_messageLabel];
    [self addSubview:_messageLabel];
    
    _errorMessageLabel = [[UILabel alloc] init];
    [[self class] configureErrorMessageLabel:_errorMessageLabel];
    _errorMessageLabel.hidden = YES;
    [self addSubview:_errorMessageLabel];
}

+ (void)configureTitleLabel:(UILabel *)aLabel
{
    aLabel.numberOfLines = 1;
    aLabel.textAlignment = NSTextAlignmentCenter;
    aLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    aLabel.font = [UIFont boldSystemFontOfSize:14.0f];
}

+ (void)configureMessageLabel:(UILabel *)aLabel
{
    aLabel.numberOfLines = 0;
    aLabel.textAlignment = NSTextAlignmentCenter;
    aLabel.lineBreakMode = NSLineBreakByWordWrapping;
    aLabel.font = [UIFont systemFontOfSize:14.0f];
}

+ (void)configureErrorMessageLabel:(UILabel *)aLabel
{
    aLabel.numberOfLines = 0;
    aLabel.textAlignment = NSTextAlignmentCenter;
    aLabel.lineBreakMode = NSLineBreakByWordWrapping;
    aLabel.backgroundColor = [UIColor colorWithRed:0.63 green:0.2 blue:0.13 alpha:1];
    aLabel.textColor = [UIColor whiteColor];
    aLabel.font = [UIFont systemFontOfSize:14.0f];
    
    aLabel.layer.cornerRadius = 10.0f;
    aLabel.layer.masksToBounds = YES;
}

- (void)setPasscodeStyle:(BKPasscodeInputViewPasscodeStyle)passcodeStyle
{
    _passcodeStyle = passcodeStyle;
    
    [self.passcodeControl removeFromSuperview];
    
    switch (passcodeStyle) {
        case BKPasscodeInputViewNumericPasscodeStyle:
        {
            self.passcodeControl = [[BKPasscodeField alloc] init];
            [self.passcodeControl sizeToFit];
            [self.passcodeControl addTarget:self action:@selector(passcodeControlEditingChanged:) forControlEvents:UIControlEventEditingChanged];
            break;
        }
            
        case BKPasscodeInputViewNormalPasscodeStyle:
        {
            UITextField *textField = [[UITextField alloc] init];
            textField.delegate = self;
            textField.borderStyle = UITextBorderStyleRoundedRect;
            textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
            textField.autocorrectionType = UITextAutocorrectionTypeNo;
            textField.spellCheckingType = UITextSpellCheckingTypeNo;
            textField.enablesReturnKeyAutomatically = YES;
            textField.keyboardType = UIKeyboardTypeASCIICapable;
            textField.secureTextEntry = YES;
            textField.font = [UIFont systemFontOfSize:20.0f];
            textField.clearButtonMode = UITextFieldViewModeWhileEditing;
            [textField sizeToFit];
            textField.frame = CGRectMake(0, 0, self.frame.size.width - kTextLeftRightSpace * 2.0f, CGRectGetHeight(textField.frame) + 10.0f);
            self.passcodeControl = textField;
            break;
        }
    }
    
    [self addSubview:_passcodeControl];
}

- (void)setTitle:(NSString *)title
{
    self.titleLabel.text = title;
    [self setNeedsLayout];
}

- (NSString *)title
{
    return self.titleLabel.text;
}

- (void)setMessage:(NSString *)message
{
    self.messageLabel.text = message;
    self.messageLabel.hidden = NO;
    
    self.errorMessageLabel.text = nil;
    self.errorMessageLabel.hidden = YES;
    
    [self setNeedsLayout];
}

- (NSString *)message
{
    return self.messageLabel.text;
}

- (void)setErrorMessage:(NSString *)errorMessage
{
    self.errorMessageLabel.text = errorMessage;
    self.errorMessageLabel.hidden = NO;
    
    self.messageLabel.text = nil;
    self.messageLabel.hidden = YES;
    
    [self setNeedsLayout];
}

- (NSString *)errorMessage
{
    return self.errorMessageLabel.text;
}

- (void)setEnabled:(BOOL)enabled
{
    _enabled = enabled;
    
    if ([self.passcodeControl isKindOfClass:[BKPasscodeField class]]) {
        [self.passcodeControl setEnabled:enabled];
    }
}

- (NSString *)passcode
{
    switch (self.passcodeStyle) {
        case BKPasscodeInputViewNumericPasscodeStyle:
            return [(BKPasscodeField *)self.passcodeControl passcode];
        case BKPasscodeInputViewNormalPasscodeStyle:
            return [(UITextField *)self.passcodeControl text];
    }
}

#pragma mark - UIView

- (CGFloat)labelPasscodeSpace
{
    return UIInterfaceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation]) ? kLabelPasscodeSpacePortrait : kLabelPasscodeSpaceLandscape;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    // layout passcode control to center
    _passcodeControl.center = CGPointMake(CGRectGetWidth(self.frame) * 0.5f, CGRectGetHeight(self.frame) * 0.5f);
    
    CGFloat maxTextWidth = self.frame.size.width - (kTextLeftRightSpace * 2.0f);
    CGFloat labelPasscodeSpace = [self labelPasscodeSpace];
    
    // layout title label
    _titleLabel.frame = CGRectMake(kTextLeftRightSpace, 0, maxTextWidth, self.frame.size.height);
    [_titleLabel sizeToFit];
    
    CGRect rect = _titleLabel.frame;
    rect.origin.x = floorf((self.frame.size.width - CGRectGetWidth(rect)) * 0.5f);
    rect.origin.y = CGRectGetMinY(_passcodeControl.frame) - labelPasscodeSpace - CGRectGetHeight(_titleLabel.frame);

    _titleLabel.frame = rect;
    
    // layout message label
    if (!_messageLabel.hidden) {
        _messageLabel.frame = CGRectMake(kTextLeftRightSpace, CGRectGetMaxY(_passcodeControl.frame) + labelPasscodeSpace, maxTextWidth, self.frame.size.height);
        [_messageLabel sizeToFit];
        
        rect = _messageLabel.frame;
        rect.origin.x = floorf((self.frame.size.width - CGRectGetWidth(rect)) * 0.5f);
        _messageLabel.frame = rect;
    }
    
    // layout error message label
    if (!_errorMessageLabel.hidden) {
        _errorMessageLabel.frame = CGRectMake(0, CGRectGetMaxY(_passcodeControl.frame) + labelPasscodeSpace,
                                              maxTextWidth - kErrorMessageLeftRightPadding * 2.0f,
                                              self.frame.size.height);
        [_errorMessageLabel sizeToFit];
        
        rect = _errorMessageLabel.frame;
        rect.size.width += (kErrorMessageLeftRightPadding * 2.0f);
        rect.size.height += (kErrorMessageTopBottomPadding * 2.0f);
        rect.origin.x = floorf((self.frame.size.width - rect.size.width) * 0.5f);
        
        _errorMessageLabel.frame = rect;
    }
}

#pragma mark - UIResponder

- (BOOL)canBecomeFirstResponder
{
    return [self.passcodeControl canBecomeFirstResponder];
}

- (BOOL)becomeFirstResponder
{
    return [self.passcodeControl becomeFirstResponder];
}

- (BOOL)canResignFirstResponder
{
    return NO;
}

#pragma mark - Actions

- (void)passcodeControlEditingChanged:(id)sender
{
    if (![self.passcodeControl isKindOfClass:[BKPasscodeField class]]) {
        return;
    }
    
    BKPasscodeField *passcodeField = (BKPasscodeField *)self.passcodeControl;
    
    if (passcodeField.passcode.length == passcodeField.maximumLength) {
        if ([self.delegate respondsToSelector:@selector(passcodeInputViewDidFinish:)]) {
            [self.delegate passcodeInputViewDidFinish:self];
        }
    }
}

#pragma mark - UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (!self.isEnabled) {
        return NO;
    }
    
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if ([self.delegate respondsToSelector:@selector(passcodeInputViewDidFinish:)]) {
        [self.delegate passcodeInputViewDidFinish:self];
    }
    
    return NO;
}

@end

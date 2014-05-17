//
//  BKPasscodeInputView.m
//  BKPasscodeViewDemo
//
//  Created by Byungkook Jang on 2014. 4. 20..
//  Copyright (c) 2014년 Byungkook Jang. All rights reserved.
//

#import "BKPasscodeInputView.h"

#define kLabelPasscodeSpacePortrait         (30.0f)
#define kLabelPasscodeSpaceLandscape        (10.0f)

#define kTextLeftRightSpace                 (20.0f)

#define kErrorMessageLeftRightPadding       (10.0f)
#define kErrorMessageTopBottomPadding       (5.0f)

#define kDefaultNumericPasscodeMaximumLength        (4)
#define kDefaultNormalPasscodeMaximumLength         (20)

@interface BKPasscodeInputView ()

@property (nonatomic, strong) UILabel           *titleLabel;
@property (nonatomic, strong) UILabel           *messageLabel;
@property (nonatomic, strong) UILabel           *errorMessageLabel;
@property (nonatomic, strong) UIControl         *passcodeControl;

@end

@implementation BKPasscodeInputView

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
    aLabel.font = [UIFont boldSystemFontOfSize:15.0f];
}

+ (void)configureMessageLabel:(UILabel *)aLabel
{
    aLabel.numberOfLines = 0;
    aLabel.textAlignment = NSTextAlignmentCenter;
    aLabel.lineBreakMode = NSLineBreakByWordWrapping;
    aLabel.font = [UIFont systemFontOfSize:15.0f];
}

+ (void)configureErrorMessageLabel:(UILabel *)aLabel
{
    aLabel.numberOfLines = 0;
    aLabel.textAlignment = NSTextAlignmentCenter;
    aLabel.lineBreakMode = NSLineBreakByWordWrapping;
    aLabel.backgroundColor = [UIColor colorWithRed:0.63 green:0.2 blue:0.13 alpha:1];
    aLabel.textColor = [UIColor whiteColor];
    aLabel.font = [UIFont systemFontOfSize:15.0f];
    
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
            _maximumLength = kDefaultNumericPasscodeMaximumLength;
            
            BKPasscodeField *passcodeField = [[BKPasscodeField alloc] init];
            [passcodeField setDelegate:self];
            [passcodeField sizeToFit];
            [passcodeField addTarget:self action:@selector(passcodeControlEditingChanged:) forControlEvents:UIControlEventEditingChanged];
            [passcodeField setMaximumLength:self.maximumLength];
            [self setPasscodeControl:passcodeField];
            break;
        }
            
        case BKPasscodeInputViewNormalPasscodeStyle:
        {
            _maximumLength = kDefaultNormalPasscodeMaximumLength;
            
            UITextField *textField = [[UITextField alloc] init];
            textField.delegate = self;
            textField.borderStyle = UITextBorderStyleRoundedRect;
            textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
            textField.autocorrectionType = UITextAutocorrectionTypeNo;
            textField.spellCheckingType = UITextSpellCheckingTypeNo;
            textField.enablesReturnKeyAutomatically = YES;
            textField.keyboardType = UIKeyboardTypeASCIICapable;
            textField.secureTextEntry = YES;
            textField.font = [UIFont systemFontOfSize:25.0f];
            textField.clearButtonMode = UITextFieldViewModeWhileEditing;
            [self setPasscodeControl:textField];
            break;
        }
    }
    
    [self addSubview:_passcodeControl];
}

- (void)setMaximumLength:(NSUInteger)maximumLength
{
    _maximumLength = maximumLength;
    
    if ([self.passcodeControl isKindOfClass:[BKPasscodeField class]]) {
        [(BKPasscodeField *)self.passcodeControl setMaximumLength:maximumLength];
    }
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

- (NSString *)passcode
{
    switch (self.passcodeStyle) {
        case BKPasscodeInputViewNumericPasscodeStyle:
            return [(BKPasscodeField *)self.passcodeControl passcode];
        case BKPasscodeInputViewNormalPasscodeStyle:
            return [(UITextField *)self.passcodeControl text];
    }
}

- (void)setPasscode:(NSString *)passcode
{
    switch (self.passcodeStyle) {
        case BKPasscodeInputViewNumericPasscodeStyle:
            [(BKPasscodeField *)self.passcodeControl setPasscode:passcode];
            break;
        case BKPasscodeInputViewNormalPasscodeStyle:
             [(UITextField *)self.passcodeControl setText:passcode];
             break;
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
    if ([self.passcodeControl isKindOfClass:[UITextField class]]) {
        [self.passcodeControl sizeToFit];
        self.passcodeControl.frame = CGRectMake(0, 0, self.frame.size.width - kTextLeftRightSpace * 2.0f, CGRectGetHeight(self.passcodeControl.frame) + 10.0f);
    }

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

#pragma mark - BKPasscodeFieldDelegate

- (BOOL)passcodeField:(BKPasscodeField *)aPasscodeField shouldInsertText:(NSString *)aText
{
    return self.isEnabled;
}

- (BOOL)passcodeFieldShouldDeleteBackward:(BKPasscodeField *)aPasscodeField
{
    return self.isEnabled;
}

#pragma mark - UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (self.isEnabled == NO) {
        return NO;
    }
    
    NSUInteger length = textField.text.length - range.length + string.length;
    if (length > self.maximumLength) {
        return NO;
    }
    
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (self.isEnabled == NO) {
        return NO;
    }
    
    if ([self.delegate respondsToSelector:@selector(passcodeInputViewDidFinish:)]) {
        [self.delegate passcodeInputViewDidFinish:self];
        return NO;
    } else {
        return YES; // default behavior
    }
}

@end

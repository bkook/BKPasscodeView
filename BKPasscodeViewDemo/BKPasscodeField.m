//
//  BKPasscodeField.m
//  BKPasscodeViewDemo
//
//  Created by Byungkook Jang on 2014. 4. 20..
//  Copyright (c) 2014년 Byungkook Jang. All rights reserved.
//

#import "BKPasscodeField.h"

@interface BKPasscodeField ()

@property (strong, nonatomic) NSMutableString       *mutablePasscode;

@end

@implementation BKPasscodeField

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self _initialize];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self _initialize];
    }
    return self;
}

- (id)init
{
    self = [super init];
    if (self) {
        [self _initialize];
    }
    return self;
}

- (void)_initialize
{
    _maximumLength = 4;
    _dotSize = CGSizeMake(18.0f, 19.0f);
    _dotSpacing = 25.0f;
    _lineHeight = 3.0f;
    _dotColor = [UIColor blackColor];
    
    [self setBackgroundColor:[UIColor clearColor]];
    
    _mutablePasscode = [[NSMutableString alloc] initWithCapacity:4];
}

- (NSString *)passcode
{
    return self.mutablePasscode;
}

#pragma mark - UIKeyInput

- (BOOL)hasText
{
    return (self.mutablePasscode.length > 0);
}

- (void)insertText:(NSString *)text
{
    if (self.enabled == NO) {
        return;
    }
    
    if (self.mutablePasscode.length == self.maximumLength) {
        return;
    }
    
    [self.mutablePasscode appendString:text];
    
    [self setNeedsDisplay];
    
    [[UIDevice currentDevice] playInputClick];
    
    [self sendActionsForControlEvents:UIControlEventEditingChanged];
}

- (void)deleteBackward
{
    if (self.enabled == NO) {
        return;
    }
    
    if (self.mutablePasscode.length == 0) {
        return;
    }
    
    [self.mutablePasscode deleteCharactersInRange:NSMakeRange(self.mutablePasscode.length - 1, 1)];
    
    [self setNeedsDisplay];
    
    [[UIDevice currentDevice] playInputClick];
    
    [self sendActionsForControlEvents:UIControlEventEditingChanged];
}

- (UITextAutocapitalizationType)autocapitalizationType
{
    return UITextAutocapitalizationTypeNone;
}

- (UITextAutocorrectionType)autocorrectionType
{
    return UITextAutocorrectionTypeNo;
}

- (UITextSpellCheckingType)spellCheckingType
{
    return UITextSpellCheckingTypeNo;
}

- (BOOL)enablesReturnKeyAutomatically
{
    return YES;
}

- (UIKeyboardAppearance)keyboardAppearance
{
    return UIKeyboardAppearanceDefault;
}

- (UIKeyboardType)keyboardType
{
    return UIKeyboardTypeNumberPad;
}

- (UIReturnKeyType)returnKeyType
{
    return UIReturnKeyDone;
}

- (BOOL)isSecureTextEntry
{
    return YES;
}

#pragma mark - UIView

- (CGSize)contentSize
{
    return CGSizeMake(self.maximumLength * _dotSize.width + (self.maximumLength - 1) * _dotSpacing,
                      _dotSize.height);
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{
    CGSize contentSize = [self contentSize];
    
    CGPoint origin = CGPointMake(floorf((self.frame.size.width - contentSize.width) * 0.5f),
                                 floorf((self.frame.size.height - contentSize.height) * 0.5f));
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, self.dotColor.CGColor);
    
    for (NSUInteger i = 0; i < self.maximumLength; i++) {

        if (i < self.mutablePasscode.length) {
            // draw circle
            CGRect circleFrame = CGRectMake(origin.x, origin.y, self.dotSize.width, self.dotSize.height);
            CGContextFillEllipseInRect(context, circleFrame);
        } else {
            // draw line
            CGRect lineFrame = CGRectMake(origin.x, origin.y + floorf((self.dotSize.height - self.lineHeight) * 0.5f),
                                          self.dotSize.width, self.lineHeight);
            CGContextFillRect(context, lineFrame);
        }
        
        origin.x += (self.dotSize.width + self.dotSpacing);
    }
}

- (CGSize)sizeThatFits:(CGSize)size
{
    return [self contentSize];
}

#pragma mark - UIResponder

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (![self isFirstResponder]) {
        [self becomeFirstResponder];
    }
}

- (BOOL)canBecomeFirstResponder
{
    return YES;
}

#pragma mark - UIInputViewAudioFeedback

- (BOOL)enableInputClicksWhenVisible
{
    return YES;
}

@end

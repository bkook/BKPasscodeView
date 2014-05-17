//
//  BKPasscodeField.h
//  BKPasscodeViewDemo
//
//  Created by Byungkook Jang on 2014. 4. 20..
//  Copyright (c) 2014년 Byungkook Jang. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol BKPasscodeFieldDelegate;

@interface BKPasscodeField : UIControl <UIKeyInput, UIInputViewAudioFeedback>

// delegate
@property (nonatomic, assign) id<BKPasscodeFieldDelegate> delegate;

// passcode
@property (nonatomic, strong) NSString      *passcode;

// configurations
@property (nonatomic) NSUInteger            maximumLength;
@property (nonatomic) CGSize                dotSize;
@property (nonatomic) CGFloat           	lineHeight;
@property (nonatomic) CGFloat           	dotSpacing;
@property (nonatomic, strong) UIColor       *dotColor;

@end


@protocol BKPasscodeFieldDelegate <NSObject>

@optional
- (BOOL)passcodeField:(BKPasscodeField *)aPasscodeField shouldInsertText:(NSString *)aText;
- (BOOL)passcodeFieldShouldDeleteBackward:(BKPasscodeField *)aPasscodeField;

@end
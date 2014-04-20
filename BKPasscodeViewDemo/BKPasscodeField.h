//
//  BKPasscodeField.h
//  BKPasscodeViewDemo
//
//  Created by Byungkook Jang on 2014. 4. 20..
//  Copyright (c) 2014년 Byungkook Jang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BKPasscodeField : UIControl <UIKeyInput, UIInputViewAudioFeedback>

@property (nonatomic, readonly) NSString    *passcode;

// configurations
@property (nonatomic) NSUInteger            maximumLength;
@property (nonatomic) CGSize                dotSize;
@property (nonatomic) CGFloat           	lineHeight;
@property (nonatomic) CGFloat           	dotSpacing;
@property (nonatomic, strong) UIColor       *dotColor;

@end

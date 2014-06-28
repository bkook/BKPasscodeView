//
//  BKCustomPasscodeViewController.m
//  BKPasscodeViewDemo
//
//  Created by Byungkook Jang on 2014. 6. 28..
//  Copyright (c) 2014년 Byungkook Jang. All rights reserved.
//

#import "BKCustomPasscodeViewController.h"

@interface BKCustomPasscodeViewController ()

@end

@implementation BKCustomPasscodeViewController

- (void)customizePasscodeInputView:(BKPasscodeInputView *)aPasscodeInputView
{
    [super customizePasscodeInputView:aPasscodeInputView];
    
    if ([aPasscodeInputView.passcodeControl isKindOfClass:[BKPasscodeField class]]) {
        BKPasscodeField *passcodeField = (BKPasscodeField *)aPasscodeInputView.passcodeControl;
        passcodeField.imageSource = self;
        passcodeField.dotSize = CGSizeMake(32, 32);
    }
}

#pragma mark - BKPasscodeFieldImageSource

- (UIImage *)passcodeField:(BKPasscodeField *)aPasscodeField dotImageAtIndex:(NSInteger)aIndex filled:(BOOL)aFilled
{
    if (aFilled) {
        return [UIImage imageNamed:@"star_full"];
    } else {
        return [UIImage imageNamed:@"star_empty"];
    }
}

@end

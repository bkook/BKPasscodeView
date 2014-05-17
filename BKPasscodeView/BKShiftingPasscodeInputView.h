//
//  BKShiftingPasscodeInputView.h
//  BKPasscodeViewDemo
//
//  Created by Byungkook Jang on 2014. 4. 21..
//  Copyright (c) 2014년 Byungkook Jang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BKPasscodeInputView.h"

typedef enum : NSUInteger {
    BKShiftingDirectionForward,
    BKShiftingDirectionBackward
} BKShiftingDirection;

@interface BKShiftingPasscodeInputView : UIView

@property (nonatomic, strong, readonly) BKPasscodeInputView     *passcodeInputView;
@property (nonatomic, assign) id<BKPasscodeInputViewDelegate>   passcodeInputViewDelegate;

- (void)shiftPasscodeInputViewWithDirection:(BKShiftingDirection)direction andConfigurationBlock:(void (^)(BKPasscodeInputView *inputView))configBlock;

@end

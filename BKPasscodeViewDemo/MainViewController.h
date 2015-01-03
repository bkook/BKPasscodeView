//
//  MainViewController.h
//  BKPasscodeViewDemo
//
//  Created by Byungkook Jang on 2014. 4. 26..
//  Copyright (c) 2014년 Byungkook Jang. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "BKCustomPasscodeViewController.h"

@interface MainViewController : UITableViewController <BKPasscodeViewControllerDelegate>

@property (strong, nonatomic) UISwitch          *simplePasscodeSwitch;
@property (strong, nonatomic) UISwitch          *customizeAppearanceSwitch;
@property (strong, nonatomic) UISwitch          *lockWhenEnterBackgroundSwitch;
@property (strong, nonatomic) UISwitch          *authWithTouchIDFirstSwitch;

@property (strong, nonatomic) NSString          *passcode;
@property (nonatomic) NSUInteger                failedAttempts;
@property (strong, nonatomic) NSDate            *lockUntilDate;

@property (nonatomic) BOOL                      showingLockScreenManually;

@end

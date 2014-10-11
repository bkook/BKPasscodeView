//
//  AppDelegate.h
//  BKPasscodeViewDemo
//
//  Created by Byungkook Jang on 2014. 4. 20..
//  Copyright (c) 2014년 Byungkook Jang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BKPasscodeLockScreenManager.h"

extern NSString *const BKPasscodeKeychainServiceName;

@interface AppDelegate : UIResponder <UIApplicationDelegate, BKPasscodeLockScreenManagerDelegate>

@property (strong, nonatomic) UIWindow *window;

@end

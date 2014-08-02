//
//  BKPasscodeLockScreenManager.h
//  BKPasscodeViewDemo
//
//  Created by Byungkook Jang on 2014. 8. 2..
//  Copyright (c) 2014년 Byungkook Jang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BKPasscodeViewController.h"
#import "BKPasscodeDummyViewController.h"

@protocol BKPasscodeLockScreenManagerDelegate;


@interface BKPasscodeLockScreenManager : NSObject <BKPasscodeDummyViewControllerDelegate>

@property (assign, nonatomic) id<BKPasscodeLockScreenManagerDelegate> delegate;

@property (nonatomic, readonly, getter = isActivated) BOOL activated;

/**
 * Shared(singleton) instance.
 */
+ (BKPasscodeLockScreenManager *)sharedManager;

/**
 * Activates manager. If manager is activated, it shows lock screen when application entered background.
 */
- (void)activate;

/**
 * Deactivate manager. If manager is deactivated, lock screen will not shown at any time.
 */
- (void)deactivate;

/**
 * Shows lock screen immediately. Before show lock screen you must activate manager first.
 */
- (void)showLockScreenNow:(BOOL)animated;

@end


@protocol BKPasscodeLockScreenManagerDelegate <NSObject>

/**
 * Ask the delegate a view controller that should be displayed as lock screen.
 */
- (UIViewController *)lockScreenManagerPasscodeViewController:(BKPasscodeLockScreenManager *)aManager;

@optional
/**
 * Ask the delegate that lock screen should be displayed or not.
 * If you prevent displaying lock screen, return NO.
 * If delegate does not implement this method, the lock screen will be shown everytime when application did enter background.
 */
- (BOOL)lockScreenManagerShouldShowLockScreen:(BKPasscodeLockScreenManager *)aManager;

@end
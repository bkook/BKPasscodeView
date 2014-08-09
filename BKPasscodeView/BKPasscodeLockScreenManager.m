//
//  BKPasscodeLockScreenManager.m
//  BKPasscodeViewDemo
//
//  Created by Byungkook Jang on 2014. 8. 2..
//  Copyright (c) 2014년 Byungkook Jang. All rights reserved.
//

#import "BKPasscodeLockScreenManager.h"
#import "BKPasscodeViewController.h"

static BKPasscodeLockScreenManager *_sharedManager;

@interface BKPasscodeLockScreenManager ()

@property (strong, nonatomic) UIWindow  *mainWindow;
@property (strong, nonatomic) UIWindow  *lockScreenWindow;
@property (strong, nonatomic) UIView    *blindView;

@end

@implementation BKPasscodeLockScreenManager

+ (BKPasscodeLockScreenManager *)sharedManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [[BKPasscodeLockScreenManager alloc] init];
    });
    return _sharedManager;
}

- (void)showLockScreen:(BOOL)animated
{
    NSAssert(self.delegate, @"delegate is not assigned.");
    
    if (self.lockScreenWindow && self.lockScreenWindow.rootViewController) {
        return;
    }
    
    if ([self.delegate respondsToSelector:@selector(lockScreenManagerShouldShowLockScreen:)]) {
        if (NO == [self.delegate lockScreenManagerShouldShowLockScreen:self]) {
            return;
        }
    }
    
    // get the main window
    self.mainWindow = [[UIApplication sharedApplication] keyWindow];
    
    // add blind view
    UIView *blindView;
    
    if ([self.delegate respondsToSelector:@selector(lockScreenManagerBlindView:)]) {
        blindView = [self.delegate lockScreenManagerBlindView:self];
    }
    
    if (nil == self.blindView) {
        blindView = [[UIView alloc] init];
        blindView.backgroundColor = [UIColor whiteColor];
    }
    
    blindView.frame = self.mainWindow.bounds;
    blindView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    [self.mainWindow addSubview:blindView];
    
    self.blindView = blindView;
    
    // resign key window
    [self.mainWindow resignKeyWindow];
    
    // set dummy view controller as root view controller
    BKPasscodeDummyViewController *dummyViewController = [[BKPasscodeDummyViewController alloc] init];
    
    UIWindow *lockScreenWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    lockScreenWindow.windowLevel = self.mainWindow.windowLevel + 1;
    lockScreenWindow.rootViewController = dummyViewController;
    [lockScreenWindow makeKeyAndVisible];
    
    self.lockScreenWindow = lockScreenWindow;
    
    // present lock screen
    UIViewController *lockScreenViewController = [self.delegate lockScreenManagerPasscodeViewController:self];
    [self.lockScreenWindow.rootViewController presentViewController:lockScreenViewController animated:animated completion:nil];
    
    [lockScreenViewController.view.superview bringSubviewToFront:lockScreenViewController.view];
    
    dummyViewController.delegate = self;
}

- (void)dummyViewControllerWillAppear:(BKPasscodeDummyViewController *)aViewController
{
    // remove blind view
    [self.blindView removeFromSuperview];
    self.blindView = nil;
}

- (void)dummyViewControllerDidAppear:(BKPasscodeDummyViewController *)aViewController
{
    [self.lockScreenWindow resignKeyWindow];
    self.lockScreenWindow.hidden = YES;
    
    if ([UIView instancesRespondToSelector:@selector(tintColor)]) {
        self.lockScreenWindow = nil;
    } else {
        [self performSelector:@selector(setLockScreenWindow:) withObject:nil afterDelay:0.1f];      // workaround for wired dealloc on iOS 6
    }
    
    [self.mainWindow makeKeyAndVisible];
    self.mainWindow = nil;
}

@end

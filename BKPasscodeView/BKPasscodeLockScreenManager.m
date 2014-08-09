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

@property (strong, nonatomic) UIWindow          *lockScreenWindow;
@property (strong, nonatomic) UIWindow          *mainWindow;
@property (strong, nonatomic) UIView            *blindView;

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

- (UIWindow *)lockScreenWindow
{
    if (nil == _lockScreenWindow) {
        _lockScreenWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    }
    return _lockScreenWindow;
}

- (void)showLockScreen:(BOOL)animated
{
    NSAssert(self.delegate, @"delegate is not assigned.");
    
    if (_lockScreenWindow && _lockScreenWindow.rootViewController) {
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
    if ([self.delegate respondsToSelector:@selector(lockScreenManagerBlindView:)]) {
        self.blindView = [self.delegate lockScreenManagerBlindView:self];
    }
    
    if (nil == self.blindView) {
        self.blindView = [[UIView alloc] init];
        self.blindView.backgroundColor = [UIColor whiteColor];
    }
    
    self.blindView.frame = self.mainWindow.bounds;
    self.blindView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    [self.mainWindow addSubview:self.blindView];
    
    // resign key window
    [self.mainWindow resignKeyWindow];
    
    // set dummy view controller as root view controller
    BKPasscodeDummyViewController *dummyViewController = [[BKPasscodeDummyViewController alloc] init];
    self.lockScreenWindow.rootViewController = dummyViewController;
    [self.lockScreenWindow makeKeyAndVisible];
    
    // present lock screen
    UIViewController *lockScreenViewController = [self.delegate lockScreenManagerPasscodeViewController:self];
    [self.lockScreenWindow.rootViewController presentViewController:lockScreenViewController animated:animated completion:nil];
    
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
    self.lockScreenWindow.rootViewController = nil;
    self.lockScreenWindow = nil;
    
    [self.mainWindow makeKeyAndVisible];
    self.mainWindow = nil;
}

@end

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

@property (nonatomic) BOOL                      activated;
@property (strong, nonatomic) UIWindow          *lockScreenWindow;

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

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(didReceiveDidEnterBackgroundNotification:)
                                                     name:UIApplicationDidEnterBackgroundNotification
                                                   object:nil];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (UIWindow *)lockScreenWindow
{
    if (nil == _lockScreenWindow) {
        _lockScreenWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    }
    return _lockScreenWindow;
}

- (void)activate
{
    NSAssert(self.delegate, @"delegate must be set before activate");
    
    self.activated = YES;
}

- (void)deactivate
{
    self.activated = NO;
}

- (void)didReceiveDidEnterBackgroundNotification:(NSNotification *)aNotification
{
    if (NO == self.isActivated) {
        return;
    }
    
    if ([self.delegate respondsToSelector:@selector(lockScreenManagerShouldShowLockScreen:)]) {
        if (NO == [self.delegate lockScreenManagerShouldShowLockScreen:self]) {
            return;
        }
    }
    
    [self showLockScreenNow:NO];
}

- (void)showLockScreenNow:(BOOL)animated
{
    NSAssert(self.delegate, @"delegate is not assigned.");
    NSAssert(self.isActivated, @"manager is not activated.");
    
    if (_lockScreenWindow && _lockScreenWindow.rootViewController) {
        return;
    }
    
    BKPasscodeDummyViewController *dummyViewController = [[BKPasscodeDummyViewController alloc] init];
    self.lockScreenWindow.rootViewController = dummyViewController;
    
    [self.lockScreenWindow makeKeyAndVisible];
    
    UIViewController *lockScreenViewController = [self.delegate lockScreenManagerPasscodeViewController:self];
    
    [self.lockScreenWindow.rootViewController presentViewController:lockScreenViewController animated:animated completion:nil];
    
    dummyViewController.delegate = self;
}

- (void)dummyViewControllerDidAppear:(BKPasscodeDummyViewController *)aViewController
{
    [self.lockScreenWindow resignKeyWindow];
    self.lockScreenWindow.rootViewController = nil;
    self.lockScreenWindow = nil;
}

@end

//
//  MainViewController.m
//  BKPasscodeViewDemo
//
//  Created by Byungkook Jang on 2014. 4. 26..
//  Copyright (c) 2014년 Byungkook Jang. All rights reserved.
//

#import "MainViewController.h"
#import "AppDelegate.h"

@interface MainViewController ()

@end

@implementation MainViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        self.passcode = @"1234";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _simplePasscodeSwitch = [[UISwitch alloc] init];
    [_simplePasscodeSwitch setOn:YES];
    
    _customizeAppearanceSwitch = [[UISwitch alloc] init];
    [_customizeAppearanceSwitch setOn:NO];
    
    _lockWhenEnterBackgroundSwitch = [[UISwitch alloc] init];
    [_lockWhenEnterBackgroundSwitch setOn:NO];
    
    _authWithTouchIDFirstSwitch = [[UISwitch alloc] init];
    [_authWithTouchIDFirstSwitch setOn:YES];
    
    self.title = @"BKPasscodeViewDemo";
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"reuseIdentifier"];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 4;
    } else if (section == 1) {
        return 4;
    } else {
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"reuseIdentifier" forIndexPath:indexPath];
    cell.accessoryView = nil;
    cell.selectionStyle = UITableViewCellSelectionStyleDefault;
    
    cell.textLabel.numberOfLines = 0;
    
    switch (indexPath.section) {
        case 0:
            if (indexPath.row == 0) {
                cell.textLabel.text = @"Set passcode";
            } else if (indexPath.row == 1) {
                cell.textLabel.text = @"Change passcode";
            } else if (indexPath.row == 2) {
                cell.textLabel.text = @"Check passcode";
            } else if (indexPath.row == 3) {
                cell.textLabel.text = @"Show lock screen";
            }
            break;
            
        case 1:
            if (indexPath.row == 0) {
                cell.textLabel.text = @"Use simple passcode";
                cell.accessoryView = self.simplePasscodeSwitch;
            } else if (indexPath.row == 1) {
                cell.textLabel.text = @"Customize appearance";
                cell.accessoryView = self.customizeAppearanceSwitch;
            } else if (indexPath.row == 2) {
                cell.textLabel.text = @"Lock when enter background";
                cell.accessoryView = self.lockWhenEnterBackgroundSwitch;
            } else {
                cell.textLabel.text = @"Auth with Touch ID first if available";
                cell.accessoryView = self.authWithTouchIDFirstSwitch;
            }
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            break;
    }
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    if (section == 3) {
        return @"Default password is 1234";
    }
    return nil;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section < 3) {
        return indexPath;
    }
    return nil;
}

- (BKPasscodeViewController *)createPasscodeViewController
{
    if (self.customizeAppearanceSwitch.isOn) {
        return [[BKCustomPasscodeViewController alloc] initWithNibName:nil bundle:nil];
    } else {
        return [[BKPasscodeViewController alloc] initWithNibName:nil bundle:nil];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        
        switch (indexPath.row) {
            case 0:
                [self presentPasscodeViewControllerWithType:BKPasscodeViewControllerNewPasscodeType];
                break;
            case 1:
                [self presentPasscodeViewControllerWithType:BKPasscodeViewControllerChangePasscodeType];
                break;
            case 2:
                [self presentPasscodeViewControllerWithType:BKPasscodeViewControllerCheckPasscodeType];
                break;
            case 3:
            {
                [tableView deselectRowAtIndexPath:indexPath animated:YES];
                
                self.showingLockScreenManually = YES;
                
                [[BKPasscodeLockScreenManager sharedManager] showLockScreen:YES];
                
                self.showingLockScreenManually = NO;
                
                break;
            }
            default:
                break;
        }
    }
}

- (void)presentPasscodeViewControllerWithType:(BKPasscodeViewControllerType)type
{
    BKPasscodeViewController *viewController = [self createPasscodeViewController];
    viewController.delegate = self;
    viewController.type = type;

    // Passcode style (numeric or ASCII)
    viewController.passcodeStyle = (self.simplePasscodeSwitch.isOn) ? BKPasscodeInputViewNumericPasscodeStyle : BKPasscodeInputViewNormalPasscodeStyle;
    
    // Setup Touch ID manager
    BKTouchIDManager *touchIDManager = [[BKTouchIDManager alloc] initWithKeychainServiceName:BKPasscodeKeychainServiceName];
    touchIDManager.promptText = @"BKPasscodeView Touch ID Demo";
    viewController.touchIDManager = touchIDManager;
    
    viewController.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(passcodeViewCloseButtonPressed:)];
    
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:viewController];
    
    if (self.authWithTouchIDFirstSwitch.isOn && viewController.type == BKPasscodeViewControllerCheckPasscodeType) {
        
        // To prevent duplicated selection before showing Touch ID user interface.
        self.tableView.userInteractionEnabled = NO;
        
        // Show Touch ID user interface
        [viewController startTouchIDAuthenticationIfPossible:^(BOOL prompted) {
            
            // Enable user interaction
            self.tableView.userInteractionEnabled = YES;
            
            // If Touch ID is unavailable or disabled, present passcode view controller for manual input.
            if (prompted) {
                NSIndexPath *selectedIndexPath = [self.tableView indexPathForSelectedRow];
                if (selectedIndexPath) {
                    [self.tableView deselectRowAtIndexPath:selectedIndexPath animated:YES];
                }
            } else {
                [self presentViewController:navController animated:YES completion:nil];
            }
        }];
        
    } else {
        
        [self presentViewController:navController animated:YES completion:nil];
    }
}

- (void)passcodeViewCloseButtonPressed:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - BKPasscodeViewControllerDelegate

- (void)passcodeViewController:(BKPasscodeViewController *)aViewController authenticatePasscode:(NSString *)aPasscode resultHandler:(void (^)(BOOL))aResultHandler
{
    if ([aPasscode isEqualToString:self.passcode]) {

        self.lockUntilDate = nil;
        self.failedAttempts = 0;
        
        aResultHandler(YES);
    } else {
        aResultHandler(NO);
    }
}

- (void)passcodeViewControllerDidFailAttempt:(BKPasscodeViewController *)aViewController
{
    self.failedAttempts++;
    
    if (self.failedAttempts > 5) {
        
        NSTimeInterval timeInterval = 60;
        
        if (self.failedAttempts > 6) {
            
            NSUInteger multiplier = self.failedAttempts - 6;
            
            timeInterval = (5 * 60) * multiplier;
            
            if (timeInterval > 3600 * 24) {
                timeInterval = 3600 * 24;
            }
        }
        
        self.lockUntilDate = [NSDate dateWithTimeIntervalSinceNow:timeInterval];
    }
}

- (NSUInteger)passcodeViewControllerNumberOfFailedAttempts:(BKPasscodeViewController *)aViewController
{
    return self.failedAttempts;
}

- (NSDate *)passcodeViewControllerLockUntilDate:(BKPasscodeViewController *)aViewController
{
    return self.lockUntilDate;
}

- (void)passcodeViewController:(BKPasscodeViewController *)aViewController didFinishWithPasscode:(NSString *)aPasscode
{
    switch (aViewController.type) {
        case BKPasscodeViewControllerNewPasscodeType:
        case BKPasscodeViewControllerChangePasscodeType:
            self.passcode = aPasscode;
            self.failedAttempts = 0;
            self.lockUntilDate = nil;
            break;
        default:
            break;
    }
    
    [aViewController dismissViewControllerAnimated:YES completion:nil];
}

@end

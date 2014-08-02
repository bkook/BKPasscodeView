//
//  MainViewController.m
//  BKPasscodeViewDemo
//
//  Created by Byungkook Jang on 2014. 4. 26..
//  Copyright (c) 2014년 Byungkook Jang. All rights reserved.
//

#import "MainViewController.h"

@interface MainViewController ()

@property (strong, nonatomic) UISwitch          *simplePasscodeSwitch;
@property (strong, nonatomic) UISwitch          *customizeAppearanceSwitch;

@property (strong, nonatomic) NSString          *passcode;

@property (nonatomic) NSUInteger                failedAttempts;
@property (strong, nonatomic) NSDate            *lockUntilDate;

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
    
    self.title = @"BKPasscodeViewDemo";
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"reuseIdentifier"];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 5;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"reuseIdentifier" forIndexPath:indexPath];
    cell.accessoryView = nil;
    cell.selectionStyle = UITableViewCellSelectionStyleDefault;
    
    switch (indexPath.section) {
        case 0:
            cell.textLabel.text = @"Set passcode";
            break;
        case 1:
            cell.textLabel.text = @"Change passcode";
            break;
        case 2:
            cell.textLabel.text = @"Check passcode";
            break;
        case 3:
            cell.textLabel.text = @"Use simple passcode";
            cell.accessoryView = self.simplePasscodeSwitch;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            break;
        case 4:
            cell.textLabel.text = @"Customize appearance";
            cell.accessoryView = self.customizeAppearanceSwitch;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            break;
    }
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    if (section == 4) {
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
    BKPasscodeViewController *viewController = [self createPasscodeViewController];
    viewController.delegate = self;
    
    switch (indexPath.section) {
        case 0:
            viewController.type = BKPasscodeViewControllerNewPasscodeType;
            break;
        case 1:
            viewController.type = BKPasscodeViewControllerChangePasscodeType;
            break;
        case 2:
            viewController.type = BKPasscodeViewControllerCheckPasscodeType;
            break;
        default:
            break;
    }

    viewController.passcodeStyle = (self.simplePasscodeSwitch.isOn) ? BKPasscodeInputViewNumericPasscodeStyle : BKPasscodeInputViewNormalPasscodeStyle;
    
    viewController.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(passcodeViewCloseButtonPressed:)];
    
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:viewController];
    
    [self presentViewController:navController animated:YES completion:nil];
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
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end

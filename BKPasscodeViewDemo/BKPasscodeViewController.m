//
//  BKPasscodeViewController.m
//  BKPasscodeViewDemo
//
//  Created by Byungkook Jang on 2014. 4. 20..
//  Copyright (c) 2014년 Byungkook Jang. All rights reserved.
//

#import "BKPasscodeViewController.h"
#import "BKShiftingPasscodeInputView.h"

@interface BKPasscodeViewController ()

@property (strong, nonatomic) BKShiftingPasscodeInputView   *shiftingPasscodeInputView;

@end

@implementation BKPasscodeViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveKeyboardWillShowNotification:) name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveKeyboardWillHideNotification:) name:UIKeyboardWillHideNotification object:nil];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.view setBackgroundColor:[UIColor colorWithRed:0.94 green:0.94 blue:0.96 alpha:1]];
    
    self.shiftingPasscodeInputView = [[BKShiftingPasscodeInputView alloc] initWithFrame:self.view.bounds];
    self.shiftingPasscodeInputView.passcodeInputViewDelegate = self;
    self.shiftingPasscodeInputView.passcodeInputView.title = @"암호 입력";
    self.shiftingPasscodeInputView.passcodeInputView.message = @"암호가 일치하지 않습니다.\n다시 시도하십시오.";
    self.shiftingPasscodeInputView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
//    self.shiftingPasscodeInputView.passcodeInputView.passcodeStyle = BKPasscodeInputViewNormalPasscodeStyle;
    
    [self.view addSubview:self.shiftingPasscodeInputView];
    
    [self.shiftingPasscodeInputView becomeFirstResponder];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIRectEdge)edgesForExtendedLayout
{
    return UIRectEdgeNone;
}

- (void)passcodeInputViewDidFinish:(BKPasscodeInputView *)aInputView
{
    NSLog(@"passcodeInputViewDidFinish:");
    
    [self.shiftingPasscodeInputView shiftPasscodeInputViewWithDirection:BKShiftingDirectionForward andConfigurationBlock:^(BKPasscodeInputView *inputView) {
        
        inputView.title = @"title";
        inputView.message = @"message";

    }];
}

- (void)didReceiveKeyboardWillShowNotification:(NSNotification *)notification
{
    NSLog(@"didReceiveKeyboardWillShowNotification");
    
    CGRect keyboardRect = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    keyboardRect = [self.view convertRect:keyboardRect fromView:nil];
    
    CGRect rect = self.view.bounds;
    rect.size.height -= keyboardRect.size.height;
    self.shiftingPasscodeInputView.frame = rect;
}

- (void)didReceiveKeyboardWillHideNotification:(NSNotification *)notification
{
    NSLog(@"didReceiveKeyboardWillHideNotification");
    
    self.shiftingPasscodeInputView.frame = self.view.bounds;
}

@end

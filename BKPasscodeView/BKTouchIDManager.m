//
//  BKTouchIDManager.m
//  BKPasscodeViewDemo
//
//  Created by Byungkook Jang on 2014. 10. 12..
//  Copyright (c) 2014년 Byungkook Jang. All rights reserved.
//

#import "BKTouchIDManager.h"
#import <LocalAuthentication/LocalAuthentication.h>

@interface BKTouchIDManager ()

@property (nonatomic, strong) dispatch_queue_t  queue;

@property (nonatomic, strong) NSString          *keychainServiceName;

@end

@implementation BKTouchIDManager

- (instancetype)initWithKeychainServiceName:(NSString *)serviceName
{
    self = [super init];
    if (self) {
        
        _queue = dispatch_queue_create("BKTouchIDManagerQueue", DISPATCH_QUEUE_SERIAL);
        
        NSParameterAssert(serviceName);
        
        self.keychainServiceName = serviceName;
    }
    return self;
}

+ (BOOL)canUseTouchID
{
    if (![LAContext class]) {
        return NO;
    }
    
    LAContext *context = [[LAContext alloc] init];
    
    NSError *error = nil;
    BOOL result = [context canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&error];
    
    return result;
}

- (void)savePasscode:(NSString *)passcode completionBlock:(void(^)(BOOL success))completionBlock
{
    NSParameterAssert(passcode);
    
    if (NO == [[self class] canUseTouchID]) {
        if (completionBlock) {
            completionBlock(NO);
        }
        return;
    }
    
    NSString *serviceName = self.keychainServiceName;
    NSData *passcodeData = [passcode dataUsingEncoding:NSUTF8StringEncoding];
    
    dispatch_async(self.queue, ^{
        
        // try to update first
        BOOL success = [[self class] updateKeychainItemWithServiceName:serviceName data:passcodeData];
        
        if (success) {
            if (completionBlock) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    completionBlock(YES);
                });
            }
            return;
        }
        
        // try deleting when update failed (workaround for iOS 8 bug)
        [[self class] deleteKeychainItemWithServiceName:serviceName];
        
        // try add
        success = [[self class] addKeychainItemWithServiceName:serviceName data:passcodeData];
        
        if (completionBlock) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completionBlock(success);
            });
        }
    });
}

- (void)loadPasscodeWithCompletionBlock:(void (^)(NSString *))completionBlock
{
    if (NO == [[self class] canUseTouchID]) {
        if (completionBlock) {
            completionBlock(nil);
        }
        return;
    }
    
    NSMutableDictionary *query = [NSMutableDictionary dictionaryWithDictionary:@{ (__bridge id)kSecClass: (__bridge id)kSecClassGenericPassword,
                                                                                  (__bridge id)kSecAttrService: self.keychainServiceName,
                                                                                  (__bridge id)kSecReturnData: @YES }];
    
    if (self.promptText) {
        query[(__bridge id)kSecUseOperationPrompt] = self.promptText;
    }
    
    dispatch_async(self.queue, ^{
        
        CFTypeRef dataTypeRef = NULL;
        
        OSStatus status = SecItemCopyMatching((__bridge CFDictionaryRef)(query), &dataTypeRef);
        
        NSString *result = nil;
        
        if (status == errSecSuccess) {
            
            NSData *resultData = ( __bridge_transfer NSData *)dataTypeRef;
            result = [[NSString alloc] initWithData:resultData encoding:NSUTF8StringEncoding];
        }
        
        if (completionBlock) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completionBlock(result);
            });
        }
    });
}

- (void)deletePasscodeWithCompletionBlock:(void (^)(BOOL))completionBlock
{
    dispatch_async(self.queue, ^{
        
        BOOL success = [[self class] deleteKeychainItemWithServiceName:self.keychainServiceName];
        
        if (completionBlock) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completionBlock(success);
            });
        }
    });
}

#pragma mark - Static Methods

+ (BOOL)addKeychainItemWithServiceName:(NSString *)serviceName data:(NSData *)data
{
    CFErrorRef error = NULL;
    SecAccessControlRef sacObject;
    
    sacObject = SecAccessControlCreateWithFlags(kCFAllocatorDefault,
                                                kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly,
                                                kSecAccessControlUserPresence, &error);
    
    if (sacObject == NULL || error != NULL) {
        return NO;
    }
    
    // we want the operation to fail if there is an item which needs authentication so we will use
    // kSecUseNoAuthenticationUI
    NSDictionary *attributes = @{ (__bridge id)kSecClass: (__bridge id)kSecClassGenericPassword,
                                  (__bridge id)kSecAttrService: serviceName,
                                  (__bridge id)kSecValueData: data,
                                  (__bridge id)kSecUseNoAuthenticationUI: @YES,
                                  (__bridge id)kSecAttrAccessControl: (__bridge_transfer id)sacObject };
    
    OSStatus status = SecItemAdd((__bridge CFDictionaryRef)attributes, nil);
    
    return (status == errSecSuccess);
}

+ (BOOL)updateKeychainItemWithServiceName:(NSString *)serviceName data:(NSData *)data
{
    NSDictionary *query = @{ (__bridge id)kSecClass: (__bridge id)kSecClassGenericPassword,
                             (__bridge id)kSecAttrService: serviceName };
    
    NSDictionary *changes = @{ (__bridge id)kSecValueData: data };
    
    OSStatus status = SecItemUpdate((__bridge CFDictionaryRef)query, (__bridge CFDictionaryRef)changes);
    
    return (status == errSecSuccess);
}

+ (BOOL)deleteKeychainItemWithServiceName:(NSString *)serviceName
{
    NSDictionary *query = @{ (__bridge id)kSecClass: (__bridge id)kSecClassGenericPassword,
                             (__bridge id)kSecAttrService: serviceName
                             };
    
    OSStatus status = SecItemDelete((__bridge CFDictionaryRef)(query));

    return (status == errSecSuccess || status == errSecItemNotFound);
}

@end

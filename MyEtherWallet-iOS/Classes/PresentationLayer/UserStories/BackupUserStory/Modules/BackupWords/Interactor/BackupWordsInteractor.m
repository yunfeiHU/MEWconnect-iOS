//
//  BackupWordsInteractor.m
//  MyEtherWallet-iOS
//
//  Created by Mikhail Nikanorov on 23/05/2018.
//  Copyright © 2018 MyEtherWallet, Inc. All rights reserved.
//

@import UIKit;

#import "BackupWordsInteractor.h"

#import "BackupWordsInteractorOutput.h"

@interface BackupWordsInteractor ()
@property (nonatomic, strong) NSArray <NSString *> *mnemonics;
@property (nonatomic, strong) AccountPlainObject *account;
@end

@implementation BackupWordsInteractor

#pragma mark - BackupWordsInteractorInput

- (void)configurateWithMnemonics:(NSArray<NSString *> *)mnemonics ofAccount:(AccountPlainObject *)account {
  _account = account;
  _mnemonics = mnemonics;
}

- (NSArray <NSString *> *) recoveryMnemonicsWords {
  return _mnemonics;
}

- (AccountPlainObject *) obtainAccount {
  return self.account;
}

- (void) subscribeToEvents {
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_userDidTakeScreenshort:) name:UIApplicationUserDidTakeScreenshotNotification object:nil];
}

- (void) unsubscribeFromEvents {
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - NSNotifications

- (void) _userDidTakeScreenshort:(NSNotification *)notification {
  [self.output userDidTakeScreenshot];
}

@end
